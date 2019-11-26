library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.interpolation_type_pkg.all;

entity delay_tap_chain is
  generic (
    din_width_c         : natural;
    engine_size_c : natural;
    rate_c         : natural;
    rate_width_c : natural;
    n_c          : natural);
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    en        : in  std_logic;
    sel : in unsigned(rate_width_c-1 downto 0);  
    din   : in  signed(din_width_c-1 downto 0);
    taps : out tap_array_type(0 to engine_size_c-1)
    );
end entity delay_tap_chain;

architecture arch of delay_tap_chain is

  signal tap_block : tap_array_type(0 to rate_c*engine_size_c-1);
  
 component shift_taps is
  generic (
    din_width_c         : natural;
    entire_tap_length_c : natural;
    tap_depth_c         : natural;
    num_taps_c          : natural);
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    en        : in  std_logic;
    data_in   : in  signed(din_width_c-1 downto 0);
    data_taps : out tap_array_type(0 to num_taps_c-1);
    data_out  : out signed(din_width_c-1 downto 0)
    );
end component shift_taps;  

begin

  tap_block(0) <= din;
  tap_inst_0: component shift_taps
    generic map (
      din_width_c => din_width_c,
      entire_tap_length_c => n_c*(rate_c-1),
      num_taps_c => rate_c-1,
      tap_depth_c => n_c)
    port map (
      clk       => clk,
      reset     => reset,
      en        => en,
      data_in   => din,
      data_taps => tap_block(1 to rate_c-1));

tap_gen: for i in 1 to engine_size_c-1 generate
tap_inst: component shift_taps
    generic map (
      din_width_c         => din_width_c,
      tap_depth_c         => n_c,
      num_taps_c          => rate_c,
      entire_tap_length_c => rate_c*n_c)
    port map (
      clk       => clk,
      reset     => reset,
      en        => en,
      data_in   => tap_block(i*rate_c-1),
      data_taps => tap_block(i*rate_c to (i+1)*rate_c-1));  
end generate tap_gen;

         -- is there a way to parameterize the case statement or mux? now
         -- limited to R=4
-- right now the output of the mux is not registered.  if registered, sel to
-- coefficients select needs to be registered as well
mux_gen: for k in 0 to engine_size_c-1 generate
  mux_inst: process (sel, tap_block(k*rate_c to (k+1)*rate_c-1)) is
  begin  -- process mux_inst
    case to_integer(sel) is
      when 0 =>
        taps(k) <= tap_block(k*rate_c);
      when 1 =>
        taps(k) <= tap_block(k*rate_c+1);
      when 2 =>
        taps(k) <= tap_block(k*rate_c+2);
      when 3 =>
        taps(k) <= tap_block(k*rate_c+3);
      when others => null;
    end case;
  end process mux_inst;
end generate mux_gen;
    
end architecture arch;
