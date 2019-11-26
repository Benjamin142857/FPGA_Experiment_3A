-- megafunction wizard: %LPM_ADD_SUB%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_add_sub 

-- ============================================================
-- File Name: final_add.vhd
-- Megafunction Name(s):
-- 			lpm_add_sub
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
-- ************************************************************


--Copyright (C) 1991-2003 Altera Corporation
--Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
--support information,  device programming or simulation file,  and any other
--associated  documentation or information  provided by  Altera  or a partner
--under  Altera's   Megafunction   Partnership   Program  may  be  used  only
--to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
--other  use  of such  megafunction  design,  netlist,  support  information,
--device programming or simulation file,  or any other  related documentation
--or information  is prohibited  for  any  other purpose,  including, but not
--limited to  modification,  reverse engineering,  de-compiling, or use  with
--any other  silicon devices,  unless such use is  explicitly  licensed under
--a separate agreement with  Altera  or a megafunction partner.  Title to the
--intellectual property,  including patents,  copyrights,  trademarks,  trade
--secrets,  or maskworks,  embodied in any such megafunction design, netlist,
--support  information,  device programming or simulation file,  or any other
--related documentation or information provided by  Altera  or a megafunction
--partner, remains with Altera, the megafunction partner, or their respective
--licensors. No other licenses, including any licenses needed under any third
--party's intellectual property, are provided herein.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY final_add IS
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (32 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (32 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		aclr		: IN STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (32 DOWNTO 0)
	);
END final_add;


ARCHITECTURE SYN OF final_add IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (32 DOWNTO 0);



	COMPONENT lpm_add_sub
	GENERIC (
		lpm_width		: NATURAL;
		lpm_direction		: STRING;
		lpm_type		: STRING;
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL
	);
	PORT (
			dataa	: IN STD_LOGIC_VECTOR (32 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (32 DOWNTO 0);
			aclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			result	: OUT STD_LOGIC_VECTOR (32 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	result    <= sub_wire0(32 DOWNTO 0);

	lpm_add_sub_component : lpm_add_sub
	GENERIC MAP (
		lpm_width => 33,
		lpm_direction => "ADD",
		lpm_type => "LPM_ADD_SUB",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1
	)
	PORT MAP (
		dataa => dataa,
		datab => datab,
		aclr => aclr,
		clock => clock,
		result => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: nBit NUMERIC "33"
-- Retrieval info: PRIVATE: Function NUMERIC "0"
-- Retrieval info: PRIVATE: WhichConstant NUMERIC "0"
-- Retrieval info: PRIVATE: ConstantA NUMERIC "0"
-- Retrieval info: PRIVATE: ConstantB NUMERIC "0"
-- Retrieval info: PRIVATE: ValidCtA NUMERIC "0"
-- Retrieval info: PRIVATE: ValidCtB NUMERIC "0"
-- Retrieval info: PRIVATE: CarryIn NUMERIC "0"
-- Retrieval info: PRIVATE: CarryOut NUMERIC "0"
-- Retrieval info: PRIVATE: Overflow NUMERIC "0"
-- Retrieval info: PRIVATE: Latency NUMERIC "1"
-- Retrieval info: PRIVATE: aclr NUMERIC "1"
-- Retrieval info: PRIVATE: clken NUMERIC "0"
-- Retrieval info: PRIVATE: LPM_PIPELINE NUMERIC "1"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "33"
-- Retrieval info: CONSTANT: LPM_DIRECTION STRING "ADD"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_ADD_SUB"
-- Retrieval info: CONSTANT: LPM_HINT STRING "ONE_INPUT_IS_CONSTANT=NO"
-- Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "1"
-- Retrieval info: USED_PORT: result 0 0 33 0 OUTPUT NODEFVAL result[32..0]
-- Retrieval info: USED_PORT: dataa 0 0 33 0 INPUT NODEFVAL dataa[32..0]
-- Retrieval info: USED_PORT: datab 0 0 33 0 INPUT NODEFVAL datab[32..0]
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT NODEFVAL aclr
-- Retrieval info: CONNECT: result 0 0 33 0 @result 0 0 33 0
-- Retrieval info: CONNECT: @dataa 0 0 33 0 dataa 0 0 33 0
-- Retrieval info: CONNECT: @datab 0 0 33 0 datab 0 0 33 0
-- Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
