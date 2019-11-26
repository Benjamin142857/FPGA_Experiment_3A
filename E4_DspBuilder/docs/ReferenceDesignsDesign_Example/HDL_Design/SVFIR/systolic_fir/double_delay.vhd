library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity double_delay is
  generic (
    width_c : natural := 25);
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    din   : in  signed(width_c -1 downto 0);
    dout  : out signed(width_c -1 downto 0);
    en    : in  std_logic);
end entity double_delay;

architecture rtl of double_delay is
  signal dout_wire1, dout_wire2 : signed(width_c - 1 downto 0);
begin  -- architecture rtl

  -- purpose: double delay
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: 
  delay: process (clk, reset) is
  begin  -- process delay
      if reset = '1' then                 -- asynchronous reset (active high)
        dout_wire1 <= (others => '0');
        dout_wire2 <= (others => '0');
      elsif rising_edge(clk) and (en = '1') then
        dout_wire1 <= din;
        dout_wire2 <= dout_wire1;
      end if;
  end process delay;
  dout <= dout_wire2;
end architecture rtl;
