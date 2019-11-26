-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: $
-- $Source: $
--
-- $Revision: $
-- $Date:  $
-- Check in by     : $Author: $
-- Author   :  <Author name>
--
-- Project      :  <project name>
--
-- Description : 
--
-- <Brief description of the contents of the file>
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

-------------------------------------------------------------------------------

entity tb_auk_dspip_ctc_umts2_itlv is
  generic (
    blk_size : unsigned(12 downto 0) := to_unsigned(40, 13));
end entity tb_auk_dspip_ctc_umts2_itlv;

-------------------------------------------------------------------------------
architecture tb_auk_dspip_ctc_umts2_itlv_rtl of tb_auk_dspip_ctc_umts2_itlv is

  -- component generics
  constant gCOUNTER_WIDTH : integer := 13;

  component auk_dspip_ctc_umts2_itlv is
    generic (
      gCOUNTER_WIDTH : integer);
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
  end component auk_dspip_ctc_umts2_itlv;

  -- component ports
  signal count        : unsigned(15 downto 0);
  signal index        : unsigned(15 downto 0);
  signal out_addr     : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal RxC          : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal addr_valid   : std_logic;
  signal seq_gen_done : std_logic;
  signal start_load   : std_logic                           := '0';
  signal enable       : std_logic                           := '0';
  signal clk          : std_logic                           := '0';
  signal reset        : std_logic                           := '0';

  type result_array is array (0 to 5114) of unsigned(12 downto 0);
  signal address_bin : result_array;
  signal itlv_bin : result_array;
  signal ditlv_bin : result_array;


begin  -- architecture tb_auk_dspip_ctc_umts_itlv_rtl

  -- component instantiation
  DUT: entity work.auk_dspip_ctc_umts2_itlv
    generic map (
      gCOUNTER_WIDTH => gCOUNTER_WIDTH)
    port map (
      out_addr     => out_addr,
      RxC          => RxC,
      blk_size     => blk_size,
      addr_valid   => addr_valid,
      seq_gen_done => seq_gen_done,
      start_load   => start_load,
      enable       => enable,
      clk          => clk,
      reset        => reset);

  -- clock generation
  Clk <= not Clk after 10 ns;


  -- waveform generation
  ResetGen_Proc: process
  begin
    reset <= '0';
    wait until Clk = '1';
    wait until Clk = '0';
    reset <= '1';
    wait until Clk = '1';
    wait until Clk = '0';
    wait until Clk = '1';
    wait until Clk = '0';
    reset <= '0';
    wait;
    
  end process ResetGen_Proc;

  counter: process (clk, reset) is
  begin  -- process counter
    if reset = '1' then                 -- asynchronous reset (active high)
      count <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      count <= count+1;
    end if;
  end process counter;

  enable <= '1' when count > 5 else '0';
  start_load <= '1' when count = 8 else '0';

  -- purpose: <[description]>
  collect_results: process (clk, reset) is
  begin  -- process collect_results
    if reset = '1' then                 -- asynchronous reset (active high)
      index <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if addr_valid = '1' then
        index <= index+1;
        address_bin(to_integer(out_addr)) <= out_addr;
        itlv_bin(to_integer(index)) <= out_addr;
        ditlv_bin(to_integer(out_addr)) <= index(12 downto 0);
      end if;
    end if;
  end process collect_results;
  

end architecture tb_auk_dspip_ctc_umts2_itlv_rtl;

-------------------------------------------------------------------------------

configuration tb_auk_dspip_ctc_umts2_itlv_rtl_cfg of tb_auk_dspip_ctc_umts2_itlv is
  for tb_auk_dspip_ctc_umts2_itlv_rtl
  end for;
end tb_auk_dspip_ctc_umts2_itlv_rtl_cfg;

-------------------------------------------------------------------------------
