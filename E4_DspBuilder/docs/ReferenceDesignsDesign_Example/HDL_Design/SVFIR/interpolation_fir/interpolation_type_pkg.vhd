library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

package interpolation_type_pkg is

  constant engine_size_c     : natural := 32;
  constant din_width_c       : natural := 25;
  constant coeff_width_c     : natural := 27;
--  dout_width_c  = din_width_c+1+coeff_width_c+ceil(log2(engine_size_c))
  constant dout_width_c      : natural := 57;
  constant num_chan_c        : natural := 4;
  constant channel_width_c   : natural := 2;  -- should be ceil(log2(num_chan_c))
  constant rate_width_c      : natural := 2;  -- = ceil(log2(rate_c)), the signal width of polyphase select signal
  constant rate_c            : natural := 4;  -- interpolation rate
  constant n_c               : natural := 4;  -- = Period/Rate=N
  -- the following parameters are for tap delay chain configuration
  -- tap depth and number of taps are used to infer altshift_taps
  constant tap_depth_c       : natural := n_c;
  constant sumof2_bitwidth_c : natural := din_width_c+coeff_width_c+1;

  type coeff_matrix_t is array (0 to engine_size_c-1, 0 to rate_c-1) of integer;
  constant coeff_matrix_c : coeff_matrix_t := (
    0  => (240810, 195531, 130252, 47180),
    1  => (-50186, -156499, -264126, -363040),
    2  => (-441185, -485397, -482888, -423161),
    3  => (-300146, -114239, 126100, 403544),
    4  => (692191, 959124, 1167271, 1279394),
    5  => (1262873, 1094764, 766501, 287555),
    6  => (-312582, -984608, -1662142, -2266972),
    7  => (-2716572, -2933267, -2854162, -2440779),
    8  => (-1687177, -625444, 672433, 2096996),
    9  => (3508286, 4747141, 5650091, 6066634),
    10 => (5877324, 5010835, 3458108, 1281814),
    11 => (-1380280, -4318995, -7264733, -9905374),
    12 => (-11909906, -12956012, -12759291, -11101511),
    13 => (-7855210, -3002160, 3356342, 10998722),
    14 => (19592477, 28713249, 37872374, 46550809),
    15 => (54236734, 60463704, 64846101, 67108863),
    16 => (67108863, 64846101, 60463704, 54236734),
    17 => (46550809, 37872374, 28713249, 19592477),
    18 => (10998722, 3356342, -3002160, -7855210),
    19 => (-11101511, -12759291, -12956012, -11909906),
    20 => (-9905374, -7264733, -4318995, -1380280),
    21 => (1281814, 3458108, 5010835, 5877324),
    22 => (6066634, 5650091, 4747141, 3508286),
    23 => (2096996, 672433, -625444, -1687177),
    24 => (-2440779, -2854162, -2933267, -2716572),
    25 => (-2266972, -1662142, -984608, -312582),
    26 => (287555, 766501, 1094764, 1262873),
    27 => (1279394, 1167271, 959124, 692191),
    28 => (403544, 126100, -114239, -300146),
    29 => (-423161, -482888, -485397, -441185),
    30 => (-363040, -264126, -156499, -50186),
    31 => (47180, 130252, 195531, 240810)); 

  type coeff_matrix_signed_t is array (0 to engine_size_c-1, 0 to rate_c-1) of signed(coeff_width_c-1 downto 0);

  -- from QII template of ROM
  -- each multiplier has its own rom, thus needing engine_size_c such rom;
  -- each rom has rate_c words
  subtype word_t is signed((coeff_width_c-1) downto 0);
  type memory_t is array(0 to rate_c-1) of word_t;
  type memory_array_t is array (0 to engine_size_c-1) of memory_t;  -- 2D
  type coeff_row_signed_t is array(0 to engine_size_c-1) of word_t;

  type tap_array_type is array (natural range <>) of signed(din_width_c -1 downto 0);

  type multout_array_type is array (0 to engine_size_c-1) of signed(din_width_c+coeff_width_c-1 downto 0);

  type sumof2_array_type is array (0 to engine_size_c/2-1) of signed(sumof2_bitwidth_c -1 downto 0);

  type my_altera_mf_logic_2D is array (natural range <>) of std_logic_vector(sumof2_bitwidth_c-1 downto 0);

  type shift_valid_type is array (natural range <>) of std_logic;

  type shift_chan_type is array (natural range <>) of unsigned(channel_width_c-1 downto 0);
  
end interpolation_type_pkg;

