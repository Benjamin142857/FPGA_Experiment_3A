library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package systolic_type_pkg is

  constant engine_size_c : natural := 32;
  constant din_width_c   : natural := 25;
  constant coeff_width_c : natural := 27;
  constant dout_width_c  : natural := 58;  --  =  din_width_c+1+coeff_width_c+ceil(log2(engine_size_c))
  constant tap_line_size_c : natural := 2*engine_size_c;
  
  type chainout_width_type is array(0 to engine_size_c-1) of natural;
  constant chainout_bitwidth_c : chainout_width_type := (53, 54, 55, 55, 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58);
  
  type coeff_type is array(0 to engine_size_c-1) of integer;
  constant coeff_c : coeff_type := (103188, 67747, -75861, -143186, 0, 208547, 157491, -192299, -378316, 0, 548852, 404403, -478970, -912354, 0, 1245085, 893421, -1034232, -1933299, 0, 2576322, 1841494, -2137162, -4036195, 0, 5667571, 4257561, -5326068, -11286771, 0, 26948102, 50193808);

  type coeff_array is array (0 to engine_size_c-1) of signed(coeff_width_c -1 downto 0);

  type tap_array is array (0 to tap_line_size_c-1) of signed(din_width_c -1 downto 0);

  type preadder_array is array (0 to engine_size_c-1) of signed(din_width_c downto 0);

  type chainout_array is array (0 to engine_size_c-1) of signed(dout_width_c -1 downto 0);

  type shift_reg_type is array (0 to 2*engine_size_c-1) of std_logic;
  
end systolic_type_pkg;

