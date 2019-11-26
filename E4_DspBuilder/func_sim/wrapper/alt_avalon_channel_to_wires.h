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
// file name	  	: $Workfile:   alt_avalon_channel_to_wires.h  $
// version			: $Version:	1.0  $
// revision			: $Revision: #1 $
// designer name  	: $Author: swbranch $
// company name   	: altera corp.
// company address	: 101 innovation drive
//				 	  san jose, california 95134
//				 	  u.s.a.
//
/////////////////////////////////////////////////////////////////////////////////////////

//Simulation of Avalon Streaming output wires.
//Interface for the SystemC models of the cores, convert the 
//ALT_AVALON_ST_OUTPUT<DataType> channel into signals in DSPBuilder wires 
//The ready-latency of the channel can be 0 or 1
//Warning: do not use sc_fix or sc_ufix as template parameter

#ifndef _ALT_AVALON_CHANNEL_TO_WIRES_
#define _ALT_AVALON_CHANNEL_TO_WIRES_

#include "alt_avalon_sim_channel.h"

#include "alt_cusp.h"
#include "systemc.h"

#include <vector>

template <typename DataType>
class alt_avalon_channel_to_wires_base: public alt_avalon_sim_channel
{
public:
	sc_out<DataType> data;
	
	alt_avalon_channel_to_wires_base(unsigned int dummy): data("data")
	{
	}

	virtual ~alt_avalon_channel_to_wires_base()
	{
	}
	
	void cast_data_to_wire(const DataType& data_to_push)
	{
		data.write(data_to_push);
	}
};

//a specialization for avalon_st_input composed of multiple bus
template <typename DataType>
class alt_avalon_channel_to_wires_base<std::vector<DataType> >: public alt_avalon_sim_channel
{
private:
	unsigned int _number_of_ports;

public:
	sc_out<DataType> *data;

	alt_avalon_channel_to_wires_base(unsigned int number_of_ports):
				_number_of_ports(number_of_ports)
	{
		data = new sc_out<DataType>[_number_of_ports];
	}

	virtual ~alt_avalon_channel_to_wires_base()
	{
		delete [] data;
	}

	void cast_data_to_wire(const std::vector<DataType>& data_to_push)
	{
		assert(data_to_push.size() == _number_of_ports);
		for (unsigned int i = 0; i < _number_of_ports; ++i)
		{
		    data[i].write(data_to_push[i]);
		}
	}
};

template <typename DataType>
class alt_avalon_channel_to_wires: public sc_module, //cannot use SC_MODULE because of inheritance
                                   public alt_avalon_channel_to_wires_base<DataType>
{
private:
	alt_avalon_st_point_to_point_channel<DataType> *dout;
	
public:
	//The clock
	sc_in_clk clock;

	//Reset wire, currently unused
	sc_in<bool> reset;

	//Input: functional simulation of Avalon Streaming
	ALT_AVALON_ST_INPUT<DataType> channel;

	//Output: wire-level simulation of Avalon Streaming
	//the data line(s) is/are handled by the base class
	sc_in<bool> ready;
	sc_out<bool> valid;
	sc_out<bool> startofpacket;
	sc_out<bool> endofpacket;
	
	int ready_latency;
	
	//Constructor
	SC_HAS_PROCESS(alt_avalon_channel_to_wires);
	alt_avalon_channel_to_wires(sc_module_name name, int ready_lat,
								unsigned int number_of_ports = 1):
		sc_module(name),
		alt_avalon_channel_to_wires_base<DataType>(number_of_ports),
		ready("ready"), valid("valid"),
		reset("reset"), startofpacket("startofpacket"),
		endofpacket("endofpacket"),
		ready_latency(ready_lat)
	{
		//Set up a functional channel to bind with the ST_OUTPUT of the core
		std::string tmp = std::string(name) + "_ptp_channel";
		dout = new alt_avalon_st_point_to_point_channel<DataType>(tmp.c_str());
		//bind the output of this channel to the queue of channel_to_wire			 
		channel(dout->getOutput());
		
		if ((ready_latency == 0) || (ready_latency == 1))
		{
			//Behaviour model is run once each clock posedge event
			SC_CTHREAD(behaviour, clock.pos());
		}
	}

	alt_avalon_st_output_channel<DataType> &getInput()
	{
		return dout->getInput();
	}
	
	virtual ~alt_avalon_channel_to_wires()
	{
		delete dout;
	}

	//Convert functional simulation (channel) to wire-level simulation.
	//Note that a call to read() refers to the status of a signal BEFORE
	//the clock goes high.
	void behaviour()
	{
		bool start_of_packet_expected = false;
		bool is_valid = false;
		startofpacket.write(true);
		//Ready latency 0: transactions are valid if ready and valid are high simultaneously
		if (ready_latency == 0)
		{
			//Reset conditions:
			DataType data_to_push;
			bool is_data_to_push = false;
			for(;;)
			{
				//Conclude transaction from the last cycle, and check whether data was
				//received.
				if (is_data_to_push && ready.read())
				{
					//Previous piece of data was recieved, get ready for the next one
					is_data_to_push = false;
				}
				
				//Try to read the next item off the channel unless a previous
				//item was not successfully transferred 
				if (channel.hasDataAvail() && !is_data_to_push)
				{
					data_to_push = channel.read();
					is_data_to_push = true;
				}

				//If there is a piece of data that needs to be sent (either because
				//we just read it at this cycle or because it was read from a previous
				//cycle but was not sent successfully before), then put the data
				//into the wires...one has to wait the next clock cycle to check whether it
				//was received				  
				if (is_data_to_push)
				{
					valid.write(true);
					cast_data_to_wire(data_to_push);
					
					if (start_of_packet_expected)
					{
						startofpacket.write(true);
						start_of_packet_expected = false;
					}
					else
					{
						startofpacket.write(false);
					}
				}				
				else
				{
					//No data to send
					valid.write(false);
				}
				
				if (channel.getEndPacket())
				{
					endofpacket.write(true);
					start_of_packet_expected = true;
				}
				else
				{
					endofpacket.write(false);
				}


				//Wait for next cycle
				wait();
			}  		
		}
		//Ready latency 1: receiving block warns that it will be ready on the previous
		//clock cycle. The sender cannot set valid high if the receiving block has
		//announced it will not receive data.  
		else if (ready_latency == 1)
		{
			//Assert valid false for the first cycle
			valid.write(false);
			start_of_packet_expected = true;
			wait();

			for(;;)
			{
				//If there's data waiting on the channel and the receiver is ready
				//then send
				if (ready.read() && channel.hasDataAvail())
				{
					cast_data_to_wire(channel.read());
					valid.write(true);
					startofpacket.write(start_of_packet_expected);
					endofpacket.write(channel.getEndPacket());
					start_of_packet_expected = channel.getEndPacket();
				}
				else
				{
					valid.write(false);
				}
				
				//Wait for next clock tick
				wait();
			}
		}
	}
};

#endif //alt_avalon_channel_to_wires

