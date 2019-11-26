----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_encoder.vhd
--
-- Project     : Turbo Codec
-- Description : CTC Encoder
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

entity auk_dspip_ctc_umts_encoder is
  generic (
    USE_MEMORY_FOR_ROM_g : boolean  := false      -- indicate if use memory for ROM
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
    out_valid   : out std_logic
    );

end entity auk_dspip_ctc_umts_encoder;

architecture SYN of auk_dspip_ctc_umts_encoder is

  constant MAX_SUB_FRAME_SIZE_c  : integer  := MAX_FRAME_SIZE_c;
  constant MAX_SUB_FRAME_WIDTH_c : positive := log2_ceil_one(MAX_SUB_FRAME_SIZE_c);

  signal block_size     : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);  -- current block size
  signal block_id       : std_logic_vector(BLOCK_ADDRESS_WIDTH_c-1 downto 0);

  signal input_rden  : std_logic;       -- input read enable for encoder
  signal data_in_ram : std_logic_vector(1 downto 0);  -- ram contents

  signal rd_addr_input  : std_logic_vector(log2_ceil(MAX_SUB_FRAME_SIZE_c)-1 downto 0);
  signal rd_addr_intlvr : std_logic_vector(log2_ceil(MAX_SUB_FRAME_SIZE_c)-1 downto 0);

  signal f1plusf2modK : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal f2times2modK : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal Km2f2modK    : signed(FRAME_SIZE_WIDTH_c downto 0);
  signal twoKm2f2modK : signed(FRAME_SIZE_WIDTH_c downto 0);

  signal encode_done  : std_logic;
  signal encode_done_s  : std_logic;
  signal encode_stall : std_logic;
  signal start_encode : std_logic;
  signal input_stall  : std_logic;

  type   enc_state_t is (IDLE, ENCODE);
  signal enc_state      : enc_state_t;
  signal next_enc_state : enc_state_t;

  signal start_encode_delayed : std_logic;

  signal ena_encoder      : std_logic;

  signal core_dout        : std_logic_vector(2 downto 0);
  signal core_blksize_out : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal core_out_valid   : std_logic;
  signal core_out_valid_s : std_logic;
  signal core_out_sop     : std_logic;
  signal core_out_eop     : std_logic;
  signal source_stall     : std_logic;
  
  component auk_dspip_ctc_umts_enc_ast_block_src is
    generic (
      MAX_BLK_SIZE_WIDTH_g : natural;
      DATAWIDTH_g          : natural);
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      blk_size     : in  std_logic_vector(MAX_BLK_SIZE_WIDTH_g-1 downto 0);
      in_valid     : in  std_logic;
      source_stall : out std_logic;
      in_data      : in  std_logic_vector(DATAWIDTH_g - 1 downto 0);
      in_sop       : in std_logic;
      in_eop       : in std_logic;
      source_valid : out std_logic;
      source_ready : in  std_logic;
      source_sop   : out std_logic;
      source_eop   : out std_logic;
      source_data  : out std_logic_vector(DATAWIDTH_g - 1 downto 0));
  end component auk_dspip_ctc_umts_enc_ast_block_src;

  
begin  -- architecture SYN

  start_encode_delayed_proc : process (clk, reset)
  begin  -- process start_encode_delayed_proc
    if reset = '1' then  
      start_encode_delayed <= '0';
    elsif rising_edge(clk) then 
      start_encode_delayed <= start_encode;
    end if;
  end process start_encode_delayed_proc;

  -- Registered state process. 
  fsm_reg : process (clk, reset)
  begin
    if reset = '1' then
      enc_state <= IDLE;
    elsif rising_edge(clk) then
      if ena = '1' then
        enc_state <= next_enc_state;
      end if;
    end if;
  end process fsm_reg;

  -- Combintorial next state process.
  fsm_comb : process (enc_state, encode_done, start_encode)
  begin
    case enc_state is
      when IDLE =>
        if start_encode = '1' then
          next_enc_state <= ENCODE;
        else
          next_enc_state <= IDLE;
        end if;
      when ENCODE =>
        if encode_done = '1' then
          next_enc_state <= IDLE;
        else
          next_enc_state <= ENCODE;
        end if;
      when others =>
        next_enc_state <= IDLE;
    end case;
  end process fsm_comb;

  input_buffer : auk_dspip_ctc_umts_enc_input
    port map(
      clk          => clk,
      ena          => ena,
      reset        => reset,
      blk_size_in  => blk_size_in,
      rd_addr_a    => rd_addr_input,
      rd_addr_b    => rd_addr_intlvr,
      data_in      => data_in,
      rd_en        => input_rden,
      rd_clken     => ena_encoder,
      data_out     => data_in_ram,
      blk_size_out => block_size,
      in_valid     => in_valid,
      in_sop       => blk_sop,
      in_eop       => blk_eop,
      in_error     => blk_error,
      encode_done  => encode_done,
      encode_stall => encode_stall,
      start_encode => start_encode,
      input_stall  => input_stall
      );

  blk_size_out <= std_logic_vector(core_blksize_out);

  encode_inst : auk_dspip_ctc_umts_encode
    port map (
      clk            => clk,
      ena            => ena_encoder,
      reset          => reset,
      encode_start   => start_encode_delayed,
      blk_size_in    => block_size,
      data_in        => data_in_ram,
      rd_addr_input  => rd_addr_input,
      rd_addr_intlvr => rd_addr_intlvr,
      input_rden     => input_rden,
      blk_size_out   => core_blksize_out,
      dout           => core_dout,
      dout_sop       => core_out_sop,
      dout_eop       => core_out_eop,
      out_valid      => core_out_valid,
      encode_done    => encode_done_s
      );


  in_ready   <= not(input_stall);

-------------------------------------------------------------------------------
-- source module
-------------------------------------------------------------------------------
  ena_encoder <= not source_stall;
--  encode_stall <= source_stall;
--  out_error  <= blk_error;

  source_ctrl_proc : process (clk, reset)
  begin  -- process source_ctrl_proc
    if reset = '1' then
      encode_stall <= '0';
      out_error  <= "00";
    elsif rising_edge(clk) then
      encode_stall <= source_stall;
      out_error  <= blk_error;
    end if;
  end process source_ctrl_proc;

  encode_done_proc : process (clk, reset)
  begin  -- process encode_done_proc
    if reset = '1' then  
      encode_done <= '0';
    elsif rising_edge(clk) then 
      if encode_done_s = '1' and source_stall = '0' then  
        encode_done <= '1';
      else
        encode_done <= '0';
      end if;
    end if;
  end process encode_done_proc;

  ast_block_src_inst: auk_dspip_ctc_umts_enc_ast_block_src
    generic map (
      MAX_BLK_SIZE_WIDTH_g => FRAME_SIZE_WIDTH_c,
      DATAWIDTH_g          => 3)
    port map (
      clk          => clk,
      reset        => reset,
      blk_size     => std_logic_vector(core_blksize_out),
      in_valid     => core_out_valid,
      source_stall => source_stall,
      in_data      => core_dout,
      in_sop       => core_out_sop,
      in_eop       => core_out_eop,
      source_valid => out_valid,
      source_ready => out_ready,
      source_sop   => dout_sop,
      source_eop   => dout_eop,
      source_data  => dout
      );
  
end architecture SYN;
