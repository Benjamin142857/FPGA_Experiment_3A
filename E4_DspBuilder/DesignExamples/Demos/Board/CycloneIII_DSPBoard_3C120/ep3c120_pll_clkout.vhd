-- Copyright (C) 1991-2008 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM "Quartus II"
-- VERSION "Version 8.0 Internal Build 178 03/11/2008 SJ Full Version"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY ep3c120_pll_clkout IS 
	port
	(
		clkin_50 :  IN  STD_LOGIC;
		pclk0p :  OUT  STD_LOGIC;
		pclk0n :  OUT  STD_LOGIC;
		pclk1p :  OUT  STD_LOGIC;
		pclk1n :  OUT  STD_LOGIC
	);
END ep3c120_pll_clkout;

ARCHITECTURE bdf_type OF ep3c120_pll_clkout IS 

component altpll0
	PORT(inclk0 : IN STD_LOGIC;
		 c0 : OUT STD_LOGIC;
		 c1 : OUT STD_LOGIC;
		 c2 : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
end component;

signal	clock_n :  STD_LOGIC;
signal	clock_nq :  STD_LOGIC;


BEGIN 



b2v_inst : altpll0
PORT MAP(inclk0 => clkin_50,
		 c1 => clock_n,
		 c2 => clock_nq);


pclk0n <= NOT(clock_n);



pclk1n <= NOT(clock_nq);


pclk0p <= clock_n;
pclk1p <= clock_nq;

END; 