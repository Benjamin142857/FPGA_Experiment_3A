library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package parallel_type_pkg is

  constant engine_size_c : natural := 64;
  constant din_width_c   : natural := 25;
  constant coeff_width_c : natural := 27;
  constant dout_width_c  : natural := 59;  --  =  din_width_c+1+coeff_width_c+ceil(log2(engine_size_c))
  constant num_chan_c : natural := 12;
  constant channel_width_c : natural := 4;  -- should be ceil(log2(num_chan_c))

  -- the following parameters are for tap delay chain configuration
  -- tap depth and number of taps are used to infer altshift_taps
  -- if direct form, tap_depth_c = period;
  -- if systolic, tap_depth_c = period + 1;
  constant tap_depth_c : natural := 12 + 1;
  -- number of taps excludes input x0.  
  constant num_taps_c : natural := 2*engine_size_c-1;
  constant entire_tap_length_c : natural := num_taps_c*tap_depth_c;
  -- tap_line_size_c includes x0
 constant tap_line_size_c : natural := 2*engine_size_c;
  
  constant sumof2_bitwidth_c : natural := din_width_c+1+coeff_width_c+1 ;
  
  type chainout_width_type is array(0 to engine_size_c-1) of natural;
    constant chainout_bitwidth_c : chainout_width_type  := (53, 54, 55, 55, 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59, 59 );  
-- next line is for short filter engine size of 16
--  constant chainout_bitwidth_c : chainout_width_type := (53, 54, 55, 55, 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57);
  
  type coeff_type is array(0 to engine_size_c-1) of integer;
  constant coeff_c : coeff_type := (-68410, -1, 72620, 47180, -50186, -87254, -1, 103131, 69876, -76880, -137179, -1, 167341, 114237, -126102, -224992, -1, 272466, 184877, -202637, -358757, -1, 427352, 287555, -312582, -548955, -1, 643998, 430262, -464585, -810808, -1, 940661, 625442, -672435, -1169153, -1, 1348563, 894886, -960862, -1669626, -1, 1928021, 1281814, -1380280, -2407998, -1, 2813908, 1886343, -2052032, -3624648, -1, 4379565, 3002158, -3356344, -6132191, -1, 8156832, 5998394, -7372925, -15407521, -1, 36154069, 67108863);
-- next line is for engine size 16
--  constant coeff_c : coeff_type := (173593, -207408, -472773, -1, 1055642, 950319, -1346202, -3011340, -1, 5486439, 4541061, -6140554, -13823293, -1, 35515063, 67108863);
  
  type coeff_array_type is array (0 to engine_size_c-1) of signed(coeff_width_c -1 downto 0);

 -- type tap_array_type is array (0 to num_taps_c-1) of signed(din_width_c -1 downto 0);
 -- type entire_tap_array_type is array (0 to entire_tap_length_c - 1) of signed(din_width_c -1 downto 0);
  type tap_array_type is array (natural range <>) of signed(din_width_c -1 downto 0);

  type preadder_array_type is array (0 to engine_size_c-1) of signed(din_width_c downto 0);

  type sumof2_array_type is array (0 to engine_size_c/2-1) of signed(sumof2_bitwidth_c -1 downto 0);
  
  type chainout_array is array (0 to engine_size_c-1) of signed(dout_width_c -1 downto 0);
  
--  type shift_reg_type is array (natural range <>) of std_logic;
  type shift_reg_type is array (0 to tap_line_size_c-1) of std_logic;

  type shift_chan_type is array (0 to tap_line_size_c-1) of unsigned(channel_width_c-1 downto 0);
  
end parallel_type_pkg;

