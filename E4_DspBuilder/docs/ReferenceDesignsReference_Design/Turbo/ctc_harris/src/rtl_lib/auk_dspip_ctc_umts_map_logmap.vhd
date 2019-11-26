----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_constlogmap.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : max* for log-MAP
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/map/auk_dspip_ctc_umts_map_logmap.vhd#1 $
-- $Log: auk_dspip_ctc_umts_map_logmap.vhd,v $
-- Revision 1.1  2007/08/24 15:18:42  zpan
-- first  revision
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

entity auk_dspip_ctc_umts_map_logmap is
  generic (
    WIDTH_g : positive := 9
    );
  port (
    delta_1_00 : in  signed(WIDTH_g-1 downto 0);
    delta_1_25 : in  signed(WIDTH_g-1 downto 0);
    delta_1_50 : in  signed(WIDTH_g-1 downto 0);
    delta_2_00 : in  signed(WIDTH_g-1 downto 0);
    delta_2_25 : in  signed(WIDTH_g-1 downto 0);
    delta_2_50 : in  signed(WIDTH_g-1 downto 0);
    delta_2_75 : in  signed(WIDTH_g-1 downto 0);
    diff       : in  signed(WIDTH_g-1 downto 0);
    q          : out signed(WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_logmap;


architecture beh of auk_dspip_ctc_umts_map_logmap is

begin  -- architecture beh

  comb_beta_logmap : process (diff, delta_2_00, delta_2_25, delta_2_50, delta_2_75, delta_1_00, delta_1_25, delta_1_50) is
  begin  -- process comb_beta_logmap
    case diff is
      when "10-------" => q <= delta_2_00;
      when "1-0------" => q <= delta_2_00;
      when "1--0-----" => q <= delta_2_00;
      when "1---0----" => q <= delta_2_00;
      when "1----0---" => q <= delta_2_00;
      when "111111000" => q <= delta_2_00;
      when "111111001" => q <= delta_2_25;
      when "111111010" => q <= delta_2_25;
      when "111111011" => q <= delta_2_25;
      when "111111100" => q <= delta_2_25;
      when "111111101" => q <= delta_2_50;
      when "111111110" => q <= delta_2_50;
      when "111111111" => q <= delta_2_50;
      when "000000000" => q <= delta_2_75;
      when "000000001" => q <= delta_1_50;
      when "000000010" => q <= delta_1_50;
      when "000000011" => q <= delta_1_50;
      when "000000100" => q <= delta_1_25;
      when "000000101" => q <= delta_1_25;
      when "000000110" => q <= delta_1_25;
      when "000000111" => q <= delta_1_25;
      when "01-------" => q <= delta_1_00;
      when "0-1------" => q <= delta_1_00;
      when "0--1-----" => q <= delta_1_00;
      when "0---1----" => q <= delta_1_00;
      when "0----1---" => q <= delta_1_00;
      when others      => q <= (others => '0');
    end case;
  end process comb_beta_logmap;
  
end architecture beh;

