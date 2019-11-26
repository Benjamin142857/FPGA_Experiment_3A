-------------------------------------------------------------------------------
-- Title         : multiplication sequence generator
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   aukui_mult_seq_gen_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
-- 
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


entity auk_dspip_ctc_umtsitlv_mult_seq_gen is
    
    port (
        prime          : in  unsigned(8 downto 0);
        g0             : in  unsigned(4 downto 0);
        start_mult_seq : in  std_logic;
	
        index          : out unsigned(8 downto 0);
        element        : out unsigned(8 downto 0);
        wr             : out std_logic;
	active         : out std_logic;
	finished       : out std_logic;

        abort          : in  std_logic;
        reset          : in  std_logic;
        enable         : in  std_logic;
        clk            : in  std_logic
        );

end auk_dspip_ctc_umtsitlv_mult_seq_gen;
 

architecture beh of auk_dspip_ctc_umtsitlv_mult_seq_gen is

    signal g0_accu_tmp        : unsigned(13 downto 0);
    signal g0_mult            : unsigned(13 downto 0);
    signal g0_accu            : unsigned(9 downto 0);
    signal g0_accu_dly        : unsigned(9 downto 0);
    signal g0x2               : unsigned(13 downto 0);
    signal g0x3               : unsigned(13 downto 0);
    signal g0x5               : unsigned(13 downto 0);
    signal g0x6               : unsigned(13 downto 0);
    signal g0x7               : unsigned(13 downto 0);
    signal g0x19              : unsigned(13 downto 0);
    signal finished_seq       : std_logic;
    signal start_mult_seq_dly : std_logic;
    signal count              : unsigned(8 downto 0);
    signal new_val            : std_logic;
    signal seq_active         : std_logic;


begin

    index    <= count;
    wr       <= new_val;
    element  <= g0_accu(8 downto 0)when count < prime-1 else (others => '0');
    new_val  <= '0' when g0_accu = g0_accu_dly          else
               '0'  when seq_active = '0'               else
               '1';
    active   <= seq_active;
    finished <= finished_seq;

    g0x2  <= "000"&g0_accu&'0';
    g0x3  <= ("000"&g0_accu&'0') + g0_accu;
    g0x5  <= ("00"&g0_accu&"00") + g0_accu;
    g0x6  <= ("00"&g0_accu&"00") + (g0_accu&'0');
    g0x7  <= ("00"&g0_accu&"00") + (g0_accu&'0') + g0_accu;
    g0x19 <= (g0_accu&"0000") + (g0_accu&'0') + g0_accu;

    sel_mult : process (g0, g0x2, g0x3, g0x5, g0x6, g0x7, g0x19, g0_accu)
    begin  -- process sel_mult
        case g0 is
            when "00010" => g0_mult <= g0x2;
            when "00011" => g0_mult <= g0x3;
            when "00101" => g0_mult <= g0x5;
            when "00110" => g0_mult <= g0x6;
            when "00111" => g0_mult <= g0x7;
            when "10011" => g0_mult <= g0x19;
            when others  => g0_mult <= (others => '-');
        end case;
    end process sel_mult;


    accumulate : process (clk, reset)

    begin  -- process accumulate
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            g0_accu_tmp         <= (others => '0');
            g0_accu             <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if abort = '1' then
                g0_accu_tmp     <= (others => '0');
                g0_accu         <= (others => '0');
            elsif enable = '1' then
                if start_mult_seq = '1' and start_mult_seq_dly = '0' then  -- first value
                    g0_accu_tmp <= to_unsigned(1, 14);
                    g0_accu     <= to_unsigned(1, 10);
                elsif new_val = '1' then
                    g0_accu_tmp <= g0_mult;
                elsif g0_accu_tmp > prime then  -- modulo substraction
                    g0_accu_tmp <= g0_accu_tmp - prime;
                else                    -- get ready for next iteration
                    g0_accu     <= g0_accu_tmp(9 downto 0);
-- g0_accu_tmp <= g0_mult;
                end if;
            end if;
        end if;
    end process accumulate;

    delay_reg : process (clk, reset)

    begin  -- process delay_reg
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            start_mult_seq_dly     <= '0';
            g0_accu_dly            <= (others => '1');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if abort = '1' then
                start_mult_seq_dly <= '0';
                g0_accu_dly        <= (others => '1');
            elsif enable = '1' then
                start_mult_seq_dly <= start_mult_seq;
                g0_accu_dly        <= g0_accu;
            end if;
        end if;
    end process delay_reg;


    index_counter : process (clk, reset)

    begin  -- process SM_COUNTER
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            count        <= (others => '0');
            seq_active   <= '0';
            finished_seq <= '0';
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if abort = '1' then
                count <= (others => '0');
                seq_active <= '0';
                finished_seq <= '0';
            elsif enable = '1' then
                
                if start_mult_seq = '1' and start_mult_seq_dly = '0' then
                    seq_active <= '1';
                    count <= (others => '0');
                    finished_seq <= '0';
                elsif new_val = '1' and finished_seq = '0' then
                    count <= count + 1;
                elsif count > prime-1 then
                    seq_active <= '0';
                    finished_seq <= '1';
                end if;
            end if;
        end if;
    end process index_counter;


end beh;



