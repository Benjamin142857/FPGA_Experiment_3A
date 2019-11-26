library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity several_delays is
  generic (
    WIDTH_g          : natural := 8;
    DELAY_g          : natural := 8;
    MEMORY_TYPE_g    : string  := "AUTO";
    REGISTER_FIRST_g : natural := 1;
    REGISTER_LAST_g  : natural := 1);
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    enable  : in  std_logic;
    datain  : in  std_logic_vector(WIDTH_g-1 downto 0);
    dataout0 : out std_logic_vector(WIDTH_g-1 downto 0);
    dataout1 : out std_logic_vector(WIDTH_g-1 downto 0);
    dataout2 : out std_logic_vector(WIDTH_g-1 downto 0);
    dataout3 : out std_logic_vector(WIDTH_g-1 downto 0);
    dataout4 : out std_logic_vector(WIDTH_g-1 downto 0);
    dataout5 : out std_logic_vector(WIDTH_g-1 downto 0);
    dataout6 : out std_logic_vector(WIDTH_g-1 downto 0);
    dataout7 : out std_logic_vector(WIDTH_g-1 downto 0));
end entity several_delays;

architecture struct of several_delays is
  component auk_dspip_delay
    generic (
      WIDTH_g          : natural;
      DELAY_g          : natural;
      MEMORY_TYPE_g    : string;
      REGISTER_FIRST_g : natural;
      REGISTER_LAST_g  : natural);
    port (
      clk     : in  std_logic;
      reset   : in  std_logic;
      enable  : in  std_logic;
      datain  : in  std_logic_vector(WIDTH_g-1 downto 0);
      dataout : out std_logic_vector(WIDTH_g-1 downto 0));
  end component auk_dspip_delay;
begin  -- architecture struct
  delay_M4K: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "M4K",
        REGISTER_FIRST_g => 0,
        REGISTER_LAST_g  => 0)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout0);
  delay_reg: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "REGISTER",
        REGISTER_FIRST_g => 0,
        REGISTER_LAST_g  => 1)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout1);
  delay_auto00: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "AUTO",
        REGISTER_FIRST_g => 0,
        REGISTER_LAST_g  => 0)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout2);
  delay_auto01: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "AUTO",
        REGISTER_FIRST_g => 0,
        REGISTER_LAST_g  => 1)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout3);
  delay_auto10: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "AUTO",
        REGISTER_FIRST_g => 1,
        REGISTER_LAST_g  => 0)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout4);
  delay_auto11: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "AUTO",
        REGISTER_FIRST_g => 1,
        REGISTER_LAST_g  => 1)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout5);
  delay_MRAM: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "AUTO",
        REGISTER_FIRST_g => 0,
        REGISTER_LAST_g  => 0)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout6);
  delay_M512: entity work.auk_dspip_delay
    generic map (
        WIDTH_g          => WIDTH_g,
        DELAY_g          => DELAY_g,
        MEMORY_TYPE_g    => "M512",
        REGISTER_FIRST_g => 1,
        REGISTER_LAST_g  => 1)
    port map (
        clk     => clk,
        reset   => reset,
        enable  => enable,
        datain  => datain,
        dataout => dataout7);
end architecture struct;

