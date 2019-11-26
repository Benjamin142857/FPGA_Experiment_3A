-------------------------------------------------------------------------------
-- Title         : PA, PB and PC row interleaver tables
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   aukui_papbpc_table_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
--
-- look up tables containing interleaver patterns for PA, PB and PC
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $Log: $
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity auk_dspip_ctc_umtsitlv2_lut is
    
    port (
        n_exponent    : in  unsigned(8 downto 0);
        five_lsbs     : in  unsigned(4 downto 0);
        table_out     : out unsigned(7 downto 0);

        reset         : in  std_logic;
        enable        : in  std_logic;
        clk           : in  std_logic
	);

end auk_dspip_ctc_umtsitlv2_lut;

architecture beh of auk_dspip_ctc_umtsitlv2_lut is

  type lut_array is array (0 to 31) of integer;

  constant n3_array : lut_array :=
  (   1,   1,   3,   5,   1,   5,   1,   5,   3,   5,   3,   5,   3,   5,   5,   1,
      3,   5,   3,   5,   3,   5,   5,   5,   1,   5,   1,   5,   3,   5,   5,   3  );
  constant n4_array : lut_array :=
  (   5,  15,   5,  15,   1,   9,   9,  15,  13,  15,   7,  11,  15,   3,  15,   5, 
     13,  15,   9,   3,   1,   3,  15,   1,  13,   1,   9,  15,  11,   3,  15,   5  );
  constant n5_array : lut_array :=
  (  27,   3,   1,  15,  13,  17,  23,  13,   9,   3,  15,   3,  13,   1,  13,  29, 
     21,  19,   1,   3,  29,  17,  25,  29,   9,  13,  23,  13,  13,   1,  13,  13  );
  constant n6_array : lut_array :=
  (   3,  27,  15,  13,  29,   5,   1,  31,   3,   9,  15,  31,  17,   5,  39,   1, 
     19,  27,  15,  13,  45,   5,  33,  15,  13,   9,  15,  31,  17,   5,  15,  33  );
  constant n7_array : lut_array :=
  (  15, 127,  89,   1,  31,  15,  61,  47, 127,  17, 119,  15,  57, 123,  95,   5, 
     85,  17,  55,  57,  15,  41,  93,  87,  63,  15,  13,  15,  81,  57,  31,  69  );
  constant n8_array : lut_array :=
  (   3,   1,   5,  83,  19, 179,  19,  99,  23,   1,   3,  13,  13,   3,  17,   1,
     63, 131,  17, 131, 211, 173, 231, 171,  23, 147, 243, 213, 189,  51,  15,  67  );
  constant n9_array : lut_array :=
  (  13, 335,  87,  15,  15,   1, 333,  11,  13,   1, 121, 155,   1, 175, 421,   5,
    509, 215,  47, 425, 295, 229, 427,  83, 409, 387, 193,  57, 501, 313, 489, 391  );
  constant n10_array : lut_array :=
  (   1, 349, 303, 721, 973, 703, 761, 327, 453,  95, 241, 187, 497, 909, 769, 349,
     71, 557, 197, 499, 409, 259, 335, 253, 677, 717, 313, 757, 189,  15,  75, 163  );

    signal n3_out         : unsigned(7 downto 0);
    signal n4_out         : unsigned(7 downto 0);
    signal n5_out         : unsigned(7 downto 0);
    signal n6_out         : unsigned(7 downto 0);
    signal n7_out         : unsigned(7 downto 0);
    signal n8_out         : unsigned(7 downto 0);

begin  -- beh

    n_lut : process (five_LSBs)

    begin  -- process n_lut

        case five_LSBs is
            when "00000" => n3_out <= to_unsigned(n3_array(0), 8);
            when "00001" => n3_out <= to_unsigned(n3_array(1), 8);
            when "00010" => n3_out <= to_unsigned(n3_array(2), 8);
            when "00011" => n3_out <= to_unsigned(n3_array(3), 8);
            when "00100" => n3_out <= to_unsigned(n3_array(4), 8);
            when "00101" => n3_out <= to_unsigned(n3_array(5), 8);
            when "00110" => n3_out <= to_unsigned(n3_array(6), 8);
            when "00111" => n3_out <= to_unsigned(n3_array(7), 8);
            when "01000" => n3_out <= to_unsigned(n3_array(8), 8);
            when "01001" => n3_out <= to_unsigned(n3_array(9), 8);
            when "01010" => n3_out <= to_unsigned(n3_array(10), 8);
            when "01011" => n3_out <= to_unsigned(n3_array(11), 8);
            when "01100" => n3_out <= to_unsigned(n3_array(12), 8);
            when "01101" => n3_out <= to_unsigned(n3_array(13), 8);
            when "01110" => n3_out <= to_unsigned(n3_array(14), 8);
            when "01111" => n3_out <= to_unsigned(n3_array(15), 8);
            when "10000" => n3_out <= to_unsigned(n3_array(16), 8);
            when "10001" => n3_out <= to_unsigned(n3_array(17), 8);
            when "10010" => n3_out <= to_unsigned(n3_array(18), 8);
            when "10011" => n3_out <= to_unsigned(n3_array(19), 8);
            when "10100" => n3_out <= to_unsigned(n3_array(20), 8);
            when "10101" => n3_out <= to_unsigned(n3_array(21), 8);
            when "10110" => n3_out <= to_unsigned(n3_array(22), 8);
            when "10111" => n3_out <= to_unsigned(n3_array(23), 8);
            when "11000" => n3_out <= to_unsigned(n3_array(24), 8);
            when "11001" => n3_out <= to_unsigned(n3_array(25), 8);
            when "11010" => n3_out <= to_unsigned(n3_array(26), 8);
            when "11011" => n3_out <= to_unsigned(n3_array(27), 8);
            when "11100" => n3_out <= to_unsigned(n3_array(28), 8);
            when "11101" => n3_out <= to_unsigned(n3_array(29), 8);
            when "11110" => n3_out <= to_unsigned(n3_array(30), 8);
            when "11111" => n3_out <= to_unsigned(n3_array(31), 8);
            when others  => n3_out <= (others => '-');  -- illegal number
        end case;

        case five_LSBs is
            when "00000" => n4_out <= to_unsigned(n4_array(0), 8);
            when "00001" => n4_out <= to_unsigned(n4_array(1), 8);
            when "00010" => n4_out <= to_unsigned(n4_array(2), 8);
            when "00011" => n4_out <= to_unsigned(n4_array(3), 8);
            when "00100" => n4_out <= to_unsigned(n4_array(4), 8);
            when "00101" => n4_out <= to_unsigned(n4_array(5), 8);
            when "00110" => n4_out <= to_unsigned(n4_array(6), 8);
            when "00111" => n4_out <= to_unsigned(n4_array(7), 8);
            when "01000" => n4_out <= to_unsigned(n4_array(8), 8);
            when "01001" => n4_out <= to_unsigned(n4_array(9), 8);
            when "01010" => n4_out <= to_unsigned(n4_array(10), 8);
            when "01011" => n4_out <= to_unsigned(n4_array(11), 8);
            when "01100" => n4_out <= to_unsigned(n4_array(12), 8);
            when "01101" => n4_out <= to_unsigned(n4_array(13), 8);
            when "01110" => n4_out <= to_unsigned(n4_array(14), 8);
            when "01111" => n4_out <= to_unsigned(n4_array(15), 8);
            when "10000" => n4_out <= to_unsigned(n4_array(16), 8);
            when "10001" => n4_out <= to_unsigned(n4_array(17), 8);
            when "10010" => n4_out <= to_unsigned(n4_array(18), 8);
            when "10011" => n4_out <= to_unsigned(n4_array(19), 8);
            when "10100" => n4_out <= to_unsigned(n4_array(20), 8);
            when "10101" => n4_out <= to_unsigned(n4_array(21), 8);
            when "10110" => n4_out <= to_unsigned(n4_array(22), 8);
            when "10111" => n4_out <= to_unsigned(n4_array(23), 8);
            when "11000" => n4_out <= to_unsigned(n4_array(24), 8);
            when "11001" => n4_out <= to_unsigned(n4_array(25), 8);
            when "11010" => n4_out <= to_unsigned(n4_array(26), 8);
            when "11011" => n4_out <= to_unsigned(n4_array(27), 8);
            when "11100" => n4_out <= to_unsigned(n4_array(28), 8);
            when "11101" => n4_out <= to_unsigned(n4_array(29), 8);
            when "11110" => n4_out <= to_unsigned(n4_array(30), 8);
            when "11111" => n4_out <= to_unsigned(n4_array(31), 8);
            when others  => n4_out <= (others => '-');  -- illegal conditions, setting to don't care
        end case;

        case five_LSBs is
            when "00000" => n5_out <= to_unsigned(n5_array(0), 8);
            when "00001" => n5_out <= to_unsigned(n5_array(1), 8);
            when "00010" => n5_out <= to_unsigned(n5_array(2), 8);
            when "00011" => n5_out <= to_unsigned(n5_array(3), 8);
            when "00100" => n5_out <= to_unsigned(n5_array(4), 8);
            when "00101" => n5_out <= to_unsigned(n5_array(5), 8);
            when "00110" => n5_out <= to_unsigned(n5_array(6), 8);
            when "00111" => n5_out <= to_unsigned(n5_array(7), 8);
            when "01000" => n5_out <= to_unsigned(n5_array(8), 8);
            when "01001" => n5_out <= to_unsigned(n5_array(9), 8);
            when "01010" => n5_out <= to_unsigned(n5_array(10), 8);
            when "01011" => n5_out <= to_unsigned(n5_array(11), 8);
            when "01100" => n5_out <= to_unsigned(n5_array(12), 8);
            when "01101" => n5_out <= to_unsigned(n5_array(13), 8);
            when "01110" => n5_out <= to_unsigned(n5_array(14), 8);
            when "01111" => n5_out <= to_unsigned(n5_array(15), 8);
            when "10000" => n5_out <= to_unsigned(n5_array(16), 8);
            when "10001" => n5_out <= to_unsigned(n5_array(17), 8);
            when "10010" => n5_out <= to_unsigned(n5_array(18), 8);
            when "10011" => n5_out <= to_unsigned(n5_array(19), 8);
            when "10100" => n5_out <= to_unsigned(n5_array(20), 8);
            when "10101" => n5_out <= to_unsigned(n5_array(21), 8);
            when "10110" => n5_out <= to_unsigned(n5_array(22), 8);
            when "10111" => n5_out <= to_unsigned(n5_array(23), 8);
            when "11000" => n5_out <= to_unsigned(n5_array(24), 8);
            when "11001" => n5_out <= to_unsigned(n5_array(25), 8);
            when "11010" => n5_out <= to_unsigned(n5_array(26), 8);
            when "11011" => n5_out <= to_unsigned(n5_array(27), 8);
            when "11100" => n5_out <= to_unsigned(n5_array(28), 8);
            when "11101" => n5_out <= to_unsigned(n5_array(29), 8);
            when "11110" => n5_out <= to_unsigned(n5_array(30), 8);
            when "11111" => n5_out <= to_unsigned(n5_array(31), 8);
            when others  => n5_out <= (others => '-');  -- illegal conditions, setting to don't care
        end case;

        case five_LSBs is
            when "00000" => n6_out <= to_unsigned(n6_array(0), 8);
            when "00001" => n6_out <= to_unsigned(n6_array(1), 8);
            when "00010" => n6_out <= to_unsigned(n6_array(2), 8);
            when "00011" => n6_out <= to_unsigned(n6_array(3), 8);
            when "00100" => n6_out <= to_unsigned(n6_array(4), 8);
            when "00101" => n6_out <= to_unsigned(n6_array(5), 8);
            when "00110" => n6_out <= to_unsigned(n6_array(6), 8);
            when "00111" => n6_out <= to_unsigned(n6_array(7), 8);
            when "01000" => n6_out <= to_unsigned(n6_array(8), 8);
            when "01001" => n6_out <= to_unsigned(n6_array(9), 8);
            when "01010" => n6_out <= to_unsigned(n6_array(10), 8);
            when "01011" => n6_out <= to_unsigned(n6_array(11), 8);
            when "01100" => n6_out <= to_unsigned(n6_array(12), 8);
            when "01101" => n6_out <= to_unsigned(n6_array(13), 8);
            when "01110" => n6_out <= to_unsigned(n6_array(14), 8);
            when "01111" => n6_out <= to_unsigned(n6_array(15), 8);
            when "10000" => n6_out <= to_unsigned(n6_array(16), 8);
            when "10001" => n6_out <= to_unsigned(n6_array(17), 8);
            when "10010" => n6_out <= to_unsigned(n6_array(18), 8);
            when "10011" => n6_out <= to_unsigned(n6_array(19), 8);
            when "10100" => n6_out <= to_unsigned(n6_array(20), 8);
            when "10101" => n6_out <= to_unsigned(n6_array(21), 8);
            when "10110" => n6_out <= to_unsigned(n6_array(22), 8);
            when "10111" => n6_out <= to_unsigned(n6_array(23), 8);
            when "11000" => n6_out <= to_unsigned(n6_array(24), 8);
            when "11001" => n6_out <= to_unsigned(n6_array(25), 8);
            when "11010" => n6_out <= to_unsigned(n6_array(26), 8);
            when "11011" => n6_out <= to_unsigned(n6_array(27), 8);
            when "11100" => n6_out <= to_unsigned(n6_array(28), 8);
            when "11101" => n6_out <= to_unsigned(n6_array(29), 8);
            when "11110" => n6_out <= to_unsigned(n6_array(30), 8);
            when "11111" => n6_out <= to_unsigned(n6_array(31), 8);
            when others  => n6_out <= (others => '-');  -- illegal conditions, setting to don't care
        end case;

        case five_LSBs is
            when "00000" => n7_out <= to_unsigned(n7_array(0), 8);
            when "00001" => n7_out <= to_unsigned(n7_array(1), 8);
            when "00010" => n7_out <= to_unsigned(n7_array(2), 8);
            when "00011" => n7_out <= to_unsigned(n7_array(3), 8);
            when "00100" => n7_out <= to_unsigned(n7_array(4), 8);
            when "00101" => n7_out <= to_unsigned(n7_array(5), 8);
            when "00110" => n7_out <= to_unsigned(n7_array(6), 8);
            when "00111" => n7_out <= to_unsigned(n7_array(7), 8);
            when "01000" => n7_out <= to_unsigned(n7_array(8), 8);
            when "01001" => n7_out <= to_unsigned(n7_array(9), 8);
            when "01010" => n7_out <= to_unsigned(n7_array(10), 8);
            when "01011" => n7_out <= to_unsigned(n7_array(11), 8);
            when "01100" => n7_out <= to_unsigned(n7_array(12), 8);
            when "01101" => n7_out <= to_unsigned(n7_array(13), 8);
            when "01110" => n7_out <= to_unsigned(n7_array(14), 8);
            when "01111" => n7_out <= to_unsigned(n7_array(15), 8);
            when "10000" => n7_out <= to_unsigned(n7_array(16), 8);
            when "10001" => n7_out <= to_unsigned(n7_array(17), 8);
            when "10010" => n7_out <= to_unsigned(n7_array(18), 8);
            when "10011" => n7_out <= to_unsigned(n7_array(19), 8);
            when "10100" => n7_out <= to_unsigned(n7_array(20), 8);
            when "10101" => n7_out <= to_unsigned(n7_array(21), 8);
            when "10110" => n7_out <= to_unsigned(n7_array(22), 8);
            when "10111" => n7_out <= to_unsigned(n7_array(23), 8);
            when "11000" => n7_out <= to_unsigned(n7_array(24), 8);
            when "11001" => n7_out <= to_unsigned(n7_array(25), 8);
            when "11010" => n7_out <= to_unsigned(n7_array(26), 8);
            when "11011" => n7_out <= to_unsigned(n7_array(27), 8);
            when "11100" => n7_out <= to_unsigned(n7_array(28), 8);
            when "11101" => n7_out <= to_unsigned(n7_array(29), 8);
            when "11110" => n7_out <= to_unsigned(n7_array(30), 8);
            when "11111" => n7_out <= to_unsigned(n7_array(31), 8);
            when others  => n7_out <= (others => '-');  -- illegal conditions, setting to don't care
        end case;

        case five_LSBs is
            when "00000" => n8_out <= to_unsigned(n8_array(0), 8);
            when "00001" => n8_out <= to_unsigned(n8_array(1), 8);
            when "00010" => n8_out <= to_unsigned(n8_array(2), 8);
            when "00011" => n8_out <= to_unsigned(n8_array(3), 8);
            when "00100" => n8_out <= to_unsigned(n8_array(4), 8);
            when "00101" => n8_out <= to_unsigned(n8_array(5), 8);
            when "00110" => n8_out <= to_unsigned(n8_array(6), 8);
            when "00111" => n8_out <= to_unsigned(n8_array(7), 8);
            when "01000" => n8_out <= to_unsigned(n8_array(8), 8);
            when "01001" => n8_out <= to_unsigned(n8_array(9), 8);
            when "01010" => n8_out <= to_unsigned(n8_array(10), 8);
            when "01011" => n8_out <= to_unsigned(n8_array(11), 8);
            when "01100" => n8_out <= to_unsigned(n8_array(12), 8);
            when "01101" => n8_out <= to_unsigned(n8_array(13), 8);
            when "01110" => n8_out <= to_unsigned(n8_array(14), 8);
            when "01111" => n8_out <= to_unsigned(n8_array(15), 8);
            when "10000" => n8_out <= to_unsigned(n8_array(16), 8);
            when "10001" => n8_out <= to_unsigned(n8_array(17), 8);
            when "10010" => n8_out <= to_unsigned(n8_array(18), 8);
            when "10011" => n8_out <= to_unsigned(n8_array(19), 8);
            when "10100" => n8_out <= to_unsigned(n8_array(20), 8);
            when "10101" => n8_out <= to_unsigned(n8_array(21), 8);
            when "10110" => n8_out <= to_unsigned(n8_array(22), 8);
            when "10111" => n8_out <= to_unsigned(n8_array(23), 8);
            when "11000" => n8_out <= to_unsigned(n8_array(24), 8);
            when "11001" => n8_out <= to_unsigned(n8_array(25), 8);
            when "11010" => n8_out <= to_unsigned(n8_array(26), 8);
            when "11011" => n8_out <= to_unsigned(n8_array(27), 8);
            when "11100" => n8_out <= to_unsigned(n8_array(28), 8);
            when "11101" => n8_out <= to_unsigned(n8_array(29), 8);
            when "11110" => n8_out <= to_unsigned(n8_array(30), 8);
            when "11111" => n8_out <= to_unsigned(n8_array(31), 8);
            when others  => n8_out <= (others => '-');  -- illegal conditions, setting to don't care
        end case;
    end process n_lut;

    select_table: process (clk, reset) is
    begin  -- process select_table
      if reset = '1' then               -- asynchronous reset (active high)
        table_out <= (others => '0');
      elsif rising_edge(clk) then       -- rising clock edge
        case n_exponent is
          when "000001000" => table_out <= n3_out;
          when "000010000" => table_out <= n4_out;
          when "000100000" => table_out <= n5_out;
          when "001000000" => table_out <= n6_out;
          when "010000000" => table_out <= n7_out;
          when "100000000" => table_out <= n8_out;
          when others => table_out <= (others => '-');  -- illegal conditions, setting to don't care
        end case;
      end if;
    end process select_table;

    
end beh ;

