library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.systolic_type_pkg.all;

entity systolic_fir is
  generic (
    engine_size_c : natural := 32;
    din_width_c   : natural := 25;
    coeff_width_c : natural := 27;
    dout_width_c  : natural := 58);  --  =  din_width_c+1+coeff_width_c+ceil(log2(engine_size_c))
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    in_data   : in  signed(din_width_c-1 downto 0);
    in_valid  : in  std_logic;
    out_data  : out signed(dout_width_c-1 downto 0);
    out_valid : out std_logic);
end entity systolic_fir;

architecture fir of systolic_fir is

  signal coeff        : coeff_array;
  signal taps         : tap_array;
  signal preadder_out : preadder_array;
  signal chainout     : chainout_array;
  signal reg_in_data  : signed(din_width_c-1 downto 0);
  signal reg_in_valid : std_logic;
  signal valid_sig    : shift_reg_type;
  
  component double_delay is
    generic (
      width_c : natural);
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      din   : in  signed(width_c-1 downto 0);
      dout  : out signed(width_c-1 downto 0);
      en    : in  std_logic);
  end component double_delay;
  
begin  -- architecture fir

  -- purpose: register input data and valid signal
  reg_input : process (clk, reset) is
  begin  -- process reg_input
    if reset = '1' then                 -- asynchronous reset (active high)
      reg_in_data  <= (others => '0');
      reg_in_valid <= '0';
    elsif rising_edge(clk) then
      reg_in_data  <= in_data;
      reg_in_valid <= in_valid;
    end if;
  end process reg_input;

  -- assign filter coefficient values
  coeff_map : for i in 0 to engine_size_c-1 generate
    coeff(i) <= to_signed(coeff_c(i), coeff_width_c);
  end generate coeff_map;

  -- generate delay taps
  tap_map : for k in 1 to tap_line_size_c -1 generate
    delay_tap : component double_delay
      generic map (
        width_c => din_width_c)
      port map (
        clk   => clk,
        reset => reset,
        en    => reg_in_valid,
        din   => taps(k-1),
        dout  => taps(k));
  end generate tap_map;
  taps(0) <= reg_in_data;

  preadder_map : for j in 0 to engine_size_c-1 generate
--  preadder_map: for j in 0 to 0 generate
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
        -- modelsim complains width mismatch. had to use resize
        current_adder_out := resize(chainout(n-1), chainout_bitwidth_c(n)) + resize(preadder_out(n)*coeff(n), chainout_bitwidth_c(n));
      end if;
      chainout(n) <= resize(current_adder_out, dout_width_c);
    end process mult;
  end generate mult_map;

  out_data <= chainout(engine_size_c-1);

   -- need to figure out latency
  valid_delay_line : for m in 1 to 2*engine_size_c-1 generate
    valid_delay_proc : process (clk, reset) is
    begin  -- process valid_delay_proc
      if reset = '1' then               -- asynchronous reset (active high)
        valid_sig(m) <= '0';
      elsif rising_edge(clk) then
        valid_sig(m) <= valid_sig(m-1);
      end if;
    end process valid_delay_proc;
  end generate valid_delay_line;
  valid_sig(0) <= reg_in_valid;

  out_valid <= valid_sig(engine_size_c-1);

  
  
end architecture fir;
