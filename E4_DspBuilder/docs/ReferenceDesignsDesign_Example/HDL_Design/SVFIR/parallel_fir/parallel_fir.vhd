library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.parallel_type_pkg.all;

entity parallel_fir is
  generic (
    engine_size_c   : natural := 64;
    din_width_c     : natural := 25;
    coeff_width_c   : natural := 27;
    channel_width_c : natural := 4;
    num_chan_c      : natural := 12;
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
end entity parallel_fir;

architecture fir of parallel_fir is

  signal coeff        : coeff_array_type;
  signal taps         : tap_array_type(0 to 2*engine_size_c-1);
  signal preadder_out : preadder_array_type;
  signal sumof2       : sumof2_array_type;
  signal chainout     : chainout_array;
  signal reg_in_data  : signed(din_width_c-1 downto 0);
  signal reg_in_valid : std_logic;
  signal valid_sig    : shift_reg_type;
  signal reg_in_chan  : unsigned(channel_width_c-1 downto 0);
  signal chan_sig     : shift_chan_type;

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

  -- assign filter coefficient values
  coeff_map : for i in 0 to engine_size_c-1 generate
    coeff(i) <= to_signed(coeff_c(i), coeff_width_c);
  end generate coeff_map;

  -- generate delay taps
  delay_tap : component shift_taps
    generic map (
      din_width_c         => din_width_c,
      entire_tap_length_c => entire_tap_length_c,
      tap_depth_c         => tap_depth_c,
      num_taps_c          => num_taps_c)
    port map (
      clk       => clk,
      reset     => reset,
      en        => reg_in_valid,
      data_in   => reg_in_data,
      data_taps => taps(1 to tap_line_size_c-1));
--        data_out => 
  taps(0) <= reg_in_data;

  preadder_map : for j in 0 to engine_size_c-1 generate
    preadder_out(j) <= resize(taps(j), din_width_c + 1) + resize(taps(tap_line_size_c-1-j), din_width_c + 1);
  end generate preadder_map;

  first_mult : process (reset, clk) is
    variable current_adder_out : signed(chainout_bitwidth_c(0)-1 downto 0);
  begin  -- process mult
    if reset = '1' then
      current_adder_out := (others => '0');
    elsif rising_edge(clk) and (reg_in_valid = '1') then
      current_adder_out := preadder_out(0)*coeff(0);
    end if;
    chainout(0) <= resize(current_adder_out, dout_width_c);
  end process first_mult;

  mult_map : for n in 1 to engine_size_c -1 generate
    mult : process (reset, clk) is
      variable current_adder_out : signed(chainout_bitwidth_c(n)-1 downto 0);
    begin  -- process mult
      if reset = '1' then
        current_adder_out := (others => '0');
      elsif rising_edge(clk) and (reg_in_valid = '1') then
        current_adder_out := resize(chainout(n-1), chainout_bitwidth_c(n)) + resize(preadder_out(n)*coeff(n), chainout_bitwidth_c(n));
      end if;
      chainout(n) <= resize(current_adder_out, dout_width_c);
    end process mult;
  end generate mult_map;

  out_data <= chainout(engine_size_c-1);

  -- need to figure out latency

  delay_proc : process (clk, reset) is
  begin  -- process valid_delay_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      valid_sig(1 to tap_line_size_c-1) <= (others => '0');
      for m in 0 to tap_line_size_c-1 loop
        chan_sig(m) <= (others => '0');
      end loop;  -- k
    elsif rising_edge(clk) then
      valid_sig(1 to tap_line_size_c-1) <= valid_sig(0 to tap_line_size_c-2);
      chan_sig(1 to tap_line_size_c-1)  <= chan_sig(0 to tap_line_size_c-2);
      chan_sig(0) <= in_chan;
    end if;
  end process delay_proc;
  valid_sig(0) <= reg_in_valid;
--  chan_sig(0)  <= reg_in_chan;

  out_valid <= valid_sig(tap_line_size_c-1);
  out_chan <= chan_sig(tap_line_size_c-1);
  
end architecture fir;
