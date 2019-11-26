-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_atlantic_sink.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/fu/atlantic/rtl/auk_dspip_atlantic_sink.vhd,v $
--
-- $Revision: 1.13 $
-- $Date: 2006/08/11 14:49:39 $
-- Check in by     : $Author: sdemirso $
-- Author   :  Suleyman S. Demirsoy
--
-- Project      :  Atlantic II Sink Interface with ready_latency=0
--
-- Description : 
--
-- This interface is capable of handling single or multi channel streams as
-- well as blocks of data. The at_sink_sop and at_sink_eop must be fed as
-- described in the Atlantic II specification. The at_sink_error input is a 2-
-- bit signal that complies with the PFC error format (by Kent Orthner). The
-- error checking is extensively done, however the resulting information is
-- still mapped on the available 3 error states as shown below.
-- 00: no error
-- 01: missing sop
-- 10: missing eop
-- 11: unexpected eop
-- other types of errors also marked as 11. 
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity auk_dspip_atlantic_sink is

  generic(
    WIDTH           : integer := 16;
    PACKET_SIZE     : natural := 4;
    log2packet_size : integer := 2
    );
  port(
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    ----------------- DESIGN SIDE SIGNALS
    data_available  : out std_logic;    --goes high when new data is available
    data            : out std_logic_vector(WIDTH-1 downto 0);
    sink_ready_ctrl : in  std_logic;    --the controller will tell
                                        --the interface whether
                                        --new input can be accepted.
    sink_stall      : out std_logic;    --needs to stall the design
                                        --if no new data is coming
    packet_error    : out std_logic_vector (1 downto 0);  --this is for SOP and EOP check only.
                                        --when any of these doesn't behave as
                                        --expected, the error is flagged.
    send_sop        : out std_logic;    -- transmit SOP signal to the design.
                                        -- It only transmits the legal SOP.
    send_eop        : out std_logic;    -- transmit EOP signal to the design.
                                        -- It only transmits the legal EOP.    
    ----------------- ATLANTIC SIDE SIGNALS
    at_sink_ready   : out std_logic;    --it will be '1' whenever the
                                        --sink_ready_ctrl signal is high.
    at_sink_valid   : in  std_logic;
    at_sink_data    : in  std_logic_vector(WIDTH-1 downto 0);
    at_sink_sop     : in  std_logic := '0';
    at_sink_eop     : in  std_logic := '0';
    at_sink_error   : in  std_logic_vector(1 downto 0)  --it indicates to the data source
                                        --that the SOP and EOP signals
                                        --are not received as expected.

    );

end auk_dspip_atlantic_sink;

-- hds interface_end
architecture rtl of auk_dspip_atlantic_sink is

  type state_type is (start, stall0,  wait1, stall, run1, st_err, end1);

  signal sink_state, sink_next_state : state_type;
  signal data_take                   : std_logic;
  signal data_available_s            : std_logic;
  signal data_available_int          : std_logic;
  signal reset_count, count_enable   : std_logic;
  signal count                       : unsigned(log2packet_size-1 downto 0);
  signal count_finished              : boolean;
  signal at_sink_error_int           : std_logic;
  signal packet_error0               : std_logic;
  signal packet_error_int            : std_logic_vector (1 downto 0);
  signal send_sop_int                : std_logic;
  signal send_eop_int : std_logic;

begin

  valid_generate_single : if packet_size = 1 generate
    at_sink_error_int <= at_sink_error(0);
    packet_error_int  <= '0' & packet_error0;

    at_sink_ready <= '1' when (sink_state /= st_err and sink_ready_ctrl = '1' and reset_n ='1') else
                              --sink_next_state = st_err or sink_ready_ctrl = '1' else
                              -- (sink_ready_ctrl = '1' and at_sink_valid = '1')              else
                                  '0';
    data_take <= '1' when (sink_ready_ctrl = '1' and at_sink_valid = '1') else
                                  '0';
    packet_error0 <= '0' when at_sink_error_int = '0' and sink_next_state /= st_err else
                                  '1';

    send_sop_int <= '0';
    send_eop_int <= '0';
    data_avail_gen : process (sink_ready_ctrl, at_sink_valid,
                              at_sink_error_int, data_available_s)
    begin  -- process data_avail_gen
      if at_sink_error_int = '1' then
        data_available_int <= '0';
      else
        if sink_ready_ctrl = '0' then
          data_available_int <= data_available_s;
        else
          if sink_ready_ctrl = '1' and at_sink_valid = '0' then
            data_available_int <= '0';
          elsif sink_ready_ctrl = '1' and at_sink_valid = '1' then
            data_available_int <= '1';
          else
            data_available_int <= '0';
          end if;
        end if;
      end if;
    end process data_avail_gen;

    sink_comb_update_1 : process (sink_state, sink_ready_ctrl,
                                  at_sink_valid, at_sink_error_int, data_available_s)
    begin  -- process sink_comb_update_1
      case sink_state is
        when start =>
          sink_stall <= '0';

          if at_sink_error_int = '1' then
            sink_next_state <= st_err;
          else
            if sink_ready_ctrl = '0' and at_sink_valid = '0' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '0' and at_sink_valid = '1' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '0' then
              sink_next_state <= stall;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '1' then
              sink_next_state <= run1;
            else
              sink_next_state <= st_err;
            end if;
          end if;
        when stall =>
          sink_stall <= '1';

          if at_sink_error_int = '1' then
            sink_next_state <= st_err;
          else
            if sink_ready_ctrl = '0' and at_sink_valid = '0' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '0' and at_sink_valid = '1' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '0' then
              sink_next_state <= stall;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '1' then
              sink_next_state <= run1;
            else
              sink_next_state <= st_err;
            end if;
          end if;

        when run1 =>
          sink_stall <= '0';

          if at_sink_error_int = '1' then
            sink_next_state <= st_err;
          else
            if sink_ready_ctrl = '0' and at_sink_valid = '0' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '0' and at_sink_valid = '1' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '0' then
              sink_next_state <= stall;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '1' then
              sink_next_state <= run1;
            else
              sink_next_state <= st_err;
            end if;
          end if;

        when st_err =>
          sink_stall <= '0';

          if at_sink_error_int = '1' then
            sink_next_state <= st_err;
          else
            if sink_ready_ctrl = '0' and at_sink_valid = '0' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '0' and at_sink_valid = '1' then
              sink_next_state <= start;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '0' then
              sink_next_state <= stall;
            elsif sink_ready_ctrl = '1' and at_sink_valid = '1' then
              sink_next_state <= run1;
            else
              sink_next_state <= st_err;
            end if;
          end if;

        when others =>
          sink_stall      <= '0';
          sink_next_state <= st_err;
      end case;
    end process sink_comb_update_1;

  end generate valid_generate_single;

  valid_generate_mult : if packet_size > 1 generate

    at_sink_error_int <= at_sink_error(1) or at_sink_error(0);

    send_sop_int      <= '1' when (sink_state = start or sink_state = end1 or sink_state = stall0) and sink_next_state = run1 else
                    '0';
    send_eop_int      <= '1' when (sink_state = stall or sink_state = run1 or sink_state = wait1) and sink_next_state = end1 else
                         '0';
    at_sink_ready <= '1' when (sink_ready_ctrl = '1' and sink_state /= st_err and reset_n = '1') else
                     '0';
    count_enable <= '1' when (sink_next_state = run1 or sink_next_state = end1) else
                    '0';
    reset_count <= '1' when sink_state = st_err else
                   '0';
    data_take <= '1' when sink_next_state = run1 or sink_next_state = end1 or
                          ((sink_state = run1 or sink_state = end1)and sink_ready_ctrl='1') or
                          (sink_state = stall and count_finished and at_sink_valid = '1')   else
                 '0';
    
    sink_comb_update_2 : process (sink_state, sink_ready_ctrl, at_sink_valid,
                                  at_sink_error, at_sink_error_int, at_sink_sop,
                                  at_sink_eop, count, count_finished, data_available_s)
    begin  -- process sink_comb_update_2
      case sink_state is
        when start =>
          sink_stall <= '0';
          
          if at_sink_error_int = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= at_sink_error;
          else
            if sink_ready_ctrl = '1' and at_sink_valid = '1' and at_sink_sop = '1' then
              sink_next_state    <= run1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif (at_sink_valid = '1' and at_sink_sop = '0') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "01";
            elsif at_sink_valid = '0' and sink_ready_ctrl = '1' then
              sink_next_state <= stall0;
              data_available_int <= '0';
              packet_error_int   <= "00";              
            else
              sink_next_state    <= start;
              data_available_int <= '0';
              packet_error_int   <= "00";
            end if;
          end if;
        when stall0 =>
          sink_stall <= '1';
          
          if at_sink_error_int = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= at_sink_error;
          else
            if sink_ready_ctrl = '1' and at_sink_valid = '1' and at_sink_sop = '1' then
              sink_next_state    <= run1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif (at_sink_valid = '1' and at_sink_sop = '0') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "01";
            elsif at_sink_valid = '0' and sink_ready_ctrl = '1' then
              sink_next_state <= stall0;
              data_available_int <= '0';
              packet_error_int   <= "00";        
            else
              sink_next_state    <= start;
              data_available_int <= '0';
              packet_error_int   <= "00";
            end if;
          end if;
          
        when run1 =>
          sink_stall  <= '0';
          
          if at_sink_error_int = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= at_sink_error;
          elsif at_sink_sop = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= "01";
          else
            if at_sink_eop = '0' and count_finished = false and at_sink_valid = '1' and sink_ready_ctrl = '1' then
              sink_next_state    <= run1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif at_sink_eop = '1' and count_finished = true and at_sink_valid = '1' and sink_ready_ctrl = '1' then
              sink_next_state    <= end1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif (count_finished = true and at_sink_valid = '0' and sink_ready_ctrl = '1') or
              (at_sink_eop = '0' and at_sink_valid = '0' and sink_ready_ctrl = '1') then
              sink_next_state    <= stall;
              data_available_int <= '0';
              packet_error_int   <= "00";
            elsif (count_finished = true and sink_ready_ctrl = '0') or (at_sink_eop = '0' and sink_ready_ctrl = '0') then
              sink_next_state    <= wait1;
              data_available_int <= data_available_s;
              packet_error_int   <= "00";
            elsif (count_finished = false and at_sink_eop = '1') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "11";
            elsif (count_finished = true and at_sink_eop = '0' and at_sink_valid = '1' and sink_ready_ctrl = '1') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "10";
            else
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "11";
            end if;
          end if;
        when wait1 =>
          sink_stall  <= '0';
          
          if at_sink_error_int = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= at_sink_error;
          elsif at_sink_sop = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= "01";
          else
            if at_sink_eop = '0' and count_finished = false and at_sink_valid = '1' and sink_ready_ctrl = '1' then
              sink_next_state    <= run1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif at_sink_eop = '1' and count_finished = true and at_sink_valid = '1' and sink_ready_ctrl = '1' then
              sink_next_state    <= end1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif (count_finished = true and at_sink_valid = '0' and sink_ready_ctrl = '1') or
              (at_sink_eop = '0' and at_sink_valid = '0' and sink_ready_ctrl = '1') then
              sink_next_state    <= stall;
              data_available_int <= '0';
              packet_error_int   <= "00";
            elsif (count_finished = true and sink_ready_ctrl = '0') or (at_sink_eop = '0' and sink_ready_ctrl = '0') then
              sink_next_state    <= wait1;
              data_available_int <= data_available_s;
              packet_error_int   <= "00";
            elsif (count_finished = false and at_sink_eop = '1') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "11";
            elsif (count_finished = true and at_sink_eop = '0' and at_sink_valid = '1' and sink_ready_ctrl = '1') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "10";
            else
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "11";
            end if;
          end if;
        when stall =>
          sink_stall  <= '1';
          
          if at_sink_error_int = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= at_sink_error;
          elsif at_sink_sop = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= "01";
          else
            if at_sink_eop = '0' and count_finished = false and at_sink_valid = '1' and sink_ready_ctrl = '1' then
              sink_next_state    <= run1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif at_sink_eop = '1' and count_finished = true and at_sink_valid = '1' and sink_ready_ctrl = '1' then
              sink_next_state    <= end1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif (count_finished = true and at_sink_valid = '0') or -- and sink_ready_ctrl = '1') or
                  (at_sink_valid = '0' and sink_ready_ctrl = '1') then
              sink_next_state    <= stall;
              data_available_int <= '0';
              packet_error_int   <= "00";
            elsif (count_finished = true and sink_ready_ctrl = '0') or (at_sink_eop = '0' and sink_ready_ctrl = '0') then
              sink_next_state    <= wait1;
              data_available_int <= data_available_s;
              packet_error_int   <= "00";
            elsif (count_finished = false and at_sink_eop = '1') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "11";
            elsif (count_finished = true and at_sink_eop = '0' and at_sink_valid = '1' and sink_ready_ctrl = '1') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "10";
            else
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "11";
            end if;
          end if;

        when end1 =>
          sink_stall <= '0';
          
          if at_sink_error_int = '1' then
            sink_next_state    <= st_err;
            data_available_int <= '0';
            packet_error_int   <= at_sink_error;
          else
            if sink_ready_ctrl = '1' and at_sink_valid = '1' and at_sink_sop = '1' then
              sink_next_state    <= run1;
              data_available_int <= '1';
              packet_error_int   <= "00";
            elsif (at_sink_valid = '1' and at_sink_sop = '0') or (at_sink_valid = '0' and at_sink_sop = '1') then
              sink_next_state    <= st_err;
              data_available_int <= '0';
              packet_error_int   <= "01";
            elsif at_sink_valid = '0' and sink_ready_ctrl = '1' then
              sink_next_state <= stall0;
              data_available_int <= '0';
              packet_error_int   <= "00";        
            else
              sink_next_state    <= start;
              data_available_int <= '0';
              packet_error_int   <= "00";
            end if;
          end if;
        when st_err =>
          sink_stall         <= '0';
          data_available_int <= '0';

          if at_sink_error_int = '1' then
            sink_next_state  <= st_err;
            packet_error_int <= at_sink_error;
          else
            sink_next_state  <= start;
            packet_error_int <= "00";
          end if;
        when others => null;
      end case;
    end process sink_comb_update_2;

    counter : process (clk, reset_n)
    begin  -- process counter
      if reset_n = '0' then
        count <= (others => '0');
      elsif clk'event and clk = '1' then  -- rising clock edge
        if reset_count = '1' then
          count <= (others => '0');
        else
          if count_enable = '1' then
            if count < packet_size then
              count <= count + 1;
            else
              count <= (others => '0');                
            end if;
            
          end if;
        end if;
      end if;
    end process counter;

    count_finished <= true when count = (packet_size-1) else 
                      false;

  end generate valid_generate_mult;

  sink_update : process (clk, reset_n)
  begin  -- process
    if reset_n = '0' then
      sink_state <= start;
    elsif clk'event and clk = '1' then
      sink_state <= sink_next_state;
    end if;

  end process sink_update;

  data_register : process (clk, reset_n)
  begin  -- process
    if reset_n = '0' then
      data             <= (others => '0');
      data_available_s <= '0';
      send_sop         <= '0';
      send_eop <= '0';
    elsif clk'event and clk = '1' then
      data_available_s <= data_available_int;
      if data_take = '1' then
        data <= at_sink_data;
        send_sop         <= send_sop_int;
        send_eop <= send_eop_int;        
      end if;
    end if;
  end process data_register;
  data_available <= data_available_s;

  error_register : process (clk, reset_n)
  begin  -- process
    if reset_n = '0' then
      packet_error <= "00";
    elsif clk'event and clk = '1' then
      packet_error <= packet_error_int;
    end if;
  end process;
end rtl;
