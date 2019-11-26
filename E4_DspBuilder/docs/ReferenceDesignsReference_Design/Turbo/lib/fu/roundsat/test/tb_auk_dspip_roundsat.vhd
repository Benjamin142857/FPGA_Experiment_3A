-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_auk_dspip_roundsat is
end entity tb_auk_dspip_roundsat;

architecture tb_auk_dspip_roundsat_rtl of tb_auk_dspip_roundsat is

  constant IN_WIDTH_g      : natural := 5;
  constant OUT_WIDTH_g     : natural := 3;
  constant ROUNDING_TYPE_g : string  := "TRUNCATE_LOW";

  constant tclk : time := 1 us;
  constant tmax : time := 200 us;

  signal clk          : std_logic                               := '0';
  signal reset        : std_logic                               := '0';
  signal enable       : std_logic                               := '0';
  signal datain       : std_logic_vector(IN_WIDTH_g-1 downto 0) := (others => '0');
  signal datain_dly   : std_logic_vector(IN_WIDTH_g-1 downto 0) := (others => '0');
  signal round        : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal round0       : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal round_up_sym : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal conv_round   : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal saturate     : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal saturate_sym : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal illegal      : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal trunc_low    : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal trunc_high   : std_logic_vector(OUT_WIDTH_g-1 downto 0);
  signal count     : signed(IN_WIDTH_g-1 downto 0);

begin  -- architecture tb_auk_dspip_roundsat_rtl

  DUT1 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "ROUND_UP")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => round);

  DUT2 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "ROUND0")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => round0);

  DUT25 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "ROUND_UP_SYM")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => round_up_sym);

  DUT3 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "CONV_ROUND")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => conv_round);

  DUT4 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "SATURATE")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => saturate);

  DUT5 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "SATURATE_SYM")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => saturate_sym);

  DUT6 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "ILLEGAL")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => illegal);

  DUT8 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "TRUNCATE_LOW")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => trunc_low);

  DUT9 : entity work.auk_dspip_roundsat
    generic map (
      IN_WIDTH_g      => IN_WIDTH_g,
      OUT_WIDTH_g     => OUT_WIDTH_g,
      ROUNDING_TYPE_g => "TRUNCATE_HIGH")
    port map (
      clk             => clk,
      reset           => reset,
      enable          => enable,
      datain          => datain,
      dataout         => trunc_high);



  -- purpose: counter
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: 
  increment : process (clk, reset) is
  begin  -- process increment
    if reset = '1' then                 -- asynchronous reset (active high)
      count <= to_signed(-2**(count'length-1), count'length);
    elsif rising_edge(clk) then         -- rising clock edge
      count <= count+1;
    end if;
  end process increment;

  delay_reg: process (clk, reset) is
  begin  -- process delay_reg
    if reset = '1' then                 -- asynchronous reset (active high)
      datain_dly <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        datain_dly <= datain;
      end if;
    end if;
  end process delay_reg;

  datain <= std_logic_vector(count);

  clkgen : process
  begin  -- process clkgen
    clk <= '0';
    wait for tclk/2;
    clk <= '1';
    wait for tclk/2;
  end process clkgen;

  resetgen : process
  begin  -- process resetgen
    reset <= '0';
    wait for tclk/4;
    reset <= '1';
    wait for tclk*2;
    reset <= '0';
    wait for tclk*130;
    reset <= '1';
    wait for tclk*2;
    reset <= '0';
    wait;
  end process resetgen;

  enablegen : process
  begin  -- process enablegen
    enable <= '1';
    wait for tclk/104;
    enable <= '0';
    wait for tclk*2;
    enable <= '1';
    wait for tclk*70;
    enable <= '0';
    wait for tclk*2;
    enable <= '1';
    wait;
  end process enablegen;

  -- purpose: stops simulations at time tmax
  stopper : process
  begin  -- process stopper
    wait for tmax;
    assert false report "simulation finished" severity failure;
  end process stopper;




end architecture tb_auk_dspip_roundsat_rtl;

-------------------------------------------------------------------------------
