----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_ram.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : RAM
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/auk_dspip_ctc_umts_ram.vhd#2 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity auk_dspip_ctc_umts_ram is
  
  generic (
    DATA_WIDTH_g    : integer := 144;   -- data width
    DATA_DEPTH_g    : integer := 768;   -- data Depth
    RAM_TYPE_g      : string  := "AUTO";
    MAXIMUM_DEPTH_g : natural := 1024;
    ADDRESS_WIDTH_g : integer := 10
    );

  port (
    clk           : in  std_logic;
    ena           : in  std_logic;
    reset         : in  std_logic;
    read_address  : in  unsigned (ADDRESS_WIDTH_g-1 downto 0);
    write_address : in  unsigned (ADDRESS_WIDTH_g-1 downto 0);
    din           : in  signed (DATA_WIDTH_g-1 downto 0) := (others => '0');
    wren          : in  std_logic                        := '0';
    rden          : in  std_logic;
    dout          : out signed (DATA_WIDTH_g-1 downto 0)
    );

end entity auk_dspip_ctc_umts_ram;


architecture SYN of auk_dspip_ctc_umts_ram is

--  constant RAM_TYPE_c        : string  := "AUTO";
  constant READ_DURING_WRITE_c : string := "DONT_CARE";

  signal dout_slv : std_logic_vector(DATA_WIDTH_g-1 downto 0);
  
  
begin  -- SYN

  dout <= signed(dout_slv);

  ram_type_gen : if RAM_TYPe_g /= "MLAB" generate
    mem0 : altsyncram
      generic map (
        address_reg_b                      => "CLOCK0",
        maximum_depth                      => MAXIMUM_DEPTH_g,
        clock_enable_input_a               => "NORMAL",
        clock_enable_input_b               => "NORMAL",
        clock_enable_output_a              => "NORMAL",
        clock_enable_output_b              => "NORMAL",
        --intended_device_family             => FAMILY_g,
        indata_reg_b                       => "CLOCK0",
        lpm_type                           => "altsyncram",
        numwords_a                         => DATA_DEPTH_g,
        numwords_b                         => DATA_DEPTH_g,
        operation_mode                     => "DUAL_PORT",
        RAM_BLOCK_TYPE                     => RAM_TYPE_g,
        outdata_aclr_b                     => "NONE",
        outdata_reg_b                      => "CLOCK0",
        rdcontrol_reg_b                    => "CLOCK0",
        power_up_uninitialized             => "FALSE",
        read_during_write_mode_mixed_ports => READ_DURING_WRITE_c,
        widthad_a                          => ADDRESS_WIDTH_g,
        widthad_b                          => ADDRESS_WIDTH_g,
        width_a                            => DATA_WIDTH_g,
        width_b                            => DATA_WIDTH_g,
        width_byteena_a                    => 1
        )
      port map (
        clocken0  => ena,
        rden_b    => rden,
        wren_a    => wren,
        clock0    => clk,
        address_a => std_logic_vector(write_address),
        address_b => std_logic_vector(read_address),
        data_a    => std_logic_vector(din),
        q_b       => dout_slv
        );

  end generate ram_type_gen;

  ram_type_mlab_gen : if RAM_TYPE_g = "MLAB" generate
  
  signal rd_addressstall : std_logic;
  
  begin
  	rd_addressstall <= not(rden);
    
    altsyncram_component : altsyncram
      generic map (
        address_aclr_b         => "NONE",
        address_reg_b          => "CLOCK0",
        clock_enable_input_a   => "BYPASS",
        clock_enable_input_b   => "BYPASS",
        clock_enable_output_b  => "BYPASS",
        intended_device_family => "Stratix IV",
        lpm_type               => "altsyncram",
        numwords_a             => DATA_DEPTH_g,
        numwords_b             => DATA_DEPTH_g,
        operation_mode         => "DUAL_PORT",
        outdata_aclr_b         => "NONE",
        outdata_reg_b          => "CLOCK0",
        power_up_uninitialized => "FALSE",
        ram_block_type         => "MLAB",
    		read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a              => ADDRESS_WIDTH_g,
        widthad_b              => ADDRESS_WIDTH_g,
        width_a                => DATA_WIDTH_g,
        width_b                => DATA_WIDTH_g,
        width_byteena_a        => 1
        )
      port map (
				addressstall_b => rd_addressstall,
        wren_a    => wren,
        clock0    => clk,
        address_a => std_logic_vector(write_address),
        address_b => std_logic_vector(read_address),
        data_a    => std_logic_vector(din),
        q_b       => dout_slv
        );

  end generate ram_type_mlab_gen;

end SYN;