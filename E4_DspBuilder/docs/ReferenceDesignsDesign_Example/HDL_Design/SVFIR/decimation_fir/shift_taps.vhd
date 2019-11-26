library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.decimation_type_pkg.all;

-- note that data width is not controlled here; it is inherited in the taps type
entity shift_taps is
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
end entity shift_taps;

architecture arch of shift_taps is

  signal entire_tap_chain : tap_array_type(0 to entire_tap_length_c-1);

begin
  shift : process (clk, reset) is
  begin
    if reset = '1' then
      for k in 0 to entire_tap_length_c-1 loop
              entire_tap_chain(k) <= (others => '0');
      end loop;  -- k
    elsif rising_edge(clk) and (en = '1') then
      entire_tap_chain(1 to entire_tap_length_c-1) <= entire_tap_chain(0 to entire_tap_length_c-2);
      entire_tap_chain(0)                              <= data_in;
    end if;
  end process shift;

  -- data_taps ' last tap is the output of the entire chain;
  gen_taps : for i in 0 to num_taps_c-1 generate
    data_taps(i) <= entire_tap_chain((i+1)*tap_depth_c-1);
  end generate gen_taps;
  data_out <= entire_tap_chain(entire_tap_length_c -1);
end architecture arch;
