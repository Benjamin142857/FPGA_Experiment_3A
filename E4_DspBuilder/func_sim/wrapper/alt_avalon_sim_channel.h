/////////////////////////////////////////////////////////////////////////////////////////
// Legal Notice: © 2007 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other software 
// and tools, and its AMPP partner logic functions, and any output files any of the 
// foregoing (including device programming or simulation files), and any associated 
// documentation or information are expressly subject to the terms and conditions of 
// the Altera Program License Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, without limitation, that 
// your use is for the sole purpose of programming logic devices manufactured by Altera 
// and sold by Altera or its authorized distributors. Please refer to the applicable 
// agreement for further details. 
/////////////////////////////////////////////////////////////////////////////////////////
//
// file name	  	: $Workfile:   alt_avalon_sim_channel.h  $
// version			: $Version:	1.0  $
// revision			: $Revision: #1 $
// designer name  	: $Author: swbranch $
// company name   	: altera corp.
// company address	: 101 innovation drive
//				 	  san jose, california 95134
//				 	  u.s.a.
//
/////////////////////////////////////////////////////////////////////////////////////////
	
/**************************************************************************************
 * @class alt_avalon_sim_channel
 * 
 * An interface for all simulation channel used in fast functional simulation
 * Provide a virtual destructor for easy destruction of the instantiated channels
 */

#ifndef _ALT_AVALON_SIM_CHANNEL_
#define _ALT_AVALON_SIM_CHANNEL_
 
class alt_avalon_sim_channel
{
public:
	virtual ~alt_avalon_sim_channel(){};
};

#endif
