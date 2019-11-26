-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_fifo_pfc.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/fu/fifo_pfc/rtl/auk_dspip_fifo_pfc.vhd,v $
--
-- $Revision: 1.8 $
-- $Date: 2007/05/04 15:30:16 $
-- Check in by     : $Author: sdemirso $
-- Author   :  <Author name>
--
-- Project      :  <project name>
--
-- Description : 
--
-- <Brief description of the contents of the file>
-- 
--
-- $Log: auk_dspip_fifo_pfc.vhd,v $
-- Revision 1.8  2007/05/04 15:30:16  sdemirso
-- merge from 7.1
--
-- Revision 1.6.2.2  2007/03/07 18:17:59  vmauer
-- the previous version had datao identical to the 6.1 version at the clock cycle after rdreq, which we had assumed was sufficient.  This version has datao always identical, with the exception of after a sync.reset.
-- Revision 1.7  2007/02/26 18:28:18  vmauer
-- changed memory instantiation (SPR 234266), fixed channel out
--
-- Revision 1.6.2.1  2007/02/26 18:26:43  vmauer
-- changed memory instantiation (SPR 234266), fixed channel out
--
-- Revision 1.6  2007/02/09 17:16:21  vmauer
-- changed memory to LPM for better timing in Cyclone
--
-- Revision 1.5  2006/11/24 16:47:18  sdemirso
-- merging from brach_6_1
--
-- Revision 1.1.2.5  2006/11/11 14:11:20  vmauer
-- SPR 226775:  Changed read latency (rdreq to datao) to 1
--
-- Revision 1.1.2.4  2006/11/09 11:43:55  vmauer
-- calculating used_words only once to increase fmax - used_words is only checked during initialisation.  SPR 226217.
--
-- Revision 1.1.2.3  2006/09/26 13:46:56  vmauer
-- updated "used_words"
--
-- Revision 1.1.2.2  2006/09/26 09:47:42  vmauer
-- added sclr functionality, produce "empty" one count earlier, set "empty" on reset and sclr
--
-- Revision 1.1.2.1  2006/09/22 09:10:47  vmauer
-- initial version
--
-- Revision 1.1.2.1  2006/09/22 08:55:37  vmauer
-- initial version
--
-- Revision 1.1.2.4  2006/09/20 16:55:28  vmauer
-- delayed channel_out
--
-- Revision 1.1.2.3  2006/09/20 16:41:58  vmauer
-- added out_valid
--
-- Revision 1.4  2006/08/24 12:57:58  sdemirso
-- headers added
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
library altera_mf;
use altera_mf.altera_mf_components.all;


entity auk_dspip_fifo_pfc is
  generic (
    NUM_CHANNELS_g            : integer := 5;
    POLY_FACTOR_g             : integer := 3;
    DATA_WIDTH_g              : integer := 16;
    ALMOST_FULL_VALUE_g       : integer := 2;
    RAM_TYPE_g                : string  := "AUTO";
    CALCULATE_USED_WORDS_ONCE : boolean := true
    );
  port (

    datai       : in  std_logic_vector(DATA_WIDTH_g-1 downto 0);
    datao       : out std_logic_vector(DATA_WIDTH_g-1 downto 0);
    channel_out : out std_logic_vector(log2_ceil(NUM_CHANNELS_g)-1 downto 0);
    used_w      : out std_logic_vector(log2_ceil(POLY_FACTOR_g * NUM_CHANNELS_g)+1 downto 0);

    wrreq       : in  std_logic;
    rdreq       : in  std_logic;
    almost_full : out std_logic;
    empty       : out std_logic;
    sclr        : in  std_logic;
    clk         : in  std_logic;
    reset       : in  std_logic;
    enable      : in  std_logic
    );
end auk_dspip_fifo_pfc;

architecture rtl of auk_dspip_fifo_pfc is


  constant MAX_ADDRESS_g     : natural                                                          := POLY_FACTOR_g * NUM_CHANNELS_g * 4;
  constant LOG_MAX_ADDRESS_g : natural                                                          := log2_ceil(MAX_ADDRESS_g);
  constant MAX_SECTION_c     : unsigned(log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 1 downto 0) := to_unsigned(POLY_FACTOR_g * NUM_CHANNELS_g, log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 2);


  signal channel_out_count_alt : unsigned(log2_ceil(NUM_CHANNELS_g)-1 downto 0);
  signal poly_out_count_alt    : unsigned(log2_ceil(POLY_FACTOR_g)-1 downto 0);

  signal rd_addr_slv : std_logic_vector(log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 1 downto 0);
  signal rd_addr_alt : unsigned(log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 1 downto 0);
  signal wr_addr     : unsigned(log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 1 downto 0);
  signal wr_addr_slv : std_logic_vector(log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 1 downto 0);
  signal used_words  : unsigned(log2_ceil(POLY_FACTOR_g * NUM_CHANNELS_g)+2 downto 0);

  signal write_section    : unsigned(1 downto 0);
  signal read_section_alt : unsigned(1 downto 0);

  signal initialised       : std_logic;
  signal start_alt         : std_logic;
  signal one               : std_logic;
  signal rden              : std_logic;
  signal rdreq_del         : std_logic;
  signal datao_alt         : std_logic_vector(DATA_WIDTH_g-1 downto 0);
  signal datao_early       : std_logic_vector(DATA_WIDTH_g-1 downto 0);
  signal datao_lpm         : std_logic_vector(DATA_WIDTH_g-1 downto 0);
  signal channel_out_early : std_logic_vector(log2_ceil(NUM_CHANNELS_g)-1 downto 0);



begin


  calc_once            : if CALCULATE_USED_WORDS_ONCE generate
  begin  -- generate calc_once
    used_word_counters : process (clk, reset) is
    begin  -- process used_word_counters
      if reset = '1' then               -- asynchronous reset (active high)
        used_words <= (others => '0');

      elsif rising_edge(clk) then       -- rising clock edge
        if enable = '1' then
          if sclr = '1' then
            used_words     <= (others => '0');
          else
            -- used words
            if (wrreq = '1') then
              if (wr_addr = POLY_FACTOR_g * NUM_CHANNELS_g) then
                used_words <= '0' & MAX_SECTION_c;
              end if;
            end if;
          end if;
        end if;
      end if;
    end process used_word_counters;


  end generate calc_once;

  calc_always          : if not CALCULATE_USED_WORDS_ONCE generate
  begin  -- generate calc_always
    used_word_counters : process (clk, reset) is
    begin  -- process used_word_counters
      if reset = '1' then               -- asynchronous reset (active high)
        used_words <= (others => '0');

      elsif rising_edge(clk) then       -- rising clock edge
        if enable = '1' then
          if sclr = '1' then
            used_words <= (others => '0');
          else

            -- used words
            if (rdreq = '0') and (wrreq = '0') then
              -- no action
            elsif (rdreq = '0') and (wrreq = '1') then
              if (wr_addr = POLY_FACTOR_g * NUM_CHANNELS_g) or
                (wr_addr = 2*POLY_FACTOR_g * NUM_CHANNELS_g) or
                (wr_addr = 3*POLY_FACTOR_g * NUM_CHANNELS_g) or
                ((wr_addr = 0) and (initialised = '1')) then
                used_words <= used_words+MAX_SECTION_c;
              end if;
            elsif (rdreq = '1') and (wrreq = '0') then
              used_words   <= used_words-1;
            else
              if (wr_addr = POLY_FACTOR_g * NUM_CHANNELS_g) or
                (wr_addr = 2*POLY_FACTOR_g * NUM_CHANNELS_g) or
                (wr_addr = 3*POLY_FACTOR_g * NUM_CHANNELS_g) or
                ((wr_addr = 0) and (initialised = '1')) then
                used_words <= used_words+MAX_SECTION_c-1;
              end if;
            end if;
          end if;
        end if;
      end if;
    end process used_word_counters;


  end generate calc_always;



  output_counters_alt : process (clk, reset) is
  begin  -- process output_counters_alt
    if reset = '1' then                 -- asynchronous reset (active high)
      channel_out_count_alt <= to_unsigned(0, log2_ceil(NUM_CHANNELS_g));
      poly_out_count_alt    <= to_unsigned(1, log2_ceil(POLY_FACTOR_g));
      rd_addr_alt           <= to_unsigned(NUM_CHANNELS_g, log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 2);
      read_section_alt      <= "00";
      start_alt             <= '1';

    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        if sclr = '1' then
          channel_out_count_alt <= (others => '0');
          poly_out_count_alt    <= to_unsigned(1, log2_ceil(POLY_FACTOR_g));
          rd_addr_alt           <= to_unsigned(NUM_CHANNELS_g, log2_ceil(NUM_CHANNELS_g * POLY_FACTOR_g) + 2);
          read_section_alt      <= "00";
          start_alt             <= '1';
        else

          start_alt <= '0';
          -- output side
          if rdreq = '1' then

            if poly_out_count_alt = POLY_FACTOR_g-1 then
              poly_out_count_alt <= (others => '0');
            else
              poly_out_count_alt <= poly_out_count_alt+1;
            end if;

            if poly_out_count_alt = POLY_FACTOR_g-1 then
              if channel_out_count_alt = NUM_CHANNELS_g-1 then
                channel_out_count_alt <= (others => '0');
              else
                channel_out_count_alt <= channel_out_count_alt+1;
              end if;
            end if;

            if poly_out_count_alt = POLY_FACTOR_g-1 then
              if channel_out_count_alt = NUM_CHANNELS_g-1 then
                if rd_addr_alt = MAX_ADDRESS_g-1 then
                  rd_addr_alt      <= (others => '0');
                  read_section_alt <= "00";
                else
                  rd_addr_alt      <= rd_addr_alt+1;
                  read_section_alt <= read_section_alt+1;
                end if;

              else
                rd_addr_alt <= rd_addr_alt-((POLY_FACTOR_g-1)*NUM_CHANNELS_g)+1;
              end if;
            else
              rd_addr_alt   <= rd_addr_alt+NUM_CHANNELS_g;
            end if;
          end if;

        end if;
      end if;
    end if;
  end process output_counters_alt;

  input_counters : process (clk, reset) is
  begin  -- process input_ccounters
    if reset = '1' then                 -- asynchronous reset (active high)
      wr_addr       <= (others => '0');
      write_section <= "00";
      initialised   <= '0';

    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        if sclr = '1' then
          wr_addr           <= (others => '0');
          write_section     <= "00";
          initialised       <= '0';
        else
          -- input side
          if wrreq = '1' then
            initialised     <= '1';
            if wr_addr = MAX_ADDRESS_g-1 then
              wr_addr       <= (others => '0');
            else
              wr_addr       <= wr_addr + 1;
            end if;
            if wr_addr = 0 then
              write_section <= "00";
            elsif wr_addr = POLY_FACTOR_g * NUM_CHANNELS_g then
              write_section <= "01";
            elsif wr_addr = 2 * POLY_FACTOR_g * NUM_CHANNELS_g then
              write_section <= "10";
            elsif wr_addr = 3 * POLY_FACTOR_g * NUM_CHANNELS_g then
              write_section <= "11";
            end if;
          end if;
        end if;
      end if;
    end if;
  end process input_counters;

  control_outputs : process (clk, reset) is
  begin  -- process control_outputs
    if reset = '1' then                 -- asynchronous reset (active high)
      empty           <= '1';
      almost_full     <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        if sclr = '1' then
          empty       <= '1';
          almost_full <= '0';
        else

          if (write_section = read_section_alt) or ((write_section = read_section_alt+1) and (poly_out_count_alt = POLY_FACTOR_g-1) and (channel_out_count_alt = NUM_CHANNELS_g-1)) then
-- if (write_section = read_section) then
            empty       <= '1';
          else
            empty       <= '0';
          end if;
          if write_section = read_section_alt-1 then
            almost_full <= '1';
          else
            almost_full <= '0';
          end if;
        end if;
      end if;
    end if;
  end process control_outputs;

  used_w <= std_logic_vector(used_words(log2_ceil(POLY_FACTOR_g * NUM_CHANNELS_g)+1 downto 0));



  -- purpose: delays data from memory
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: 
  delay_out : process (clk, reset) is
  begin  -- process delay_out
    if reset = '1' then                 -- asynchronous reset (active high)
      datao_alt       <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        if sclr = '1' then
          datao_alt   <= (others => '0');
        else
          if rdreq_del = '1' then
            datao_alt <= datao_early;
          end if;
        end if;
      end if;
    end if;
  end process delay_out;

  delay_regs : process (clk, reset) is
  begin  -- process delay_regs
    if reset = '1' then                 -- asynchronous reset (active high)
      channel_out             <= (others => '0');
      channel_out_early       <= (others => '0');
      rdreq_del               <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      if enable = '1' then
        if sclr = '1' then
          channel_out         <= (others => '0');
          channel_out_early   <= (others => '0');
          rdreq_del           <= '0';
        else
          channel_out         <= channel_out_early;
          if rdreq = '1' then
            channel_out_early <= std_logic_vector(channel_out_count_alt);
          end if;
          rdreq_del           <= rdreq;
        end if;
      end if;
    end if;
  end process delay_regs;


  one         <= '1';
  rden        <= '1' when rdreq = '1' or start_alt = '1' else '0';
  wr_addr_slv <= std_logic_vector(wr_addr);
  rd_addr_slv <= std_logic_vector(rd_addr_alt);

  altsyncram_component : altsyncram
    generic map (
      address_reg_b                      => "CLOCK0",
      clock_enable_input_a               => "NORMAL",
      clock_enable_input_b               => "NORMAL",
      clock_enable_output_a              => "NORMAL",
      clock_enable_output_b              => "NORMAL",
      intended_device_family             => "Stratix II",
      lpm_type                           => RAM_TYPE_g,
      numwords_a                         => MAX_ADDRESS_g,
      numwords_b                         => MAX_ADDRESS_g,
      operation_mode                     => "DUAL_PORT",
      outdata_aclr_b                     => "CLEAR0",
      outdata_reg_b                      => "CLOCK0",
      power_up_uninitialized             => "FALSE",
      rdcontrol_reg_b                    => "CLOCK0",
      read_during_write_mode_mixed_ports => "DONT_CARE",
      widthad_a                          => LOG_MAX_ADDRESS_g,
      widthad_b                          => LOG_MAX_ADDRESS_g,
      width_a                            => DATA_WIDTH_g,
      width_b                            => DATA_WIDTH_g,
      width_byteena_a                    => 1
      )
    port map (
      clocken0                           => one,
      wren_a                             => wrreq,
      aclr0                              => reset,
      clock0                             => clk,
      address_a                          => wr_addr_slv,
      address_b                          => rd_addr_slv,
      rden_b                             => rden,
      data_a                             => datai,
      q_b                                => datao_early
      );

  datao <= datao_early when rdreq_del = '1' else datao_alt;
end rtl;
