-------------------------------------------------------------------------------
-- Title         : PA, PB and PC row interleaver tables
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   aukui_papbpc_table_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
--
-- look up tables containing interleaver patterns for PA, PB and PC
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


entity auk_dspip_ctc_umtsitlv_papbpc_table is
    
    port (
        itlv_length   : in  unsigned(12 downto 0);
        PAPBPC_index  : in  unsigned(5 downto 0);
        PAPBPC_val    : out unsigned(4 downto 0);

        reset         : in  std_logic;
        enable        : in  std_logic;
        clk           : in  std_logic
	);

end auk_dspip_ctc_umtsitlv_papbpc_table;

architecture beh of auk_dspip_ctc_umtsitlv_papbpc_table is

    signal PA         : unsigned(4 downto 0);
    signal PB         : unsigned(4 downto 0);
    signal PC         : unsigned(4 downto 0);
    signal PD         : unsigned(4 downto 0);
    signal sel_PA     : std_logic;
    signal sel_PB     : std_logic;
    signal sel_PC     : std_logic;
    signal sel_PD     : std_logic;
    signal select_vec : unsigned(3 downto 0);

begin  -- beh

    PA_lut : process (PAPBPC_index)

    begin  -- process prime_lut

        case PAPBPC_index is
            when "000000" => PA <= to_unsigned(19, 5);
            when "000001" => PA <= to_unsigned( 9, 5);
            when "000010" => PA <= to_unsigned(14, 5);
            when "000011" => PA <= to_unsigned( 4, 5);
            when "000100" => PA <= to_unsigned( 0, 5);
            when "000101" => PA <= to_unsigned( 2, 5);
            when "000110" => PA <= to_unsigned( 5, 5);
            when "000111" => PA <= to_unsigned( 7, 5);
            when "001000" => PA <= to_unsigned(12, 5);
            when "001001" => PA <= to_unsigned(18, 5);
            when "001010" => PA <= to_unsigned(10, 5);
            when "001011" => PA <= to_unsigned( 8, 5);
            when "001100" => PA <= to_unsigned(13, 5);
            when "001101" => PA <= to_unsigned(17, 5);
            when "001110" => PA <= to_unsigned( 3, 5);
            when "001111" => PA <= to_unsigned( 1, 5);
            when "010000" => PA <= to_unsigned(16, 5);
            when "010001" => PA <= to_unsigned( 6, 5);
            when "010010" => PA <= to_unsigned(15, 5);
            when "010011" => PA <= to_unsigned(11, 5);
            when others   => PA <= (others => '-');  -- illegal number
        end case;
    end process PA_lut;

    PB_lut : process (PAPBPC_index)

    begin  -- process prime_lut

        case PAPBPC_index is
            when "000000" => PB <= to_unsigned(19, 5);
            when "000001" => PB <= to_unsigned( 9, 5);
            when "000010" => PB <= to_unsigned(14, 5);
            when "000011" => PB <= to_unsigned( 4, 5);
            when "000100" => PB <= to_unsigned( 0, 5);
            when "000101" => PB <= to_unsigned( 2, 5);
            when "000110" => PB <= to_unsigned( 5, 5);
            when "000111" => PB <= to_unsigned( 7, 5);
            when "001000" => PB <= to_unsigned(12, 5);
            when "001001" => PB <= to_unsigned(18, 5);
            when "001010" => PB <= to_unsigned(16, 5);
            when "001011" => PB <= to_unsigned(13, 5);
            when "001100" => PB <= to_unsigned(17, 5);
            when "001101" => PB <= to_unsigned(15, 5);
            when "001110" => PB <= to_unsigned( 3, 5);
            when "001111" => PB <= to_unsigned( 1, 5);
            when "010000" => PB <= to_unsigned( 6, 5);
            when "010001" => PB <= to_unsigned(11, 5);
            when "010010" => PB <= to_unsigned( 8, 5);
            when "010011" => PB <= to_unsigned(10, 5);
            when others   => PB <= (others => '-');  -- illegal number
        end case;
    end process PB_lut;

    PC_lut : process (PAPBPC_index)

    begin  -- process prime_lut

        case PAPBPC_index is
            when "000000" => PC <= to_unsigned(9, 5);
            when "000001" => PC <= to_unsigned(8, 5);
            when "000010" => PC <= to_unsigned(7, 5);
            when "000011" => PC <= to_unsigned(6, 5);
            when "000100" => PC <= to_unsigned(5, 5);
            when "000101" => PC <= to_unsigned(4, 5);
            when "000110" => PC <= to_unsigned(3, 5);
            when "000111" => PC <= to_unsigned(2, 5);
            when "001000" => PC <= to_unsigned(1, 5);
            when "001001" => PC <= to_unsigned(0, 5);
            when others   => PC <= (others => '-');  -- illegal number
        end case;
    end process PC_lut;


    PD_lut : process (PAPBPC_index)

    begin  -- process prime_lut

        case PAPBPC_index is
            when "000000" => PD <= to_unsigned(4, 5);
            when "000001" => PD <= to_unsigned(3, 5);
            when "000010" => PD <= to_unsigned(2, 5);
            when "000011" => PD <= to_unsigned(1, 5);
            when "000100" => PD <= to_unsigned(0, 5);
            when others   => PD <= (others => '-');  -- illegal number
        end case;
    end process PD_lut;


    select_vec <= sel_PA & sel_PB & sel_PC & sel_PD;

    -- purpose: <description>
    select_table : process (clk, reset)

    begin  -- process select_table
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            PAPBPC_val     <= (others => '1');  -- illegal number
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then

                case select_vec is
                    when "1000" => PAPBPC_val <= PA;
                    when "0100" => PAPBPC_val <= PB;
                    when "0010" => PAPBPC_val <= PC;
                    when "0001" => PAPBPC_val <= PD;
                    when others => PAPBPC_val <= (others => '1');  -- illegal number
                end case;
            end if;

        end if;
    end process select_table;

    select_table_sigs : process (clk, reset)

    begin  -- process select_table_sigs
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            sel_PA         <= '0';
            sel_PB         <= '0';
            sel_PC         <= '0';
            sel_PD         <= '0';
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then
                
                if (itlv_length < 160) then
                    sel_PA <= '0';
                    sel_PB <= '0';
                    sel_PC <= '0';
                    sel_PD <= '1';
                elsif (itlv_length < 201) then
                    sel_PA <= '0';
                    sel_PB <= '0';
                    sel_PC <= '1';
                    sel_PD <= '0';
                elsif (itlv_length < 481) then
                    sel_PA <= '1';
                    sel_PB <= '0';
                    sel_PC <= '0';
                    sel_PD <= '0';
                elsif (itlv_length < 531) then
                    sel_PA <= '0';
                    sel_PB <= '0';
                    sel_PC <= '1';
                    sel_PD <= '0';
                elsif (itlv_length < 2281) then
                    sel_PA <= '1';
                    sel_PB <= '0';
                    sel_PC <= '0';
                    sel_PD <= '0';
                elsif(itlv_length < 2481) then
                    sel_PA <= '0';
                    sel_PB <= '1';
                    sel_PC <= '0';
                    sel_PD <= '0';
                elsif (itlv_length < 3161) then
                    sel_PA <= '1';
                    sel_PB <= '0';
                    sel_PC <= '0';
                    sel_PD <= '0';
                elsif (itlv_length < 3211) then
                    sel_PA <= '0';
                    sel_PB <= '1';
                    sel_PC <= '0';
                    sel_PD <= '0';
                elsif (itlv_length < 5115) then
                    sel_PA <= '1';
                    sel_PB <= '0';
                    sel_PC <= '0';		    
                    sel_PD <= '0';
                else
                    sel_PA <= '-';
                    sel_PB <= '-';
                    sel_PC <= '-';		    
                    sel_PD <= '-';
                end if;    
            end if;
        end if;
    end process select_table_sigs;
    
end beh ;

