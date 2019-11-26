-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_ctc_umts_decoder_top.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/CTC_umts/src/rtl/decoder/auk_dspip_ctc_umts_decoder_top.vhd,v $
--
-- $Revision: #3 $
-- $Date: 2010/01/12 $
-- Check in by     : $Author: zpan $
-- Author   :  kmarks
--
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

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;


entity auk_dspip_ctc_umts_decoder_top is
  generic (
    IN_WIDTH_g          : positive := 8;
    OUT_WIDTH_g         : positive := 1;
    NENGINES_g          : positive := 4;
    RAM_TYPE_g          : string   := "AUTO";  -- "MLAB", "M9K" --
    DECODER_TYPE_g      : string   := "MAXLOGMAP"  --"CONST_LOGMAP"  --
    );
  port (
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    --ena           : in  std_logic;
    sink_blk_size   : in  std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
    sink_iter       : in  std_logic_vector(IT_WIDTH_c - 1 downto 0);
    sink_sop        : in  std_logic;
    sink_eop        : in  std_logic;
    sink_valid      : in  std_logic;
    sink_ready      : out std_logic;
    sink_data       : in  std_logic_vector(3*IN_WIDTH_g - 1 downto 0);
    sink_error      : in  std_logic_vector(1 downto 0);
    source_error    : out std_logic_vector(1 downto 0);
    source_blk_size : out std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
    source_valid    : out std_logic;
    source_ready    : in  std_logic;
    source_sop      : out std_logic;
    source_eop      : out std_logic;
    source_data     : out std_logic_vector(OUT_WIDTH_g - 1 downto 0)
    );

    -- disble warnings (14130)--
--  attribute altera_attribute : string; 
--  attribute altera_attribute of auk_dspip_ctc_umts_decoder_top : entity is "-name MESSAGE_DISABLE 14130";
    
end entity auk_dspip_ctc_umts_decoder_top;


architecture rtl of auk_dspip_ctc_umts_decoder_top is

  constant SOFT_WIDTH_c : positive := IN_WIDTH_g + 4;
  
  signal reset           : std_logic;
  signal ctc_in_blk_size : std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
  signal ctc_in_iter     : std_logic_vector(IT_WIDTH_c-1 downto 0);
  signal ctc_in_sop      : std_logic;
  signal ctc_in_eop      : std_logic;
  signal ctc_in_valid    : std_logic;
  signal ctc_ready       : std_logic;
  signal ctc_in_data     : std_logic_vector(IN_WIDTH_g*3 - 1 downto 0);

--  signal decoder_in_valid    : std_logic;

  signal ctc_out_valid    : std_logic;
  signal ctc_out_data     : signed(NENGINES_g - 1 downto 0);
  signal ctc_out_blk_size : unsigned(FRAME_SIZE_WIDTH_c - 1 downto 0);

  signal source_stall : std_logic;
  signal sink_ready_s : std_logic;
--  signal ena_decoder  : std_logic;

  signal ctc_in_error : std_logic_vector(1 downto 0);

  
begin  -- architecture rtl

  sink_ready   <= sink_ready_s;
  source_error <= ctc_in_error;
  reset        <= not reset_n;
--  decoder_in_valid <= not(ctc_in_error(0) or ctc_in_error(1)) and ctc_in_valid;
--  ena_decoder  <= not(ctc_in_error(0) or ctc_in_error(1));

  sink_inst : auk_dspip_ctc_umts_ast_sink
    generic map (
      MAX_BLK_SIZE_g => MAX_FRAME_SIZE_c,
      TAIL_BITS_g    => NUM_OF_TAIL_BIT_CYCLES_c,
      DATAWIDTH_g    => IN_WIDTH_g*3)
    port map (
      clk           => clk,
      reset         => reset,
      sink_blk_size => sink_blk_size,
      sink_iter     => sink_iter,
      sink_sop      => sink_sop,
      sink_eop      => sink_eop,
      sink_valid    => sink_valid,
      sink_ready    => sink_ready_s,
      sink_data     => sink_data,
      sink_error    => sink_error,
      out_error     => ctc_in_error,
      out_valid     => ctc_in_valid,
      out_ready     => ctc_ready,
      out_sop       => ctc_in_sop,
      out_eop       => ctc_in_eop,
      out_data      => ctc_in_data,
      out_blk_size  => ctc_in_blk_size,
      out_iter      => ctc_in_iter
      );

  
  ctc_map_decoder_inst : auk_dspip_ctc_umts_map_decoder
    generic map (
      IN_WIDTH_g          => IN_WIDTH_g,
      OUT_WIDTH_g         => OUT_WIDTH_g,
      NPROCESSORS_g       => NENGINES_g,
      SOFT_WIDTH_g        => SOFT_WIDTH_c,
      RAM_TYPE_g          => RAM_TYPE_g,
      DECODER_TYPE_g      => DECODER_TYPE_g)
    port map (
      clk          => clk,
      ena          => '1',
      reset        => reset,
      in_valid     => ctc_in_valid,
      in_ready     => ctc_ready,
      blk_sop      => ctc_in_sop,
      blk_eop      => ctc_in_eop,
      blk_size_in  => unsigned(ctc_in_blk_size),
      input_c      => signed(ctc_in_data),
      iter         => unsigned(ctc_in_iter),
      blk_size_out => source_blk_size,
      dout_sop     => source_sop,
      dout_eop     => source_eop,
      dout         => source_data,
      out_ready    => source_ready,
      out_valid    => source_valid);

end architecture rtl;
