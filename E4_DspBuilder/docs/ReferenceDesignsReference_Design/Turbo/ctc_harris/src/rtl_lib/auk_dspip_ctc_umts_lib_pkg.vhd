-- ================================================================================
-- (c) 2005 Altera Corporation. All rights reserved.
-- Altera products are protected under numerous U.S. and foreign patents, maskwork
-- rights, copyrights and other intellectual property laws.
-- 
-- This reference design file, and your use thereof, is subject to and governed
-- by the terms and conditions of the applicable Altera Reference Design License
-- Agreement (either as signed by you, agreed by you upon download or as a
-- "click-through" agreement upon installation andor found at www.altera.com).
-- By using this reference design file, you indicate your acceptance of such terms
-- and conditions between you and Altera Corporation.  In the event that you do
-- not agree with such terms and conditions, you may not use the reference design
-- file and please promptly destroy any copies you have made.
-- 
-- This reference design file is being provided on an "as-is" basis and as an
-- accommodation and therefore all warranties, representations or guarantees of
-- any kind (whether express, implied or statutory) including, without limitation,
-- warranties of merchantability, non-infringement, or fitness for a particular
-- purpose, are specifically disclaimed.  By making this reference design file
-- available, Altera expressly does not recommend, suggest or require that this
-- reference design file be used in combination with any other product not
-- provided by Altera.
-- ================================================================================
----------------------------------------------------------------------
--
--  auk_dspip_ctc_umts_lib_pkg.vhd
--
-- Project     :  Turbo Encoder/Decoder
-- Description : This package defines library fucntions, entities for Turbo
--                Encoder/Decoder
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/auk_dspip_ctc_umts_lib_pkg.vhd#4 $
----------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

library auk_dspip_ctc_umts_lib;

package auk_dspip_ctc_umts_lib_pkg is
  constant IN_WIDTH                 : integer  := 6;  -- received decoder signal width
  constant SOFT_WIDTH               : integer  := 9;  -- accumulated distance width
  constant NUM_FRAME_SIZE_c         : integer  := 188;  -- number of interleaver sizes in UMTS spec
  constant MAX_FRAME_SIZE_c         : positive := 5120;  -- Maximum frame size supported by the decoder
  constant IT                       : integer  := 8;  -- number of decoding iterations
  constant IT_WIDTH_c               : integer  := 5;  -- number of bits to hold decoding iteration numbers
  constant MAX_STATES_c             : integer  := 8;  -- maximum number of states
  constant SLDWIN_SIZE_c            : integer  := 32;   -- Sliding window size
  constant BLOCK_ADDRESS_WIDTH_c    : integer  := log2_ceil(NUM_FRAME_SIZE_c);
  constant FRAME_SIZE_WIDTH_c       : integer  := log2_ceil(MAX_FRAME_SIZE_c);
  constant SLDWIN_SIZE_WIDTH_c      : integer  := log2_ceil(SLDWIN_SIZE_c);
  constant NUM_OF_TAIL_BIT_CYCLES_c : integer  := 4;  -- number of clock cycles to feed tail bits


  subtype INT1BIT is integer range 0 to 1;
  subtype INT2BIT is integer range 0 to 3;
  subtype INT3BIT is integer range 0 to 7;
  subtype INT4BIT is integer range 0 to 15;
  subtype INT5BIT is integer range 0 to 31;
  subtype INT6BIT is integer range 0 to 63;
  subtype INT7BIT is integer range 0 to 127;
  subtype INT8BIT is integer range 0 to 255;
  subtype INT9BIT is integer range 0 to 511;
  subtype INT10BIT is integer range 0 to 1023;
  subtype INT11BIT is integer range 0 to 2047;
  subtype INT12BIT is integer range 0 to 4095;
  subtype INT13BIT is integer range 0 to 8191;
  type    ARRAY8c is array (0 to 7) of INT2BIT;
  type    ARRAY8d is array (0 to 7) of INT3BIT;

  -- 3GPP Turbo state transition
  constant OUT0   : ARRAY8C := (0, 0, 1, 1, 1, 1, 0, 0);  -- RSC output from state 0 to 7 when input is 0
  constant OUT1   : ARRAY8c := (3, 3, 2, 2, 2, 2, 3, 3);  -- RSC output from state 0 to 7 when input is 1
  constant STATE0 : ARRAY8d := (0, 4, 5, 1, 2, 6, 7, 3);  -- RSC state transaction when input is 0
  constant STATE1 : ARRAY8d := (4, 0, 1, 5, 6, 2, 3, 7);  -- RSC state transaction when input is 1

  -- constants for alpha calculation
  constant OUT0_A   : ARRAY8C := (0, 1, 1, 0, 0, 1, 1, 0);  -- RSC output from state 0 to 7 when input is 0
  constant OUT1_A   : ARRAY8c := (3, 2, 2, 3, 3, 2, 2, 3);  -- RSC output from state 0 to 7 when input is 1
  constant STATE0_A : ARRAY8d := (0, 3, 4, 7, 1, 2, 5, 6);  -- RSC state transaction when input is 0
  constant STATE1_A : ARRAY8d := (1, 2, 5, 6, 0, 3, 4, 7);  -- RSC state transaction when input is 1

  type vec_of_vec is array (natural range <>, natural range <>) of std_logic;
  type gcd_vec is array (19 downto 0) of unsigned(7 downto 0);

  component auk_dspip_ctc_umts_map_alpha is
    generic (
      WIDTH_g             : positive := 9;
      DECODER_TYPE_g      : string   := "CONST_LOGMAP"
                                        -- possible values are "MAXLOGMAP", "LOGMAP",
                                        -- "CONST_LOGMAP".
      );
    port (
      clk            : in  std_logic;
      ena            : in  std_logic;
      reset          : in  std_logic;
      metric_c_1     : in  signed(WIDTH_g-1 downto 0);
      metric_c_2     : in  signed(WIDTH_g-1 downto 0);
      metric_c_3     : in  signed(WIDTH_g-1 downto 0);
      sload          : in  std_logic;
      alpha_prime_in : in  signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
      alpha_prime    : out signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
      alpha_out      : out signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_map_alpha;

  component auk_dspip_ctc_umts_map_beta is
    generic (
      WIDTH_g             : positive := 9;
      DECODER_TYPE_g      : string   := "CONST_LOGMAP"
                                        -- possible values are "MAXLOGMAP", "LOGMAP",
                                        -- "CONST_LOGMAP".
      );
    port (
      clk           : in  std_logic;
      ena           : in  std_logic;
      reset         : in  std_logic;
      metric_c_1    : in  signed(WIDTH_g-1 downto 0);
      metric_c_2    : in  signed(WIDTH_g-1 downto 0);
      metric_c_3    : in  signed(WIDTH_g-1 downto 0);
      sload         : in  std_logic;
      beta_prime_in : in  signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
      beta_prime    : out signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
      beta_out      : out signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_map_beta;

  component auk_dspip_ctc_umts_map_gamma is
    generic (
      INPUT_WIDTH_g : positive := 6;
      WIDTH_g       : positive := 9
      );
    port (
      clk          : in  std_logic;
      ena          : in  std_logic;
      reset        : in  std_logic;
      input_c_0    : in  signed(INPUT_WIDTH_g-1 downto 0);
      input_c_1    : in  signed(INPUT_WIDTH_g-1 downto 0);
      app_in       : in  signed(INPUT_WIDTH_g-1 downto 0);
      gamma_to_mem : out signed(3*WIDTH_g+INPUT_WIDTH_g-1 downto 0);
      gamma_1      : out signed(WIDTH_g-1 downto 0);
      gamma_2      : out signed(WIDTH_g-1 downto 0);
      gamma_3      : out signed(WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_map_gamma;

  component auk_dspip_ctc_umts_input_ram is
    
    generic (
--    NPROCESSORS_g*INPUT_WIDTH_g        : integer  := 144;    -- data width
      DATA_DEPTH_g        : integer  := 2*(768+1);  -- data Depth
      NPROCESSORS_g       : integer  := 8;  -- number of parallel engines
      INPUT_WIDTH_g       : integer  := 18;         -- input data width
      NUM_ENGINES_WIDTH_g : positive := 3;  -- log2_ceil_one(NPROCESSORS_g);
      ADDRESS_WIDTH_g     : integer  := 11
      );

    port (
      clk           : in  std_logic;
      ena           : in  std_logic;
      reset         : in  std_logic;
      read_address  : in  unsigned (ADDRESS_WIDTH_g-1 downto 0);
      write_address : in  unsigned (ADDRESS_WIDTH_g-1 downto 0);
      sub_address   : in  unsigned (NUM_ENGINES_WIDTH_g-1 downto 0);
      din           : in  signed (INPUT_WIDTH_g-1 downto 0);
      wren          : in  std_logic;
      rden          : in  std_logic;
      dout          : out signed (NPROCESSORS_g*INPUT_WIDTH_g-1 downto 0)
      );

  end component auk_dspip_ctc_umts_input_ram;

  component auk_dspip_ctc_umts_ram is
    
    generic (
      DATA_WIDTH_g    : integer := 144;  -- data width
      DATA_DEPTH_g    : integer := 768;  -- data Depth
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

  end component auk_dspip_ctc_umts_ram;

  component auk_dspip_ctc_umts_map_llr is
    generic (
      WIDTH_g             : positive := 9;
      DECODER_TYPE_g      : string   := "CONST_LOGMAP"
                                        -- possible values are "MAXLOGMAP", "LOGMAP",
                                        -- "CONST_LOGMAP".
      );
    port (
      clk            : in  std_logic;
      ena            : in  std_logic;
      reset          : in  std_logic;
      metric_c_1     : in  signed(WIDTH_g-1 downto 0);
      metric_c_2     : in  signed(WIDTH_g-1 downto 0);
      metric_c_3     : in  signed(WIDTH_g-1 downto 0);
      alpha_prime_in : in  signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
      beta_in        : in  signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
      llr            : out signed(WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_map_llr;

  component auk_dspip_ctc_umts_map_maxlogmap is
    generic (
      WIDTH_g : positive := 9
      );
    port (
      delta_1_00 : in  signed(WIDTH_g-1 downto 0);
      delta_2_00 : in  signed(WIDTH_g-1 downto 0);
      diff       : in  signed(WIDTH_g-1 downto 0);
      q          : out signed(WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_map_maxlogmap;

  component auk_dspip_ctc_umts_map_maxlogmap_pipelined is
    generic (
      WIDTH_g : positive
      );
    port (
      clk   : in  std_logic;
      ena   : in  std_logic;
      reset : in  std_logic;
      a     : in  signed(WIDTH_g-1 downto 0);
      b     : in  signed(WIDTH_g-1 downto 0);
      q     : out signed(WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_map_maxlogmap_pipelined;

  component auk_dspip_ctc_umts_map_constlogmap is
    generic (
      WIDTH_g : positive := 9
      );
    port (
      delta_1_00 : in  signed(WIDTH_g-1 downto 0);
      delta_1_50 : in  signed(WIDTH_g-1 downto 0);
      delta_2_00 : in  signed(WIDTH_g-1 downto 0);
      delta_2_50 : in  signed(WIDTH_g-1 downto 0);
      diff       : in  signed(WIDTH_g-1 downto 0);
      q          : out signed(WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_map_constlogmap;

  component auk_dspip_ctc_umts_map_logmap is
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
  end component auk_dspip_ctc_umts_map_logmap;

  component auk_dspip_ctc_umts_map_constlogmap_pipelined is
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
  end component auk_dspip_ctc_umts_map_constlogmap_pipelined;

  component auk_dspip_ctc_umts_input is
    generic (
      NPROCESSORS_g       : integer  := 4;  -- number of parallel engines
      NUM_ENGINES_WIDTH_g : positive := 3;  -- log2_ceil_one(NPROCESSORS_g);
      DATA_WIDTH_g        : positive := 11;  -- log2_ceil_one(MAX_FRAME_SIZE_c/NPROCESSORS_g);
      INPUT_WIDTH_g       : integer  := 24;  -- input data width
      ADDRESS_WIDTH_g     : positive := 11  -- =log2_ceil(MAX_SUB_FRAME_SIZE_c)
      );
    port (
      clk                    : in  std_logic;
      ena                    : in  std_logic;
      reset                  : in  std_logic;
      blk_size_in            : in  unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
      iter_in                : in  unsigned(IT_WIDTH_c-1 downto 0);
      data_in                : in  signed (INPUT_WIDTH_g-1 downto 0);  -- data to memory
      addr_rd                : in  unsigned (ADDRESS_WIDTH_g-1 downto 0);  -- read address
      data_out               : out signed(NPROCESSORS_g*INPUT_WIDTH_g-1 downto 0);  -- data out of memory
      read_en                : in  std_logic;  -- read enable
      blk_size_out           : out unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
      it_to_run              : out unsigned(IT_WIDTH_c-1 downto 0);
      -- ports for interleaver
      intlvr_addr_rd         : in  unsigned(ADDRESS_WIDTH_g-1 downto 0);
      intlvr_ram_rden        : in  std_logic;
      intlvr_info_from_mem   : out std_logic_vector(NPROCESSORS_g*(ADDRESS_WIDTH_g+NUM_ENGINES_WIDTH_g)-1 downto 0);
      -- ports for deinterleaver
      deintlvr_addr_rd       : in  unsigned(ADDRESS_WIDTH_g-1 downto 0);
      deintlvr_ram_rden      : in  std_logic;
      deintlvr_info_from_mem : out std_logic_vector(NPROCESSORS_g*(ADDRESS_WIDTH_g+NUM_ENGINES_WIDTH_g)-1 downto 0);
      ---------------------------------------------------------------------------
      -- control signals
      ---------------------------------------------------------------------------
      in_valid               : in  std_logic;
      in_sop                 : in  std_logic;
      in_eop                 : in  std_logic;
      decode_done            : in  std_logic;
      decode_stall           : in  std_logic;
      start_decode           : out std_logic;
      input_stall            : out std_logic
      );
  end component auk_dspip_ctc_umts_input;

component auk_dspip_ctc_umts_itlvr_ram is
  
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

end component auk_dspip_ctc_umts_itlvr_ram;

  component auk_dspip_ctc_umts_map_decoder is
    generic (
      IN_WIDTH_g          : positive := 6;
      OUT_WIDTH_g         : positive := 8;
      NPROCESSORS_g       : positive := 8;
      SOFT_WIDTH_g        : positive := 9;
      RAM_TYPE_g          : string   := "AUTO";  -- "MLAB", "M9K" --
      DECODER_TYPE_g      : string   := "MAXLOGMAP"  --"CONST_LOGMAP"  --
      );
    port (
      clk          : in  std_logic;
      ena          : in  std_logic;
      reset        : in  std_logic;
      in_valid     : in  std_logic;
      out_ready    : in  std_logic;
      blk_sop      : in  std_logic;
      blk_eop      : in  std_logic;
      blk_size_in  : in  unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
      input_c      : in  signed(3*IN_WIDTH_g-1 downto 0);
      iter         : in  unsigned(IT_WIDTH_c-1 downto 0);
      blk_size_out : out std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
      dout         : out std_logic_vector(OUT_WIDTH_g-1 downto 0);
      in_ready     : out std_logic;
      dout_sop     : out std_logic;
      dout_eop     : out std_logic;
      out_valid    : out std_logic
      );
  end component auk_dspip_ctc_umts_map_decoder;

  component auk_dspip_ctc_umts_siso is
    generic (
      IN_WIDTH_g          : positive := 6;
      NPROCESSORS_g       : positive := 8;
      SOFT_WIDTH_g        : positive := 9;
      NUM_ENGINES_WIDTH_g : positive := 3;   -- log2_ceil_one(NPROCESSORS_g);
      DATA_WIDTH_g        : positive := 10;  -- log2_ceil_one(MAX_FRAME_SIZE_c/NPROCESSORS_g);
      RAM_TYPE_g          : string   := "AUTO";  -- "MLAB", "M9K" --
      ADDRESS_WIDTH_g     : positive := 10;  -- =log2_ceil(MAX_SUB_FRAME_SIZE_c)
      DECODER_TYPE_g      : string   := "MAXLOGMAP"  --"CONST_LOGMAP"  --
      );
    port (
      clk                    : in  std_logic;
      ena                    : in  std_logic;
      reset                  : in  std_logic;
      decode_start           : in  std_logic;
      block_size             : in  unsigned (FRAME_SIZE_WIDTH_c-1 downto 0);
      data_in                : in  signed (3*IN_WIDTH_g*NPROCESSORS_g-1 downto 0);
      max_iter_dec           : in  unsigned (IT_WIDTH_c-1 downto 0);
      iter_dec               : in  unsigned (IT_WIDTH_c-1 downto 0);
      intlvr_addr_rd         : out unsigned(ADDRESS_WIDTH_g-1 downto 0);
      intlvr_ram_rden        : out std_logic;
      intlvr_info_from_mem   : in  std_logic_vector(NPROCESSORS_g*(ADDRESS_WIDTH_g+NUM_ENGINES_WIDTH_g)-1 downto 0);
      deintlvr_addr_rd       : out unsigned(ADDRESS_WIDTH_g-1 downto 0);
      deintlvr_ram_rden      : out std_logic;
      deintlvr_info_from_mem : in  std_logic_vector(NPROCESSORS_g*(ADDRESS_WIDTH_g+NUM_ENGINES_WIDTH_g)-1 downto 0);
      input_rd_addr          : out unsigned (ADDRESS_WIDTH_g-1 downto 0);
      input_rden             : out std_logic;
      dout                   : out unsigned(NPROCESSORS_g-1 downto 0);
      dout_address           : out unsigned(NPROCESSORS_g*ADDRESS_WIDTH_g-1 downto 0);
      dout_sop               : out std_logic;
      dout_eop               : out std_logic;
      out_valid              : out std_logic_vector(NPROCESSORS_g-1 downto 0);
      max_num_bits_per_eng   : out unsigned(DATA_WIDTH_g-1 downto 0);  -- maximum number of bits per engine for output block
      num_bits_last_engine   : out unsigned(DATA_WIDTH_g-1 downto 0);  -- number of bits last engine for output block
      half_decode_done       : out std_logic
      );
  end component auk_dspip_ctc_umts_siso;

  component auk_dspip_ctc_umts_fifo is
    generic (
      IN_WIDTH_g          : positive := 6;
      NPROCESSORS_g       : positive := 4;
      RAM_TYPE_g          : string   := "AUTO";
      NUM_ENGINES_WIDTH_g : positive := 2;   -- log2_ceil_one(NPROCESSORS_g);
      ADDRESS_WIDTH_g     : positive := 12;  -- =log2_ceil(MAX_FRAME_SIZE_c/NPROCESSORS_g)
      DATA_IN_WIDTH_g     : positive := 20;  -- = IN_WIDTH_g + ADDRESS_WIDTH_g + NUM_ENGINES_WIDTH_g
      DATA_OUT_WIDTH_g    : positive := 18   -- = IN_WIDTH_g + ADDRESS_WIDTH_g
      );
    port (
      clk   : in  std_logic;
      ena   : in  std_logic;
      reset : in  std_logic;
      wrreq : in  std_logic_vector(NPROCESSORS_g-1 downto 0);
      data  : in  std_logic_vector(NPROCESSORS_g*DATA_IN_WIDTH_g-1 downto 0);
      wren  : out std_logic_vector(NPROCESSORS_g-1 downto 0);
      q     : out std_logic_vector(NPROCESSORS_g*DATA_OUT_WIDTH_g-1 downto 0)
      );
  end component auk_dspip_ctc_umts_fifo;

  component auk_dspip_ctc_umts_out_mem
    generic (
      A_DATWIDTH : integer;
      B_DATWIDTH : integer;
      A_ADDWIDTH : integer;
      B_ADDWIDTH : integer;
      A_NWORDS   : integer;
      B_NWORDS   : integer);
    port (
      aclr      : in  std_logic := '0';
      clock     : in  std_logic;
      data      : in  std_logic_vector (A_DATWIDTH - 1 downto 0);
      rdaddress : in  std_logic_vector (B_ADDWIDTH - 1 downto 0);
      wraddress : in  std_logic_vector (A_ADDWIDTH - 1 downto 0);
      wren      : in  std_logic := '1';
      q         : out std_logic_vector (B_DATWIDTH - 1 downto 0));
  end component;

  component auk_dspip_ctc_umts_output is
    generic (
      NPROCESSORS_g       : positive := 8;
      OUT_WIDTH_g         : positive := 1;
      NUM_ENGINES_WIDTH_g : positive := 3;  -- log2_ceil_one(NPROCESSORS_g)
      NWORDS_BLK_WIDTH_g  : positive := 10  -- log2_ceil(FRAME_SIZE_WIDTH_c / NPROCESSORS_g)
      );
    port (
      clk                  : in  std_logic;
      reset                : in  std_logic;
      -- Interface with Turbo MAP decoders
      -- Avalon Streaming with NO BACK PRESSURE SUPPORT
      din                  : in  std_logic_vector(NPROCESSORS_g - 1 downto 0);
      din_addr             : in  std_logic_vector(NPROCESSORS_g*NWORDS_BLK_WIDTH_g - 1 downto 0);
      din_sop              : in  std_logic;
      din_eop              : in  std_logic;
      din_valid            : in  std_logic_vector(NPROCESSORS_g - 1 downto 0);
      blk_size             : in  std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
      max_num_bits_per_eng : in  std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- maximum number of bits per engine for output block
      num_bits_last_engine : in  std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- number of bits last engine for output block
      buffer_avail         : out std_logic;
      -- Output interface : Avalon Streaming with Ready Latency of zero
      dout_valid           : out std_logic;
      dout                 : out std_logic_vector(OUT_WIDTH_g - 1 downto 0);
      dout_blk_size        : out std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
      dout_sop             : out std_logic;
      dout_eop             : out std_logic;
      dout_ready           : in  std_logic
      );
  end component auk_dspip_ctc_umts_output;

  component auk_dspip_ctc_umts_ast_sink is
    generic (
      MAX_BLK_SIZE_g : natural;
      TAIL_BITS_g    : natural;
      DATAWIDTH_g    : natural);
    port (
      clk           : in  std_logic;
      reset         : in  std_logic;
      sink_blk_size : in  std_logic_vector(log2_ceil(MAX_BLK_SIZE_g) - 1 downto 0);
      sink_iter     : in  std_logic_vector(IT_WIDTH_c-1 downto 0);
      sink_sop      : in  std_logic;
      sink_eop      : in  std_logic;
      sink_valid    : in  std_logic;
      sink_ready    : out std_logic;
      sink_data     : in  std_logic_vector(DATAWIDTH_g - 1 downto 0);
      sink_error    : in  std_logic_vector(1 downto 0);
      out_error     : out std_logic_vector(1 downto 0);
      out_valid     : out std_logic;
      out_ready     : in  std_logic;
      out_sop       : out std_logic;
      out_eop       : out std_logic;
      out_data      : out std_logic_vector(DATAWIDTH_g - 1 downto 0);
      out_blk_size  : out std_logic_vector(log2_ceil(MAX_BLK_SIZE_g)- 1 downto 0);
      out_iter      : out std_logic_vector(IT_WIDTH_c-1 downto 0));
  end component auk_dspip_ctc_umts_ast_sink;

  component auk_dspip_ctc_umtsitlv_prime_rom
    port (
      prime_index : in unsigned(6 downto 0);

      prime : out unsigned(8 downto 0);
      g0    : out unsigned(4 downto 0);
-- gcd : out vec_of_vec(19 downto 0, 5 downto 0);
-- gcd : out gcd_vec;

      gcd_index : in  unsigned(4 downto 0);
      gcd       : out unsigned(7 downto 0);

      reset  : in std_logic;
      enable : in std_logic;
      clk    : in std_logic
      );
  end component;

  component auk_dspip_ctc_umtsitlv_papbpc_table
    port (
      itlv_length  : in  unsigned(12 downto 0);
      PAPBPC_index : in  unsigned(5 downto 0);
      PAPBPC_val   : out unsigned(4 downto 0);

      reset  : in std_logic;
      enable : in std_logic;
      clk    : in std_logic
      );
  end component;

  component auk_dspip_ctc_umtsitlv_setup_control
    generic (
      gCNT_WIDTH : integer := 13
      );

    port (
      start_setup       : in  std_logic;
      itlv_setup_active : out std_logic;
      itlv_rdy          : out std_logic;

      R10not20 : out std_logic;
      R        : out unsigned(4 downto 0);
      K        : in  unsigned(12 downto 0);
      C        : out unsigned(8 downto 0);
      RxC      : out unsigned(12 downto 0);
      prime    : out unsigned(8 downto 0);
      g0       : out unsigned(4 downto 0);

      gcd_index : out unsigned(4 downto 0);
      gcd       : out unsigned(7 downto 0);
      wr_gcd    : out std_logic;

      gen_mul_seq_finished : in  std_logic;
      start_gen_mul_seq    : out std_logic;

      flag_a  : out std_logic;
      flag_b  : out std_logic;
      flag_b6 : out std_logic;
      flag_c  : out std_logic;

      clk    : in std_logic;
      enable : in std_logic;
      reset  : in std_logic
      );
  end component;

  component auk_dspip_ctc_umtsitlv_mult_seq_gen
    port (
      prime          : in unsigned(8 downto 0);
      g0             : in unsigned(4 downto 0);
      start_mult_seq : in std_logic;

      index    : out unsigned(8 downto 0);
      element  : out unsigned(8 downto 0);
      wr       : out std_logic;
      active   : out std_logic;
      finished : out std_logic;

      abort  : in std_logic;
      reset  : in std_logic;
      enable : in std_logic;
      clk    : in std_logic
      );
  end component;

  component auk_dspip_ctc_umts_mem

    generic (
      gADDR_WIDTH : integer := 8;
      gDATA_WIDTH : integer := 16
      );
    port (
      wr_addr : in unsigned(gADDR_WIDTH-1 downto 0);
      rd_addr : in unsigned(gADDR_WIDTH-1 downto 0);

      datai : in  unsigned(gDATA_WIDTH-1 downto 0);
      datao : out unsigned(gDATA_WIDTH-1 downto 0);

      rd     : in std_logic;
      wr     : in std_logic;
      enable : in std_logic;
      reset  : in std_logic;
      clk    : in std_logic
      );
  end component;

  component auk_dspip_ctc_umts_itlv
    generic (
      gCOUNTER_WIDTH : integer := 13);

    port (
      out_addr     : out unsigned(gCOUNTER_WIDTH-1 downto 0);
      RxC          : out unsigned(gCOUNTER_WIDTH-1 downto 0);
      blk_size     : in  unsigned(gCOUNTER_WIDTH-1 downto 0);
      addr_valid   : out std_logic;
      seq_gen_done : out std_logic;
      start_load   : in  std_logic;
      clk          : in  std_logic;
      enable       : in  std_logic;
      reset        : in  std_logic);
  end component;

  component auk_dspip_ctc_umts2_itlv
    generic (
      gCOUNTER_WIDTH : integer := 13);

    port (
      out_addr     : out unsigned(gCOUNTER_WIDTH-1 downto 0);
      RxC          : out unsigned(gCOUNTER_WIDTH-1 downto 0);
      blk_size     : in  unsigned(gCOUNTER_WIDTH-1 downto 0);
      addr_valid   : out std_logic;
      seq_gen_done : out std_logic;
      start_load   : in  std_logic;
      clk          : in  std_logic;
      enable       : in  std_logic;
      reset        : in  std_logic);
  end component;

  component auk_dspip_ctc_umtsitlv2_lut is
    port (
      n_exponent : in  unsigned(8 downto 0);
      five_lsbs  : in  unsigned(4 downto 0);
      table_out  : out unsigned(7 downto 0);

      reset  : in std_logic;
      enable : in std_logic;
      clk    : in std_logic);
  end component auk_dspip_ctc_umtsitlv2_lut;
  
  component auk_dspip_ctc_umtsitlv_multmod

    port (
      a       : in  unsigned(8 downto 0);
      b       : in  unsigned(7 downto 0);   -- max.89
      c       : in  unsigned(8 downto 0);
      axbmodc : out unsigned(14 downto 0);  -- multiplication/modulo result

      reset  : in std_logic;
      enable : in std_logic;
      clk    : in std_logic
      );

  end component;

  component auk_dspip_ctc_umtsitlv_mul_pipe

    port (a     : in  unsigned(12 downto 0);
          b     : in  unsigned(7 downto 0);   -- max.89
          a_x_b : out unsigned(20 downto 0);  -- multiplication result

          reset  : in std_logic;
          enable : in std_logic;
          clk    : in std_logic
          );
  end component;

  component auk_dspip_ctc_umts_ditlv_seq_gen

    port (
      ditlv_addr       : out unsigned(12 downto 0);
      ditlv_addr_valid : out std_logic;
      prune_me         : out std_logic;
      seq_gen_done     : out std_logic;
      papbpc_index     : out unsigned(4 downto 0);
      papbpc_val       : in  unsigned(4 downto 0);
      table_p_index    : out unsigned(4 downto 0);
      table_p_val      : in  unsigned(7 downto 0);
      table_c_index    : out unsigned(8 downto 0);
      table_c_val      : in  unsigned(8 downto 0);
      prime            : in  unsigned(8 downto 0);
      R10not20         : in  std_logic;
      max_column       : in  unsigned(8 downto 0);
      itlv_length      : in  unsigned(12 downto 0);
      RxC              : in  unsigned(12 downto 0);
      R                : in  unsigned(4 downto 0);
      flag_a           : in  std_logic;
      flag_b           : in  std_logic;
      flag_b6          : in  std_logic;
      flag_c           : in  std_logic;

      start_incr : in std_logic;
      start_decr : in std_logic;
      reset      : in std_logic;
      enable     : in std_logic;
      clk        : in std_logic
      );
  end component;

  component auk_dspip_ctc_umts_enc_ast_block_sink is
    generic (
      MAX_BLK_SIZE_g : natural;
      DATAWIDTH_g    : natural);
    port (
      clk           : in  std_logic;
      reset         : in  std_logic;
      sink_blk_size : in  std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
      sink_sop      : in  std_logic;
      sink_eop      : in  std_logic;
      sink_valid    : in  std_logic;
      sink_ready    : out std_logic;
      sink_data     : in  std_logic_vector(DATAWIDTH_g - 1 downto 0);
      sink_error    : in  std_logic_vector(1 downto 0);
      out_error     : out std_logic_vector(1 downto 0);
      out_valid     : out std_logic;
      out_ready     : in  std_logic;
      out_sop       : out std_logic;
      out_eop       : out std_logic;
      out_data      : out std_logic_vector(DATAWIDTH_g - 1 downto 0);
      out_blk_size  : out std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0));
  end component auk_dspip_ctc_umts_enc_ast_block_sink;

  component auk_dspip_ctc_umts_encoder is
    generic (
      USE_MEMORY_FOR_ROM_g : boolean := false  -- indicate if use memory for ROM
      );
    port (
      clk          : in  std_logic;
      ena          : in  std_logic;
      reset        : in  std_logic;
      in_valid     : in  std_logic;
      out_ready    : in  std_logic;
      blk_sop      : in  std_logic;
      blk_eop      : in  std_logic;
      blk_error    : in  std_logic_vector(1 downto 0);
      blk_size_in  : in  unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
      data_in      : in  std_logic;
      blk_size_out : out std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
      dout         : out std_logic_vector(2 downto 0);
      in_ready     : out std_logic;
      out_error    : out std_logic_vector(1 downto 0);
      dout_sop     : out std_logic;
      dout_eop     : out std_logic;
      out_valid    : out std_logic);
  end component auk_dspip_ctc_umts_encoder;

  component auk_dspip_ctc_umts_enc_input is
    port (
      clk          : in  std_logic;
      ena          : in  std_logic;
      reset        : in  std_logic;
      blk_size_in  : in  unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
      rd_addr_a    : in  std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
      rd_addr_b    : in  std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
      rd_en        : in  std_logic;
      rd_clken     : in  std_logic;
      data_in      : in  std_logic;
      data_out     : out std_logic_vector(1 downto 0);
      blk_size_out : out unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
      ---------------------------------------------------------------------------
      -- control signals
      ---------------------------------------------------------------------------
      in_valid     : in  std_logic;
      in_sop       : in  std_logic;
      in_eop       : in  std_logic;
      in_error     : in  std_logic_vector(1 downto 0);
      encode_done  : in  std_logic;
      encode_stall : in  std_logic;
      start_encode : out std_logic;
      input_stall  : out std_logic);
  end component auk_dspip_ctc_umts_enc_input;


  component auk_dspip_ctc_umts_enc_input_ram is
    port (
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
  end component auk_dspip_ctc_umts_enc_input_ram;

  component auk_dspip_ctc_umts_encode is
    port (
      clk            : in  std_logic;
      ena            : in  std_logic;
      reset          : in  std_logic;
      encode_start   : in  std_logic;
      blk_size_in    : in  unsigned (FRAME_SIZE_WIDTH_c-1 downto 0);
      data_in        : in  std_logic_vector(1 downto 0);
      rd_addr_input  : out std_logic_vector (FRAME_SIZE_WIDTH_c-1 downto 0);
      rd_addr_intlvr : out std_logic_vector (FRAME_SIZE_WIDTH_c-1 downto 0);
      input_rden     : out std_logic;
      dout           : out std_logic_vector(2 downto 0);
      dout_sop       : out std_logic;
      dout_eop       : out std_logic;
      blk_size_out   : out unsigned (FRAME_SIZE_WIDTH_c-1 downto 0);
      encode_done    : out std_logic;
      out_valid      : out std_logic
      );
  end component auk_dspip_ctc_umts_encode;

  component auk_dspip_ctc_umts_conv_encode is
    generic (
      CONSTRAINT_LENGTH_g : positive);
    port (
      clk     : in  std_logic;
      ena     : in  std_logic;
      reset   : in  std_logic;
      data_in : in  std_logic;
      dout    : out std_logic_vector(1 downto 0)
      );
  end component auk_dspip_ctc_umts_conv_encode;
  
 end package auk_dspip_ctc_umts_lib_pkg;

package body auk_dspip_ctc_umts_lib_pkg is

end package body auk_dspip_ctc_umts_lib_pkg;
