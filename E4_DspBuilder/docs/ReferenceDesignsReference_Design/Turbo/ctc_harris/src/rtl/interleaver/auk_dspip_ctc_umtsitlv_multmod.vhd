-------------------------------------------------------------------------------
-- Title         : multiplier/modulo combination
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   aukui_multmod_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
--
-- performs a*b mod c = axbmodc
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

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

entity auk_dspip_ctc_umtsitlv_multmod is
    
    port
	(a      : in  unsigned(8 downto 0);
	 b      : in  unsigned(7 downto 0);   -- max.89
	 c      : in  unsigned(8 downto 0);
	 axbmodc : out unsigned(14 downto 0);  -- multiplication/modulo result

	 reset  : in  std_logic;
	 enable : in  std_logic;
	 clk    : in  std_logic
	 );

end auk_dspip_ctc_umtsitlv_multmod;


architecture beh of auk_dspip_ctc_umtsitlv_multmod is

    signal c_dly1 : unsigned(8 downto 0);
    signal c_dly2 : unsigned(8 downto 0);
    signal c_dly3 : unsigned(8 downto 0);

    signal ax1_mod  : unsigned( 8 downto 0);
    signal ax2_mod  : unsigned( 9 downto 0);
    signal ax4_mod  : unsigned(10 downto 0);
    signal ax8_mod  : unsigned(11 downto 0);
    signal ax16_mod : unsigned(12 downto 0);
    signal ax32_mod : unsigned(13 downto 0);
    signal ax64_mod : unsigned(14 downto 0);

    signal ax4_mod_saved  : unsigned(10 downto 0);
    signal ax16_mod_saved : unsigned(12 downto 0);

    signal ax1_mul_in  : unsigned( 8 downto 0);
    signal ax2_mul_in  : unsigned( 9 downto 0);
    signal ax4_mul_in  : unsigned(10 downto 0);
    signal ax8_mul_in  : unsigned(11 downto 0);
    signal ax16_mul_in : unsigned(12 downto 0);
    signal ax32_mul_in : unsigned(13 downto 0);
    signal ax64_mul_in : unsigned(14 downto 0);

    signal ax124    : unsigned(10 downto 0);
    signal ax124816 : unsigned(12 downto 0);
    signal a_x_b    : unsigned(14 downto 0);

    signal a_internal : unsigned(8 downto 0);
-- signal b_internal : unsigned(7 downto 0);
    signal b_internal : unsigned(8 downto 0);
    signal b_dly1     : unsigned(7 downto 0);
    signal b_dly2     : unsigned(7 downto 0);
    signal c_internal : unsigned(8 downto 0);

begin  -- beh

    -- purpose: saves inputs
    -- type:    memorizing
    -- inputs:  clk, reset
    -- outputs: 
    save_inputs : process (clk, reset)

    begin  -- process save_inputs
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            a_internal     <= (others => '0');
            b_internal     <= (others => '0');
            c_internal     <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then

-- a_internal <= a;
-- b_internal <= b;
                c_internal     <= c(8 downto 1) & '0';  -- only even numbers are allowed
                if c < b then
                    b_internal <= b - c;
                else
                    b_internal <= '0' & b;
                end if;
                if c < a then
                    a_internal <= a - c;
                else
                    a_internal <= a;
                end if;
            end if;
        end if;
    end process save_inputs;

-- pragma translate_off
-- assert c>a or c=a report "a is greater than c -> illegal input" severity error;
-- assert not (c(0)='1') report "c is odd number -> illegal input" severity error;
-- pragma translate_on

-- ax1_mod <= a when a < c_internal else a - c_internal;
    ax1_mod <= a_internal;              -- a always smaller than c_internal
--    ax2_mod  <= a_internal & "0";
--    ax4_mod  <= a_internal & "00";
--    ax8_mod  <= a_internal & "000";
--    ax16_mod <= a_internal & "0000";
--    ax32_mod <= a_internal & "00000";
--    ax64_mod <= a_internal & "000000";

    ax2_mod <= ax1_mod & "0" when (ax1_mod & "0") < c_internal else (ax1_mod & "0") - c_internal;
    ax4_mod <= ax2_mod & "0" when (ax2_mod & "0") < c_internal else (ax2_mod & "0") - c_internal;

    save_ax4_mod : process (clk, reset)
    begin  -- process save_ax8_mod
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            ax4_mod_saved     <= (others => '0');
            ax124             <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then                
                ax4_mod_saved <= ax4_mod;
                ax124         <= ax1_mul_in + ax2_mul_in + ax4_mul_in;
            end if;
        end if;
    end process save_ax4_mod;

    ax8_mod  <= ax4_mod_saved & "0" when (ax4_mod_saved & "0") < c_dly1 else (ax4_mod_saved & "0") - c_dly1;
    ax16_mod <= ax8_mod & "0"       when (ax8_mod & "0") < c_dly1       else (ax8_mod & "0") - c_dly1;

    save_ax16_mod : process (clk, reset)
    begin  -- process save_ax8_mod
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            ax16_mod_saved     <= (others => '0');
            ax124816           <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then                
                ax16_mod_saved <= ax16_mod;
                ax124816       <= ax124 + ax8_mul_in + ax16_mul_in;
            end if;
        end if;
    end process save_ax16_mod;

    ax32_mod <= ax16_mod_saved & "0" when (ax16_mod_saved & "0") < c_dly2 else (ax16_mod_saved & "0") - c_dly2;
    ax64_mod <= ax32_mod & "0"       when (ax32_mod & "0") < c_dly2       else (ax32_mod & "0") - c_dly2;

-- ax1_mul_in <= ax1_mod when b_internal(0) = '1' else (others => '0');
    ax1_mul_in  <= ax1_mod;             -- b always odd
    ax2_mul_in  <= ax2_mod  when b_internal(1) = '1' else (others => '0');
    ax4_mul_in  <= ax4_mod  when b_internal(2) = '1' else (others => '0');
    ax8_mul_in  <= ax8_mod  when b_dly1(3) = '1'     else (others     => '0');
    ax16_mul_in <= ax16_mod when b_dly1(4) = '1'     else (others    => '0');
    ax32_mul_in <= ax32_mod when b_dly2(5) = '1'     else (others    => '0');
    ax64_mul_in <= ax64_mod when b_dly2(6) = '1'     else (others    => '0');

    p_multiplier : process (clk, reset)

    begin  -- process p_divider_chain
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            a_x_b     <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then               
                a_x_b <= ax124816 + ax32_mul_in + ax64_mul_in;
            end if;
        end if;
    end process p_multiplier;

    -- purpose: <description>
    modulo : process (clk, reset)

    begin  -- process mod
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            axbmodc     <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then                
                if a_x_b >= ((c_dly3 & "00") + (c_dly3 & '0')) then
                    axbmodc <= a_x_b - (c_dly3 & "00")- (c_dly3 & '0');
                elsif a_x_b >= ((c_dly3 & "00") + c_dly3) then
                    axbmodc <= a_x_b - (c_dly3 & "00")- c_dly3;
                elsif a_x_b >= (c_dly3 & "00") then
                    axbmodc <= a_x_b - (c_dly3 & "00");
                elsif a_x_b >= ((c_dly3 & '0') + c_dly3) then
                    axbmodc <= a_x_b - (c_dly3 & '0')- c_dly3;
                elsif a_x_b >= (c_dly3 & '0') then
                    axbmodc <= a_x_b - (c_dly3 & '0');
                elsif a_x_b >= c_dly3 then
                    axbmodc <= a_x_b - c_dly3;
                else
                    axbmodc <= a_x_b;
                end if;
            end if;
        end if;
    end process modulo;

    delay_reg : process (clk, reset)
        
    begin  -- process delay_reg
        -- activities triggered by asynchronous reset (active highw)
        if reset = '1' then
            b_dly1 <= (others => '0');
            b_dly2 <= (others => '0');
            c_dly1 <= (others => '0');
            c_dly2 <= (others => '0');
            c_dly3 <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then                
                b_dly1 <= b_internal(7 downto 0);
                b_dly2 <= b_dly1;
                c_dly1 <= c_internal;
                c_dly2 <= c_dly1;
                c_dly3 <= c_dly2;
            end if;
        end if;
    end process delay_reg;
end beh;
