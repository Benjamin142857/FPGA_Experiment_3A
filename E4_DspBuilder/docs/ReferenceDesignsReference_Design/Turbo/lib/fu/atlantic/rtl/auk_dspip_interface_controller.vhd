-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_interface_controller.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/fu/atlantic/rtl/auk_dspip_interface_controller.vhd,v $
--
-- $Revision: 1.2 $
-- $Date: 2006/08/22 15:28:52 $
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
-- $Log: auk_dspip_interface_controller.vhd,v $
-- Revision 1.2  2006/08/22 15:28:52  sdemirso
-- clock port added
--
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY auk_dspip_interface_controller IS
   PORT( 
    clk 	            : in  std_logic;
      reset               : IN     std_logic;
    ready               : in  std_logic;
      sink_packet_error   : IN     std_logic_vector (1 DOWNTO 0);
      sink_stall          : IN     std_logic;
      source_stall        : IN     std_logic;
      valid               : IN     std_logic;
      reset_design        : OUT    std_logic;
      reset_n             : OUT    std_logic;
      sink_ready_ctrl     : OUT    std_logic;
      source_packet_error : OUT    std_logic_vector (1 DOWNTO 0);
      source_valid_ctrl   : OUT    std_logic;
      stall               : OUT    std_logic
   );

-- Declarations

END auk_dspip_interface_controller ;

-- hds interface_end



ARCHITECTURE struct OF auk_dspip_interface_controller IS


  signal stall_int : std_logic;
  signal res       : std_logic;

BEGIN
  reset_design        <= res or sink_packet_error(0) or sink_packet_error(1);
   reset_n <= not reset;
   source_packet_error <= sink_packet_error;

   stall_int <= sink_stall or source_stall;

   source_valid_ctrl <= valid and not sink_stall;
   sink_ready_ctrl <= ready and not source_stall;
   stall <= stall_int;

  res_reg : process (clk, reset)
  begin  -- process res_reg
    if reset = '1' then
      res <= '1';
    elsif rising_edge(clk) then
      res <= '0';
    end if;
  end process res_reg;

END struct;
