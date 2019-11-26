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
// file name	  	: $Workfile:   core_wrapper.h  $
// version			: $Version:	1.0  $
// revision			: $Revision: #1 $
// designer name  	: $Author: swbranch $
// company name   	: altera corp.
// company address	: 101 innovation drive
//				 	  san jose, california 95134
//				 	  u.s.a.
//
/////////////////////////////////////////////////////////////////////////////////////////

//Wrapper for the SystemC model of various megacores.
//The wrapper plug the wires to the avalon interfaces of the core
//respecting the exchange protocols.
//Currently provides wrapper for the following CusP models:
// * Avalon Streaming source (Ready-Latency 0 & 1)
// * Avalon Streaming sink (Ready-Latency 0 & 1)
// * Avalon MM Slave
// * Avalon MM Master

#ifndef _COREWRAPPER_H_
#define _COREWRAPPER_H_

#include "alt_avalon_sim_channel.h"
#include "alt_avalon_wires_to_channel.h"
#include "alt_avalon_channel_to_wires.h"
#include "alt_avalon_mm_mem_wires_to_slave.h"
#include "alt_avalon_mm_mem_master_to_wires.h"

#include "alt_cusp.h"
#include "systemc.h"

//STL includes
#include <string>
#include <map>

namespace ALT_CUSP_SYNTH
{
	// Deprecated constructor only method which gets numbers out of XML strings
	// Placeholder definition on C++ side (in 8.0, this is for generation only and should 
	// never be called during the simulation step if its value would change the 
	// simulation behaviour, so returning an arbitrary value is sufficient.)
	int extract_from_xml(char const* xml, char const* pattern, int defvalue) { return 0; };
} 

/* All the definition in this file are in a namespace since each .o files (one for each core
 * in a design) will contain them. This is rather inefficient and can probably be improved */
 
namespace{

	/**************************************************************************************
	 * @class writable_wire
	 * 
	 * An interface.
	 * Provide a method to update the value of the wire
	 */
	class writeable_wire {
	public:
		virtual void setValue(const sc_dt::sc_fix& value) = 0;
		virtual void setValue(const sc_dt::sc_ufix& value) = 0;
		virtual ~writeable_wire() {}
	};
	/**************************************************************************************
	 * @class readable_wire
	 * 
	 * An interface.
	 * Provide a method to return the value of the wire
	 */
	class readable_wire {
	public:
		virtual void getValue(sc_dt::sc_fix& value) = 0;
		virtual void getValue(sc_dt::sc_ufix& value) = 0;
		virtual ~readable_wire() {}
	};
	
	/**************************************************************************************
	 * @class dangling_wire
	 *
	 * Stubs an unused port
	 */
	class dangling_wire : public writeable_wire, public readable_wire
	{
		virtual void setValue(const sc_dt::sc_fix& value) { }
		virtual void setValue(const sc_dt::sc_ufix& value) { }
		virtual void getValue(sc_dt::sc_fix& value) { }
		virtual void getValue(sc_dt::sc_ufix& value) { }
	};
	
	/**************************************************************************************
	 * @class wire
	 *
	 * Maps the sc_signal<T> of a given port to the value
	 * of the corresponding wire
	 */
	template <typename T>
	class wire : public writeable_wire, public readable_wire
	{
	private:
		//A signal created for each wire object
		sc_signal<T> signalT;
		//The name of this wire and of its corresponding sc_signal<T>
		std::string wire_name;
	
	public:
		/**************************************************************************************
		 * wire: constructor
		 *
		 * @params	  name - name for the object and its signal
		 */
		wire(const char* name): wire_name(name){}

		/**************************************************************************************
		 * wire: destructor
		 */
		virtual ~wire(){}
	
		/**************************************************************************************
		 * wire: getSignalRef
		 *
		 * @return	a reference to the internal sc_signal that can
		 *			be binded to a port of the core 
		 */
		sc_signal<T>& getSignalRef(){
			return signalT;
		}

		/**************************************************************************************
		 * wire: setValue
		 *
		 * The pure virtual function from the interface writeable_wire
		 * Change the value carried by the wire by updating the sc_signal<T>
		 * The DSPB type is converted into the type of the signal here
		 * 
		 * @param	 a new value 
		 */
		virtual void setValue(const sc_dt::sc_fix& value) {
			signalT = static_cast<T>(value);
		}
		virtual void setValue(const sc_dt::sc_ufix& value) {
			signalT = static_cast<T>(value);
		}

		/**************************************************************************************
		 * wire: getValue
		 *
		 * The pure virtual function from the interface readable_wire.
		 * Read the value carried by the wire by converting the sc_signal<T>
		 * back into a DSPB type.
		 * 
		 * @param	value - a DSPB_Megacore_Type properly initialized
		 *				   (eg, with the right bit width)
		 *		 
		 */
		virtual void getValue(sc_dt::sc_ufix& value) {
			value = static_cast<T>(signalT);
		}
		virtual void getValue(sc_dt::sc_fix& value) {
			value = static_cast<T>(signalT);
		}
	};

	/**************************************************************************************
	 * @class CoreWrapper
	 *
	 * Provide some useful functions for the hooks of the DLL.
	 * Convert the values carried by the wires
	 * into proper sc_signal<T>. Bundle set of related wires
	 * into relevant Avalon interfaces that are bound to the cores.
	 */
	class CoreWrapper {

	private:
		//clock wires are not handled by Simulink (although update
		//is called every clock cycle) and VIP blocks ignore the reset
		//wire. Consequently, the core wrapper takes control of these two
		//signals. 
		sc_signal<bool> wrapper_core_clk;
		sc_signal<bool> wrapper_rst;

		std::vector<writeable_wire*> inputs;
		std::vector<readable_wire*> outputs;
		
		std::map<std::string, unsigned int> input_port_mapping;
		std::map<std::string, unsigned int> output_port_mapping;

		//a pointer to the core (untyped since the actual core type is determined later in the .cpp file)
		void *core;

		//keep record of the channels created in order to delete them later on
		std::vector<alt_avalon_sim_channel*> channels;
		

	public:
		/* 
		 * CoreWrapper: constructor
		 * 
		 * Link the wires to the core signals and channels.
		 */
		CoreWrapper();

		/* 
		 * CoreWrapper: destructor
		 * 
		 * Tidy up
		 */ 
		~CoreWrapper();

		/* 
		 * CoreWrapper: read_value
		 * 
		 * Read the signal carried by the specified wire
		 * 
		 * @param[in]   output_id  - the id of the wire (corresponds to the order
		 *						   in which output wires are mapped) and should
		 *						   match the Megacore block order.
		 * @param[out]  value	  - the requested value (value should have been
		 *						   properly initialized with correct bitwidth).
		 */
		template<typename DSPB_TYPE>
		void read_value(unsigned int outputwire_id, DSPB_TYPE& value)
		{
			assert(outputwire_id<outputs.size());
			outputs[outputwire_id]->getValue(value);
		}

		/* 
		 * CoreWrapper: write_value
		 * 
		 * Update the signal carried by the specified wire 
		 * 
		 * @param[in]   input_id  - the id of the wire (corresponds to the order
		 *						   in which input wires are mapped) and should
		 *						   match the Megacore block order.
		 * @param[out]  value	 - the new value (should be compatible with the
		 *						  type of the signal.
		 */
		template<typename DSPB_TYPE>
		void write_value(unsigned int inputwire_id, const DSPB_TYPE& value)
		{
			assert(inputwire_id<inputs.size());
			inputs[inputwire_id]->setValue(value);
		}

		/* 
		 * CoreWrapper: add_XXX_mapping
		 * 
		 * a convenient set of functions used to declare ports names and reserve
		 * some space for them in the array of inputs and outputs wire.
		 * This should disappear with EntityInterface
		 * 
		 * @param[in]   a name or a common prefix for the wire(s)
		 */
		//add "name" to the list of declared input ports and create some space for its
		//associated wire at the end of "inputs"
		void add_input_port_mapping(const std::string &name);
		//add "name" to the list of declared output ports and create some space for its
		//associated wire at the end of "output"
		void add_output_port_mapping(const std::string &name);
		//add the names of the 3 ports of an av_st input to the list of
		//declared input and output ports and create some space for them in
		//"inputs" and "outputs"
		void add_av_st_input_port_mapping(const std::string &base_name);
		//add the names of the 3 ports of an av_st output to the list of
		//declared input and output ports and create some space for them in
		//"inputs" and "outputs"
		void add_av_st_output_port_mapping(const std::string &base_name);
		//same but for all the ports of an av_mem_slave interface 
		void add_av_mem_slave_port_mapping(const std::string &base_name);
		//same but for all the ports of an av_mem_master interface
		//one can select not to use the "read_ports" or not to use the "write_ports"
		void add_av_mem_master_port_mapping(const std::string &base_name,
		                             bool read_ports = true, bool write_ports = true);

		/* 
		 * CoreWrapper: inputs_changed_event
		 * 
		 * Event sent by DSPBuilder when the signal of a wire has changed.
		 * It triggers delta cycles to propagate the change(s) through the core
		 */
		void inputs_changed_event();

		/* 
		 * CoreWrapper: inputs_changed_event
		 * 
		 * Event sent by DSPBuilder at each clock tick.
		 * It triggers delta cycles and update the clock signal to propagate
		 * the clock negedge and posedge through the core
		 */
		void clock_event();

		/* 
		 * CoreWrapper: input_place_holder/output_place_holder
		 * 
		 * Create empty wires and signals for the wires that are not used
		 * by the functional model of the core but are still referenced by
		 * DSPBuilder  
		 * 
		 * @param[in]  name   - the name for the wire and its signal
		 */
		void input_place_holder(const std::string& name)
		{
			if (inputs[input_port_mapping.find(name)->second])
				delete inputs[input_port_mapping.find(name)->second];
			inputs[input_port_mapping.find(name)->second] = new dangling_wire();
		}
		void output_place_holder(const std::string& name)
		{
			if (outputs[output_port_mapping.find(name)->second])
				delete outputs[output_port_mapping.find(name)->second];
			outputs[output_port_mapping.find(name)->second] = new dangling_wire();
		}

		/* 
		 * CoreWrapper: wire_port
		 * 
		 * Create wires and their corresponding signal and bind them to
		 * the given port.
		 * 
		 * @param[in]  input/output port - the port used to bind the new signal
		 * @param[in]  name			  - the name for the wire and its signal
		 */
		template <typename T>
		void wire_port(sc_in<T>& input_port, const std::string& name)
		{
			if (inputs[input_port_mapping.find(name)->second])
				delete inputs[input_port_mapping.find(name)->second];
			wire<T>* ws = new wire<T>(name.c_str());
			input_port(ws->getSignalRef());
			inputs[input_port_mapping.find(name)->second] = ws;
		}
		template <typename T>
		void wire_port(sc_out<T>& output_port, const std::string& name)
		{
			if (outputs[output_port_mapping.find(name)->second])
				delete outputs[output_port_mapping.find(name)->second];
			wire<T>* ws = new wire<T>(name.c_str());
			output_port(ws->getSignalRef());
			outputs[output_port_mapping.find(name)->second] = ws;
		}
		
		/* 
		 * CoreWrapper: wire_clock
		 * 
		 * Bind the clock to the given port.
		 * (currently no provision for multiple clocks)
		 * 
		 * @param[in]  input port - the port to be bound to the clock
		 */
		void wire_clock(sc_in<bool>& input_port)
		{
			input_port(wrapper_core_clk);
		}

		/* 
		 * CoreWrapper: wire_channel
		 * 
		 * Create wires and their corresponding signals and create an interface
		 * to connect them to the given avalon interface.
		 * 
		 * @param[in]  channel			- the avalon interface to connect to the wires
		 * @param[in]  channel_name		- the name of this interface
		 * @param[in]  ready latency	- for avalon streaming channels, can be 0 or 1
		 */
		// Wire up an Avalon Streaming input port (old style)
		template <typename DataType>
		void wire_channel(ALT_AVALON_ST_INPUT<DataType>& channel_input,
			const std::string& channel_name, int ready_latency)
		{
			//Set up the convertor wires<->avalon_interface
			alt_avalon_wires_to_channel<DataType>* wtc =
				new alt_avalon_wires_to_channel<DataType>(channel_name.c_str(), ready_latency);
			channels.push_back(wtc);	
					
			//bind the output of the func. channel to AVALON_ST_INPUT 
			channel_input(wtc->getOutput());

			wtc->clock(wrapper_core_clk);
			wtc->reset(wrapper_rst);
		
			//bind the three wires to the functional channel
			wire_port(wtc->data, channel_name + "_data");
			wire_port(wtc->ready, channel_name + "_ready"); //this is an output
			wire_port(wtc->valid, channel_name + "_valid");
			wire_port(wtc->startofpacket, channel_name + "_startofpacket");
			wire_port(wtc->endofpacket, channel_name + "_endofpacket");
		}
		
		// Wire up an Avalon Streaming input port (new style)
		struct default_av_st_in_params
		{
			static const bool has_port_data = false;
			const std::string port_data;
			static const bool has_port_ready = false;
			const std::string port_ready;
			static const bool has_port_valid = false;
			const std::string port_valid;
			static const bool has_port_startofpacket = false;
			const std::string port_startofpacket;
			static const bool has_port_endofpacket = false;
			const std::string port_endofpacket;
			default_av_st_in_params() {}
		};
		template <typename DataType, typename ParamGen>
		void wire_channel(ALT_AVALON_ST_INPUT<DataType>& channel, const ParamGen&)
		{
			typename ParamGen::template params<default_av_st_in_params> params;
			
			//Set up the convertor wires<->avalon_interface
			alt_avalon_wires_to_channel<DataType>* wtc =
				new alt_avalon_wires_to_channel<DataType>(params.pointName.c_str(), params.param_readyLatency);
			channels.push_back(wtc);	
					
			//bind the output of the func. channel to AVALON_ST_INPUT 
			channel(wtc->getOutput());

			wtc->clock(wrapper_core_clk);
			wtc->reset(wrapper_rst);
		
			//bind the three wires to the functional channel
			if (params.has_port_ready)
				wire_port(wtc->ready, params.port_ready);
			if (params.has_port_valid)
				wire_port(wtc->valid, params.port_valid);
			if (params.has_port_data)
				wire_port(wtc->data, params.port_data);
			if (params.has_port_startofpacket)
				wire_port(wtc->startofpacket, params.port_startofpacket);
			if (params.has_port_endofpacket)
				wire_port(wtc->endofpacket, params.port_endofpacket);
		}

		// Wire up an Avalon Streaming output port (old style)
		template <typename DataType>
		void wire_channel(ALT_AVALON_ST_OUTPUT<DataType>& channel_output,
				const std::string& channel_name, int ready_latency)
		{
			//Set up the convertor avalon_interface<->wires
			alt_avalon_channel_to_wires<DataType>* ctw =
				new alt_avalon_channel_to_wires<DataType>(channel_name.c_str(), ready_latency);
			channels.push_back(ctw);
						
			//bind the output of the core to the queue of channel_to_wire			 
			channel_output(ctw->getInput());

			ctw->clock(wrapper_core_clk);
			ctw->reset(wrapper_rst);
		
			//bind the three wires to the functional channel
			wire_port(ctw->data, channel_name + "_data");
			wire_port(ctw->ready, channel_name + "_ready"); //this is an input
			wire_port(ctw->valid, channel_name + "_valid");
			wire_port(ctw->startofpacket, channel_name + "_startofpacket");
			wire_port(ctw->endofpacket, channel_name + "_endofpacket");
		}
		
		// Wire up an Avalon Streaming output port (new style)
		struct default_av_st_out_params
		{
			static const bool has_port_data = false;
			const std::string port_data;
			static const bool has_port_ready = false;
			const std::string port_ready;
			static const bool has_port_valid = false;
			const std::string port_valid;
			static const bool has_port_startofpacket = false;
			const std::string port_startofpacket;
			static const bool has_port_endofpacket = false;
			const std::string port_endofpacket;
			default_av_st_out_params() { }
		};
		template <typename DataType, typename ParamGen>
		void wire_channel(ALT_AVALON_ST_OUTPUT<DataType>& channel, const ParamGen&)
		{
			typename ParamGen::template params<default_av_st_out_params> params;

			//Set up the convertor avalon_interface<->wires
			alt_avalon_channel_to_wires<DataType>* ctw =
				new alt_avalon_channel_to_wires<DataType>(params.pointName.c_str(), params.param_readyLatency);
			channels.push_back(ctw);
						
			//bind the output of the core to the queue of channel_to_wire			 
			channel(ctw->getInput());

			ctw->clock(wrapper_core_clk);
			ctw->reset(wrapper_rst);
		
			//bind the three wires to the functional channel
			if (params.has_port_ready)
				wire_port(ctw->ready, params.port_ready);
			if (params.has_port_valid)
				wire_port(ctw->valid, params.port_valid);
			if (params.has_port_data)
				wire_port(ctw->data, params.port_data);
			if (params.has_port_startofpacket)
				wire_port(ctw->startofpacket, params.port_startofpacket);
			if (params.has_port_endofpacket)
				wire_port(ctw->endofpacket, params.port_endofpacket); 
		}

		// Wire up an Avalon MM slave port (old style)
		template <int data_width, int depth>
		void wire_channel(ALT_AVALON_MM_MEM_SLAVE<data_width, depth>& channel,
							const std::string& channel_name, int)
		{
			//Set up the convertor wires<->avalon_interface
			alt_avalon_mm_mem_wires_to_slave<data_width, depth>* wts =
				new alt_avalon_mm_mem_wires_to_slave<data_width, depth>(channel_name.c_str());
			channels.push_back(wts);			
			
			//bind AVALON_MM_MEM_SLAVE to the output of wire_to_slave
			wts->bind_port(channel, channel_name + "_mem_slave_port");

			wts->clock(wrapper_core_clk);
			wts->reset(wrapper_rst);

			//bind the wires to the functional channel
			wire_port(wts->address, channel_name + "_av_address");
			wire_port(wts->chipselect, channel_name + "_av_chipselect");
			wire_port(wts->write, channel_name + "_av_write");
			wire_port(wts->writedata, channel_name + "_av_writedata");
			input_place_holder(channel_name + "_test_writeack");
			wire_port(wts->readdata, channel_name + "_av_readdata");
			output_place_holder(channel_name + "_test_writetog");
		}
		
		// Wire up an Avalon MM slave port (new style)
		struct default_av_mm_slave_params
		{
			static const bool has_port_address = false;
			const std::string port_address;
			static const bool has_port_chipselect = false;
			const std::string port_chipselect;
			static const bool has_port_write = false;
			const std::string port_write;
			static const bool has_port_writedata = false;
			const std::string port_writedata;
			static const bool has_port_writeack = false;
			const std::string port_writeack;
			static const bool has_port_readdata = false;
			const std::string port_readdata;
			static const bool has_port_writetog = false;
			const std::string port_writetog;
			default_av_mm_slave_params() { }
		};
		template <int data_width, int depth, typename ParamGen>
		void wire_channel(ALT_AVALON_MM_MEM_SLAVE<data_width, depth>& channel, const ParamGen&)
		{
			typename ParamGen::template params<default_av_mm_slave_params> params;

			//Set up the convertor wires<->avalon_interface
			alt_avalon_mm_mem_wires_to_slave<data_width, depth>* wts =
				new alt_avalon_mm_mem_wires_to_slave<data_width, depth>(params.pointName.c_str());
			channels.push_back(wts);			

			//bind AVALON_MM_MEM_SLAVE to the output of wire_to_slave
			wts->bind_port(channel, params.pointName + "_mem_slave_port");

			wts->clock(wrapper_core_clk);
			wts->reset(wrapper_rst);

			//bind the wires to the functional channel
			if (params.has_port_address)
				wire_port(wts->address, params.port_address);
			if (params.has_port_chipselect)
				wire_port(wts->chipselect, params.port_chipselect);
			if (params.has_port_write)
				wire_port(wts->write, params.port_write);
			if (params.has_port_writedata)
				wire_port(wts->writedata, params.port_writedata);
			if (params.has_port_writeack)
				input_place_holder(params.port_writeack);
			if (params.has_port_readdata)
				wire_port(wts->readdata, params.port_readdata);
			if (params.has_port_writetog)
				output_place_holder(params.port_writetog);
		}

		// Wire up an Avalon MM master port (old style)
		template <int data_width, int addr_width, int MAX_BURST, int PARTIAL_DATA_WIDTH>
		void wire_channel(ALT_AVALON_MM_MASTER_FIFO<data_width, addr_width, MAX_BURST, PARTIAL_DATA_WIDTH>& channel,
					const std::string& channel_name, bool read_ports, bool write_ports)
		{
			//Set up the convertor wires<->avalon_interface
			alt_avalon_mm_mem_master_to_wires<data_width, addr_width>* mtw =
				new alt_avalon_mm_mem_master_to_wires<data_width, addr_width>
										(channel_name.c_str(), read_ports, write_ports);
			channels.push_back(mtw);			

			//bind AVALON_MM_MASTER_FIFO to the input of master_to_wires
			channel(mtw->getInput());
			
			mtw->clock(wrapper_core_clk);
			mtw->reset(wrapper_rst);

			//bind the wires to the functional channel
			wire_port(mtw->address, channel_name + "_av_address");
			if (read_ports)
			{
				wire_port(*(mtw->read), channel_name + "_av_read");
				wire_port(*(mtw->readdata), channel_name + "_av_readdata");
				wire_port(*(mtw->readdatavalid), channel_name + "_av_readdatavalid");
			}
			wire_port(mtw->waitrequest, channel_name + "_av_waitrequest");
			if (write_ports)
			{
				wire_port(*(mtw->write), channel_name + "_av_write");
				wire_port(*(mtw->writedata), channel_name + "_av_writedata");
			}
		}
		
		// Wire up an Avalon MM master port (new style)
		struct default_av_mm_master_params
		{
			const static bool has_port_write = false;
			const std::string port_write;
			const static bool has_port_writedata = false;
			const std::string port_writedata;
			const static bool has_port_read = false;
			const std::string port_read;
			const static bool has_port_readdata = false;
			const std::string port_readdata;
			const static bool has_port_readdatavalid = false;
			const std::string port_readdatavalid;
			default_av_mm_master_params() { }
		};
		template <int data_width, int addr_width, int MAX_BURST, int PARTIAL_DATA_WIDTH, typename ParamGen>
		void wire_channel(ALT_AVALON_MM_MASTER_FIFO<data_width, addr_width, MAX_BURST, PARTIAL_DATA_WIDTH>& channel, const ParamGen&)
		{
			typename ParamGen::template params<default_av_mm_master_params> params;

			//Set up the convertor wires<->avalon_interface
			alt_avalon_mm_mem_master_to_wires<data_width, addr_width>* mtw =
				new alt_avalon_mm_mem_master_to_wires<data_width, addr_width>
						(params.pointName.c_str(), params.has_port_read, params.has_port_write);
			channels.push_back(mtw);

			//bind AVALON_MM_MASTER_FIFO to the input of master_to_wires
			channel(mtw->getInput());
			
			mtw->clock(wrapper_core_clk);
			mtw->reset(wrapper_rst);

			//bind the wires to the functional channel
			wire_port(mtw->address, params.port_address);
			if (params.has_port_read)
				wire_port(*(mtw->read), params.port_read);
			if (params.has_port_readdata)
				wire_port(*(mtw->readdata), params.port_readdata);
			if (params.has_port_readdatavalid)
				wire_port(*(mtw->readdatavalid), params.port_readdatavalid);
			wire_port(mtw->waitrequest, params.port_waitrequest);
			if (params.has_port_write)
				wire_port(*(mtw->write), params.port_write);
			if (params.has_port_writedata)
				wire_port(*(mtw->writedata), params.port_writedata);
		}
		
		// Wire up an optional (pointer) port
		template <typename T, typename ParamGen>
		void wire_channel(T* channel, const ParamGen& x)
		{
			wire_channel(*channel, x);
		}

		/* 
		 * CoreWrapper: wire_composite_channel
		 * 
		 * Special cases of Avalon streaming input and output where there are distinct
		 * data lines (eg, the real and imag wires for the FFT)
		 * @param[in]  channel			- the avalon interface to connect to the wires
		 * @param[in]  channel_name		- the name of this interface
		 * @param[in]  data_ports_name	- the name of the different data ports, names
		 *                                starting with '_' are prefixed with channel_name
		 * @param[in]  ready latency	- can be 0 or 1
		 */
		template <typename DataType>
		void wire_composite_channel(ALT_AVALON_ST_INPUT<std::vector<DataType> >& channel_input,
			const std::string& channel_name, const std::vector<std::string>& data_ports_name,
			int ready_latency)
		{
			//Set up the convertor wires<->avalon_interface
			alt_avalon_wires_to_channel<std::vector<DataType> >* wtc =
				new alt_avalon_wires_to_channel<std::vector<DataType> >(
				        channel_name.c_str(), ready_latency, data_ports_name.size());
			channels.push_back(wtc);			

			//bind the output of the func. channel to AVALON_ST_INPUT 
			channel_input(wtc->getOutput());

			wtc->clock(wrapper_core_clk);
			wtc->reset(wrapper_rst);
		
			//bind the wires to the functional channel
			for(unsigned int i = 0; i < data_ports_name.size(); ++i)
			{
				if ((data_ports_name[i])[0] == '_')
				{
					wire_port(wtc->data[i], channel_name + data_ports_name[i]);
				}
				else //(port that does not use the "channel_name" prefix)
				{
					wire_port(wtc->data[i], data_ports_name[i]);
				}
			}
			wire_port(wtc->valid, channel_name + "_valid");
			wire_port(wtc->ready, channel_name + "_ready"); //this is an output
		}

		// Wire up an Avalon Streaming output port
		template <typename DataType>
		void wire_composite_channel(ALT_AVALON_ST_OUTPUT<std::vector<DataType> >& channel_output,
			const std::string& channel_name, const std::vector<std::string>& data_ports_name,
			int ready_latency)
		{
			//Set up the convertor avalon_interface<->wires
			alt_avalon_channel_to_wires<std::vector<DataType> >* ctw =
				new alt_avalon_channel_to_wires<std::vector<DataType> >(
				        channel_name.c_str(), ready_latency, data_ports_name.size());
			channels.push_back(ctw);			

			//bind the output of the core to the queue of channel_to_wire			 
			channel_output(ctw->getInput());

			ctw->clock(wrapper_core_clk);
			ctw->reset(wrapper_rst);
		
			//bind the three wires to the functional channel
			for(unsigned int i = 0; i < data_ports_name.size(); ++i)
			{
				if ((data_ports_name[i])[0] == '_')
				{
					wire_port(ctw->data[i], channel_name + data_ports_name[i]);
				}
				else //(port that does not use the "channel_name" prefix)
				{
					wire_port(ctw->data[i], data_ports_name[i]);
				}
			}
			wire_port(ctw->valid, channel_name + "_valid");
			wire_port(ctw->ready, channel_name + "_ready"); //this is an input
		}
	};
} //end of anonymous namespace
#endif
