library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


Entity fir_vhdl is 
	Port(
		clock	:   in std_logic;
		sclr	:   in std_logic:='0';
		data_in			:   in std_logic_vector(15 downto 0);
		data_out		:   out std_logic_vector(32 downto 0));
end fir_vhdl;

architecture arch_fir_vhdl of fir_vhdl is

constant coef_0_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"11111111011110";  -- -34
constant coef_1_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"00001110100101";	-- 677
constant coef_2_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"00111110011110";	-- 3998
constant coef_3_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"01111111111111";  -- 8191
constant coef_4_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"01111111111111";  -- 8191
constant coef_5_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"00111110011110";	-- 3998
constant coef_6_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"00001110100101";	-- 677
constant coef_7_sig : STD_LOGIC_VECTOR (13 DOWNTO 0) := B"11111111011110";  -- -34


signal clock0_sig		:   std_logic:='1';
signal aclr3_sig		:   std_logic:='0';
signal dataa_0_sig		:   std_logic_vector(15 downto 0);
signal shiftouta_sig	: 	std_logic_vector(15 downto 0);
signal shiftouta_d_sig  :   std_logic_vector(15 downto 0);
signal result1_sig		:   std_logic_vector(31 downto 0);
signal result2_sig		:   std_logic_vector(31 downto 0);
signal add_a_sig		:   std_logic_vector(32 downto 0);
signal add_b_sig		:   std_logic_vector(32 downto 0);
signal result_sig		:   std_logic_vector(32 downto 0);

component four_mult_add 
	port
	(
		clock0		: IN STD_LOGIC  := '1';
		aclr3	 	: IN STD_LOGIC  := '0';
		dataa_0		: IN STD_LOGIC_VECTOR (15 DOWNTO 0) :=  (OTHERS => '0');
		datab_0		: IN STD_LOGIC_VECTOR (13 DOWNTO 0) :=  (OTHERS => '0');
		datab_1		: IN STD_LOGIC_VECTOR (13 DOWNTO 0) :=  (OTHERS => '0');
		datab_2		: IN STD_LOGIC_VECTOR (13 DOWNTO 0) :=  (OTHERS => '0');
		datab_3		: IN STD_LOGIC_VECTOR (13 DOWNTO 0) :=  (OTHERS => '0');
		shiftouta	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component four_mult_add;

component final_add 
	port
	(
		dataa		: IN STD_LOGIC_VECTOR (32 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (32 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		aclr		: IN STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (32 DOWNTO 0)
	);
end component final_add;

begin

four_mult_add_inst1 : four_mult_add PORT MAP (
		clock0	 => clock0_sig,
		aclr3	 => aclr3_sig,
		dataa_0	 => dataa_0_sig,
		datab_0	 => coef_0_sig,
		datab_1	 => coef_1_sig,
		datab_2	 => coef_2_sig,
		datab_3	 => coef_3_sig,
		shiftouta	 => shiftouta_sig,
		result	 => result1_sig
	);
	
four_mult_add_inst2 : four_mult_add PORT MAP (
		clock0	 => clock0_sig,
		aclr3	 => aclr3_sig,
		dataa_0	 => shiftouta_sig,
		datab_0	 => coef_4_sig,
		datab_1	 => coef_5_sig,
		datab_2	 => coef_6_sig,
		datab_3	 => coef_7_sig,
		shiftouta	 => shiftouta_d_sig,
		result	 => result2_sig
	);
	
final_add_inst : final_add PORT MAP (
		dataa	 => add_a_sig,
		datab	 => add_b_sig,
		clock	 => clock0_sig,
		aclr	 => aclr3_sig,
		result	 => result_sig
	);



dataa_0_sig 	<= 	data_in;
clock0_sig		<=  clock;
aclr3_sig		<=  sclr;
add_a_sig		<=  result1_sig(31) & result1_sig;
add_b_sig		<=  result2_sig(31) & result2_sig;
data_out		<=  result_sig;

end architecture arch_fir_vhdl;

