-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library auk_dspip_lib;
use auk_dspip_lib.auk_dspip_math_pkg.all;


-------------------------------------------------------------------------------

entity tb_auk_dspip_fifo_pfc is
end entity tb_auk_dspip_fifo_pfc;

-------------------------------------------------------------------------------

architecture tb_auk_dspip_fifo_pfc_rtl of tb_auk_dspip_fifo_pfc is

  constant tclk : time := 1 us;
  constant tmax : time := 2 ms;

  constant NUM_CHANNELS_g      : integer := 5;
  constant POLY_FACTOR_g       : integer := 3;
  constant DATA_WIDTH_g        : integer := 16;
  constant ALMOST_FULL_VALUE_g : integer := 2;
  constant RAM_TYPE_g          : string  := "AUTO";

  signal datai          : std_logic_vector(DATA_WIDTH_g-1 downto 0) := (others => '0');
  signal datao          : std_logic_vector(DATA_WIDTH_g-1 downto 0);
  signal expected       : integer;
  signal expected_early : integer;
  signal channel_out    : std_logic_vector(log2_ceil(NUM_CHANNELS_g)-1 downto 0);
  signal used_w         : std_logic_vector(log2_ceil(POLY_FACTOR_g * NUM_CHANNELS_g)+1 downto 0);
  signal wrreq          : std_logic;
  signal rdreq          : std_logic;
  signal almost_full    : std_logic;
  signal empty          : std_logic;
  signal sclr           : std_logic;
  signal clk            : std_logic;
  signal reset          : std_logic;
  signal enable         : std_logic;
  signal count          : unsigned(DATA_WIDTH_g-1 downto 0);
  signal count_chan     : integer;
  signal count_poly     : integer;
  signal count_wrap     : integer;
  signal error_found    : boolean;

begin  -- architecture tb_auk_dspip_fifo_pfc_rtl

  -- purpose: increments while "incr" is high
  -- type : sequential
  -- inputs : clk, reset, incr
  -- outputs: count
  incr : process ( clk, reset )
  begin
    if reset = '1' then
      count     <= (others => '0');
    elsif rising_edge(clk) then
      if enable = '1' then
        if sclr = '1' then
          count <= (others => '0');
        else
          count <= count+1;             -- count must be signed or unsigned
        end if;

      end if;
    end if;
  end process incr;

  -- purpose: increments while "incr" is high
  -- type : sequential
  -- inputs : clk, reset, incr
  -- outputs: count
  incr_data : process ( clk, reset )
  begin
    if reset = '1' then
      datai     <= (others => '0');
    elsif rising_edge(clk) then
      if enable = '1' then
        if sclr = '1' then
          datai <= (others => '0');
        elsif wrreq = '1' then
          datai <= std_logic_vector(unsigned(datai)+1);
        end if;

      end if;
    end if;
  end process incr_data;

  -- decode test signals from counter

  sclr  <= '1'             when count = 1888                else '0';
  wrreq <= not almost_full when count < 300                 else
           ((count(0) and count(1)) or (count(9) and count(7))) and not almost_full;
  rdreq <= not (empty)     when count > 150 and count < 450 else
           ((not(count(0)) and count(1) and not(count(2))) or (count(9) and count(7) and count(8))) and not (empty);


  DUT : entity work.auk_dspip_fifo_pfc
    generic map (
      NUM_CHANNELS_g      => NUM_CHANNELS_g,
      POLY_FACTOR_g       => POLY_FACTOR_g,
      DATA_WIDTH_g        => DATA_WIDTH_g,
      ALMOST_FULL_VALUE_g => ALMOST_FULL_VALUE_g,
      RAM_TYPE_g          => RAM_TYPE_g)
    port map (
      datai               => datai,
      datao               => datao,
      channel_out         => channel_out,
      used_w              => used_w,
      wrreq               => wrreq,
      rdreq               => rdreq,
      almost_full         => almost_full,
      empty               => empty,
      sclr                => sclr,
      clk                 => clk,
      reset               => reset,
      enable              => enable);



  clkgen : process
  begin  -- process clkgen
    clk <= '0';
    wait for tclk/2;
    clk <= '1';
    wait for tclk/2;
  end process clkgen;

  resetgen : process
  begin  -- process resetgen
    reset <= '0';
    wait for tclk/4;
    reset <= '1';
    wait for tclk*2;
    reset <= '0';
    --wait for tclk*130;
    --reset <= '1';
    --wait for tclk*2;
    --reset <= '0';
    wait;
  end process resetgen;

  enablegen : process
  begin  -- process enablegen
    enable <= '1';
    wait for tclk*504;
    enable <= '0';
    wait for tclk*2;
    enable <= '1';
    wait for tclk*70;
    enable <= '0';
    wait for tclk*2;
    enable <= '1';
    wait;
  end process enablegen;

  -- purpose: stops simulations at time tmax
  stopper : process
  begin  -- process stopper
    wait for tmax;
    assert false report "simulation finished" severity failure;
  end process stopper;

  reference                                                                                              : process (clk, reset) is
                                                                                   variable expected_tmp : unsigned(DATA_WIDTH_g-1 downto 0) := (others => '0');
  begin  -- process reference
    if reset = '1' then                 -- asynchronous reset (active high)
      expected         <= 0;
      expected_early   <= 0;
      count_chan       <= 0;
      count_poly       <= 0;
      count_wrap       <= 0;
    elsif rising_edge(clk) then         -- rising clock edge
      if sclr = '1' then
        expected       <= 0;
        expected_early <= 0;
        count_chan     <= 0;
        count_poly     <= 0;
        count_wrap     <= 0;

      elsif rdreq = '1' then

        count_poly     <= (count_poly+1) mod POLY_FACTOR_g;
        if count_poly = POLY_FACTOR_g-1 then
          count_chan   <= (count_chan+1) mod NUM_CHANNELS_g;
          if count_chan = NUM_CHANNELS_g-1 then
            count_wrap <= count_wrap + 1;
          end if;
        end if;
      end if;
      expected         <= count_poly*NUM_CHANNELS_g+count_chan+count_wrap*(NUM_CHANNELS_g*POLY_FACTOR_g);
      --expected <= expected_early;
    end if;
  end process reference;

  check : process (clk, reset) is
  begin  -- process check
    if reset = '1' then                 -- asynchronous reset (active high)
      error_found   <= false;
    elsif rising_edge(clk) then         -- rising clock edge
      if expected = to_integer(unsigned(datao)) then
        error_found <= false;
      else
        error_found <= true;
      end if;
    end if;
  end process check;

end architecture tb_auk_dspip_fifo_pfc_rtl;

