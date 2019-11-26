----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_llr.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : alpha Processing Unit
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/map/auk_dspip_ctc_umts_map_llr.vhd#2 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

entity auk_dspip_ctc_umts_map_llr is
  generic (
    WIDTH_g             : positive := 9;
    DECODER_TYPE_g      : string   := "CONST_LOGMAP"
                                        -- possible values are "MAXLOGMAP", "LOGMAP",
                                        -- "CONST_LOGMAP".
    );
  port (
    clk            : in  std_logic;
    ena            : in  std_logic;
    reset          : in  std_logic;
    metric_c_1     : in  signed(WIDTH_g-1 downto 0);
    metric_c_2     : in  signed(WIDTH_g-1 downto 0);
    metric_c_3     : in  signed(WIDTH_g-1 downto 0);
    alpha_prime_in : in  signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
    beta_in        : in  signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
    llr            : out signed(WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_llr;


architecture SYN of auk_dspip_ctc_umts_map_llr is
  type trellis is array (MAX_STATES_c-1 downto 0) of signed(WIDTH_g-1 downto 0);
  type trellis6 is array (MAX_STATES_c-2 downto 0) of signed(WIDTH_g-1 downto 0);
  type branch is array (3 downto 0) of signed(WIDTH_g-1 downto 0);

  signal den_delta      : trellis;
  signal num_delta      : trellis;
--  signal den_diff       : trellis6;
--  signal num_diff       : trellis6;
  signal den_llr        : trellis6;
  signal num_llr        : trellis6;
  signal alpha_prime    : trellis;
  signal beta           : trellis;
  signal metric_c_input : branch;

begin  -- architecture SYN

  -- map inputs
  metric_c_input(0) <= (others => '0');
  metric_c_input(1) <= metric_c_1;
  metric_c_input(2) <= metric_c_2;
  metric_c_input(3) <= metric_c_3;
  alpha_prime(0)    <= (others => '0');
  beta(0)           <= (others => '0');

  input_format_gen : for i in 1 to MAX_STATES_c-1 generate
    alpha_prime(i) <= alpha_prime_in(i*WIDTH_g-1 downto (i-1)*WIDTH_g);
    beta(i)        <= beta_in(i*WIDTH_g-1 downto (i-1)*WIDTH_g);
  end generate input_format_gen;

  llr_array : for i in 0 to MAX_STATES_c-1 generate
  begin  -- generate alpha_array

    first_stage : process (clk, reset) is
    begin  -- process delta_unit
      if reset = '1' then
        den_delta(i) <= (others => '0');
        num_delta(i) <= (others => '0');

      elsif rising_edge(clk) then       -- rising clock edge
        den_delta(i) <= alpha_prime(i) + metric_c_input(OUT0(i)) + beta(STATE0(i));
        num_delta(i) <= alpha_prime(i) + metric_c_input(OUT1(i)) + beta(STATE1(i));
      end if;
    end process first_stage;
  end generate llr_array;

  max_logmap_llr : if DECODER_TYPE_g = "MAXLOGMAP" generate
  begin  -- generate max_logmap_llr

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst0 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(0),
        b     => den_delta(1),
        q     => den_llr(0)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst1 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(2),
        b     => den_delta(3),
        q     => den_llr(1)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst2 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(4),
        b     => den_delta(5),
        q     => den_llr(2)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst3 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(6),
        b     => den_delta(7),
        q     => den_llr(3)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst4 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(0),
        b     => num_delta(1),
        q     => num_llr(0)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst5 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(2),
        b     => num_delta(3),
        q     => num_llr(1)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst6 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(4),
        b     => num_delta(5),
        q     => num_llr(2)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst7 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(6),
        b     => num_delta(7),
        q     => num_llr(3)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst8 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_llr(0),
        b     => den_llr(1),
        q     => den_llr(4)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst9 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_llr(2),
        b     => den_llr(3),
        q     => den_llr(5)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst10 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_llr(4),
        b     => den_llr(5),
        q     => den_llr(6)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst11 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_llr(0),
        b     => num_llr(1),
        q     => num_llr(4)
        );

    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst12 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_llr(2),
        b     => num_llr(3),
        q     => num_llr(5)
        );


    auk_dspip_ctc_umts_map_maxlogmap_pipelined_inst13 : auk_dspip_ctc_umts_map_maxlogmap_pipelined
      generic map (
        WIDTH_g => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_llr(4),
        b     => num_llr(5),
        q     => num_llr(6)
        );

  end generate max_logmap_llr;

  logmap_llr : if DECODER_TYPE_g = "LOGMAP" generate
  begin  -- generate logmap_llr

  end generate logmap_llr;


  const_logmap_llr : if DECODER_TYPE_g = "CONST_LOGMAP" generate
  begin  -- generate const_logmap_llr
    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst0 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(0),
        b     => den_delta(1),
        q     => den_llr(0)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst1 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(2),
        b     => den_delta(3),
        q     => den_llr(1)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst2 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(4),
        b     => den_delta(5),
        q     => den_llr(2)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst3 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_delta(6),
        b     => den_delta(7),
        q     => den_llr(3)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst4 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(0),
        b     => num_delta(1),
        q     => num_llr(0)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst5 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(2),
        b     => num_delta(3),
        q     => num_llr(1)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst6 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(4),
        b     => num_delta(5),
        q     => num_llr(2)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst7 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_delta(6),
        b     => num_delta(7),
        q     => num_llr(3)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst8 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_llr(0),
        b     => den_llr(1),
        q     => den_llr(4)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst9 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_llr(2),
        b     => den_llr(3),
        q     => den_llr(5)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst10 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => den_llr(4),
        b     => den_llr(5),
        q     => den_llr(6)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst11 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_llr(0),
        b     => num_llr(1),
        q     => num_llr(4)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst12 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_llr(2),
        b     => num_llr(3),
        q     => num_llr(5)
        );

    auk_dspip_ctc_umts_map_constlogmap_pipelined_inst13 : auk_dspip_ctc_umts_map_constlogmap_pipelined
      generic map (
        WIDTH_g             => WIDTH_g
        ) 
      port map (
        clk   => clk,
        reset => reset,
        ena   => ena,
        a     => num_llr(4),
        b     => num_llr(5),
        q     => num_llr(6)
        );

  end generate const_logmap_llr;

  llr_proc : process (clk, reset)
  begin  -- process llr_proc
    if reset = '1' then
      llr <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        llr <= num_llr(6) - den_llr(6);
      end if;
    end if;
  end process llr_proc;
end architecture SYN;

