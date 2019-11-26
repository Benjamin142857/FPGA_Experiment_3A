-------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY TFFE IS	
	PORT
	(
		t	: IN STD_LOGIC;
		clk   : IN STD_LOGIC;
		ena	: IN STD_LOGIC;
		prn	: IN STD_LOGIC;
		clrn	: IN STD_LOGIC;
		q		: OUT STD_LOGIC
	);
END TFFE;


ARCHITECTURE SYN OF TFFE IS

signal iq	: std_logic :='0';

BEGIN

	p:process(clk, prn, clrn)
		begin	
		if clrn='0' then 
			iq <= '0';
		elsif prn='0' then 
			iq <= '1';
		elsif clk'event and clk='1' then
			if (ena='1') and (t='1') then
				iq <= not iq;
			end if;					
		end if;		
	end process;
	
	q <= iq;
	
END SYN;