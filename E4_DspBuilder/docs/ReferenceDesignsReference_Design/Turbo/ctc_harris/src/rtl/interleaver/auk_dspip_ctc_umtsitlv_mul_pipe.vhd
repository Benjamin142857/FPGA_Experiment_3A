-------------------------------------------------------------------------------
-- Title         : multiplier
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   aukui_mul_pipe_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
-- 
-- performs a*b = a_x_b
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $Log: $
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity auk_dspip_ctc_umtsitlv_mul_pipe is
    
    port (a      : in  unsigned(12 downto 0);
          b      : in  unsigned(7 downto 0);   -- max.89
          a_x_b : out unsigned(20 downto 0);  -- multiplication result

          reset  : in  std_logic;
          enable : in  std_logic;
          clk    : in  std_logic
	  );

end auk_dspip_ctc_umtsitlv_mul_pipe;



architecture beh of auk_dspip_ctc_umtsitlv_mul_pipe is

    signal ax1 : unsigned(20 downto 0);  
    signal ax2 : unsigned(20 downto 0);  
    signal ax4 : unsigned(20 downto 0);  
    signal ax8 : unsigned(20 downto 0); 
    signal ax16 : unsigned(20 downto 0);
    signal ax32 : unsigned(20 downto 0);
    signal ax64 : unsigned(20 downto 0);

    
begin  -- beh

    ax1  <= "00000000" & a      when b(0) = '1' else (others => '0');
    ax2  <= "0000000" & a & "0" when b(1) = '1' else (others => '0');
    ax4  <= "000000" & a & "00" when b(2) = '1' else (others => '0');
    ax8  <= "00000" & a & "000" when b(3) = '1' else (others => '0');
    ax16 <= "0000" & a & "0000" when b(4) = '1' else (others => '0');
    ax32 <= "000" & a & "00000" when b(5) = '1' else (others => '0');
    ax64 <= "00" & a & "000000" when b(6) = '1' else (others => '0');
    

    p_multiplier : process (clk, reset)
	
    begin  -- process p_divider_chain
	-- activities triggered by asynchronous reset (active high)
	if reset = '1' then
		a_x_b <= (others => '0');
	    -- activities triggered by rising edge of clock
	elsif clk'event and clk = '1' then
	    if enable = '1' then            
		    a_x_b <= ax1 + ax2 + ax4 + ax8 + ax16 + ax32 + ax64;
	    end if;
	end if;
    end process p_multiplier;
    
end beh;
