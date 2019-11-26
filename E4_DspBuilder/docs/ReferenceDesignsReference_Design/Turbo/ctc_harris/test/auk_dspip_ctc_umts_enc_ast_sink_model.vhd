-- ================================================================================
-- (c) 2007 Altera Corporation. All rights reserved.
-- Altera products are protected under numerous U.S. and foreign patents, maskwork
-- rights, copyrights and other intellectual property laws.
-- 
-- This reference design file, and your use thereof, is subject to and governed
-- by the terms and conditions of the applicable Altera Reference Design License
-- Agreement (either as signed by you, agreed by you upon download or as a
-- "click-through" agreement upon installation andor found at www.altera.com).
-- By using this reference design file, you indicate your acceptance of such terms
-- and conditions between you and Altera Corporation.  In the event that you do
-- not agree with such terms and conditions, you may not use the reference design
-- file and please promptly destroy any copies you have made.
-- 
-- This reference design file is being provided on an "as-is" basis and as an
-- accommodation and therefore all warranties, representations or guarantees of
-- any kind (whether express, implied or statutory) including, without limitation,
-- warranties of merchantability, non-infringement, or fitness for a particular
-- purpose, are specifically disclaimed.  By making this reference design file
-- available, Altera expressly does not recommend, suggest or require that this
-- reference design file be used in combination with any other product not
-- provided by Altera.
-- ================================================================================
--
-- Description : 
--
-- A behavioural model of an avalon streaming sink. The data received by this
-- model is written to a file.
-- FILENAME_g         : the path to the output file where the data received
--                      will be written
-- RANDOM_DELAY_g     : insert random delays into the output, ie sink_ready
--                      will be asserted randomly.
-- SYMBOLS_PER_BEAT_g : As per the avalon streaming definition. For example,
--                      complex data with source_data = real & imag, will have
--                      2 symbols per beat.
-- SYMBOL_DELIMETER_g : symbols written to the file are separated by the
--                      SYMBOL_DELIMETER_g, for example it could be
--                      " " or "," or "\n".
-- SYMBOL_DATAWIDTH_g : As per avalon streaming definition. source_data will
--                      have width SYMBOL_DATAWIDTH_g*SYMBOLS_PER_BEAT_g.
--
-- $Header: $
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library std;
use std.textio.all;


entity auk_dspip_ctc_umts_enc_ast_sink_model is

  generic (
    FILENAME_g         : string         := "op.txt";
    RANDOM_DELAY_g     : natural        := 1;
    MAX_BLKSIZE_g      : natural        := 1024;
    MIN_BLKSIZE_g      : natural        := 16;
    VARIABLE_BLKSIZE_g : natural        := 1;  -- 0 for constant, 1 for random, 2 from
                                        -- array (defined in signal list)
    ERROR_SEVERITY_g   : severity_level := failure;  -- FAILURE, ERROR, WARNING, NOTE
    REPORT_AS_g        : string         := "SIGNED_INTEGER";  -- SIGNED_INTEGER, UNSIGNED_INTEGER,
                                        -- HEX (default if > 32 bits), BIN  
    REPORT_LARGE_DEC_AS_g        : string         := "HEX";  -- SIGNED_INTEGER, UNSIGNED_INTEGER,
    SYMBOLS_PER_BEAT_g : natural        := 2;
    SYMBOL_DELIMETER_g : string         := " ";
    SYMBOL_DATAWIDTH_g : natural        := 18;
    BLK_SIZE_WIDTH_g   : natural        := 13
    );
  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;
    -- enables the model
    enable     : in  std_logic;
    blksize    : in  std_logic_vector(integer(ceil(log2(real(MAX_BLKSIZE_g))))-1 downto 0) := (others => '0');
    
    -- atlantic signals
    sink_valid : in  std_logic;
    sink_ready : out std_logic;
    sink_sop   : in  std_logic;
    sink_eop   : in  std_logic;
    sink_data  : in  std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0)
    );

end entity auk_dspip_ctc_umts_enc_ast_sink_model;

-------------------------------------------------------------------------------

architecture beh of auk_dspip_ctc_umts_enc_ast_sink_model is
 constant LONG_DELAY_MULTIPLE_c : natural := 7;
 constant INFO_DELIMETER_c      : string  := " ";

  type   data_packet_t is array (SYMBOLS_PER_BEAT_g -1 downto 0) of std_logic_vector(SYMBOL_DATAWIDTH_g - 1 downto 0);
  signal data_packet : data_packet_t;

  signal sink_ready_s   : std_logic;
  signal curr_blksize   : std_logic_vector(integer(ceil(log2(real(MAX_BLKSIZE_g))))-1 downto 0);
  --error signals
  signal got_sop        : std_logic;
  signal got_eop        : std_logic;
  signal out_error_s    : std_logic_vector(1 downto 0);
  signal missing_sop    : std_logic;
  signal missing_eop    : std_logic;
  signal unexpected_eop : std_logic;
  signal unexpected_sop : std_logic;
  signal error_all      : std_logic;
  signal cnt            : natural range 0 to MAX_BLKSIZE_g - 1;

  signal blksize_sop        : std_logic_vector(BLK_SIZE_WIDTH_g - 1 downto 0) := (others => '0');
  signal sideband_change    : std_logic;
  signal sideband_sop_valid : std_logic;

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


begin  -- architecture beh
  sink_ready <= sink_ready_s;

  gen_data_packets : for i in SYMBOLS_PER_BEAT_g downto 1 generate
    data_packet(i-1) <= sink_data(i*SYMBOL_DATAWIDTH_g - 1 downto (i-1)*SYMBOL_DATAWIDTH_g);
  end generate gen_data_packets;

  testbench_o : process(clk) is
    file outfile_v          : text open write_mode is FILENAME_g;
    variable data_v         : line;
    variable signed_int_v   : integer;
    variable unsigned_int_v : natural;
    variable hex_v          : string (integer(ceil(real(SYMBOL_DATAWIDTH_g)/4.0)) downto 1);
    variable bin_v          : bit_vector(SYMBOL_DATAWIDTH_g-1 downto 0);
    variable idata_v        : integer;
  begin
    if rising_edge(clk) then
      if enable = '1' then
        if(sink_valid = '1' and sink_ready_s = '1') then
          for i in 0 to SYMBOLS_PER_BEAT_g - 1 loop
            if (SYMBOL_DATAWIDTH_g > 32 and REPORT_LARGE_DEC_AS_g = "HEX") or REPORT_AS_g = "HEX" then
              hex_v := to_hstring(signed(data_packet(i)));
              write(data_v, hex_v);
            elsif (SYMBOL_DATAWIDTH_g > 32 and REPORT_LARGE_DEC_AS_g= "BIN")  or REPORT_AS_g = "BIN" then
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
  end process testbench_o;

  gen_sink_ready : process
    variable rand_v  : real     := 0.0;
    variable seed2_v : positive := 2;
    variable seed1_v : positive := 4;
  begin  -- process gen_sink_ready
    if sink_valid = '1' then
      uniform(seed1_v, seed2_v, rand_v);
      -- if the random delay is between 0.0 and 0.3 then we do a long delay
      if (RANDOM_DELAY_g = 1 and rand_v > 0.7) or RANDOM_DELAY_g = 0 then
        sink_ready_s <= '1';
      else
        sink_ready_s <= '0';
        if rand_v < 0.3  then
          for i in 1 to LONG_DELAY_MULTIPLE_c loop
            wait until rising_edge(clk);
          end loop;
        end if;
      end if;
      wait until rising_edge(clk);
    else
      uniform(seed1_v, seed2_v, rand_v);
      if (RANDOM_DELAY_g = 1 and rand_v > 0.6) or RANDOM_DELAY_g = 0 then
        sink_ready_s <= '1';
      else
        sink_ready_s <= '0';
        if rand_v < 0.3 then
          for i in 1 to LONG_DELAY_MULTIPLE_c loop
            wait until rising_edge(clk);
          end loop;
        end if;
      end if;
      wait until rising_edge(clk);
    end if;
  end process gen_sink_ready;

  save_blksize : process (clk, reset_n)
  begin  -- process save_blksize
    if reset_n = '0' then
      curr_blksize <= (others => '0');
    elsif rising_edge(clk) then
      if enable = '1' then
        if sink_ready_s = '1' and sink_valid = '1' and sink_sop = '1' then
          curr_blksize <= blksize;
        end if;
      end if;
    end if;
  end process save_blksize;

  -----------------------------------------------------------------------------
  -- Error checking. Check that sop and eop are correct.
  -----------------------------------------------------------------------------
  error_assert : process (clk)
    variable blksize_v : natural range 0 to MAX_BLKSIZE_g := 0;
  begin  -- process error_assert
    if rising_edge(clk) then
     if VARIABLE_BLKSIZE_g = 1 or VARIABLE_BLKSIZE_g = 2 then
       blksize_v := to_integer(unsigned(curr_blksize));
     else
       blksize_v := MAX_BLKSIZE_g;
     end if;
     if blksize_v > 1 then              -- ignore missing sop and eop for blksize1
      assert not (missing_sop = '1')
        report "Avalon sink model: ERROR: Missing SOP." severity ERROR_SEVERITY_g;
      assert not (missing_eop = '1')
        report "Avalon sink model: ERROR: Missing EOP." severity ERROR_SEVERITY_g;
      assert not ( unexpected_eop = '1')
        report "Avalon sink model: ERROR: Unexpected EOP." severity ERROR_SEVERITY_g;
      assert not ( unexpected_sop = '1')
        report "Avalon sink model: ERROR: Unexpected SOP." severity ERROR_SEVERITY_g;
      assert not ( sideband_change = '1')
        report "Avalon sink model: ERROR: Sideband signal blksize has changed since values during SOP." severity ERROR_SEVERITY_g;
    end if;
     end if;
  end process error_assert;

  -- error flagged until new sop
  error_all_p : process (clk, reset_n)
  begin  -- process error_all_p
    if reset_n = '0' then
      error_all <= '0';
    elsif rising_edge(clk) then
      if enable = '1' then
        if (out_error_s(0) = '1' or out_error_s(1) = '1') then
          error_all <= '1';
        end if;
        if sink_valid = '1' and sink_ready_s = '1' and sink_sop = '1' then
          error_all <= '0';
        end if;
       end if;
    end if;
  end process error_all_p;

  out_error_s <= "01" when missing_sop = '1' else
                 "10" when missing_eop = '1'                            else
                 "11" when unexpected_eop = '1' or unexpected_sop = '1' or sideband_change = '1' else
                 "00";
  
  got_sop_p : process (clk, reset_n)
  begin  -- process got_sop
    if reset_n = '0' then
      got_sop <= '0';
    elsif rising_edge(clk) then
      if enable = '1' then
        if sink_valid = '1' and sink_ready_s = '1' and sink_sop = '1' then
          got_sop <= '1';
        end if;
        if sink_valid = '1' and sink_ready_s = '1' and sink_eop = '1' then
          got_sop <= '0';
        end if;
      end if;
    end if;
  end process got_sop_p;

  got_eop_p : process (clk, reset_n)
  begin  -- process got_sop
    if reset_n = '0' then
      got_eop <= '1';
    elsif rising_edge(clk) then
      if enable = '1' then
        if sink_valid = '1' and sink_ready_s = '1' and sink_eop = '1' then
          got_eop <= '1';
        end if;
        if (sink_valid = '1' and sink_ready_s = '1' and sink_sop = '1') then
          got_eop <= '0';
        end if;
      end if;
    end if;
  end process got_eop_p;

  -- error if get a valid when we dont have an sop.
  missing_sop_p : process (clk, reset_n)
  begin  -- process missing_sop
    if reset_n = '0' then
      missing_sop <= '0';
    elsif rising_edge(clk) then
      if enable = '1' then
        if sink_valid = '1' and sink_sop = '0' and got_sop = '0' then
          missing_sop <= '1';
        end if;
        if missing_sop = '1' then
          missing_sop <= '0';
        end if;
      end if;
    end if;
  end process missing_sop_p;


  -- error if we get and sop with no eop
  missing_eop_p : process (clk, reset_n)
   variable blksize_v : natural := 0;
  begin  -- process missing_eop_p
    if reset_n = '0' then
      missing_eop <= '0';
    elsif rising_edge(clk) then
      if enable = '1' then
     if VARIABLE_BLKSIZE_g = 1 or VARIABLE_BLKSIZE_g = 2 then
             blksize_v := to_integer(unsigned(curr_blksize));
         else
            blksize_v := MAX_BLKSIZE_g;
           end if;
           if sink_valid = '1' and sink_ready_s = '1' and 
        ((sink_sop = '1' and got_eop = '0') or (sink_eop = '0' and cnt = blksize_v - 1))then
          missing_eop <= '1';
        end if;
        if missing_eop = '1' then
          missing_eop <= '0';
        end if;
      end if;
    end if;
  end process missing_eop_p;

  -- unexpected eop (if received before all fftpts have been entered)
  unexpected_eop_p : process (clk, reset_n)
    variable blksize_v : natural := 0;
  begin  -- process unexpected_eop_p
    if reset_n = '0' then
      unexpected_eop <= '0';
    elsif rising_edge(clk) then
      if enable = '1' then
        if VARIABLE_BLKSIZE_g = 1 or VARIABLE_BLKSIZE_g = 2 then
          blksize_v := to_integer(unsigned(curr_blksize));
        else
          blksize_v := MAX_BLKSIZE_g;
        end if;
        if (sink_valid = '1' and sink_ready_s = '1' and sink_eop = '1' and cnt /= blksize_v - 1) then
          unexpected_eop <= '1';
        end if;
        if unexpected_eop = '1' then
          unexpected_eop <= '0';
        end if;
      end if;
    end if;
  end process unexpected_eop_p;

  -- unexpected sop (if received before all fftpts have been entered)
  unexpected_sop_p : process (clk, reset_n)
    variable blksize_v : natural := 0;
  begin  -- process unexpected_eop_p
    if reset_n = '0' then
      unexpected_sop <= '0';
    elsif rising_edge(clk) then
      if enable = '1' then
        if VARIABLE_BLKSIZE_g = 1 or VARIABLE_BLKSIZE_g = 2 then
          blksize_v := to_integer(unsigned(curr_blksize));
        else
          blksize_v := MAX_BLKSIZE_g;
        end if;
        if sink_valid = '1' and sink_ready_s = '1' and sink_sop = '1' and cnt /= 0 then
          unexpected_sop <= '1';
        end if;
        if unexpected_sop = '1' then
          unexpected_sop <= '0';
        end if;
      end if;
    end if;
  end process unexpected_sop_p;

  -- sideband information changes before end of blk
  -- meant to stay stable from sop through to eop
  sideband_change_p    : process (clk, reset_n)
    variable blksize_v : natural := 0;
  begin  -- process unexpected_eop_p
    if reset_n = '0' then
      sideband_change        <= '0';
      sideband_sop_valid     <= '0';
      blksize_sop            <= (others => '0');
    elsif rising_edge(clk) then
      if enable = '1' then
        if sink_valid = '1' and sink_ready_s = '1' and sink_eop = '1' then
          sideband_sop_valid    <= '0';
        end if;
        
        if sink_valid = '1' and sink_ready_s = '1' and sink_sop = '1' then
          blksize_sop        <= blksize;
          sideband_sop_valid <= '1';
        elsif (sink_valid = '1') and (sink_ready_s = '1') and (sideband_sop_valid = '1') then
          if (blksize_sop /= blksize) then
            sideband_change <= '1';
          end if;
        end if;                         -- if sink_valid = '1' and sink_ready_s = '1' and sink_sop = '1' then

        if sideband_change = '1' then
          sideband_change  <= '0';
        end if;
        
      end if;                           -- if enable = '1' then
    end if;
  end process sideband_change_p;


  cnt_p : process (clk, reset_n)
    variable blksize_v : natural := 0;
  begin  -- process cnt_p
    if reset_n = '0' then
      cnt <= 0;
    elsif rising_edge(clk) then
      if enable = '1' then
        if VARIABLE_BLKSIZE_g = 1 or VARIABLE_BLKSIZE_g = 2 then
          blksize_v := to_integer(unsigned(curr_blksize));
        else
          blksize_v := MAX_BLKSIZE_g;
        end if;
        if sink_valid = '1' and sink_ready_s = '1' then
          if cnt = blksize_v - 1 then
            cnt <= 0;
          else
            cnt <= cnt + 1;
          end if;
          if error_all = '1' and sink_sop = '0' then
            cnt <= 0;
          end if;
        end if;
        
      end if;
    end if;
  end process cnt_p;

end architecture beh;

-------------------------------------------------------------------------------
