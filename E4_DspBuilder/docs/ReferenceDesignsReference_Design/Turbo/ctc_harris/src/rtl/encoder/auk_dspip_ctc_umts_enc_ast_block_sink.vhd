-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_ctc_umts_enc_ast_block_sink.vhd,v $
-- $Source: auk_dspip_ctc_umts_enc_ast_block_sink.vhd $
--
-- $Revision: #4 $
-- $Date: 2008/12/19 $
-- Author   :  zpan
--
--
-- ALTERA Confidential and Proprietary
-- Copyright 2009 (c) Altera Corporation
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


entity auk_dspip_ctc_umts_enc_ast_block_sink is
  generic (
    MAX_BLK_SIZE_g : natural := 5114;
    DATAWIDTH_g    : natural := 18
    );
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
    out_blk_size  : out std_logic_vector(FRAME_SIZE_WIDTH_c - 1  downto 0)
    );
end entity auk_dspip_ctc_umts_enc_ast_block_sink;


architecture rtl of auk_dspip_ctc_umts_enc_ast_block_sink is

  type   state_t is (IDLE, RUN, PAUSE_DATA, PAUSE_NO_DATA, WAIT_INPUT, ERROR_STATE);
  signal state      : state_t;
  signal next_state : state_t;


  signal sink_data_shunt     : std_logic_vector(DATAWIDTH_g - 1 downto 0);
  signal sink_sop_shunt      : std_logic;
  signal sink_eop_shunt      : std_logic;
  signal sink_blk_size_shunt : std_logic_vector(log2_ceil(MAX_BLK_SIZE_g)-1 downto 0);

  -- control signals
  signal out_eop_s      : std_logic;
  signal out_sop_s      : std_logic;
  signal out_blk_size_s : std_logic_vector(log2_ceil(MAX_BLK_SIZE_g)-1 downto 0);
  signal sink_ready_s   : std_logic;
  signal out_valid_s    : std_logic;
  signal out_valid_s_reg: std_logic;
  
  --error signals
--  signal got_sop        : std_logic;
  signal out_error_s    : std_logic_vector(1 downto 0);
  signal missing_sop    : std_logic;
--  signal missing_eop    : std_logic;
--  signal unexpected_eop : std_logic;
  signal unexpected_sop : std_logic;
  signal sink_cnt       : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  signal end_cnt        : unsigned(FRAME_SIZE_WIDTH_c-1 downto 0);
  
  signal error_occured : std_logic;
  signal data_available : std_logic_vector(1 downto 0);
  
begin  -- architecture rtl


  -----------------------------------------------------------------------------
  -- assign ouotputs
  -----------------------------------------------------------------------------

  -- control signals
  sink_ready   <= sink_ready_s;
  out_valid    <= out_valid_s;
  out_blk_size <= out_blk_size_s;
  out_error    <= out_error_s when out_valid_s_reg = '1' or error_occured ='1' else (others => '0');
  out_eop      <= out_eop_s and out_valid_s;
  out_sop      <= out_sop_s and out_valid_s;

  -----------------------------------------------------------------------------
  -- state machine to control input irdy/trdy bus with transfer to stall state
  -- when fft frame size changes
  -----------------------------------------------------------------------------
  fsm_reg : process (clk, reset) is
  begin
    if reset = '1' then
      state <= IDLE;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process fsm_reg;


  fsm_cmb : process(sink_sop, out_ready, sink_valid, state) is

  begin  -- process fsm_cmb
    case state is
      when IDLE =>
        next_state <= IDLE;
        if sink_valid = '1' then
         if out_ready = '1' then
          next_state <= RUN;
         end if;
        elsif sink_valid = '0' then
          next_state <= IDLE;
        end if;

      when RUN =>
        next_state <= RUN;
        if sink_valid = '1' then
          if out_ready = '1' then
            next_state <= RUN;
          elsif out_ready = '0' then
            next_state <= PAUSE_DATA;
          end if;
        elsif sink_valid = '0' then
          if out_ready = '0' then
            next_state <= PAUSE_NO_DATA;
          elsif out_ready = '1' then
            next_state <= IDLE;
          end if;
        end if;

      -- output cannot accept data, and no data on input
      when PAUSE_NO_DATA => -- no input data
        next_state <= PAUSE_NO_DATA;
        if sink_valid = '1' then
          if out_ready = '1' then
            next_state <= RUN;
          end if;
        elsif sink_valid = '0' then
          if out_ready = '1' then
            next_state <= IDLE;
          end if;
        end if;
  
     -- output can not accept data, and data on input
     when PAUSE_DATA =>
        next_state <= PAUSE_DATA;
        if sink_valid = '1' then
          if out_ready = '1' then
            next_state <= RUN;
          end if;
        elsif sink_valid = '0' then
          if out_ready = '1' then
            next_state <= WAIT_INPUT;
          end if;
        end if;

      when WAIT_INPUT =>
        next_state <= WAIT_INPUT;
        if sink_valid = '1' then
          if out_ready = '1' then
            next_state <= RUN;
          end if;
        elsif sink_valid = '0' then
          if out_ready = '1' then
            next_state <= IDLE;
          end if;
        end if;
        
      when others =>
        next_state <= IDLE;
        
    end case;
  end process fsm_cmb;


  sink_ready_s <= '1' when out_ready = '1' else
                  '0';

  -- data is registered. The shunt register is required for when the output
  -- stalls as the rdy signal goes low one cycle after (and hence one more
  -- data is transfered)
  shunt_p : process (clk, reset) is
  begin
    if reset = '1' then
      sink_data_shunt     <= (others => '0');
      sink_sop_shunt      <= '0';
      sink_eop_shunt      <= '0';
      sink_blk_size_shunt <= (others => '0');
    elsif rising_edge(clk) then
      if ((state = RUN) and (sink_valid = '0' or out_ready = '0')) then
        sink_data_shunt     <= sink_data;
        sink_sop_shunt      <= sink_sop;
        sink_eop_shunt      <= sink_eop;
        sink_eop_shunt      <= sink_eop;
        sink_blk_size_shunt <= sink_blk_size;
      end if;
    end if;
  end process shunt_p;

  data_available_p : process (clk, reset)
  begin  -- process data_available_p
    if reset = '1' then  
      data_available <= (others => '0');
    elsif rising_edge(clk) then 
      if or_reduce(out_error_s)='1' then
        if sink_sop = '1' and sink_eop= '0' and sink_valid = '1' and sink_ready_s = '1'  then
          data_available <= std_logic_vector(to_unsigned(1, data_available'length));
        else
          data_available <= (others => '0');
        end if;
      elsif sink_valid = '1' and sink_ready_s = '1' then
        if out_valid_s = '1' and out_ready = '1' then
          --stays the same
          data_available <= std_logic_vector(unsigned(data_available));  
        else
          data_available <= std_logic_vector(unsigned(data_available) + 1);  
        end if;
      elsif out_valid_s = '1' and out_ready = '1' then
        data_available <= std_logic_vector(unsigned(data_available) - 1);
      end if;
    end if;
  end process data_available_p;

  out_data_p : process (clk, reset) is
  begin
    if reset = '1' then
      out_data       <= (others => '0');
      out_sop_s      <= '0';
      out_eop_s      <= '0';
      out_blk_size_s <= (others => '0');
    elsif rising_edge(clk) then
      if (sink_valid = '1' and sink_ready_s = '1') then
        if (state = PAUSE_DATA) then
          out_data       <= sink_data_shunt;
          out_sop_s      <= sink_sop_shunt;
          out_eop_s      <= sink_eop_shunt;
          out_blk_size_s <= sink_blk_size_shunt;
        else
          out_data       <= sink_data;
          out_sop_s      <= sink_sop;
          out_eop_s      <= sink_eop;
         out_blk_size_s <= sink_blk_size;
        end if;
      end if;
    end if;
  end process out_data_p;

  out_valid_s <= '1' when unsigned(data_available) /= 0 and or_reduce(out_error_s) = '0' else
    '0';
  proc_out_valid_s_reg : process (clk, reset)
  begin  -- process out_valid_s_reg
    if reset = '1' then  
      out_valid_s_reg <= '0';
    elsif rising_edge(clk) then 
      out_valid_s_reg <= out_valid_s;
    end if;
  end process proc_out_valid_s_reg;
  
  -----------------------------------------------------------------------------
  -- check error counts
  -----------------------------------------------------------------------------

  reg_error_p : process (clk, reset)
  begin
    if reset = '1' then
      out_error_s <= (others => '0');
      error_occured <= '0';
    elsif rising_edge(clk) then
      if out_error_s = "00" then
        if missing_sop = '1' then
          out_error_s <= "01" or sink_error;
          error_occured <= '1';
        elsif sink_valid = '1' and sink_eop = '0' and sink_cnt = end_cnt  and sink_cnt /= 0 then--missing_eop = '1'
          out_error_s <= "10" or sink_error;
          error_occured <= '1';
        elsif (sink_valid = '1' and sink_eop = '1' and sink_cnt /= end_cnt) or --unexpected_eop = '1'
              unexpected_sop='1' then
          out_error_s <= "11" or sink_error;
          error_occured <= '1';
        end if;
     end if;
      if sink_sop = '1' and sink_valid = '1' and sink_ready_s = '1' and unexpected_sop='0' then
        out_error_s <= "00";
      end if;
      if error_occured = '1' then
        error_occured <= '0';
      end if;
    end if;
  end process reg_error_p;

  -- error if get a valid when we dont have an sop.
  missing_sop_p : process (clk, reset)
  begin
    if reset = '1' then
      missing_sop <= '0';
    elsif rising_edge(clk) then
      missing_sop <= '0';
      if sink_valid = '1' and sink_sop = '0' and (sink_cnt = 0 or sink_cnt = unsigned(sink_blk_size) )then
        missing_sop <= '1';
      end if;
    end if;
  end process missing_sop_p;


--  -- error if we get and sop with no eop
--  missing_eop_p : process (clk, reset)
--  begin
--    if reset = '1' then
--      missing_eop <= '0';
--    elsif rising_edge(clk) then
--      missing_eop <= '0';
--      if sink_valid = '1' and sink_eop = '0' and sink_cnt = end_cnt and sink_sop = '0' then
--        missing_eop <= '1';
--      end if;
--    end if;
--  end process missing_eop_p;

--  -- unexpected eop (if received before all blk have been entered)
--  unexpected_eop_p : process (clk, reset)
--  begin
--    if reset = '1' then
--      unexpected_eop <= '0';
--    elsif rising_edge(clk) then
--      unexpected_eop <= '0';
--      if sink_valid = '1' and sink_eop = '1' and sink_cnt /= end_cnt then
--        unexpected_eop <= '1';
--      end if;
--    end if;
--  end process unexpected_eop_p;

  -- unexpected sop (if received before a blk have been fully received)
  unexpected_sop_p : process (clk, reset)
  begin
    if reset = '1' then
      unexpected_sop <= '0';
    elsif rising_edge(clk) then
      unexpected_sop <= '0';
      if sink_valid = '1' and sink_sop = '1' and sink_cnt > 0 and sink_cnt < unsigned(sink_blk_size) then
        unexpected_sop <= '1';
      end if;
    end if;
  end process unexpected_sop_p;
  
  sink_cnt_p : process (clk, reset)
  begin
    if reset = '1' then
      sink_cnt <= to_unsigned(0,FRAME_SIZE_WIDTH_c);
    elsif rising_edge(clk) then
      if sink_valid = '1' and sink_ready_s = '1' then
        if  (sink_eop = '1' and sink_cnt = end_cnt) then  --(sink_cnt = end_cnt and sink_sop = '0') or
          sink_cnt <= to_unsigned(0,FRAME_SIZE_WIDTH_c);
        elsif sink_eop = '1' and sink_cnt < end_cnt then
          sink_cnt <= unsigned(sink_blk_size);
        elsif sink_sop = '1'  then
          sink_cnt <= to_unsigned(1,FRAME_SIZE_WIDTH_c);
        elsif sink_cnt <= end_cnt then
          sink_cnt <= sink_cnt + 1;
        end if;
      end if;
    end if;
  end process sink_cnt_p;

  end_cnt_p : process (clk, reset)
  begin  -- process end_cnt_p
    if reset = '1' then
      end_cnt <= to_unsigned(0, FRAME_SIZE_WIDTH_c);
    elsif rising_edge(clk) then
      if sink_valid = '1' and sink_sop = '1' and sink_ready_s = '1' then
        end_cnt <= unsigned(sink_blk_size) - 1;
      end if;
    end if;
  end process end_cnt_p;

end architecture rtl;
