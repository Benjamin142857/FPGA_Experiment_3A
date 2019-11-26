----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_constlogmap_pipelined.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : Pipelined max* for constant log-MAP
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Log: auk_dspip_ctc_umts_map_constlogmap_pipelined.vhd,v $
-- Revision 1.2  2007/09/10 09:56:43  zpan
-- added double window support
--
-- Revision 1.1  2007/08/31 23:37:25  zpan
-- first  revision
--
--
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

entity auk_dspip_ctc_umts_map_constlogmap_pipelined is
  generic (
    WIDTH_g             : positive := 9
    );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    ena   : in  std_logic;
    a     : in  signed(WIDTH_g-1 downto 0);
    b     : in  signed(WIDTH_g-1 downto 0);
    q     : out signed(WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_constlogmap_pipelined;

architecture beh of auk_dspip_ctc_umts_map_constlogmap_pipelined is
--  signal a_reg                   : signed(WIDTH_g-1 downto 0);
--  signal b_reg                   : signed(WIDTH_g-1 downto 0);
  signal a_minus_b               : signed(WIDTH_g-1 downto 0);
  signal a_minus_b_addsub_15     : signed(WIDTH_g-1 downto 0);
  signal a_or_b_reg              : signed(WIDTH_g-1 downto 0);
  signal a_minus_b_msb           : std_logic;
  signal a_minus_b_msb_reg       : std_logic;
  signal a_minus_b_addsub_15_msb : std_logic;
  signal sel                     : std_logic;
  signal zero_or_05              : signed(WIDTH_g-1 downto 0);  -- 0 or 0.5

begin  -- architecture beh

  a_minus_b_msb           <= a_minus_b(a_minus_b'high);
  a_minus_b_addsub_15_msb <= a_minus_b_addsub_15(a_minus_b_addsub_15'high);
  sel                     <= a_minus_b_addsub_15_msb xor a_minus_b_msb_reg;

  zero_or_05 <= (others => '0') when sel = '0' else "000000010";  -- 0 or 0.5

  a_minus_b <= a - b;

  a_minus_b_proc : process (clk, reset)
  begin  -- process a_minus_b_proc
    if reset = '1' then
      a_or_b_reg        <= (others => '0');
      a_minus_b_msb_reg <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        a_minus_b_msb_reg <= a_minus_b_msb;
        if a_minus_b_msb = '1' then
          a_or_b_reg <= b;
        else
          a_or_b_reg <= a;
        end if;
      end if;
    end if;
  end process a_minus_b_proc;

  addsub_proc : process (clk, reset)
  begin  -- process addsub_proc
    if reset = '1' then
      a_minus_b_addsub_15 <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        if a_minus_b_msb = '1' then
          a_minus_b_addsub_15 <= a_minus_b + "00110";  -- add 1.5
        else
          a_minus_b_addsub_15 <= a_minus_b - "00110";  -- sub 1.5
        end if;
      end if;
    end if;
  end process addsub_proc;

  q <= a_or_b_reg + zero_or_05;

end architecture beh;

