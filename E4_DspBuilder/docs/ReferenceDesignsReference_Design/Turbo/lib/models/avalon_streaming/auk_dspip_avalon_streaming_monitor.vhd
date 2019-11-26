-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_avalon_streaming_monitor.vhd,v $
-- $Source: /cvs/uksw/dsp_cores/lib/models/avalon_streaming/auk_dspip_avalon_streaming_monitor.vhd,v $
--
-- $Revision: 1.3 $
-- $Date: 2007/02/26 17:41:18 $
-- Check in by     : $Author: kmarks $
-- Author   :  kmarks
--
-- Project      :  auk_dspip_lib
--
-- Description : 
--
-- Monitors the transations on a avalon streaming bus and reports them to a file.
-- FILENAME_g         : the path to the output file where the data received
--                      will be written
-- COMPARE_g          : True will make a real-time comparison to the contents
--                      of the file COMPARE_TO_FILE_g. If an error is detected,
--                      then an assertion will be made.
-- COMPARE_TO_FILE_g  : the path to the file containing hte data for the real-time
--                      comparison. Only required if COMPARE_g = true. Must
--                      have the same format as the output file (ie
--                      SYMBOL_DELIMETER_g and SYMBOLS_PER_BEAT_g)
-- IGNORE_PREFIX_g    : Lines starting with IGNORE_PREFIX_g will be ignored for
--                      the comparison
-- SYMBOLS_PER_BEAT_g : As per the avalon streaming definition. For example,
--                      complex data with source_data = real & imag, will have
--                      2 symbols per beat.
-- SYMBOL_DELIMETER_g : symbols written to the file are separated by the
--                      SYMBOL_DELIMETER_g, for example it could be
--                      " " or "," or "\n".
-- SYMBOL_DATAWIDTH_g : As per avalon streaming definition. source_data will
--                      have width SYMBOL_DATAWIDTH_g*SYMBOLS_PER_BEAT_g.
-- 
-- PRINT_CLK_REPORT_g : if true, this will prink the clk number that the
--                      transation took place at as a prefix to each line. This
--                      can be helpful to locate any problems, but if you are
--                      using a diff tool and there are any problems, then all
--                      output may mismatch (as the prefix may not be in the
--                      expected output file)
-- $Log: auk_dspip_avalon_streaming_monitor.vhd,v $
-- Revision 1.3  2007/02/26 17:41:18  kmarks
-- updates
--
-- Revision 1.2.2.1  2007/02/26 17:40:50  kmarks
-- SPR 234961
--
-- Revision 1.2  2007/01/11 16:40:50  kmarks
-- Two new generics to change the way the output is reported:
--     REPORT_LARGE_DEC_AS_g : string    := "HEX";  -- “HEX” or “BIN”
--     REPORT_AS_g           : string    := "SIGNED_INTEGER"; -- “HEX”, “BIN”, “SIGNED_INTEGER”, “UNSIGNED_INTEGER”
--
-- Previously, there was no option as to how the data was reported, it was always a signed integer. This is the default, so there should be no need to adjust your code.
-- The REPORT_LARGE_DEC_AS_g is used only when the datawidth >32.
--
-- Revision 1.1  2006/08/18 13:55:16  kmarks
-- Avalon streaming testbench components - initial check in
--
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library std;
use std.textio.all;


-------------------------------------------------------------------------------

entity auk_dspip_avalon_streaming_monitor is

  generic (
    FILENAME_g            : string    := "../out/vhdlout.txt";
    COMPARE_g             : boolean   := false;
    COMPARE_TO_FILE_g     : string    := "";
    IGNORE_PREFIX_g       : character := '#';
    SYMBOLS_PER_BEAT_g    : natural   := 2;
    REPORT_LARGE_DEC_AS_g : string    := "HEX";
    REPORT_AS_g           : string    := "SIGNED_INTEGER";
    SYMBOL_DELIMETER_g    : string    := " ";
    LOG_SIGNALS_g         : boolean   := false;
    PRINT_CLK_REPORT_g    : boolean   := false;
    SYMBOL_DATAWIDTH_g    : natural   := 18
    );
  port (
    clk       : in std_logic;
    reset_n   : in std_logic;
    -- enables the model
    enable    : in std_logic;
    -- atlantic signals
    avs_valid : in std_logic;
    avs_ready : in std_logic;
    avs_sop   : in std_logic;
    avs_eop   : in std_logic;
    -- data contains real and imaginary data, imaginary in LSW, real in MSW
    avs_data  : in std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0)
    );

end entity auk_dspip_avalon_streaming_monitor;

-------------------------------------------------------------------------------

architecture beh of auk_dspip_avalon_streaming_monitor is

  -- taken from http://www.vhdl.org/vhdl-200x/vhdl-200x-ft/packages/numeric_std_additions.vhdl
  function to_hstring (value : in signed) return string is
    constant ne     : integer        := (value'length+3)/4;
    constant NUS    : string(2 to 1) := (others => ' ');  -- NULL array
    variable pad    : std_logic_vector(0 to (ne*4 - value'length) - 1);
    variable ivalue : std_logic_vector(0 to ne*4 - 1);
    variable result : string(1 to ne);
    variable quad   : std_logic_vector(0 to 3);
  begin
    if value'length < 1 then
      return NUS;
    else
      if value (value'left) = 'Z' then
        pad := (others => 'Z');
      else
        pad := (others => value(value'high));             -- Extend sign bit
      end if;
      ivalue := pad & std_logic_vector (value);
      for i in 0 to ne-1 loop
        quad := To_X01Z(ivalue(4*i to 4*i+3));
        case quad is
          when x"0"   => result(i+1) := '0';
          when x"1"   => result(i+1) := '1';
          when x"2"   => result(i+1) := '2';
          when x"3"   => result(i+1) := '3';
          when x"4"   => result(i+1) := '4';
          when x"5"   => result(i+1) := '5';
          when x"6"   => result(i+1) := '6';
          when x"7"   => result(i+1) := '7';
          when x"8"   => result(i+1) := '8';
          when x"9"   => result(i+1) := '9';
          when x"A"   => result(i+1) := 'A';
          when x"B"   => result(i+1) := 'B';
          when x"C"   => result(i+1) := 'C';
          when x"D"   => result(i+1) := 'D';
          when x"E"   => result(i+1) := 'E';
          when x"F"   => result(i+1) := 'F';
          when "ZZZZ" => result(i+1) := 'Z';
          when others => result(i+1) := 'X';
        end case;
      end loop;
      return result;
    end if;
  end function to_hstring;


  signal filename          : string(1 to FILENAME_g'length);
  signal filewriter_enable : std_logic;

  type   data_packet_t is array (SYMBOLS_PER_BEAT_g -1 downto 0) of std_logic_vector(SYMBOL_DATAWIDTH_g - 1 downto 0);
  signal data_packet : data_packet_t;

  
begin  -- architecture beh

  gen_data_packets : for i in SYMBOLS_PER_BEAT_g downto 1 generate
    data_packet(i-1) <= avs_data(i*SYMBOL_DATAWIDTH_g - 1 downto (i-1)*SYMBOL_DATAWIDTH_g);
  end generate gen_data_packets;

  gen_log : if LOG_SIGNALS_g = true generate

  begin
    -- report file has the following format
    -- # clk_cnt   clk     reset_n   avs_valid    avs_ready     avs_sop   avs_eop avs_data(symbol high) avs_data(symbol high -1) etc
    --
    write_report_p : process (clk, reset_n) is
      file outfile_v           : text open write_mode is FILENAME_g & "_log_file.txt";
      variable data_v          : line;
      variable clk_cnt_v       : integer   := 0;
      variable signed_int_v    : integer;
      variable unsigned_int_v  : natural;
      variable hex_v           : string (integer(ceil(real(SYMBOL_DATAWIDTH_g)/4.0)) downto 1);
      variable bin_v           : bit_vector(SYMBOL_DATAWIDTH_g-1 downto 0);
      variable log_delimeter_v : character := HT;
      variable write_header_v  : boolean   := true;
    begin
      if rising_edge(clk) then
        if(write_header_v) then
          write(data_v, "# clk_cnt" & HT &  "reset_n" & HT & "avs_valid" & HT & "avs_ready" & HT & "avs_sop" & HT & "avs_eop" & HT);
          for i in SYMBOLS_PER_BEAT_g - 1 downto 0 loop
            write(data_v, "avs_data[" & integer'image(i) & "]" & HT);
          end loop;
          writeline(outfile_v, data_v);
          write_header_v := false;
        end if;
        clk_cnt_v := clk_cnt_v + 1;
        -- 
        write(data_v, integer'image(clk_cnt_v));
        write(data_v, log_delimeter_v);
        -- reset_n
        write(data_v, to_bit(reset_n));
        write(data_v, log_delimeter_v);
        -- avs_valid
        write(data_v, to_bit(avs_valid));
        write(data_v, log_delimeter_v);
        --write(data_v, to_bit(avs_valid));
        --write(data_v, log_delimeter_v);
        -- avs_ready
        write(data_v, to_bit(avs_ready));
        write(data_v, log_delimeter_v);
        -- avs_sop
        write(data_v, to_bit(avs_sop));
        write(data_v, log_delimeter_v);
        -- avs_eop
        write(data_v, to_bit(avs_eop));
        write(data_v, log_delimeter_v);
        -- data symobols
        for i in SYMBOLS_PER_BEAT_g - 1 downto 0 loop
          if (SYMBOL_DATAWIDTH_g > 32 and REPORT_LARGE_DEC_AS_g = "HEX") or REPORT_AS_g = "HEX" then
            hex_v := to_hstring(signed(data_packet(i)));
            write(data_v, hex_v);
          elsif (SYMBOL_DATAWIDTH_g > 32 and REPORT_LARGE_DEC_AS_g = "BIN") or REPORT_AS_g = "BIN" then
            bin_v := to_bitvector(data_packet(i));
            write(data_v, bin_v);
          elsif REPORT_AS_g = "SIGNED_INTEGER" then
            signed_int_v := to_integer(signed(data_packet(i)));
            write(data_v, signed_int_v);
          elsif REPORT_AS_g = "UNSIGNED_INTEGER" then
            unsigned_int_v := to_integer(unsigned(data_packet(i)));
            write(data_v, unsigned_int_v);
          end if;
          write(data_v, log_delimeter_v);
        end loop;
        writeline(outfile_v, data_v);
      end if;
    end process write_report_p;
  end generate gen_log;

  monitor_p : process(clk) is
    file outfile_v           : text open write_mode is FILENAME_g;
    variable data_v          : line;
    variable data_with_clk_v : line;
    variable rdata_v         : integer;
    variable idata_v         : integer;
    variable signed_int_v    : integer;
    variable unsigned_int_v  : natural;
    variable hex_v           : string (integer(ceil(real(SYMBOL_DATAWIDTH_g)/4.0)) downto 1);
    variable bin_v           : bit_vector(SYMBOL_DATAWIDTH_g-1 downto 0);
    variable event_time_v    : integer   := 0;
    variable clk_delimeter_v : character := ' ';
  begin
    if rising_edge(clk) then
      event_time_v := event_time_v + 1;
      if enable = '1' then
        if(avs_valid = '1' and avs_ready = '1') then
          for i in SYMBOLS_PER_BEAT_g - 1 downto 0 loop
            if PRINT_CLK_REPORT_g = true and
              (((i = SYMBOLS_PER_BEAT_g - 1) and SYMBOL_DELIMETER_g /= "\n")or
               (SYMBOL_DELIMETER_g = "\n"))then
              write(data_v, integer'image(event_time_v));
              write(data_v, clk_delimeter_v);
            end if;
            if (SYMBOL_DATAWIDTH_g > 32 and REPORT_LARGE_DEC_AS_g = "HEX") or REPORT_AS_g = "HEX" then
              hex_v := to_hstring(signed(data_packet(i)));
              write(data_v, hex_v);
            elsif (SYMBOL_DATAWIDTH_g > 32 and REPORT_LARGE_DEC_AS_g = "BIN") or REPORT_AS_g = "BIN" then
              bin_v := to_bitvector(data_packet(i));
              write(data_v, bin_v);
            elsif REPORT_AS_g = "SIGNED_INTEGER" then
              signed_int_v := to_integer(signed(data_packet(i)));
              write(data_v, signed_int_v);
            elsif REPORT_AS_g = "UNSIGNED_INTEGER" then
              unsigned_int_v := to_integer(unsigned(data_packet(i)));
              write(data_v, unsigned_int_v);
            end if;
            if SYMBOL_DELIMETER_g = "\n" then
              writeline(outfile_v, data_v);
            else
              if i > 0 then             -- dont add delimeter at end of line
                write(data_v, SYMBOL_DELIMETER_g);
              end if;
            end if;
          end loop;  -- i
          if not(SYMBOL_DELIMETER_g = "\n") then
            writeline(outfile_v, data_v);
          end if;
        end if;
      end if;
    end if;
  end process monitor_p;


  comparison_p : process (clk, reset_n)
    file comparefile_v : text;
    variable rdata_v   : integer;
    variable data_v    : line;
    variable status_v  : file_open_status := status_error;
  begin  -- process comparison_p
    if reset_n = '0' then
      if COMPARE_g = true then
        file_open(status_v, comparefile_v, COMPARE_TO_FILE_g, read_mode);
        if status_v = status_error then
          report "Could not open the file " & COMPARE_TO_FILE_g severity error;
        end if;
      end if;
    elsif rising_edge(clk) then
      if COMPARE_g = true then
        if enable = '1' then
          if(avs_valid = '1' and avs_ready = '1') then
            if SYMBOL_DELIMETER_g = "\n" then
              -- read SYMBOLS_PER_BEAT_g lines from the file
              for i in SYMBOLS_PER_BEAT_g - 1 downto 0 loop
                readline(comparefile_v, data_v);
                while (data_v(1) = IGNORE_PREFIX_g) loop
                  readline(comparefile_v, data_v);
                end loop;
                read(data_v, rdata_v);
                assert rdata_v = to_integer(signed(data_packet(i)))
                  report "Avalon streaming monitor: Error detected in received output. Received : " & integer'image(to_integer(signed(data_packet(i)))) & " Expected : " & integer'image(rdata_v) severity error;
              end loop;  -- i
            else
              -- non eol delimeted
              readline(comparefile_v, data_v);
              while (data_v(1) = IGNORE_PREFIX_g) loop
                readline(comparefile_v, data_v);
              end loop;
              for i in SYMBOLS_PER_BEAT_g - 1 downto 0 loop
                read(data_v, rdata_v);
                assert rdata_v = to_integer(signed(data_packet(i))) report "Avalon streaming monitor: Error detected in received output. Received : " & integer'image(to_integer(signed(data_packet(i)))) & " Expected : " & integer'image(rdata_v) severity error;
              end loop;  -- i
            end if;
          end if;
        end if;
      end if;
    end if;
  end process comparison_p;


end architecture beh;

-------------------------------------------------------------------------------
