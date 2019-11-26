library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;
use work.systolic_type_pkg.all;

entity tb_systolic_fir is

  constant FIR_INPUT_FILE_c  : string := "sine_systolic_fir_input.txt";
  constant FIR_OUTPUT_FILE_c : string := "systolic_fir_output.txt";
--  constant DATA_WIDTH_c             : natural := 25;
--  constant OUT_WIDTH_c              : natural := 58;
--  constant COEF_SET_ADDRESS_WIDTH_c : natural := 0;

end entity tb_systolic_fir;


architecture rtl of tb_systolic_fir is
  
  signal in_data    : signed (DIN_WIDTH_c-1 downto 0) := (others => '0');
  signal out_data  : signed (DOUT_WIDTH_c-1 downto 0);
  signal in_valid   : std_logic                                  := '0';
  signal out_valid : std_logic;
  signal clk            : std_logic := '0';
  signal reset        : std_logic := '0';
  signal eof            : std_logic := '0';
  signal start : std_logic;
  
  constant tclk           : time := 10 ns;  -- 100MHz
  constant time_lapse_max : time := 60 us;
  signal time_lapse       : time;

  function div_ceil(a : natural; b : natural) return natural is
    variable res : natural := a/b;
  begin
    if res*b /= a then
      res := res +1;
    end if;
    return res;
  end div_ceil;

  function to_hex (value : in signed) return string is
    constant ne     : integer        := (value'length+3)/4;
    constant NUS    : string(2 to 1) := (others => ' ');  
    variable pad    : std_logic_vector(0 to (ne*4 - value'length) - 1);
    variable ivalue : std_logic_vector(0 to ne*4 - 1);
    variable result : string(1 to ne);
    variable quad   : std_logic_vector(0 to 3);
  begin
    if value'length < 1 then
      return NUS;
    else
      if value (value'left) = 'Z' then
        pad := (others => 'Z');
      else
        pad := (others => value(value'high));             
      end if;
      ivalue := pad & std_logic_vector (value);
      for i in 0 to ne-1 loop
        quad := To_X01Z(ivalue(4*i to 4*i+3));
        case quad is
          when x"0"   => result(i+1) := '0';
          when x"1"   => result(i+1) := '1';
          when x"2"   => result(i+1) := '2';
          when x"3"   => result(i+1) := '3';
          when x"4"   => result(i+1) := '4';
          when x"5"   => result(i+1) := '5';
          when x"6"   => result(i+1) := '6';
          when x"7"   => result(i+1) := '7';
          when x"8"   => result(i+1) := '8';
          when x"9"   => result(i+1) := '9';
          when x"A"   => result(i+1) := 'A';
          when x"B"   => result(i+1) := 'B';
          when x"C"   => result(i+1) := 'C';
          when x"D"   => result(i+1) := 'D';
          when x"E"   => result(i+1) := 'E';
          when x"F"   => result(i+1) := 'F';
          when "ZZZZ" => result(i+1) := 'Z';
          when others => result(i+1) := 'X';
        end case;
      end loop;
      return result;
    end if;
  end function to_hex;

  component systolic_fir is
  generic (
    engine_size_c : natural ;
    din_width_c   : natural ;
    coeff_width_c : natural ;
    dout_width_c  : natural ); 
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    in_data       : in  signed(din_width_c-1 downto 0);
    in_valid  : in  std_logic;
    out_data  : out signed(dout_width_c-1 downto 0);
    out_valid : out std_logic);
end component systolic_fir;
  
begin
  
  systolic_fir_inst: systolic_fir
    generic map (
      engine_size_c => engine_size_c,
      din_width_c   => DATA_WIDTH_c,
      coeff_width_c => engine_size_c,
      dout_width_c  => OUT_WIDTH_c)
    port map (
      clk                => clk,
      reset            => reset,
      in_data      => in_data,
      out_data    => out_data,
      in_valid     => in_valid,
      out_valid   => out_valid);

  -- start valid for first cycle to indicate that the file reading should start.
  -- start drops to '0' upon first in_valid assertion
  start_p : process (clk, reset)
  begin
    if reset = '1' then
      start <= '1';
    elsif rising_edge(clk) then
      if in_valid = '1' then
        start <= '0';
      end if;
    end if;
  end process start_p;
  -----------------------------------------------------------------------------------------------
  -- Read input data from file                                                                 
  -----------------------------------------------------------------------------------------------
  source_model : process(clk) is
    file in_file     : text open read_mode is FIR_INPUT_FILE_c;
    variable data_in : integer;
    variable indata  : line;
  begin
    if rising_edge(clk) then
      if(reset = '1') then
        in_data  <= to_signed(0, DIN_WIDTH_c) after tclk/4;
        in_valid <= '0' after tclk/4;
        eof            <= '0';
      else
        if not endfile(in_file) and (eof = '0') then
          eof <= '0';
          if((in_valid = '1' ) or
             (start = '1'and in_valid = '0' )) then
            readline(in_file, indata);
            read(indata, data_in);
            in_valid <= '1' after tclk/4;
            in_data  <= to_signed(data_in, DIN_WIDTH_c) after tclk/4;
          end if;
        else
          eof            <= '1';
          in_valid <= '0' after tclk/4;
          in_data  <= to_signed(0, DIN_WIDTH_c) after tclk/4;
        end if;
      end if;
    end if;
  end process source_model;
  ---------------------------------------------------------------------------------------------
  -- Write FIR output to file                                               
  ---------------------------------------------------------------------------------------------

  sink_model : process(clk) is
    file ro_file   : text open write_mode is FIR_OUTPUT_FILE_c;
    variable rdata : line;
    variable data_r : string(div_ceil(DOUT_WIDTH_c,4) downto 1);
  begin
    if rising_edge(clk) then
      if(out_valid = '1') then
        -- report as hex representation of integer.
        data_r := to_hex(out_data);
        write(rdata, data_r);
        writeline(ro_file, rdata);
      end if;
    end if;
  end process sink_model;
-------------------------------------------------------------------------------
-- clock generator
-------------------------------------------------------------------------------      
  clkgen : process
  begin  -- process clkgen
    if eof = '1' then
      clk <= '0';
      assert FALSE
        report "NOTE: Stimuli ended" severity note;
      wait;
    elsif time_lapse >= time_lapse_max then
      clk <= '0';
      assert FALSE
        report "ERROR: Reached time_lapse_max without activity, probably simulation is stuck!" severity Error;
      wait;      
    else
      clk <= '0';
      wait for tclk/2;
      clk <= '1';
      wait for tclk/2;
    end if;
  end process clkgen;

  monitor_toggling_activity : process(clk, reset,
                                      out_data, out_valid)
  begin
    if reset = '1' then
      time_lapse <= 0 ns;
    elsif out_data'event or out_valid'event then
      time_lapse <= 0 ns;
    elsif rising_edge(clk) then
      if time_lapse < time_lapse_max then
        time_lapse <= time_lapse + tclk;
      end if;
    end if;
  end process monitor_toggling_activity;


-------------------------------------------------------------------------------
-- reset generator
-------------------------------------------------------------------------------
  reset_gen : process
  begin  -- process resetgen
    reset <= '0';
    wait for tclk/4;
    reset <= '1';
    wait for tclk*2;
    reset <= '0';
    wait;
  end process reset_gen;  

-------------------------------------------------------------------------------
-- control signals
-------------------------------------------------------------------------------

end architecture rtl;