-------------------------------------------------------------------------------
-- Title         : umts interleaver top level
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $RCSfile: auk_dspip_ctc_umts_itlv.vhd,v $
-- Revision      : $Revision: #2 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/12/15 $
-------------------------------------------------------------------------------
-- Description :
--
-- interleaver according to 3G TS25.212 V3.1.1 (1999-12)
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $Log: auk_dspip_ctc_umts_itlv.vhd,v $
-- Revision 1.5  2008/02/15 10:58:05  zpan
-- change some ports to internal signals
--
-- Revision 1.4  2008/02/14 00:00:04  zpan
-- change inferred ram for QII 7.2
--
-- Revision 1.3  2008/02/13 22:32:51  zpan
-- use common ctc_umts_libs
--
------------------------------------------------------------------------------- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity auk_dspip_ctc_umts2_itlv is
  generic (
    gCOUNTER_WIDTH : integer := 13); 

  port (
    out_addr     : out unsigned(gCOUNTER_WIDTH-1 downto 0);
    RxC          : out unsigned(gCOUNTER_WIDTH-1 downto 0);
    blk_size     : in  unsigned(gCOUNTER_WIDTH-1 downto 0);
    addr_valid   : out std_logic;
    seq_gen_done : out std_logic;
    start_load   : in  std_logic;
    enable       : in  std_logic;
    clk          : in  std_logic;
    reset        : in  std_logic);
end auk_dspip_ctc_umts2_itlv;



architecture beh of auk_dspip_ctc_umts2_itlv is

  signal blk_size_reg      : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal count             : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal max_count         : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal RxC_int           : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal msbs_and_lsbs     : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal active            : std_logic_vector(4 downto 0);
  signal n_raw             : unsigned(8 downto 0);
  signal n_exponent        : unsigned(8 downto 0);
  signal mult              : unsigned(15 downto 0);
  signal table_out         : unsigned(7 downto 0);
  signal five_lsbs         : unsigned(4 downto 0);
  signal five_lsbs_delayed : unsigned(4 downto 0);
  signal five_lsbs_br      : unsigned(4 downto 0);
  signal msbs_plus_1_early : unsigned(7 downto 0);
  signal msbs_plus_1       : unsigned(7 downto 0);

  component auk_dspip_ctc_umtsitlv2_lut is
    port (
      n_exponent : in  unsigned(8 downto 0);
      five_lsbs  : in  unsigned(4 downto 0);
      table_out  : out unsigned(7 downto 0);

      reset  : in std_logic;
      enable : in std_logic;
      clk    : in std_logic);
  end component auk_dspip_ctc_umtsitlv2_lut;



begin  -- beh

  register_new_block_size : process (clk, reset) is
  begin  -- process register_new_block_size
    if reset = '1' then                 -- asynchronous reset (active high)
      blk_size_reg <= (others => '0');
      seq_gen_done <= '0';
      active       <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if start_load = '1' then
        blk_size_reg <= blk_size;
        active(0)       <= '1';
        seq_gen_done <= '0';       
      elsif count = max_count then
        active(0) <= '0';
        seq_gen_done <= '1';
      end if;
      active(4 downto 1) <= active(3 downto 0);
    end if;
  end process register_new_block_size;

  calc_n_and_n_exponent : process (clk, reset) is
  begin  -- process calc_n_and_n_exponent
    if reset = '1' then                 -- asynchronous reset (active high)
      --n <= (others => '0');
      n_raw      <= (others => '0');
      n_exponent <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if blk_size_reg < 187 then
        n_raw(3) <= '1';
      end if;
      if blk_size_reg < 402 then
        n_raw(4) <= '1';
      end if;
      if blk_size_reg < 787 then
        n_raw(5) <= '1';
      end if;
      if blk_size_reg < 1555 then
        n_raw(6) <= '1';
      end if;
      if blk_size_reg < 3090 then
        n_raw(7) <= '1';
      end if;
      n_raw(8)               <= '1';
      
      n_exponent(8)          <= n_raw(8) and not n_raw(7);
      n_exponent(7)          <= n_raw(7) and not n_raw(6);
      n_exponent(6)          <= n_raw(6) and not n_raw(5);
      n_exponent(5)          <= n_raw(5) and not n_raw(4);
      n_exponent(4)          <= n_raw(4) and not n_raw(3);
      n_exponent(3)          <= n_raw(3);
      n_exponent(2 downto 0) <= "000";
      
    end if;
  end process calc_n_and_n_exponent;

  counter : process (clk, reset) is
  begin  -- process counter
    if reset = '1' then                 -- asynchronous reset (active high)
      count     <= (others => '0');
      max_count <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      max_count <= RxC_int-1;
      if active(0) = '1' then
        count <= count+1;
      else
        count <= (others => '0');
      end if;
    end if;
  end process counter;


  delay_reverse_lsbs : process (clk, reset) is
  begin  -- process delay_reverse_lsbs
    if reset = '1' then                 -- asynchronous reset (active high)
      five_lsbs <= (others => '0');
      five_lsbs_delayed <= (others => '0');
      five_lsbs_br      <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      five_lsbs <= count(4 downto 0);
      five_lsbs_delayed <= five_lsbs;
      five_lsbs_br      <= five_lsbs_delayed(0) & five_lsbs_delayed(1) & five_lsbs_delayed(2) & five_lsbs_delayed(3) & five_lsbs_delayed(4);
    end if;
  end process delay_reverse_lsbs;

  add_one : process (clk, reset) is
  begin  -- process add_one
    if reset = '1' then                 -- asynchronous reset (active high)
      msbs_plus_1_early <= (others => '0');
      msbs_plus_1 <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      msbs_plus_1_early <= count(12 downto 5) + 1;
      msbs_plus_1 <= msbs_plus_1_early;
    end if;
  end process add_one;

  multiplier : process (clk, reset) is
  begin  -- process multiplier
    if reset = '1' then                 -- asynchronous reset (active high)
      mult <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      mult <= table_out * msbs_plus_1(7 downto 0);
    end if;
  end process multiplier;

  select_bits_from_mult : process (clk, reset) is
  begin  -- process select_bits_from_mult
    if reset = '1' then                 -- asynchronous reset (active high)
      msbs_and_lsbs <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      case n_exponent is
        when "000001000" => msbs_and_lsbs <= "00000" & five_lsbs_br & mult(2 downto 0);
        when "000010000" => msbs_and_lsbs <= "0000" & five_lsbs_br & mult(3 downto 0);
        when "000100000" => msbs_and_lsbs <= "000" & five_lsbs_br & mult(4 downto 0);
        when "001000000" => msbs_and_lsbs <= "00" & five_lsbs_br & mult(5 downto 0);
        when "010000000" => msbs_and_lsbs <= '0' & five_lsbs_br & mult(6 downto 0);
        when "100000000" => msbs_and_lsbs <= five_lsbs_br & mult(7 downto 0);
        when others      => msbs_and_lsbs <= (others => '-');  -- illegal conditions, setting to don't care
      end case;
    end if;
  end process select_bits_from_mult;

  auk_dspip_ctc_umtsitlv2_lut_inst : entity work.auk_dspip_ctc_umtsitlv2_lut
    port map (
      n_exponent => n_exponent,
      five_lsbs  => five_lsbs,
      table_out  => table_out,

      reset  => reset,
      enable => enable,
      clk    => clk);


  combine_bits : process (clk, reset) is
  begin  -- process combine_bits
    if reset = '1' then                 -- asynchronous reset (active high)
      out_addr   <= (others => '0');
      addr_valid <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      out_addr <= msbs_and_lsbs;
      if msbs_and_lsbs < blk_size_reg then
        addr_valid <= active(4);
      else
        addr_valid <= '0';
      end if;
    end if;
  end process combine_bits;

  gen_RxC : process (clk, reset) is
  begin  -- process gen_RxC
    if reset = '1' then                 -- asynchronous reset (active high)
      RxC_int <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      case n_exponent is
--        when "000001000" => RxC_int <= to_unsigned(186, 13);
--        when "000010000" => RxC_int <= to_unsigned(402, 13);
--        when "000100000" => RxC_int <= to_unsigned(786, 13);
--        when "001000000" => RxC_int <= to_unsigned(1554, 13);
--        when "010000000" => RxC_int <= to_unsigned(3090, 13);
--        when "100000000" => RxC_int <= to_unsigned(6162, 13);
        when "000001000" => RxC_int <= to_unsigned(255, 13);
        when "000010000" => RxC_int <= to_unsigned(511, 13);
        when "000100000" => RxC_int <= to_unsigned(1023, 13);
        when "001000000" => RxC_int <= to_unsigned(2047, 13);
        when "010000000" => RxC_int <= to_unsigned(4095, 13);
        when "100000000" => RxC_int <= to_unsigned(8191, 13);
        when others      => RxC_int <= (others => '-');
      end case;
    end if;
  end process gen_RxC;

  RxC <= RxC_int;



end beh;
