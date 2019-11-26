-- changes to make: use only memory type and make coeff rows a subtype,
-- regenrate matlab matrix to swap rows and columns, redefine sel as natural
-- with a range, remove the case statement

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.decimation_type_pkg.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity decimation_fir is
  generic (
    engine_size_c   : natural := 32;
    din_width_c     : natural := 25;
    coeff_width_c   : natural := 27;
    channel_width_c : natural := 2;
    num_chan_c      : natural := 4;
    dout_width_c    : natural := 59);  --  =  din_width_c+1+coeff_width_c+ceil(log2(engine_size_c))
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    in_data   : in  signed(din_width_c-1 downto 0);
    in_valid  : in  std_logic;
    in_chan   : in  unsigned(channel_width_c-1 downto 0);
    out_data  : out signed(dout_width_c-1 downto 0);
    out_chan  : out unsigned(channel_width_c-1 downto 0);
    out_valid : out std_logic);
end entity decimation_fir;

architecture fir of decimation_fir is

--  constant pipeline_c     : natural := 4;
  constant output_delay_c    : natural := pipeline_c+2;

  signal taps                : tap_array_type(0 to engine_size_c-1);
  signal multout             : multout_array_type;
  signal sumof2              : sumof2_array_type;
  signal sumof2_2D           : altera_mf_logic_2D(0 to engine_size_c/2-1, sumof2_bitwidth_c-1 downto 0);
  signal my_sumof2_2D        : my_altera_mf_logic_2D(0 to engine_size_c/2-1);
  signal reg_in_data         : signed(din_width_c-1 downto 0);
  signal reg_in_valid        : std_logic;
  signal reg_in_chan         : unsigned(channel_width_c-1 downto 0);
  signal sel                 : natural range 0 to rate_c - 1;
  signal chan_sig            : shift_chan_type(0 to output_delay_c-1);
  signal valid_sig           : shift_valid_type(0 to output_delay_c-1);
  signal cnt                 : natural;  -- counts towards rate factor
  signal en                  : std_logic;
  signal load, load_delayed  : std_logic;
--  signal accum_cnt        : natural;  -- counter to generate accumulator reload signal
  signal parallel_adder_out  : std_logic_vector(adderout_width_c-1 downto 0);
  -- delay period_in_c cycles
  signal valid_sig2          : shift_valid_type(0 to period_in_c);
  signal chan_sig2           : shift_chan_type(0 to period_in_c-1);
  signal accum_data_in       : signed(dout_width_c-1 downto 0);

  component shift_taps is
    generic (
      din_width_c         : natural;
      entire_tap_length_c : natural;
      tap_depth_c         : natural;
      num_taps_c          : natural);
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      en        : in  std_logic;
      data_in   : in  signed(din_width_c-1 downto 0);
      data_taps : out tap_array_type(0 to num_taps_c-1);
      data_out  : out signed(din_width_c-1 downto 0)
      );
  end component shift_taps;

  component parallel_add
    generic (
      width            : natural := 4;  -- input data width
      size             : natural := 2;  -- number of input data ports
      widthr           : natural := 4;  -- output data width
      shift            : natural := 0;
      msw_subtract     : string  := "NO";
      representation   : string  := "SIGNED";
      pipeline         : natural := 4;  -- need to investigate how many
                                        -- pipeline stages are needed for fmax
      result_alignment : string  := "LSB";
      lpm_hint         : string  := "UNUSED";
      lpm_type         : string  := "parallel_add");
    port (
      data   : in  altera_mf_logic_2D(size - 1 downto 0, width- 1 downto 0);
      clock  : in  std_logic := '1';
      aclr   : in  std_logic := '0';
      clken  : in  std_logic := '1';
      result : out std_logic_vector(widthr - 1 downto 0));
  end component;

  component accum_sload
    generic (
      din_width_c : natural;
      num_delay_c : natural);
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      en       : in  std_logic;
      load     : in  std_logic;
      data_in  : in  signed(din_width_c-1 downto 0);
      data_out : out signed(din_width_c-1 downto 0)
      );
  end component;

  component coeff_rom
    generic
      (
        coeff_width_c : natural := 27;
        contents_c    : memory_t;
        rate_c        : natural := 4
        );
    port
      (
        addr : in  natural range 0 to rate_c - 1;
        q    : out word_t
        );

  end component;

-- convert integer coefficients into signed type
  function coeff_type_conv
    return memory_array_t is
    variable tmp : memory_array_t := (others => (others => (others => '0')));
  begin
    for i in 0 to engine_size_c-1 loop
      for j in 0 to rate_c - 1 loop
        tmp(i)(j) := word_t(to_signed(coeff_matrix_c(i, j), coeff_width_c));
      end loop;
    end loop;
    return tmp;
  end coeff_type_conv;

-- an engine_size_c by rate_c matrix; each row is used to initialize a coeff ROM
  constant coeff_matrix_signed_c : memory_array_t := coeff_type_conv;
  -- an engine_size_c by 1 vector, each element feeds a DSP block
  signal coeff_row           : coeff_row_signed_t;  

begin  -- architecture fir

  -- purpose: register input data and valid signal
  reg_input : process (clk, reset) is
  begin  -- process reg_input
    if reset = '1' then                 -- asynchronous reset (active high)
      reg_in_data  <= (others => '0');
      reg_in_valid <= '0';
      reg_in_chan  <= (others => '0');
    elsif rising_edge(clk) then
      reg_in_data  <= in_data;
      reg_in_valid <= in_valid;
      reg_in_chan  <= in_chan;
    end if;
  end process reg_input;

  -- enable signal here applies only to the specified fmax and input sample
  -- rate combination
  -- in more general case, en needs to be generated by internal counter, and
  -- should remain high if reg_in_valid deasserts to indicate don't care samples;
  -- en should deasserts when reg_in_valid deasserts to indicate pulsed input data
  en <= reg_in_valid;

  -- purpose: control select signal
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: sel
  -- period_in_c replaces n_c in interpolation fir
  sel_gen : process (clk, reset) is
  begin  -- process sel_gen
    if reset = '1' then                 -- asynchronous reset (active high)
      sel <= 0;
      cnt <= 0;
    elsif rising_edge(clk) and (reg_in_valid = '1') then
      if cnt < period_in_c-1 then
        cnt <= cnt + 1;
      else
        cnt <= 0;
      end if;
      if cnt = period_in_c-1 then
        if sel < rate_c-1 then
          sel <= sel + 1;
        else
          sel <= 0;
        end if;
--          else
--            sel <= sel; -- if cnt !=N-1, nothing happens
      end if;
    end if;
  end process sel_gen;

  -- generate delay taps
  tap_inst : component shift_taps
    generic map (
      din_width_c         => din_width_c,
      entire_tap_length_c => period_in_c*rate_c*(engine_size_c-1),
      num_taps_c          => engine_size_c-1,
      tap_depth_c         => period_in_c*rate_c)
    port map (
      clk       => clk,
      reset     => reset,
      en        => en,
      data_in   => reg_in_data,
      data_taps => taps(1 to engine_size_c-1));
  taps(0) <= reg_in_data;

  rom_gen : for i in 0 to engine_size_c-1 generate
    rom_inst : component coeff_rom
      generic map (
        coeff_width_c => coeff_width_c,
        contents_c    => coeff_matrix_signed_c(i),
        rate_c        => rate_c)
      port map (
        addr => sel,
        q    => coeff_row(i));
  end generate rom_gen;

  mult_map : for n in 0 to engine_size_c -1 generate
    mult : process (reset, clk) is
    begin  -- process mult
      if reset = '1' then
        multout(n) <= (others => '0');
      elsif rising_edge(clk) and (reg_in_valid = '1') then
        multout(n) <= resize(taps(n)*coeff_row(n), din_width_c+coeff_width_c);
      end if;
    end process mult;
  end generate mult_map;

  sumof2_gen : for k in 0 to engine_size_c/2-1 generate
    sumof2_add : process (multout(2*k), multout(2*k+1)) is
    begin  -- process sumof2_add
      sumof2(k) <= resize(multout(2*k), sumof2_bitwidth_c) + resize(multout(2*k+1), sumof2_bitwidth_c);
    end process sumof2_add;
  end generate sumof2_gen;

  -- convert adder tree input to altera_mf data type
  tmp_type : process(sumof2)
  begin  -- process tmp_type
    for k in 0 to engine_size_c/2-1 loop
      my_sumof2_2D(k) <= std_logic_vector(sumof2(k));
      for j in sumof2_bitwidth_c-1 downto 0 loop
        sumof2_2D(k, j) <= my_sumof2_2D(k)(j);
      end loop;  -- j
    end loop;  -- k
  end process tmp_type;


  -- the final adder tree is an engine_size_c/2-input adder
  adder_tree : component parallel_add
    generic map (
      width    => sumof2_bitwidth_c,
      size     => engine_size_c/2,
      widthr   => adderout_width_c,
      pipeline => pipeline_c)
    port map (
      clock  => clk,
      aclr   => reset,
      data   => sumof2_2D,
      result => parallel_adder_out);

  accum_sload_inst : component accum_sload
    generic map (
      din_width_c => dout_width_c,
      num_delay_c => period_in_c)
    port map (
      clk      => clk,
      reset    => reset,
      en       => en,
      load     => load_delayed,
      data_in  => accum_data_in,
      data_out => out_data);

  accum_data_in <= resize(signed(parallel_adder_out), dout_width_c);
  -- reload accumulator when applying phase 0
  -- the load signal to accumulator must account for parallel adder delay
  load_gen : process (clk, reset) is
  begin  -- process load_gen
    if reset = '1' then                 -- asynchronous reset (active high)
      load <= '0';
    elsif rising_edge(clk) and (en = '1') then
      if (sel = to_unsigned(0, rate_width_c)) then
        load <= '1';
      else
        load <= '0';
      end if;
    end if;
  end process load_gen;

  -- load(i.e.valid) and chan delayed by number of pipeline stages in adder tree plus
  -- (optional) delay in sel path
  delay_proc : process (clk, reset) is
  begin  -- process valid_delay_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      valid_sig(1 to output_delay_c-1) <= (others => '0');
      for m in 0 to output_delay_c-1 loop
        chan_sig(m) <= (others => '0');
      end loop;  -- k
    elsif rising_edge(clk) then
      valid_sig(1 to output_delay_c-1) <= valid_sig(0 to output_delay_c-2);
      chan_sig(1 to output_delay_c-1)  <= chan_sig(0 to output_delay_c-2);
      chan_sig(0)                      <= in_chan;
    end if;
  end process delay_proc;
  valid_sig(0) <= load;
  load_delayed <= valid_sig(output_delay_c-1);

  -- final output channel and valid signal needs to be delayed by period_in_c
  delay_proc2 : process (clk, reset) is
  begin  -- process valid_delay_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      valid_sig2(1 to period_in_c) <= (others => '0');
      for m in 0 to period_in_c-1 loop
        chan_sig2(m) <= (others => '0');
      end loop;  -- k
    elsif rising_edge(clk) then
      valid_sig2(1 to period_in_c)  <= valid_sig2(0 to period_in_c-1);
      chan_sig2(1 to period_in_c-1) <= chan_sig2(0 to period_in_c-2);
      chan_sig2(0)                  <= chan_sig(output_delay_c-1);
    end if;
  end process delay_proc2;
  valid_sig2(0) <= valid_sig(output_delay_c-1);
--  chan_sig2(0) <= chan_sig(output_delay_c-1);

--  out_valid <= valid_sig2(period_in_c);
  out_valid <= load_delayed;
  out_chan  <= chan_sig2(period_in_c-1);

--  out_valid <= reg_in_valid;
--  out_chan  <= reg_in_chan;
  
end architecture fir;
