-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_atlantic_source.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/fu/atlantic/rtl/auk_dspip_atlantic_source.vhd,v $
--
-- $Revision: 1.8 $
-- $Date: 2006/08/22 15:22:11 $
-- Check in by     : $Author: sdemirso $
-- Author   :  Suleyman S. Demirsoy
--
-- Project      :  Atlantic II Source Interface with ready_latency=0
--
-- Description : 
--
-- This interface is capable of handling single or multi channel streams as
-- well as blocks of data. The at_source_sop and at_source_eop are generated as
-- described in the Atlantic II specification. The at_source_error output is a 2-
-- bit signal that complies with the PFC error format (by Kent Orthner). 
-- 
-- 00: no error
-- 01: missing sop
-- 10: missing eop
-- 11: unexpected eop
-- other types of errors also marked as 11. Any error signal is accompanied
-- by at_sink_eop flagged high. 
--
-- When packet_size is greater than one, this interface expects the main design
-- to supply the count of data starting from 1 to the packet_size. When it
-- receives the valid flag together with the data_count=1, it starts pumping
-- out data by flagging the at_source_sop and at_source_valid both high.
--
-- When the data_count=packet_size, the at_source_eop is flagged high together
-- with at_source_valid.  THERE IS NO ERROR CHECKING FOR THE data_count signal.
--
-- If the receiver is not ready to accept any data, the interface flags the source_
-- stall signal high to tell the design to stall. It is the designers
-- responsibility to use this signal properly. In some design, the stall signal
-- needs to stall all of the design so that no new data can be accepted (as in
-- FIR), in other cases (i.e. a FIFO built on a dual port RAM),the input can
-- still accept new data although it cannot send any output.
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

entity auk_dspip_atlantic_source is
  generic(
    WIDTH             :     integer  := 16;
    packet_size       :     natural  := 4;
    LOG2packet_size   :     integer  := 2;
    multi_channel     :     BOOLEAN  := TRUE
    );
  port(
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    ----------------- DESIGN SIDE SIGNALS
    data              : in  std_logic_vector (WIDTH-1 downto 0);
    data_count        : in  std_logic_vector (LOG2packet_size-1 downto 0) := (others => '0');
    source_valid_ctrl : in  std_logic;  --the controller will tell
                                        --the interface whether
                                        --new input can be accepted.
    source_stall      : out std_logic;  --needs to stall the design
                                        --if no new data is coming
    packet_error      : in  std_logic_vector (1 downto 0);
    ----------------- ATLANTIC SIDE SIGNALS
    at_source_ready   : in  std_logic;
    at_source_valid   : out std_logic;
    at_source_data    : out std_logic_vector (WIDTH-1 downto 0);
    at_source_channel : out std_logic_vector (log2packet_size-1 downto 0);
    at_source_error   : out std_logic_vector (1 downto 0);
    at_source_sop     : out std_logic;
    at_source_eop     : out std_logic
    );

-- Declarations

end auk_dspip_atlantic_source;

-- hds interface_end
architecture rtl of auk_dspip_atlantic_source is

  type state_type is (start, wait1, stall, run1, st_err, end1);
  signal source_state, source_next_state : state_type;
  signal data_wr_enb                     : std_logic;
  signal packet_error0                   : std_logic;
  signal at_source_error_int             : std_logic_vector(1 downto 0);
--   signal count : unsigned(log2packet_size-1 downto 0);
--   signal count_enable : std_logic;
--   signal count_finished : std_logic;
--   signal reset_count  : std_logic;
  signal at_source_sop_int : std_logic;
  signal at_source_eop_int : std_logic;
  signal at_source_valid_int : std_logic;
  signal at_source_valid_s : std_logic;
  signal valid_reg_reset : std_logic;
  signal res_reg : std_logic;
  
begin

    source_stall <= '1' when (source_valid_ctrl = '1' and at_source_ready='0') else
                    '0';
    at_source_valid_int <= '1' when (source_valid_ctrl = '1' and source_next_state /=st_err  and res_reg = '1') else
                           '0';
    valid_reg_reset <= '1' when at_source_valid_s = '1' and source_valid_ctrl = '0' and at_source_ready = '1' else
                       '0';
        
  single_channel : if packet_size = 1 generate
    
    at_source_sop_int         <= '0';
    at_source_eop_int         <= '0';
    packet_error0         <= packet_error(0);
    at_source_error_int(1) <= '0';
    at_source_error_int(0) <= '1' when source_next_state = st_err else
                              '0';
    data_wr_enb <= '1' when source_next_state = run1  else 
                   '0';
    source_comb_update_1 : process (source_state, source_valid_ctrl,
                                    at_source_ready, packet_error0)
    begin  -- process source_comb_update_1
      
      case source_state is
        when start =>
          if packet_error0 = '1' then
            source_next_state        <= st_err;
          else
            if source_valid_ctrl = '0' and at_source_ready = '0' then
              source_next_state      <= start;
            elsif source_valid_ctrl = '0' and at_source_ready = '1' then
              source_next_state      <= start;
            elsif source_valid_ctrl = '1' and at_source_ready = '0' then
              source_next_state      <= stall;
            elsif source_valid_ctrl = '1' and at_source_ready = '1' then
              source_next_state      <= run1;
            else
              source_next_state      <= st_err;
            end if;
          end if;

        when stall  =>

          if packet_error0 = '1' then
            source_next_state        <= st_err;
          else
            if source_valid_ctrl = '0' and at_source_ready = '0' then
              source_next_state      <= stall;
            elsif source_valid_ctrl = '0' and at_source_ready = '1' then
              source_next_state      <= start;
            elsif source_valid_ctrl = '1' and at_source_ready = '0' then
              source_next_state      <= stall;
            elsif source_valid_ctrl = '1' and at_source_ready = '1' then
              source_next_state      <= run1;
            else
              source_next_state      <= st_err;
            end if;
          end if;

        when run1 =>

          if packet_error0 = '1' then
            source_next_state        <= st_err;
          else
            if source_valid_ctrl = '0' and at_source_ready = '0' then
              source_next_state      <= stall;
            elsif source_valid_ctrl = '0' and at_source_ready = '1' then
              source_next_state      <= start;
            elsif source_valid_ctrl = '1' and at_source_ready = '0' then
              source_next_state      <= stall;
            elsif source_valid_ctrl = '1' and at_source_ready = '1' then
              source_next_state      <= run1;
            else
              source_next_state      <= st_err;
            end if;
          end if;

        when st_err =>
            
          if packet_error0 = '1' then
            source_next_state        <= st_err;
          else
            if source_valid_ctrl = '0' and at_source_ready = '0' then
              source_next_state      <= start;
            elsif source_valid_ctrl = '0' and at_source_ready = '1' then
              source_next_state      <= start;
            elsif source_valid_ctrl = '1' and at_source_ready = '0' then
              source_next_state      <= stall;
            elsif source_valid_ctrl = '1' and at_source_ready = '1' then
              source_next_state      <= run1;
            else
              source_next_state      <= st_err;
            end if;
          end if;

        when others =>
          source_next_state <= st_err;
      end case;
    end process source_comb_update_1;

  end generate single_channel;

  packet_multi: if packet_size > 1 generate

    packet_error0 <= packet_error(1) or packet_error(0);

    data_wr_enb <= '1' when source_next_state = run1 or source_next_state = end1 else 
                   '0';
    at_source_eop_int <= '1' when source_next_state = st_err or source_next_state = end1 else
                         '0';
source_comb_update_2: process (source_state, source_valid_ctrl,packet_error,
                      at_source_ready, packet_error0, data_count)
    begin  -- process source_comb_update_2
       
      case source_state is
        when start =>
          if packet_error0 ='1'  then
            source_next_state <= st_err;
            at_source_error_int <= packet_error;
            at_source_sop_int <= '0';
          else
            at_source_error_int <= "00";
            if source_valid_ctrl = '1' and unsigned(data_count)=0 and at_source_ready='1' then
               source_next_state <= run1;
               at_source_sop_int <= '1';
             else
               source_next_state <= start;
               at_source_sop_int <= '0';
              end if;  
          end if;

        when run1 =>
          at_source_sop_int <= '0';

          if packet_error0 ='1'  then
            source_next_state <= st_err;
            at_source_error_int <= packet_error;
          else
            if at_source_ready='0' then
              source_next_state <= stall;
              at_source_error_int <= "00";
            elsif source_valid_ctrl = '0' and at_source_ready='1' then
              source_next_state <= wait1;
              at_source_error_int <= "00";
            elsif source_valid_ctrl = '1' and at_source_ready='1' then
              if unsigned(data_count)=(packet_size-1) then
                source_next_state <= end1;
                at_source_error_int <= "00";
              else
                source_next_state <= run1;
                at_source_error_int <= "00";
              end if;
            else
              source_next_state <= st_err;
              at_source_error_int <= "11";
            end if;
          end if;
              
        when wait1 =>
          at_source_sop_int <= '0';

          if packet_error0 ='1'  then
            source_next_state <= st_err;
            at_source_error_int <= packet_error;
          else
            if at_source_ready='0' then
              source_next_state <= stall;
              at_source_error_int <= "00";
            elsif source_valid_ctrl = '0' and at_source_ready='1' then
              source_next_state <= wait1;
              at_source_error_int <= "00";
            elsif source_valid_ctrl = '1' and at_source_ready='1' then
              if unsigned(data_count)=(packet_size-1) then
                source_next_state <= end1;
                at_source_error_int <= "00";
              else
                source_next_state <= run1;
                at_source_error_int <= "00";
              end if;
            else
              source_next_state <= st_err;
              at_source_error_int <= "11";
            end if;
          end if;
          
        when stall =>

          at_source_sop_int <= '0';

          if packet_error0 ='1'  then
            source_next_state <= st_err;
            at_source_error_int <= packet_error;
          else
            if at_source_ready='0' then
              source_next_state <= stall;
              at_source_error_int <= "00";
            elsif source_valid_ctrl = '0' and at_source_ready='1' then
              source_next_state <= wait1;
              at_source_error_int <= "00";
            elsif source_valid_ctrl = '1' and at_source_ready='1' then
              if unsigned(data_count)=(packet_size-1) then
                source_next_state <= end1;
                at_source_error_int <= "00";
              else
                source_next_state <= run1;
                at_source_error_int <= "00";
              end if;
            else
              source_next_state <= st_err;
              at_source_error_int <= "11";
            end if;
          end if;
          
        when end1 =>

          if packet_error0 ='1'  then
            source_next_state <= st_err;
            at_source_error_int <= packet_error;
            at_source_sop_int <= '0';
          else
            at_source_error_int <= "00";
            if source_valid_ctrl = '1' and unsigned(data_count)=0 and at_source_ready='1' then
               source_next_state <= run1;
               at_source_sop_int <= '1';
             else
               source_next_state <= start;
               at_source_sop_int <= '0';
              end if;  
          end if;          
        when st_err =>
          at_source_sop_int <= '0';

          if packet_error0 ='1'  then
            source_next_state <= st_err;
            at_source_error_int <= packet_error;
          else
            source_next_state <= start;
            at_source_error_int <= "00";
          end if;
        when others => null;
      end case;          
    end process source_comb_update_2;    

--     counter : process (clk, reset_n)
--     begin  -- process counter
--       if reset_n = '0' then
--         count     <= (others => '0');
--       elsif clk'event and clk = '1' then  -- rising clock edge
--         if reset_count = '1' then
--           count   <= (others => '0');
--         else
--           if count_enable = '1' then
--             count <= count + 1;
--           end if;
--         end if;
--       end if;
--     end process counter;

--     count_finished <= count = packet_size;
  end generate packet_multi;
  
  source_update : process (clk, reset_n)
  begin  -- process
    if reset_n = '0' then
      source_state <= start;
    elsif clk'event and clk = '1' then
      source_state <= source_next_state;
    end if;

  end process source_update;


  output_registers : process (clk, reset_n)
  begin  -- process
    if reset_n = '0' then
      at_source_data   <= (others => '0');
    elsif clk'event and clk = '1' then
      if data_wr_enb = '1' then
        at_source_data <= data;
      end if;
    end if;
  end process output_registers;

   
  valid_register : process (clk, reset_n)
  begin
    if reset_n = '0' then 
      at_source_valid_s <= '0';
    elsif clk'event and clk = '1' then
      if valid_reg_reset = '1'  then
        at_source_valid_s <= '0';
      end if;
      if data_wr_enb = '1' then      
        at_source_valid_s <= at_source_valid_int;
      end if;        
    end if;
  end process;   
  at_source_valid <= at_source_valid_s;
  
  other_register : process (clk, reset_n)
  begin
    if reset_n = '0' then 
      at_source_error <= "00";    
      at_source_sop <= '0';
      at_source_eop <= '0';

    elsif clk'event and clk = '1' then
      at_source_sop <= at_source_sop_int;
      at_source_eop <= at_source_eop_int;  
      at_source_error <= at_source_error_int;   
    end if;
  end process;  

  channel_info_exists: if multi_channel=TRUE  generate
  channel_register : process (clk, reset_n)
  begin  -- process channel_register
    if reset_n = '0' then
      at_source_channel   <= (others => '0');
    elsif clk'event and clk = '1' then
      if data_wr_enb = '1' then
        at_source_channel <= data_count;
      end if;
    end if;
  end process channel_register;    
  end generate channel_info_exists;

  no_channel_info: if multi_channel=FALSE generate
    at_source_channel <= (others => '0');
  end generate no_channel_info;

  res_reg_gen : process (clk, reset_n)
  begin  -- process res_reg
    if reset_n = '0' then
      res_reg <= '0';
    elsif rising_edge(clk) then
      res_reg <= '1';
    end if;
  end process res_reg_gen;

  

end rtl;

