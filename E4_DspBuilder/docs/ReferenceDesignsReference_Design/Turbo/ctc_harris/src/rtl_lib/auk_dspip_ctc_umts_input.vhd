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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;
use auk_dspip_lib.auk_dspip_lib_pkg.all;

entity auk_dspip_ctc_umts_input is
  generic (
    NPROCESSORS_g       : integer  := 4;   -- number of parallel engines
    NUM_ENGINES_WIDTH_g : positive := 3;   -- log2_ceil_one(NPROCESSORS_g);
    DATA_WIDTH_g        : positive := 11;  -- log2_ceil_one(MAX_FRAME_SIZE_c/NPROCESSORS_g);
    INPUT_WIDTH_g       : integer  := 24;  -- input data width
    ADDRESS_WIDTH_g     : positive := 11   -- =log2_ceil(MAX_SUB_FRAME_SIZE_c)
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
end entity auk_dspip_ctc_umts_input;

architecture SYN of auk_dspip_ctc_umts_input is

  function get_sub_loc_cnt_width(arg : in integer) return integer is
    variable res : integer;
  begin
    res := log2_ceil_one(arg);
    if res < 2 then
      res := 2;
    end if;
    return res;
  end get_sub_loc_cnt_width;

  constant MAX_SUB_FRAME_SIZE_c       : natural  := MAX_FRAME_SIZE_c/NPROCESSORS_g;
  constant MEMORY_WIDTH_c             : natural  := NPROCESSORS_g*INPUT_WIDTH_g;
  constant ADDRESS_WIDTH_c            : natural  := ADDRESS_WIDTH_g + 1;
  constant MEMORY_DEPTH_c             : natural  := 2*MAX_SUB_FRAME_SIZE_c;
  constant MAX_SUB_FRAME_WIDTH_c      : positive := log2_ceil_one(MAX_SUB_FRAME_SIZE_c);
  constant SUB_LOC_CNT_WIDTH_c   : positive := get_sub_loc_cnt_width(NPROCESSORS_g);
  constant DEINTLVR_LOAD_DELAY_c      : natural  := 6;  -- delay that interlvrs are sloaded
  constant DEINTLVR_INFO_WIDTH_c      : natural  := MAX_SUB_FRAME_WIDTH_c+NUM_ENGINES_WIDTH_g;
  constant INTLVR_LOAD_DONE_LATENCY_c : natural  := 3;

  signal address_wr  : unsigned (ADDRESS_WIDTH_g-1 downto 0);
  signal address_in  : unsigned (ADDRESS_WIDTH_c-1 downto 0);
  signal address_out : unsigned (ADDRESS_WIDTH_c-1 downto 0);
  signal write_en    : std_logic;       -- write enable

  signal bank_id       : integer range 0 to 1;  -- buffer bank id
  signal bank_id_reg   : integer range 0 to 1;  -- buffer bank id
  signal read_bank_id  : integer range 0 to 1;  -- buffer bank id that decoder is using
  signal bank_full     : std_logic_vector(1 downto 0);  -- indicating if the input bank is full
  signal bank_ready    : std_logic_vector(1 downto 0);  -- indicating if the
                                        -- bank is ready for decoding
  signal decoder_ready : std_logic;     -- is the decoder ready for decoding
                                        -- next block

  type block_size_type is array (0 to 1) of unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  type iter_to_run_type is array (0 to 1) of unsigned(IT_WIDTH_c-1 downto 0);

  signal iter_to_run_data : iter_to_run_type;
  signal block_size_data  : block_size_type;
  signal block_size_s     : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal sub_block_size_s : unsigned(DATA_WIDTH_g-1 downto 0);  -- current sub-block size

  signal ena_intlvr     : std_logic;
  signal start_decode_s : std_logic;

  type   state_t is (IDLE, LOAD, STALL);
  signal state      : state_t;
  signal next_state : state_t;

  signal sload_intlvr_load_s : std_logic;  -- reset load interleaver

  type intlvr_data_type0 is array (0 to 1) of unsigned(DATA_WIDTH_g-1 downto 0);
  type intlvr_data_type1 is array (0 to 1) of unsigned(DATA_WIDTH_g downto 0);
  type intlvr_data_type2 is array (0 to 1) of signed(DATA_WIDTH_g downto 0);
  type intlvr_data_type3 is array (0 to 1) of unsigned(NUM_ENGINES_WIDTH_g-1 downto 0);
  type intlvr_data_type4 is array (0 to 1) of unsigned((NPROCESSORS_g-1)*NUM_ENGINES_WIDTH_g-1 downto 0);

  signal blk_cnt     : unsigned (FRAME_SIZE_WIDTH_c-1 downto 0);  --integer range 0 to MAX_FRAME_SIZE_c + NUM_OF_TAIL_BIT_CYCLES_c-1;
  signal sub_blk_cnt : unsigned (MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal sub_loc_cnt : unsigned (SUB_LOC_CNT_WIDTH_c-1 downto 0);
  signal sub_loc     : unsigned (NUM_ENGINES_WIDTH_g-1 downto 0);  -- sub-location of input data should go

  signal intlvr_sub_blk_cnt : unsigned (MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal intlvr_sub_loc_cnt : unsigned (NUM_ENGINES_WIDTH_g-1 downto 0);

  signal intlvr_sub_blk_delayed   : unsigned (MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal intlvr_sub_loc_delayed   : unsigned (NUM_ENGINES_WIDTH_g-1 downto 0);
  signal intlvr_sub_blk_delayed_s : unsigned (MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  signal intlvr_sub_loc_delayed_s : unsigned (NUM_ENGINES_WIDTH_g-1 downto 0);

  type   intlvr_inter_reg_array is array (0 to NPROCESSORS_g-2) of unsigned(NUM_ENGINES_WIDTH_g-1 downto 0);
  type   intlvr_sub_loc_array is array (0 to NPROCESSORS_g-1) of unsigned(NUM_ENGINES_WIDTH_g-1 downto 0);
  type   intlvr_location_array is array (0 to NPROCESSORS_g-1) of unsigned(MAX_SUB_FRAME_WIDTH_c-1 downto 0);
  type   intlvr_out_addr_minus_array is array (0 to NPROCESSORS_g-1) of signed(FRAME_SIZE_WIDTH_c downto 0);
  signal intlvr_sub_locs       : intlvr_sub_loc_array;  -- interleaver sub-locations
  signal intlvr_out_addr       : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal intlvr_out_addr_minus : intlvr_out_addr_minus_array;
  signal intlvr_location_arr   : intlvr_location_array;

  signal deintlvr_sub_locs     : intlvr_sub_loc_array;  -- deinterleaver sub-locations
  signal deintlvr_location_arr : intlvr_location_array;

  type intlvr_info_to_mem_array is array (0 to NPROCESSORS_g-1) of signed(DEINTLVR_INFO_WIDTH_c-1 downto 0);

  signal intlvr_info_to_mem_arr   : intlvr_info_to_mem_array;
  signal deintlvr_info_to_mem_arr : intlvr_info_to_mem_array;

  signal intlvr_loc_valid         : std_logic;
  signal intlvr_loc_valid_s       : std_logic;
  signal intlvr_loc_valid_delayed : std_logic;
  signal intlvr_load_done         : std_logic;
  signal block_load_done          : std_logic;
  signal intlvr_load_done_slv     : std_logic_vector(0 downto 0);
  signal block_load_done_slv      : std_logic_vector(0 downto 0);

  type deintlvr_address_write_array is array (0 to NPROCESSORS_g-1) of unsigned(MAX_SUB_FRAME_WIDTH_c downto 0);

  signal intlvr_address_write_arr   : deintlvr_address_write_array;
  signal intlvr_address_read        : unsigned(MAX_SUB_FRAME_WIDTH_c downto 0);
  signal intlvr_addr_rd_s           : unsigned(ADDRESS_WIDTH_g-1 downto 0);
  signal deintlvr_address_write_arr : deintlvr_address_write_array;
  signal deintlvr_address_read      : unsigned(MAX_SUB_FRAME_WIDTH_c downto 0);
  signal deintlvr_addr_rd_s         : unsigned(ADDRESS_WIDTH_g-1 downto 0);

  signal intlvr_ram_wren_arr   : std_logic_vector(0 to NPROCESSORS_g-1);
  signal deintlvr_ram_wren_arr : std_logic_vector(0 to NPROCESSORS_g-1);

  constant DEBUG_c : natural := 1;

    type     sub_itlv_type is array (0 to 2*MAX_SUB_FRAME_SIZE_c-1) of signed(12 downto 0);
    type     itlv_type is array (0 to NPROCESSORS_g-1) of sub_itlv_type;
    signal   itlv   : itlv_type;




begin  -- architecture SYN
-----------------------------------------------------------------------------
  -- error checking:
  -----------------------------------------------------------------------------
  assert (ADDRESS_WIDTH_g = log2_ceil(MAX_SUB_FRAME_SIZE_c)) report "Your ADDRESS_WIDTH_g must be " & integer'image(log2_ceil(MAX_SUB_FRAME_SIZE_c)) severity error;
  assert (DATA_WIDTH_g = log2_ceil(MAX_SUB_FRAME_SIZE_c)) report "Your DATA_WIDTH_g must be " & integer'image(log2_ceil_one(MAX_FRAME_SIZE_c/NPROCESSORS_g)) severity error;

  -- Use bank_id to adjust the addresses
  -- bank_id is the bank to write (for input) and not(bank_id) is the bank to
  -- read (for decode)
  -- address_wr is the absolute address offset from the start of current mem bank
  address_wr  <= resize(sub_blk_cnt, ADDRESS_WIDTH_g);
  address_in  <= resize(address_wr, address_in'length) when bank_id = 0 else resize(address_wr, address_in'length) + MAX_SUB_FRAME_SIZE_c;
  address_out <= resize(addr_rd, address_out'length)   when bank_id = 1 else resize(addr_rd, address_out'length) + MAX_SUB_FRAME_SIZE_c;

  -- input stall asserts if current bank being written to is full
  input_stall    <= '1' when bank_full(bank_id) = '1'                                                                                        else '0';
  start_decode_s <= '1' when bank_full(read_bank_id) = '1' and bank_ready(read_bank_id) = '1' and decoder_ready = '1' and decode_stall = '0' else '0';
  start_decode   <= start_decode_s;
  ena_intlvr     <= ena;

  bank_id      <= bank_id_reg;
  read_bank_id <= 1 - bank_id;
  sub_loc      <= sub_loc_cnt(NUM_ENGINES_WIDTH_g-1 downto 0);

  write_en <= '1' when in_valid = '1' and bank_full(bank_id) = '0' else '0';

  block_size_s <= block_size_data(bank_id);

  sub_block_size_gen1 : if NPROCESSORS_g = 1 generate
    sub_block_size_s <= block_size_data(bank_id);
  end generate sub_block_size_gen1;

  -- if block size is even, half it; if odd, half the size + 1
  sub_block_size_gen2 : if NPROCESSORS_g = 2 generate
    sub_block_size_s <= block_size_data(bank_id)(block_size_data(bank_id)'high downto 1) when block_size_data(bank_id)(0) = '0' else
                        block_size_data(bank_id)(block_size_data(bank_id)'high downto 1) + 1;
  end generate sub_block_size_gen2;

  -- if block size is divisible by 4, divide it by 4; otherwise, use ceil()
  sub_block_size_gen4 : if NPROCESSORS_g = 4 generate
    sub_block_size_s <= block_size_data(bank_id)(block_size_data(bank_id)'high downto 2) when block_size_data(bank_id)(1 downto 0) = "00" else
                        block_size_data(bank_id)(block_size_data(bank_id)'high downto 2) + 1;
  end generate sub_block_size_gen4;

  -- why we need to reset intlvr read address to 0 when read enable is low?
  -- intlvr_addr_rd is the absolute address offset from the start of either ram block
  intlvr_addr_rd_s    <= intlvr_addr_rd                                       when intlvr_ram_rden = '1' else to_unsigned(0, ADDRESS_WIDTH_g);
  intlvr_address_read <= resize(intlvr_addr_rd_s, intlvr_address_read'length) when read_bank_id = 0      else
                         resize(intlvr_addr_rd_s, intlvr_address_read'length) + MAX_SUB_FRAME_SIZE_c;

  deintlvr_addr_rd_s    <= deintlvr_addr_rd                                         when deintlvr_ram_rden = '1' else to_unsigned(0, ADDRESS_WIDTH_g);
  deintlvr_address_read <= resize(deintlvr_addr_rd_s, deintlvr_address_read'length) when read_bank_id = 0        else
                           resize(deintlvr_addr_rd_s, deintlvr_address_read'length) + MAX_SUB_FRAME_SIZE_c;

  block_size_proc : process (clk, reset)
  begin  -- process block_size_proc
    if reset = '1' then
      iter_to_run_data <= (others => (others => '0'));
      block_size_data  <= (others => to_unsigned(MAX_FRAME_SIZE_c, FRAME_SIZE_WIDTH_c));
    elsif rising_edge(clk) then
      if ena = '1' then
        -- sample input block size at in_sop
        -- is this equivalent to checking input_stall?
        if in_valid = '1' and in_sop = '1' and bank_full(bank_id) = '0' then
          block_size_data(bank_id)  <= blk_size_in;
          iter_to_run_data(bank_id) <= iter_in;
        end if;
      end if;
    end if;
  end process block_size_proc;

  -- bank_ready means bank ready to be read from
  -- decoder_ready means decoder can accept a new frame
  bank_state_proc : process (clk, reset)
  begin
    if reset = '1' then
      bank_full     <= (others => '0');
      bank_ready    <= (others => '0');
      decoder_ready <= '1';
    elsif rising_edge(clk) then
      if ena = '1' then
        if decode_done = '1' then
          bank_full(read_bank_id)  <= '0';
          bank_ready(read_bank_id) <= '0';
          decoder_ready            <= '1';
        elsif start_decode_s = '1' then
          decoder_ready <= '0';
        end if;
        -- dn't need to check input_stall here? we assume we don't back
        -- pressure within a frame?
        if in_valid = '1' and in_eop = '1' then
          bank_full(bank_id) <= '1';
        end if;
        -- what's block_load_done?
        if block_load_done = '1' then
          bank_ready(bank_id) <= '1';
        end if;
      end if;
    end if;
  end process bank_state_proc;

  bank_id_proc : process (clk, reset)
  begin  -- process bank_id_proc
    if reset = '1' then
      bank_id_reg <= 0;
    elsif rising_edge(clk) then
      if ena = '1' then
        -- toggle the bank_id when it is ready to decode
        if (bank_full(bank_id) = '1' and bank_ready(bank_id) = '1' and decoder_ready = '1' and decode_stall = '0') then
          bank_id_reg <= 1 - bank_id_reg;
        end if;
      end if;
    end if;
  end process bank_id_proc;

  blk_cnt_proc : process (clk, reset)
  begin  -- process blk_cnt_proc
    if reset = '1' then
      blk_cnt <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
    elsif rising_edge(clk) then
      if ena = '1' then
        if in_valid = '1' and bank_full(bank_id) = '0' then
          if in_sop = '1' then
            blk_cnt <= to_unsigned(1, FRAME_SIZE_WIDTH_c);
          elsif in_eop = '1' then
            blk_cnt <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
          else
            blk_cnt <= blk_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process blk_cnt_proc;

  intlvr_sub_blk_cnt_proc : process (clk, reset)
  begin  -- process intlvr_sun_blk_cnt_porc
    if reset = '1' then
      intlvr_sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
      intlvr_sub_loc_cnt <= to_unsigned(0, NUM_ENGINES_WIDTH_g);
    elsif rising_edge(clk) then
      if ena = '1' then
        if intlvr_load_done = '1' then
          intlvr_sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
          intlvr_sub_loc_cnt <= to_unsigned(0, NUM_ENGINES_WIDTH_g);
          -- Q: why intlvr_sub_blk_cnt increment depends on loc_valid signal?
        elsif intlvr_loc_valid = '1' then
          if intlvr_sub_blk_cnt = sub_block_size_s - 1 then
            intlvr_sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
            intlvr_sub_loc_cnt <= intlvr_sub_loc_cnt + 1;
          else
            intlvr_sub_blk_cnt <= intlvr_sub_blk_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process intlvr_sub_blk_cnt_proc;

  num_engine2_gen : if (NPROCESSORS_g <= 2) generate
    sub_blk_cnt_proc : process (clk, reset)
    begin  -- process sub_blk_cnt_proc
      if reset = '1' then
        sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
        sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
      elsif rising_edge(clk) then
        if ena = '1' then
          if in_valid = '1' and bank_full(bank_id) = '0' then
            if in_sop = '1' then
              sub_blk_cnt <= to_unsigned(1, MAX_SUB_FRAME_WIDTH_c);
              sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
            elsif in_eop = '1' then
              sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
              sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
            elsif blk_cnt < block_size_s-1 then
              if sub_blk_cnt = sub_block_size_s - 1 then
                sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
                sub_loc_cnt <= sub_loc_cnt + 1;
              else
                sub_blk_cnt <= sub_blk_cnt + 1;
              end if;
            else  -- tail bits : blk_cnt >= block_size_s-1
              if blk_cnt = block_size_s-1 then
                sub_blk_cnt <= sub_block_size_s;
                sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
              elsif sub_loc_cnt = NPROCESSORS_g-1 then
                sub_blk_cnt <= sub_blk_cnt + 1;
                sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
              else
                sub_loc_cnt <= sub_loc_cnt + 1;
              end if;
            end if;
          end if;
        end if;
      end if;
    end process sub_blk_cnt_proc;
  end generate num_engine2_gen;

  -- if NPROCESSORS_g > 2
  num_engine_bt2_gen : if (NPROCESSORS_g > 2) generate
    sub_blk_cnt_proc : process (clk, reset)
    begin  -- process sub_blk_cnt_proc
      if reset = '1' then
        sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
        sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
      elsif rising_edge(clk) then
        if ena = '1' then
          if in_valid = '1' and bank_full(bank_id) = '0' then
            if in_sop = '1' then
              sub_blk_cnt <= to_unsigned(1, MAX_SUB_FRAME_WIDTH_c);
              sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
            elsif in_eop = '1' then
              sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
              sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
              -- Q: does sub_block_size_s account for the tail bits?
            elsif blk_cnt < block_size_s-1 then
              if sub_blk_cnt = sub_block_size_s - 1 then
                sub_blk_cnt <= to_unsigned(0, MAX_SUB_FRAME_WIDTH_c);
                sub_loc_cnt <= sub_loc_cnt + 1;
              else
                sub_blk_cnt <= sub_blk_cnt + 1;
              end if;
              -- so apparently block_size_s does NOT account for the tail bits
            else  -- tail bits : blk_cnt >= block_size_s-1
              if blk_cnt = block_size_s-1 then
                sub_blk_cnt <= sub_block_size_s;
                sub_loc_cnt <= to_unsigned(0, SUB_LOC_CNT_WIDTH_c);
              else
                sub_loc_cnt <= sub_loc_cnt + 1;
              end if;
            end if;
          end if;
        end if;
      end if;
    end process sub_blk_cnt_proc;
  end generate num_engine_bt2_gen;

  -- Registered state process.
  fsm_reg : process (clk, reset)
  begin
    if reset = '1' then
      state <= IDLE;
    elsif rising_edge(clk) then
      if ena = '1' then
        state <= next_state;
      end if;
    end if;
  end process fsm_reg;

  -- Combintorial next state process.
  -- If input data is bursty within a frame, status goes from load to idle
  -- Q: why does input need a fsm?
  fsm_comb : process (bank_full, bank_id, in_valid, state)
  begin
    case state is
      when IDLE =>
        if in_valid = '1' then
          if bank_full(bank_id) = '1' then
            next_state <= STALL;
          else
            next_state <= LOAD;
          end if;
        else
          next_state <= IDLE;
        end if;
      when LOAD =>
        if in_valid = '1' then
          if bank_full(bank_id) = '1' then
            next_state <= STALL;
          else
            next_state <= LOAD;
          end if;
        else
          next_state <= IDLE;
        end if;
      when STALL =>
        if bank_full(bank_id) = '0' then
          if in_valid = '1' then
            next_state <= LOAD;
          else
            next_state <= IDLE;
          end if;
        else
          next_state <= STALL;
        end if;
      when others =>
        next_state <= IDLE;
    end case;
  end process fsm_comb;

  -- Memory used for input double buffering
  input_ram_inst : auk_dspip_ctc_umts_input_ram
    generic map (
      DATA_DEPTH_g        => MEMORY_DEPTH_c,
      NPROCESSORS_g       => NPROCESSORS_g,
      INPUT_WIDTH_g       => INPUT_WIDTH_g,
      NUM_ENGINES_WIDTH_g => NUM_ENGINES_WIDTH_g,
      ADDRESS_WIDTH_g     => ADDRESS_WIDTH_c
      )
    port map (
      clk           => clk,
      reset         => reset,
      ena           => ena,
      read_address  => address_out,
      write_address => address_in,
      sub_address   => sub_loc,
      din           => data_in,
      wren          => write_en,
      rden          => read_en,
      dout          => data_out
      );

  umts_intlvr : auk_dspip_ctc_umts2_itlv
    generic map (
      gCOUNTER_WIDTH => FRAME_SIZE_WIDTH_c
      )

    port map (
      clk          => clk,
      enable       => ena_intlvr,
      reset        => reset,
      start_load   => sload_intlvr_load_s,
      out_addr     => intlvr_out_addr,
      RxC          => open ,
      blk_size     => block_size_s ,
      addr_valid   => intlvr_loc_valid ,
      seq_gen_done => intlvr_load_done
      );

  intlvr_load_done_inst : auk_dspip_delay
    generic map (
      WIDTH_g          => 1,
      DELAY_g          => INTLVR_LOAD_DONE_LATENCY_c,
      MEMORY_TYPE_g    => "register",
      REGISTER_FIRST_g => 0,
      REGISTER_LAST_g  => 0)
    port map (
      clk     => clk,
      reset   => reset,
      enable  => ena,
      datain  => intlvr_load_done_slv,
      dataout => block_load_done_slv
      );

  intlvr_load_done_slv(0) <= intlvr_load_done;
  block_load_done         <= block_load_done_slv(0);

  intlvr_out_addr_minus_gen2 : if NPROCESSORS_g = 2 generate
    intlvr_out_addr_minus_proc : process (clk, reset)
    begin  -- process intlvr_out_addr_minus_proc
      if reset = '1' then
        intlvr_out_addr_minus <= (others => (others => '0'));
      elsif rising_edge(clk) then
        if ena = '1' then
          for i in 0 to NPROCESSORS_g-1 loop
            case i is
              when 0 =>
                intlvr_out_addr_minus(i) <= signed('0' & intlvr_out_addr);
              when 1 =>
                intlvr_out_addr_minus(i) <= signed('0' & intlvr_out_addr) - signed(resize('0' & sub_block_size_s, FRAME_SIZE_WIDTH_c+1));
              when others => null;
            end case;
          end loop;  -- i
        end if;
      end if;
    end process intlvr_out_addr_minus_proc;
  end generate intlvr_out_addr_minus_gen2;

  intlvr_out_addr_minus_gen4 : if NPROCESSORS_g = 4 generate
    intlvr_out_addr_minus_proc : process (clk, reset)
    begin  -- process intlvr_out_addr_minus_proc
      if reset = '1' then
        intlvr_out_addr_minus <= (others => (others => '0'));
      elsif rising_edge(clk) then
        if ena = '1' then
          for i in 0 to NPROCESSORS_g-1 loop
            case i is
              when 0 =>
                intlvr_out_addr_minus(i) <= signed('0' & intlvr_out_addr);
              when 1 =>
                intlvr_out_addr_minus(i) <= signed('0' & intlvr_out_addr) - signed(resize('0' & sub_block_size_s, FRAME_SIZE_WIDTH_c+1));
              when 2 =>
                intlvr_out_addr_minus(i) <= signed('0' & intlvr_out_addr) - signed(resize('0' & sub_block_size_s & '0', FRAME_SIZE_WIDTH_c+1));
              when 3 =>
                intlvr_out_addr_minus(i) <= signed('0' & intlvr_out_addr) - signed(resize('0' & sub_block_size_s & '0', FRAME_SIZE_WIDTH_c+1)) - signed(resize('0' & sub_block_size_s, FRAME_SIZE_WIDTH_c+1));
              when others => null;
            end case;
          end loop;  -- i
        end if;
      end if;
    end process intlvr_out_addr_minus_proc;
  end generate intlvr_out_addr_minus_gen4;

  intlvr_sub_loc_delayed_proc : process (clk, reset)
  begin  -- process intlvr_sub_loc_delayed_proc
    if reset = '1' then
      intlvr_sub_loc_delayed_s <= (others => '0');
      intlvr_sub_blk_delayed_s <= (others => '0');
      intlvr_sub_blk_delayed   <= (others => '0');
      intlvr_sub_loc_delayed   <= (others => '0');
    elsif rising_edge(clk) then
      intlvr_sub_loc_delayed_s <= intlvr_sub_loc_cnt;
      intlvr_sub_blk_delayed_s <= intlvr_sub_blk_cnt;
      intlvr_sub_blk_delayed   <= intlvr_sub_blk_delayed_s;
      intlvr_sub_loc_delayed   <= intlvr_sub_loc_delayed_s;
    end if;
  end process intlvr_sub_loc_delayed_proc;

  intlvr_location_gen1 : if NPROCESSORS_g = 1 generate
    intlvr_location_proc : process (clk, reset)
    begin  -- process intlvr_location_proc
      if reset = '1' then
        intlvr_location_arr <= (others => (others => '0'));
        intlvr_sub_locs     <= (others => (others => '0'));
      elsif rising_edge(clk) then
        intlvr_location_arr(0) <= unsigned(intlvr_out_addr_minus(0)(MAX_SUB_FRAME_WIDTH_c-1 downto 0));
        intlvr_sub_locs(0)     <= to_unsigned(0, NUM_ENGINES_WIDTH_g);
      end if;
    end process intlvr_location_proc;
  end generate intlvr_location_gen1;

  intlvr_location_gen2 : if NPROCESSORS_g = 2 generate
    intlvr_location_proc : process (clk, reset)
    begin  -- process intlvr_location_proc
      if reset = '1' then
        intlvr_location_arr <= (others => (others => '0'));
        intlvr_sub_locs     <= (others => (others => '0'));
      elsif rising_edge(clk) then
        if intlvr_out_addr_minus(1)(FRAME_SIZE_WIDTH_c) = '1' then
          intlvr_location_arr(to_integer(intlvr_sub_loc_delayed_s)) <= unsigned(intlvr_out_addr_minus(0)(MAX_SUB_FRAME_WIDTH_c-1 downto 0));
          intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed_s))     <= to_unsigned(0, NUM_ENGINES_WIDTH_g);
        else
          intlvr_location_arr(to_integer(intlvr_sub_loc_delayed_s)) <= unsigned(intlvr_out_addr_minus(1)(MAX_SUB_FRAME_WIDTH_c-1 downto 0));
          intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed_s))     <= to_unsigned(1, NUM_ENGINES_WIDTH_g);
        end if;
      end if;
    end process intlvr_location_proc;
  end generate intlvr_location_gen2;

  intlvr_location_gen4 : if NPROCESSORS_g = 4 generate
    intlvr_location_proc : process (clk, reset)
    begin  -- process intlvr_location_proc
      if reset = '1' then
        intlvr_location_arr <= (others => (others => '0'));
        intlvr_sub_locs     <= (others => (others => '0'));
      elsif rising_edge(clk) then
        if intlvr_out_addr_minus(1)(FRAME_SIZE_WIDTH_c) = '1' then
          intlvr_location_arr(to_integer(intlvr_sub_loc_delayed_s)) <= unsigned(intlvr_out_addr_minus(0)(MAX_SUB_FRAME_WIDTH_c-1 downto 0));
          intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed_s))     <= to_unsigned(0, NUM_ENGINES_WIDTH_g);
        elsif intlvr_out_addr_minus(2)(FRAME_SIZE_WIDTH_c) = '1' then
          intlvr_location_arr(to_integer(intlvr_sub_loc_delayed_s)) <= unsigned(intlvr_out_addr_minus(1)(MAX_SUB_FRAME_WIDTH_c-1 downto 0));
          intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed_s))     <= to_unsigned(1, NUM_ENGINES_WIDTH_g);
        elsif intlvr_out_addr_minus(3)(FRAME_SIZE_WIDTH_c) = '1' then
          intlvr_location_arr(to_integer(intlvr_sub_loc_delayed_s)) <= unsigned(intlvr_out_addr_minus(2)(MAX_SUB_FRAME_WIDTH_c-1 downto 0));
          intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed_s))     <= to_unsigned(2, NUM_ENGINES_WIDTH_g);
        else
          intlvr_location_arr(to_integer(intlvr_sub_loc_delayed_s)) <= unsigned(intlvr_out_addr_minus(3)(MAX_SUB_FRAME_WIDTH_c-1 downto 0));
          intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed_s))     <= to_unsigned(3, NUM_ENGINES_WIDTH_g);
        end if;
      end if;
    end process intlvr_location_proc;
  end generate intlvr_location_gen4;

  intlvr_address_write_proc : process (clk, reset)
  begin  -- process intlvr_address_write_proc
    if reset = '1' then
      intlvr_address_write_arr <= (others => (others => '0'));
    elsif rising_edge(clk) then
      for i in 0 to NPROCESSORS_g-1 loop
        if bank_id = 0 then
          intlvr_address_write_arr(i) <= resize(intlvr_sub_blk_delayed, intlvr_address_write_arr(i)'length);
        else
          intlvr_address_write_arr(i) <= resize(intlvr_sub_blk_delayed, intlvr_address_write_arr(i)'length) + MAX_SUB_FRAME_SIZE_c;
        end if;
      end loop;  -- i
    end if;
  end process intlvr_address_write_proc;

  deintlvr_address_write_proc : process (clk, reset)
  begin  -- process address_write_deintlvr_proc
    if reset = '1' then
      deintlvr_address_write_arr <= (others => (others => '0'));
    elsif rising_edge(clk) then
      for i in 0 to NPROCESSORS_g-1 loop
        if intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed)) = to_unsigned(i, NUM_ENGINES_WIDTH_g) then
          if bank_id = 0 then
            deintlvr_address_write_arr(i) <= resize(intlvr_location_arr(to_integer(intlvr_sub_loc_delayed)), MAX_SUB_FRAME_WIDTH_c+1);
          else
            deintlvr_address_write_arr(i) <= resize(intlvr_location_arr(to_integer(intlvr_sub_loc_delayed)), MAX_SUB_FRAME_WIDTH_c+1) + MAX_SUB_FRAME_SIZE_c;
          end if;
        else
          deintlvr_address_write_arr(i) <= (others => '0');
        end if;
      end loop;  -- i
    end if;
  end process deintlvr_address_write_proc;

  intlvr_info_to_mem_proc : process (clk, reset)
  begin  -- process intlvr_info_to_mem_proc
    if reset = '1' then
      intlvr_info_to_mem_arr   <= (others => (others => '0'));
      deintlvr_info_to_mem_arr <= (others => (others => '0'));
    elsif rising_edge(clk) then
      for i in 0 to NPROCESSORS_g-1 loop
        intlvr_info_to_mem_arr(i)(DEINTLVR_INFO_WIDTH_c-1 downto NUM_ENGINES_WIDTH_g)   <= signed(intlvr_location_arr(i));
        intlvr_info_to_mem_arr(i)(NUM_ENGINES_WIDTH_g-1 downto 0)                       <= signed(intlvr_sub_locs(i));
        deintlvr_info_to_mem_arr(i)(DEINTLVR_INFO_WIDTH_c-1 downto NUM_ENGINES_WIDTH_g) <= signed(intlvr_sub_blk_delayed);
        deintlvr_info_to_mem_arr(i)(NUM_ENGINES_WIDTH_g-1 downto 0)                     <= signed(intlvr_sub_loc_delayed);
      end loop;  -- i
    end if;
  end process intlvr_info_to_mem_proc;

  intlvr_address_wren_proc : process (clk, reset)
  begin  -- process intlvr_address_wren_proc
    if reset = '1' then
      intlvr_loc_valid_delayed <= '0';
      intlvr_ram_wren_arr      <= (others => '0');
    elsif rising_edge(clk) then
      intlvr_loc_valid_s       <= intlvr_loc_valid;
      intlvr_loc_valid_delayed <= intlvr_loc_valid_s;
      for i in 0 to NPROCESSORS_g-1 loop
        -- Q: why Frame width instead of Num_engine width?
        -- Q: impact of single buffer reflects on loc_valid_delayed?
        if intlvr_sub_loc_delayed = to_unsigned(i, MAX_SUB_FRAME_WIDTH_c) then
          intlvr_ram_wren_arr(i) <= intlvr_loc_valid_delayed;
        else
          intlvr_ram_wren_arr(i) <= '0';
        end if;
      end loop;  -- i
    end if;
  end process intlvr_address_wren_proc;

  sload_intlvr_load_proc : process (clk, reset)
  begin  -- process sload_intlvr_load_proc
    if reset = '1' then
      sload_intlvr_load_s <= '0';
    elsif rising_edge(clk) then
      if bank_full(bank_id) = '0' and in_sop = '1' then
        sload_intlvr_load_s <= '1';
      else
        sload_intlvr_load_s <= '0';
      end if;
    end if;
  end process sload_intlvr_load_proc;

  deintlvr_ram_wren_proc : process (clk, reset)
  begin  -- process deintlvr_ram_wren_proc
    if reset = '1' then
      deintlvr_ram_wren_arr <= (others => '0');
    elsif rising_edge(clk) then
      for i in 0 to NPROCESSORS_g-1 loop
        if intlvr_sub_locs(to_integer(intlvr_sub_loc_delayed)) = to_unsigned(i, NUM_ENGINES_WIDTH_g) then
          deintlvr_ram_wren_arr(i) <= intlvr_loc_valid_delayed;
        else
          deintlvr_ram_wren_arr(i) <= '0';
        end if;
      end loop;  -- i
    end if;
  end process deintlvr_ram_wren_proc;






  deintlvr_ram_gen : for i in 0 to NPROCESSORS_g-1 generate
    intlvr_ram : auk_dspip_ctc_umts_itlvr_ram
      generic map (
        DATA_WIDTH_g    => DEINTLVR_INFO_WIDTH_c,
        DATA_DEPTH_g    => 2*MAX_SUB_FRAME_SIZE_c,
        ADDRESS_WIDTH_g => MAX_SUB_FRAME_WIDTH_c+1
        )
      port map (
        clk           => clk,
        reset         => reset,
        ena           => ena,
        read_address  => std_logic_vector(intlvr_address_read),
        write_address => std_logic_vector(intlvr_address_write_arr(i)),
        din           => std_logic_vector(intlvr_info_to_mem_arr(i)),
        wren          => intlvr_ram_wren_arr(i),
        rden          => intlvr_ram_rden,
        dout          => intlvr_info_from_mem((i+1)*DEINTLVR_INFO_WIDTH_c-1 downto i*DEINTLVR_INFO_WIDTH_c)
        );
      write_itlv_debug_mem: process (clk, reset) is
      begin  -- process write_itlv_debug_mem

        if rising_edge(clk) then     -- rising clock edge





          if intlvr_ram_wren_arr(i) = '1' then

            itlv(i)(to_integer(deintlvr_address_write_arr(i))) <= intlvr_info_to_mem_arr(i);

            end if;


        end if;
      end process write_itlv_debug_mem;

    deintlvr_ram : auk_dspip_ctc_umts_itlvr_ram
      generic map (
        DATA_WIDTH_g    => DEINTLVR_INFO_WIDTH_c,
        DATA_DEPTH_g    => 2*MAX_SUB_FRAME_SIZE_c,
        ADDRESS_WIDTH_g => MAX_SUB_FRAME_WIDTH_c+1
        )
      port map (
        clk           => clk,
        reset         => reset,
        ena           => ena,
        read_address  => std_logic_vector(deintlvr_address_read),
        write_address => std_logic_vector(deintlvr_address_write_arr(i)),
        din           => std_logic_vector(deintlvr_info_to_mem_arr(i)),
        wren          => deintlvr_ram_wren_arr(i),
        rden          => deintlvr_ram_rden,
        dout          => deintlvr_info_from_mem((i+1)*DEINTLVR_INFO_WIDTH_c-1 downto i*DEINTLVR_INFO_WIDTH_c)
        );

  end generate deintlvr_ram_gen;

  blk_size_out <= block_size_data(read_bank_id);
  it_to_run    <= iter_to_run_data(read_bank_id);

  --synthesis translate_off
  input_symbol_debug : if DEBUG_c = 1 generate
    constant IN_WIDTH_c   : natural := INPUT_WIDTH_g/3;
    type     input_symbol_type is array (0 to 2) of signed(IN_WIDTH_c-1 downto 0);
    signal   input_symbol : input_symbol_type;

  begin
    input_debug_gen : for i in 0 to 2 generate
      input_symbol(i) <= data_in(IN_WIDTH_c*(i+1)-1 downto IN_WIDTH_c*i);
    end generate input_debug_gen;
  end generate input_symbol_debug;
  --synthesis translate_on

  --synthesis translate_off
  --itlv_debug : if DEBUG_c = 1 generate
    --type     sub_itlv_type is array (0 to 12) of signed(12 downto 0);
    --type     itlv_type is array (0 to NPROCESSORS_g-1) of sub_itlv_type;
    --signal   itlv : itlv_type;

-- --begin
--   itlv_debug_gen : for i in 0 to NPROCESSORS_g-1 generate
--     write_itlv_debug_mem: process (clk, reset) is
--     begin  -- process write_itlv_debug_mem
--       if rising_edge(clk) then     -- rising clock edge
--         if intlvr_ram_wren_arr(i) = '1' then
--           itlv(i)(to_integer(deintlvr_address_write_arr(i))) <= intlvr_info_to_mem_arr(i);
--         end if;
--       end if;
--     end process write_itlv_debug_mem;
--
--   end generate itlv_debug_gen;
-- --end generate itlv_debug;
-- --synthesis translate_on

end architecture SYN;

