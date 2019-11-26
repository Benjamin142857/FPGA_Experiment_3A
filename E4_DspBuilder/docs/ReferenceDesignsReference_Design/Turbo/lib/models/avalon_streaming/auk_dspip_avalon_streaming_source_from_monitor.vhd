-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_avalon_streaming_source_from_monitor.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/models/avalon_streaming/auk_dspip_avalon_streaming_source_from_monitor.vhd,v $
--
-- $Revision: 1.1 $
-- $Date: 2007/02/26 17:41:19 $
-- Check in by     : $Author: kmarks $
-- Author   :  kmarks
--
-- Project      :  auk_dspip_lib
--
-- Description : 
--
-- A behavioural model (used for testbench purposes) of an avalon streaming
-- source controller,  that feeds data from a file onto an avalon streaming bus.
-- 
--    FILENAME_g         : path to the input file containing data in format
--                         descibed below
--    RANDOM_DELAY_g     : insert random delays in the input. ie source valid
--                         will be asserted randomly.
--    MAX_BLKSIZE_g      : For streaming block based cores, this is the maximum
--                         block size. For cores that do not have variable
--                         block sizes (ie VARIABLE_BLKSIZE_g = 0), the blksize
--                         used will be MAX_BLKSIZE_g.
--    MIN_BLKSIZE_g      : For streaming block based cores, this is the minimum
--                         block size. For cores that do not have variable
--                         block sizes (ie VARIABLE_BLKSIZE_g = 0), set this to
--                         the same as the MAX_BLKSIZE_g
--    VARIABLE_BLKSIZE_g : 1 = Randomly vary the block size between MIN_BLKSIZE_g
--                             and MAX_BLKSIZE_g (only pwrs of 2).
--                         0 = Keep block size as MAX_BLKSIZE_g.
--                         2 = Block size specified in array  (NOT IMPLEMENTED
--                         YET).
--    REPORT_BLKSIZE_g   : A value of true will cause the model to write the
--                         (random) block sizes it uses to BLKSIZE_REPORT_FILE_g.
--    BLKSIZE_REPORT_FILE_g :path to the block size report file. The block
--                           sizes generated will be written into this report
--                           file. If REPORT_BLKSIZE_g = false then this can be
--                           set to "".
--    SYMBOLS_PER_BEAT_g : As per avalon streaming definition. For example,
--                         complex data with source_data = real & imag, will have
--                         2 symbols per beat.
--    SYMBOL_DELIMETER_g : symbols in beat are separated by the
--                         SYMBOL_DELIMETER_g, for example it could be
--                         " " or "," or "\n".
--    SYMBOL_DATAWIDTH_g : As per avalon streaming definition. source_data will
--                         have width SYMBOL_DATAWIDTH_g*SYMBOLS_PER_BEAT_g.
--
--  Input file format should start with the indentifier
--  NUMSYMBOLS <insert number of words in the file>
--  The remainer of the file contains the data to be sent out. Each beat should
--  be printed with the symbols separated by the SYMBOL_DELIMETER_g. After each
--  beat there should be a new line. For example if SYMBOL_DELIMETER_g = " "
--  and there are 2 symbols per beat, then the input file will have the format
-------------------------------------------------------------------------------
--   #NUMSYMBOLS 6
--   <symbol 1> <symbol 2>
--   <symbol 3> <symbol 4>
--   <symbol 5> <symbol 6>
-------------------------------------------------------------------------------
-- Alternatively if the delimeter was "\n" the format would be
-------------------------------------------------------------------------------
--   #NUMSYMBOLS 6
--   <symbol 1>
--   <symbol 2>
--   <symbol 3>
--   <symbol 4>
--   <symbol 5>
--   <symbol 6>
-------------------------------------------------------------------------------
-- $Log: auk_dspip_avalon_streaming_source_from_monitor.vhd,v $
-- Revision 1.1  2007/02/26 17:41:19  kmarks
-- updates
--
-- Revision 1.8  2007/01/10 15:18:52  kmarks
-- bug fix - if the number of words is not specified at the top of the file and the source is to generate variable block sizes, then the code always generated size 1 block size due to a bug.
--
-- Revision 1.7  2006/11/24 16:50:29  sdemirso
-- merging from branch 6.1
--
-- Revision 1.4.2.4  2006/10/04 14:45:59  kmarks
-- Updated to include ERROR_TEST_g for testing erroneious avalon streaming input
--
-- Revision 1.4.2.3  2006/09/18 12:48:10  kmarks
-- updated to stop test when sent in the number of symbols indicated at top of file
--
-- Revision 1.4.2.2  2006/09/18 12:35:39  kmarks
-- updated to stop test when sent in the number of symbols indicated at top of file
--
-- Revision 1.4.2.1  2006/09/15 21:35:49  sdemirso
-- a small paranthese change. doesn't effect the functionality.
--
-- Revision 1.4  2006/09/08 18:21:33  kmarks
-- blksize change
--
-- Revision 1.3  2006/09/05 10:18:20  kmarks
-- bug fix with eof, valid still asserted when eof
--
-- Revision 1.2  2006/08/31 08:15:53  kmarks
-- updated source model to have eof as output.
--
-- Revision 1.1  2006/08/18 13:55:17  kmarks
-- Avalon streaming testbench components - initial check in
--
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library std;
use std.textio.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

-------------------------------------------------------------------------------

entity auk_dspip_avalon_streaming_source_from_monitor is

  generic (
    FILENAME_g         : string;
    READ_SYMBOLS_AS_g  : string  := "SIGNED_INTEGER";
    SYMBOLS_PER_BEAT_g : natural := 2;
    SYMBOL_DATAWIDTH_g : natural := 18
    );
  port (
    clk          : in  std_logic;
    reset_n      : out  std_logic;
    -- atlantic signals
    source_valid : out std_logic;
    source_ready : in  std_logic;
    source_sop   : out std_logic;
    source_eop   : out std_logic;
    source_data  : out std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0);
    eof          : out std_logic
    );

end entity auk_dspip_avalon_streaming_source_from_monitor;

-------------------------------------------------------------------------------

architecture beh of auk_dspip_avalon_streaming_source_from_monitor is

  signal source_valid_s : std_logic;
  signal source_eop_s   : std_logic;
  signal source_sop_s   : std_logic;
  type   data_packet_t is array (SYMBOLS_PER_BEAT_g -1 downto 0) of std_logic_vector(SYMBOL_DATAWIDTH_g - 1 downto 0);
  signal data_packet    : data_packet_t;


  function hstring_to_std_logic_vector(value : in string) return std_logic_vector is
    variable pad    : integer;
    variable result : std_logic_vector(SYMBOL_DATAWIDTH_g -1 downto 0);
    variable quad   : std_logic_vector(3 downto 0);
  begin
    for i in 1 downto value'length loop
      case value(i) is
        when '0'    => quad := (others => '0');
        when '1'    => quad := "0001";
        when '2'    => quad := "0010";
        when '3'    => quad := "0011";
        when '4'    => quad := "0100";
        when '5'    => quad := "0101";
        when '6'    => quad := "0110";
        when '7'    => quad := "0111";
        when '8'    => quad := "1000";
        when '9'    => quad := "1001";
        when 'A'    => quad := "1010";
        when 'B'    => quad := "1011";
        when 'C'    => quad := "1100";
        when 'D'    => quad := "1101";
        when 'E'    => quad := "1110";
        when 'F'    => quad := "1111";
        when others => quad := "----";
      end case;
      if i = value'length and (value'length*4 /= SYMBOL_DATAWIDTH_g)then
        -- truncate the last bits
        pad                            := (value'length*4 mod SYMBOL_DATAWIDTH_g);
        result(result'high downto i*4) := quad(pad - 1 downto 0);
      else
        result((i+1)*4 - 1 downto i*4) := quad;
      end if;
    end loop;  -- i
    return result;
  end function hstring_to_std_logic_vector;



begin  -- architecture beh

  source_sop   <= source_sop_s ;
  source_eop   <= source_eop_s ;
  source_valid <= source_valid_s ;

  gen_source_data : for i in SYMBOLS_PER_BEAT_g downto 1 generate
    source_data(i*SYMBOL_DATAWIDTH_g - 1 downto (i-1)*SYMBOL_DATAWIDTH_g) <= data_packet(i-1);
  end generate gen_source_data;


  -- file reading process
  testbench_i : process is
    file infile_v              : text open read_mode is FILENAME_g;
    variable data_v            : line;
    variable std_logic_v       : bit;
    variable start : boolean:= true;
    variable int_v             : integer;
    variable symbol_v          : string(SYMBOL_DATAWIDTH_g downto 1);
    variable symbol_hex_v      : string(integer(ceil(real(SYMBOL_DATAWIDTH_g/4))) downto 1);
     begin
    if (not endfile(infile_v)) then
      eof <= '0';
      readline(infile_v, data_v);
      if data_v(1) /= '#' then
        --read clk cnt
        read(data_v, int_v);
        -- read reset_n
        read(data_v, std_logic_v);
        reset_n      <=  To_StdULogic(std_logic_v);
        -- read avs_valid
        read(data_v, std_logic_v);
        source_valid_s <= To_StdULogic(std_logic_v);
        -- read avs_ready
        read(data_v, std_logic_v);
        assert source_ready = To_StdULogic(std_logic_v) report "DIFFERENCE : avs_ready does not match simulation." severity warning;
        -- read avs_sop
        read(data_v, std_logic_v);
        source_sop_s <= To_StdULogic(std_logic_v);
        -- read avs_eop
        read(data_v, std_logic_v);
        source_eop_s <= To_StdULogic(std_logic_v);
        -- read data
        for i in SYMBOLS_PER_BEAT_g - 1 downto 0 loop
          -- read avs_eop
          if READ_SYMBOLS_AS_g = "SIGNED_INTEGER" then
            read(data_v, int_v);
            data_packet(i) <= std_logic_vector(to_signed(int_v, SYMBOL_DATAWIDTH_g));
          elsif READ_SYMBOLS_AS_g = "HEX" then
            read(data_v, symbol_hex_v);
            -- convert string to std_logic_vector
            data_packet(i) <= hstring_to_std_logic_vector(symbol_hex_v);
          elsif READ_SYMBOLS_AS_g = "BIN" then
            read(data_v, symbol_v);
            -- convert string to binary
            for j in 0 to SYMBOL_DATAWIDTH_g loop
              if symbol_v(i) = '0' then
                data_packet(i)(j) <= '0';
              else
                data_packet(i)(j) <= '1';
              end if;
            end loop;  -- i
          else
            assert false report "FORMAT not supported" severity error;
          end if;
        end loop;
        
      end if;
      else
        eof <= '1';
    end if;
    if start = false then
    wait until rising_edge(clk);
     else
     wait for 1 ns;
     start := false;
 end if; 
end process testbench_i;



end architecture beh;
  
-------------------------------------------------------------------------------
