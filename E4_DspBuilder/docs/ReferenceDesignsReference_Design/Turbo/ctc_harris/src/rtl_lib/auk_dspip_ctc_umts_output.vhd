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
-- Filename    : auk_dspip_ctc_umts_output.vhd
--

-- Author : Kully Dhanoa
--
-- Description : Top level for Output Interface Block
--
--               Output Interface is Avalon Streaming with Ready Latency of zero.
--               1 data bit is output at a time
--
--               The memory in this block is double buffered. If both buffers
--               are in use it will signal this information to the Turbo MAP decoders.
--               However, it will not prevent any writes occurring. This is the
--               responsibility of the MAP decoders.
------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

entity auk_dspip_ctc_umts_output is
  generic (
    NPROCESSORS_g       : positive := 8;
    OUT_WIDTH_g         : positive := 1;
    NUM_ENGINES_WIDTH_g : positive := 3;  -- log2_ceil_one(NPROCESSORS_g)
    NWORDS_BLK_WIDTH_g  : positive := 10  -- log2_ceil(FRAME_SIZE_WIDTH_c / NPROCESSORS_g)
    );
  port (
    clk                  : in  std_logic;
    reset                : in  std_logic;
    -- Interface with Turbo MAP decoders
    -- Avalon Streaming with NO BACK PRESSURE SUPPORT
    din                  : in  std_logic_vector(NPROCESSORS_g - 1 downto 0);
    din_addr             : in  std_logic_vector(NPROCESSORS_g * NWORDS_BLK_WIDTH_g - 1 downto 0);
    din_sop              : in  std_logic;
    din_eop              : in  std_logic;
    din_valid            : in  std_logic_vector(NPROCESSORS_g - 1 downto 0);
    blk_size             : in  std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
    max_num_bits_per_eng : in  std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- maximum number of bits per engine for output block
    num_bits_last_engine : in  std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- number of bits last engine for output block

    buffer_avail : out std_logic;

    -- Output interface : Avalon Streaming with Ready Latency of zero
    dout_valid    : out std_logic;
    dout_sop      : out std_logic;
    dout_eop      : out std_logic;
    dout          : out std_logic_vector(0 downto 0);
    dout_blk_size : out std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);


    dout_ready : in std_logic
    );

end entity auk_dspip_ctc_umts_output;

architecture rtl of auk_dspip_ctc_umts_output is
  -----------------------------------------------------------------------------
  -- CONSTANT DECLARATIONS
  -----------------------------------------------------------------------------
  constant OPFIFO_DWIDTH_c : integer := 3;
  constant OPFIFO_DEPTH_c  : integer := 4;
  constant OPFIFO_AWIDTH_c : integer := 2;

  constant OPMEM_RD_LATENCY_c  : integer := 3;
  constant OPMEM_DIN_DWIDTH_c  : integer := NPROCESSORS_g;
  constant OPMEM_DOUT_DWIDTH_c : integer := 1;

  -- depth of each memory storing one engines data bits; note double-buffered
  constant ENG_MEM_WADDR_WIDTH : integer := NWORDS_BLK_WIDTH_g + 1;
  constant ENG_MEM_RADDR_WIDTH : integer := ENG_MEM_WADDR_WIDTH;
  constant ENG_MEM_DEPTH       : integer := 2 ** ENG_MEM_WADDR_WIDTH;
  
  constant INFO_FIFO_DWIDTH    : integer := FRAME_SIZE_WIDTH_c + (2 * NWORDS_BLK_WIDTH_g);

  -----------------------------------------------------------------------------
  -- TYPE DECLARATIONS
  -----------------------------------------------------------------------------
  type T_INFO_FIFO is array (0 to 1) of std_logic_vector( INFO_FIFO_DWIDTH - 1 downto 0);
  type T_OP_MEM is array (0 to NPROCESSORS_g - 1, 0 to ENG_MEM_DEPTH - 1) of std_logic;
  type T_ENG_MEM is array (0 to ENG_MEM_DEPTH - 1) of std_logic;
  type T_OP_MEM_ADDR is array (0 to NPROCESSORS_g - 1) of std_logic_vector(ENG_MEM_WADDR_WIDTH - 1 downto 0);
  type T_ENG_NO_SR is array (0 to OPMEM_RD_LATENCY_c - 1) of std_logic_vector(NPROCESSORS_g - 1 downto 0);
  
  type T_OPFIFO is array (0 to OPFIFO_DEPTH_c - 1) of std_logic_vector(OPFIFO_DWIDTH_c - 1 downto 0);

  -----------------------------------------------------------------------------
  -- SIGNAL DECLARATIONS
  -----------------------------------------------------------------------------
  signal opmem_raddr    : T_OP_MEM_ADDR;
  signal opmem_waddr    : T_OP_MEM_ADDR;
  signal opmem_wren     : std_logic_vector(NPROCESSORS_g - 1 downto 0);
  signal opmem_dout     : std_logic_vector (NPROCESSORS_g - 1 downto 0);
  signal opmem_dout_bits : std_logic_vector (NPROCESSORS_g - 1 downto 0);
--  signal opmem_dout_bit : std_logic;

  signal cur_buf           : std_logic_vector(NPROCESSORS_g - 1 downto 0);

  signal din_r                    : std_logic_vector(NPROCESSORS_g - 1 downto 0);
  signal din_addr_r               : std_logic_vector(NPROCESSORS_g * NWORDS_BLK_WIDTH_g - 1 downto 0);
  signal blk_size_minus1          : std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
  signal max_nbits_minus1_per_eng : std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- maximum number of bits per engine for output block
  signal nbits_minus1_last_engine : std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- number of bits last engine for output block
  signal first_time               : std_logic;

  signal info_fifo    : T_INFO_FIFO;
  signal waddr_info   : std_logic_vector(1 downto 0);
  signal raddr_info   : std_logic_vector(1 downto 0);
  signal dout_info    : std_logic_vector(INFO_FIFO_DWIDTH - 1 downto 0);
  signal info_full_c  : std_logic;
  signal info_empty_c : std_logic;

  signal opfifo              : T_OPFIFO;
  signal waddr_opfifo        : std_logic_vector(OPFIFO_AWIDTH_c downto 0);
  signal waddr_early_opfifo  : std_logic_vector(OPFIFO_AWIDTH_c downto 0);
  signal raddr_opfifo        : std_logic_vector(OPFIFO_AWIDTH_c downto 0);
  signal raddr_opfifo_next_c : std_logic_vector(OPFIFO_AWIDTH_c downto 0);
  signal dout_opfifo         : std_logic_vector(OPFIFO_DWIDTH_c - 1 downto 0);
  signal opfifo_full_c       : std_logic;
  signal opfifo_empty_c      : std_logic;
  signal wren_opfifo         : std_logic;

  signal dout_valid_cp   : std_logic;
  signal dout_valid_int  : std_logic;

  signal cur_buf_rd         : std_logic;
  signal opmem_eng_no_rd    : std_logic_vector (NPROCESSORS_g - 1 downto 0);
  signal opmem_eng_rd_cnt   : std_logic_vector (ENG_MEM_RADDR_WIDTH - 2 downto 0);
  
  signal rd_in_prog         : std_logic;

  signal wr_early_opmem_sr : std_logic_vector(OPMEM_RD_LATENCY_c - 1 downto 0);
  signal sop_sr            : std_logic_vector(OPMEM_RD_LATENCY_c - 1 downto 0);
  signal eop_sr            : std_logic_vector(OPMEM_RD_LATENCY_c - 1 downto 0);
  signal eng_no_sr         : T_ENG_NO_SR;

  signal dout_blk_size_minus1 : std_logic_vector(FRAME_SIZE_WIDTH_c - 1 downto 0);
  signal dout_max_nbits_1_per_eng : std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- maximum number of bits per engine for output block
  signal dout_nbits_1_last_engine : std_logic_vector(NWORDS_BLK_WIDTH_g-1 downto 0);  -- number of bits last engine for output block

  -- output memories
  -- separate memories for each potential turbo engine; helps ensure Quartus
  -- will infer memory blocks
  signal opmem_eng0           : T_ENG_MEM;
  signal opmem_eng1           : T_ENG_MEM;
  signal opmem_eng2           : T_ENG_MEM;
  signal opmem_eng3           : T_ENG_MEM;
  signal opmem_eng4           : T_ENG_MEM;
  signal opmem_eng5           : T_ENG_MEM;
  signal opmem_eng6           : T_ENG_MEM;
  signal opmem_eng7           : T_ENG_MEM;

  -- combined signal to represent all memory blocks. Easy to write VHDL using
  -- this style
  signal opmem_all            : T_OP_MEM;
begin  -- rtl

  -----------------------------------------------------------------------------
  -- REGISTER INPUT INFORMATION
  -----------------------------------------------------------------------------
  p_ipreg : process (clk, reset)
  begin  -- process p_ipreg
    if reset = '1' then                 -- asynchronous reset (active low)
      din_r      <= (others => '0');
      din_addr_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      din_r      <= din;
      din_addr_r <= din_addr;
    end if;
  end process p_ipreg;

  p_ipreg3 : process (clk, reset)
  begin  -- process p_ipreg3
    if reset = '1' then                 -- asynchronous reset (active low)
      blk_size_minus1              <= (others => '0');
      max_nbits_minus1_per_eng     <= (others => '0');
      nbits_minus1_last_engine     <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (or_reduce(din_valid) = '1') then
        if (din_sop = '1') then
          blk_size_minus1          <= blk_size - 1;
          max_nbits_minus1_per_eng <= max_num_bits_per_eng - 1;
          nbits_minus1_last_engine <= num_bits_last_engine - 1;
        end if;
      end if;
    end if;
  end process p_ipreg3;

  -----------------------------------------------------------------------------
  -- MEMORY
  -- Double buffered to be be able to store 2 blocks of data
  --
  -- Separate memory for each turbo engine output.
  -- Each memory block has 1 bit data word input and output widths
  --
  -- Writes on same cycle may not be for all memory blocks and/or may be to
  -- different addresses.
  -----------------------------------------------------------------------------
  -- WRITE INPUT DATA TO MEMORY
  p_wrdin                        : process (clk, reset)
  begin  -- process p_wrdin
    if reset = '1' then                 -- asynchronous reset (active low)
      opmem_wren <= (others => '0');
      cur_buf    <= (others => '0');
      first_time <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge

      --generate write enable for each memory block.
      opmem_wren              <= din_valid;
      
      if (or_reduce(din_valid) = '1') then

        -- detect first valid after reset
        first_time <= '0';

        if ((din_sop = '1') and (first_time = '0'))then
          cur_buf <= not(cur_buf);
        end if;
      end if;
    end if;
  end process p_wrdin;

  -- purpose: construct write address for each block of memory for each turbo engine
  -- type   : combinational
  -- inputs : din_addr_r, cur_buf
  -- outputs: opmem_waddr
  p_opmem_waddr: process (din_addr_r, cur_buf)
  begin  -- process p_opmem_waddr
    for P in 0 to NPROCESSORS_g - 1 loop
      opmem_waddr(P)    <= cur_buf(P) & din_addr_r( (P + 1) * NWORDS_BLK_WIDTH_g - 1 downto P * NWORDS_BLK_WIDTH_g);
    end loop;  -- P
  end process p_opmem_waddr;

  -- purpose: Output MEMORY
  p_opmem: process (clk)
  begin  -- process p_opmem
    if clk'event and clk = '1' then  -- rising clock edge
      for P in 0 to NPROCESSORS_g - 1 loop
        if (opmem_wren(P) = '1') then
          opmem_all(P, to_integer(UNSIGNED(opmem_waddr(P))))     <= din_r(P);
        end if;

--         opmem_dout(P)   <= opmem_all(P, to_integer(UNSIGNED(opmem_raddr(P))));
--         opmem_dout_bits(P) <= opmem_dout(P);
      end loop;  -- P
    end if;
  end process p_opmem;

  -- mutliplexing correct memory block output
--   p_dout_mem : process (clk, reset)
--   begin  -- process p_dout_mem
--     if reset = '1' then                 -- asynchronous reset (active low)
--       opmem_dout_bit <= '0';
--     elsif clk'event and clk = '1' then  -- rising clock edge
--       opmem_dout_bit <= opmem_dout(to_integer(UNSIGNED(eng_no_sr(0))));
--     end if;
--   end process p_dout_mem;
--   p_dout_mem : process (clk, reset)
--   begin  -- process p_dout_mem
--     if reset = '1' then                 -- asynchronous reset (active low)
--       opmem_dout_bits <= (others => '0');
--     elsif clk'event and clk = '1' then  -- rising clock edge
--       opmem_dout_bits <= opmem_dout;
--     end if;
--   end process p_dout_mem;

  -- copying read address to each memory block
  p_opmem_raddr: process (clk, reset)
  begin  -- process p_opmem_raddr
    if reset = '1' then                 -- asynchronous reset (active high)
      for I in 0 to NPROCESSORS_g - 1 loop
        opmem_raddr(I)  <= (others => '0');
        
      end loop;  -- I
      opmem_dout        <= (others => '0');
      opmem_dout_bits   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      for I in 0 to NPROCESSORS_g - 1 loop
        opmem_raddr(I)  <= cur_buf_rd & opmem_eng_rd_cnt;
        opmem_dout(I)   <= opmem_all(I, to_integer(UNSIGNED(opmem_raddr(I))));
        opmem_dout_bits(I) <= opmem_dout(I);
      end loop;  -- I
    end if;
  end process p_opmem_raddr;

p_opmem_gen1: if NPROCESSORS_g = 1 generate
  assert NPROCESSORS_g /= 1 report "Not supported yet!" severity error;
end generate p_opmem_gen1;
              
p_opmem_gen2: if NPROCESSORS_g = 2 generate
  p_opmem_0: process (opmem_all)
  begin  -- process p_opmem_0
    for P in 0 to NPROCESSORS_g - 1 loop
      for D in 0 to ENG_MEM_DEPTH - 1 loop
        case P is
          when 0 => opmem_eng0(D)  <= opmem_all(P, D);
          when 1 => opmem_eng1(D)  <= opmem_all(P, D);
          when others => null;
        end case;
      end loop;  -- D
    end loop;  -- P
  end process p_opmem_0;
end generate p_opmem_gen2;

p_opmem_gen4: if NPROCESSORS_g = 4 generate
  p_opmem_0: process (opmem_all)
  begin  -- process p_opmem_0
    for P in 0 to NPROCESSORS_g - 1 loop
      for D in 0 to ENG_MEM_DEPTH - 1 loop
        case P is
          when 0 => opmem_eng0(D)  <= opmem_all(P, D);
          when 1 => opmem_eng1(D)  <= opmem_all(P, D);
          when 2 => opmem_eng2(D)  <= opmem_all(P, D);
          when 3 => opmem_eng3(D)  <= opmem_all(P, D);
          when others => null;
        end case;
      end loop;  -- D
    end loop;  -- P
  end process p_opmem_0;
end generate p_opmem_gen4;

p_opmem_gen8: if NPROCESSORS_g = 8 generate
  p_opmem_0: process (opmem_all)
  begin  -- process p_opmem_0
    for P in 0 to NPROCESSORS_g - 1 loop
      for D in 0 to ENG_MEM_DEPTH - 1 loop
        case P is
          when 0 => opmem_eng0(D)  <= opmem_all(P, D);
          when 1 => opmem_eng1(D)  <= opmem_all(P, D);
          when 2 => opmem_eng2(D)  <= opmem_all(P, D);
          when 3 => opmem_eng3(D)  <= opmem_all(P, D);
          when 4 => opmem_eng4(D)  <= opmem_all(P, D);
          when 5 => opmem_eng5(D)  <= opmem_all(P, D);
          when 6 => opmem_eng6(D)  <= opmem_all(P, D);
          when 7 => opmem_eng7(D)  <= opmem_all(P, D);
          when others => null;
        end case;
      end loop;  -- D
    end loop;  -- P
  end process p_opmem_0;
end generate p_opmem_gen8;

--   ENG2: if (NPROCESSORS_g >= 2) generate
--     opmem_eng1          <= opmem_all(1);
--   end generate ENG2;

--   ENG3: if (NPROCESSORS_g >= 3) generate
--     opmem_eng2          <= opmem_all(2);
--   end generate ENG3;

--   ENG4: if (NPROCESSORS_g >= 4) generate
--     opmem_eng3          <= opmem_all(3);
--   end generate ENG4;

--   ENG5: if (NPROCESSORS_g >= 5) generate
--     opmem_eng4          <= opmem_all(4);
--   end generate ENG5;

--   ENG6: if (NPROCESSORS_g >= 6) generate
--     opmem_eng5          <= opmem_all(5);
--   end generate ENG6;

--   ENG7: if (NPROCESSORS_g >= 7) generate
--     opmem_eng6          <= opmem_all(6);
--   end generate ENG7;

--   ENG8: if (NPROCESSORS_g >= 8) generate
--     opmem_eng7          <= opmem_all(7);
--   end generate ENG8;

  -----------------------------------------------------------------------------
  -- INFORMATION FIFO
  --
  -- Pass the number of words in each buffer to output interface
  -- IF this FIFO is full, then this information is passed upstream to the
  -- Turbo MAP decoder. It is up to the decoder to ensure that no more data is
  -- sent to this module. If it sends data, then it will still get written to
  -- FIFO causing corruption.
  -----------------------------------------------------------------------------
  info_full_c <= '1' when ((waddr_info(1) /= raddr_info(1)) and (waddr_info(0) = raddr_info(0)))
                 else '0';

  info_empty_c <= '1' when (waddr_info = raddr_info) else '0';

  -- generating output signal buffer_avail:
  -- indicates whether one of the 2 buffers is free for the next block of turbo
  -- output.
  buffer_avail <= not(info_full_c);

  -- information word is written into FIFO on clk edge that the last data word
  -- (for new block) is being written into double buffer.
  --
  -- NOTE DIN_EOP IS NOT VALIDATED WITH DIN_VALID DUE TO FUNCTIONING OF DECODER
  p_wrinfo : process (clk, reset)
  begin  -- process p_wrinfo
    if reset = '1' then                 -- asynchronous reset (active low)
      waddr_info <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
--      if ((or_reduce(din_valid) = '1') and (din_eop = '1')) then
      if (din_eop = '1') then
        info_fifo(to_integer(unsigned(waddr_info(waddr_info'high - 1 downto 0)))) <= nbits_minus1_last_engine & max_nbits_minus1_per_eng & blk_size_minus1;
        waddr_info                                                                <= waddr_info + 1;
      end if;
    end if;
  end process p_wrinfo;

  p_rdinfo : process (clk, reset)
  begin  -- process p_rdinfo
    if reset = '1' then                 -- asynchronous reset (active low)
      dout_info <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      dout_info <= info_fifo(to_integer(unsigned(raddr_info(raddr_info'high - 1 downto 0))));
    end if;
  end process p_rdinfo;

  dout_blk_size_minus1     <= dout_info(dout_blk_size_minus1'range);
  dout_max_nbits_1_per_eng <= dout_info( dout_max_nbits_1_per_eng'length + dout_blk_size_minus1'high downto dout_blk_size_minus1'high + 1);
  dout_nbits_1_last_engine <= dout_info(dout_info'high downto dout_info'high - dout_nbits_1_last_engine'length + 1);
  

  -----------------------------------------------------------------------------
  -- READING DATA FROM OP MEMORY
  --
  -----------------------------------------------------------------------------
  p_rd_opmem : process (clk, reset)
  begin  -- process p_rd_opmem
    if reset = '1' then                 -- asynchronous reset (active low)
      cur_buf_rd       <= '0';
      opmem_eng_no_rd  <= (others => '0');
      opmem_eng_rd_cnt <= (others => '0');

      waddr_early_opfifo <= (others => '0');
      wr_early_opmem_sr  <= (others => '0');

      rd_in_prog <= '0';
      raddr_info <= (others => '0');
      sop_sr     <= (others => '0');
      eop_sr     <= (others => '0');

      for Q in 0 to OPMEM_RD_LATENCY_c - 1 loop
        eng_no_sr(Q)      <= (others => '0');
      end loop;  -- Q
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- shift register
      wr_early_opmem_sr(wr_early_opmem_sr'high - 1 downto 0) <= wr_early_opmem_sr(wr_early_opmem_sr'high downto 1);
      -- maybe overwritten by later assignment
      wr_early_opmem_sr(wr_early_opmem_sr'high)              <= '0';  --


      --shift register for eop and sop
      sop_sr(sop_sr'high - 1 downto 0) <= sop_sr(sop_sr'high downto 1);
      eop_sr(eop_sr'high - 1 downto 0) <= eop_sr(eop_sr'high downto 1);

      -- shift register for engine no
      for Q in 0 to OPMEM_RD_LATENCY_c - 2 loop
        eng_no_sr(Q)                    <= eng_no_sr(Q+1);
      end loop;  -- Q
      eng_no_sr(eng_no_sr'high)         <= opmem_eng_no_rd;
      
      -- default values which can be overwirtten by later assignments
      sop_sr(sop_sr'high) <= '0';
      eop_sr(eop_sr'high) <= '0';

      if ((opfifo_full_c = '0') and (rd_in_prog = '1')) then
        waddr_early_opfifo                        <= waddr_early_opfifo + 1;
        wr_early_opmem_sr(wr_early_opmem_sr'high) <= '1';

        if ((opmem_eng_no_rd = STD_LOGIC_VECTOR(to_unsigned(NPROCESSORS_g - 1, opmem_eng_no_rd'length))) and (opmem_eng_rd_cnt = dout_nbits_1_last_engine)) then
          -- Reading from Memory block for LAST turbo engine AND
          -- Last data bit being read on this cycle.
          -- Reset addresses and counters
          
          opmem_eng_no_rd     <= (others => '0');
          opmem_eng_rd_cnt    <= (others => '0');

          cur_buf_rd          <= not(cur_buf_rd);

          rd_in_prog          <= '0';

          eop_sr(eop_sr'high) <= '1';
          -- signal that current buffer is no longer required
          raddr_info          <= raddr_info + 1;

        elsif (opmem_eng_rd_cnt = dout_max_nbits_1_per_eng) then
          -- outputting last data bit from Memory block.
          -- Need to point to Memory block for NEXT Turbo engine and also reset
          -- bit address
          opmem_eng_no_rd     <= opmem_eng_no_rd + 1;
          opmem_eng_rd_cnt    <= (others => '0');
          
        else
          -- increment bit address
          opmem_eng_rd_cnt    <= opmem_eng_rd_cnt + 1;
        end if;


        if ((opmem_eng_no_rd = std_logic_vector(to_unsigned(0, opmem_eng_no_rd'length))) and (opmem_eng_rd_cnt = std_logic_vector(to_unsigned(0, opmem_eng_rd_cnt'length)))) then
          sop_sr(sop_sr'high) <= '1';
        end if;
      end if;                           -- if ((opfifo_full_c = '0') and (rd_in_prog = '1')) then

      if (rd_in_prog = '0') then
        -- wait for new entry in info_fifo. This indicates that data buffer is
        -- available.
        rd_in_prog <= not(info_empty_c);
      end if;
    end if;
  end process p_rd_opmem;



  -----------------------------------------------------------------------------
  -- OUTPUT FIFO
  --
  -- Small FIFO to cope with fact that reads from double buffer have latency
  -- and need to cope with back pressure from Avalon Streaming interface
  -----------------------------------------------------------------------------
  opfifo_full_c <= '1' when ((waddr_early_opfifo(waddr_early_opfifo'high) /= raddr_opfifo_next_c(raddr_opfifo_next_c'high)) and (waddr_early_opfifo(waddr_early_opfifo'high - 1 downto 0) = raddr_opfifo_next_c(raddr_opfifo_next_c'high - 1 downto 0)))
                   else '0';

  opfifo_empty_c <= '1' when (waddr_opfifo = raddr_opfifo)
                    else '0';

  wren_opfifo <= wr_early_opmem_sr(0);


  p_wr_opfifo : process (clk, reset)
  begin  -- process p_wr_opfifo
    if reset = '1' then                 -- asynchronous reset (active low)
      waddr_opfifo <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if wren_opfifo = '1' then
        opfifo(to_integer(unsigned(waddr_opfifo(waddr_opfifo'high - 1 downto 0)))) <= sop_sr(0) & eop_sr(0) & opmem_dout_bits(to_integer(UNSIGNED(eng_no_sr(0))));

        waddr_opfifo <= waddr_opfifo + 1;
      end if;
    end if;
  end process p_wr_opfifo;

  p_rd_opfifo : process (clk, reset)
  begin  -- process p_rd_opfifo
    if reset = '1' then                 -- asynchronous reset (active low)
      raddr_opfifo   <= (others => '0');
      dout_opfifo    <= (others => '0');
      dout_valid_int <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ((dout_valid_cp = '0') or (dout_ready = '1')) then
        if (opfifo_empty_c = '0') then
          dout_valid_int <= '1';
          dout_opfifo    <= opfifo(to_integer(unsigned(raddr_opfifo(raddr_opfifo'high - 1 downto 0))));
        else
          dout_valid_int <= '0';
        end if;
      end if;

      raddr_opfifo <= raddr_opfifo_next_c;
    end if;
  end process p_rd_opfifo;

  raddr_opfifo_next_c <= (raddr_opfifo + 1) when (((dout_valid_cp = '0') or (dout_ready = '1')) and (opfifo_empty_c = '0'))
                         else raddr_opfifo;
  -- Avalon Streaming with Ready Latency of ZERO
  p_opdata : process (clk, reset)
  begin  -- process p_opdata
    if reset = '1' then                 -- asynchronous reset (active low)
      dout_valid_cp <= '0';
      dout_valid    <= '0';
      dout          <= (others => '0');
      dout_sop      <= '0';
      dout_eop      <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      if ((dout_valid_cp = '0') or (dout_ready = '1')) then
        dout          <= dout_opfifo(0 downto 0);
        dout_sop      <= dout_opfifo(dout_opfifo'high);
        dout_eop      <= dout_opfifo(dout_opfifo'high - 1);
        dout_valid    <= dout_valid_int;
        dout_valid_cp <= dout_valid_int;
      end if;
    end if;
  end process p_opdata;


  p_dout_blk_size : process (clk, reset)
  begin  -- process p_dout_blk_size
    if reset = '1' then
      dout_blk_size <= (others => '0');
    elsif rising_edge(clk) then
      dout_blk_size <= dout_blk_size_minus1 + 1;
    end if;
  end process p_dout_blk_size;

  
end rtl;
