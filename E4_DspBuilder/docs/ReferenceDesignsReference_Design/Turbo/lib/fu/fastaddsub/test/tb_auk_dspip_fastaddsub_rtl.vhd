-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity tb_auk_dspip_fastaddsub is
end entity tb_auk_dspip_fastaddsub;

-------------------------------------------------------------------------------

architecture tb_auk_dspip_fastaddsub_rtl of tb_auk_dspip_fastaddsub is


  constant tclk       : time    := 1 us;
  constant tmax       : time    := 9000 us;
  constant INWIDTH_g  : natural := 6;
  constant LABWIDTH_g : natural := 4;

  signal datain1    : std_logic_vector(INWIDTH_g-1 downto 0) := (others => '0');
  signal datain2    : std_logic_vector(INWIDTH_g-1 downto 0) := (others => '0');
  signal add_nsub   : std_logic;
  signal clk        : std_logic                              := '0';
  signal enable     : std_logic                              := '0';
  signal reset      : std_logic                              := '0';
  signal refout     : std_logic_vector(INWIDTH_g downto 0);
  signal dataout    : std_logic_vector(INWIDTH_g downto 0);
  signal difference : std_logic_vector(INWIDTH_g downto 0);
  signal count      : std_logic_vector(2*INWIDTH_g downto 0);

begin  -- architecture tb_auk_dspip_fastaddsub_rtl

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


  DUT : entity work.auk_dspip_fastaddsub
    generic map (
      INWIDTH_g  => INWIDTH_g,
      LABWIDTH_g => LABWIDTH_g)
    port map (
      datain1    => datain1,
      datain2    => datain2,
      add_nsub   => add_nsub,
      clk        => clk,
      enable     => enable,
      reset      => reset,
      dataout    => dataout);

  datain1  <= count(INWIDTH_g-1 downto 0);
-- datain2 <= count(INWIDTH_g-1 downto 0);
  datain2  <= count(2*INWIDTH_g-1 downto INWIDTH_g);
  add_nsub <= count(2*INWIDTH_g);

  -- purpose: simple adder
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: 
  golden_reference : process (clk, reset) is
  begin  -- process golden_reference
    if reset = '1' then                 -- asynchronous reset (active high)
      refout     <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        if add_nsub = '1' then
          refout <= std_logic_vector(signed(datain1(INWIDTH_g-1)&datain1) + signed(datain2(INWIDTH_g-1)&datain2));
          -- refout <= std_logic_vector(unsigned(datain1(INWIDTH_g-1)&datain1) + unsigned(datain2(INWIDTH_g-1)&datain2));
        else
          refout <= std_logic_vector(signed(datain1(INWIDTH_g-1)&datain1) - signed(datain2(INWIDTH_g-1)&datain2));
          -- refout <= std_logic_vector(unsigned(datain1(INWIDTH_g-1)&datain1) - unsigned(datain2(INWIDTH_g-1)&datain2));
        end if;
      end if;
    end if;
  end process golden_reference;

  compare : process (clk) is
  begin  -- process compare
    if rising_edge(clk) then            -- rising clock edge
      assert refout = dataout report "difference found" severity warning;
      difference <= refout xor dataout;
    end if;
  end process compare;


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
    wait;
  end process resetgen;

  -- purpose: stops simulations at time tmax
  stopper : process
  begin  -- process stopper
    wait for tmax;
    assert false report "simulation finished" severity failure;
  end process stopper;

end architecture tb_auk_dspip_fastaddsub_rtl;

-------------------------------------------------------------------------------
