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
-- $Header: //depot/ssg/main/turbo/ctc_umts/test/auk_dspip_avalon_streaming_source_model.vhd#1 $
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-------------------------------------------------------------------------------

entity auk_dspip_avalon_streaming_source_model is

  generic (
    FILENAME_g            : string;
    RANDOM_DELAY_g        : natural := 1;
    RANDOM_FRAME_DELAY_g  : natural := 1;
    ERROR_TEST_g          : natural := 0;
    MAX_BLKSIZE_g         : natural := 1024;
    MIN_BLKSIZE_g         : natural := 16;
    VARIABLE_BLKSIZE_g    : natural := 1;  -- 0 for constant, 1 for random, 2 from
                                           -- file blksize.txt
    REPORT_BLKSIZE_g      : boolean := false;
    BLKSIZE_REPORT_FILE_g : string;
    FORMAT_g              : string  := "SIGNED_INTEGER";  -- SIGNED_INTEGER, UNSIGNED_INTEGER,
                                        -- HEX (default if > 32 bits), BIN
    SOP_NUM_DATA_g        : natural := 0;  -- how many separate words as sop data
                                           -- a(data provided with sop only)
    SOP_DATAWIDTH_g       : natural := 6;
    SYMBOLS_PER_BEAT_g    : natural := 2;
    SYMBOL_DELIMETER_g    : string  := " ";
    SYMBOL_DATAWIDTH_g    : natural := 18
    );
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    -- enables the model
    enable       : in  std_logic;
    -- atlantic signals
    source_valid : out std_logic;
    source_ready : in  std_logic;
    source_sop   : out std_logic;
    source_eop   : out std_logic;
    source_data  : out std_logic_vector(SYMBOLS_PER_BEAT_g*(SYMBOL_DATAWIDTH_g) - 1 downto 0);
    -- sideband signals
    blksize      : out std_logic_vector(integer(ceil(log2(real(MAX_BLKSIZE_g))))-1 downto 0);
    sop_data     : out std_logic_vector(SOP_DATAWIDTH_g*SOP_NUM_DATA_g -1 downto 0);
    eof          : out std_logic
    );

end entity auk_dspip_avalon_streaming_source_model;

-------------------------------------------------------------------------------

architecture beh of auk_dspip_avalon_streaming_source_model is



  signal numwords       : natural;
  signal sample_cnt     : natural;
  signal frame_cnt      : natural;
  signal blksize_s      : std_logic_vector(integer(ceil(log2(real(MAX_BLKSIZE_g)))) - 1 downto 0);
  signal source_valid_s : std_logic;
  signal source_eop_s   : std_logic;
  signal source_sop_s   : std_logic;
  signal start          : std_logic;
  signal end_test       : std_logic;
  type   data_packet_t is array (SYMBOLS_PER_BEAT_g -1 downto 0) of std_logic_vector(SYMBOL_DATAWIDTH_g - 1 downto 0);
  signal data_packet    : data_packet_t;
  signal read_to_eof    : std_logic;

  signal inter_frame_delay     : natural;
  signal inter_frame_delay_cnt : natural;
  signal inter_frame_pause     : std_logic;
  
begin  -- architecture beh

  source_sop   <= source_sop_s and enable;
  source_eop   <= source_eop_s and enable;
  source_valid <= source_valid_s and enable;
  blksize      <= blksize_s;


  gen_source_data : for i in SYMBOLS_PER_BEAT_g downto 1 generate
    source_data(i*SYMBOL_DATAWIDTH_g - 1 downto (i-1)*SYMBOL_DATAWIDTH_g) <= data_packet(i-1);
  end generate gen_source_data;


  -- file reading process
  testbench_i : process(clk, reset_n) is
    file infile_v              : text open read_mode is FILENAME_g;
    variable rdata_v           : integer;
    variable rdata_sl_v        : std_logic_vector(SYMBOL_DATAWIDTH_g - 1 downto 0);
    variable data_v            : line;
    variable numwords_v        : integer;
    variable identifier_v      : string(10 downto 1);
    variable identifier_hash_v : string(1 downto 1);
    variable rand_v            : real     := 0.0;
    variable seed2_v           : positive := 2;
    variable seed1_v           : positive := 4;
    variable read_identifier_v : boolean  := false;
  begin
    if reset_n = '0' then
      if read_identifier_v = false then
        read_to_eof       <= '0';
        read_identifier_v := true;
        readline(infile_v, data_v);
        read(data_v, identifier_hash_v);
        if (identifier_hash_v = "#") then
          read(data_v, identifier_v);
          -- read the number of words
          read(data_v, numwords_v);
          numwords <= numwords_v;
        else
          -- check for numwords identifier
          report "NUMSYMBOLS not found at start of file, reading entire file." severity note;
          read_to_eof <= '1';
          numwords    <= 0;
          --reopen the file to reset the file pointer to the start of the file
          file_close(infile_v);
          file_open(infile_v, FILENAME_g, read_mode);
        end if;
      end if;
      data_packet    <= (others => (others => '0'));
      source_valid_s <= '0';
      eof            <= '0';
      file_close(infile_v);
      file_open(infile_v, FILENAME_g, read_mode);
    elsif rising_edge(clk) then
      if enable = '1' then
        if (not endfile(infile_v)) and (end_test = '0') then
          uniform(seed1_v, seed2_v, rand_v);
          if ((RANDOM_DELAY_g = 1 and rand_v > 0.2) or (RANDOM_DELAY_g = 0) ) and
          ((RANDOM_FRAME_DELAY_g = 1 and inter_frame_pause = '0') or RANDOM_FRAME_DELAY_g = 0) then
               if((source_valid_s = '1' and source_ready = '1') or source_valid_s = '0') then
                if SYMBOL_DELIMETER_g = "\n" then
                  for i in 0 to SYMBOLS_PER_BEAT_g - 1 loop
                    readline(infile_v, data_v);
                    if FORMAT_g = "HEX" then
                      -- read in as hexadecimal
                      hread(data_v, rdata_sl_v);
                      data_packet(i) <= rdata_sl_v;
                    else
                      read(data_v, rdata_v);
                      data_packet(i) <= std_logic_vector(to_signed(rdata_v, SYMBOL_DATAWIDTH_g));
                    end if;
                    -- if we arent reading to the eof, then we read up to the
                    -- number of symbols specified
                    if read_to_eof = '0' then
                      numwords <= numwords - 1;
                    end if;
                  end loop;  -- i
                else
                  readline(infile_v, data_v);
                  for i in 0 to SYMBOLS_PER_BEAT_g - 1 loop
                    if FORMAT_g = "HEX" then
                      -- read in as hexadecimal
                      hread(data_v, rdata_sl_v);
                      data_packet(i) <= rdata_sl_v;
                    else
                      read(data_v, rdata_v);
                      data_packet(i) <= std_logic_vector(to_signed(rdata_v, SYMBOL_DATAWIDTH_g));
                    end if;
                    if read_to_eof = '0' then
                      numwords <= numwords - 1;
                    end if;
                  end loop;  -- i
                end if;
                source_valid_s <= '1';
            end if;
          else
            -- insert random input pause
            if source_ready = '0' and source_valid_s = '1' then
              source_valid_s <= '1';
              data_packet    <= data_packet;
            else
              source_valid_s <= '0';
              data_packet    <= (others => (others => '0'));
            end if;
          end if;
        else
          -- end of file
          if (source_ready = '1' and source_valid_s = '1') or source_valid_s = '0' then
            eof            <= '1';
            source_valid_s <= '0';
            data_packet    <= (others => (others => '0'));
          end if;
        end if;
      end if;
    end if;
  end process testbench_i;


  inter_frame_p : process (clk, reset_n)
    variable rand_v  : real     := 0.0;
    variable seed2_v : positive := 4;
    variable seed1_v : positive := 4;
    variable inter_frame_delay_v : real := 0.0;
  begin  -- process inter_frame
    if reset_n = '0' then
      inter_frame_delay     <= 0;
      inter_frame_pause     <= '0';
      inter_frame_delay_cnt <= 0;
    elsif rising_edge(clk) then
      if enable = '1' then
        if sample_cnt = unsigned(blksize_s) - 2 then
          -- get a random delay
          uniform(seed1_v, seed2_v, rand_v);
          inter_frame_delay_v := rand_v*real(2*MAX_BLKSIZE_g);
          -- scale it to be between 0 & 2 max frame sizes
          inter_frame_delay <=integer(inter_frame_delay_v);
          if integer(inter_frame_delay_v) > 0 then
            inter_frame_pause <= '1';
          end if;
        end if;
        if inter_frame_pause = '1'  then
          if inter_frame_delay_cnt <= inter_frame_delay - 1 then
            inter_frame_delay_cnt <= inter_frame_delay_cnt + 1;
          else
            inter_frame_delay_cnt <= 0;
            inter_frame_pause     <= '0';
          end if;
        end if;
      end if;
    end if;
  end process inter_frame_p;


  -- count number of words in this frame
  sample_cnt_p : process (clk, reset_n)
  begin  -- process sample_cnt
    if reset_n = '0' then
      sample_cnt <= 0;
    elsif rising_edge(clk) then
      if enable = '1' then
        if source_valid_s = '1' and source_ready = '1' then
          if sample_cnt = unsigned(blksize_s) - 1 then
            sample_cnt <= 0;
          else
            sample_cnt <= sample_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process sample_cnt_p;

  -- count the number of frames and decrement the number of words.
  track_frames_p : process (clk, reset_n)
    file outfile_v          : text;
    variable rdata_v        : integer;
    variable data_v         : line;
    variable status_v       : file_open_status := status_error;
    variable blksize_open_v : boolean          := false;
  begin  -- process track_frames_p
    if reset_n = '0' then
      frame_cnt <= 0;
      -- open the report file if requested
      if REPORT_BLKSIZE_g = true and blksize_open_v = false then
        file_open(status_v, outfile_v, BLKSIZE_REPORT_FILE_g, write_mode);
        if status_v = status_error then
          report "Could not open the file " & BLKSIZE_REPORT_FILE_g severity error;
        else
          blksize_open_v := true;
        end if;
      end if;
    elsif rising_edge(clk) then
      if enable = '1' then
        if source_valid_s = '1' and source_ready = '1' and sample_cnt = unsigned(blksize_s) - 1 then
          frame_cnt <= frame_cnt + 1;
          if REPORT_BLKSIZE_g = true then
            rdata_v := to_integer(unsigned(blksize_s));
            write(data_v, rdata_v);
            writeline(outfile_v, data_v);
          end if;
        end if;
      end if;
    end if;
  end process track_frames_p;


-- assign the current block size, randomly if generic is set. Check that
-- there are enough words in the file to output the frame
  gen_blksize : process(clk)
    variable rand_v       : real     := 0.0;
    variable seed2_v      : positive := 3;
    variable seed1_v      : positive := 9;
    variable words_left_v : natural;
    variable blksize_v    : natural;
    variable blksize_fn   : string(1 to 15) := "ctc_blksize.txt";  
    file blksize_file     : text open read_mode is blksize_fn;
    variable blksize_data : line;
  begin  -- process
    if reset_n = '0' then
      start <= '1';

      --reopen the file to reset the file pointer to the start of the file
      file_close(blksize_file);
      file_open(blksize_file, blksize_fn, read_mode);
    elsif rising_edge(clk) and enable = '1'then
      if end_test = '0' and
        ((source_eop_s = '1' and source_valid_s = '1' and source_ready = '1')or
         (start = '1' and source_valid_s = '0')) then
        start <= '0';
        case VARIABLE_BLKSIZE_g is
          when 0 =>
            -- constant block size;
            blksize_s <= std_logic_vector(to_unsigned(MAX_BLKSIZE_g, blksize_s'length));
            
          when 1 =>
            -- random block size
            uniform(seed1_v, seed2_v, rand_v);
            rand_v    := abs(rand_v)*real(MAX_BLKSIZE_g);
            -- rounded to the nearest pwr 2.
            blksize_v := integer(ceil(log2(real(integer(rand_v)))));
            blksize_v := 2**(integer(blksize_v));
            -- check there are still enough words in the file to read, otherwise
            -- use the remaining words
            if blksize_v < MIN_BLKSIZE_g then
              blksize_v := MIN_BLKSIZE_g;
            end if;
            if start = '1' and read_to_eof = '1' then
              -- first block is either pwr 2 or not
              uniform(seed1_v, seed2_v, rand_v);
              rand_v := abs(rand_v);
              if rand_v < 0.5 then
                -- change to pwr 2
                if integer(ceil(log2(real(blksize_v)))) = 0 then
                  if blksize_v*2 <= MAX_BLKSIZE_g then
                    blksize_v := blksize_v*2;
                  end if;
                end if;
              end if;
              blksize_s <= std_logic_vector(to_unsigned(blksize_v, blksize_s'length));
            elsif numwords >= blksize_v or read_to_eof = '1' then
              blksize_s <= std_logic_vector(to_unsigned(blksize_v, blksize_s'length));
              report "generating new block - random " & integer'image(blksize_v);
            else
              words_left_v := integer(floor(log2(real(numwords))));
              blksize_v    := 2**(integer(words_left_v));
              blksize_s    <= std_logic_vector(to_unsigned(blksize_v, blksize_s'length));
              report "generating new block - left over blocks " & integer'image(blksize_v);
            end if;

          when 2 =>
            -- take block size from file
            if (not endfile(blksize_file)) then
              readline(blksize_file, blksize_data);
              read(blksize_data, blksize_v);
              blksize_s <= std_logic_vector(to_unsigned(blksize_v, blksize_s'length));
              report "generating new block " & integer'image(blksize_v);
            end if;
            
          when others => null;
        end case;
      end if;
      
    end if;
    
  end process gen_blksize;

  -- assign the current block size, randomly if generic is set. Check that
-- there are enough words in the file to output the frame
  gen_sop_data : process(clk)
    variable sop_data_v : natural;
    variable sop_data_fn: string(1 to 17) := "ctc_iter_data.txt";
    file sop_data_file  : text open read_mode is sop_data_fn;
    variable data       : line;
  begin  -- process
    if reset_n = '0' then
      --reopen the file to reset the file pointer to the start of the file
      file_close(sop_data_file);
      file_open(sop_data_file, sop_data_fn, read_mode);
    elsif rising_edge(clk) and enable = '1'then
      if end_test = '0' and
        ((source_eop_s = '1' and source_valid_s = '1' and source_ready = '1')or
         (start = '1' and source_valid_s = '0')) then
        -- take block size from file
        if (not endfile(sop_data_file)) then
          readline(sop_data_file, data);
          for i in 1 to SOP_NUM_DATA_g loop
            read(data, sop_data_v);
            sop_data(i*SOP_DATAWIDTH_g -1 downto (i-1)*SOP_DATAWIDTH_g) <= std_logic_vector(to_unsigned(sop_data_v, SOP_DATAWIDTH_g));
            report "generating new sop_data " & integer'image(sop_data_v);
          end loop;  -- i
        end if;
      end if;
    end if;
  end process gen_sop_data;



  -- errors in the input test the functionality of the error handling, need at
  -- least X blocks at the input
  gen_error_input : if ERROR_TEST_g = 1 generate
    constant ERROR_CASES_c : natural := 6;  -- number of error cases to be tested
    type     error_case_t is (NO_SOP, NO_EOP, UNEXPECTED_SOP, UNEXPECTED_EOP, NO_ERROR);
    signal   error_case    : error_case_t;
  begin
    gen_errors_p : process
    begin  -- process gen_errors_p
      wait until start = '0';
      -- check that the number of words available for input is at least X blocks
      assert numwords < ERROR_CASES_c*MAX_BLKSIZE_g report "WARNING: All error cases may not be tested due to a lack of input vectors. Add more input vectors (require at least " & integer'image(ERROR_CASES_c) & " blocks)." severity warning;

      -- ERROR_CASE 1 (first block, data with no sop.)
      error_case <= NO_SOP;
      -- wait until eop, then go to next error case
      wait until sample_cnt = unsigned(blksize_s) - 1 and source_valid_s = '1' and source_ready = '1' and rising_edge(clk);

      --ERROR CASE 2 (no eop)
      error_case <= NO_EOP;
      wait until sample_cnt = unsigned(blksize_s) - 1 and source_valid_s = '1' and source_ready = '1' and rising_edge(clk);

      -- ERROR CASE 3 (unexpected sop)
      error_case <= UNEXPECTED_SOP;
      wait until sample_cnt = unsigned(blksize_s) - 1 and source_valid_s = '1' and source_ready = '1' and rising_edge(clk);

      -- ERROR CASE 4 (unexpected eop)
      error_case <= UNEXPECTED_EOP;
      wait until source_eop_s = '1' and source_valid_s = '1' and source_ready = '1' and rising_edge(clk);

      -- ERROR CASE 5 (no_error)
      error_case <= NO_ERROR;
      wait until sample_cnt = unsigned(blksize_s) - 1 and source_valid_s = '1' and source_ready = '1' and rising_edge(clk);
    end process gen_errors_p;

    sop_p : process (blksize_s, error_case, sample_cnt)
    begin  -- process sop_p
      source_sop_s <= '0';
      source_eop_s <= '0';
      case error_case is
        
        when NO_SOP =>
          if sample_cnt = unsigned(blksize_s) - 1 then
            source_eop_s <= '1';
          end if;

        when NO_EOP =>
          if sample_cnt = 0 then
            source_sop_s <= '1';
          end if;

        when UNEXPECTED_EOP =>
          if sample_cnt = 0 then
            source_sop_s <= '1';
          end if;
          if sample_cnt = unsigned(blksize_s) - 2 then
            source_eop_s <= '1';
          end if;

        when UNEXPECTED_SOP =>
          if sample_cnt = unsigned(blksize_s) - 1 or sample_cnt = 0 then
            source_sop_s <= '1';
          end if;
          if sample_cnt = unsigned(blksize_s) - 1 then
            source_eop_s <= '1';
          end if;
          
        when NO_ERROR =>
          if sample_cnt = 0 then
            source_sop_s <= '1';
          end if;
          if sample_cnt = unsigned(blksize_s) - 1 then
            source_eop_s <= '1';
          end if;

        when others =>
          source_sop_s <= '0';
          source_eop_s <= '0';
          
      end case;
    end process sop_p;
    
    
    
  end generate gen_error_input;

  -- no errors in the input, for testing data functionality
  gen_no_errors : if ERROR_TEST_g = 0 generate
    source_sop_s <= '1' when sample_cnt = 0 else
                    '0';
    source_eop_s <= '1' when sample_cnt = unsigned(blksize_s) - 1 else
                    '0';
  end generate gen_no_errors;


  end_test <= '1' when ((source_eop_s = '1' and source_ready = '1' and (numwords <= MIN_BLKSIZE_g)) or numwords = 0) and read_to_eof = '0' else
              '0' when read_to_eof = '1' else
              '0';




end architecture beh;

-------------------------------------------------------------------------------
