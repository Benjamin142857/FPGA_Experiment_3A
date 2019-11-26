-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_pfc.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/fu/pfc/rtl/auk_dspip_pfc.vhd,v $
--
-- $Revision: 1.3 $
-- $Date: 2006/11/24 16:47:59 $
-- Check in by     : $Author: sdemirso $
-- Author   :  <Author name>
--
-- Project      :  <project name>
--
-- Description : 
--
-- <Brief description of the contents of the file>
-- 
--
-- $Log: auk_dspip_pfc.vhd,v $
-- Revision 1.3  2006/11/24 16:47:59  sdemirso
-- merging from branch_6_1
--
-- Revision 1.1.2.5  2006/10/12 13:50:07  vmauer
-- added clock enable to memory array
--
-- Revision 1.2  2006/09/22 18:19:25  sdemirso
-- PFC implemented by Volker
--
-- Revision 1.1.2.4  2006/09/20 16:55:28  vmauer
-- delayed channel_out
--
-- Revision 1.1.2.3  2006/09/20 16:41:58  vmauer
-- added out_valid
--
-- Revision 1.4  2006/08/24 12:57:58  sdemirso
-- headers added
--
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

--use work.fir_definitions_pkg.all;
--use work.auk_dspip_fir_math_pkg.all;

entity auk_dspip_pfc is
  generic (
    NUM_CHANNELS_g : integer := 5;
    POLY_FACTOR_g  : integer := 3;
    DATA_WIDTH_g   : integer := 16;
    RAM_TYPE_g     : string  := "AUTO"
    );
  port (

    datai       : in  std_logic_vector(DATA_WIDTH_g-1 downto 0);
    datao       : out std_logic_vector(DATA_WIDTH_g-1 downto 0);
    channel_out : out std_logic_vector(log2_ceil(NUM_CHANNELS_g)-1 downto 0);

    in_valid  : in  std_logic;
    out_valid : out std_logic;
    clk       : in  std_logic;
    reset     : in  std_logic;
    enable    : in  std_logic
    );
end auk_dspip_pfc;

-- hds interface_end
architecture rtl of auk_dspip_pfc is
-- constant eventaps : signed(1 downto 0) := NUM_OF_TAPS_c rem 2;
  type MEMORY_TYPE_t is array (0 to (2**log2_ceil(POLY_FACTOR_g)) * (2**log2_ceil(NUM_CHANNELS_g)) * 2 -1) of std_logic_vector(DATA_WIDTH_g-1 downto 0);
  signal mem : MEMORY_TYPE_t;

  signal channel_in_count  : unsigned(log2_ceil(NUM_CHANNELS_g)-1 downto 0);
  signal channel_out_count : unsigned(log2_ceil(NUM_CHANNELS_g)-1 downto 0);
  signal poly_in_count     : unsigned(log2_ceil(POLY_FACTOR_g)-1 downto 0);
  signal poly_out_count    : unsigned(log2_ceil(POLY_FACTOR_g)-1 downto 0);

  signal rd_addr : unsigned(log2_ceil(NUM_CHANNELS_g)+log2_ceil(POLY_FACTOR_g) downto 0);
  signal wr_addr : unsigned(log2_ceil(NUM_CHANNELS_g)+log2_ceil(POLY_FACTOR_g) downto 0);

  signal in_valid_dly : std_logic;
  signal toggle       : std_logic;
  signal initialised  : std_logic;

begin


  indicators : process (clk, reset) is
  begin  -- process indicators
    if reset = '1' then                 -- asynchronous reset (active high)
      channel_in_count  <= (others => '0');
      channel_out_count <= (others => '0');
      poly_in_count     <= (others => '0');
      poly_out_count    <= (others => '0');
      toggle            <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        if in_valid = '1' then

          -- input side
          if poly_in_count < POLY_FACTOR_g-1 then
            poly_in_count <= poly_in_count+1;
          else
            poly_in_count <= (others => '0');
          end if;

          if poly_in_count = POLY_FACTOR_g-1 then
            if channel_in_count < NUM_CHANNELS_g-1 then
              channel_in_count <= channel_in_count+1;
            else
              channel_in_count <= (others => '0');
            end if;
          end if;

          -- output side
          if channel_out_count < NUM_CHANNELS_g-1 then
            channel_out_count <= channel_out_count+1;
          else
            channel_out_count <= (others => '0');
          end if;

          if channel_out_count = NUM_CHANNELS_g-1 then
            if poly_out_count < POLY_FACTOR_g-1 then
              poly_out_count <= poly_out_count+1;
            else
              poly_out_count <= (others => '0');
            end if;
          end if;

          -- toggle (shared for input and output)
          if (channel_in_count = num_channels_g-1) and (poly_in_count = poly_factor_g-1) then
            toggle <= not toggle;
          end if;

        end if;

      end if;

    end if;

  end process indicators;

  wr_addr <= toggle & channel_in_count & poly_in_count;
  rd_addr <= not(toggle) & channel_out_count & poly_out_count;


  memory : process (clk)
  begin
    if clk'event and clk = '1' then
      if enable = '1' then        
        datao <= mem(to_integer(unsigned(rd_addr)));
        if in_valid = '1' then
          mem(to_integer(
            unsigned(wr_addr))) <= datai;
        end if;
      end if;
    end if;
  end process memory;

  delay_regs : process (clk, reset) is
  begin  -- process delay_regs
    if reset = '1' then                 -- asynchronous reset (active high)
      out_valid   <= '0';
      initialised <= '0';
      channel_out <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        channel_out <= std_logic_vector(channel_out_count);
        if (channel_in_count = num_channels_g-1) and (poly_in_count = poly_factor_g-1) then
          initialised <= '1';
        end if;
        if initialised = '1' then
          out_valid <= in_valid;
        end if;
        
      end if;
    end if;
  end process delay_regs;



end rtl;
