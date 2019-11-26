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
// file name	  	: $Workfile:   alt_avalon_wires_to_channel.h  $
// version			: $Version:	1.0  $
// revision			: $Revision: #1 $
// designer name  	: $Author: swbranch $
// company name   	: altera corp.
// company address	: 101 innovation drive
//				 	  san jose, california 95134
//				 	  u.s.a.
//
/////////////////////////////////////////////////////////////////////////////////////////

//Simulation of Avalon Streaming input wires.
//Interface for the SystemC models of the cores, convert the 
//signals in DSPBuilder wires into an ALT_AVALON_ST_INPUT<DataType> channel 
//The ready-latency can be either 0 or 1
//Warning: do not use sc_fix or sc_ufix as template parameter

#ifndef _ALT_AVALON_WIRES_TO_CHANNEL_
#define _ALT_AVALON_WIRES_TO_CHANNEL_

#include "alt_avalon_sim_channel.h"

#include "alt_cusp.h"
#include "systemc.h"

#include <vector>

template <typename DataType>
class alt_avalon_wires_to_channel_base: public alt_avalon_sim_channel
{
public:
	sc_in<DataType> data;
	
	alt_avalon_wires_to_channel_base(unsigned int dummy): data("data")
	{
	}
	
	virtual ~alt_avalon_wires_to_channel_base()
	{
	}
	
	void cast_wires_to_data(DataType &data_to_push)
	{
		data_to_push = data.read();
	}
};

//a specialization for avalon_st_input composed of multiple bus
template <typename DataType>
class alt_avalon_wires_to_channel_base<std::vector<DataType> >: public alt_avalon_sim_channel
{
private:
	unsigned int _number_of_ports;
	
public:
	sc_in<DataType> *data;
	
	alt_avalon_wires_to_channel_base(unsigned int number_of_ports):
			_number_of_ports(number_of_ports)
	{
		data = new sc_in<DataType>[number_of_ports];
	}

	virtual ~alt_avalon_wires_to_channel_base()
	{
		delete [] data;
	}

	void cast_wires_to_data(std::vector<DataType>& data_to_push)
	{
		data_to_push.resize(_number_of_ports);
		for (unsigned int i = 0; i < _number_of_ports; ++i)
		{
		    data_to_push[i] = data[i].read();
		}
	}
};

template <typename DataType>
class alt_avalon_wires_to_channel: public sc_module, //cannot use SC_MODULE because of inheritance
                                   public alt_avalon_wires_to_channel_base<DataType>
{
private:
	alt_avalon_st_point_to_point_channel<DataType> *din;	
	
public:
	//The clock
	sc_in_clk clock;

	//Reset wire, currently unused
	sc_in<bool> reset;

	// Input: wire-level simulation of Avalon Streaming
	sc_out<bool> ready;
	sc_in<bool> valid;
	sc_in<bool> startofpacket;
	sc_in<bool> endofpacket;

	// Output: functional simulation of Avalon Streaming
	ALT_AVALON_ST_OUTPUT<DataType> channel;

	int ready_latency;
	
	// Constructor
	SC_HAS_PROCESS(alt_avalon_wires_to_channel);
	alt_avalon_wires_to_channel(sc_module_name name, int ready_lat,
								unsigned int number_of_ports = 1):
		sc_module(name),
		alt_avalon_wires_to_channel_base<DataType>(number_of_ports),
		ready("ready"), valid("valid"), 
		reset("reset"), startofpacket("startofpacket"),
		endofpacket("endofpacket"), ready_latency(ready_lat)
	{		
		//Set up a functional channel to bind with the ST_INPUT of the core
		std::string tmp = std::string(name) + "_ptp_channel";
		din = new alt_avalon_st_point_to_point_channel<DataType>(tmp.c_str());
		//bind the queue of wire-to-channel to the input of the func. channel 
		channel(din->getInput());

		if ((ready_latency == 0) || (ready_latency == 1))
		{
			// Behaviour model is run once each clock posedge event
			SC_CTHREAD(behaviour, clock.pos());
		}
	}
	
	alt_avalon_st_input_channel<DataType> &getOutput()
	{
		return din->getOutput();
	}
	
	virtual ~alt_avalon_wires_to_channel()
	{
		delete din;
	}

	// Convert wire-level simulation into functional simulation (a channel)
	// Note that a call to read() refers to the status of a signal BEFORE
	// the clock goes high.
	void behaviour()
	{
		//ready latency 0: transactions are recorded if ready and valid are
		//high simultaneously
		if (ready_latency == 0)
		{
			DataType data_to_push;
			for(;;)
			{			
				//If there is space on the channel, assert ready high for the next cycle.
				if (channel.hasSpaceAvail())
				{
					ready.write(true);
					wait();
					//after the clock tick, get data from the wires if valid is high
					if (valid.read())
					{
						cast_wires_to_data(data_to_push);
						channel.write(data_to_push);
					}
					bool eop = endofpacket.read();
					channel.setEndPacket(eop);
				}
				//Otherwise, if the channel is full, assert ready low
				else
				{
					ready.write(false);
					wait();
					//valid and data are ignored since ready was asserted low
				}
			}
		}
		//Ready latency 1: receiving block warns that it will be ready on the previous
		//clock cycle. The sender cannot set valid high if the receiving block has
		//announced it will not receive data.  
		else if (ready_latency == 1)
		{
			//Reset conditions, data_to_push act as a temporary storage space
			DataType data_to_push;
			bool is_data_to_push = false;
            bool is_data_eop;

			//Assert ready high immediately, so that data can be transfered in the
			//next clock cycle. 
			ready.write(true);

			wait();

			for(;;)
			{
				//Pull data off the wire and overwrite storage space if valid is true
				//Note: the behaviour when data is sent but not requested is supposed to 
				//be undefined.
				if (valid.read())
				{
					is_data_to_push = true;
					cast_wires_to_data(data_to_push);
					is_data_eop = endofpacket.read();
				}

				// Push data onto the channel if possible
				if (is_data_to_push && channel.hasSpaceAvail())
				{
					channel.writeDataAndEop(data_to_push, is_data_eop); // Cannot block
					is_data_to_push = false;
				}

				//If still space on the queue, assert ready high
				//(because there is also space on the storage and we can 
				//consequently receive data for at least two cycles).
				if (channel.hasSpaceAvail())
				{
					ready.write(true);
				}
				//Otherwise, assert ready low. We must still be able to handle
				//one more cycle of possible incoming data because of the ready latency
				//but data_to_push should be free
				else
				{
					ready.write(false);
				}
					
				// Each subsequent cycle:
				wait();
			}
		}
	}
};

#endif // _alt_avalon_wires_to_channel_
