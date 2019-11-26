-------------------------------------------------------------------------------
-- Title         : umts_itlv testbench architecture
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   umts_itlv_tb_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
--
-- allows producing interleaved sequences, which need to be compared
-- against C model
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $Log: umts_itlv_tb.vhd,v $
-- Revision 1.4  2008/02/15 10:58:19  zpan
-- change some ports to internal signals
--
-- Revision 1.3  2008/02/14 00:00:04  zpan
-- change inferred ram for QII 7.2
--
-- Revision 1.2  2008/02/13 22:32:55  zpan
-- use common ctc_umts_libs
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

entity umts_itlv_testbench is
    
end umts_itlv_testbench;



architecture tb of umts_itlv_testbench is

    constant cMAX_COUNT : integer := 5;
    constant cTMEMACC : integer := 4;
    constant cCOUNTER_WIDTH : integer := 13;  
    constant cTCLK : time := 100 ns;

--    signal count : unsigned(cCOUNTER_WIDTH-1 downto 0);
    signal RxC : unsigned(cCOUNTER_WIDTH-1 downto 0);
    signal blk_size : unsigned(cCOUNTER_WIDTH-1 downto 0);
    signal prune_me : std_logic :='0';  	
    signal addr_valid : std_logic :='0';  	
    signal start_load : std_logic := '0';  	
    signal start_itlv_fwd : std_logic := '0';  	
    signal start_itlv_bwd : std_logic := '0';  	
    signal clk : std_logic := '0';  	
    signal enable : std_logic := '1';  	
    signal reset : std_logic := '0';
    signal data_in : unsigned(cCOUNTER_WIDTH-1 downto 0);
    signal out_addr : unsigned(cCOUNTER_WIDTH-1 downto 0);
    signal end_test : std_logic := '0';
    signal end_test_s : std_logic;
    
    
begin  -- tb

    data_in <= (others => '0');
    
    DUT : auk_dspip_ctc_umts_itlv
        generic map (
            gCOUNTER_WIDTH => cCOUNTER_WIDTH
            )
        port map (
            out_addr       => out_addr   ,
            RxC            => RxC        ,
            blk_size       => blk_size   ,
            addr_valid     => addr_valid ,
            start_load     => start_load ,
            seq_gen_done   => end_test,

            enable         => enable        ,
            clk            => clk        ,
            reset          => reset      
            );

    clock_generator : process
	
    begin  -- process clock_generator
      if end_test = '1' then
        clk <= '0';
        report "Done.";
        wait;
      else
    	clk <= '1';
        wait for cTCLK/2;
    	clk <= '0';
    	wait for cTCLK/2;
      end if;
    end process clock_generator;

    -- purpose: generates reset
    -- type:    memoryless
    -- inputs:  
    -- outputs: RSTB
    reset_generator : process
    	
    begin  -- process reset_generator
      if end_test = '1' then
        reset <= '1';
        wait;
      else
        wait for cTCLK;
    	reset <= '1';
    	wait for cTCLK * 2;
    	reset <= '0';
      end if;
	wait;
	
    end process reset_generator;

    start_cnt_generator : process
    	
    begin  -- process start_cnt_generator
    	start_load <= '0';
    	start_itlv_fwd <= '0';
    	start_itlv_bwd <= '0';
	    wait for 1 ns;
    	wait for cTCLK * 20;
    	start_load <= '1';
    	wait for cTCLK * 1;
    	start_load <= '0';
--    	wait for cTCLK * 600;
--    	wait for cTCLK * 500;
--    	start_itlv_fwd <= '1';
    	wait for cTCLK * 20;
--    	start_itlv_fwd <= '0';
	wait;
	
    end process start_cnt_generator;

--
-- UNCOMMENT THIS TO CHECK SETUP FOR DIFFERENT LENGTHS
--    nsamples_generator : process
--	  
--    begin  -- process nsamples_generator
--	  nsamples <= to_unsigned(341, cCOUNTER_WIDTH);
--	  wait for cTCLK * 150;
--	  nsamples <= to_unsigned(361, cCOUNTER_WIDTH);
--	  wait for cTCLK * 150;
--	  nsamples <= to_unsigned(5120, cCOUNTER_WIDTH);
--	  wait;
--    end process nsamples_generator;

    nsamples_generator : process
	
    begin  -- process nsamples_generator
--	nsamples <= to_unsigned(320, cCOUNTER_WIDTH);  -- ok
--	nsamples <= to_unsigned(341, cCOUNTER_WIDTH);  -- ok
--	  nsamples <= to_unsigned(481, cCOUNTER_WIDTH);  -- ok
--	  nsamples <= to_unsigned(530, cCOUNTER_WIDTH);  -- ok
--	  nsamples <= to_unsigned(2300, cCOUNTER_WIDTH);  -- ok
--	  nsamples <= to_unsigned(5120, cCOUNTER_WIDTH);  -- ok
	blk_size <= to_unsigned(5114, cCOUNTER_WIDTH); 
	wait;
    end process nsamples_generator;


end tb;
