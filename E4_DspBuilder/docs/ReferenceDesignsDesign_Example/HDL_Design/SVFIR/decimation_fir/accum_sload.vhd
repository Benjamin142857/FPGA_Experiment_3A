library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.decimation_type_pkg.all;

entity accum_sload is
  generic (
    din_width_c         : natural;
    num_delay_c : natural);
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    en        : in  std_logic;
    load : in std_logic;
    data_in   : in  signed(din_width_c-1 downto 0);
    data_out  : out signed(din_width_c-1 downto 0)
    );
end entity accum_sload;

architecture arch of accum_sload is

  signal adder_out: signed(din_width_c-1 downto 0);
  signal dataa, datab : signed(din_width_c-1 downto 0);
  signal delay_sig : shift_data_type(0 to num_delay_c-1);

begin

  delay_proc : process (clk, reset) is
  begin  
    if reset = '1' then                 -- asynchronous reset (active high)
      for m in 0 to num_delay_c-1 loop
        delay_sig(m) <= (others => '0');
      end loop;  -- m
    elsif rising_edge(clk) and (en = '1') then
      delay_sig(1 to num_delay_c-1)  <= delay_sig(0 to num_delay_c-2);
      delay_sig(0) <= adder_out;
    end if;
  end process delay_proc;
  
adder_gen: process (load, dataa, datab) is
begin  -- process adder_gen
  if load = '1' then
    adder_out <= dataa;
  else
    adder_out <= dataa + datab;
  end if;
end process adder_gen;

dataa <= data_in;
datab <= delay_sig(num_delay_c-1);
data_out <= delay_sig(num_delay_c-1);

end architecture arch;
