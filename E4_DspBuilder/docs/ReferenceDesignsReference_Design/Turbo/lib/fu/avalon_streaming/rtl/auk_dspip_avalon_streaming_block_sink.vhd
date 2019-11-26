-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_avalon_streaming_block_sink.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/fu/avalon_streaming/rtl/auk_dspip_avalon_streaming_block_sink.vhd,v $
--
-- $Revision: 1.1 $
-- $Date: 2007/09/26 10:22:33 $
-- Check in by     : $Author: kmarks $
-- Author   :  kmarks
--
-- Project      :  auk_dspip_r22sdf
--
-- Description : 
--                prev fft frame                       new fft frame
--              |--------------------| <---delay--> |-----------------|
--              <---delay-->|----------------------|       |---------------|
--
-- This unit inserts a stall between blocks (only for the first stage) when
-- the fft frame size changes. This ensures that there is no overlap between
-- the fft output and the fft input of the next frame. This is done to
-- simplify the logic required for controlling each stage.
--
-- delay = previous fft block size - fft new block.
--
-- If the frame size remains the same there is no need to insert the delay
--
-- $Log: auk_dspip_avalon_streaming_block_sink.vhd,v $
-- Revision 1.1  2007/09/26 10:22:33  kmarks
-- added block based avalon streaming modules (was FFT avalon streaming)
--
-- Revision 1.8  2007/02/02 18:09:25  kmarks
-- added -N/2 to N/2 to the input orders
--
-- Revision 1.7  2007/01/29 10:21:35  kmarks
-- ready high by default
--
-- Revision 1.6  2006/12/05 10:54:44  kmarks
-- updated from the 6.1 branch
--
-- Revision 1.5.2.3  2006/10/31 14:19:41  kmarks
-- SPR223918
--
-- Revision 1.5.2.2  2006/10/04 14:26:40  kmarks
-- *** empty log message ***
--
-- Revision 1.5.2.1  2006/09/28 16:47:29  kmarks
-- fmax improvements SPR 219316
--
-- Revision 1.5  2006/09/06 14:39:39  kmarks
-- added global clock enable and error ports to atlantic interfaces. Added checkbox on GUI for Global clock enable . Some bug fixed for the new architecture.
--
-- Revision 1.4  2006/08/24 12:49:28  kmarks
-- various bug fixes and added bit reversal.
--
-- Revision 1.3  2006/08/14 12:08:36  kmarks
-- *** empty log message ***
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


entity auk_dspip_avalon_streaming_block_sink is
  generic (
    MAX_BLK_g : natural := 1024;
    STALL_g      : natural := 1;
    DATAWIDTH_g  : natural := 18;
    -- this generic is specific for the FFT.
    NUM_STAGES_g : natural := 2
     );
  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    in_blk      : in  std_logic_vector(log2_ceil(MAX_BLK_g) downto 0);
    in_sop         : in  std_logic;
    in_eop         : in  std_logic;
    in_inverse     : in  std_logic;
    sink_valid     : in  std_logic;
    sink_ready     : out std_logic;
    source_stall   : in  std_logic;
    in_data        : in  std_logic_vector(DATAWIDTH_g - 1 downto 0);
    processing     : in  std_logic;
    in_error       : in  std_logic_vector(1 downto 0);
    out_error      : out std_logic_vector(1 downto 0);
    out_valid      : out std_logic;
    out_sop        : out std_logic;
    out_eop        : out std_logic;
    out_data       : out std_logic_vector(DATAWIDTH_g - 1 downto 0);
    curr_blk       : out std_logic_vector(log2_ceil(MAX_BLK_g) downto 0);
    -- these are specific to the FFT, no effort has been made to optimize! 
    curr_pwr_2     : out std_logic;
    curr_inverse   : out std_logic;
    curr_input_sel : out std_logic_vector(NUM_STAGES_g - 1 downto 0)
    );
end entity auk_dspip_avalon_streaming_block_sink;


architecture rtl of auk_dspip_avalon_streaming_block_sink is

  constant MAX_PWR_2_c : natural := log2_ceil(MAX_BLK_g) rem 2;

  type   state_t is (S1, S2, S3, S4, S5, ERROR_STATE, FLUSH);
  signal state      : state_t;
  signal next_state : state_t;


  signal in_data_shunt : std_logic_vector(DATAWIDTH_g - 1 downto 0);
  signal in_sop_shunt  : std_logic;
  signal in_eop_shunt  : std_logic;

  -- stall signals

  signal stall_s     : std_logic;
  signal stall_int   : std_logic;
  signal stalled     : std_logic;
  signal stall_delay : natural range 0 to MAX_BLK_g;

  --
  signal curr_input_sel_s : std_logic_vector(NUM_STAGES_g - 1 downto 0);
  signal curr_pwr_2_s     : std_logic;
  signal curr_blk_s    : std_logic_vector(log2_ceil(MAX_BLK_g) downto 0);
  signal curr_inverse_s   : std_logic;


  signal blk_shunt    : std_logic_vector(log2_ceil(MAX_BLK_g) downto 0);
  signal pwr_2_shunt     : std_logic;
  signal input_sel_shunt : std_logic_vector(NUM_STAGES_g - 1 downto 0);
  signal inverse_shunt   : std_logic;

  signal stg_input_sel   : std_logic_vector(NUM_STAGES_g - 1 downto 0);
  signal in_blk_pwr_2 : std_logic_vector(log2_ceil(MAX_BLK_g) downto 0);
  signal in_pwr_2        : std_logic;

  -- control signals
  signal sink_ready_s : std_logic;
  signal out_valid_s  : std_logic;

  signal out_trdy : std_logic;

  --error signals
  signal got_sop        : std_logic;
  signal got_eop        : std_logic;
  signal out_error_s    : std_logic_vector(1 downto 0);
  signal missing_sop    : std_logic;
  signal missing_eop    : std_logic;
  signal unexpected_eop : std_logic;
  signal unexpected_sop : std_logic;
  signal cnt            : natural range 0 to MAX_BLK_g -1;
  signal in_cnt         : natural range 0 to MAX_BLK_g-1;
  signal out_eop_s      : std_logic;
  signal out_sop_s      : std_logic;
  signal start          : std_logic;
begin  -- architecture rtl


  -----------------------------------------------------------------------------
  -- assign ouotputs
  -----------------------------------------------------------------------------

  -- control signals
  sink_ready     <= sink_ready_s;
  out_valid      <= out_valid_s;
  curr_pwr_2     <= curr_pwr_2_s;
  curr_blk    <= curr_blk_s;
  curr_inverse   <= curr_inverse_s;
  curr_input_sel <= curr_input_sel_s;
  out_error      <= out_error_s;
  out_eop        <= out_eop_s;
  out_sop        <= out_sop_s;

  -----------------------------------------------------------------------------
  -- state machine to control input irdy/trdy bus with transfer to stall state
  -- when fft frame size changes
  -----------------------------------------------------------------------------
  fsm_reg : process (clk, reset) is
  begin
    if reset = '1' then
      state <= S1;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process fsm_reg;

  out_trdy <= not (source_stall);

  fsm_cmb : process(cnt, curr_blk_s, in_sop, out_trdy,
                    processing, sink_valid, stall_delay, stall_s, stalled,
                    state) is

  begin  -- process fsm_cmb
    case state is
      when S1 =>
        next_state <= S1;
        if sink_valid = '1' then
          if in_sop = '1' and stall_s = '1' and stall_delay > 0 and out_trdy = '1'then
            next_state <= S5;
            -- elsif out_trdy = '1' then
            --    next_state <=  S0;
          else
            next_state <= S2;
          end if;
        elsif sink_valid = '0' then
          next_state <= S1;
        end if;

      when S2 =>
        next_state <= S2;
        if sink_valid = '1' then
          if in_sop = '1' and stall_s = '1' and stall_delay > 0 and out_trdy = '1' then
            next_state <= S5;
          elsif out_trdy = '1' then
            next_state <= S2;
          elsif out_trdy = '0' then
            next_state <= S3;
          end if;
        elsif sink_valid = '0' then
          if out_trdy = '0' then
            next_state <= S1;
          elsif out_trdy = '1' then
            next_state <= S1;
          end if;
        end if;

      when S3 =>
        next_state <= S3;
        if sink_valid = '1' then
          if in_sop = '1' and stall_s = '1' and stall_delay > 0 and out_trdy = '1' then
            next_state <= S5;
          elsif out_trdy = '1' then
            if stalled = '1' then
              --next_state <= S4;
              next_state <= S5;
            else
              next_state <= S2;
            end if;
          end if;
        elsif sink_valid = '0' then
          if out_trdy = '1' then
            next_state <= S4;
          end if;
        end if;

      when S4 =>
        next_state <= S4;
        if sink_valid = '1' then
          if out_trdy = '1' then
            next_state <= S2;
            -- else
            --   next_state <=  S1;
          end if;
        elsif sink_valid = '0' then
          if out_trdy = '1' then
            next_state <= S1;
          end if;
        end if;
        
      when S5 =>
        next_state <= S5;
        if processing = '0' then
          if sink_valid = '1' then
            if out_trdy = '1' then
              next_state <= S1;
            elsif out_trdy = '0' then
              -- this should not ever happen as the stall delay will be >16 so we
              -- should not be ending data out when in this state.
              next_state <= S5;
            end if;
          elsif sink_valid = '0' then
            --still can send out the sop
            next_state <= S4;
          end if;
        end if;
        
      when others =>
        next_state <= S1;
        
    end case;
  end process fsm_cmb;


  sink_ready_s <= '1' when source_stall = '0' and (state = S1 or state = S2 or state = S3 or state = ERROR_STATE or
                                                   (sink_valid = '1' and state = S4)) else 
                  '0';

  out_sop_s <= '1' when cnt = 0 else
               '0';
  out_eop_s <= '1' when cnt = unsigned(curr_blk_s) - 1 else
               '0';

  -- data is registered. The shunt register is required for when the output
  -- stalls as the trdy signal goes low one cycle after (and hence one more
  -- data is transfered)
  shunt_p : process (clk, reset) is
  begin
    if reset = '1' then
      in_data_shunt <= (others => '0');
     elsif rising_edge(clk) then
      if ((state = S2) and (sink_valid = '0' or out_trdy = '0')) or
        ((state = S1 or state = S2) and stall_s = '1') then
        in_data_shunt <= in_data;
      end if;
    end if;
  end process shunt_p;

  out_data_p : process (clk, reset) is
  begin
    if reset = '1' then
      out_data <= (others => '0');
    elsif rising_edge(clk) then
      if (sink_valid = '1' and sink_ready_s = '1') then
        if (state = S3) or
          (state = S5 and processing = '0') then
          out_data <= in_data_shunt;
        else
          out_data <= in_data;
        end if;
      end if;
    end if;
  end process out_data_p;

  out_valid_p : process (clk, reset)
  begin  -- process out_valid_p
    if reset = '1' then
      out_valid_s <= '0';
    elsif rising_edge(clk) then
      if(sink_valid = '1' and source_stall = '0' and
         ((state = S1 and not(in_sop = '1' and sink_ready_s = '1' and stall_s = '1')) or
          (state = S5 and processing = '0') or
          ((state = S2 or state = S3) and stall_s = '0')))
        or (state = S4 and stall_s = '0')
      then
        out_valid_s <= '1' and (got_sop or in_sop);  --dont send data if
                                                     --havent got sop
      else
        
        out_valid_s <= '0';
      end if;
    end if;
  end process out_valid_p;


  -----------------------------------------------------------------------------
  -- check error counts
  -----------------------------------------------------------------------------

  reg_error_p : process (clk, reset)
  begin  -- process reg_error_s
    if reset = '1' then
      out_error_s <= (others => '0');
    elsif rising_edge(clk) then
      out_error_s <= (others => '0');
      if missing_sop = '1' then
        out_error_s <= "01" or in_error;
      elsif missing_eop = '1' then
        out_error_s <= "10" or in_error;
      elsif unexpected_eop = '1' then
        out_error_s <= "11" or in_error;
      end if;

    end if;
  end process reg_error_p;

  got_sop_p : process (clk, reset)
  begin  -- process got_sop
    if reset = '1' then
      got_sop <= '0';
    elsif rising_edge(clk) then
      if sink_valid = '1' and sink_ready_s = '1' and in_sop = '1' then
        got_sop <= '1';
      end if;
      if sink_valid = '1' and sink_ready_s = '1' and in_cnt = unsigned(curr_blk_s) - 1 then
        got_sop <= '0';
      end if;
    end if;
  end process got_sop_p;


  -- error if get a valid when we dont have an sop.
  missing_sop_p : process (clk, reset)
  begin  -- process missing_sop
    if reset = '1' then
      missing_sop <= '0';
    elsif rising_edge(clk) then
      missing_sop <= '0';
      if sink_valid = '1' and in_sop = '0' and in_cnt = 0 then
        missing_sop <= '1';
      end if;
    end if;
  end process missing_sop_p;


  -- error if we get and sop with no eop
  missing_eop_p : process (clk, reset)
  begin  -- process missing_eop_p
    if reset = '1' then
      missing_eop <= '0';
    elsif rising_edge(clk) then
      missing_eop <= '0';
      if sink_valid = '1' and in_eop = '0' and in_cnt = unsigned(curr_blk_s) - 1 then
        missing_eop <= '1';
      end if;
    end if;
  end process missing_eop_p;

  -- unexpected eop (if received before all blk have been entered)
  unexpected_eop_p : process (clk, reset)
  begin  -- process unexpected_eop_p
    if reset = '1' then
      unexpected_eop <= '0';
    elsif rising_edge(clk) then
      unexpected_eop <= '0';
      if sink_valid = '1' and in_eop = '1' and in_cnt /= unsigned(curr_blk_s) - 1 then
        unexpected_eop <= '1';
      end if;
    end if;
  end process unexpected_eop_p;

  in_cnt_p : process (clk, reset)
  begin  -- process cnt_p
    if reset = '1' then
      in_cnt <= 0;
    elsif rising_edge(clk) then
      if sink_valid = '1' and sink_ready_s = '1' then
        if (in_cnt = unsigned(curr_blk_s) - 1) or
          in_cnt = MAX_BLK_g - 1 then
          in_cnt <= 0;
        else
          in_cnt <= in_cnt + 1;
        end if;
      end if;
    end if;
  end process in_cnt_p;

  cnt_p : process (clk, reset)
  begin  -- process cnt_p
    if reset = '1' then
      cnt <= 0;
    elsif rising_edge(clk) then
      if out_valid_s = '1' then
        if (cnt = unsigned(curr_blk_s) - 1) then
          cnt <= 0;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process cnt_p;

  ------------------------------------------------------------------------------
-- shunt 
-------------------------------------------------------------------------------
  shunt_control : process (clk, reset) is
  begin
    if reset = '1' then
      blk_shunt    <= (others => '0');
      pwr_2_shunt     <= '0';
      input_sel_shunt <= (others => '0');
      inverse_shunt   <= '0';
    elsif rising_edge(clk) then
      if in_sop = '1' and sink_valid = '1' and stall_s = '1' then
        blk_shunt    <= in_blk;
        pwr_2_shunt     <= in_pwr_2;
        input_sel_shunt <= stg_input_sel;
        inverse_shunt   <= in_inverse;
      end if;
    end if;

  end process shunt_control;

-----------------------------------------------------------------------------
-- current blk
-----------------------------------------------------------------------------
  curr_blk_p : process (clk, reset)
  begin
    if reset = '1' then
      curr_blk_s <= (others => '0');
    elsif rising_edge(clk) then
      if in_sop = '1' and sink_valid = '1' and sink_ready_s = '1' and
        (stall_s = '0' or (stall_s = '1' and stall_delay = 0)) then
        curr_blk_s <= in_blk;
      elsif state = S5 and processing = '0' then
        curr_blk_s <= blk_shunt;
      end if;
    end if;
  end process curr_blk_p;
-----------------------------------------------------------------------------
-- current inverse
-----------------------------------------------------------------------------
  curr_inverse_p : process (clk, reset)
  begin
    if reset = '1' then
      curr_inverse_s <= '0';
    elsif rising_edge(clk) then
      if in_sop = '1' and sink_valid = '1' and sink_ready_s = '1' and
        (stall_s = '0' or (stall_s = '1' and stall_delay = 0)) then
        curr_inverse_s <= in_inverse;
      elsif state = S5 and processing = '0' then
        curr_inverse_s <= inverse_shunt;
      end if;
    end if;
  end process curr_inverse_p;

-----------------------------------------------------------------------------
-- stage input sel
-----------------------------------------------------------------------------
-- input sel controls the flow of data from the input throught the
-- appropriate number of stages for the number of blk.
  gen_input_sel_p : process (in_blk)
  begin
    stg_input_sel <= (others => '0');
    for i in (NUM_STAGES_g*2 - MAX_PWR_2_c) downto 1 loop
      if (i mod 2) = 0 then
        if in_blk(i) = '1' then
          stg_input_sel(NUM_STAGES_g - (i)/2 - MAX_PWR_2_c) <= '1';
        end if;
      else
        if in_blk(i) = '1' then
          stg_input_sel(NUM_STAGES_g - (i)/2 - 1) <= '1';
        end if;
      end if;
    end loop;
  end process;

-- save the value of this for the duration of the input
  stg_input_sel_int_p : process (clk, reset)
  begin
    if reset = '1' then
      curr_input_sel_s <= (others => '0');
    elsif rising_edge(clk) then
      if in_sop = '1' and sink_valid = '1' and sink_ready_s = '1' and
        (stall_s = '0' or (stall_delay = 0 and stall_s = '1')) then
        curr_input_sel_s <= stg_input_sel;
      elsif state = S5 and processing = '0' then
        curr_input_sel_s <= input_sel_shunt;
      end if;
      
    end if;
  end process stg_input_sel_int_p;

-----------------------------------------------------------------------------
-- radix 2 control
-----------------------------------------------------------------------------
-- determine if the in_blk is a pwr of 2.
  in_pwr_2_p : process (in_blk)
  begin
    in_blk_pwr_2 <= (others => '0');
    for i in 0 to (log2_ceil(MAX_BLK_g) + MAX_PWR_2_c) - 1 loop
      if (i mod 2) = 1 then
        if in_blk(i) = '1' then
          in_blk_pwr_2(i/2) <= '1';
        else
          in_blk_pwr_2(i/2) <= '0';
        end if;
      end if;
    end loop;
  end process in_pwr_2_p;

  in_pwr_2 <= or_reduce(in_blk_pwr_2);


  pwr_2_p : process (clk, reset)
  begin  -- process radix_2_p
    if reset = '1' then
      curr_pwr_2_s <= '0';
    elsif rising_edge(clk) then
      if in_sop = '1' and sink_valid = '1' and sink_ready_s = '1' and
        (stall_s = '0' or (stall_delay = 0 and stall_s = '1'))then
        curr_pwr_2_s <= in_pwr_2;
      elsif state = S5 and processing = '0' then
        curr_pwr_2_s <= pwr_2_shunt;
      end if;
    end if;
  end process pwr_2_p;
-----------------------------------------------------------------------------
-- stall control
----------------------------------------------------------------------------

  gen_no_stall : if STALL_g = 0 generate
    stall_delay <= 0;
    stall_s     <= '0';
    stall_int <= '0';
  end generate gen_no_stall;

  gen_stall : if STALL_g = 1 generate

    -- stall delay is 0 when the incoming fft is larger than the current fft 
    stall_delay <= to_integer(unsigned(curr_blk_s));

    -- want to stall on first sop, so data first data not accepted.
    stall_s <= '1' when in_sop = '1' and sink_valid = '1' and processing = '1' and unsigned(in_blk) /= unsigned(curr_blk_s) and start = '0' else
               '0';

    gen_stall_p : process (clk, reset)
    begin
      if reset = '1' then
        stall_int <= '0';
      elsif rising_edge(clk) then
        -- in the case when curr_blk_s = 0 (ie at start) stall will not occur
        -- as it is reset here.
        if stall_int = '1' and processing = '0' then
          stall_int <= '0';
        elsif in_sop = '1' and sink_valid = '1' and
          (unsigned(in_blk) /= unsigned(curr_blk_s) and start = '0')  --unsigned(curr_fftpts_s) /= 0)
        then
          stall_int <= '1';
        end if;
      end if;
    end process gen_stall_p;

  end generate gen_stall;

  stalled_p : process (clk, reset)
  begin  -- process stalled_p
    if reset = '1' then
      stalled <= '0';
    elsif rising_edge(clk) then
      if stall_s = '1' and sink_valid = '1' and sink_ready_s = '1' then
        stalled <= '1';
      end if;
      if stall_s = '0' then
        stalled <= '0';
      end if;
    end if;
  end process stalled_p;

  -----------------------------------------------------------------------------
  

  start_p : process (clk, reset)
  begin  -- process start_p
    if reset = '1' then
      start <= '1';
    elsif rising_edge(clk) then
      if out_valid_s = '1' then
        start <= '0';
      end if;
    end if;
  end process start_p;







end architecture rtl;
