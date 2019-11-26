----------------------------------------------------------------------
-- File: auk_dspip_ctc_umts_fifo.vhd
--
-- Project     : UMTS Turbo Codec
-- Description : FIFO in the SISO decoder to resolve interleaver conflicts
--
-- Author      :  Zhengjun Pan
--
-- ALTERA Confidential and Proprietary
-- Copyright 2008 (c) Altera Corporation
-- All rights reserved
--
-- $Header: //depot/ssg/main/turbo/ctc_umts/src/rtl/decoder/auk_dspip_ctc_umts_fifo.vhd#2 $
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;
use altera_mf.altera_mf_components.all;

library auk_dspip_ctc_umts_lib;
use auk_dspip_ctc_umts_lib.auk_dspip_ctc_umts_lib_pkg.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;
use auk_dspip_lib.auk_dspip_lib_pkg.all;

entity auk_dspip_ctc_umts_fifo is
  generic (
    IN_WIDTH_g          : positive := 6;
    NPROCESSORS_g       : positive := 4;
    NUM_ENGINES_WIDTH_g : positive := 2;   -- log2_ceil_one(NPROCESSORS_g);
    RAM_TYPE_g          : string   := "AUTO";
    ADDRESS_WIDTH_g     : positive := 12;  -- =log2_ceil(MAX_FRAME_SIZE_c/NPROCESSORS_g)
    DATA_IN_WIDTH_g     : positive := 20;  -- = IN_WIDTH_g + ADDRESS_WIDTH_g + NUM_ENGINES_WIDTH_g
    DATA_OUT_WIDTH_g    : positive := 18   -- = IN_WIDTH_g + ADDRESS_WIDTH_g
    );
  port (
    clk   : in  std_logic;
    ena   : in  std_logic;
    reset : in  std_logic;
    wrreq : in  std_logic_vector(NPROCESSORS_g-1 downto 0);
    data  : in  std_logic_vector(NPROCESSORS_g*DATA_IN_WIDTH_g-1 downto 0);
    wren  : out std_logic_vector(NPROCESSORS_g-1 downto 0);
    q     : out std_logic_vector(NPROCESSORS_g*DATA_OUT_WIDTH_g-1 downto 0)
    );
end entity auk_dspip_ctc_umts_fifo;

architecture SYN of auk_dspip_ctc_umts_fifo is

  type data_in_array_type is array (NPROCESSORS_g-1 downto 0) of std_logic_vector(DATA_IN_WIDTH_g-1 downto 0);
  type data_out_array_type is array (NPROCESSORS_g-1 downto 0) of std_logic_vector(DATA_OUT_WIDTH_g-1 downto 0);

  signal data_in  : data_in_array_type;
  signal data_out : data_out_array_type;

  type fifo_inout_array_type is array (NPROCESSORS_g-1 downto 0) of data_out_array_type;

  signal fifo_in  : fifo_inout_array_type;
  signal fifo_out : fifo_inout_array_type;

  type   intlvr_sub_loc_array is array (0 to NPROCESSORS_g-1) of unsigned(NUM_ENGINES_WIDTH_g-1 downto 0);
  signal intlvr_sub_locs : intlvr_sub_loc_array;

  type fifo_slv_array is array (0 to NPROCESSORS_g-1) of std_logic_vector(0 to NPROCESSORS_g-1);

  signal fifo_rdreq         : fifo_slv_array;
  signal fifo_wrreq         : fifo_slv_array;
  signal fifo_empty         : fifo_slv_array;
  signal fifo_not_empty_row : fifo_slv_array;
  signal fifo_wren          : fifo_slv_array;

  signal fifo_full          : fifo_slv_array := (others => (others => '0'));  -- stop warnings at reset
  signal fifo_almost_full   : fifo_slv_array := (others => (others => '0'));

  -- indicating if the fifos for the same destonation are all empty
  signal fifo_not_empty_reduce : std_logic_vector(0 to NPROCESSORS_g-1);

  signal mux_sel : fifo_slv_array;

  -- set fifo size
  -- The final processor's row of FIFOs is set higher than others due to the
  -- arbitration scheme on outputs which favours lower numbered engines.
  -- This is an optimisation to reduce resource utilisation whilst ensuring no
  -- FIFO overflows.
  constant FIFO_SIZE_LOW    : integer := 31;   -- first 2 rows have a lower size
  constant FIFO_SIZE_MID    : integer := 63;   -- second to last has a stepped FIFO size
  constant FIFO_SIZE_LAST   : integer := 127;  -- larger for last row because arbitation biased towards lower numbered fifos

  type t_fifo_size_el is record
    size        : integer;
    index_width : integer;
  end record;

  type t_fifo_size_vec is array (0 to NPROCESSORS_g-1) of t_fifo_size_el;
  type t_fifo_size_arr is array (0 to NPROCESSORS_g-1) of t_fifo_size_vec;

  function set_fifo_size (NUM_PROCESSORS : integer) return t_fifo_size_arr is
    variable v_fifo_size : t_fifo_size_arr;
  begin
    for i in 0 to NUM_PROCESSORS-1 loop
        for j in 0 to NUM_PROCESSORS-1 loop

            if i < NUM_PROCESSORS-1 then

                if NUM_PROCESSORS > 2 then
                    if i < NUM_PROCESSORS -2 then
                        v_fifo_size(i)(j).size    := FIFO_SIZE_LOW;
                    else
                        v_fifo_size(i)(j).size    := FIFO_SIZE_MID;
                    end if;
                else
                    v_fifo_size(i)(j).size        := FIFO_SIZE_MID;
                end if;

            else
                v_fifo_size(i)(j).size        := FIFO_SIZE_LAST;
            end if;

            v_fifo_size(i)(j).index_width := log2_ceil(v_fifo_size(i)(j).size);
        end loop;
    end loop;
    return v_fifo_size;
  end function;
  constant FIFO_SIZING : t_fifo_size_arr := set_fifo_size(NPROCESSORS_g);

begin  -- architecture SYN

  fifo_gen : for i in 0 to NPROCESSORS_g-1 generate
    data_in(i)                                            <= data((i+1)*DATA_IN_WIDTH_g-1 downto i*DATA_IN_WIDTH_g);
    q((i+1)*DATA_OUT_WIDTH_g-1 downto i*DATA_OUT_WIDTH_g) <= data_out(i);

    wren(i) <= or_reduce(fifo_wren(i));

    intlvr_sub_locs(i) <= unsigned(data_in(i)(NUM_ENGINES_WIDTH_g-1 downto 0));

    data_out_gen1 : if NPROCESSORS_g = 1 generate
      data_out(i) <= fifo_out(0)(i) when fifo_wren(i)(0) = '1' else (others => '0');
    end generate data_out_gen1;

    data_out_gen2 : if NPROCESSORS_g = 2 generate
      data_out(i) <= fifo_out(0)(i) when fifo_wren(i)(0) = '1' else
                     fifo_out(1)(i) when fifo_wren(i)(1) = '1' else
                     (others => '0');
    end generate data_out_gen2;

    data_out_gen4 : if NPROCESSORS_g = 4 generate
      data_out(i) <= fifo_out(0)(i) when fifo_wren(i)(0) = '1' else
                     fifo_out(1)(i) when fifo_wren(i)(1) = '1' else
                     fifo_out(2)(i) when fifo_wren(i)(2) = '1' else
                     fifo_out(3)(i) when fifo_wren(i)(3) = '1' else
                     (others => '0');
    end generate data_out_gen4;

    fifo_for_each_engine_gen : for j in 0 to NPROCESSORS_g-1 generate

      fifo_in(i)(j)            <= data_in(i)(data_in(i)'high downto NUM_ENGINES_WIDTH_g) when intlvr_sub_locs(i) = j else (others => '0');
      fifo_wrreq(i)(j)         <= wrreq(i)                                               when intlvr_sub_locs(i) = j else '0';
      fifo_not_empty_row(i)(j) <= not(fifo_empty(j)(i));

      fifo_wren_proc : process (clk, reset)
      begin  -- process fifo_wren_proc
        if reset = '1' then
          fifo_wren(i)(j) <= '0';
        elsif rising_edge(clk) then
          fifo_wren(i)(j) <= fifo_rdreq(j)(i);
        end if;
      end process fifo_wren_proc;

      mux_sel(i)(j)    <= '1' when i = j                                        else '0' when i > j else '-';
      fifo_rdreq(i)(j) <= '1' when std_match(mux_sel(i)(0 to i), fifo_not_empty_row(j)(0 to i)) else '0';

      output_u_fifo : altera_mf.altera_mf_components.scfifo
        generic map
        (
          add_ram_output_register => "ON",
          lpm_numwords            => FIFO_SIZING(i)(j).size,
          almost_full_value       => FIFO_SIZING(i)(j).size-2,
          lpm_type                => "scfifo",
          lpm_width               => DATA_OUT_WIDTH_g,
          lpm_widthu              => FIFO_SIZING(i)(j).index_width,
          lpm_hint                => "RAM_BLOCK_TYPE=" & RAM_TYPE_g,
          intended_device_family  => "Stratix",  -- only used for functional simulation
          use_eab                 => "ON"
          )
        port map (
          aclr  => reset,
          clock => clk,
          empty => fifo_empty(i)(j),
          rdreq => fifo_rdreq(i)(j),
          wrreq => fifo_wrreq(i)(j),
          data  => fifo_in(i)(j),
          full => fifo_full(i)(j),
          almost_full => fifo_almost_full(i)(j),
          q     => fifo_out(i)(j)
          );

          assert fifo_full(i)(j) /= '1'        report "FIFO (" & integer'image(i) & "," & integer'image(j) & ") full" severity warning;
          assert fifo_almost_full(i)(j) /= '1' report "FIFO (" & integer'image(i) & "," & integer'image(j) & ") almost full - 2 locations off" severity warning;

    end generate fifo_for_each_engine_gen;

  end generate fifo_gen;

end architecture SYN;

