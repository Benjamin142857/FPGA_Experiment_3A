-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;


-------------------------------------------------------------------------------

entity tb_auk_dspip_pfc is
end entity tb_auk_dspip_pfc;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

architecture tb_auk_dspip_pfc_rtl of tb_auk_dspip_pfc is

  constant tclk : time := 1 us;
  constant tmax : time := 1 ms;

  constant NUM_CHANNELS_g : integer := 5;
  constant POLY_FACTOR_g  : integer := 3;
  constant DATA_WIDTH_g   : integer := 16;
  constant RAM_TYPE_g     : string  := "AUTO";

  signal datai       : std_logic_vector(DATA_WIDTH_g-1 downto 0) := (others => '0');
  signal datao       : std_logic_vector(DATA_WIDTH_g-1 downto 0);
  signal channel_out : std_logic_vector(log2_ceil(NUM_CHANNELS_g-1) downto 0);
  signal in_valid    : std_logic                                 := '0';
  signal out_valid    : std_logic                                 := '0';
  signal clk         : std_logic                                 := '0';
  signal reset       : std_logic                                 := '0';
  signal enable      : std_logic                                 := '0';
  signal count : unsigned(31 downto 0);

begin  -- architecture tb_auk_dspip_pfc_rtl

  -- purpose: increments while "incr" is high
  -- type : sequential
  -- inputs : clk, reset, incr
  -- outputs: count
  incr : process ( clk, reset )
  begin  
      if reset = '1' then           
          count <= (others => '0');
      elsif rising_edge(clk) then  
          if enable = '1' then  
                  count <= count+1; -- count must be signed or unsigned
          end if;
      end if;
  end process incr;

  --in_valid <= count(1) and count(0);
  --datai <= std_logic_vector(count(DATA_WIDTH_g+1 downto 2));
  in_valid <= '1';
  datai <= std_logic_vector(count(DATA_WIDTH_g-1 downto 0));

  DUT: entity work.auk_dspip_pfc
    generic map (
        NUM_CHANNELS_g => NUM_CHANNELS_g,
        POLY_FACTOR_g  => POLY_FACTOR_g,
        DATA_WIDTH_g   => DATA_WIDTH_g,
        RAM_TYPE_g     => RAM_TYPE_g)
    port map (
        datai       => datai,
        datao       => datao,
        channel_out => channel_out,
        out_valid    => out_valid,
        in_valid    => in_valid,
        clk         => clk,
        reset       => reset,
        enable      => enable);


  
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
    --wait for tclk*130;
    --reset <= '1';
    --wait for tclk*2;
    --reset <= '0';
    wait;
  end process resetgen;

  enablegen : process
  begin  -- process enablegen
    enable <= '1';
    wait for tclk*504;
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



  

end architecture tb_auk_dspip_pfc_rtl;

-------------------------------------------------------------------------------
