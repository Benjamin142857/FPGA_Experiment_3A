library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

package decimation_type_pkg is

  constant engine_size_c     : natural := 32;
  constant din_width_c       : natural := 25;
  constant coeff_width_c     : natural := 27;
--  dout_width_c = din_width_c+1+coeff_width_c+ceil(log2(engine size))+ceil(log2(rate))
  constant dout_width_c      : natural := 59;
  constant num_chan_c        : natural := 4;
  constant channel_width_c   : natural := 2;  -- should be ceil(log2(num_chan_c))
  constant rate_width_c      : natural := 2;  -- = ceil(log2(rate_c)), the signal width of polyphase select signal
  constant rate_c            : natural := 4;  -- decimation rate
  constant period_in_c       : natural := 4;  -- = Period in = 4
  constant period_out_c      : natural := 16;                     -- period out
  constant sumof2_bitwidth_c : natural := din_width_c+coeff_width_c+1;
  constant adderout_width_c  : natural := sumof2_bitwidth_c + 4;  -- =sumof2_outwidth + ceil(log2(engine size/2))
  -- the following parameters are for tap delay chain configuration
  -- tap depth and number of taps are used to infer altshift_taps
  constant tap_depth_c       : natural := period_in_c*rate_c;
  -- define pipeline level in adder tree
  constant pipeline_c        : natural := 4;

--  type coeff_row_t is array(0 to engine_size_c-1) of integer;
  type coeff_matrix_t is array (0 to engine_size_c-1, 0 to rate_c-1) of integer;

-- this coefficients matrix has polyphases flipped for decimation FIR
  constant coeff_matrix_c : coeff_matrix_t := (
    0  => (47180, 130252, 195531, 240810),
    1  => (-363040, -264126, -156499, -50186),
    2  => (-423161, -482888, -485397, -441185),
    3  => (403544, 126100, -114239, -300146),
    4  => (1279394, 1167271, 959124, 692191),
    5  => (287555, 766501, 1094764, 1262873),
    6  => (-2266972, -1662142, -984608, -312582),
    7  => (-2440779, -2854162, -2933267, -2716572),
    8  => (2096996, 672433, -625444, -1687177),
    9  => (6066634, 5650091, 4747141, 3508286),
    10 => (1281814, 3458108, 5010835, 5877324),
    11 => (-9905374, -7264733, -4318995, -1380280),
    12 => (-11101511, -12759291, -12956012, -11909906),
    13 => (10998722, 3356342, -3002160, -7855210),
    14 => (46550809, 37872374, 28713249, 19592477),
    15 => (67108863, 64846101, 60463704, 54236734),
    16 => (54236734, 60463704, 64846101, 67108863),
    17 => (19592477, 28713249, 37872374, 46550809),
    18 => (-7855210, -3002160, 3356342, 10998722),
    19 => (-11909906, -12956012, -12759291, -11101511),
    20 => (-1380280, -4318995, -7264733, -9905374),
    21 => (5877324, 5010835, 3458108, 1281814),
    22 => (3508286, 4747141, 5650091, 6066634),
    23 => (-1687177, -625444, 672433, 2096996),
    24 => (-2716572, -2933267, -2854162, -2440779),
    25 => (-312582, -984608, -1662142, -2266972),
    26 => (1262873, 1094764, 766501, 287555),
    27 => (692191, 959124, 1167271, 1279394),
    28 => (-300146, -114239, 126100, 403544),
    29 => (-441185, -485397, -482888, -423161),
    30 => (-50186, -156499, -264126, -363040),
    31 => (240810, 195531, 130252, 47180));  

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

--      type ALTERA_MF_LOGIC_2D is array (NATURAL RANGE <>, NATURAL RANGE <>) of STD_LOGIC;  
  type my_altera_mf_logic_2D is array (natural range <>) of std_logic_vector(sumof2_bitwidth_c-1 downto 0);

  type shift_valid_type is array (natural range <>) of std_logic;


  type shift_chan_type is array (natural range <>) of unsigned(channel_width_c-1 downto 0);
  type shift_data_type is array (natural range <>) of signed(dout_width_c-1 downto 0);
  
end decimation_type_pkg;

