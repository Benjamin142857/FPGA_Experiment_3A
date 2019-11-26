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

entity auk_dspip_ctc_umts_encode is
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

end entity auk_dspip_ctc_umts_encode;

architecture SYN of auk_dspip_ctc_umts_encode is
  constant INPUT_READ_LATENCY_c   : positive := 2;  -- input memory latency
  constant TAIL_BITS_c            : positive := 4;  -- tail bits
  constant OUTPUT_LATENCY_c       : positive := TAIL_BITS_c + 2;  -- output latency
  constant ENCODE_START_LATENCY_c : positive := 6;  -- encoder start latency
  constant NUMBER_OF_DELAY_c      : positive := 5;  -- number of delay of intlvr_loc_valid

  signal enc_cnt     : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal enc_cnt_slv : std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);

  signal enc_cnt_delayed     : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal enc_cnt_delayed_slv : std_logic_vector(FRAME_SIZE_WIDTH_c-1 downto 0);

  signal is_enc_cnt_lt_blk_size     : std_logic;

  signal address_intlvr : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal din            : std_logic_vector(1 downto 0);
  signal dout_s         : std_logic_vector(2 downto 0);

  signal conv_enc_out0 : std_logic_vector(1 downto 0);
  signal conv_enc_out1 : std_logic_vector(1 downto 0);
  signal enc_cnt_max   : unsigned (FRAME_SIZE_WIDTH_c-1 downto 0);

  signal encode_start_delayed : std_logic_vector(ENCODE_START_LATENCY_c-1 downto 0);
  signal data_in_reg          : std_logic_vector(1 downto 0);

  signal seen_encode_start : std_logic;

  signal encode_ena    : std_logic;
  signal encode_ena_s  : std_logic;
  signal encode_done_s : std_logic;

  constant CYCLE_DELAYS_c        : positive := 2;
  signal   encode_ena_delayed    : std_logic_vector(CYCLE_DELAYS_c-1 downto 0);
  signal   encode_done_s_delayed : std_logic_vector(CYCLE_DELAYS_c-1 downto 0);

  type   encode_state_t is (IDLE, ENC_INPUT_BITS, ENC_TAIL_BITS);
  signal encode_state      : encode_state_t;
  signal next_encode_state : encode_state_t;

  constant TAIL_BITS_CNT_WIDTH_c : positive := 3;
  signal   tail_bits_cnt         : unsigned (TAIL_BITS_CNT_WIDTH_c-1 downto 0);

  signal temp_out_reg : std_logic_vector(3 downto 0);
  signal ena_delayed  : std_logic_vector(2 downto 0);
  signal out_valid_s  : std_logic;
  signal input_rden_s : std_logic;

  signal intlvr_loc_valid     : std_logic;
  signal intlvr_loc_valid_delayed  : std_logic_vector(NUMBER_OF_DELAY_c-1 downto 0);  -- delayed of intlvr_loc_valid
  signal intlvr_load_done     : std_logic;
begin  -- architecture SYN

--  encode_done_s <= '1' when enc_cnt = enc_cnt_max else '0';

  dout_sop    <= seen_encode_start when enc_cnt = 5                   else '0';
  dout_eop    <= seen_encode_start when enc_cnt_delayed = enc_cnt_max else '0';
  encode_done <= encode_done_s;
  input_rden  <= input_rden_s and ena and intlvr_loc_valid;

--  out_valid  <= encode_ena_delayed(1);

  ena_delayed_proc : process (clk, reset)
  begin  -- process ena_delayed_proc
    if reset = '1' then
      ena_delayed <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        for i in 2 downto 1 loop
          ena_delayed(i) <= ena_delayed(i-1);
        end loop;  -- i
        ena_delayed(0) <= ena;
      end if;
    end if;
  end process ena_delayed_proc;

  out_valid_proc : process (clk, reset)
  begin  -- process out_valid_proc
    if reset = '1' then
      out_valid_s <= '0';
      out_valid   <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        out_valid_s <= encode_ena;
        out_valid   <= out_valid_s;
      else
        out_valid <= '0';
      end if;
    end if;
  end process out_valid_proc;

--  out_valid <= '1' when enc_cnt_delayed > 2 and enc_cnt_delayed < enc_cnt_max else '0';

  enc_cnt_slv <= std_logic_vector(enc_cnt);

  rd_addr_intlvr <= std_logic_vector(address_intlvr) when seen_encode_start = '1' else (others => '0');
  rd_addr_input  <= std_logic_vector(enc_cnt);

  -- Registered state process. 
  fsm_reg : process (clk, reset)
  begin
    if reset = '1' then
      encode_state <= IDLE;
    elsif rising_edge(clk) then
      if ena = '1' then
        encode_state <= next_encode_state;
      end if;
    end if;
  end process fsm_reg;

  -- Combintorial next state process.
  fsm_comb : process (blk_size_in, enc_cnt, enc_cnt_delayed, encode_state,
                      seen_encode_start, tail_bits_cnt)
  begin
    case encode_state is
      when IDLE =>
        if seen_encode_start = '1' and enc_cnt = 2 then
          next_encode_state <= ENC_INPUT_BITS;
        else
          next_encode_state <= IDLE;
        end if;
      when ENC_INPUT_BITS =>
        if enc_cnt_delayed = blk_size_in then
          next_encode_state <= ENC_TAIL_BITS;
        else
          next_encode_state <= ENC_INPUT_BITS;
        end if;
      when ENC_TAIL_BITS =>
        if tail_bits_cnt = 4 then
          next_encode_state <= IDLE;
        else
          next_encode_state <= ENC_TAIL_BITS;
        end if;
      when others =>
        next_encode_state <= IDLE;
    end case;
  end process fsm_comb;

  tail_bits_cnt_proc : process (clk, reset)
  begin  -- process tail_bits_cnt_proc
    if reset = '1' then
      tail_bits_cnt <= to_unsigned(0, TAIL_BITS_CNT_WIDTH_c);
    elsif rising_edge(clk) then
      if ena = '1' then
        if encode_state = ENC_TAIL_BITS then
          if seen_encode_start = '1' and enc_cnt_delayed = blk_size_in then
            tail_bits_cnt <= to_unsigned(0, TAIL_BITS_CNT_WIDTH_c);
          else
            tail_bits_cnt <= tail_bits_cnt + 1;
          end if;
        else
          tail_bits_cnt <= to_unsigned(0, TAIL_BITS_CNT_WIDTH_c);
        end if;
      end if;
    end if;
  end process tail_bits_cnt_proc;

  encode_start_delayed_proc : process (clk, reset)
  begin  -- process encode_start_delayed_proc
    if reset = '1' then
      encode_start_delayed <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        for i in ENCODE_START_LATENCY_c-1 downto 1 loop
          encode_start_delayed(i) <= encode_start_delayed(i-1);
        end loop;  -- i
        encode_start_delayed(0) <= encode_start;
      end if;
    end if;
  end process encode_start_delayed_proc;

  encode_done_proc : process (clk, reset)
  begin  -- process encode_done_proc
    if reset = '1' then
      encode_done_s <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        if seen_encode_start = '1' and enc_cnt_delayed = enc_cnt_max then
          encode_done_s <= '1';
        else
          encode_done_s <= '0';
        end if;
      end if;
    end if;
  end process encode_done_proc;

  seen_encode_start_proc : process (clk, reset)
  begin  -- process seen_encode_start_proc
    if reset = '1' then
      seen_encode_start <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        if encode_start = '1' then
          seen_encode_start <= '1';
        elsif encode_done_s = '1' then
          seen_encode_start <= '0';
        end if;
      end if;
    end if;
  end process seen_encode_start_proc;


  input_rden_s <= seen_encode_start and is_enc_cnt_lt_blk_size;
  
  is_enc_cnt_lt_blk_size <= '1' when enc_cnt < blk_size_in else
    '0';


  blk_size_out_proc : process (clk, reset)
  begin  -- process blk_size_out_proc
    if reset = '1' then
      blk_size_out <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
    elsif rising_edge(clk) then
      if ena = '1' and encode_start = '1' then
        blk_size_out <= blk_size_in + TAIL_BITS_c;
      end if;
    end if;
  end process blk_size_out_proc;

  enc_cnt_max_proc : process (clk, reset)
  begin  -- process enc_cnt_max_proc
    if reset = '1' then
      enc_cnt_max <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
    elsif rising_edge(clk) then
      if encode_start = '1' then
        enc_cnt_max <= blk_size_in + OUTPUT_LATENCY_c;
      end if;
    end if;
  end process enc_cnt_max_proc;

  enc_cnt_proc : process (clk, reset)
  begin  -- process enc_cnt_proc
    if reset = '1' then
      enc_cnt <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
    elsif rising_edge(clk) then
      if ena = '1' then
        if encode_start = '1' or enc_cnt = enc_cnt_max then
          enc_cnt <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
        elsif seen_encode_start = '1' and (is_enc_cnt_lt_blk_size = '0' or intlvr_loc_valid = '1') then
          enc_cnt <= enc_cnt +1;
        end if;
      end if;
    end if;
  end process enc_cnt_proc;

  intlvr_inst : auk_dspip_ctc_umts2_itlv
    generic map (
      gCOUNTER_WIDTH => FRAME_SIZE_WIDTH_c
      )
    port map (
      clk          => clk,
      enable       => ena,
      reset        => reset,
      start_load   => encode_start,
      out_addr     => address_intlvr,
      RxC          => open ,
      blk_size     => blk_size_in ,
      addr_valid   => intlvr_loc_valid ,
      seq_gen_done => intlvr_load_done
      );

  enc_cnt_delayed <= unsigned(enc_cnt_delayed_slv);

  enc_cnt_delay_inst : auk_dspip_delay
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
      datain  => enc_cnt_slv,
      dataout => enc_cnt_delayed_slv
      );


  intlvr_loc_valid_proc : process (clk, reset)
  begin  -- process intlvr_loc_valid_proc
    if reset = '1' then  
      intlvr_loc_valid_delayed <= (others => '0');
    elsif rising_edge(clk) then 
      if ena = '1' then  
        for i in NUMBER_OF_DELAY_c - 1 downto 1 loop
          intlvr_loc_valid_delayed(i) <= intlvr_loc_valid_delayed(i-1);
        end loop;  -- i
        intlvr_loc_valid_delayed(0) <= intlvr_loc_valid;
      end if;
    end if;
  end process intlvr_loc_valid_proc;
  
  encode_ena_proc : process (clk, reset)
  begin  -- process encode_ena_proc
    if reset = '1' then
      encode_ena_s <= '0';
    elsif rising_edge(clk) then
      if ena = '1' then
        if seen_encode_start = '1' and enc_cnt = 2 and input_rden_s = '1' then
          encode_ena_s <= '1';
        elsif enc_cnt = enc_cnt_max then
          encode_ena_s <= '0';
        end if;
      end if;
    end if;
  end process encode_ena_proc;

  data_in_reg_proc : process (clk, reset)
  begin  -- process data_in_reg_proc
    if reset = '1' then
      data_in_reg <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        data_in_reg <= data_in;
      end if;
    end if;
  end process data_in_reg_proc;

  din(0) <= data_in_reg(0) when enc_cnt_delayed <= blk_size_in else conv_enc_out0(1);
  din(1) <= data_in_reg(1) when enc_cnt_delayed <= blk_size_in else conv_enc_out1(1);

  encode_ena <= '1' when encode_ena_s = '1' and ena = '1' and (intlvr_loc_valid_delayed(2) = '1' or encode_state = ENC_TAIL_BITS) else '0';

  conv_encode_inst0 : auk_dspip_ctc_umts_conv_encode
    generic map (
      CONSTRAINT_LENGTH_g => 4
      )
    port map (
      clk     => clk,
      ena     => encode_ena,
      reset   => reset,
      data_in => din(0),
      dout    => conv_enc_out0
      );

  conv_encode_inst1 : auk_dspip_ctc_umts_conv_encode
    generic map (
      CONSTRAINT_LENGTH_g => 4
      )
    port map (
      clk     => clk,
      ena     => encode_ena,
      reset   => reset,
      data_in => din(1),
      dout    => conv_enc_out1
      );

  delayed_proc : process (clk, reset)
  begin  -- process delayed_proc
    if reset = '1' then
      encode_ena_delayed    <= (others => '0');
      encode_done_s_delayed <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        for i in CYCLE_DELAYS_c-1 downto 1 loop
          encode_ena_delayed(i)    <= encode_ena_delayed(i-1);
          encode_done_s_delayed(i) <= encode_done_s_delayed(i-1);
        end loop;  -- i
        encode_ena_delayed(0)    <= encode_ena;
        encode_done_s_delayed(0) <= encode_done_s;
      end if;
    end if;
  end process delayed_proc;

  -- Output: handling tail bits
  dout_proc : process (clk, reset)
  begin  -- process dout_proc
    if reset = '1' then
      dout_s       <= (others => '0');
      dout         <= (others => '0');
      temp_out_reg <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        if encode_state = ENC_INPUT_BITS then
          dout_s(0) <= din(0);
          dout_s(1) <= conv_enc_out0(0);  -- first convolutional encoder output
          dout_s(2) <= conv_enc_out1(0);  -- second convolutional encoder output
          dout      <= dout_s;
        elsif encode_state = ENC_TAIL_BITS then
          if tail_bits_cnt = 0 then
            dout_s(0)       <= conv_enc_out0(1);
            dout_s(1)       <= conv_enc_out0(0);
            dout            <= dout_s;
            temp_out_reg(0) <= conv_enc_out1(1);
            temp_out_reg(1) <= conv_enc_out1(0);
          elsif tail_bits_cnt = 1 then
            dout_s(0)       <= conv_enc_out0(0);
            dout(0)         <= dout_s(0);
            dout(1)         <= dout_s(1);
            dout(2)         <= conv_enc_out0(1);
            temp_out_reg(2) <= conv_enc_out1(1);
            temp_out_reg(3) <= conv_enc_out1(0);
          elsif tail_bits_cnt = 2 then
            dout_s(1) <= conv_enc_out1(0);
            dout_s(2) <= conv_enc_out1(1);
            dout(0)   <= dout_s(0);
            dout(1)   <= conv_enc_out0(1);
            dout(2)   <= conv_enc_out0(0);
          elsif tail_bits_cnt = 3 then
            dout(0) <= temp_out_reg(0);
            dout(1) <= temp_out_reg(1);
            dout(2) <= temp_out_reg(2);
          elsif tail_bits_cnt = 4 then
            dout(0) <= temp_out_reg(3);
            dout(1) <= dout_s(1);
            dout(2) <= dout_s(2);
          end if;
        end if;
      end if;
    end if;
  end process dout_proc;
  
end architecture SYN;
