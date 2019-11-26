-------------------------------------------------------------------------------
-- Title         : deinterleaved sequence generator
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $RCSfile: auk_dspip_ctc_umts_ditlv_seq_gen.vhd,v $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
-- 
-- generates the sequence of interleaved addresses.  Also indicates pruned
-- positions
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $Log: auk_dspip_ctc_umts_ditlv_seq_gen.vhd,v $
-- Revision 1.4  2008/02/15 11:42:45  zpan
-- added seq_gen_done port to indicate that interleaver can be stopped
--
-- Revision 1.3  2008/02/13 22:32:51  zpan
-- use common ctc_umts_libs
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

entity auk_dspip_ctc_umts_ditlv_seq_gen is

  port (
    ditlv_addr       : out unsigned(12 downto 0);
    ditlv_addr_valid : out std_logic;

    prune_me     : out std_logic;
    seq_gen_done : out std_logic;

    papbpc_index  : out unsigned(4 downto 0);
    papbpc_val    : in  unsigned(4 downto 0);
    table_p_index : out unsigned(4 downto 0);
    table_p_val   : in  unsigned(7 downto 0);
    table_c_index : out unsigned(8 downto 0);
    table_c_val   : in  unsigned(8 downto 0);
    prime         : in  unsigned(8 downto 0);
    R10not20      : in  std_logic;
    max_column    : in  unsigned(8 downto 0);
    itlv_length   : in  unsigned(12 downto 0);
    RxC           : in  unsigned(12 downto 0);
    R             : in  unsigned(4 downto 0);

    flag_a  : in std_logic;
    flag_b  : in std_logic;
    flag_b6 : in std_logic;
    flag_c  : in std_logic;

    start_incr : in std_logic;
    start_decr : in std_logic;
    reset      : in std_logic;
    enable     : in std_logic;
    clk        : in std_logic
    );

end auk_dspip_ctc_umts_ditlv_seq_gen;


architecture beh of auk_dspip_ctc_umts_ditlv_seq_gen is

-- constant cITLV_DLY : integer := 20;
  constant cITLV_DLY   : integer := 9;
  type     tCOLUMNDLYCHAIN is array (0 to 7) of unsigned(8 downto 0);
  signal   column_dlyx : tCOLUMNDLYCHAIN;
  type     tROWDLYCHAIN is array (0 to 7) of unsigned(4 downto 0);
  signal   row_dlyx    : tROWDLYCHAIN;

  signal count_rows        : unsigned(4 downto 0);  -- new
  signal count_columns     : unsigned(8 downto 0);  -- new
  signal count             : unsigned(12 downto 0);
  signal RxCplus5          : unsigned(12 downto 0);
  --signal compare_val_1     : unsigned(12 downto 0);
  --signal compare_val_2     : unsigned(12 downto 0);
  --signal compare_val_3     : unsigned(12 downto 0);
  signal tail_offset       : unsigned(2 downto 0);
  signal Cxrow             : unsigned(12 downto 0);
  signal Cxrow_ext         : unsigned(20 downto 0);
  signal row               : unsigned(4 downto 0);
  signal row_dly_ext       : unsigned(7 downto 0);
  signal max_row_ext       : unsigned(8 downto 0);
  signal max_row_minus_1   : unsigned(4 downto 0);
  signal max_column_ext    : unsigned(12 downto 0);
  signal column_ext        : unsigned(12 downto 0);
  signal column            : unsigned(8 downto 0);
  signal column_mod        : unsigned(8 downto 0);
  signal prime_minus_1     : unsigned(8 downto 0);
  signal papbpc_index_ext  : unsigned(12 downto 0);
  signal table_c_index_ext : unsigned(14 downto 0);
  signal table_p_val_ext   : unsigned(7 downto 0);
  signal incr              : std_logic;
  signal decr              : std_logic;
  signal tail              : std_logic;
  signal incr_tail_flag    : std_logic;
  signal start_incr_dly    : std_logic;
  signal start_decr_dly    : std_logic;
  signal incr_dly          : std_logic;
  signal decr_dly          : std_logic;
  signal addr_valid        : std_logic;
  signal prune_me_int      : std_logic;
  signal R_and_flag        : std_logic;
  signal seq_gen_done_s    : std_logic;

begin  -- beh

  prune_me         <= '1'                when prune_me_int = '1' and addr_valid = '1' else '0';
  ditlv_addr_valid <= addr_valid;
  row_dly_ext      <= "000" & row_dlyx(6);
  max_row_ext      <= to_unsigned(10, 9) when R10not20 = '1'                          else
                      "0000" & R;
  max_row_minus_1 <= to_unsigned(9, 5) when R10not20 = '1' else
                      R - 1;
  max_column_ext  <= "0000" & max_column;
  table_p_index   <= row;
  row             <= papbpc_val;
  prime_minus_1   <= prime - 1;
  papbpc_index    <= papbpc_index_ext(4 downto 0);  -- remove leading zeros
  column          <= column_ext(8 downto 0);
  table_c_index   <= table_c_index_ext(8 downto 0);
  table_p_val_ext <= table_p_val;
  Cxrow           <= Cxrow_ext(12 downto 0);

  seq_gen_done <= seq_gen_done_s;
-- tail_offset <= count(2 downto 0);


  mult_and_mod : auk_dspip_ctc_umtsitlv_multmod

    port map(
      a       => column_dlyx(1),
      b       => table_p_val_ext,
      c       => prime_minus_1,
      axbmodc => table_c_index_ext,

      reset  => reset,
      enable => enable,
      clk    => clk
      );


  mult : auk_dspip_ctc_umtsitlv_mul_pipe

    port map(
      a     => max_column_ext,
      b     => row_dly_ext(7 downto 0),
      a_x_b => Cxrow_ext,

      reset  => reset,
      enable => enable,
      clk    => clk
      );



  ctr : process(clk, reset)

  begin
    if (reset = '1') then                -- reset
      count         <= (others => '0');
      count_rows    <= (others => '0');  -- new
      count_columns <= (others => '0');  -- new
    elsif clk'event and (clk = '1') then
      if enable = '1' then

        if start_incr = '1' and start_incr_dly = '0' then
          count         <= (others => '0');
          count_rows    <= (others => '0');     -- new
          count_columns <= (others => '0');     -- new
        elsif start_decr = '1' and start_decr_dly = '0' then
          count         <= RxC-1;
          count_rows    <= max_row_minus_1;     -- new
          count_columns <= max_column-1;        -- new
        elsif (decr = '1') and count = 0 then   -- decrement
          count <= to_unsigned(cITLV_DLY-1, 13);
        elsif (decr = '1') then                 -- decrement
          count <= count-1;
          if count_rows = 0 then                -- new
            count_rows    <= max_row_minus_1;   -- new
            count_columns <= count_columns-1;   -- new
          else                                  -- new
            count_rows <= count_rows-1;         -- new
          end if;  -- new
        elsif (incr = '1') then                 -- increment
          count <= count+1;
          if count_rows < max_row_ext-1 then    -- new
            count_rows <= count_rows+1;         -- new
          else                                  -- new
            count_rows    <= (others => '0');   -- new
            count_columns <= count_columns+1;   -- new
          end if;  -- new
        elsif (incr = '0' and incr_dly = '1') then
-- count <= to_unsigned(cITLV_DLY-3, 13);
          count <= to_unsigned(cITLV_DLY, 13);  -- add 3 tail bits
        elsif (decr = '0' and decr_dly = '1') then
          count <= to_unsigned(cITLV_DLY-2, 13);
        elsif tail = '1' and not(count = 0) then
          count <= count - 1;
        else
          count <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  incrdecr : process (clk, reset)

  begin  -- process incrdecr
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      incr           <= '0';
      decr           <= '0';
      tail           <= '0';
      incr_tail_flag <= '0';
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then

        if start_decr = '1' and start_decr_dly = '0' then
          decr <= '1';
        elsif count = 0 and decr = '1'then
          decr <= '0';
        end if;
        if start_incr = '1' and start_incr_dly = '0' then
          incr <= '1';
        elsif count = RxC and incr = '1'then
          incr <= '0';
        end if;
        if incr = '0' and incr_dly = '1' then
          tail           <= '1';
          incr_tail_flag <= '1';
        elsif decr = '0' and decr_dly = '1' then
          tail <= '1';
        elsif count = 0 and tail = '1' then
          tail           <= '0';
          incr_tail_flag <= '0';
        end if;
      end if;

    end if;
  end process incrdecr;

  delay_regs : process (clk, reset)

  begin  -- process delay_regs
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      start_incr_dly <= '0';
      start_decr_dly <= '0';
      incr_dly       <= '0';
      decr_dly       <= '0';
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then

        start_incr_dly <= start_incr;
        start_decr_dly <= start_decr;
        incr_dly       <= incr;
        decr_dly       <= decr;
      end if;
    end if;
  end process delay_regs;

  tail_address : process (clk, reset)

  begin  -- process tail_address
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      tail_offset <= (others => '0');
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then

        if addr_valid = '0' then
          tail_offset <= "110";
        elsif tail_offset = "110" then
          tail_offset <= "101";
        elsif tail_offset = "101" then
          tail_offset <= "100";
        else
          tail_offset <= "000";
        end if;
      end if;
    end if;
  end process tail_address;


  r_and_flag <= '1' when max_row_minus_1 = row_dlyx(6) and flag_b6 = '1' else '0';  -- for
  -- debugging only
  modify_column : process (clk, reset)

  begin  -- process modify_column
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      column_mod <= (others => '0');
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then
        if row_dlyx(6) = max_row_minus_1 and flag_b6 = '1' then
          if column_dlyx(7) = 0 then
            column_mod <= prime;
          elsif column_dlyx(7) = prime-1 then
            column_mod <= (others => '0');
          elsif column_dlyx(7) = prime then
            column_mod <= to_unsigned(1, 9);  -- tab_c(0) = 1
          else
            if flag_c = '1' then
              column_mod <= table_c_val - to_unsigned(1, 9);
            else
              column_mod <= table_c_val;
            end if;
          end if;
        else
          if column_dlyx(7) = prime-1 then
            column_mod <= (others => '0');
          elsif column_dlyx(7) = prime then
            column_mod <= column_dlyx(7);
          else
            if flag_c = '1' then
              column_mod <= table_c_val - to_unsigned(1, 9);
            else
              column_mod <= table_c_val;
            end if;
          end if;
        end if;
      end if;
    end if;

  end process modify_column;

  gen_outputs : process (clk, reset)

  begin  -- process gen_outputs
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      ditlv_addr     <= (others => '0');
      addr_valid     <= '0';
      prune_me_int   <= '0';
      seq_gen_done_s <= '0';
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then
        -- de-interleaved address
        if (incr = '1' or incr_dly = '1') and count >= cITLV_DLY then
          ditlv_addr <= column_mod + Cxrow;
          --elsif (decr = '1' or decr_dly = '1') and RxC-cITLV_DLY > count then
          --    ditlv_addr     <= column_mod + Cxrow;
          --elsif decr = '1' and compare_val_1 > count then  -- 3 tail bits 
          --    ditlv_addr     <= itlv_length + 3;  -- applies to parity2,     
          --elsif decr = '1' and compare_val_2 > count then  -- 3 tail bits 
          --    ditlv_addr     <= itlv_length + 4;  -- applies to parity2,     
          --elsif decr = '1' and compare_val_3 > count then  -- 3 tail bits 
          --    ditlv_addr     <= itlv_length + 5;  -- applies to parity2, 
        elsif tail = '1' then
          if incr_tail_flag = '0' then
            ditlv_addr <= column_mod + Cxrow;
          elsif count < 3 then
            --ditlv_addr <= RxCplus5 - count;
            ditlv_addr <= (others => '0');
          else
            ditlv_addr <= column_mod + Cxrow;
          end if;
        else
          ditlv_addr <= (others => '0');
        end if;

        -- address valid flag
        if incr = '1' and count = cITLV_DLY then
          addr_valid <= '1';
          seq_gen_done_s <= '0';
          --elsif decr = '1' and count = RxC+2-cITLV_DLY then
          --    addr_valid <= '1';
          --elsif incr_dly = '0' and decr_dly = '0' and tail = '0' then
        elsif (count = 3) and tail = '1' then
          seq_gen_done_s <= '1';
          addr_valid <= '1';
        elsif seq_gen_done_s = '1' then
          addr_valid <= '0';
          seq_gen_done_s <= '0';
        end if;

        -- pruning indicator
        if not (decr = '1' and count > RxC-cITLV_DLY-1) and not(incr_tail_flag = '1' and count < 3) then
          if column_mod + Cxrow > itlv_length-1 then
            prune_me_int <= '1';
          else
            prune_me_int <= '0';
          end if;
        else
          prune_me_int <= '0';
        end if;
      end if;
    end if;
  end process gen_outputs;


  p_rowcoldlychain : process (clk, reset)

  begin  -- process p_rowcoldlychain
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      reset_loop : for i in 0 to 7 loop
        row_dlyx(i)    <= (others => '0');
        column_dlyx(i) <= (others => '0');
      end loop reset_loop;
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then
        
        row_dlyx(0)    <= row;
        column_dlyx(0) <= column;
        delay_loop : for i in 1 to 7 loop
          row_dlyx(i)    <= row_dlyx(i-1);
          column_dlyx(i) <= column_dlyx(i-1);
        end loop delay_loop;
      end if;
    end if;
  end process p_rowcoldlychain;



  static_after_setup : process (clk, reset)

  begin  -- process
    -- by registering these signals here, synthesis provides better results
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      --compare_val_1 <= (others => '0');
      --compare_val_2 <= (others => '0');
      --compare_val_3 <= (others => '0');
      RxCplus5 <= (others => '0');
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then
        --compare_val_1 <= RxC-cITLV_DLY+1;
        --compare_val_2 <= RxC-cITLV_DLY+2;
        --compare_val_3 <= RxC-cITLV_DLY+3;
        RxCplus5 <= itlv_length + 5;
      end if;
    end if;
  end process static_after_setup;

  column_ext       <= "0000" & count_columns;
  papbpc_index_ext <= "00000000" & count_rows;

  
  

end beh;
