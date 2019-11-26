-------------------------------------------------------------------------------
-- Title         : umts_itlv_setup_control
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   aukui_setup_control_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
--
-- state machine controlling the setup procedure of the interleaver
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $log$
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

entity auk_dspip_ctc_umtsitlv_setup_control is

    generic (
        gCNT_WIDTH : integer := 13
        );

    port (
        start_setup       : in  std_logic;
        itlv_setup_active : out std_logic;
        itlv_rdy          : out std_logic;

        R10not20 : out std_logic;
        R        : out unsigned(4 downto 0);
        K        : in  unsigned(12 downto 0);
        C        : out unsigned(8 downto 0);
        RxC      : out unsigned(12 downto 0);
        prime    : out unsigned(8 downto 0);
        g0       : out unsigned(4 downto 0);

        gcd_index : out unsigned(4 downto 0);
        gcd       : out unsigned(7 downto 0);
        wr_gcd    : out std_logic;

        gen_mul_seq_finished : in  std_logic;
        start_gen_mul_seq    : out std_logic;

        flag_a  : out std_logic;
        flag_b  : out std_logic;
        flag_b6 : out std_logic;
        flag_c  : out std_logic;

        enable : in std_logic;
        clk    : in std_logic;         
        reset                  : in  std_logic);

end auk_dspip_ctc_umtsitlv_setup_control;



architecture beh of auk_dspip_ctc_umtsitlv_setup_control is
    type STATES is (
        IDLE,
        INITIALIZE,
        SAVE_K,
        CASE1,
        CASE2,
        FIND_PRIME,
        SAVE_PRIME,
        SAVE_PRIME_2,
        SAVE_C,
        START_GEN_MUL,
        FILL_TABLE_C,
        START_TABLE_P,
        FILL_TABLE_P
        );

    signal STATE                    : STATES;
    signal gcd_index_int            : unsigned(4 downto 0);
-- signal gcd_index : unsigned(4 downto 0);
-- signal gcd : unsigned(7 downto 0);
    signal C_int                    : unsigned(8 downto 0);
    signal R_int                    : unsigned(4 downto 0);
    signal itlv_length              : unsigned(12 downto 0);
    signal prime_index              : unsigned(6 downto 0);
    signal count                    : unsigned(gCNT_WIDTH-1 downto 0);
    signal load_val                 : unsigned(gCNT_WIDTH-1 downto 0);
    signal load_cnt                 : std_logic;
    signal decr                     : std_logic;
    signal R_x_Pand1_gt_itlv_length : std_logic;
    signal sel_Cminus1              : std_logic;
    signal sel_Cplus1               : std_logic;
    signal R10not20_int             : std_logic;
    signal prime_int                : unsigned(8 downto 0);
    signal prime_and_1              : unsigned(8 downto 0);
    signal prime_minus_1            : unsigned(8 downto 0);
    signal RxC_int                  : unsigned(12 downto 0);
    signal prime_x_R                : unsigned(13 downto 0);
    signal prime_and_1_x_R          : unsigned(13 downto 0);
    signal prime_minus_1_x_R        : unsigned(13 downto 0);
    signal g0_int                   : unsigned(4 downto 0);
-- signal g0_accu : unsigned(8 downto 0);
    signal table_c_index            : unsigned(8 downto 0);
-- signal table_c_in : unsigned(8 downto 0);
-- signal wr_table_c : std_logic;


begin  -- beh

    I_prime_lut : auk_dspip_ctc_umtsitlv_prime_rom
        port map (
            prime_index => prime_index,
            prime       => prime_int,
            g0          => g0_int,
            gcd_index   => gcd_index_int,
            gcd         => gcd,
            reset       => reset,
            enable      => enable,
            clk         => clk
            );

    g0                <= g0_int;
    itlv_setup_active <= '0'                                                             when STATE = IDLE else '1';
    prime_and_1       <= prime_int + 1;
    prime_minus_1     <= prime_int - 1;
    ---------------------------------------------------------------------------
    -- version 3.1.1
    --prime_and_1_x_R <= ("0" & prime_and_1 & "0000") + ("000" & prime_and_1 & "00");
    --prime_minus_1_x_R <= ("0" & prime_minus_1 & "0000") + ("000" & prime_minus_1 & "00");
    --prime_x_R <= ("0" & prime_int & "0000") + ("000" & prime_int & "00");
    --RxC_int <= ("0" & C_int & "000") + ("000" & C_int & "0") when R10not20_int = '1' else
    --         (C_int & "0000") + ("00" & C_int & "00");
    ---------------------------------------------------------------------------
    -- version 3.2.0
    prime_and_1_x_R   <= ("0" & prime_and_1 & "0000") + ("000" & prime_and_1 & "00")     when R_int = 20   else
                         ("00" & prime_and_1 & "000") + ("0000" & prime_and_1 & "0")     when R_int = 10   else
                         ("000" & prime_and_1 & "00") + ("00000" & prime_and_1);  -- R_int = 5
    prime_minus_1_x_R <= ("0" & prime_minus_1 & "0000") + ("000" & prime_minus_1 & "00") when R_int = 20   else
                         ("00" & prime_minus_1 & "000") + ("0000" & prime_minus_1 & "0") when R_int = 10   else
                         ("000" & prime_minus_1 & "00") + ("00000" & prime_minus_1);  -- R_int = 5
    prime_x_R         <= ("0" & prime_int & "0000") + ("000" & prime_int & "00")         when R_int = 20   else
                         ("00" & prime_int & "000") + ("0000" & prime_int & "0")         when R_int = 10   else
                         ("000" & prime_int & "00") + ("00000" & prime_int);  -- R_int = 5
    RxC_int           <= (C_int & "0000") + ("00" & C_int & "00")                        when R_int = 20   else
               ("0" & C_int & "000") + ("000" & C_int & "0")                             when R_int = 10   else
               ("00" & C_int & "00") + ("0000" & C_int);


    ---------------------------------------------------------------------------

    R_x_pand1_gt_itlv_length <= '1' when prime_and_1_x_R >= itlv_length else '0';

    sel_Cplus1  <= '1' when itlv_length > prime_x_R and R10not20_int = '0'          else '0';
    sel_Cminus1 <= '1' when prime_minus_1_x_R >= itlv_length and R10not20_int = '0' else '0';

-------------------------------------------------------------------------------
-- registered the following outputs to aid synthesis
-- flag_b <= sel_Cplus1;
-- flag_b6 <= '1' when itlv_length = RxC_int and sel_Cplus1='1' else '0';
-- flag_c <= sel_Cminus1;
-- flag_a <= '1' when sel_Cplus1 = '0' and sel_Cminus1 = '0' else '0';


-- wr_table_c <= '1' when STATE = FILL_TABLE_C else '0';
-- table_c_in <= g0_accu;

    gcd_index_int <= count(4 downto 0) when STATE = FILL_TABLE_P else
                     (others => '0');
    gcd_index     <= gcd_index_int;
    wr_gcd        <= '1'               when STATE = FILL_TABLE_P else
              '0';

    start_gen_mul_seq <= '1' when STATE = START_GEN_MUL else '0';

    STATE_TRANSITION : process(clk, reset )
    begin
        if reset = '1' then
            STATE     <= IDLE;
        elsif clk'event and clk = '1' then
            if enable = '1' then

                case STATE is

                    when IDLE =>
                        if start_setup = '1' then
                            STATE <= INITIALIZE;
                        else
                            STATE <= IDLE;
                        end if;

                    when INITIALIZE =>
                        STATE <= SAVE_K;

                    when SAVE_K =>
                        if K < 481 or K > 530 then
                            STATE <= CASE2;
                        else
                            STATE <= CASE1;
                        end if;

                    when CASE1 =>
                        STATE <= START_GEN_MUL;

                    when CASE2 =>
                        if r_x_pand1_gt_itlv_length = '0' then
                            STATE <= SAVE_PRIME;
                        else
                            STATE <= CASE2;
                        end if;

                    when SAVE_PRIME =>
                        STATE <= SAVE_PRIME_2;

                    when SAVE_PRIME_2 =>
                        STATE <= SAVE_C;

                    when SAVE_C =>
                        STATE <= START_GEN_MUL;

                    when START_GEN_MUL =>
                        STATE <= FILL_TABLE_C;

                    when FILL_TABLE_C =>
                        if gen_mul_seq_finished = '1' then
                            STATE <= START_TABLE_P;
                        else
                            STATE <= FILL_TABLE_C;
                        end if;

                    when START_TABLE_P =>
                        STATE <= FILL_TABLE_P;

                    when FILL_TABLE_P =>
                        if count = 0 then
                            STATE <= IDLE;
                        else
                            STATE <= FILL_TABLE_P;
                        end if;

                    when others =>
                        STATE <= IDLE;

                end case;
            end if;
        end if;

    end process STATE_TRANSITION;


    SM_COUNTER : process (clk, reset)

    begin  -- process SM_COUNTER
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            count         <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then
                if load_cnt = '1' then
                    count <= load_val;
                elsif decr = '1' then
                    count <= count - 1;
                else
                    count <= count;
                end if;
            end if;
        end if;
    end process SM_COUNTER;

    P_FILL_TABLES : process (clk, reset)

    begin  -- process P_FILL_TABLES
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            table_c_index         <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then
                if STATE = FILL_TABLE_C then
                    table_c_index <= table_c_index + 1;
                else
                    table_c_index <= (others => '0');
                end if;
            end if;
        end if;
    end process P_FILL_TABLES;


    load_val <=
        to_unsigned(55, gCNT_WIDTH) when STATE = IDLE          else
        to_unsigned(0, gCNT_WIDTH)  when STATE = CASE2         else
        "0000" & prime_int          when STATE = SAVE_C        else
        to_unsigned(19, gCNT_WIDTH) when STATE = START_TABLE_P else
        (others => '0');

    load_cnt <= '1' when (count = 0) or (STATE = START_TABLE_P) or (STATE = SAVE_C) else '0';
    decr     <= '1' when not (STATE = IDLE)                                         else '0';

    -- OUTPUT SIGNALS
    p_save_K_and_R : process (clk, reset)

    begin  -- process p_save_K
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            itlv_length      <= (others => '0');
            R10not20_int     <= '0';
            R_int            <= to_unsigned(20, 5);
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then

                if STATE = SAVE_K then
                    itlv_length  <= K;
                    R10not20_int <= '0';  -- new oct03
                    R_int    <= to_unsigned(20, 5);  -- new oct03
                elsif STATE = CASE1 then
                    R10not20_int <= '1';
                    R_int        <= to_unsigned(10, 5);
                elsif STATE = CASE2 then
                    R10not20_int <= '0';
                    if K < 160 then
                        R_int    <= to_unsigned(5, 5);
                    elsif K < 201 then
                        R_int    <= to_unsigned(10, 5);
                    else
                        R_int    <= to_unsigned(20, 5);
                    end if;
                end if;
            end if;
        end if;
    end process p_save_K_and_R;

    p_prime : process (clk, reset)

    begin  -- process p_prime
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            prime_index         <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then
                if STATE = CASE2 or STATE = SAVE_K or STATE = INITIALIZE then
                    prime_index <= count(6 downto 0)-2;
                elsif STATE = CASE1 then
                    prime_index <= to_unsigned(14, 7);  -- index for 53
                elsif STATE = SAVE_PRIME then
                    prime_index <= prime_index + 3;
                end if;
            end if;
        end if;
    end process p_prime;


    p_C : process (clk, reset)

    begin  -- process p_C
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            C_int                 <= (others => '0');
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then
                if R10not20_int = '0' then
                    if STATE = SAVE_C then
                        if sel_Cplus1 = '1' then
                            C_int <= prime_int + 1;
                        elsif sel_Cminus1 = '1' then
                            C_int <= prime_int - 1;
                        else
                            C_int <= prime_int;
                        end if;
                    end if;
                else
                    C_int <= to_unsigned(53, 9);
                end if;
            end if;
        end if;
    end process p_C;

    ready_sig : process (clk, reset)
        
    begin  -- process ready_sig
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            itlv_rdy <= '0';
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then
                if STATE = INITIALIZE then
                    itlv_rdy <= '0';
                elsif STATE = FILL_TABLE_P and count = 0 then
                    itlv_rdy <= '1';
                end if;
            end if;
        end if;
    end process ready_sig;

    save_outputs : process (clk, reset)
        
    begin  -- process save_outputs
        -- activities triggered by asynchronous reset (active high)
        if reset = '1' then
            R10not20 <= '0';
            C <= (others => '0');
            R <= (others => '0');
            RxC <= (others => '0');
            prime <= (others => '0');
--	    g0 <= (others => '0');
            flag_b <= '0';
            flag_b6 <= '0';
            flag_c <= '0';
            flag_a <= '0';
            
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if enable = '1' then
                
                R10not20 <= R10not20_int;
                C <= C_int;
                R <= R_int;
                RxC <= RxC_int;
                prime <= prime_int;
--		    g0 <= g0_int;
                flag_b <= sel_Cplus1;
                -- flag_b6 <= '1' when itlv_length = RxC_int and sel_Cplus1='1' else '0';
                if itlv_length = RxC_int and sel_Cplus1='1' then
                    flag_b6 <= '1';
                else
                    flag_b6 <= '0';
                end if;
                flag_c <= sel_Cminus1;
                -- flag_a <= '1' when sel_Cplus1 = '0' and sel_Cminus1 = '0' else '0';
                if sel_Cplus1 = '0' and sel_Cminus1 = '0' then
                    flag_a <= '1';
                else
                    flag_a <= '0';
                end if;
                
            end if;
        end if;
    end process save_outputs;

end beh;





