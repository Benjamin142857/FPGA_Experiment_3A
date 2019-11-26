----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_enc_input.vhd
--
-- Project     : Turbo Codec
-- Description : Input Unit for Turbo encoder
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

entity auk_dspip_ctc_umts_enc_input is
  port (
    clk          : in  std_logic;
    ena          : in  std_logic;
    reset        : in  std_logic;
    blk_size_in  : in  unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
    rd_addr_a    : in  std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
    rd_addr_b    : in  std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
    data_in      : in  std_logic;
    rd_en        : in  std_logic;
    rd_clken     : in  std_logic;
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
    input_stall  : out std_logic
    );
end entity auk_dspip_ctc_umts_enc_input;

architecture SYN of auk_dspip_ctc_umts_enc_input is

  constant MAX_SUB_FRAME_SIZE_c  : natural  := MAX_FRAME_SIZE_c;
  constant MEMORY_WIDTH_c        : natural  := 1;
  constant MEMORY_DEPTH_c        : natural  := MAX_SUB_FRAME_SIZE_c;
  constant ADDRESS_WIDTH_c       : natural  := log2_ceil_one(MEMORY_DEPTH_c);
  constant MAX_SUB_FRAME_WIDTH_c : positive := log2_ceil_one(MAX_SUB_FRAME_SIZE_c);

  signal buffer_full  : std_logic;  -- indicating if the input buffer is full
  signal bank_id      : integer range 0 to 1;  -- buffer bank id
  signal bank_id_reg  : integer range 0 to 1;  -- buffer bank id
  signal read_bank_id : integer range 0 to 1;  -- buffer bank id that encoder is using
  signal bank_full    : std_logic_vector(1 downto 0);  -- indicating if the input bank is full

  type block_size_type is array (0 to 1) of unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);

  signal block_size_data : block_size_type;
  signal block_size_s    : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);

  signal start_encode_s : std_logic;
  signal bank_id_s      : std_logic_vector(0 downto 0);

  signal blk_cnt : unsigned (FRAME_SIZE_WIDTH_c-1 downto 0);  --integer range 0 to MAX_FRAME_SIZE_c + NUM_OF_TAIL_BIT_CYCLES_c-1;

  signal is_encoder_started : std_logic;  -- is in the state of encoding previously
  signal can_start_encoder      : std_logic;  -- is in the state of encoding
  signal seen_sop          : std_logic;

  type address_type is array (0 to 1) of std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);

  signal write_en   : std_logic_vector(1 downto 0);  -- input memory write enable
  signal read_en    : std_logic_vector(1 downto 0);  -- input memory read enable

  signal address_a : address_type;
  signal address_b : address_type;
  signal dout_0    : std_logic_vector(1 downto 0);
  signal dout_1    : std_logic_vector(1 downto 0);

  
begin  -- architecture SYN

  start_encode <= start_encode_s;
  
  address_a(0) <= std_logic_vector(blk_cnt) when bank_id_s(0) = '0' else rd_addr_a;
  address_b(0) <= std_logic_vector(blk_cnt) when bank_id_s(0) = '0' else rd_addr_b;

  address_a(1) <= std_logic_vector(blk_cnt) when bank_id_s(0) = '1' else rd_addr_a;
  address_b(1) <= std_logic_vector(blk_cnt) when bank_id_s(0) = '1' else rd_addr_b;

  bank_id_s <=  std_logic_vector(to_unsigned(bank_id, 1));
  
  read_en_proc : process (bank_id_s, rd_en) is
  begin  -- process read_en_proc
    if rd_en = '1' then
      read_en(0) <= bank_id_s(0);
      read_en(1) <= not(bank_id_s(0));
    else
      read_en <= "00";
    end if;
  end process read_en_proc;

  -- purpose: define write_en
  -- type   : combinational
  -- inputs : ena, bank_id
  -- outputs: write_en
  write_en_proc : process (bank_id_s, ena, in_valid, buffer_full) is
  begin  -- process write_en_proc
    if ena = '1' and in_valid = '1' and buffer_full = '0' then
      write_en(0) <= not(bank_id_s(0));
      write_en(1) <= bank_id_s(0);
    else
      write_en <= "00";
    end if;
  end process write_en_proc;

  data_out <= dout_0 when read_bank_id = 0 else dout_1;

  input_stall  <= '1' when buffer_full = '1'                         else '0';
  buffer_full    <= '1' when bank_full(0) = '1' and bank_full(1) = '1' else '0';
  can_start_encoder <= '1' when bank_full(read_bank_id) = '1' else '0';

  start_proc : process (clk, reset)
  begin  -- process start_proc
    if reset = '1' then
      start_encode_s <= '0';
      is_encoder_started <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        if is_encoder_started = '0' and can_start_encoder = '1' and in_error = "00" then
          start_encode_s <= '1';
          is_encoder_started <= '1';
        elsif encode_done = '1' then
          is_encoder_started <= '0';
        elsif encode_stall = '0' then
          start_encode_s <= '0';
        end if;
      end if;
    end if;
  end process start_proc;

  bank_id      <= bank_id_reg;
  read_bank_id <= 1 - bank_id;

  block_size_s <= blk_size_in;

  block_size_proc : process (clk, reset)
  begin  -- process block_size_proc
    if reset = '1' then
      block_size_data <= (others => to_unsigned(MAX_FRAME_SIZE_c, FRAME_SIZE_WIDTH_c));
    elsif rising_edge(clk) then
      if ena = '1' then
        if in_valid = '1' and in_sop = '1' and buffer_full = '0' then
          block_size_data(bank_id) <= block_size_s;
        end if;
      end if;
    end if;
  end process block_size_proc;

  bank_state_proc : process (clk, reset)
  begin
    if reset = '1' then
      bank_full <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        if encode_done = '1' then
          bank_full(read_bank_id) <= '0';
        end if;
        if in_valid = '1' and in_eop = '1' and in_sop = '0' and blk_cnt = block_size_s-1 then
          bank_full(bank_id) <= '1';
        end if;
      end if;
    end if;
  end process bank_state_proc;

  blk_cnt_proc : process (clk, reset)
  begin  -- process blk_cnt_proc
    if reset = '1' then
      blk_cnt  <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
      seen_sop <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        if in_error /= "00" then
          blk_cnt  <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
          seen_sop <= '0';
        elsif in_valid = '1' and buffer_full = '0' then
          if in_sop = '1' then
            blk_cnt  <= to_unsigned(1, FRAME_SIZE_WIDTH_c);
            seen_sop <= '1';
          elsif in_eop = '1' then
            blk_cnt  <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
            seen_sop <= '0';
          elsif seen_sop = '1' then
            blk_cnt <= blk_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process blk_cnt_proc;


  bank_id_proc : process (clk, reset)
  begin  -- process bank_id_proc
    if reset = '1' then
      bank_id_reg <= 0;
    elsif rising_edge(clk) then
      if ena = '1' then
        -- toggle the bank_id when eop is reached
        -- check both eop and blk_cnt for handling error recovery (if a full
        -- block is received)
        if (in_valid = '1' and in_eop = '1' and in_sop = '0' and
            (bank_full(read_bank_id) = '0' or encode_done = '1') and
            blk_cnt = block_size_s-1) or
          (buffer_full = '1' and encode_done = '1') then
          bank_id_reg <= 1 - bank_id_reg;
        end if;
      end if;
    end if;
  end process bank_id_proc;


  -- Memory used for input double buffering
  input_ram_inst0 : auk_dspip_ctc_umts_enc_input_ram
    port map (
      address_a => address_a(0),
      address_b => address_b(0),
      clock     => clk,
      data_in   => data_in,
      rden_a    => read_en(0),
      rden_b    => read_en(0),
      wren_a    => write_en(0),
      rd_clken  => rd_clken, 
      q_a       => dout_0(0),
      q_b       => dout_0(1)
      );

  input_ram_inst1 : auk_dspip_ctc_umts_enc_input_ram
    port map (
      address_a => address_a(1),
      address_b => address_b(1),
      clock     => clk,
      data_in   => data_in,
      rden_a    => read_en(1),
      rden_b    => read_en(1),
      wren_a    => write_en(1),
      rd_clken  => rd_clken, 
      q_a       => dout_1(0),
      q_b       => dout_1(1)
      );

  blk_size_out <= block_size_data(read_bank_id);

end architecture SYN;

