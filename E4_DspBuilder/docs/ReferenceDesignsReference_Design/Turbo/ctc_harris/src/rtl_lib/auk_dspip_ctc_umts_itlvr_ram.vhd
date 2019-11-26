----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_ram.vhd
--
-- Project     : UMTS Turbo Encoder/Decoder
-- Description : Intleaver RAM
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/input/auk_dspip_ctc_umts_itlvr_ram.vhd#1 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

entity auk_dspip_ctc_umts_itlvr_ram is
  
  generic (
    DATA_DEPTH_g        : integer  := 2*768;  -- data Depth
    DATA_WIDTH_g        : integer  := 18;     -- input data width
    ADDRESS_WIDTH_g     : integer  := 11
    );

  port (
    clk           : in  std_logic;
    ena           : in  std_logic;
    reset         : in  std_logic;
    read_address  : in  std_logic_vector(ADDRESS_WIDTH_g-1 downto 0);
    write_address : in  std_logic_vector(ADDRESS_WIDTH_g-1 downto 0);
    din           : in  std_logic_vector(DATA_WIDTH_g-1 downto 0);
    wren          : in  std_logic;
    rden          : in  std_logic;
    dout          : out std_logic_vector(DATA_WIDTH_g-1 downto 0)
    );

end entity auk_dspip_ctc_umts_itlvr_ram;


architecture SYN of auk_dspip_ctc_umts_itlvr_ram is

  component altsyncram
    generic (
      address_aclr_b                     : string;
      address_reg_b                      : string;
--      byte_size                          : natural;
      maximum_depth                      : natural;
      clock_enable_input_a               : string;
      clock_enable_input_b               : string;
      clock_enable_output_b              : string;
--      intended_device_family             : string;
      lpm_type                           : string;
      numwords_a                         : natural;
      numwords_b                         : natural;
      operation_mode                     : string;
      outdata_aclr_b                     : string;
      outdata_reg_b                      : string;
      power_up_uninitialized             : string;
      rdcontrol_reg_b                    : string;
      read_during_write_mode_mixed_ports : string;
      widthad_a                          : natural;
      widthad_b                          : natural;
      width_a                            : natural;
      width_b                            : natural;
      width_byteena_a                    : natural
      );
    port (
      clocken0  : in  std_logic;
      wren_a    : in  std_logic;
      aclr0     : in  std_logic;
      clock0    : in  std_logic;
--      byteena_a : in  std_logic_vector (BYTEENA_WIDTH_c-1 downto 0);
      address_a : in  std_logic_vector (ADDRESS_WIDTH_g-1 downto 0);
      address_b : in  std_logic_vector (ADDRESS_WIDTH_g-1 downto 0);
      rden_b    : in  std_logic;
      q_b       : out std_logic_vector (DATA_WIDTH_g-1 downto 0);
      data_a    : in  std_logic_vector (DATA_WIDTH_g-1 downto 0)
      );
  end component;

  
begin  -- SYN


  altsyncram_component : altsyncram
    generic map (
      address_aclr_b                     => "CLEAR0",
      address_reg_b                      => "CLOCK0",
--      byte_size                          => BYTE_SIZE_c,
      maximum_depth                      => 512,
      clock_enable_input_a               => "NORMAL",
      clock_enable_input_b               => "NORMAL",
      clock_enable_output_b              => "NORMAL",
--      intended_device_family             => "Stratix III",
      lpm_type                           => "altsyncram",
      numwords_a                         => DATA_DEPTH_g,
      numwords_b                         => DATA_DEPTH_g,
      operation_mode                     => "DUAL_PORT",
      outdata_aclr_b                     => "CLEAR0",
      outdata_reg_b                      => "CLOCK0",
      power_up_uninitialized             => "TRUE",
      rdcontrol_reg_b                    => "CLOCK0",
      read_during_write_mode_mixed_ports => "DONT_CARE",
      widthad_a                          => ADDRESS_WIDTH_g ,
      widthad_b                          => ADDRESS_WIDTH_g ,
      width_a                            => DATA_WIDTH_g,
      width_b                            => DATA_WIDTH_g,
      width_byteena_a                    => 1
      )
    port map (
      clocken0  => ena,
      wren_a    => wren,
      aclr0     => reset,
      clock0    => clk,
      address_a => write_address,
      address_b => read_address,
      rden_b    => rden,
      data_a    => din,
      q_b       => dout
      );

end SYN;
