----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_map_decoder.vhd
--
-- Project     : Turbo Codec
-- Description : MAP decoder
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/decoder/auk_dspip_ctc_umts_map_decoder.vhd#2 $
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

entity auk_dspip_ctc_umts_map_decoder is
  generic (
    IN_WIDTH_g          : positive := 6;
    OUT_WIDTH_g         : positive := 1;
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

end entity auk_dspip_ctc_umts_map_decoder;

architecture SYN of auk_dspip_ctc_umts_map_decoder is

  constant MAX_SUB_FRAME_SIZE_c  : integer  := MAX_FRAME_SIZE_c/NPROCESSORS_g;
  constant NUM_ENGINES_WIDTH_c   : integer  := log2_ceil_one(NPROCESSORS_g);
  constant MAX_SUB_FRAME_WIDTH_c : positive := log2_ceil_one(MAX_SUB_FRAME_SIZE_c);

  signal block_size : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);  -- current block size

  signal input_rden  : std_logic;       -- input read enable for siso decoder
  signal data_in_ram : signed(3*NPROCESSORS_g*IN_WIDTH_g-1 downto 0);  -- ram contents

  signal address_read_input : unsigned (log2_ceil(MAX_SUB_FRAME_SIZE_c)-1 downto 0);

  signal decode_done      : std_logic;
  signal half_decode_done : std_logic;
  signal decode_stall     : std_logic;
  signal start_decode     : std_logic;
  signal input_stall      : std_logic;

  type   dec_state_t is (IDLE, DECODE);
  signal dec_state      : dec_state_t;
  signal next_dec_state : dec_state_t;

  signal iteration_cnt   : unsigned(IT_WIDTH_c-1 downto 0);
  signal iter_dec_to_run : unsigned(IT_WIDTH_c-1 downto 0);  -- requested decoding iteration
  signal half_iter_dec   : unsigned(IT_WIDTH_c-1 downto 0);

  signal start_half_decode      : std_logic;
  signal ena_siso_decoder       : std_logic;
  signal out_valid_siso         : std_logic_vector(NPROCESSORS_g-1 downto 0);
  signal out_valid_to_output    : std_logic_vector(NPROCESSORS_g-1 downto 0);
  signal out_buffer_ready       : std_logic;
  signal siso_out_address       : unsigned(NPROCESSORS_g*MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal siso_out_sop           : std_logic;
  signal siso_out_eop           : std_logic;
  signal output_in_sop          : std_logic;
  signal output_in_eop          : std_logic;
  signal siso_dout              : unsigned(NPROCESSORS_g-1 downto 0);
  signal intlvr_addr_rd         : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal intlvr_ram_rden        : std_logic;
  signal intlvr_info_from_mem   : std_logic_vector(NPROCESSORS_g*(MAX_SUB_FRAME_WIDTH_c+NUM_ENGINES_WIDTH_c)-1 downto 0);
  signal deintlvr_addr_rd       : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal deintlvr_ram_rden      : std_logic;
  signal deintlvr_info_from_mem : std_logic_vector(NPROCESSORS_g*(MAX_SUB_FRAME_WIDTH_c+NUM_ENGINES_WIDTH_c)-1 downto 0);

  signal max_num_bits_per_eng : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);  -- maximum number of bits per engine for output block
  signal num_bits_last_engine : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);  -- number of bits last engine for output block

begin  -- architecture SYN

  -- synthesis translate_off
  assert (NPROCESSORS_g = 2 or NPROCESSORS_g = 4 or NPROCESSORS_g = 8) report "NPROCESSORS_g must be 2 or 4 or 8." severity error;

  assert (OUT_WIDTH_g = 1) report "OUTPUT word width must be 1 bit." severity error;
  -- synthesis translate_on

  decode_done_proc : process (clk, reset)
  begin  -- process decode_done_proc
    if reset = '1' then
      decode_done <= '0';
    elsif rising_edge(clk) then
      if half_decode_done = '1' and dec_state = DECODE and iteration_cnt = iter_dec_to_run-1 then
        decode_done <= '1';
      else
        decode_done <= '0';
      end if;
    end if;
  end process decode_done_proc;

  decode_stall <= not (out_buffer_ready);

  start_half_decode <= '1' when start_decode = '1' else '0';

  half_iter_dec <= iteration_cnt;

  ena_siso_decoder <= out_buffer_ready;  --'1' when start_decode = '1' else '0' when decode_done = '1' else ena_siso_decoder_reg;

-- ena_siso_decoder_reg_proc : process (clk, reset)
-- begin                                -- process ena_siso_decoder_reg_proc
--    if reset = '1' then
--      ena_siso_decoder_reg <= '0';
--    elsif rising_edge(clk) then
--      if ena = '1' then
--        if start_decode = '1' then
--          ena_siso_decoder_reg <= '1';
--        elsif decode_done = '1' then
--          ena_siso_decoder_reg <= '0';
--        end if;
--      end if;
--    end if;
--  end process ena_siso_decoder_reg_proc;

  iteration_cnt_proc : process (clk, reset)
  begin  -- process iteration_cnt_proc
    if reset = '1' then
      iteration_cnt <= to_unsigned(0, IT_WIDTH_c);
    elsif rising_edge(clk) then
      if ena = '1' then
        if start_decode = '1' then
          iteration_cnt <= to_unsigned(0, IT_WIDTH_c);
        elsif dec_state = DECODE and half_decode_done = '1' then
-- if iteration_cnt < iter_dec_to_run then
          iteration_cnt <= iteration_cnt + to_unsigned(1, IT_WIDTH_c);
-- end if;
        end if;
      end if;
    end if;
  end process iteration_cnt_proc;

  -- Registered state process. 
  fsm_reg : process (clk, reset)
  begin
    if reset = '1' then
      dec_state <= IDLE;
    elsif rising_edge(clk) then
      dec_state <= next_dec_state;
    end if;
  end process fsm_reg;

  -- Combintorial next state process.
  fsm_comb : process (start_decode, decode_done, dec_state)
  begin
    case dec_state is
      when IDLE =>
        if start_decode = '1' then
          next_dec_state <= DECODE;
        else
          next_dec_state <= IDLE;
        end if;
      when DECODE =>
        if decode_done = '1' then
          next_dec_state <= IDLE;
        else
          next_dec_state <= DECODE;
        end if;
      when others =>
        next_dec_state <= IDLE;
    end case;
  end process fsm_comb;

  input_buffer : auk_dspip_ctc_umts_input
    generic map (
      NPROCESSORS_g       => NPROCESSORS_g,
      NUM_ENGINES_WIDTH_g => NUM_ENGINES_WIDTH_c,
      DATA_WIDTH_g        => MAX_SUB_FRAME_WIDTH_c,
      INPUT_WIDTH_g       => 3*IN_WIDTH_g,
      ADDRESS_WIDTH_g     => MAX_SUB_FRAME_WIDTH_c
      )
    port map(
      clk                    => clk,
      ena                    => ena,
      reset                  => reset,
      blk_size_in            => blk_size_in,
      iter_in                => iter,
      data_in                => input_c,
      addr_rd                => address_read_input,
      data_out               => data_in_ram,
      read_en                => input_rden,
      it_to_run              => iter_dec_to_run,
      blk_size_out           => block_size,
      intlvr_addr_rd         => intlvr_addr_rd,
      intlvr_ram_rden        => intlvr_ram_rden,
      intlvr_info_from_mem   => intlvr_info_from_mem,
      deintlvr_addr_rd       => deintlvr_addr_rd,
      deintlvr_ram_rden      => deintlvr_ram_rden,
      deintlvr_info_from_mem => deintlvr_info_from_mem,
      in_valid               => in_valid,
      in_sop                 => blk_sop,
      in_eop                 => blk_eop,
      decode_done            => decode_done,
      decode_stall           => decode_stall,
      start_decode           => start_decode,
      input_stall            => input_stall
      );

  auk_dspip_ctc_umts_siso_inst : auk_dspip_ctc_umts_siso
    generic map (
      IN_WIDTH_g          => IN_WIDTH_g,
      NPROCESSORS_g       => NPROCESSORS_g,
      SOFT_WIDTH_g        => SOFT_WIDTH_g,
      NUM_ENGINES_WIDTH_g => NUM_ENGINES_WIDTH_c,
      DATA_WIDTH_g        => MAX_SUB_FRAME_WIDTH_c,
      RAM_TYPE_g          => RAM_TYPE_g,
      ADDRESS_WIDTH_g     => MAX_SUB_FRAME_WIDTH_c,
      DECODER_TYPE_g      => DECODER_TYPE_g
      )
    port map (
      clk                    => clk,
      ena                    => ena_siso_decoder,
      reset                  => reset,
      decode_start           => start_half_decode,
      block_size             => block_size,
      data_in                => data_in_ram,
      max_iter_dec           => iter_dec_to_run,
      iter_dec               => half_iter_dec,
      intlvr_addr_rd         => intlvr_addr_rd,
      intlvr_ram_rden        => intlvr_ram_rden,
      intlvr_info_from_mem   => intlvr_info_from_mem,
      deintlvr_addr_rd       => deintlvr_addr_rd,
      deintlvr_ram_rden      => deintlvr_ram_rden,
      deintlvr_info_from_mem => deintlvr_info_from_mem,
      input_rd_addr          => address_read_input,
      input_rden             => input_rden,
      dout                   => siso_dout,
      dout_address           => siso_out_address,
      dout_sop               => siso_out_sop,
      dout_eop               => siso_out_eop,
      out_valid              => out_valid_siso,
      max_num_bits_per_eng   => max_num_bits_per_eng,
      num_bits_last_engine   => num_bits_last_engine,
      half_decode_done       => half_decode_done
      );

  out_valid_to_output <= out_valid_siso when iteration_cnt = iter_dec_to_run-1 and dec_state = DECODE else (others => '0');
  output_in_sop       <= siso_out_sop   when iteration_cnt = iter_dec_to_run-1 and dec_state = DECODE else '0';
  output_in_eop       <= siso_out_eop   when iteration_cnt = iter_dec_to_run-1 and dec_state = DECODE else '0';

  ouput_1bit_gen : if (OUT_WIDTH_g = 1) generate
    auk_dspip_ctc_umts_output_inst : auk_dspip_ctc_umts_output
      generic map (
        NPROCESSORS_g       => NPROCESSORS_g,
        OUT_WIDTH_g         => OUT_WIDTH_g,
        NUM_ENGINES_WIDTH_g => log2_ceil_one(NPROCESSORS_g),
        NWORDS_BLK_WIDTH_g  => MAX_SUB_FRAME_WIDTH_c
        )
      port map (
        clk                  => clk,
        reset                => reset,
        -- Interface with Turbo MAP decoders
        -- Avalon Streaming with NO BACK PRESSURE SUPPORT
        din                  => std_logic_vector(siso_dout),
        din_addr             => std_logic_vector(siso_out_address),
        din_sop              => output_in_sop,
        din_eop              => output_in_eop,
        din_valid            => out_valid_to_output,
        blk_size             => std_logic_vector(block_size),
        max_num_bits_per_eng => std_logic_vector(max_num_bits_per_eng),
        num_bits_last_engine => std_logic_vector(num_bits_last_engine),
        buffer_avail         => out_buffer_ready,
        -- Output interface : Avalon Streaming with Ready Latency of zero
        dout_valid           => out_valid,
        dout_blk_size        => blk_size_out,
        dout                 => dout,
        dout_sop             => dout_sop,
        dout_eop             => dout_eop,
        dout_ready           => out_ready
        );

  end generate ouput_1bit_gen;

  ouput_not1bit_gen : if (OUT_WIDTH_g /= 1) generate
    assert OUT_WIDTH_g = 1 report "Not supported" severity error;
  end generate ouput_not1bit_gen;

  in_ready <= not(input_stall);

end architecture SYN;
