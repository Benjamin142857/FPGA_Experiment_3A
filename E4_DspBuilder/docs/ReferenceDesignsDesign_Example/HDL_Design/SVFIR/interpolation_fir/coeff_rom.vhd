-- Quartus II VHDL Template
-- Single-Port ROM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.interpolation_type_pkg.all;

entity coeff_rom is

  generic
    (coeff_width_c : natural := 27;
     contents_c    : memory_t;          -- coefficients for 1 multiplier across
                                  -- rate_c polyphases
     rate_c        : natural := 4);
  port
    (addr : in  natural range 0 to rate_c - 1;
     q    : out word_t);
end entity;

architecture rtl of coeff_rom is
  -- Build a 2-D array type for the RoM
  -- initialize ROM contents to the input coefficients vector
  function init_rom
    return memory_t is
    variable tmp : memory_t := (others => (others => '0'));
  begin
    for addr_pos in 0 to rate_c - 1 loop
      -- Initialize each address with the coeff vector
      tmp(addr_pos) := contents_c(addr_pos);
    end loop;
    return tmp;
  end init_rom;

  -- Declare the ROM signal and specify a default value.        Quartus II
  -- will create a memory initialization file (.mif) based on the 
  -- default value.
  signal rom : memory_t := init_rom;
-- this is combinational logic
begin
  process(addr)
  begin
    q <= rom(addr);
  end process;

end rtl;
