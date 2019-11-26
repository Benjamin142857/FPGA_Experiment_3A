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
// file name	  	: $Workfile:   alt_avalon_mm_mem_master_to_wires.h  $
// version			: $Version:	1.0  $
// revision			: $Revision: #1 $
// designer name  	: $Author: swbranch $
// company name   	: altera corp.
// company address	: 101 innovation drive
//				 	  san jose, california 95134
//				 	  u.s.a.
//
/////////////////////////////////////////////////////////////////////////////////////////

//Simulation of Avalon Memory Master Interface
//Interface for the SystemC models of the cores, convert the 
//master channel into signals in DSPBuilder wires 

#ifndef _ALT_AVALON_MM_MEM_MASTER_TO_WIRES_
#define _ALT_AVALON_MM_MEM_MASTER_TO_WIRES_

#include "alt_avalon_sim_channel.h"

#include "alt_cusp.h"
#include "systemc.h"

//STL include
#include <list>

#define MEM_MASTER_SIMUL_WRITE_QUEUE_SIZE 128

//A simplified avalon_bus_matrix with limited capabilities.
//It does the strict necessary for a wire<->master_channel interface
template <int data_width>
class alt_avalon_dummy_master_bus_matrix : public alt_avalon_bus_matrix
{
	typedef ALT_FAST_INT_TYPES<data_width> fast_int_types;
private:
	sc_event _busEvent;

public:
	typedef typename fast_int_types::sint data_s;
	bool read_pending;
	bool read_received;
	unsigned int read_address;
	data_s read_data;
	std::list<unsigned int> write_addresses;
	std::list<data_s>  write_data;

	alt_avalon_dummy_master_bus_matrix(sc_module_name busName)
		: alt_avalon_bus_matrix(busName)
	{
		read_pending = false;
	}

	virtual void waitForChange()
	{
		sc_core::wait(_busEvent);
	}
	virtual void waitForChange(alt_avalon_mm_master_channel&, unsigned int)
	{
		waitForChange();
	}
	virtual void notifyChange()
	{
		sc_core::notify(_busEvent);
	}

	//Generic read/write functions operating on data_s
	void write(unsigned int address, const data_s data)
	{
		//Stall if write queue is full
		while (write_addresses.size() > MEM_MASTER_SIMUL_WRITE_QUEUE_SIZE)
			waitForChange();
		//When there is space, push address and data in the writing queues
		write_addresses.push_back(address);
		write_data.push_back(data);
	}
	data_s readNative(unsigned int address)
	{
		read_pending = true;
		read_received = false;
		read_address = address;
		//Wait until read_request is satisfied and read_data is set properly
		while (!read_received)
			waitForChange();
		return read_data;
	}
   
   //Read/write functions that have to be provided by an av_bus_matrix 
	virtual const sc_int_base read(alt_avalon_mm_master_channel& channel,
			unsigned int address)
	{
		return static_cast<sc_int<data_width> >(readNative(address));
	}
	virtual void write(alt_avalon_mm_master_channel& channel, unsigned int address,
			const sc_int_base& data)
	{
		data_s temp;
		temp = data; // Must use operator= to cast from sc_int_base to sc_bigint
		write(address, temp);
	}

	virtual const sc_signed readWide(alt_avalon_mm_master_channel& channel,
			unsigned int address)
	{
		return static_cast<const sc_bigint<data_width> >(readNative(address));
	}
	virtual void write(alt_avalon_mm_master_channel& channel, unsigned int address,
			const sc_signed& data)
	{
   		write(address, data);
	}

	//Virtual functions that are deactivated
	virtual void addSlave(alt_avalon_mm_mem_slave_channel&) {}
	virtual void addMaster(alt_avalon_mm_master_channel&) {}
	virtual void mapSlave(alt_avalon_mm_mem_slave_channel&,
					  unsigned int, unsigned int) {}
	virtual void mapSlave(alt_avalon_mm_mem_slave_channel&,
			alt_avalon_mm_master_channel&, unsigned int, unsigned int, int) {}
	virtual void setInterrupt(alt_avalon_mm_mem_slave_channel &slave, bool) {};
};

template <int data_width, int addr_width>
class alt_avalon_mm_mem_master_to_wires: public sc_module, public alt_avalon_sim_channel
{
	typedef ALT_FAST_INT_TYPES<data_width> fast_int_types;
private:
	alt_avalon_dummy_master_bus_matrix<data_width> _queue;
	alt_avalon_mm_master_channel _master;

public:
	typedef typename fast_int_types::sint data_s;
	//Clock
	sc_in_clk clock;

	//Reset wire, currently unused
	sc_in<bool> reset;

	//Input: functional simulation of Avalon MM Master
	alt_avalon_mm_master_channel& getInput(){
		return _master;
	}

	//Output: wire-level simulation of Avalon MM Master
	sc_in<bool> waitrequest;
	sc_out<sc_int<addr_width> > address;
	
	//unfortunately, SystemC does not allow yet for optional ports in 2.1, create dynamically
	//at construction
	sc_out<bool> *read;
	sc_in<bool> *readdatavalid;
	sc_in<data_s> *readdata;
	sc_out<bool> *write;
	sc_out<data_s> *writedata;
	
	//Constructor
	SC_HAS_PROCESS(alt_avalon_mm_mem_master_to_wires);
	alt_avalon_mm_mem_master_to_wires(sc_module_name name, bool read_ports, bool write_ports):
		sc_module(name),
		waitrequest("waitrequest"), address("address"), reset("reset"),
		_queue("dummy_master_bus"), _master(_queue)
	{
		if (read_ports)
		{
			read = new sc_out<bool>("read");
			readdatavalid = new sc_in<bool>("readdatavalid");
			readdata = new sc_in<data_s>("readdata");
		}
		else
		{
			read = NULL;
			readdatavalid = NULL;
			readdata = NULL;
		}		
		if (write_ports)
		{
			write = new sc_out<bool>("write");
			writedata = new sc_out<data_s>("writedata");
		}
		else
		{
			write = NULL;
			writedata = NULL;
		}
		//Behaviour model is run once each clock posedge event
		SC_CTHREAD(behaviour, clock.pos());
	}
	
	virtual ~alt_avalon_mm_mem_master_to_wires()
	{
	}

	//Convert wire-level simulation to functional simulation
	void behaviour()
	{
		if (read) read->write(false);
		if (write) write->write(false);
		for (;;)
		{
			if (waitrequest.read())
			{
				//Maitain input if waitrequest is pulled high
			}
			else
			{
				//default is no read or write at this cycle but this can be overwriten below
				if (read) read->write(false);
				if (write) write->write(false);
				if (write && _queue.write_addresses.size() > 0)
				{
					address.write(_queue.write_addresses.front());
					writedata->write(_queue.write_data.front());
					_queue.write_data.pop_front();
					_queue.write_addresses.pop_front();
					write->write(true);
					//Wake up bus if waiting on writing queue full
					_queue.notifyChange();
				}
				else if (read && _queue.read_pending){
					address.write(_queue.read_address);
					_queue.read_pending = false;
					read->write(true);
				}
			}
			//Process incoming data if readdatavalid is true,
			//whatever the wait_request status
			if (read && readdatavalid->read())
			{
				_queue.read_data = readdata->read();
				_queue.read_received = true;
				//Wake up bus waiting on read
				_queue.notifyChange();
			}
			wait();
		}
	}
};

#endif //alt_avalon_mm_mem_master_to_wires
