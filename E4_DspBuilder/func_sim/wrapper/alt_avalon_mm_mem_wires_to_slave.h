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
// file name	  	: $Workfile:   alt_avalon_mm_mem_wires_to_slave.h  $
// version			: $Version:	1.0  $
// revision			: $Revision: #1 $
// designer name  	: $Author: swbranch $
// company name   	: altera corp.
// company address	: 101 innovation drive
//				 	  san jose, california 95134
//				 	  u.s.a.
//
/////////////////////////////////////////////////////////////////////////////////////////

//Simulation of Avalon Memory Slave Interface
//Interface for the SystemC models of the cores, convert the 
//signals from the DSPBuilder wires into the slave channel 

#ifndef _ALT_AVALON_MM_MEM_WIRES_TO_SLAVE_
#define _ALT_AVALON_MM_MEM_WIRES_TO_SLAVE_

#include "alt_avalon_sim_channel.h"

#include "alt_cusp.h"
#include "systemc.h"

template <int data_width, int depth>
class alt_avalon_mm_mem_wires_to_slave: public sc_module, public alt_avalon_sim_channel
{
private:
	alt_avalon_bfm _dummy_bus;
	alt_avalon_mm_mem_slave_channel _slave;
	int shiftwidth;

public:
	//Clock
	sc_in_clk clock;

	//Reset wire, currently unused
	sc_in<bool> reset;

	//Input: wire-level simulation of Avalon MM Slave
	sc_in<bool> chipselect;
	sc_in<sc_uint<ALT_UTIL::LOG2CEIL<depth>::value> > address;
	sc_out<sc_int<data_width> > readdata;
	sc_in<bool> write;
	sc_in<sc_int<data_width> > writedata;
	
	//Constructor
	SC_CTOR(alt_avalon_mm_mem_wires_to_slave)
		:   chipselect("chipselect"), address("address"), write("write"),
			readdata("readdata"), writedata("writedata"), reset("reset"),
			_dummy_bus("dummy_slave_bus"), _slave(_dummy_bus)
	{
		//Determine number of bytes to shift address by
		for (shiftwidth = 0; 8 * (1 << shiftwidth) < data_width; shiftwidth++) {};

		//Behaviour model is run once each clock posedge event
		SC_CTHREAD(behaviour, clock.pos());
	}

	virtual ~alt_avalon_mm_mem_wires_to_slave()
	{
	}

	void bind_port(alt_avalon_mm_mem_slave_port& port, const std::string& port_name)
	{
		_slave.register_port(port, port_name.c_str());
		port.bind(_slave);
	}
	
	//Convert wire-level simulation to functional simulation
	void behaviour()
	{
		for (;;)
		{
			//Ignore all signals unless chipselect is asserted
			if (chipselect.read())
			{
				unsigned int _address = address.read();
				//Shift address to compensate for ALT_AVALON_MM_MEM_SLAVE
				_address = _address << shiftwidth;
				//Input data if write asserted
				if (write.read())
				{
					sc_int<data_width> _writedata = writedata.read();
					_slave.acceptBusWrite(_address, _writedata);
				}
				//Always output read
				_slave.acceptBusRead(_address);
				sc_int<data_width> _readdata = _slave.acceptBusRead(_address);
				readdata.write(_readdata);
			}
			wait();
		}
	}
};

#endif
