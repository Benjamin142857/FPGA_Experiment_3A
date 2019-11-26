----------------------------------------------------------------------
--
-- File: auk_dspip_ctc_umts_map_gamma.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : Entity for updating gamma metrics
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/map/auk_dspip_ctc_umts_map_gamma.vhd#1 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity auk_dspip_ctc_umts_map_gamma is
  generic (
    INPUT_WIDTH_g : positive := 6;
    WIDTH_g       : positive := 9
    );
  port (
    clk          : in  std_logic;
    ena          : in  std_logic;
    reset        : in  std_logic;
    input_c_0    : in  signed(INPUT_WIDTH_g-1 downto 0);
    input_c_1    : in  signed(INPUT_WIDTH_g-1 downto 0);
    app_in       : in  signed(INPUT_WIDTH_g-1 downto 0);
    gamma_to_mem : out signed(3*WIDTH_g+INPUT_WIDTH_g-1 downto 0);
    gamma_1      : out signed(WIDTH_g-1 downto 0);
    gamma_2      : out signed(WIDTH_g-1 downto 0);
    gamma_3      : out signed(WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_map_gamma;


architecture beh of auk_dspip_ctc_umts_map_gamma is

  signal app_in_reg : signed(INPUT_WIDTH_g-1 downto 0);  -- delayed app_in (extrisic info)
  signal gamma_1_s  : signed(WIDTH_g-1 downto 0);
  signal gamma_2_s  : signed(WIDTH_g-1 downto 0);
  signal gamma_3_s  : signed(WIDTH_g-1 downto 0);
  
begin  -- architecture beh
  gamma : process (clk, reset)
  begin  -- process gamma
    if reset = '1' then
      gamma_1_s  <= (others => '0');
      gamma_2_s  <= (others => '0');
      gamma_3_s  <= (others => '0');
      app_in_reg <= (others => '0');
    elsif rising_edge(clk) then
      if ena = '1' then
        gamma_1_s  <= resize(input_c_1, WIDTH_g);
        gamma_2_s  <= resize(input_c_0, WIDTH_g) + resize(app_in, WIDTH_g);
        gamma_3_s  <= resize(input_c_0, WIDTH_g) + resize(input_c_1, WIDTH_g) + resize(app_in, WIDTH_g);
        app_in_reg <= app_in;
      end if;
    end if;
  end process gamma;

  gamma_to_mem <= app_in_reg & gamma_3_s & gamma_2_s & gamma_1_s;
  gamma_1      <= gamma_1_s;
  gamma_2      <= gamma_2_s;
  gamma_3      <= gamma_3_s;
  
end architecture beh;

