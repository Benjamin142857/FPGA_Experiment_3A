
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DFFE IS	
	PORT
	(
		d	: IN STD_LOGIC;
		clk   : IN STD_LOGIC;
		ena	: IN STD_LOGIC;
		prn	: IN STD_LOGIC;
		clrn	: IN STD_LOGIC;
		q		: OUT STD_LOGIC
	);
END DFFE;


ARCHITECTURE SYN OF DFFE IS


BEGIN

	p:process(prn, clrn, clk)
		begin	
		if clrn='0' then 
			q <= '0';
		elsif prn='0' then 
			q <= '1';
		elsif clk'event and clk='1' then
			if (ena='1') then
				q <= d;
			end if;					
		end if;
	end process;	
END SYN;


