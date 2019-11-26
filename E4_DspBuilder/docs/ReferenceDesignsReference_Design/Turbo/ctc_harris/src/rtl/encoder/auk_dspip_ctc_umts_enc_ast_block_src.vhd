-- ================================================================================
-- Legal Notice: Copyright (C) 1991-2008 Altera Corporation
-- Any megafunction design, and related net list (encrypted or decrypted),
-- support information, device programming or simulation file, and any other
-- associated documentation or information provided by Altera or a partner
-- under Altera's Megafunction Partnership Program may be used only to
-- program PLD devices (but not masked PLD devices) from Altera.  Any other
-- use of such megafunction design, net list, support information, device
-- programming or simulation file, or any other related documentation or
-- information is prohibited for any other purpose, including, but not
-- limited to modification, reverse engineering, de-compiling, or use with
-- any other silicon devices, unless such use is explicitly licensed under
-- a separate agreement with Altera or a megafunction partner.  Title to
-- the intellectual property, including patents, copyrights, trademarks,
-- trade secrets, or maskworks, embodied in any such megafunction design,
-- net list, support information, device programming or simulation file, or
-- any other related documentation or information provided by Altera or a
-- megafunction partner, remains with Altera, the megafunction partner, or
-- their respective licensors.  No other licenses, including any licenses
-- needed under any third party's intellectual property, are provided herein.
-- ================================================================================
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;

entity auk_dspip_ctc_umts_enc_ast_block_src is
  generic (
    MAX_BLK_SIZE_WIDTH_g : natural := 10;
    DATAWIDTH_g          : natural := 18
    );
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    blk_size     : in  std_logic_vector(MAX_BLK_SIZE_WIDTH_g-1 downto 0);
    in_valid     : in  std_logic;
    source_stall : out std_logic;
    in_data      : in  std_logic_vector(DATAWIDTH_g - 1 downto 0);
    in_sop       : in  std_logic;
    in_eop       : in  std_logic;
    source_valid : out std_logic;
    source_ready : in  std_logic;
    source_sop   : out std_logic;
    source_eop   : out std_logic;
    source_data  : out std_logic_vector(DATAWIDTH_g - 1 downto 0)
    );
end entity auk_dspip_ctc_umts_enc_ast_block_src;



architecture rtl of auk_dspip_ctc_umts_enc_ast_block_src is

--  constant MAX_PWR_2_c : natural := log2_ceil(MAX_BLK_SIZE_WIDTH_g) rem 2;

  type   state_t is (IDLE, OUT_1, OUT_2, OUT_3);
  signal state      : state_t;
  signal next_state : state_t;

  signal data_count : unsigned(MAX_BLK_SIZE_WIDTH_g-1 downto 0);

  type shunt_registers_t is array (1 downto 0) of std_logic_vector(DATAWIDTH_g - 1 downto 0);

  signal in_data_shunt : shunt_registers_t;

  -- control signals
  signal source_valid_s : std_logic;
  signal source_stall_s : std_logic;

begin  -- architecture rtl

 -----------------------------------------------------------------------------
  -- assign ouotputs
  -----------------------------------------------------------------------------

  -- control signals
  source_valid <= source_valid_s;



 ------------------------------------------------------------------------------
 -- stall when there is no ready from the receiver, or while the shunt
 -- registers are full.
 ------------------------------------------------------------------------------
  stall_p : process (clk, reset)
  begin  -- process stall_p
    if reset = '1' then  
      source_stall_s <= '0';
    elsif rising_edge(clk) then 
      if (source_valid_s = '1' and source_ready = '0' ) or
        (source_valid_s = '1' and source_ready = '1' and state = OUT_3) then
        source_stall_s <= '1';
      else
        source_stall_s <= '0';
      end if;
    end if;
  end process stall_p;
  
  source_stall   <= source_stall_s;


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  fsm_reg : process (clk, reset) is
  begin
    if reset = '1' then
      state <= IDLE;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process fsm_reg;

  fsm_cmb : process(in_valid, source_ready, state) is
  begin
    case state is

      when IDLE =>
        next_state <= IDLE;
        if in_valid = '1' then
          next_state <= OUT_1;
        end if;

      when OUT_1 =>
        next_state <= OUT_1;
        if in_valid = '1' then
          if source_ready = '1' then
            next_state <= OUT_1;
          else
            next_state <= OUT_2;
          end if;
        elsif in_valid = '0' then
          if source_ready = '1' then
            next_state <= IDLE;
          end if;
        end if;
        
      when OUT_2 =>
        next_state <= OUT_2;
        if in_valid = '1' then
          if source_ready = '1' then
            next_state <= OUT_2;
          else
            next_state <= OUT_3;
          end if;
        elsif in_valid = '0' then
          if source_ready = '1'  then
            next_state <= OUT_1;
            else
              next_state <= OUT_2;
          end if;
        end if;
        
      when OUT_3 =>
        next_state <= OUT_3;
        if in_valid = '1' then
          -- in_valid should not be asserted (stalled previous to this state)
          assert in_valid = '1' report "in_valid asserted in state OUT_3" severity error;
        elsif in_valid = '0' then
          if source_ready = '1'  then
            next_state <= OUT_2;
            else
              next_state <= OUT_3;
          end if;
        end if;
        
      when others =>
        next_state <= IDLE;
        
    end case;
  end process fsm_cmb;

 
  -- outputs from fsm
  source_valid_s <= '1' when (state = OUT_1 or state = OUT_2 or state = OUT_3 ) else
                    '0';

  -----------------------------------------------------------------------------
  -- Data is shunted between registers.
  -----------------------------------------------------------------------------
  shunt_p : process (clk, reset)
  begin  -- process shunt_p
    if reset = '1' then  
      in_data_shunt <= (others => (others => '0'));
    elsif rising_edge(clk) then 
      -- first shunt register
      if (in_valid = '1' and source_ready = '0' and state = OUT_1) or
          (in_valid = '1' and source_ready = '1' and state = OUT_2) then
          in_data_shunt(0) <= in_data;
      elsif source_ready = '1' and state = OUT_3 then
          in_data_shunt(0) <= in_data_shunt(1);
      end if;
      -- second shunt register.
       if in_valid = '1' and source_ready = '0' and state = OUT_2 then
          in_data_shunt(1) <= in_data;
       end if;
    end if;
  end process shunt_p;

  -- output data register
  out_data_p : process (clk, reset)
  begin  -- process out_data_p
    if reset = '1' then  
      source_data <= (others => '0');
    elsif rising_edge(clk) then 
      if (in_valid = '1' and state = IDLE) or
      (in_valid = '1' and source_ready = '1' and state = OUT_1) then
        source_data <= in_data;
      elsif source_ready = '1' and (state = OUT_2 or state = OUT_3) then
        source_data <= in_data_shunt(0);
      end if;
    end if;
  end process out_data_p;
  

  source_sop <= '1' when data_count = 0 else
                '0';
  source_eop <= '1' when data_count = unsigned(blk_size) - 1 else
                '0';

  data_count_p : process (clk, reset) is
  begin
    if reset = '1' then
      data_count <= to_unsigned(0,MAX_BLK_SIZE_WIDTH_g);
    elsif rising_edge(clk) then
      if source_valid_s = '1' and source_ready = '1' then
        if data_count = unsigned(blk_size) - 1 then
          data_count <= to_unsigned(0, MAX_BLK_SIZE_WIDTH_g);
        else
          data_count <= data_count + 1;
        end if;
      end if;
    end if;

  end process data_count_p;

end architecture rtl;
