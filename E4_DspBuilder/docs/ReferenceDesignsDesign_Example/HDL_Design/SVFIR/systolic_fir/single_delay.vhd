library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_delay is
  generic (
    width_c : natural := 25);
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    din   : in  signed(width_c -1 downto 0);
    dout  : out signed(width_c -1 downto 0);
    en    : in  std_logic);
end entity single_delay;

architecture rtl of single_delay is
  signal dout_wire : signed(width_c - 1 downto 0);
begin  -- architecture rtl

  -- purpose: single delay
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: 
  delay: process (clk, reset) is
  begin  -- process delay
    if reset = '1' then                 -- asynchronous reset (active high)
      dout_wire <= (others => '0');
    elsif rising_edge(clk) then 
      if en = '1' then
        dout_wire <= din;
        else
          dout_wire <= dout_wire;
      end if;
    end if;
  end process delay;
  dout <= dout_wire;
end architecture rtl;
