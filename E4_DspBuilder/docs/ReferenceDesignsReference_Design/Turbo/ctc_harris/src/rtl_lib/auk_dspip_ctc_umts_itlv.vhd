-------------------------------------------------------------------------------
-- Title         : umts interleaver top level
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $RCSfile: auk_dspip_ctc_umts_itlv.vhd,v $
-- Revision      : $Revision: #2 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/12/15 $
-------------------------------------------------------------------------------
-- Description :
--
-- interleaver according to 3G TS25.212 V3.1.1 (1999-12)
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $Log: auk_dspip_ctc_umts_itlv.vhd,v $
-- Revision 1.5  2008/02/15 10:58:05  zpan
-- change some ports to internal signals
--
-- Revision 1.4  2008/02/14 00:00:04  zpan
-- change inferred ram for QII 7.2
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

entity auk_dspip_ctc_umts_itlv is
  generic (
    gCOUNTER_WIDTH : integer := 13);

  port (
    out_addr       : out unsigned(gCOUNTER_WIDTH-1 downto 0);
    RxC            : out unsigned(gCOUNTER_WIDTH-1 downto 0);
    blk_size       : in  unsigned(gCOUNTER_WIDTH-1 downto 0);
    addr_valid     : out std_logic;
    seq_gen_done   : out std_logic;
    start_load     : in  std_logic;
    enable         : in  std_logic;
    clk            : in  std_logic;
    reset          : in  std_logic);
end auk_dspip_ctc_umts_itlv;



architecture beh of auk_dspip_ctc_umts_itlv is

  component LPM_RAM_DP
    generic (LPM_WIDTH             : positive;
             LPM_WIDTHAD           : positive;
             LPM_NUMWORDS          : positive;
             LPM_INDATA            : string := "REGISTERED";
             LPM_RDADDRESS_CONTROL : string := "REGISTERED";
             LPM_WRADDRESS_CONTROL : string := "REGISTERED";
             LPM_OUTDATA           : string := "REGISTERED";
             LPM_TYPE              : string := "LPM_RAM_DP";
             LPM_FILE              : string := "UNUSED");
    port (RDCLOCK   : in  std_logic := '0';
          RDCLKEN   : in  std_logic := '0';
          RDADDRESS : in  std_logic_vector(LPM_WIDTHad-1 downto 0);
          RDEN      : in  std_logic := '1';
          DATA      : in  std_logic_vector(LPM_WIDTH-1 downto 0);
          WRADDRESS : in  std_logic_vector(LPM_WIDTHad-1 downto 0);
          WREN      : in  std_logic;
          WRCLOCK   : in  std_logic := '0';
          WRCLKEN   : in  std_logic := '1';
          Q         : out std_logic_vector(LPM_WIDTH-1 downto 0));
  end component;


  signal start_load_dly        : std_logic;
  signal one                   : std_logic;  -- always '1'
  signal zero                  : std_logic;  -- always '0'
  signal itlv_length           : unsigned(gCOUNTER_WIDTH-1 downto 0);
  signal RxC_int               : unsigned(12 downto 0);
  signal R                     : unsigned(4 downto 0);
  signal start_mult_seq_gen    : std_logic;
  signal mult_seq_gen_active   : std_logic;
  signal mult_seq_gen_finished : std_logic;
  signal PAPBPC_index          : unsigned(5 downto 0);
  signal PAPBPC_rd_index       : unsigned(4 downto 0);
  signal PAPBPC_rd_val         : unsigned(4 downto 0);
  signal table_p_wr_index      : unsigned(4 downto 0);
  signal table_p_rd_index      : unsigned(4 downto 0);
  signal table_p_rd_val        : unsigned(7 downto 0);
  signal table_c_wr_index      : unsigned(8 downto 0);
  signal table_c_rd_index      : unsigned(8 downto 0);
  signal c_element             : unsigned(8 downto 0);
  signal table_c_rd_val        : unsigned(8 downto 0);
  signal table_p_rd_val_slv    : std_logic_vector(7 downto 0);
  signal table_c_rd_val_slv    : std_logic_vector(8 downto 0);
  signal table_p_wr_index_slv  : std_logic_vector(4 downto 0);
  signal table_p_rd_index_slv  : std_logic_vector(4 downto 0);
  signal table_c_wr_index_slv  : std_logic_vector(8 downto 0);
  signal table_c_rd_index_slv  : std_logic_vector(8 downto 0);
  signal c_element_slv         : std_logic_vector(8 downto 0);
  signal inv_table_c_rd_val    : unsigned(8 downto 0);
  signal wr_table_c            : std_logic;
  signal wr_table_p            : std_logic;
  signal prime                 : unsigned(8 downto 0);
  signal g0                    : unsigned(4 downto 0);
  signal R10not20              : std_logic;
  signal synreset_multseqgn    : std_logic;
  signal gcd_index             : unsigned(4 downto 0);
  signal gcd                   : unsigned(7 downto 0);
  signal gcd_dly               : unsigned(7 downto 0);
  signal gcd_dly_slv           : std_logic_vector(7 downto 0);
  signal wr_gcd                : std_logic;
  signal flag_a                : std_logic;
  signal flag_b                : std_logic;
  signal flag_b6               : std_logic;
  signal flag_c                : std_logic;
  signal itlv_setup_active     : std_logic;
  signal ditlv_addr_valid      : std_logic;
  signal max_column            : unsigned(8 downto 0);
  signal prune_me_s            : std_logic;

  signal setup_active_s   : std_logic;
  signal setup_active_reg : std_logic;
  signal start_itlv_fwd_s : std_logic;
  signal intlvr_ready     : std_logic;

begin  -- beh


  table_p_wr_index_slv <= std_logic_vector(table_p_wr_index);
  table_p_rd_index_slv <= std_logic_vector(table_p_rd_index);
  gcd_dly_slv          <= std_logic_vector(gcd_dly);
  --table_p_rd_val       <= unsigned(table_p_rd_val_slv);

  table_c_wr_index_slv <= std_logic_vector(table_c_wr_index);
  table_c_rd_index_slv <= std_logic_vector(table_c_rd_index);
  --table_c_rd_val       <= unsigned(table_c_rd_val_slv);
  c_element_slv        <= std_logic_vector(c_element);

  start_itlv_fwd_s <= setup_active_reg and not(setup_active_s);


  addr_valid         <= ditlv_addr_valid and not(prune_me_s);
  one                <= '1';
  zero               <= '0';
  itlv_length        <= blk_size;
  synreset_multseqgn <= '1' when (start_load = '1' and start_load_dly = '0') else '0';

  PAPBPC_index <= '0' & gcd_index when itlv_setup_active = '1' else
                   '0' & PAPBPC_rd_index;
  papbpc_rd_val  <= table_p_wr_index;
  RxC            <= RxC_int;
  setup_active_s <= itlv_setup_active or wr_table_p;

  i_PAPBPC : auk_dspip_ctc_umtsitlv_PAPBPC_table
    port map(
      itlv_length  => itlv_length,
      PAPBPC_index => PAPBPC_index,
      PAPBPC_val   => table_p_wr_index,

      reset  => reset,
      enable => enable,
      clk    => clk
      );

  i_table_c : auk_dspip_ctc_umts_mem
    generic map(
      gADDR_WIDTH => 9,
      gDATA_WIDTH => 9
      )
    port map(
      wr_addr => table_c_wr_index,
      rd_addr => table_c_rd_index,

      datai => c_element,
      datao => table_c_rd_val,
      reset => reset,

      rd     => one,
      wr     => wr_table_c,
      enable => enable,
      clk    => clk
      );


--    table_c : LPM_RAM_DP
--        generic map (LPM_WIDTH             => 9,
--                     LPM_WIDTHAD           => 9,
--                     LPM_NUMWORDS          => 512,
--                     LPM_INDATA            => "REGISTERED", 
--                     LPM_RDADDRESS_CONTROL => "REGISTERED",
--                     LPM_WRADDRESS_CONTROL => "REGISTERED",
--                     LPM_OUTDATA           => "UNREGISTERED")
--        port map (RDCLOCK                  => clk,
--                  WRCLOCK                  => clk,
--                  RDCLKEN                  => enable,
--                  WRCLKEN                  => enable,
--                  RDADDRESS                => table_c_rd_index_slv,
--                  WRADDRESS                => table_c_wr_index_slv,
--                  data                     => c_element_slv,
--                  WREN                     => wr_table_c,
--                  RDEN                     => one,
--                  q                        => table_c_rd_val_slv);

  

  i_table_p : auk_dspip_ctc_umts_mem
    generic map(
      gADDR_WIDTH => 5,
      gDATA_WIDTH => 8
      )
    port map(
      wr_addr => table_p_wr_index,
      rd_addr => table_p_rd_index,

      datai  => gcd_dly,
      datao  => table_p_rd_val,
      reset  => reset,
      rd     => one,
      wr     => wr_table_p,
      enable => enable,
      clk    => clk
      );

--    table_p : LPM_RAM_DP
--        generic map (LPM_WIDTH             => 8,
--                     LPM_WIDTHAD           => 5,
--                     LPM_NUMWORDS          => 32,
--                     LPM_INDATA            => "REGISTERED", 
--                     LPM_RDADDRESS_CONTROL => "REGISTERED",
--                     LPM_WRADDRESS_CONTROL => "REGISTERED",
--                     LPM_OUTDATA           => "UNREGISTERED")
--        port map (RDCLOCK                  => clk,
--                  WRCLOCK                  => clk,
--                  RDCLKEN                  => enable,
--                  WRCLKEN                  => enable,
--                  RDADDRESS                => table_p_rd_index_slv,
--                  WRADDRESS                => table_p_wr_index_slv,
--                  data                     => gcd_dly_slv,
--                  WREN                     => wr_table_p,
--                  RDEN                     => one,
--                  q                        => table_p_rd_val_slv);



  i_gen_mult_seq : auk_dspip_ctc_umtsitlv_mult_seq_gen
    port map(
      prime          => prime,
      g0             => g0,
      start_mult_seq => start_mult_seq_gen,

      index    => table_c_wr_index,
      element  => c_element,
      wr       => wr_table_c,
      active   => mult_seq_gen_active,
      finished => mult_seq_gen_finished,

      abort  => synreset_multseqgn,
      reset  => reset,
      enable => enable,
      clk    => clk
      );


  i_setup : auk_dspip_ctc_umtsitlv_setup_control
    generic map(
      gCNT_WIDTH => gCOUNTER_WIDTH
      )
    port map(
      start_setup       => start_load,
      itlv_setup_active => itlv_setup_active,
      itlv_rdy          => intlvr_ready,

      R10not20 => R10not20,
      R        => R,
      K        => itlv_length,
      C        => max_column,
      RxC      => RxC_int,
      prime    => prime,
      g0       => g0,

      gcd_index => gcd_index,
      gcd       => gcd,
      wr_gcd    => wr_gcd,

      gen_mul_seq_finished => mult_seq_gen_finished,
      start_gen_mul_seq    => start_mult_seq_gen,

      flag_a  => flag_a,
      flag_b  => flag_b,
      flag_b6 => flag_b6,
      flag_c  => flag_c,

      enable => enable,
      clk    => clk,
      reset  => reset
      );


  sequence : auk_dspip_ctc_umts_ditlv_seq_gen

    port map(
      ditlv_addr       => out_addr,
      ditlv_addr_valid => ditlv_addr_valid,

      prune_me      => prune_me_s,
      seq_gen_done  => seq_gen_done,
      papbpc_index  => papbpc_rd_index,
      papbpc_val    => papbpc_rd_val,
      table_p_index => table_p_rd_index,
      table_p_val   => table_p_rd_val,
      table_c_index => table_c_rd_index,
      table_c_val   => table_c_rd_val,
      prime         => prime,
      R10not20      => R10not20,
      max_column    => max_column,
      itlv_length   => itlv_length,
      RxC           => RxC_int,
      R             => R,

      flag_a  => flag_a,
      flag_b  => flag_b,
      flag_b6 => flag_b6,
      flag_c  => flag_c,

      start_incr => start_itlv_fwd_s,
      start_decr => zero,
      reset      => reset,
      enable     => enable,
      clk        => clk
      );

  

  delay_regs : process (clk, reset)

  begin  -- process delay_regs
    -- activities triggered by asynchronous reset (active high)
    if reset = '1' then
      start_load_dly   <= '0';
      wr_table_p       <= '0';
      gcd_dly          <= (others => '0');
      setup_active_reg <= '0';
      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if enable = '1' then
        start_load_dly   <= start_load;
        wr_table_p       <= wr_gcd;
        gcd_dly          <= gcd;
        setup_active_reg <= setup_active_s;
      end if;
    end if;
  end process delay_regs;

  

end beh;
