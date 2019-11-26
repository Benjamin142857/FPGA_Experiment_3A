----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_ram.vhd
--
-- Project     : Turbo Encoder/Decoder
-- Description : Input RAM
--
-- Author      :  Zhengjun Pan
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/input/auk_dspip_ctc_umts_input_ram.vhd#1 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

entity auk_dspip_ctc_umts_input_ram is
  -- inupt width is 15 to 24, corresponding to 5-8 bit width
  generic (
    DATA_DEPTH_g        : integer  := 2*768;  -- data Depth
    NPROCESSORS_g       : integer  := 8;      -- number of parallel engines
    INPUT_WIDTH_g       : integer  := 18;     -- input data width
    NUM_ENGINES_WIDTH_g : positive := 3;      -- log2_ceil_one(NPROCESSORS_g);
    ADDRESS_WIDTH_g     : integer  := 11
    );

  port (
    clk           : in  std_logic;
    ena           : in  std_logic;
    reset         : in  std_logic;
    read_address  : in  unsigned (ADDRESS_WIDTH_g-1 downto 0);
    write_address : in  unsigned (ADDRESS_WIDTH_g-1 downto 0);
    sub_address   : in  unsigned (NUM_ENGINES_WIDTH_g-1 downto 0);
    din           : in  signed (INPUT_WIDTH_g-1 downto 0);
    wren          : in  std_logic;
    rden          : in  std_logic;
    dout          : out signed (NPROCESSORS_g*INPUT_WIDTH_g-1 downto 0)
    );

end entity auk_dspip_ctc_umts_input_ram;


architecture SYN of auk_dspip_ctc_umts_input_ram is

  constant BYTE_SIZE_c     : natural := 9;
  -- for input width 5-8 bits wide, the duplication factor is 2, 2, 3, 3
  constant byte_enable_duplication_factor : natural := div_ceil(INPUT_WIDTH_g, 9);
  -- this number is 4, 6 for 2-engine and 8, 12 for 4-engine 
  constant BYTEENA_WIDTH_c : natural := byte_enable_duplication_factor*NPROCESSORS_g;

  signal byte_en : std_logic_vector(byte_enable_duplication_factor*NPROCESSORS_g-1 downto 0);  -- write enable

  signal mem_in    : std_logic_vector (NPROCESSORS_g*byte_enable_duplication_factor*BYTE_SIZE_c-1 downto 0);
  signal mem_out   : std_logic_vector (NPROCESSORS_g*byte_enable_duplication_factor*BYTE_SIZE_c-1 downto 0);
  signal wraddress : std_logic_vector(ADDRESS_WIDTH_g-1 downto 0);
  signal rdaddress : std_logic_vector(ADDRESS_WIDTH_g-1 downto 0);
  signal byteena_a : std_logic_vector(BYTEENA_WIDTH_c-1 downto 0);

  component altsyncram
    generic (
      address_aclr_b                     : string;
      address_reg_b                      : string;
      byte_size                          : natural;
      maximum_depth                      : natural;
      clock_enable_input_a               : string;
      clock_enable_input_b               : string;
      clock_enable_output_b              : string;
--      intended_device_family             : string;
      lpm_type                           : string;
      numwords_a                         : natural;
      numwords_b                         : natural;
      operation_mode                     : string;
      outdata_aclr_b                     : string;
      outdata_reg_b                      : string;
      power_up_uninitialized             : string;
      rdcontrol_reg_b                    : string;
      read_during_write_mode_mixed_ports : string;
      widthad_a                          : natural;
      widthad_b                          : natural;
      width_a                            : natural;
      width_b                            : natural;
      width_byteena_a                    : natural
      );
    port (
      clocken0  : in  std_logic;
      wren_a    : in  std_logic;
      aclr0     : in  std_logic;
      clock0    : in  std_logic;
      byteena_a : in  std_logic_vector (BYTEENA_WIDTH_c-1 downto 0);
      address_a : in  std_logic_vector (ADDRESS_WIDTH_g-1 downto 0);
      address_b : in  std_logic_vector (ADDRESS_WIDTH_g-1 downto 0);
      rden_b    : in  std_logic;
      q_b       : out std_logic_vector (NPROCESSORS_g*byte_enable_duplication_factor*BYTE_SIZE_c-1 downto 0);
      data_a    : in  std_logic_vector (NPROCESSORS_g*byte_enable_duplication_factor*BYTE_SIZE_c-1 downto 0)
      );
  end component;

  
begin  -- SYN

  wraddress <= std_logic_vector(write_address);
  rdaddress <= std_logic_vector(read_address);

  proc_loop: for proc in 0 to NPROCESSORS_g-1 generate
    begin  -- generate proc_loop
    expand_enables: for index in 0 to byte_enable_duplication_factor-1 generate
    begin  -- generate expand_enables

      create_enables: process (sub_address) is
      begin  -- process create_enables
        -- need a 0-prefix to convert it as unsigned?
        if (proc=(to_integer('0' & sub_address))) then
          byte_en(byte_enable_duplication_factor*proc+index) <= '1';
        else
          byte_en(byte_enable_duplication_factor*proc+index) <= '0';
        end if;
      end process create_enables;
      
    end generate expand_enables;
  end generate proc_loop;

  -------------------------------------------------------------------------------
  ---- this process would connect the relevant input to din, and set the others
  ---- to 0.  Synthesises to logic gates.
  -------------------------------------------------------------------------------
  --mem_in_p : process (din, sub_address)
  --begin  -- process tmp_p
  --  mem_in                           <= (others => '0');
  --  for i in 0 to INPUT_WIDTH_g - 1 loop
  --    mem_in(i+to_integer(sub_address)*byte_enable_duplication_factor*BYTE_SIZE_c) <= din(i);
  --  end loop;
  --end process mem_in_p;

  -----------------------------------------------------------------------------
  -- this process connects all the inputs to din.  doesn't matter, because byte
  -- enable takes care of which one is written to.  This synthesises to wires only.
  -----------------------------------------------------------------------------
  mem_in_p : process (din, sub_address)
  begin  -- process tmp_p
    mem_in                           <= (others => '0');
    for proc in 0 to NPROCESSORS_g - 1 loop
      for bitnum in 0 to INPUT_WIDTH_g - 1 loop
         mem_in(proc*byte_enable_duplication_factor*BYTE_SIZE_c+bitnum) <= din(bitnum);
      end loop;
    end loop;
  end process mem_in_p;

-- Q: so the total memory size is 2*Fsub*2?
  altsyncram_component : altsyncram
    generic map (
      address_aclr_b                     => "CLEAR0",
      address_reg_b                      => "CLOCK0",
      byte_size                          => BYTE_SIZE_c,
      maximum_depth                      => 512,
      clock_enable_input_a               => "NORMAL",
      clock_enable_input_b               => "NORMAL",
      clock_enable_output_b              => "NORMAL",
--      intended_device_family             => "Stratix III",
      lpm_type                           => "altsyncram",
      numwords_a                         => DATA_DEPTH_g,
      numwords_b                         => DATA_DEPTH_g,
      operation_mode                     => "DUAL_PORT",
      outdata_aclr_b                     => "CLEAR0",
      outdata_reg_b                      => "CLOCK0",
      power_up_uninitialized             => "FALSE",
      rdcontrol_reg_b                    => "CLOCK0",
      read_during_write_mode_mixed_ports => "OLD_DATA",
      widthad_a                          => ADDRESS_WIDTH_g ,
      widthad_b                          => ADDRESS_WIDTH_g ,
      width_a                            => NPROCESSORS_g*byte_enable_duplication_factor*BYTE_SIZE_c,
      width_b                            => NPROCESSORS_g*byte_enable_duplication_factor*BYTE_SIZE_c,
      width_byteena_a                    => BYTEENA_WIDTH_c
      )
    port map (
      clocken0  => ena,
      wren_a    => wren,
      aclr0     => reset,
      clock0    => clk,
      byteena_a => byte_en,
      address_a => wraddress,
      address_b => rdaddress,
      rden_b    => rden,
      data_a    => mem_in,
      q_b       => mem_out
      );

  mem_out_p : process (mem_out)
  begin  -- process tmp_p
    for proc in 0 to NPROCESSORS_g - 1 loop
      for bitnum in 0 to INPUT_WIDTH_g - 1 loop
        dout(proc*INPUT_WIDTH_g+bitnum) <= mem_out(proc*byte_enable_duplication_factor*BYTE_SIZE_c+bitnum);
      end loop;
    end loop;
  end process mem_out_p;
  --dout <= signed(mem_out);
end SYN;
