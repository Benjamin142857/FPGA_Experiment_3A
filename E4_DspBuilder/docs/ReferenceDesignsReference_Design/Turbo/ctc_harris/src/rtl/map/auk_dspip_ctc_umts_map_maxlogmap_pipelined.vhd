----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_maxlogmap_pipelined_pipelined.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : max* for max-log-MAP (pipelined)
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/map/auk_dspip_ctc_umts_map_maxlogmap_pipelined.vhd#1 $
-- $Log: auk_dspip_ctc_umts_map_maxlogmap_pipelined.vhd,v $
-- Revision 1.1  2007/11/06 10:45:47  zpan
-- *** empty log message ***
--
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity auk_dspip_ctc_umts_map_maxlogmap_pipelined is
  generic (
    WIDTH_g : positive := 9
    );
  port (
    clk   : in  std_logic;
    ena   : in  std_logic;
    reset : in  std_logic;
    a     : in  signed(WIDTH_g-1 downto 0);
    b     : in  signed(WIDTH_g-1 downto 0);
    q     : out signed(WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_maxlogmap_pipelined;


architecture beh of auk_dspip_ctc_umts_map_maxlogmap_pipelined is

  signal diff : signed(WIDTH_g-1 downto 0);
  
begin  -- architecture beh

  diff <= a - b;

  pipelined_maxlogmap : process (clk, reset)
  begin  -- process pipelined_maxlogmap
    if reset = '1' then
      q <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        if diff(WIDTH_g-1) = '0' then
          q <= a;
        else
          q <= b;
        end if;
      end if;
    end if;
  end process pipelined_maxlogmap;

end architecture beh;

