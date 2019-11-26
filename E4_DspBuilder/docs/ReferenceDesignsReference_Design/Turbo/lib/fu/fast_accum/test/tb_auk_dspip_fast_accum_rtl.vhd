-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: tb_auk_dspip_fast_accum_rtl.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/fu/fast_accum/test/tb_auk_dspip_fast_accum_rtl.vhd,v $
--
-- $Revision: 1.1 $
-- $Date: 2007/09/24 16:59:35 $
-- Check in by     : $Author: admanero $
-- Author   :  Alex Diaz-Manero
--
-- Project      :  FIR
--
-- Description : 
--
-- Fast pipelined Accumulator for fast filters 
-- 
--
-- $Log: tb_auk_dspip_fast_accum_rtl.vhd,v $
-- Revision 1.1  2007/09/24 16:59:35  admanero
-- first revision of fast (pipelined) accumulator.
--
--
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity tb_auk_dspip_fast_accum is
end entity tb_auk_dspip_fast_accum;

-------------------------------------------------------------------------------

architecture bench of tb_auk_dspip_fast_accum is


  constant tclk       : time    := 20 ns;
  constant tmax       : time    := 4000 ns;
  constant INWIDTH_g  : natural := 7;
  constant LABWIDTH_g : natural := 3;
	constant OUTPUT_EXTRA_BITS_c : natural := 3;  -- output width is INWIDTH_g + OUTPUT_EXTRA_BITS_c
	constant MAXIMUM_ACCUMS_c : natural := 2 ** OUTPUT_EXTRA_BITS_c;
	constant PROCESSING_DELAY_c : natural := 2;  -- to be refered to the formula for this FU

	Subtype ref_vector   is std_logic_vector(INWIDTH_g+OUTPUT_EXTRA_BITS_c-1 downto 0);
	Type    ref_2D_array is array (natural range <>) of ref_vector;
	
  signal datain1    : std_logic_vector(INWIDTH_g-1 downto 0) := (others => '0');
  --signal datain2    : std_logic_vector(INWIDTH_g-1 downto 0) := (others => '0');
  signal add_to_zero   : std_logic;
  signal clk        : std_logic                              := '0';
  signal enable     : std_logic                              := '0';
  signal reset      : std_logic                              := '0';
  signal ref_seed   : signed(INWIDTH_g+OUTPUT_EXTRA_BITS_c-1 downto 0);
	signal ref_delay  : ref_2D_array(PROCESSING_DELAY_c downto 0);
	signal refout     : std_logic_vector(INWIDTH_g+OUTPUT_EXTRA_BITS_c-1 downto 0);
  signal dataout    : std_logic_vector(INWIDTH_g+OUTPUT_EXTRA_BITS_c-1 downto 0);
  signal difference : std_logic_vector(INWIDTH_g+OUTPUT_EXTRA_BITS_c-1 downto 0);
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


  DUT : entity work.auk_dspip_fast_accumulator
	
	
	generic map (
      NUM_OF_CHANNELS_g => 1,
	    DATA_WIDTH_g  => INWIDTH_g,
      LABWIDTH_g => LABWIDTH_g,
			ACCUM_OUT_WIDTH_g => INWIDTH_g+OUTPUT_EXTRA_BITS_c,
			ACCUM_MEM_TYPE_g => "auto")
    port map (
      datai    => datain1,
      add_to_zero   => add_to_zero,
      clk        => clk,
      enb        => enable,
      reset      => reset,
      datao      => dataout);

  datain1(INWIDTH_g-2 downto 0)  <= count(INWIDTH_g-2 downto 0);
	datain1(INWIDTH_g-1)  <= not count(INWIDTH_g-1) when (unsigned(count) mod 3 = natural(0)) else count(INWIDTH_g-1);
	add_to_zero  <= '1' when ((unsigned(count) + natural(1)) mod MAXIMUM_ACCUMS_c = natural(0)) else '0';
  --add_to_zero <= count(2) and count(1) and count(0);

  -- purpose: simple adder
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: 
	
	ref_delay(0) <= std_logic_vector(ref_seed);
  golden_reference : process (clk, reset) is
  begin  -- process golden_reference
    if reset = '1' then                 -- asynchronous reset (active high)
      ref_seed     <= (others => '0');
			ref_delay(PROCESSING_DELAY_c downto 1)  <= (PROCESSING_DELAY_c downto 1 => (others => '0'));
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
				ref_delay(PROCESSING_DELAY_c downto 1) <= ref_delay(PROCESSING_DELAY_c-1 downto 0);
			
        if add_to_zero = '1' then
          ref_seed(INWIDTH_g-1 downto 0) <= signed(datain1);
					ref_seed(INWIDTH_g+2 downto INWIDTH_g) <= (2 downto 0 => datain1(INWIDTH_g-1));
        else
          ref_seed <= ref_seed + signed(datain1);
        end if;
      end if;
    end if;
  end process golden_reference;
	
	refout <= ref_delay(PROCESSING_DELAY_c);

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
    --reset <= '0';
    --wait for tclk/4;
    reset <= '1';
    wait for tclk*2;
		wait for tclk/4;
    reset <= '0';
    wait;
  end process resetgen;

  -- purpose: stops simulations at time tmax
  stopper : process
  begin  -- process stopper
    wait for tmax;
    assert false report "simulation finished" severity failure;
  end process stopper;

end architecture bench;

-------------------------------------------------------------------------------
