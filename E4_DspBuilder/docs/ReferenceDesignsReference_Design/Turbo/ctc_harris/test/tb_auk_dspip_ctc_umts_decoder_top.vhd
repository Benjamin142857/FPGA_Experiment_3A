-- ================================================================================
-- (c) 2007 Altera Corporation. All rights reserved.
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
-- 
-- Description : Top level for Turbo decoder test bench
--
-------------------------------------------------------------------------
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/test/tb_auk_dspip_ctc_umts_decoder_top.vhd#2 $
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;

-------------------------------------------------------------------------------

entity tb_auk_dspip_ctc_umts_decoder_top is
  generic (
    TB_IN_WIDTH_g          : positive := 8;
    TB_OUT_WIDTH_g         : positive := 1;
    TB_NENGINES_g          : positive := 4;
    TB_RAM_TYPE_g          : string  := "AUTO";
    TB_DECODER_TYPE_g      : string   := "MAXLOGMAP";
    TB_MAX_BLK_SIZE_g      : natural  := 5118; -- 5114 + 4(tail bits)
    INPUTFILE_DIR_g        : string   := "";
    OUTPUTFILE_DIR_g       : string   := "";
    NUM_FRAMES_g           : natural  := 0;  -- 0 for all input frames, # for a number of frames
    DELAY_g                : natural  := 0
    ); 
end entity tb_auk_dspip_ctc_umts_decoder_top;

architecture tb of tb_auk_dspip_ctc_umts_decoder_top is

  constant TB_IT_WIDTH_c : positive := 5;

  -- component generics
  constant TAIL_BITS_c               : natural := 4;
  constant DATAWIDTH_g               : natural := TB_IN_WIDTH_g*3;
  constant MIN_BLK_SIZE_c            : natural := 40;
  constant VARIABLE_BLKSIZE_c        : natural := 2;  -- read from a file
  constant ERROR_TEST_c              : natural := 0;
  constant REPORT_BLKSIZE_c          : boolean := false;
  constant SOURCE_SYMBOLS_PER_BEAT_c : natural := 3;
  constant SOURCE_SYMBOL_DELIMETER_c : string  := " ";
  constant SOURCE_SYMBOL_DATAWIDTH_c : natural := TB_IN_WIDTH_g;
  constant SOURCE_RAND_DELAY_c       : natural := 1;
  constant SOURCE_RANDOM_FRAME_DELAY_c: natural := 1;

  -- these constants control the flow of data into the sink
  constant SINK_SYMBOLS_PER_BEAT_c : natural := TB_OUT_WIDTH_g;
  constant SINK_SYMBOL_DELIMETER_c : string  := "\n";
  constant SINK_SYMBOL_DATAWIDTH_c : natural := 1;
  -- 1 = random intra-block delays in sink data (back-pressure), 0 = no delays
  constant SINK_RAND_DELAY_c       : natural := 1;

  constant tclk : time := 1 ns;

  -- component ports
  signal clk           : std_logic;
  signal reset         : std_logic;
  signal reset_n       : std_logic;
  signal blk_size      : std_logic_vector(integer(ceil(log2(real(TB_MAX_BLK_SIZE_g + TAIL_BITS_c))))-1 downto 0);
  signal sink_error    : std_logic_vector(1 downto 0);
  signal sink_valid    : std_logic;
  signal sink_sop      : std_logic;
  signal sink_eop      : std_logic;
  signal sink_ready    : std_logic;
  signal sink_data     : std_logic_vector(SOURCE_SYMBOL_DATAWIDTH_c*SOURCE_SYMBOLS_PER_BEAT_c - 1 downto 0);
  signal sink_blk_size : std_logic_vector(integer(ceil(log2(real(TB_MAX_BLK_SIZE_g)))) - 1 downto 0);
  signal sink_iter     : std_logic_vector(TB_IT_WIDTH_c - 1 downto 0);

  signal source_blk_size : std_logic_vector(integer(ceil(log2(real(TB_MAX_BLK_SIZE_g))))- 1 downto 0);
  signal output_blk_size : std_logic_vector(integer(ceil(log2(real(TB_MAX_BLK_SIZE_g))))- 1 downto 0);
  signal source_sop      : std_logic;
  signal source_eop      : std_logic;
  signal source_valid    : std_logic;
  signal source_data     : std_logic_vector(SINK_SYMBOLS_PER_BEAT_c*SINK_SYMBOL_DATAWIDTH_c - 1 downto 0);
  signal source_ready    : std_logic;
  signal source_error    : std_logic_vector(1 downto 0);

  constant NUM_DONE_c : natural := 100;
  signal   cnt_done   : natural range 0 to NUM_DONE_c;
  signal   seen_eof   : std_logic;
  signal   eof        : std_logic;

  signal enable              : std_logic;
  signal source_model_enable : std_logic;

  signal frames_in_cnt  : natural;
  signal frames_out_cnt : natural;

  component auk_dspip_avalon_streaming_source_model is
    generic (
      FILENAME_g            : string;
      RANDOM_DELAY_g        : natural;
      RANDOM_FRAME_DELAY_g    : natural;
      ERROR_TEST_g          : natural;
      MAX_BLKSIZE_g         : natural;
      MIN_BLKSIZE_g         : natural;
      VARIABLE_BLKSIZE_g    : natural;
      FORMAT_g              : string;
      REPORT_BLKSIZE_g      : boolean;
      BLKSIZE_REPORT_FILE_g : string;
      SOP_NUM_DATA_g        : natural;
      SOP_DATAWIDTH_g       : natural;
      SYMBOLS_PER_BEAT_g    : natural;
      SYMBOL_DELIMETER_g    : string;
      SYMBOL_DATAWIDTH_g    : natural);
    port (
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      enable       : in  std_logic;
      source_valid : out std_logic;
      source_ready : in  std_logic;
      source_sop   : out std_logic;
      source_eop   : out std_logic;
      source_data  : out std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0);
      blksize      : out std_logic_vector(integer(ceil(log2(real(MAX_BLKSIZE_g))))- 1 downto 0);
      sop_data     : out std_logic_vector(SOP_DATAWIDTH_g*SOP_NUM_DATA_g -1 downto 0);
      eof          : out std_logic);
  end component auk_dspip_avalon_streaming_source_model;

  component auk_dspip_ctc_umts_decoder_top is
    generic (
      IN_WIDTH_g          : positive;
      OUT_WIDTH_g         : positive;
      NENGINES_g          : positive;
      RAM_TYPE_g          : string;
      DECODER_TYPE_g      : string
      );
    port (
      clk           : in  std_logic;
      reset_n         : in  std_logic;
      sink_blk_size : in  std_logic_vector(12 downto 0);
      sink_iter     : in  std_logic_vector(TB_IT_WIDTH_c - 1 downto 0);
      sink_sop      : in  std_logic;
      sink_eop      : in  std_logic;
      sink_valid    : in  std_logic;
      sink_ready    : out std_logic;
      sink_data     : in  std_logic_vector(3*TB_IN_WIDTH_g - 1 downto 0);
      sink_error    : in  std_logic_vector(1 downto 0);
      source_error  : out std_logic_vector(1 downto 0);
      source_blk_size : out std_logic_vector(12 downto 0);
      source_valid  : out std_logic;
      source_ready  : in  std_logic;
      source_sop    : out std_logic;
      source_eop    : out std_logic;
      source_data   : out std_logic_vector(OUT_WIDTH_g - 1 downto 0));
  end component auk_dspip_ctc_umts_decoder_top;

  component auk_dspip_avalon_streaming_sink_model is
    generic (
      FILENAME_g         : string;
      RANDOM_DELAY_g     : natural;
      MAX_BLKSIZE_g      : natural;
      MIN_BLKSIZE_g      : natural;
      VARIABLE_BLKSIZE_g : natural;
      -- array (defined in signal list)
      ERROR_SEVERITY_g   : severity_level;
      REPORT_AS_g        : string;
      -- HEX (default if > 32 bits), BIN  
      SYMBOLS_PER_BEAT_g : natural;
      SYMBOL_DELIMETER_g : string;
      SYMBOL_DATAWIDTH_g : natural);
    port (
      clk        : in  std_logic;
      reset_n    : in  std_logic;
      -- enables the model
      enable     : in  std_logic;
      blksize    : in  std_logic_vector(integer(ceil(log2(real(MAX_BLKSIZE_g))))- 1 downto 0) := (others => '0');
      -- atlantic signals
      sink_valid : in  std_logic;
      sink_ready : out std_logic;
      sink_sop   : in  std_logic;
      sink_eop   : in  std_logic;
      sink_data  : in  std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0));
  end component auk_dspip_avalon_streaming_sink_model;

 
  signal end_test  : std_logic;
  
begin
  
  clkgen : process
  begin
    -- seen 10 consecutive deasserted valids
    if (cnt_done = NUM_DONE_c - 1) then
      clk <= '0';
      report "Done.";
      wait;
    else
      clk <= '0';
      wait for tclk;
      clk <= '1';
      wait for tclk;
    end if;
  end process clkgen;

  -- count for NUM_DONE_c after last frame
  done_p : process (clk, reset_n)
  begin  -- process done_p
    if reset_n = '0' then
      cnt_done <= 0;
    elsif rising_edge(clk) then
      if (NUM_FRAMES_g /= 0 and frames_out_cnt = NUM_FRAMES_g) or
        (NUM_FRAMES_g = 0 and seen_eof = '1' and frames_out_cnt = frames_in_cnt)then
        if cnt_done = NUM_DONE_c - 1 then
          cnt_done <= 0;
        else
          cnt_done <= cnt_done + 1;
        end if;
      end if;
    end if;
  end process done_p;

  resetgen : process
    variable rand_v     : real     := 0.0;
    variable rand_int_v : natural  := 0;
    variable seed1      : positive := 2;
    variable seed2      : positive := 4;

  begin  -- process resetgen
    enable <= '0';
    reset_n  <= '1';
    wait for 0.5*tclk;
    reset_n  <= '0';
    wait for tclk*6.0;
    reset_n  <= '1';
    wait until clk'event and clk = '1';
    enable <= '1';
    wait;
  end process resetgen;

 
  -- count the number of input frames
  cnt_frames_in : process (clk, reset_n)
  begin  -- process cnt_frames_in
    if reset_n = '0' then
      frames_in_cnt       <= 0;
      source_model_enable <= '0';
     end_test <= '0';
    elsif rising_edge(clk) then
      if enable = '1' and end_test = '0' then
        source_model_enable <= '1';
        if (sink_eop = '1' and sink_valid = '1' and sink_ready = '1')then
          if (NUM_FRAMES_g /= 0) and (frames_in_cnt = NUM_FRAMES_g - 1) then
            source_model_enable <= '0';
            end_test <= '1';
            report "eof found";
          end if;
          frames_in_cnt <= frames_in_cnt + 1;
        end if;
      else
        source_model_enable <= '0';
      end if;
    end if;
  end process cnt_frames_in;

  source_model_inst : auk_dspip_avalon_streaming_source_model
    generic map (
      FILENAME_g            => "ctc_data_input.txt",
      RANDOM_DELAY_g        => SOURCE_RAND_DELAY_c*DELAY_g,
      RANDOM_FRAME_DELAY_g => SOURCE_RANDOM_FRAME_DELAY_c*DELAY_g,
      MAX_BLKSIZE_g         => TB_MAX_BLK_SIZE_g + TAIL_BITS_c,
      MIN_BLKSIZE_g         => MIN_BLK_SIZE_c + TAIL_BITS_c,
      VARIABLE_BLKSIZE_g    => VARIABLE_BLKSIZE_c,
      ERROR_TEST_g          => ERROR_TEST_c,
      FORMAT_g              => "SIGNED_INTEGER",
      REPORT_BLKSIZE_g      => REPORT_BLKSIZE_c,
      BLKSIZE_REPORT_FILE_g => "",
      SOP_NUM_DATA_g        => 1,
      SOP_DATAWIDTH_g       => TB_IT_WIDTH_c,
      SYMBOLS_PER_BEAT_g    => SOURCE_SYMBOLS_PER_BEAT_c,
      SYMBOL_DELIMETER_g    => SOURCE_SYMBOL_DELIMETER_c,
      SYMBOL_DATAWIDTH_g    => SOURCE_SYMBOL_DATAWIDTH_c)
    port map (
      clk          => clk,
      reset_n      => reset_n,
      -- enables the model
      enable       => source_model_enable,
      -- atlantic signals
      source_valid => sink_valid,
      source_ready => sink_ready,
      source_sop   => sink_sop,
      source_eop   => sink_eop,
      -- data contains real and imaginary data, imaginary in LSW, real in MSW
      source_data  => sink_data,
      -- sideband signals
      eof          => eof,
      blksize      => blk_size,
      sop_data     => sink_iter
      );

  sink_error    <= (others => '0');
  sink_blk_size <= std_logic_vector(resize(unsigned(blk_size) - TAIL_BITS_c, sink_blk_size'length));

  -- component instantiation

  DUT : auk_dspip_ctc_umts_decoder_top
    generic map (
      IN_WIDTH_g          => TB_IN_WIDTH_g,
      OUT_WIDTH_g         => TB_OUT_WIDTH_g,
      NENGINES_g          => TB_NENGINES_g,
      RAM_TYPE_g          => TB_RAM_TYPE_g,
      DECODER_TYPE_g      => TB_DECODER_TYPE_g
      )
    port map (
      clk           => clk,
      reset_n         => reset_n,
      sink_blk_size => sink_blk_size,
      sink_iter     => sink_iter,
      sink_sop      => sink_sop,
      sink_eop      => sink_eop,
      sink_valid    => sink_valid,
      sink_ready    => sink_ready,
      sink_data     => sink_data,
      sink_error    => sink_error,
      source_error  => source_error,
      source_blk_size => source_blk_size,
      source_valid  => source_valid,
      source_ready  => source_ready,
      source_sop    => source_sop,
      source_eop    => source_eop,
      source_data   => source_data);

 
  output_blk_size <= std_logic_vector(unsigned(source_blk_size)/TB_OUT_WIDTH_g);
  
  sink_model_inst : auk_dspip_avalon_streaming_sink_model
    generic map (
      FILENAME_g         => "ctc_decoded_output.txt",
      RANDOM_DELAY_g     => SINK_RAND_DELAY_c*DELAY_g,
      MAX_BLKSIZE_g      => TB_MAX_BLK_SIZE_g,
      MIN_BLKSIZE_g      => MIN_BLK_SIZE_c,
      VARIABLE_BLKSIZE_g => VARIABLE_BLKSIZE_c,
      -- array (defined in signal list)
      ERROR_SEVERITY_g   => failure,
      REPORT_AS_g        => "BIN",
      SYMBOLS_PER_BEAT_g => SINK_SYMBOLS_PER_BEAT_c,
      SYMBOL_DELIMETER_g => SINK_SYMBOL_DELIMETER_c,
      SYMBOL_DATAWIDTH_g => SINK_SYMBOL_DATAWIDTH_c)
    port map (
      clk        => clk,
      reset_n    => reset_n,
      -- enables the model
      enable     => enable,
      blksize    => output_blk_size,
      -- atlantic signals
      sink_valid => source_valid,
      sink_ready => source_ready,
      sink_sop   => source_sop,
      sink_eop   => source_eop,
      sink_data  => source_data);


  cnt_frames_out : process (clk, reset_n)
  begin  -- process cnt_frames_in
    if reset_n = '0' then
      frames_out_cnt <= 0;
    elsif rising_edge(clk) then
      if source_eop = '1' and source_valid = '1' and source_ready = '1' then
        frames_out_cnt <= frames_out_cnt + 1;
      end if;
    end if;
  end process cnt_frames_out;

  -- look for NUM_DONE_c consecutive deasserted valids
  seen_eof_p : process (clk, reset_n)
  begin  -- process done_p
    if reset_n = '0' then
      seen_eof <= '0';
    elsif rising_edge(clk) then
      if eof = '1' and seen_eof = '0' then
        seen_eof <= '1';
        report "eof found";
      end if;
    end if;
  end process seen_eof_p;

end architecture tb;

