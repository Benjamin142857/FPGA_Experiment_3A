-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_ctc_umts_encoder_top.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/CTC/src/rtl/auk_dspip_ctc_umts_encoder_top.vhd,v $
--
-- $Revision: 1.12 $
-- $Date: 2008/01/16 21:38:27 $
-- Author   :  Zhengjun Pan
--
--
-- ALTERA Confidential and Proprietary
-- Copyright 2009 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;


entity auk_dspip_ctc_umts_encoder_top is
  generic (
    USE_MEMORY_FOR_ROM_g : boolean  := false      -- indicate if use memory for ROM
    );
  port (
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    sink_blk_size   : in  std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
    sink_sop        : in  std_logic;
    sink_eop        : in  std_logic;
    sink_valid      : in  std_logic;
    sink_ready      : out std_logic;
    sink_data       : in  std_logic;
    sink_error      : in  std_logic_vector(1 downto 0);
    source_error    : out std_logic_vector(1 downto 0);
    source_blk_size : out std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
    source_valid    : out std_logic;
    source_ready    : in  std_logic;
    source_sop      : out std_logic;
    source_eop      : out std_logic;
    source_data     : out std_logic_vector(2 downto 0)
    );

    -- disble warnings (14130)--
--  attribute altera_attribute : string; 
--  attribute altera_attribute of auk_dspip_ctc_umts_encoder_top : entity is "-name MESSAGE_DISABLE 14130";
    
end entity auk_dspip_ctc_umts_encoder_top;


architecture rtl of auk_dspip_ctc_umts_encoder_top is

  constant DATAWIDTH_c : natural := 1;  -- input data width

  signal reset           : std_logic;
  signal ctc_in_blk_size : std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
  signal ctc_in_sop      : std_logic;
  signal ctc_in_eop      : std_logic;
  signal ctc_in_valid    : std_logic;
  signal ctc_ready       : std_logic;
  signal ctc_in_data     : std_logic_vector(0 downto 0);


  signal ctc_out_valid    : std_logic;
  signal sink_data_slv    : std_logic_vector(DATAWIDTH_c - 1 downto 0);
  signal ctc_out_blk_size : unsigned(FRAME_SIZE_WIDTH_c - 1 downto 0);

  signal source_stall : std_logic;
  signal sink_ready_s : std_logic;

  signal ctc_in_error : std_logic_vector(1 downto 0);

begin  -- architecture rtl

  sink_ready   <= sink_ready_s;
--  source_error <= ctc_in_error;
  reset        <= not reset_n;
  sink_data_slv(0) <= sink_data;

  sink_inst : auk_dspip_ctc_umts_enc_ast_block_sink
    generic map (
      MAX_BLK_SIZE_g => MAX_FRAME_SIZE_c,
      DATAWIDTH_g    => DATAWIDTH_c)
    port map (
      clk           => clk,
      reset         => reset,
      sink_blk_size => sink_blk_size,
      sink_sop      => sink_sop,
      sink_eop      => sink_eop,
      sink_valid    => sink_valid,
      sink_ready    => sink_ready_s,
      sink_data     => sink_data_slv,
      sink_error    => sink_error,
      out_error     => ctc_in_error,
      out_valid     => ctc_in_valid,
      out_ready     => ctc_ready,
      out_sop       => ctc_in_sop,
      out_eop       => ctc_in_eop,
      out_data      => ctc_in_data,
      out_blk_size  => ctc_in_blk_size
      );

  
  ctc_encoder_inst : auk_dspip_ctc_umts_encoder
    generic map (
      USE_MEMORY_FOR_ROM_g => USE_MEMORY_FOR_ROM_g
      )
    port map (
      clk          => clk,
      ena          => '1',
      reset        => reset,
      in_valid     => ctc_in_valid,
      in_ready     => ctc_ready,
      blk_sop      => ctc_in_sop,
      blk_eop      => ctc_in_eop,
      blk_error    => ctc_in_error,
      blk_size_in  => unsigned(ctc_in_blk_size),
      data_in      => ctc_in_data(0),
      blk_size_out => source_blk_size,
      dout_sop     => source_sop,
      dout_eop     => source_eop,
      dout         => source_data,
      out_error    => source_error, 
      out_ready    => source_ready,
      out_valid   => source_valid
      );

end architecture rtl;
