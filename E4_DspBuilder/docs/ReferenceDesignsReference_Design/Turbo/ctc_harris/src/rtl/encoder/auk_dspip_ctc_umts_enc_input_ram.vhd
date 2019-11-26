----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_enc_input_ram.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : Input RAM: this block uses true dual port mem
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2009 (c) Altera Corporation
-- All rights reserved
--
-- $Header: $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

entity auk_dspip_ctc_umts_enc_input_ram is
  
  port
    (
      address_a : in  std_logic_vector (12 downto 0);
      address_b : in  std_logic_vector (12 downto 0);
      clock     : in  std_logic;
      data_in   : in  std_logic;
      rden_a    : in  std_logic := '1';
      rden_b    : in  std_logic := '1';
      wren_a    : in  std_logic := '1';
      rd_clken  : in  std_logic := '1';
      q_a       : out std_logic;
      q_b       : out std_logic
      );

end entity auk_dspip_ctc_umts_enc_input_ram;


architecture SYN of auk_dspip_ctc_umts_enc_input_ram is

  signal data_a    : std_logic_vector (0 downto 0);
  signal sub_wire0 : std_logic_vector (0 downto 0);
  signal sub_wire1 : std_logic_vector (0 downto 0);

  component altsyncram
    generic (
      address_reg_b                      : string;
      clock_enable_input_a               : string;
      clock_enable_input_b               : string;
      clock_enable_output_a              : string;
      clock_enable_output_b              : string;
      indata_reg_b                       : string;
--      intended_device_family             : string;
      lpm_type                           : string;
      numwords_a                         : natural;
      numwords_b                         : natural;
      operation_mode                     : string;
      outdata_aclr_a                     : string;
      outdata_aclr_b                     : string;
      outdata_reg_a                      : string;
      outdata_reg_b                      : string;
      power_up_uninitialized             : string;
--      ram_block_type                     : string;
      read_during_write_mode_mixed_ports : string;
      read_during_write_mode_port_a      : string;
      read_during_write_mode_port_b      : string;
      widthad_a                          : natural;
      widthad_b                          : natural;
      width_a                            : natural;
      width_b                            : natural;
      width_byteena_a                    : natural;
      width_byteena_b                    : natural;
      wrcontrol_wraddress_reg_b          : string
      );
    port (
      clocken0  : in  std_logic;
      clocken1  : in  std_logic;
      wren_a    : in  std_logic;
      clock0    : in  std_logic;
      wren_b    : in  std_logic;
      clock1    : in  std_logic;
      address_a : in  std_logic_vector (12 downto 0);
      address_b : in  std_logic_vector (12 downto 0);
      rden_a    : in  std_logic;
      q_a       : out std_logic_vector (0 downto 0);
      rden_b    : in  std_logic;
      q_b       : out std_logic_vector (0 downto 0);
      data_a    : in  std_logic_vector (0 downto 0);
      data_b    : in  std_logic_vector (0 downto 0)
      );
  end component;

  
begin  -- SYN

  data_a(0) <= data_in;
  q_a       <= sub_wire0(0);
  q_b       <= sub_wire1(0);

  altsyncram_component : altsyncram
    generic map (
      address_reg_b                      => "CLOCK0",
      clock_enable_input_a               => "NORMAL",
      clock_enable_input_b               => "NORMAL",
      clock_enable_output_a              => "NORMAL",
      clock_enable_output_b              => "NORMAL",
      indata_reg_b                       => "CLOCK0",
--      intended_device_family             => "Stratix III",
      lpm_type                           => "altsyncram",
      numwords_a                         => 8192,
      numwords_b                         => 8192,
      operation_mode                     => "BIDIR_DUAL_PORT",
      outdata_aclr_a                     => "NONE",
      outdata_aclr_b                     => "NONE",
      outdata_reg_a                      => "CLOCK1",
      outdata_reg_b                      => "CLOCK1",
      power_up_uninitialized             => "FALSE",
--      ram_block_type                     => "M9K",
      read_during_write_mode_mixed_ports => "DONT_CARE",
      read_during_write_mode_port_a      => "NEW_DATA_NO_NBE_READ",
      read_during_write_mode_port_b      => "NEW_DATA_NO_NBE_READ",
      widthad_a                          => 13,
      widthad_b                          => 13,
      width_a                            => 1,
      width_b                            => 1,
      width_byteena_a                    => 1,
      width_byteena_b                    => 1,
      wrcontrol_wraddress_reg_b          => "CLOCK0"
      )
    port map (
      clocken0  => '1',
      clocken1  => rd_clken,
      wren_a    => wren_a,
      clock0    => clock,
      wren_b    => '0',
      clock1    => clock,
      address_a => address_a,
      address_b => address_b,
      rden_a    => rden_a,
      rden_b    => rden_b,
      data_a    => data_a,
      data_b    => data_a,
      q_a       => sub_wire0,
      q_b       => sub_wire1
      );

end SYN;
