-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vholib;

entity tb_several_delays is
end entity tb_several_delays;

architecture tb_several_delays_rtl of tb_several_delays is

  constant WIDTH_g          : natural := 8;
  constant DELAY_g          : natural := 8;
  constant MEMORY_TYPE_g    : string  := "AUTO";
  constant REGISTER_FIRST_g : natural := 1;
  constant REGISTER_LAST_g  : natural := 1;

  constant tclk : time := 1 us;
  constant tmax : time := 60 us;

  signal clk              : std_logic                            := '0';
  signal reset            : std_logic                            := '0';
  signal enable           : std_logic                            := '0';
  signal datain           : std_logic_vector(WIDTH_g-1 downto 0) := (others => '0');
  signal dataout0         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout1         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout2         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout3         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout4         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout5         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout6         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout7         : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout0_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout1_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout2_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout3_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout4_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout5_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout6_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout7_vho     : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout0_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout1_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout2_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout3_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout4_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout5_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout6_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal dataout7_vho_sdo : std_logic_vector(WIDTH_g-1 downto 0);
  signal wire_together    : std_logic_vector(WIDTH_g-1 downto 0);
  signal count            : std_logic_vector(WIDTH_g-1 downto 0);

begin  -- architecture tb_several_delays_rtl

  -- purpose: generates enables ib falling clock edge
  -- type   : sequential
  -- inputs : clk, reset, count
  -- outputs: enable
  enable_gen : process (clk, reset) is
  begin  -- process enable_gen
    if reset = '1' then                 -- asynchronous reset (active high)
      enable   <= '1';
    elsif falling_edge(clk) then        -- rising clock edge
      if unsigned(count) < 17 or unsigned(count) > 22 then
        enable <= '1';
      else
        enable <= '0';
      end if;

    end if;
  end process enable_gen;


  DUT_rtl : entity work.several_delays
    generic map (
      WIDTH_g          => WIDTH_g,
      DELAY_g          => DELAY_g,
      MEMORY_TYPE_g    => MEMORY_TYPE_g,
      REGISTER_FIRST_g => REGISTER_FIRST_g,
      REGISTER_LAST_g  => REGISTER_LAST_g)
    port map (
      clk              => clk,
      reset            => reset,
      enable           => enable,
      datain           => datain,
      dataout0         => dataout0,
      dataout1         => dataout1,
      dataout2         => dataout2,
      dataout3         => dataout3,
      dataout4         => dataout4,
      dataout5         => dataout5,
      dataout6         => dataout6,
      dataout7         => dataout7);

  DUT_vho : entity vholib.several_delays
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      datain   => datain,
      dataout0 => dataout0_vho,
      dataout1 => dataout1_vho,
      dataout2 => dataout2_vho,
      dataout3 => dataout3_vho,
      dataout4 => dataout4_vho,
      dataout5 => dataout5_vho,
      dataout6 => dataout6_vho,
      dataout7 => dataout7_vho);

  DUT_vho_sdo : entity vholib.several_delays
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      datain   => datain,
      dataout0 => dataout0_vho_sdo,
      dataout1 => dataout1_vho_sdo,
      dataout2 => dataout2_vho_sdo,
      dataout3 => dataout3_vho_sdo,
      dataout4 => dataout4_vho_sdo,
      dataout5 => dataout5_vho_sdo,
      dataout6 => dataout6_vho_sdo,
      dataout7 => dataout7_vho_sdo);

  datain <= count(WIDTH_g-1 downto 0);

  -- check that all outputs are the same
  wire_together <= dataout0;
  wire_together <= dataout1;
  wire_together <= dataout2;
  wire_together <= dataout3;
  wire_together <= dataout4;
  wire_together <= dataout5;
  wire_together <= dataout6;
  wire_together <= dataout7;
-- wire_together <= dataout0_vho;
-- wire_together <= dataout1_vho;
-- wire_together <= dataout2_vho;
-- wire_together <= dataout3_vho;
-- wire_together <= dataout4_vho;
-- wire_together <= dataout5_vho;
-- wire_together <= dataout6_vho;
-- wire_together <= dataout7_vho;
 wire_together <= dataout0_vho_sdo;
  wire_together <= dataout1_vho_sdo;
  wire_together <= dataout2_vho_sdo;
  wire_together <= dataout3_vho_sdo;
  wire_together <= dataout4_vho_sdo;
  wire_together <= dataout5_vho_sdo;
  wire_together <= dataout6_vho_sdo;
  wire_together <= dataout7_vho_sdo;

  check_identity : process (clk) is
  begin  -- process check_identity
    assert wire_together = dataout0 report "mismatch" severity warning;
  end process check_identity;


  incr : process ( clk, reset )
  begin  -- process incr
    if reset = '1' then                 -- asynchronous reset (active high)
      count <= (others => '0');
    elsif clk 'event and clk = '1' then  -- rising clock edge
      count <= std_logic_vector(unsigned(count)+1);  -- count must be signed or unsigned
    end if;
  end process incr;

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
    wait for tclk*30;
    reset <= '1';
    wait for tclk*2;
    reset <= '0';
    wait;
  end process resetgen;

  -- purpose: stops simulations at time tmax
  stopper : process
  begin  -- process stopper
    wait for tmax;
    assert false report "simulation finished" severity failure;
  end process stopper;




end architecture tb_several_delays_rtl;

-------------------------------------------------------------------------------
