----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_constlogmap.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : max* for constant log-MAP
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/map/auk_dspip_ctc_umts_map_constlogmap.vhd#1 $
-- $Log: auk_dspip_ctc_umts_map_constlogmap.vhd,v $
-- Revision 1.3  2007/08/24 15:19:03  zpan
-- update for saving purpose
--
-- Revision 1.2  2007/08/08 10:50:38  zpan
-- update for backup
--
-- Revision 1.1  2007/07/30 15:31:50  zpan
-- initial put
--
--
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity auk_dspip_ctc_umts_map_constlogmap is
  generic (
    WIDTH_g : positive := 9
    );
  port (
    delta_1_00 : in  signed(WIDTH_g-1 downto 0);
    delta_1_50 : in  signed(WIDTH_g-1 downto 0);
    delta_2_00 : in  signed(WIDTH_g-1 downto 0);
    delta_2_50 : in  signed(WIDTH_g-1 downto 0);
    diff       : in  signed(WIDTH_g-1 downto 0);
    q          : out signed(WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_constlogmap;


architecture beh of auk_dspip_ctc_umts_map_constlogmap is

begin  -- architecture beh

  comb_beta_const_logmap : process (diff, delta_2_00, delta_2_50, delta_1_00, delta_1_50) is
  begin  -- process comb_beta_const_logmap
    case diff is
      when "10-------"   => q <= delta_2_00;  -- diff < -32
      when "110------"   => q <= delta_2_00;  -- diff < -16
      when "1110-----"   => q <= delta_2_00;  -- diff < -8
      when "11110----"   => q <= delta_2_00;  -- diff < -4
      when "111110---"   => q <= delta_2_00;  -- diff < -2
      when "11111100-"   => q <= delta_2_00;  -- diff = -1.75, -2
      when "11111101-"   => q <= delta_2_50;  -- diff = -1.25, -1.5
      when "1111111--"   => q <= delta_2_50;  -- diff = -0.25,-0.5,-0.75, -1
      when "01-------"   => q <= delta_1_00;  -- diff >= 32
      when "001------"   => q <= delta_1_00;  -- diff >= 16
      when "0001-----"   => q <= delta_1_00;  -- diff >= 8
      when "00001----"   => q <= delta_1_00;  -- diff >= 4
      when "000001---"   => q <= delta_1_00;  -- diff >= 2
      when "000000111"   => q <= delta_1_00;  -- diff = 1.75
      when "000000110"   => q <= delta_1_50;  -- diff = 1.5
      when "00000010-"   => q <= delta_1_50;  -- diff = 1, 1.25
      when "0000000--"   => q <= delta_1_50;  -- diff = 0, 0.25, 0.5, 0.75
      when others        => q <= (others => '0');
    end case;
  end process comb_beta_const_logmap;

end architecture beh;

