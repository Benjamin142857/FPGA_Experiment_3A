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
// file name	  	: $Workfile:   simgen_interface.cpp  $
// version			: $Version:	1.0  $
// revision			: $Revision: #1 $
// designer name  	: $Author: swbranch $
// company name   	: altera corp.
// company address	: 101 innovation drive
//				 	  san jose, california 95134
//				 	  u.s.a.
//
/////////////////////////////////////////////////////////////////////////////////////////

/*
 *  Defines the core-invariant interface of the functional simulation DLL
 */

#include "alt_cusp.h"
#include "systemc.h"

#ifndef DLL_INTERFACE_FUNCTION
	#define DLL_INTERFACE_FUNCTION __attribute__((dllexport))
#endif

/*
 * systemC has to be initialised once (and only once)
 * for each simulation, the static variable
 * alt_dspbuilder_simgen_sysc_inited and the two
 * following functions, shared by all the cores,
 * take care of that
 */
int alt_dspbuilder_simgen_sysc_inited = 0;

extern "C" DLL_INTERFACE_FUNCTION
void init_sysc_simulation()
{
	if (alt_dspbuilder_simgen_sysc_inited == 0)
	{
		//Start up SystemC
		sc_elab_and_sim(0, NULL);
	}
	++alt_dspbuilder_simgen_sysc_inited;
}

extern "C" DLL_INTERFACE_FUNCTION
void terminate_sysc_simulation()
{
	--alt_dspbuilder_simgen_sysc_inited;
	if (alt_dspbuilder_simgen_sysc_inited == 0)
	{
		//Stop SystemC
		sc_stop();
	}
}
//sc_main is compulsory (and called by sc_elab_and_sim I believe)
int sc_main(int argc, char *argv[])
{
	return 0;
}
