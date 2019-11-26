----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_conv_encode.vhd
--
-- Project     : Turbo Codec
-- Description : CTC Convolutional Encode
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2009 (c) Altera Corporation
-- All rights reserved
--
-- $Header: $
----------------------------------------------------------------------

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

entity auk_dspip_ctc_umts_conv_encode is
  generic (
    CONSTRAINT_LENGTH_g : positive := 4
    );
  port (
    clk     : in  std_logic;
    ena     : in  std_logic;
    reset   : in  std_logic;
    data_in : in  std_logic;
    dout    : out std_logic_vector(1 downto 0)
    );

end entity auk_dspip_ctc_umts_conv_encode;

architecture SYN of auk_dspip_ctc_umts_conv_encode is

  constant NUM_OF_SHIFT_REGS_c : positive := CONSTRAINT_LENGTH_g-1;  -- number of delay elements

  signal shift_register : std_logic_vector(NUM_OF_SHIFT_REGS_c-1 downto 0);

  signal sr_in    : std_logic;          -- input to the shift register
  signal mod_out  : std_logic;          -- mod output after first register
  signal feedback : std_logic;          -- feedback to the input mod

-----------------------------------------------------------------------------
--
--                  |-------------(+)-----------mod_out-----------(+)-----dout(0)
--                  |              |                               |
--                  |              |                               |
--                  |    -----     |    -----         -----        |
-- data_in --(+)--sr_in--| D | -------- | D | ------- | D | --------
--            |          -----          -----    |    -----        |
--            |                                  |                 |
--            |-------feedback------------------(+)----------------|
--
-----------------------------------------------------------------------------
  
  
begin  -- architecture SYN

  feedback <= shift_register(2) xor shift_register(1);
  sr_in    <= data_in xor feedback;
  mod_out  <= sr_in xor shift_register(0);
  dout(0)  <= shift_register(2) xor mod_out;
  dout(1)  <= feedback;

  encode_proc : process (clk, reset)
  begin  -- process encode_proc
    if reset = '1' then
      shift_register <= (others => '0');
      
    elsif rising_edge(clk) then
      if ena = '1' then
        for i in NUM_OF_SHIFT_REGS_c-1 downto 1 loop
          shift_register(i) <= shift_register(i-1);
        end loop;  -- i
        shift_register(0) <= sr_in;
      end if;
    end if;
  end process encode_proc;

--  output_proc : process (clk, reset)
--  begin  -- process output_proc
--    if reset = '1' then
--      dout <= (others => '0');
--    elsif rising_edge(clk) then
--      if ena = '1' then
--        dout(0) <= shift_register(2) xor mod_out;
--        dout(1) <= feedback;
--      end if;
--    end if;
--  end process output_proc;
  
end architecture SYN;
