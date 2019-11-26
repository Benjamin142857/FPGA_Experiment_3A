----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_maxlogmap.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : max* for max-log-MAP
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/map/auk_dspip_ctc_umts_map_maxlogmap.vhd#1 $
-- $Log: auk_dspip_ctc_umts_map_maxlogmap.vhd,v $
-- Revision 1.2  2007/08/24 15:19:03  zpan
-- update for saving purpose
--
-- Revision 1.1  2007/07/30 15:31:50  zpan
-- initial put
--
--
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity auk_dspip_ctc_umts_map_maxlogmap is
  generic (
    WIDTH_g : positive := 9
    );
  port (
    delta_1_00 : in  signed(WIDTH_g-1 downto 0);
    delta_2_00 : in  signed(WIDTH_g-1 downto 0);
    diff       : in  signed(WIDTH_g-1 downto 0);
    q          : out signed(WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_maxlogmap;


architecture beh of auk_dspip_ctc_umts_map_maxlogmap is

begin  -- architecture beh

  comb_beta_maxlogmap : process (diff, delta_2_00, delta_1_00) is
  begin  -- process comb_beta_maxlogmap
    case diff(WIDTH_g-1) is
      when '1'    => q <= delta_2_00;
      when '0'    => q <= delta_1_00;
      when others => q <= (others => '0');
    end case;
  end process comb_beta_maxlogmap;

end architecture beh;

