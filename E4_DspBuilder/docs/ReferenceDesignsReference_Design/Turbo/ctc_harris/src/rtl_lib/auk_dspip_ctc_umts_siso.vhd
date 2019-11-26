----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_siso.vhd
--
-- Project     : Turbo Codec
-- Description : SISO decoder
--
-- Author      :  Zhengjun Pan
--
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/decoder/auk_dspip_ctc_umts_siso.vhd#3 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;
use altera_mf.altera_mf_components.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;
use auk_dspip_lib.auk_dspip_lib_pkg.all;

entity auk_dspip_ctc_umts_siso is
  generic (
    IN_WIDTH_g          : positive := 6;
    NPROCESSORS_g       : positive := 4;
    SOFT_WIDTH_g        : positive := 10;
    NUM_ENGINES_WIDTH_g : positive := 2;   -- log2_ceil_one(NPROCESSORS_g);
    DATA_WIDTH_g        : positive := 11;  -- log2_ceil_one(MAX_FRAME_SIZE_c/NPROCESSORS_g);
    RAM_TYPE_g          : string   := "AUTO";
    ADDRESS_WIDTH_g     : positive := 11;  -- =log2_ceil(MAX_SUB_FRAME_SIZE_c)
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
end entity auk_dspip_ctc_umts_siso;

architecture SYN of auk_dspip_ctc_umts_siso is

  constant MAX_SUB_FRAME_SIZE_c         : integer  := MAX_FRAME_SIZE_c/NPROCESSORS_g;
  constant NUM_ENGINES_WIDTH_c          : integer  := log2_ceil_one(NPROCESSORS_g);
  constant MAX_SUB_FRAME_WIDTH_c        : positive := log2_ceil_one(MAX_SUB_FRAME_SIZE_c);
  constant PREVS_ALPHABETA_DEPTH_c      : positive := 1+DIV_CEIL(MAX_SUB_FRAME_SIZE_c, SLDWIN_SIZE_c);  -- 1+768/32 = 25 when parallel window size is 32
  constant PREVS_ALPHABETA_ADDR_WIDTH_c : positive := log2_ceil(2*PREVS_ALPHABETA_DEPTH_c);  -- 8*7*9 = 504 for 8 parallel engines
  constant SLDWIN_SIZE_WIDTH_c          : positive := log2_ceil(SLDWIN_SIZE_c);
  constant BETA_RAM_ADDR_WIDTH_c        : positive := SLDWIN_SIZE_WIDTH_c+1;
  constant MAXLOGMAP_LLR_LATENCY_c      : positive := 5;  -- llr_cu latency + 1(roundsat)
  constant INPUT_READ_LATENCY_c         : positive := 3;  -- latency for beta_cu to start
  constant OUTPUT_LATENCY_c             : positive := MAXLOGMAP_LLR_LATENCY_c + 4;  -- (1 for interleavering, 1 for writing to ram, 2 for ready to read)
  constant OUT_VALID_LATENCY_c          : positive := OUTPUT_LATENCY_c-1;
  constant MAX_TAIL_BIT_COUNT_c         : positive := 14;
  constant MAX_WINDOW_CNT_c             : positive := DIV_CEIL(MAX_SUB_FRAME_SIZE_c, SLDWIN_SIZE_c);
  constant DEINTLVR_INFO_WIDTH_c        : natural  := MAX_SUB_FRAME_WIDTH_c+NUM_ENGINES_WIDTH_g;
  constant MEM_ADDRESS_WIDTH_c          : natural  := ADDRESS_WIDTH_g + 1;
  constant MEMORY_DEPTH_c               : natural  := 2**MEM_ADDRESS_WIDTH_c;

  constant DEBUG_OUTPUT_U_c : natural := 1;
  constant DEBUG_BETA_c     : natural := 0;

  type trellis_array is array (NPROCESSORS_g-1 downto 0) of signed((MAX_STATES_c-1)*SOFT_WIDTH_g-1 downto 0);
  type trellis_in_mem is array (NPROCESSORS_g-1 downto 0) of signed((MAX_STATES_c-1)*SOFT_WIDTH_g-1 downto 0);

  signal alpha              : trellis_in_mem;
  signal alpha_prime        : trellis_in_mem;
  signal alpha_prime_in     : trellis_in_mem;
  signal beta               : trellis_in_mem;
  signal beta_to_mem        : trellis_in_mem;
  signal beta_from_mem      : trellis_in_mem;
  signal prev_beta_to_mem   : trellis_in_mem;
  signal prev_beta_from_mem : trellis_in_mem;
  signal beta_prime_in      : trellis_in_mem;
  signal sload_alpha        : std_logic;
  signal sload_beta         : std_logic;
  signal sload_beta_last    : std_logic;
  signal sload_beta_bcu     : std_logic_vector(NPROCESSORS_g-1 downto 0);

  type   gamma_in_mem is array (NPROCESSORS_g-1 downto 0) of signed(3*SOFT_WIDTH_g+IN_WIDTH_g-1 downto 0);
  type   metric_type is array (2 downto 0) of signed(SOFT_WIDTH_g-1 downto 0);
  type   metric_array_type is array (NPROCESSORS_g-1 downto 0) of metric_type;
  signal gamma_to_mem   : gamma_in_mem;
  signal gamma_from_mem : gamma_in_mem;
  signal metric_input   : metric_array_type;

  signal sub_block_size      : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);  -- current sub-block size
  signal sub_block_size_last : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);  -- sub-block size for last engine
  signal sub_block_size_diff : unsigned(NUM_ENGINES_WIDTH_g downto 0);

  type input_array_type is array (NPROCESSORS_g-1 downto 0) of signed(IN_WIDTH_g-1 downto 0);

  signal input_u         : input_array_type;
  signal input_u_for_llr : input_array_type;
  signal input_u_ram_arr : input_array_type;

  signal input_u_wren_arr            : std_logic_vector(NPROCESSORS_g-1 downto 0);  -- write enable for input_u
  signal input_u_rden                : std_logic;  -- read enable for input_u
  signal beta_ram_rden               : std_logic;  -- read enable for beta_ram
  signal beta_ram_wren               : std_logic;  -- write enable for beta_ram
  signal gamma_ram_rden              : std_logic;  -- read enable for gamma_ram
  signal gamma_ram_wren              : std_logic;  -- write enable for gamma_ram
  signal prev_alpha_ram_rden         : std_logic;  -- read enable for prev_beta_ram
  signal prev_alpha_ram_wren         : std_logic;  -- write enable for prev_beta_ram
  signal prev_beta_ram_rden          : std_logic;  -- read enable for prev_beta_ram
  signal prev_beta_ram_wren          : std_logic;  -- write enable for prev_beta_ram
  signal prev_alphabeta_ram_rden     : std_logic;  -- read enable for prev_beta_ram
  signal prev_alphabeta_ram_wren     : std_logic;  -- write enable for prev_beta_ram
  signal prev_alphabeta_ram_wren_reg : std_logic;  -- write enable for
                                                   -- prev_beta_ram registered

  signal metric_c_data : metric_array_type;

  signal input_c_sys : input_array_type;
  signal input_c_par : input_array_type;

  type   tail_bit_array_type is array (11 downto 0) of signed(IN_WIDTH_g-1 downto 0);
  signal input_tail_bits : tail_bit_array_type;

  signal address_read_u       : unsigned (MEM_ADDRESS_WIDTH_c-1 downto 0);
  signal dec_cnt              : integer range 0 to MAX_FRAME_SIZE_c-1;
  signal rd_addr_cnt          : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal rd_addr_cnt_s        : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal intlvr_addr_rd_cnt   : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal deintlvr_addr_rd_cnt : unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);

  type soft_bits_internal_array_type is array (NPROCESSORS_g-1 downto 0) of signed(SOFT_WIDTH_g-1 downto 0);
  type input_u_array_slv_type is array (NPROCESSORS_g-1 downto 0) of std_logic_vector(IN_WIDTH_g-1 downto 0);

  signal output_u         : input_array_type;
  signal output_u_ram_arr : input_array_type;

  signal output_u_from_llr : soft_bits_internal_array_type;
  signal output_u_diff     : soft_bits_internal_array_type;
  signal output_u_scaled   : soft_bits_internal_array_type;
  signal output_u_slv      : input_u_array_slv_type;
  signal output_u_ram      : signed(NPROCESSORS_g*IN_WIDTH_g-1 downto 0);
  signal detected_data     : unsigned(NPROCESSORS_g-1 downto 0);

  constant FIFO_IN_WIDTH_c  : positive := IN_WIDTH_g+DATA_WIDTH_g+NUM_ENGINES_WIDTH_c+1;
  constant FIFO_OUT_WIDTH_c : positive := IN_WIDTH_g+DATA_WIDTH_g+1;

  signal fifo_in          : std_logic_vector(NPROCESSORS_g*FIFO_IN_WIDTH_c-1 downto 0);
  signal fifo_out         : std_logic_vector(NPROCESSORS_g*FIFO_OUT_WIDTH_c-1 downto 0);
  signal fifo_wrreq_slv   : std_logic_vector(NPROCESSORS_g-1 downto 0);
  signal fifo_wren_slv    : std_logic_vector(NPROCESSORS_g-1 downto 0);  -- write enable for input_u
  signal fifo_flushed     : std_logic;
  signal fifo_flushed_reg : std_logic;


  type   address_write_u_arr_type is array (NPROCESSORS_g-1 downto 0) of unsigned (log2_ceil(2*MAX_SUB_FRAME_SIZE_c)-1 downto 0);
  signal address_write_u_arr : address_write_u_arr_type;

  type   dout_address_arr_type is array (NPROCESSORS_g-1 downto 0) of std_logic_vector(ADDRESS_WIDTH_g-1 downto 0);
  signal dout_address_arr : dout_address_arr_type;

  type   soft_bits_internal_array_type_2 is array (NPROCESSORS_g-1 downto 0) of signed(SOFT_WIDTH_g+1 downto 0);
  signal output_u_scaled_s : soft_bits_internal_array_type_2;

  type   block_end_beta_data_type is array (0 to 1) of signed((MAX_STATES_c-1)*SOFT_WIDTH_g-1 downto 0);
  signal block_end_beta : block_end_beta_data_type;

  signal tail_bit_cnt           : integer range 0 to MAX_TAIL_BIT_COUNT_c;
  signal beta_cnt               : unsigned(SLDWIN_SIZE_WIDTH_c-1 downto 0);
  signal alpha_cnt              : unsigned(SLDWIN_SIZE_WIDTH_c-1 downto 0);
  signal window_cnt_alpha       : integer range 0 to MAX_WINDOW_CNT_c;
  signal window_cnt_beta        : integer range 0 to MAX_WINDOW_CNT_c;
  signal iter_dec_int_for_input : unsigned (IT_WIDTH_c-1 downto 0);

  signal address_beta_read   : unsigned(BETA_RAM_ADDR_WIDTH_c-1 downto 0);
  signal address_beta_write  : unsigned(BETA_RAM_ADDR_WIDTH_c-1 downto 0);
  signal address_gamma_read  : unsigned(BETA_RAM_ADDR_WIDTH_c-1 downto 0);
  signal address_gamma_write : unsigned(BETA_RAM_ADDR_WIDTH_c-1 downto 0);

  signal address_prev_beta_read  : unsigned(PREVS_ALPHABETA_ADDR_WIDTH_c-1 downto 0);
  signal address_prev_beta_write : unsigned(PREVS_ALPHABETA_ADDR_WIDTH_c-1 downto 0);

  type intlvr_sub_loc_array is array (0 to NPROCESSORS_g-1) of unsigned(NUM_ENGINES_WIDTH_c-1 downto 0);
  type intlvr_location_array is array (0 to NPROCESSORS_g-1) of unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  type intlvr_inter_reg_array is array (0 to NPROCESSORS_g-2) of unsigned(NUM_ENGINES_WIDTH_c-1 downto 0);

  signal intlvr_sub_locs       : intlvr_sub_loc_array;  -- interleaver sub-locations
  signal intlvr_location_arr   : intlvr_location_array;
  signal deintlvr_sub_locs     : intlvr_sub_loc_array;  -- deinterleaver sub-locations
  signal deintlvr_location_arr : intlvr_location_array;

  signal half_decode_done_s : std_logic;

  signal max_dec_cnt_value : integer range 0 to 2**FRAME_SIZE_WIDTH_c-1;
  signal startup_latency   : unsigned(5 downto 0);

  signal dec_cnt_delayed     : integer range 0 to MAX_FRAME_SIZE_c-1;
  signal dec_cnt_delayed_slv : std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal dec_cnt_slv         : std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);

  signal input_u_slv : input_u_array_slv_type;

  signal last_sldwin_size_s      : integer range 0 to SLDWIN_SIZE_c;
  signal last_sldwin_size_last_s : integer range 0 to SLDWIN_SIZE_c;
  signal num_of_sld_window       : integer range 0 to PREVS_ALPHABETA_DEPTH_c;
  signal num_of_sld_window_last  : integer range 0 to PREVS_ALPHABETA_DEPTH_c;
  signal is_small_block          : std_logic;  -- indicate if the sub_block_size is smaller than the sliding window size SLDWIN_SIZE_c
  signal is_small_last_block     : std_logic;  -- indicate if the sub_block_size is smaller than the sliding window size SLDWIN_SIZE_c

  signal out_valid_s      : std_logic;
  signal out_valid_last_s : std_logic;
  signal dout_sop_s       : std_logic;
  signal dout_eop_s       : std_logic;

  signal is_in_beta_window_range : std_logic;

  signal is_the_first_iteration       : boolean;
  signal is_the_second_iteration      : boolean;
  signal is_dec_cnt_lt_sub_block_size : boolean;  -- is dec_cnt < sub_block_size
  signal is_in_decode                 : std_logic;

  signal input_rden_s    : std_logic;
  signal input_rden_tail : std_logic;

  type   state_t is (IDLE, READ_TAIL, PROCESS_TAIL, DECODE);
  signal state      : state_t;
  signal next_state : state_t;


begin  -- architecture SYN

  last_sldwin_size_proc : process (clk, reset)
  begin  -- process first_sldwin_size_proc
    if reset = '1' then
      last_sldwin_size_s      <= 0;
      last_sldwin_size_last_s <= 0;
    elsif rising_edge(clk) then
      if to_integer(sub_block_size mod SLDWIN_SIZE_c) = 0 then
        last_sldwin_size_s <= SLDWIN_SIZE_c;
      else
        last_sldwin_size_s <= to_integer(sub_block_size mod SLDWIN_SIZE_c);
      end if;
      if to_integer(sub_block_size_last mod SLDWIN_SIZE_c) = 0 then
        last_sldwin_size_last_s <= SLDWIN_SIZE_c;
      else
        last_sldwin_size_last_s <= to_integer(sub_block_size_last mod SLDWIN_SIZE_c);
      end if;
    end if;
  end process last_sldwin_size_proc;

  is_in_decode_proc : process (clk, reset)
  begin  -- process is_in_decode_proc
    if reset = '1' then
      is_in_decode <= '0';
    elsif rising_edge(clk) then
      if decode_start = '1' then
        is_in_decode <= '1';
      elsif half_decode_done_s = '1' and iter_dec = max_iter_dec-1 then
        is_in_decode <= '0';
      end if;
    end if;
  end process is_in_decode_proc;

  max_num_bits_per_eng <= sub_block_size;
  num_bits_last_engine <= sub_block_size_last;

  sub_block_size_gen1 : if NPROCESSORS_g = 1 generate
    sub_block_size_proc : process (block_size)
    begin  -- process sub_block_size_proc
      sub_block_size      <= block_size;
      sub_block_size_last <= block_size;
      sub_block_size_diff <= to_unsigned(0, sub_block_size_diff'length);
    end process sub_block_size_proc;
  end generate sub_block_size_gen1;

  sub_block_size_gen2 : if NPROCESSORS_g = 2 generate
    sub_block_size_proc : process (clk, reset)
    begin  -- process sub_block_size_proc
      if reset = '1' then
        sub_block_size      <= to_unsigned(0, sub_block_size'length);
        sub_block_size_last <= to_unsigned(0, sub_block_size_last'length);
      elsif rising_edge(clk) then
        if block_size(0) = '0' then
          sub_block_size <= block_size(block_size'high downto 1);
        else
          sub_block_size <= block_size(block_size'high downto 1) + 1;
        end if;
        sub_block_size_last <= block_size(block_size'high downto 1);
        -- sub_block_size_diff <= to_unsigned(1, sub_block_size_diff'length);
        sub_block_size_diff <= resize(sub_block_size & "0" - block_size, sub_block_size_diff'length);
      end if;
    end process sub_block_size_proc;
  end generate sub_block_size_gen2;

  sub_block_size_gen4 : if NPROCESSORS_g = 4 generate
    sub_block_size_proc : process (clk, reset)
    begin  -- process sub_block_size_proc
      if reset = '1' then
        sub_block_size      <= to_unsigned(0, sub_block_size'length);
        sub_block_size_last <= to_unsigned(0, sub_block_size_last'length);
      elsif rising_edge(clk) then
        if block_size(1 downto 0) = "00" then
          sub_block_size      <= block_size(block_size'high downto 2);
          sub_block_size_last <= block_size(block_size'high downto 2);
        else
          sub_block_size      <= block_size(block_size'high downto 2) + 1;
          sub_block_size_last <= block_size(block_size'high downto 2) + block_size(1 downto 0) - 3;
        end if;
        sub_block_size_diff <= resize(sub_block_size & "00" - block_size, sub_block_size_diff'length);
      end if;
    end process sub_block_size_proc;
  end generate sub_block_size_gen4;

  sub_block_size_gen8 : if NPROCESSORS_g = 8 generate
    assert (NPROCESSORS_g /= 8) report "Not supported yet!" severity error;
  end generate sub_block_size_gen8;

  is_small_block_proc : process (clk, reset)
  begin  -- process is_small_block_proc
    if reset = '1' then
      is_small_block         <= '0';
      is_small_last_block    <= '0';
      num_of_sld_window      <= 0;
      num_of_sld_window_last <= 0;
      startup_latency        <= (others => '0');
    elsif rising_edge(clk) then
      if sub_block_size <= SLDWIN_SIZE_c then
        is_small_block  <= '1';
        startup_latency <= resize(sub_block_size, startup_latency'length);
      else
        is_small_block  <= '0';
        startup_latency <= to_unsigned(SLDWIN_SIZE_c, startup_latency'length);
      end if;
      if sub_block_size_last <= SLDWIN_SIZE_c then
        is_small_last_block <= '1';
      else
        is_small_last_block <= '0';
      end if;
      if last_sldwin_size_s = SLDWIN_SIZE_c then
        num_of_sld_window <= to_integer(sub_block_size/SLDWIN_SIZE_c);
      else
        num_of_sld_window <= to_integer(sub_block_size/SLDWIN_SIZE_c) + 1;
      end if;
      if last_sldwin_size_last_s = SLDWIN_SIZE_c then
        num_of_sld_window_last <= to_integer(sub_block_size_last/SLDWIN_SIZE_c);
      else
        num_of_sld_window_last <= to_integer(sub_block_size_last/SLDWIN_SIZE_c) + 1;
      end if;
    end if;
  end process is_small_block_proc;

  max_dec_cnt_value_proc : process (clk, reset)
  begin  -- process max_dec_cnt_value_proc
    if reset = '1' then
      max_dec_cnt_value <= 0;
    elsif rising_edge(clk) then
      if tail_bit_cnt = 1 then
        max_dec_cnt_value <= to_integer(sub_block_size) + to_integer(startup_latency) + OUTPUT_LATENCY_c + INPUT_READ_LATENCY_c + 1;
      end if;
    end if;
  end process max_dec_cnt_value_proc;

  is_dec_cnt_lt_sub_block_size_proc : process (clk, reset)
  begin  -- process is_dec_cnt_lt_sub_block_size_proc
    if reset = '1' then
      is_dec_cnt_lt_sub_block_size <= false;
    elsif rising_edge(clk) then
      if decode_start = '1' or dec_cnt = max_dec_cnt_value then
        is_dec_cnt_lt_sub_block_size <= true;
      elsif dec_cnt = sub_block_size-1 then
        is_dec_cnt_lt_sub_block_size <= false;
      end if;
    end if;
  end process is_dec_cnt_lt_sub_block_size_proc;

  -- Registered state process.
  fsm_reg : process (clk, reset)
  begin
    if reset = '1' then
      state <= IDLE;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process fsm_reg;

  input_rd_addr <= resize(rd_addr_cnt_s, ADDRESS_WIDTH_g) when input_rden_s = '1' or input_rden_tail = '1' else (others => '0');

  input_rden <= '1' when input_rden_s = '1' or input_rden_tail = '1' else '0';

  input_rden_tail_gen1 : if NPROCESSORS_g = 1 generate
    input_rden_tail_proc1 : process (clk, reset)
    begin  -- process input_rden_tail_proc1
      if reset = '1' then
        input_rden_tail <= '0';
      elsif rising_edge(clk) then
        if is_in_decode = '1' or tail_bit_cnt <= 3 then
          input_rden_tail <= '1';
        else
          input_rden_tail <= '0';
        end if;
      end if;
    end process input_rden_tail_proc1;
  end generate input_rden_tail_gen1;

  input_rden_tail_gen2 : if NPROCESSORS_g = 2 generate
    input_rden_tail_proc2 : process (clk, reset)
    begin  -- process input_rden_tail_proc2
      if reset = '1' then
        input_rden_tail <= '0';
      elsif rising_edge(clk) then
        if decode_start = '1' or tail_bit_cnt <= 1 then
          input_rden_tail <= '1';
        else
          input_rden_tail <= '0';
        end if;
      end if;
    end process input_rden_tail_proc2;
  end generate input_rden_tail_gen2;

  input_rden_tail_gen4 : if NPROCESSORS_g = 4 generate
    input_rden_tail_proc4 : process (clk, reset)
    begin  -- process input_rden_tail_proc4
      if reset = '1' then
        input_rden_tail <= '0';
      elsif rising_edge(clk) then
        if is_in_decode = '1' and tail_bit_cnt = 0 then
          input_rden_tail <= '1';
        else
          input_rden_tail <= '0';
        end if;
      end if;
    end process input_rden_tail_proc4;
  end generate input_rden_tail_gen4;

  input_rden_proc : process (clk, reset)
  begin  -- process input_rden_proc
    if reset = '1' then
      input_rden_s <= '0';
    elsif rising_edge(clk) then
      if (dec_cnt < sub_block_size-1 or (dec_cnt = max_dec_cnt_value and fifo_flushed = '1')) then
        if is_in_decode = '1' and tail_bit_cnt > MAX_TAIL_BIT_COUNT_c-4 then
          input_rden_s <= '1';
        else
          input_rden_s <= '0';
        end if;
      else
        input_rden_s <= '0';
      end if;
    end if;
  end process input_rden_proc;

  sload_alpha_proc : process (clk, reset)
  begin  -- process sload_alpha_proc
    if reset = '1' then
      sload_alpha <= '0';
    elsif rising_edge(clk) then
      if dec_cnt_delayed = startup_latency then
        sload_alpha <= '1';
      else
        sload_alpha <= '0';
      end if;
    end if;
  end process sload_alpha_proc;

  sload_beta_proc : process (clk, reset)
  begin  -- process sload_beta_proc
    if reset = '1' then
      sload_beta <= '0';
    elsif rising_edge(clk) then
      if tail_bit_cnt = MAX_TAIL_BIT_COUNT_c-8 or dec_cnt = 1 or (beta_cnt = 1 and window_cnt_beta /= num_of_sld_window-1 and is_in_beta_window_range = '1') then
        sload_beta <= '1';
      else
        sload_beta <= '0';
      end if;
    end if;
  end process sload_beta_proc;

  sload_beta_last_proc : process (clk, reset)
  begin  -- process sload_beta_last_proc
    if reset = '1' then
      sload_beta_last <= '0';
    elsif rising_edge(clk) then
      if tail_bit_cnt = MAX_TAIL_BIT_COUNT_c-8 then
        sload_beta_last <= '1';
      elsif (num_of_sld_window = num_of_sld_window_last+1) then
        if (dec_cnt/SLDWIN_SIZE_c < num_of_sld_window_last-1 and dec_cnt mod SLDWIN_SIZE_c = 1) then
          sload_beta_last <= '1';
        elsif (dec_cnt/SLDWIN_SIZE_c = num_of_sld_window_last-1) then
          if last_sldwin_size_last_s = SLDWIN_SIZE_c then
            if dec_cnt mod SLDWIN_SIZE_c = 1 then
              sload_beta_last <= '1';
            else
              sload_beta_last <= '0';
            end if;
          elsif dec_cnt mod SLDWIN_SIZE_c = 1 + SLDWIN_SIZE_c - last_sldwin_size_last_s then
            sload_beta_last <= '1';
          else
            sload_beta_last <= '0';
          end if;
        else
          sload_beta_last <= '0';
        end if;
      else
        if (dec_cnt/SLDWIN_SIZE_c < num_of_sld_window_last-1 and dec_cnt mod SLDWIN_SIZE_c = 1) then -- not the last window
          sload_beta_last <= '1';
        elsif (dec_cnt/SLDWIN_SIZE_c = num_of_sld_window_last-1 and dec_cnt mod SLDWIN_SIZE_c = 1 + sub_block_size_diff) then -- last window
          sload_beta_last <= '1';
        else
          sload_beta_last <= '0';
        end if;
      end if;
    end if;
  end process sload_beta_last_proc;

  beta_ram_wren <= '1' when (dec_cnt > 2 and dec_cnt_delayed < sub_block_size) else '0';
  beta_ram_rden <= '1' when (dec_cnt_delayed >= startup_latency)               else '0';

  address_beta_write <= '0' & beta_cnt  when window_cnt_beta mod 2 = 0  else '1' & beta_cnt;
  address_beta_read  <= '0' & alpha_cnt when window_cnt_alpha mod 2 = 0 else '1' & alpha_cnt;

  address_gamma_write <= '0' & beta_cnt  when window_cnt_beta mod 2 = 0  else '1' & beta_cnt;
  address_gamma_read  <= '0' & alpha_cnt when window_cnt_alpha mod 2 = 0 else '1' & alpha_cnt;

  gamma_ram_wren <= beta_ram_wren;
  gamma_ram_rden <= beta_ram_rden;

  address_read_u <= '0' & resize(rd_addr_cnt_s, address_read_u'length-1) when iter_dec_int_for_input(0) = '1' else
                    '1' & resize(rd_addr_cnt_s, address_read_u'length-1);

  input_u_rden <= '1' when not(is_the_first_iteration) and is_dec_cnt_lt_sub_block_size else '0';

  prev_alpha_ram_wren_proc : process (clk, reset)
  begin  -- process prev_alpha_ram_wren_proc
    if reset = '1' then
      prev_alpha_ram_wren <= '0';
    elsif rising_edge(clk) then
      if dec_cnt_delayed = startup_latency+sub_block_size then
        prev_alpha_ram_wren <= '1';
      else
        prev_alpha_ram_wren <= '0';
      end if;
    end if;
  end process prev_alpha_ram_wren_proc;

  prev_beta_ram_wren_proc : process (clk, reset)
  begin  -- process prev_beta_ram_wren_proc
    if reset = '1' then
      prev_beta_ram_wren <= '0';
    elsif rising_edge(clk) then
      if is_in_beta_window_range = '1' and (dec_cnt mod SLDWIN_SIZE_c = 1 or dec_cnt = sub_block_size+1) then
        prev_beta_ram_wren <= '1';
      else
        prev_beta_ram_wren <= '0';
      end if;
    end if;
  end process prev_beta_ram_wren_proc;

  prev_alpha_ram_rden_proc : process (clk, reset)
  begin  -- process prev_alpha_ram_rden_proc
    if reset = '1' then
      prev_alpha_ram_rden <= '0';
    elsif rising_edge(clk) then
      if not(is_the_first_iteration or is_the_second_iteration) then
        if is_small_block = '0'then
          if dec_cnt_delayed = SLDWIN_SIZE_c-2 then
            prev_alpha_ram_rden <= '1';
          else
            prev_alpha_ram_rden <= '0';
          end if;
        else                            -- is_small_block = '1'
          if dec_cnt = sub_block_size then
            prev_alpha_ram_rden <= '1';
          else
            prev_alpha_ram_rden <= '0';
          end if;
        end if;
      else
        prev_alpha_ram_rden <= '0';
      end if;
    end if;
  end process prev_alpha_ram_rden_proc;

  prev_alphabeta_ram_wren <= prev_alpha_ram_wren or prev_beta_ram_wren;
  prev_alphabeta_ram_rden <= prev_alpha_ram_rden or prev_beta_ram_rden;

  prev_alphabeta_ram_wren_reg_proc : process (clk, reset)
  begin  -- process prev_alphabeta_ram_wren_reg_proc
    if reset = '1' then
      prev_alphabeta_ram_wren_reg <= '0';
    elsif rising_edge(clk) then
      prev_alphabeta_ram_wren_reg <= prev_alphabeta_ram_wren;
    end if;
  end process prev_alphabeta_ram_wren_reg_proc;

  prev_beta_ram_rden_proc : process (beta_cnt, dec_cnt,
                                     is_dec_cnt_lt_sub_block_size,
                                     is_small_block, is_the_first_iteration,
                                     is_the_second_iteration,
                                     num_of_sld_window, window_cnt_beta)
  begin  -- process prev_beta_ram_rden_proc
    if (is_the_first_iteration or is_the_second_iteration) then
      if is_small_block = '0' and beta_cnt = 2 and window_cnt_beta = num_of_sld_window-2 then
        prev_beta_ram_rden <= '1';
      else
        prev_beta_ram_rden <= '0';
      end if;
    elsif (dec_cnt = 0 or (beta_cnt = 2 and dec_cnt > 2 and is_dec_cnt_lt_sub_block_size)) then
      prev_beta_ram_rden <= '1';
    else
      prev_beta_ram_rden <= '0';
    end if;
  end process prev_beta_ram_rden_proc;

  address_prev_beta_write_proc : process (clk, reset)
  begin  -- process address_prev_beta_write_proc
    if reset = '1' then
      address_prev_beta_write <= (others => '0');
    elsif rising_edge(clk) then
      if prev_alpha_ram_wren = '1' then
        if iter_dec_int_for_input(0) = '0' then
          address_prev_beta_write <= to_unsigned(0, address_prev_beta_write'length);
        else
          address_prev_beta_write <= to_unsigned(PREVS_ALPHABETA_DEPTH_c, address_prev_beta_write'length);
        end if;
      else
        -- for beta write
        if iter_dec_int_for_input(0) = '0' then
          address_prev_beta_write <= to_unsigned(window_cnt_beta+1, address_prev_beta_write'length);
        else
          address_prev_beta_write <= to_unsigned(window_cnt_beta+1+PREVS_ALPHABETA_DEPTH_c, address_prev_beta_write'length);
        end if;
      end if;
    end if;
  end process address_prev_beta_write_proc;

  address_prev_beta_read_proc : process (dec_cnt, is_small_block,
                                         iter_dec_int_for_input,
                                         num_of_sld_window,
                                         prev_alpha_ram_rden,
                                         prev_beta_ram_rden, window_cnt_beta)
  begin  -- process address_prev_beta_read_proc
    if prev_alpha_ram_rden = '1' then
      if iter_dec_int_for_input(0) = '0' then
        address_prev_beta_read <= to_unsigned(0, address_prev_beta_read'length);
      else
        address_prev_beta_read <= to_unsigned(PREVS_ALPHABETA_DEPTH_c, address_prev_beta_read'length);
      end if;
    elsif prev_beta_ram_rden = '1' then  -- for beta read
      if is_small_block = '1' then
        if iter_dec_int_for_input(0) = '0' then
          address_prev_beta_read <= to_unsigned(window_cnt_beta+1, address_prev_beta_read'length);
        else
          address_prev_beta_read <= to_unsigned(window_cnt_beta+1+PREVS_ALPHABETA_DEPTH_c, address_prev_beta_read'length);
        end if;
      else
        if iter_dec_int_for_input(0) = '0' then
          if dec_cnt = 0 then
            address_prev_beta_read <= to_unsigned(window_cnt_beta+2, address_prev_beta_read'length);
          elsif window_cnt_beta = num_of_sld_window-2 then
            -- pass the first window beta for the last window
            address_prev_beta_read <= to_unsigned(1, address_prev_beta_read'length);
          else
            address_prev_beta_read <= to_unsigned(window_cnt_beta+3, address_prev_beta_read'length);
          end if;
        else
          if dec_cnt = 0 then
            address_prev_beta_read <= to_unsigned(window_cnt_beta+2+PREVS_ALPHABETA_DEPTH_c, address_prev_beta_read'length);
          elsif window_cnt_beta = num_of_sld_window-2 then
            -- pass the first window beta for the last window
            address_prev_beta_read <= to_unsigned(1+PREVS_ALPHABETA_DEPTH_c, address_prev_beta_read'length);
          else
            address_prev_beta_read <= to_unsigned(window_cnt_beta+3+PREVS_ALPHABETA_DEPTH_c, address_prev_beta_read'length);
          end if;
        end if;
      end if;
    else
      address_prev_beta_read <= to_unsigned(0, address_prev_beta_read'length);
    end if;
  end process address_prev_beta_read_proc;

  max_beta_window_range_proc : process (clk, reset)
  begin  -- process max_beta_window_range_proc
    if reset = '1' then
      -- max_beta_window_range <= 0;
      is_in_beta_window_range <= '0';
    elsif rising_edge(clk) then
      if dec_cnt = 2 then
        is_in_beta_window_range <= '1';
      elsif decode_start = '1' or dec_cnt > sub_block_size + 1 then
        is_in_beta_window_range <= '0';
      end if;  --max_beta_window_range <= to_integer(sub_block_size + to_unsigned(last_sldwin_size_s, FRAME_SIZE_WIDTH_c));
    end if;
  end process max_beta_window_range_proc;

  window_cnt_beta_proc : process (clk, reset)
  begin  -- process window_cnt_proc
    if reset = '1' then
      window_cnt_beta <= 0;
    elsif rising_edge(clk) then
      if decode_start = '1' or dec_cnt = max_dec_cnt_value then
        window_cnt_beta <= 0;
      elsif is_in_beta_window_range = '1' then
--          if beta_cnt = 0 and dec_cnt_delayed < max_beta_window_range then
        if beta_cnt = 0 then
          if window_cnt_beta = MAX_WINDOW_CNT_c-1 then
            window_cnt_beta <= 0;
          else
            window_cnt_beta <= window_cnt_beta + 1;
          end if;
        end if;
      end if;
    end if;
  end process window_cnt_beta_proc;

  -- start of the trellis
  alpha_prime_in_0 : for i in 1 to MAX_STATES_c-1 generate
    alpha_prime_in(0)(i*SOFT_WIDTH_g-1 downto (i-1)*SOFT_WIDTH_g+IN_WIDTH_g-1)   <= (others => '1');
    alpha_prime_in(0)((i-1)*SOFT_WIDTH_g+IN_WIDTH_g-2 downto (i-1)*SOFT_WIDTH_g) <= (others => '0');
  end generate alpha_prime_in_0;

  -- in the middle of the trellis
  init_alpha_prime_gen : for i in 1 to NPROCESSORS_g-1 generate
    load_alpha_proc : process (is_the_first_iteration, is_the_second_iteration,
                               prev_beta_from_mem)
    begin  -- process load_alpha_proc
      if (is_the_first_iteration or is_the_second_iteration) then  -- 1st & 2nd iteration
        alpha_prime_in(i) <= (others => '0');
      else
        alpha_prime_in(i) <= prev_beta_from_mem(i-1);
      end if;
    end process load_alpha_proc;
  end generate init_alpha_prime_gen;

  init_beta_prime_in_gen : for i in 0 to NPROCESSORS_g-2 generate
  begin
    load_beta_proc : process (beta, dec_cnt, dec_cnt_delayed, is_small_block,
                              is_the_first_iteration, is_the_second_iteration,
                              num_of_sld_window, prev_beta_from_mem,
                              tail_bit_cnt, window_cnt_beta)
    begin  -- process load_beta_proc
      if is_the_first_iteration then
        if tail_bit_cnt = MAX_TAIL_BIT_COUNT_c-7 then
          for j in 1 to MAX_STATES_c-1 loop
            beta_prime_in(i)(j*SOFT_WIDTH_g-1 downto (j-1)*SOFT_WIDTH_g+IN_WIDTH_g-1)   <= (others => '1');
            beta_prime_in(i)((j-1)*SOFT_WIDTH_g+IN_WIDTH_g-2 downto (j-1)*SOFT_WIDTH_g) <= (others => '0');
          end loop;  -- beta_prime_in_loop
        elsif is_small_block = '1' then
          beta_prime_in(i) <= (others => '0');
        elsif num_of_sld_window = 2 then
          if dec_cnt_delayed = SLDWIN_SIZE_c-1 then      -- for last window
            beta_prime_in(i) <= beta(i+1);
          else
            beta_prime_in(i) <= (others => '0');
          end if;
        else                                             -- not small block
          if window_cnt_beta = num_of_sld_window-2 then  -- last window
            beta_prime_in(i) <= prev_beta_from_mem(i+1);
          else
            beta_prime_in(i) <= (others => '0');
          end if;
        end if;
      elsif is_the_second_iteration then
        if is_small_block = '1' then
          beta_prime_in(i) <= (others => '0');
        elsif num_of_sld_window = 2 then
          if dec_cnt_delayed = SLDWIN_SIZE_c-1 then      -- for last window
            beta_prime_in(i) <= beta(i+1);
          else
            beta_prime_in(i) <= (others => '0');
          end if;
        else                                             -- not small block
          if window_cnt_beta = num_of_sld_window-2 then  -- last window
            beta_prime_in(i) <= prev_beta_from_mem(i+1);
          else
            beta_prime_in(i) <= (others => '0');
          end if;
        end if;
      else                                               -- iter_dec > 0
        if num_of_sld_window = 2 then
          if dec_cnt_delayed = SLDWIN_SIZE_c-1 then      -- for last window
            beta_prime_in(i) <= beta(i+1);
          else
            beta_prime_in(i) <= prev_beta_from_mem(i);
          end if;
        elsif (is_small_block = '1' and dec_cnt = 2) or (is_small_block = '0' and window_cnt_beta >= num_of_sld_window-2) then
          beta_prime_in(i) <= prev_beta_from_mem(i+1);
        else
          beta_prime_in(i) <= prev_beta_from_mem(i);
        end if;
      end if;
    end process load_beta_proc;
  end generate init_beta_prime_in_gen;

  init_beta_prime_in_gen_last : for i in NPROCESSORS_g-1 to NPROCESSORS_g-1 generate
  begin
    load_beta_proc : process (block_end_beta, dec_cnt, is_the_first_iteration,
                              is_the_second_iteration, iter_dec_int_for_input,
                              last_sldwin_size_last_s, num_of_sld_window,
                              num_of_sld_window_last, prev_beta_from_mem,
                              sub_block_size_diff, tail_bit_cnt)
    begin  -- process load_beta_proc
      if tail_bit_cnt = MAX_TAIL_BIT_COUNT_c-7 then
        for j in 1 to MAX_STATES_c-1 loop
          beta_prime_in(i)(j*SOFT_WIDTH_g-1 downto (j-1)*SOFT_WIDTH_g+IN_WIDTH_g-1)   <= (others => '1');
          beta_prime_in(i)((j-1)*SOFT_WIDTH_g+IN_WIDTH_g-2 downto (j-1)*SOFT_WIDTH_g) <= (others => '0');
        end loop;  -- beta_prime_in_loop
      elsif (num_of_sld_window = num_of_sld_window_last+1 and dec_cnt/SLDWIN_SIZE_c = num_of_sld_window_last-1) then
        if last_sldwin_size_last_s = SLDWIN_SIZE_c and dec_cnt mod SLDWIN_SIZE_c = 2 then
          if iter_dec_int_for_input(0) = '0' then
            beta_prime_in(i) <= block_end_beta(0);
          else
            beta_prime_in(i) <= block_end_beta(1);
          end if;
        elsif last_sldwin_size_last_s /= SLDWIN_SIZE_c and dec_cnt mod SLDWIN_SIZE_c = 2 + SLDWIN_SIZE_c - last_sldwin_size_last_s then
          if iter_dec_int_for_input(0) = '0' then
            beta_prime_in(i) <= block_end_beta(0);
          else
            beta_prime_in(i) <= block_end_beta(1);
          end if;
        elsif is_the_first_iteration or is_the_second_iteration then
          beta_prime_in(i) <= (others => '0');
        else
          beta_prime_in(i) <= prev_beta_from_mem(i);
        end if;
      elsif (dec_cnt/SLDWIN_SIZE_c = num_of_sld_window_last-1 and dec_cnt mod SLDWIN_SIZE_c = 2 + sub_block_size_diff) then
        if iter_dec_int_for_input(0) = '0' then
          beta_prime_in(i) <= block_end_beta(0);
        else
          beta_prime_in(i) <= block_end_beta(1);
        end if;
      elsif is_the_first_iteration or is_the_second_iteration then
        beta_prime_in(i) <= (others => '0');
      else
        beta_prime_in(i) <= prev_beta_from_mem(i);
      end if;
    end process load_beta_proc;
  end generate init_beta_prime_in_gen_last;

  block_end_beta_proc : process (clk, reset)
  begin  -- process block_end_beta_proc
    if reset = '1' then
      block_end_beta <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if tail_bit_cnt = MAX_TAIL_BIT_COUNT_c-3 then
        block_end_beta(1) <= beta_to_mem(0);  -- interleavered tail bits
        block_end_beta(0) <= beta_to_mem(NPROCESSORS_g-1);  -- first 6 tail bits
      end if;
    end if;
  end process block_end_beta_proc;

  tail_bit_cnt_proc : process (clk, reset)
  begin  -- process tail_bit_cnt_proc
    if reset = '1' then
      tail_bit_cnt <= 0;
    elsif rising_edge(clk) then
      if ena = '1' then
        if decode_start = '1' then
          tail_bit_cnt <= 0;
        elsif tail_bit_cnt < MAX_TAIL_BIT_COUNT_c then
          tail_bit_cnt <= tail_bit_cnt +1;
        end if;
      end if;
    end if;
  end process tail_bit_cnt_proc;

  dec_cnt_proc : process (clk, reset)
  begin  -- process dec_cnt_proc
    if reset = '1' then
      dec_cnt <= 0;
    elsif rising_edge(clk) then
      if ena = '1' then
        if decode_start = '1' then
          dec_cnt <= 0;
        elsif dec_cnt = max_dec_cnt_value then
          if fifo_flushed = '1' and iter_dec < max_iter_dec-1 then
            dec_cnt <= 0;
          end if;
        elsif tail_bit_cnt > MAX_TAIL_BIT_COUNT_c-3 and is_in_decode = '1' then
          dec_cnt <= dec_cnt +1;
        end if;
      end if;
    end if;
  end process dec_cnt_proc;

  beta_cnt_proc : process (clk, reset)
  begin  -- process beta_cnt_proc
    if reset = '1' then
      beta_cnt <= to_unsigned(0, beta_cnt'length);
    elsif rising_edge(clk) then
      if ena = '1' then
        if dec_cnt = 2 then
          if is_small_block = '1' then
            beta_cnt <= resize((sub_block_size-1) mod SLDWIN_SIZE_c, beta_cnt'length);
          else
            beta_cnt <= (others => '1');  --SLDWIN_SIZE_c-1
          end if;
        elsif beta_cnt = 0 then
          if window_cnt_beta = sub_block_size(sub_block_size'high downto SLDWIN_SIZE_WIDTH_c)-1 then
            beta_cnt <= resize((sub_block_size-1) mod SLDWIN_SIZE_c, beta_cnt'length);
          else
            beta_cnt <= (others => '1');  -- SLDWIN_SIZE_c-1;
          end if;
        else
          beta_cnt <= beta_cnt - 1;
        end if;
      end if;
    end if;
  end process beta_cnt_proc;

  rd_addr_cnt_s <= rd_addr_cnt when is_in_decode = '1' else to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);

  rd_addr_cnt_proc : process (clk, reset)
  begin  -- process rd_addr_cnt_proc
    if reset = '1' then
      rd_addr_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
    elsif rising_edge(clk) then
      if tail_bit_cnt = 0 then
        rd_addr_cnt <= sub_block_size;
      elsif tail_bit_cnt <= 4 then
        rd_addr_cnt <= rd_addr_cnt + 1;
      elsif is_in_decode = '1' then
        if tail_bit_cnt = MAX_TAIL_BIT_COUNT_c-3 or (dec_cnt = max_dec_cnt_value and fifo_flushed = '1') then
          if is_small_block = '1' then
            rd_addr_cnt <= sub_block_size-1;
          else
            rd_addr_cnt <= to_unsigned(SLDWIN_SIZE_c-1, MAX_SUB_FRAME_WIDTH_c);
          end if;
        elsif dec_cnt < sub_block_size+SLDWIN_SIZE_c-1 then
          if rd_addr_cnt mod SLDWIN_SIZE_c = 0 then
            if window_cnt_beta = sub_block_size/SLDWIN_SIZE_c-1 then
              rd_addr_cnt <= sub_block_size-1;
            elsif rd_addr_cnt < sub_block_size-2*SLDWIN_SIZE_c+1 then
              rd_addr_cnt <= rd_addr_cnt+2*SLDWIN_SIZE_c-1;
            end if;
          else
            rd_addr_cnt <= rd_addr_cnt-1;
          end if;
        end if;
      end if;
    end if;
  end process rd_addr_cnt_proc;

  alpha_cnt_proc : process (clk, reset)
  begin  -- process alpha_cnt_proc
    if reset = '1' then
      alpha_cnt <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        if is_small_block = '1' then
          if dec_cnt_delayed = sub_block_size-1 then
            alpha_cnt <= (others => '0');
          else
            alpha_cnt <= alpha_cnt + 1;
          end if;
        else
          if dec_cnt_delayed = SLDWIN_SIZE_c-1 then
            alpha_cnt <= (others => '0');
          else
            alpha_cnt <= alpha_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process alpha_cnt_proc;

  window_cnt_alpha_proc : process (clk, reset)
  begin  -- process window_cnt_alpha_proc
    if reset = '1' then
      window_cnt_alpha <= 0;
    elsif rising_edge(clk) then
      if ena = '1' then
        if is_small_block = '1' then
          if dec_cnt_delayed = sub_block_size-1 then
            window_cnt_alpha <= 0;
          elsif and_reduce(alpha_cnt) = '1' then  -- alpha_cnt = SLDWIN_SIZE_c-1
            if window_cnt_alpha = MAX_WINDOW_CNT_c-1 then
              window_cnt_alpha <= 0;
            else
              window_cnt_alpha <= window_cnt_alpha + 1;
            end if;
          end if;
        else
          if dec_cnt_delayed = SLDWIN_SIZE_c-1 then
            window_cnt_alpha <= 0;
          elsif and_reduce(alpha_cnt) = '1' then  -- alpha_cnt = SLDWIN_SIZE_c-1
            if window_cnt_alpha = MAX_WINDOW_CNT_c-1 then
              window_cnt_alpha <= 0;
            else
              window_cnt_alpha <= window_cnt_alpha + 1;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process window_cnt_alpha_proc;

  fifo_flushed_reg_proc : process (clk, reset)
  begin  -- process fifo_flushed_reg_proc
    if reset = '1' then
      fifo_flushed_reg <= '0';
    elsif rising_edge(clk) then
      fifo_flushed_reg <= fifo_flushed;
    end if;
  end process fifo_flushed_reg_proc;

  half_decode_done_proc : process (clk, reset)
  begin  -- process half_decode_done_proc
    if reset = '1' then
      half_decode_done_s <= '0';
    elsif rising_edge(clk) then
      if fifo_flushed = '1' and fifo_flushed_reg = '0' and dec_cnt = max_dec_cnt_value then
        half_decode_done_s <= '1';
      else
        half_decode_done_s <= '0';
      end if;
    end if;
  end process half_decode_done_proc;

  half_decode_done <= half_decode_done_s;

  dec_cnt_slv     <= std_logic_vector(to_unsigned(dec_cnt, FRAME_SIZE_WIDTH_c));
  dec_cnt_delayed <= to_integer(unsigned(dec_cnt_delayed_slv));

  dec_cnt_delay_inst : auk_dspip_delay
    generic map (
      WIDTH_g          => FRAME_SIZE_WIDTH_c,
      DELAY_g          => INPUT_READ_LATENCY_c,
      MEMORY_TYPE_g    => "register",
      REGISTER_FIRST_g => 0,
      REGISTER_LAST_g  => 0)
    port map (
      clk     => clk,
      reset   => reset,
      enable  => ena,
      datain  => dec_cnt_slv,
      dataout => dec_cnt_delayed_slv
      );

  -- read the tail bits from registers in input buffer

  read_tail_gen1 : if NPROCESSORS_g = 1 generate
--    assert NPROCESSORS_g /= 1 report "Currently this isn't supported yet." severity error;
    read_tal_bits_proc1 : process (clk, reset)
    begin  -- process read_tal_bits_proc1
      if reset = '1' then
        input_tail_bits <= (others => (others => '0'));
      elsif rising_edge(clk) then
        -- NB: read address from right to left
        if tail_bit_cnt = 3 then
          for i in 0 to 2 loop
            input_tail_bits(i) <= data_in((i+1)*IN_WIDTH_g-1 downto i*IN_WIDTH_g);
          end loop;  -- i
        elsif tail_bit_cnt = 4 then
          for i in 3 to 5 loop
            input_tail_bits(i) <= data_in((i+1-3)*IN_WIDTH_g-1 downto (i-3)*IN_WIDTH_g);
          end loop;  -- i
        elsif tail_bit_cnt = 5 then
          for i in 6 to 8 loop
            input_tail_bits(i) <= data_in((i+1-6)*IN_WIDTH_g-1 downto (i-6)*IN_WIDTH_g);
          end loop;  -- i
        elsif tail_bit_cnt = 6 then
          for i in 9 to 11 loop
            input_tail_bits(i) <= data_in((i+1-9)*IN_WIDTH_g-1 downto (i-9)*IN_WIDTH_g);
          end loop;  -- i
        end if;
      end if;
    end process read_tal_bits_proc1;
  end generate read_tail_gen1;

  read_tail_gen2 : if NPROCESSORS_g = 2 generate
    read_tal_bits_proc2 : process (clk, reset)
    begin  -- process read_tal_bits_proc2
      if reset = '1' then
        input_tail_bits <= (others => (others => '0'));
      elsif rising_edge(clk) then
        -- NB: read address from right to left
        if tail_bit_cnt = 3 then
          for i in 0 to 5 loop
            input_tail_bits(i) <= data_in((i+1)*IN_WIDTH_g-1 downto i*IN_WIDTH_g);
          end loop;  -- i
        elsif tail_bit_cnt = 4 then
          for i in 6 to 11 loop
            input_tail_bits(i) <= data_in((i+1-6)*IN_WIDTH_g-1 downto (i-6)*IN_WIDTH_g);
          end loop;  -- i
        end if;
      end if;
    end process read_tal_bits_proc2;
  end generate read_tail_gen2;

  read_tail_gen4 : if NPROCESSORS_g = 4 generate
    read_tal_bits_proc4 : process (clk, reset)
    begin  -- process read_tal_bits_proc4
      if reset = '1' then
        input_tail_bits <= (others => (others => '0'));
      elsif rising_edge(clk) then
        if tail_bit_cnt = 3 then
          for i in 0 to 11 loop
            input_tail_bits(i) <= data_in((i+1)*IN_WIDTH_g-1 downto i*IN_WIDTH_g);
          end loop;  -- i
        end if;
      end if;
    end process read_tal_bits_proc4;
  end generate read_tail_gen4;

  input_gen : for i in 0 to NPROCESSORS_g-1 generate
  begin
    gen_input_sys_par : process (data_in, input_tail_bits,
                                 iter_dec_int_for_input, tail_bit_cnt)

    begin  -- process gen_input_sys_par
      if tail_bit_cnt >= MAX_TAIL_BIT_COUNT_c-7 and tail_bit_cnt < MAX_TAIL_BIT_COUNT_c-4 then
        if i = NPROCESSORS_g-1 then     -- first 6 tail bits
          input_c_sys(i) <= input_tail_bits(4 - 2*(tail_bit_cnt - (MAX_TAIL_BIT_COUNT_c - 7)));
          input_c_par(i) <= input_tail_bits(5 - 2*(tail_bit_cnt - (MAX_TAIL_BIT_COUNT_c - 7)));
        elsif i = 0 then                -- interleavered tail bits
          input_c_sys(i) <= input_tail_bits(10 - 2*(tail_bit_cnt - (MAX_TAIL_BIT_COUNT_c - 7)));
          input_c_par(i) <= input_tail_bits(11 - 2*(tail_bit_cnt - (MAX_TAIL_BIT_COUNT_c - 7)));
        else
          input_c_sys(i) <= (others => '0');
          input_c_par(i) <= (others => '0');
        end if;
      elsif tail_bit_cnt = MAX_TAIL_BIT_COUNT_c then
        if iter_dec_int_for_input(0) = '0' then
          input_c_sys(i) <= data_in((3*i+1)*IN_WIDTH_g-1 downto 3*i*IN_WIDTH_g);
          input_c_par(i) <= data_in((3*i+2)*IN_WIDTH_g-1 downto (3*i+1)*IN_WIDTH_g);
        else
          input_c_sys(i) <= (others => '0');
          input_c_par(i) <= data_in((3*i+3)*IN_WIDTH_g-1 downto (3*i+2)*IN_WIDTH_g);
        end if;
      else
        input_c_sys(i) <= (others => '0');
        input_c_par(i) <= (others => '0');
      end if;
    end process gen_input_sys_par;
  end generate input_gen;

  iter_dec_int_for_input_proc : process (clk, reset)
  begin  -- process iter_dec_int_for_input_proc
    if reset = '1' then
      iter_dec_int_for_input  <= to_unsigned(0, IT_WIDTH_c);
      is_the_first_iteration  <= false;
      is_the_second_iteration <= false;
    elsif rising_edge(clk) then
      if ena = '1' then
        if decode_start = '1' then
          iter_dec_int_for_input <= to_unsigned(0, IT_WIDTH_c);
          is_the_first_iteration <= true;
        elsif dec_cnt = max_dec_cnt_value and fifo_flushed = '1' then
          if is_in_decode = '1' then
            iter_dec_int_for_input <= iter_dec_int_for_input + 1;
          end if;
          if is_the_first_iteration then
            is_the_first_iteration  <= false;
            is_the_second_iteration <= true;
          else
            is_the_second_iteration <= false;
          end if;
        end if;
      end if;
    end if;
  end process iter_dec_int_for_input_proc;

  input_u_gen : for i in 0 to NPROCESSORS_g-1 generate
  begin
    input_u_proc : process (input_u_ram_arr, is_the_first_iteration)
    begin  -- process input_u_proc
      if is_the_first_iteration then
        input_u(i) <= (others => '0');
      else
        input_u(i) <= input_u_ram_arr(i);
      end if;
    end process input_u_proc;
  end generate input_u_gen;

  output_u_ram_gen : for i in 0 to NPROCESSORS_g-1 generate
    output_u_ram((i+1)*IN_WIDTH_g-1 downto i*IN_WIDTH_g) <= output_u(i);
  end generate output_u_ram_gen;

  fifo_flushed <= not(or_reduce(fifo_wren_slv));

  auk_dspip_ctc_umts_fifo_inst : auk_dspip_ctc_umts_fifo
    generic map (
      IN_WIDTH_g          => IN_WIDTH_g,
      NPROCESSORS_g       => NPROCESSORS_g,
      RAM_TYPE_g          => RAM_TYPE_g,
      NUM_ENGINES_WIDTH_g => NUM_ENGINES_WIDTH_g,
      ADDRESS_WIDTH_g     => ADDRESS_WIDTH_g,
      DATA_IN_WIDTH_g     => FIFO_IN_WIDTH_c,
      DATA_OUT_WIDTH_g    => FIFO_OUT_WIDTH_c)
    port map (
      clk   => clk,
      ena   => ena,
      reset => reset,
      wrreq => fifo_wrreq_slv,
      data  => fifo_in,
      wren  => fifo_wren_slv,
      q     => fifo_out);


  parallel_window_gen : for i in 0 to NPROCESSORS_g-1 generate

    fifo_wrreq_slv(i)                                         <= out_valid_last_s when i = NPROCESSORS_g-1 else out_valid_s;
    fifo_in((i+1)*FIFO_IN_WIDTH_c-1 downto i*FIFO_IN_WIDTH_c) <= std_logic_vector(output_u(i)) &
                                                                 detected_data(i) &
                                                                 std_logic_vector(intlvr_location_arr(i)) &
                                                                 std_logic_vector(intlvr_sub_locs(i)) when iter_dec(0) = '1' else
                                                                 std_logic_vector(output_u(i)) &
                                                                 detected_data(i) &
                                                                 std_logic_vector(deintlvr_location_arr(i)) &
                                                                 std_logic_vector(deintlvr_sub_locs(i));

    dout(i)             <= fifo_out((i+1)*FIFO_OUT_WIDTH_c-IN_WIDTH_g-1);
    dout_address_arr(i) <= fifo_out(i*FIFO_OUT_WIDTH_c+ADDRESS_WIDTH_g-1 downto i*FIFO_OUT_WIDTH_c);
    out_valid(i)        <= fifo_wren_slv(i);

    dout_address((i+1)*ADDRESS_WIDTH_g-1 downto i*ADDRESS_WIDTH_g) <= unsigned(dout_address_arr(i));

    address_write_u_proc : process (clk, reset)
    begin  -- process address_write_u_proc
      if reset = '1' then
        address_write_u_arr(i) <= (others => '0');
        output_u_ram_arr(i)    <= (others => '0');
        input_u_wren_arr(i)    <= '0';
      elsif rising_edge(clk) then
        output_u_ram_arr(i) <= signed(fifo_out((i+1)*FIFO_OUT_WIDTH_c-1 downto (i+1)*FIFO_OUT_WIDTH_c-IN_WIDTH_g));
        input_u_wren_arr(i) <= fifo_wren_slv(i);

        if iter_dec(0) = '0' then
          address_write_u_arr(i) <= '0' & unsigned(fifo_out(i*FIFO_OUT_WIDTH_c+ADDRESS_WIDTH_g-1 downto i*FIFO_OUT_WIDTH_c));
        else
          address_write_u_arr(i) <= '1' & unsigned(fifo_out(i*FIFO_OUT_WIDTH_c+ADDRESS_WIDTH_g-1 downto i*FIFO_OUT_WIDTH_c));
        end if;
      end if;
    end process address_write_u_proc;

    input_u_inst : auk_dspip_ctc_umts_ram  -- extrinsic info
      generic map (
        DATA_WIDTH_g    => IN_WIDTH_g,
        DATA_DEPTH_g    => MEMORY_DEPTH_c,
        MAXIMUM_DEPTH_g => 1024,
        ADDRESS_WIDTH_g => MEM_ADDRESS_WIDTH_c
        )
      port map (
        clk           => clk,
        reset         => reset,
        ena           => ena,
        read_address  => address_read_u,
        write_address => address_write_u_arr(i),
        din           => output_u_ram_arr(i),
        wren          => input_u_wren_arr(i),
        rden          => input_u_rden,
        dout          => input_u_ram_arr(i)
        );

    -- Gamma Calculation units
    gamma_cu : auk_dspip_ctc_umts_map_gamma
      generic map(
        INPUT_WIDTH_g => IN_WIDTH_g,
        WIDTH_g       => SOFT_WIDTH_g
        )
      port map(
        clk          => clk,
        ena          => ena,
        reset        => reset,
        input_c_0    => input_c_sys(i),
        input_c_1    => input_c_par(i),
        app_in       => input_u(i),
        gamma_to_mem => gamma_to_mem(i),
        gamma_1      => metric_c_data(i)(0),
        gamma_2      => metric_c_data(i)(1),
        gamma_3      => metric_c_data(i)(2)
        );


    -- Alpha calculation units
    alpha_cu : auk_dspip_ctc_umts_map_alpha
      generic map (
        WIDTH_g             => SOFT_WIDTH_g,
        DECODER_TYPE_g      => DECODER_TYPE_g
        )
      port map (
        clk            => clk,
        ena            => ena,
        reset          => reset,
        metric_c_1     => metric_input(i)(0),
        metric_c_2     => metric_input(i)(1),
        metric_c_3     => metric_input(i)(2),
        sload          => sload_alpha,
        alpha_prime_in => alpha_prime_in(i),
        alpha_prime    => alpha_prime(i),
        alpha_out      => alpha(i)
        );

    sload_beta_bcu(i) <= sload_beta_last when i = NPROCESSORS_g-1 else sload_beta;

    -- Beta calculation units
    beta_cu : auk_dspip_ctc_umts_map_beta
      generic map (
        WIDTH_g             => SOFT_WIDTH_g,
        DECODER_TYPE_g      => DECODER_TYPE_g
        )
      port map (
        clk           => clk,
        ena           => ena,
        reset         => reset,
        metric_c_1    => metric_c_data(i)(0),
        metric_c_2    => metric_c_data(i)(1),
        metric_c_3    => metric_c_data(i)(2),
        sload         => sload_beta_bcu(i),
        beta_prime_in => beta_prime_in(i),
        beta_prime    => beta_to_mem(i),
        beta_out      => beta(i)
        );


    --synthesis translate_off
    gen_debug_gamma : if DEBUG_BETA_c = 1 generate
      signal reset_n       : std_logic;
      signal output_concat : std_logic_vector(10*SOFT_WIDTH_g -1 downto 0);
      signal beta_valid    : std_logic;
      component auk_dspip_avalon_streaming_monitor is
        generic (
          FILENAME_g         : string;
          COMPARE_g          : boolean;
          COMPARE_TO_FILE_g  : string;
          IGNORE_PREFIX_g    : character;
          SYMBOLS_PER_BEAT_g : natural;
          SYMBOL_DELIMETER_g : string;
          PRINT_CLK_REPORT_g : boolean;
          SYMBOL_DATAWIDTH_g : natural);
        port (
          clk       : in std_logic;
          reset_n   : in std_logic;
          -- enables the model
          enable    : in std_logic;
          -- atlantic signals
          avs_valid : in std_logic;
          avs_ready : in std_logic;
          avs_sop   : in std_logic;
          avs_eop   : in std_logic;
          -- data contains real and imaginary data, imaginary in LSW, real in MSW
          avs_data  : in std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0));
      end component auk_dspip_avalon_streaming_monitor;
      signal monitor_valid   : std_logic;
      signal decoder_started : std_logic;
    begin
      reset_n <= not reset;
      decoder_started_p : process (clk, reset)
      begin  -- process decoder_started_p
        if reset = '1' then
          decoder_started <= '0';
        elsif rising_edge(clk) then
          if decode_start = '1' then
            decoder_started <= '1';
          end if;
        end if;
      end process decoder_started_p;

      beta_valid <= '1' when is_in_decode = '1' and decoder_started = '1' and beta_ram_wren = '1' else
                    '0';
      concat_gamma_output : for k in 8 to 10 generate
        output_concat(k*SOFT_WIDTH_g - 1 downto (k-1)*SOFT_WIDTH_g) <= std_logic_vector(metric_c_data(i)(10-k));
      end generate concat_gamma_output;

      output_concat(7*SOFT_WIDTH_g - 1 downto (0)*SOFT_WIDTH_g) <= std_logic_vector(beta_to_mem(i));

      monitor : auk_dspip_avalon_streaming_monitor
        generic map (
          FILENAME_g         => "beta" & integer'image(i) & ".txt",
          COMPARE_g          => false,
          COMPARE_TO_FILE_g  => "",
          IGNORE_PREFIX_g    => '#',
          SYMBOLS_PER_BEAT_g => 3+7,
          SYMBOL_DELIMETER_g => " ",
          PRINT_CLK_REPORT_g => false,
          SYMBOL_DATAWIDTH_g => SOFT_WIDTH_g)
        port map (
          clk       => clk,
          reset_n   => reset_n,
          -- enables the model
          enable    => ena,
          -- atlantic signals
          avs_valid => beta_valid,
          avs_ready => '1',
          avs_sop   => '1',
          avs_eop   => '1',
          -- data contains real and imaginary data, imaginary in LSW, real in MSW
          avs_data  => output_concat);

    end generate gen_debug_gamma;
    --synthesis translate_on


--    gamma_to_mem(i) <= metric_c_data(i)(3) & metric_c_data(i)(2) & metric_c_data(i)(1) & resize(input_u(i), SOFT_WIDTH_g);

    metric_input_gen : for j in 0 to 2 generate
      metric_input(i)(j) <= gamma_from_mem(i)((j+1)*SOFT_WIDTH_g-1 downto j*SOFT_WIDTH_g);
    end generate metric_input_gen;

    input_u_for_llr(i) <= gamma_from_mem(i)(3*SOFT_WIDTH_g+IN_WIDTH_g-1 downto 3*SOFT_WIDTH_g);

    -- RAMs for calculated gamma and input_u to avoid reading confliction
    gamma_ram : auk_dspip_ctc_umts_ram
      generic map (
        DATA_WIDTH_g    => 3*SOFT_WIDTH_g+IN_WIDTH_g,
        DATA_DEPTH_g    => 2*(SLDWIN_SIZE_c),
        RAM_TYPE_g      => RAM_TYPE_g,
        MAXIMUM_DEPTH_g => 256,
        ADDRESS_WIDTH_g => log2_ceil(2*(SLDWIN_SIZE_c))
        )
      port map (
        clk           => clk,
        reset         => reset,
        ena           => ena,
        read_address  => address_gamma_read,
        write_address => address_gamma_write,
        din           => gamma_to_mem(i),
        wren          => gamma_ram_wren,
        rden          => gamma_ram_rden,
        dout          => gamma_from_mem(i)
        );

    -- Beta RAMs
    beta_ram : auk_dspip_ctc_umts_ram
      generic map (
        DATA_WIDTH_g    => (MAX_STATES_c-1)*SOFT_WIDTH_g,
        DATA_DEPTH_g    => 2*(SLDWIN_SIZE_c),
        RAM_TYPE_g      => RAM_TYPE_g,
        MAXIMUM_DEPTH_g => 256,
        ADDRESS_WIDTH_g => log2_ceil(2*(SLDWIN_SIZE_c))
        )
      port map (
        clk           => clk,
        reset         => reset,
        ena           => ena,
        read_address  => address_beta_read,
        write_address => address_beta_write,
        din           => beta_to_mem(i),
        wren          => beta_ram_wren,
        rden          => beta_ram_rden,
        dout          => beta_from_mem(i)
        );

    prev_beta_to_mem_proc : process (clk, reset)
    begin  -- process prev_beta_to_mem_proc
      if reset = '1' then
        prev_beta_to_mem(i) <= (others => '0');
      elsif rising_edge(clk) then
        if prev_alpha_ram_wren = '0' then
          prev_beta_to_mem(i) <= beta(i);
        else
          prev_beta_to_mem(i) <= alpha(i);
        end if;
      end if;
    end process prev_beta_to_mem_proc;

--    prev_beta_to_mem(i) <= beta(i) when prev_alpha_ram_wren = '0' else alpha(i);

    -- RAMs for previous Alpha & Beta values
    previous_beta_ram : auk_dspip_ctc_umts_ram
      generic map (
        DATA_WIDTH_g    => (MAX_STATES_c-1)*SOFT_WIDTH_g,
        DATA_DEPTH_g    => 2*PREVS_ALPHABETA_DEPTH_c,
        RAM_TYPE_g      => RAM_TYPE_g,
        MAXIMUM_DEPTH_g => 256,
				ADDRESS_WIDTH_g => PREVS_ALPHABETA_ADDR_WIDTH_c
        )
      port map (
        clk           => clk,
        reset         => reset,
        ena           => ena,
        read_address  => address_prev_beta_read,
        write_address => address_prev_beta_write,
        din           => prev_beta_to_mem(i),
        wren          => prev_alphabeta_ram_wren_reg,
        rden          => prev_alphabeta_ram_rden,
        dout          => prev_beta_from_mem(i)
        );

    -- LLR Calculation Units
    llr_inst : auk_dspip_ctc_umts_map_llr
      generic map (
        WIDTH_g             => SOFT_WIDTH_g,
        DECODER_TYPE_g      => DECODER_TYPE_g
        )
      port map (
        clk            => clk,
        ena            => ena,
        reset          => reset,
        metric_c_1     => metric_input(i)(0),
        metric_c_2     => metric_input(i)(1),
        metric_c_3     => metric_input(i)(2),
        alpha_prime_in => alpha_prime(i),
        beta_in        => beta_from_mem(i),
        llr            => output_u_from_llr(i)
        );

    detected_data_proc : process (clk, reset)
    begin  -- process detected_data_proc
      if reset = '1' then
        detected_data(i) <= '0';
      elsif rising_edge(clk) then
        detected_data(i) <= not(output_u_from_llr(i)(output_u_from_llr(i)'high));
      end if;
    end process detected_data_proc;

    input_u_delay_inst : auk_dspip_delay
      generic map (
        WIDTH_g          => IN_WIDTH_g,
        DELAY_g          => MAXLOGMAP_LLR_LATENCY_c,  -- the latency of llr_cu
                                                      -- which will be different if
                                                      -- CONST_LOGMAP is used
        MEMORY_TYPE_g    => "register",
        REGISTER_FIRST_g => 0,
        REGISTER_LAST_g  => 0)
      port map (
        clk     => clk,
        reset   => reset,
        enable  => ena,
        datain  => std_logic_vector(input_u_for_llr(i)),
        dataout => input_u_slv(i)
        );

    output_u_diff(i) <= output_u_from_llr(i) - signed(input_u_slv(i));

    scaling_gen : if DECODER_TYPE_g = "MAXLOGMAP" generate
      output_u_scaled_s(i) <= resize(output_u_diff(i) & "0", SOFT_WIDTH_g+2) +
                              resize(output_u_diff(i), SOFT_WIDTH_g+2);
      output_u_scaled(i) <= output_u_scaled_s(i)(SOFT_WIDTH_g+1 downto 2);  --output_u_scaled= output_u_diff*0.75
    end generate scaling_gen;

    non_scaling_gen : if DECODER_TYPE_g /= "MAXLOGMAP" generate
      output_u_scaled(i) <= output_u_diff(i);
    end generate non_scaling_gen;

    auk_dspip_roundsat_inst : auk_dspip_roundsat
      generic map (
        IN_WIDTH_g      => SOFT_WIDTH_g,
        OUT_WIDTH_g     => IN_WIDTH_g,
        ROUNDING_TYPE_g => "SATURATE"
        )
      port map (
        clk     => clk,
        reset   => reset,
        enable  => ena,
        datain  => std_logic_vector(output_u_scaled(i)),
        dataout => output_u_slv(i)
        );

    output_u(i) <= signed(output_u_slv(i));

  end generate parallel_window_gen;

  --synthesis translate_off
  gen_debug : if DEBUG_OUTPUT_U_c = 1 generate
    signal reset_n         : std_logic;
    signal output_concat   : std_logic_vector(IN_WIDTH_g*NPROCESSORS_g -1 downto 0);
    signal decoder_started : std_logic;
    component auk_dspip_avalon_streaming_monitor is
      generic (
        FILENAME_g         : string;
        COMPARE_g          : boolean;
        COMPARE_TO_FILE_g  : string;
        IGNORE_PREFIX_g    : character;
        SYMBOLS_PER_BEAT_g : natural;
        SYMBOL_DELIMETER_g : string;
        PRINT_CLK_REPORT_g : boolean;
        SYMBOL_DATAWIDTH_g : natural);
      port (
        clk       : in std_logic;
        reset_n   : in std_logic;
        -- enables the model
        enable    : in std_logic;
        -- atlantic signals
        avs_valid : in std_logic;
        avs_ready : in std_logic;
        avs_sop   : in std_logic;
        avs_eop   : in std_logic;
        -- data contains real and imaginary data, imaginary in LSW, real in MSW
        avs_data  : in std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0));
    end component auk_dspip_avalon_streaming_monitor;
    signal monitor_valid : std_logic;

  begin
    reset_n <= not reset;

    decoder_started_p : process (clk, reset)
    begin  -- process decoder_started_p
      if reset = '1' then
        decoder_started <= '0';
      elsif rising_edge(clk) then
        if decode_start = '1' then
          decoder_started <= '1';
        elsif dout_eop_s = '1' and to_integer(iter_dec) = max_iter_dec-1 then
          decoder_started <= '0';
        end if;
      end if;
    end process decoder_started_p;

    monitor_valid <= out_valid_s and decoder_started;

    concat_output : for k in 1 to NPROCESSORS_g-1 generate
      output_concat(k*IN_WIDTH_g - 1 downto (k-1)*IN_WIDTH_g) <= std_logic_vector(output_u(k-1));
    end generate concat_output;

    output_concat(NPROCESSORS_g*IN_WIDTH_g - 1 downto (NPROCESSORS_g-1)*IN_WIDTH_g) <= std_logic_vector(output_u(NPROCESSORS_g-1)) when out_valid_last_s = '1' else (others => '0');

    monitor : auk_dspip_avalon_streaming_monitor
      generic map (
        FILENAME_g         => "output_u.txt",
        COMPARE_g          => false,
        COMPARE_TO_FILE_g  => "",
        IGNORE_PREFIX_g    => '#',
        SYMBOLS_PER_BEAT_g => NPROCESSORS_g,
        SYMBOL_DELIMETER_g => " ",
        PRINT_CLK_REPORT_g => false,
        SYMBOL_DATAWIDTH_g => IN_WIDTH_g)
      port map (
        clk       => clk,
        reset_n   => reset_n,
        -- enables the model
        enable    => ena,
        -- atlantic signals
        avs_valid => monitor_valid,
        avs_ready => '1',
        avs_sop   => '1',
        avs_eop   => '1',
        -- data contains real and imaginary data, imaginary in LSW, real in MSW
        avs_data  => output_concat);

  end generate gen_debug;
  --synthesis translate_on

-- interleavers

  deintlvr_addr_rd_cnt_proc : process (clk, reset)
  begin  -- process deintlvr_addr_rd_cnt_proc
    if reset = '1' then
      deintlvr_addr_rd_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
      deintlvr_ram_rden    <= '0';
      intlvr_ram_rden      <= '0';
    elsif rising_edge(clk) then
      if dec_cnt_delayed = startup_latency + OUTPUT_LATENCY_c-4 then
        deintlvr_addr_rd_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
        if iter_dec(0) = '0' then
          deintlvr_ram_rden <= '1';
        else
          intlvr_ram_rden <= '1';
        end if;
      elsif deintlvr_addr_rd_cnt = sub_block_size-1 then
        deintlvr_addr_rd_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
        deintlvr_ram_rden    <= '0';
        intlvr_ram_rden      <= '0';
      else
        deintlvr_addr_rd_cnt <= deintlvr_addr_rd_cnt + to_unsigned(1, MAX_SUB_FRAME_WIDTH_c);
      end if;
    end if;
  end process deintlvr_addr_rd_cnt_proc;

  deintlvr_addr_rd <= deintlvr_addr_rd_cnt;
  intlvr_addr_rd   <= deintlvr_addr_rd_cnt;

  deintlvr_sub_locs_gen : for i in 0 to NPROCESSORS_g-1 generate
    deintlvr_location_arr(i) <= unsigned(deintlvr_info_from_mem((i+1)*DEINTLVR_INFO_WIDTH_c-1 downto i*DEINTLVR_INFO_WIDTH_c+NUM_ENGINES_WIDTH_g));
    deintlvr_sub_locs(i)     <= unsigned(deintlvr_info_from_mem(i*DEINTLVR_INFO_WIDTH_c+NUM_ENGINES_WIDTH_g-1 downto i*DEINTLVR_INFO_WIDTH_c));
  end generate deintlvr_sub_locs_gen;

  intlvr_sub_locs_gen : for i in 0 to NPROCESSORS_g-1 generate
    intlvr_location_arr(i) <= unsigned(intlvr_info_from_mem((i+1)*DEINTLVR_INFO_WIDTH_c-1 downto i*DEINTLVR_INFO_WIDTH_c+NUM_ENGINES_WIDTH_g));
    intlvr_sub_locs(i)     <= unsigned(intlvr_info_from_mem(i*DEINTLVR_INFO_WIDTH_c+NUM_ENGINES_WIDTH_g-1 downto i*DEINTLVR_INFO_WIDTH_c));
  end generate intlvr_sub_locs_gen;

  -- output

  out_valid_proc : process (clk, reset)
  begin  -- process out_valid_proc
    if reset = '1' then
      out_valid_s <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        if dec_cnt = startup_latency+OUT_VALID_LATENCY_c+INPUT_READ_LATENCY_c-1 then
          out_valid_s <= '1';
        elsif (dec_cnt_delayed = startup_latency+sub_block_size+OUT_VALID_LATENCY_c-1) or decode_start = '1' then
          out_valid_s <= '0';
        end if;
      end if;
    end if;
  end process out_valid_proc;

  out_valid_last_proc : process (clk, reset)
  begin  -- process out_valid_last_proc
    if reset = '1' then
      out_valid_last_s <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        if dec_cnt = startup_latency+OUT_VALID_LATENCY_c+INPUT_READ_LATENCY_c-1 then
          out_valid_last_s <= '1';
        elsif (dec_cnt_delayed = startup_latency+sub_block_size+OUT_VALID_LATENCY_c-1-sub_block_size_diff) or decode_start = '1' then
          out_valid_last_s <= '0';
        end if;
      end if;
    end if;
  end process out_valid_last_proc;

  dout_sop_s <= or_reduce(fifo_wren_slv) and not(or_reduce(input_u_wren_arr));
  dout_eop_s <= or_reduce(input_u_wren_arr) and not(or_reduce(fifo_wren_slv));
  dout_eop   <= dout_eop_s;
  dout_sop   <= dout_sop_s;

end architecture SYN;

