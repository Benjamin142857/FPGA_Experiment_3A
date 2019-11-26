----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_alpha.vhd
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
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/map/auk_dspip_ctc_umts_map_alpha.vhd#2 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

entity auk_dspip_ctc_umts_map_alpha is
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
    sload          : in  std_logic;
    alpha_prime_in : in  signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
    alpha_prime    : out signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0);
    alpha_out      : out signed((MAX_STATES_c-1)*WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_alpha;


architecture SYN of auk_dspip_ctc_umts_map_alpha is

  type trellis is array (7 downto 0) of signed(WIDTH_g-1 downto 0);
  type branch is array (3 downto 0) of signed(WIDTH_g-1 downto 0);

  signal delta_1_00     : trellis;
  signal delta_1_25     : trellis;
  signal delta_1_50     : trellis;
  signal delta_2_00     : trellis;
  signal delta_2_25     : trellis;
  signal delta_2_50     : trellis;
  signal delta_2_75     : trellis;
  signal diff           : trellis;
  signal alpha          : trellis;
  signal alpha_norm     : trellis;
  signal alpha_reg      : trellis;
  signal metric_c_input : branch;

begin  -- architecture SYN

  -- map inputs
  metric_c_input(0) <= (others => '0');
  metric_c_input(1) <= metric_c_1;
  metric_c_input(2) <= metric_c_2;
  metric_c_input(3) <= metric_c_3;

  alpha_array : for i in 0 to 7 generate
  begin  -- generate alpha_array

    -- code for single window case
    delta_1_00(i) <= alpha_reg(STATE0_A(i)) + metric_c_input(OUT0_A(i));
    delta_1_25(i) <= alpha_reg(STATE0_A(i)) + metric_c_input(OUT0_A(i)) + "001";
    delta_1_50(i) <= alpha_reg(STATE0_A(i)) + metric_c_input(OUT0_A(i)) + "010";
    delta_2_00(i) <= alpha_reg(STATE1_A(i)) + metric_c_input(OUT1_A(i));
    delta_2_25(i) <= alpha_reg(STATE1_A(i)) + metric_c_input(OUT1_A(i)) + "001";
    delta_2_50(i) <= alpha_reg(STATE1_A(i)) + metric_c_input(OUT1_A(i)) + "010";
    delta_2_75(i) <= alpha_reg(STATE1_A(i)) + metric_c_input(OUT1_A(i)) + "011";
    diff(i)       <= delta_1_00(i) - delta_2_00(i);

    max_logmap_alpha : if DECODER_TYPE_g = "MAXLOGMAP" generate
    begin  -- generate max_logmap_alpha
      
      auk_dspip_ctc_umts_map_maxlogmap_inst : auk_dspip_ctc_umts_map_maxlogmap
        generic map (
          WIDTH_g => WIDTH_g
          ) 
        port map (
          delta_1_00 => delta_1_00(i),
          delta_2_00 => delta_2_00(i),
          diff       => diff(i),
          q          => alpha(i)
          );

    end generate max_logmap_alpha;

    logmap_alpha : if DECODER_TYPE_g = "LOGMAP" generate
    begin  -- generate logmap_alpha

      auk_dspip_ctc_umts_map_logmap_inst : auk_dspip_ctc_umts_map_logmap
        generic map (
          WIDTH_g => WIDTH_g
          ) 
        port map (
          delta_1_00 => delta_1_00(i),
          delta_1_25 => delta_1_25(i),
          delta_1_50 => delta_1_50(i),
          delta_2_00 => delta_2_00(i),
          delta_2_25 => delta_2_25(i),
          delta_2_50 => delta_2_50(i),
          delta_2_75 => delta_2_75(i),
          diff       => diff(i),
          q          => alpha(i)
          );

    end generate logmap_alpha;


    const_logmap_alpha : if DECODER_TYPE_g = "CONST_LOGMAP" generate
    begin  -- generate const_logmap_alpha

      auk_dspip_ctc_umts_map_constlogmap_inst : auk_dspip_ctc_umts_map_constlogmap
        generic map (
          WIDTH_g => WIDTH_g
          ) 
        port map (
          delta_1_00 => delta_1_00(i),
          delta_1_50 => delta_1_50(i),
          delta_2_00 => delta_2_00(i),
          delta_2_50 => delta_2_50(i),
          diff       => diff(i),
          q          => alpha(i)
          );

    end generate const_logmap_alpha;

    normalise_and_reg_output : process (clk, reset) is
    begin  -- process normalise_and_reg_output
      if reset = '1' then               -- asynchronous reset (active high)
          alpha_reg(i) <= (others => '0');
      elsif rising_edge(clk) then       -- rising clock edge
        if ena = '1' then
          if i = 0 then
            alpha_reg(i) <= (others => '0');
          else
            if sload = '1' then         -- load data to registers
              alpha_reg(i) <= alpha_prime_in(i*WIDTH_g-1 downto (i-1)*WIDTH_g);
            else
              alpha_reg(i) <= alpha_norm(i);
            end if;
          end if;
        end if;
      end if;
    end process normalise_and_reg_output;

    alpha_norm(i) <= alpha(i) - alpha(0);
  end generate alpha_array;

  output_gen : for i in 1 to MAX_STATES_c-1 generate
  begin
    alpha_out(i*WIDTH_g-1 downto (i-1)*WIDTH_g) <= alpha_norm(i);
    alpha_prime(i*WIDTH_g-1 downto (i-1)*WIDTH_g) <= alpha_reg(i);
  end generate output_gen;
  
end architecture SYN;

