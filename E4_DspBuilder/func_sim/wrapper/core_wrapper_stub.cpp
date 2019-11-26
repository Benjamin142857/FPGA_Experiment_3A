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
// file name	  	: $Workfile:   core_wrapper_stub.cpp  $
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
//Edited and compiled on the fly by DSP_Builder.
#include "core_wrapper.h"
#include the_core_fsi_file

//STL includes
#include <sstream>

#ifndef DLL_INTERFACE_FUNCTION
	#define DLL_INTERFACE_FUNCTION __attribute__((dllexport))
#endif

//a pointer to the core wrapper
CoreWrapper* the_core_name_wrapper = NULL;

CoreWrapper::CoreWrapper()
{	
	/** create the input and output wires for the core.
	 * The order of creation is critical since DSPB 7.1
	 * is refering to the wires using ids that match
	 * the alphabetical order.
	 */

 /* FFT block */
#ifdef THE_CORE_IS_FFT
	TLA_NAME* wrapped_core = new TLA_NAME(the_core_name_str,
				 IN_DW, OUT_DW, FFTPTS_SIZE, TWIDW, 
				 ROUNDING_TYPE, OUTPUT_ORDER, INPUT_ORDER
#ifdef REPRESENTATION
				 , REPRESENTATION
#endif
				 ); 
#ifdef REPRESENTATION
	// HDL ordering
	input_port_mapping["reset_n"] = 0;
	input_port_mapping["fftpts"] = 1;
	input_port_mapping["inverse"] = 2;
	input_port_mapping["sink_valid"] = 3;
	input_port_mapping["sink_sop"] = 4;
	input_port_mapping["sink_eop"] = 5;
	input_port_mapping["sink_real"] = 6;
	input_port_mapping["sink_imag"] = 7;
	input_port_mapping["sink_error"] = 8;
	input_port_mapping["source_ready"] = 9;
	
	output_port_mapping["fftptsout"] = 0;
	output_port_mapping["sink_ready"] = 1;
	output_port_mapping["source_error"] = 2;
	output_port_mapping["source_sop"] = 3;
	output_port_mapping["source_eop"] = 4;
	output_port_mapping["source_valid"] = 5;
	output_port_mapping["source_real"] = 6;
	output_port_mapping["source_imag"] = 7;
#else
	// Alphabetic ordering
	input_port_mapping["fftpts"] = 0;
	input_port_mapping["inverse"] = 1;
	input_port_mapping["reset_n"] = 2;
	input_port_mapping["sink_eop"] = 3;
	input_port_mapping["sink_error"] = 4;
	input_port_mapping["sink_imag"] = 5;
	input_port_mapping["sink_real"] = 6;
	input_port_mapping["sink_sop"] = 7;
	input_port_mapping["sink_valid"] = 8;
	input_port_mapping["source_ready"] = 9;
	
	output_port_mapping["fftptsout"] = 0;
	output_port_mapping["sink_ready"] = 1;
	output_port_mapping["source_eop"] = 2;
	output_port_mapping["source_error"] = 3;
	output_port_mapping["source_imag"] = 4;
	output_port_mapping["source_real"] = 5;
	output_port_mapping["source_sop"] = 6;
	output_port_mapping["source_valid"] = 7;
#endif

	std::vector<std::string> sink_data_ports;
	sink_data_ports.push_back("fftpts");
	sink_data_ports.push_back("inverse");
	sink_data_ports.push_back("_eop");
	sink_data_ports.push_back("_error");
	sink_data_ports.push_back("_imag");
	sink_data_ports.push_back("_real");
	sink_data_ports.push_back("_sop");

	std::vector<std::string> source_data_ports;
	source_data_ports.push_back("fftptsout");
	source_data_ports.push_back("_eop");
	source_data_ports.push_back("_error");
	source_data_ports.push_back("_imag");
	source_data_ports.push_back("_real");
	source_data_ports.push_back("_sop");

	inputs.resize(input_port_mapping.size());
	outputs.resize(output_port_mapping.size());
	input_place_holder("reset_n");
	wire_composite_channel(wrapped_core->in_data, "sink", sink_data_ports, 0);
	wire_composite_channel(wrapped_core->out_data, "source", source_data_ports, 0);

 /* VIP cores */
#else	 
	TLA_NAME* wrapped_core = new TLA_NAME(the_core_name_str);
	
	//Since 7.1, the scaler might have a control
	#ifdef THE_CORE_IS_SCL
		#if SCL_RUNTIME_CONTROL
			add_av_mem_slave_port_mapping("control");
			wire_channel(wrapped_core->control, "control", 0);
		#endif
	#endif
	
	//All the cores have a standard avalon streaming input
	//but mix core is a special case with multiple inputs
	#ifndef THE_CORE_IS_MIX
		add_av_st_input_port_mapping("din");
		wire_channel(wrapped_core->din, "din", 1);
	#else
		#if (MIX_ALPHA_ENABLED == 1) //alpha inputs
			for (int i = 0; i < MIX_NUM_LAYERS; ++i)
			{
				std::stringstream s;
				s << "alpha_in_" << i;
				add_av_st_input_port_mapping(s.str());
				wire_channel(wrapped_core->alpha_in[i], s.str(), 1);
			}
		#endif
		add_av_mem_slave_port_mapping("control");
		wire_channel(wrapped_core->control, "control", 0);
		for (int i = 0; i < MIX_NUM_LAYERS; ++i)
		{
			std::stringstream s;
			s << "din_" << i;
			add_av_st_input_port_mapping(s.str());
			wire_channel(wrapped_core->din[i], s.str(), 1);
		}
	#endif

	//All the cores have a unique avalon streaming output
	add_av_st_output_port_mapping("dout");
	wire_channel(wrapped_core->dout, "dout", 1);


	//The gamma corrector and mixer cores have an avalon memory slave interface
	#ifdef THE_CORE_IS_GAM
		add_av_mem_slave_port_mapping("gamma_lut");
		wire_channel(wrapped_core->gamma_lut, "gamma_lut", 0);
	#endif

	//The deinterlacer (weave mode) has an avalon memory master interface to
	//read from an external memory 
	#ifdef THE_CORE_IS_DIL 
		#if (DIL_METHOD == DEINTERLACING_WEAVE)
		    //add a read_master with the "read ports" and no "write ports"
			add_av_mem_master_port_mapping("read_master", true /*read*/, false /*write*/);
			wire_channel(wrapped_core->read_master, std::string("read_master"), true /*read*/, false /*write*/);
		#endif
	#endif

	//Reserve space for the fake reset, it is not used by the functional VIP
	//models but the wire is there
	add_input_port_mapping("reset");
	input_place_holder("reset");

	//The deinterlacer (weave mode) alsp has an avalon memory master interface
	//to write to an external memory 
	#ifdef THE_CORE_IS_DIL 
		#if (DIL_METHOD == DEINTERLACING_WEAVE)
		    //add a write_master without "read ports" and with "write ports"
			add_av_mem_master_port_mapping("write_master", false /*read*/, true /*write*/);
			wire_channel(wrapped_core->write_master, std::string("write_master"), false /*read*/, true /*write*/);
		#endif
	#endif

#endif	

	//Save an untyped reference to the core for proper deletion at destruction
	core = reinterpret_cast<void*>(wrapped_core);
}

CoreWrapper::~CoreWrapper()
{
	for (std::vector<writeable_wire*>::iterator iter = inputs.begin();
		iter != inputs.end(); ++iter)
	{
		delete *iter;
	}
	for (std::vector<readable_wire*>::iterator iter = outputs.begin();
		iter != outputs.end(); ++iter)
	{
		delete *iter;
	}
	for (std::vector<alt_avalon_sim_channel*>::iterator iter = channels.begin();
		iter != channels.end(); ++iter)
	{
		delete *iter;
	}

	TLA_NAME* wrapped_core = reinterpret_cast<TLA_NAME*>(core);
	delete wrapped_core;
}

//add name to the list of declared input ports and give it the first unused wire id 
void CoreWrapper::add_input_port_mapping(const std::string &name)
{
	input_port_mapping[name] = input_port_mapping.size();
	//create placeholder in vector of input wires
	inputs.push_back(0);
}
//add name to the list of declared output ports and give it the first unused wire id 
void CoreWrapper::add_output_port_mapping(const std::string &name)
{
	output_port_mapping[name] = output_port_mapping.size();
	outputs.push_back(0);
}
//add the names of the 3 ports of an av_st input to the list of
//declared input and output ports
void CoreWrapper::add_av_st_input_port_mapping(const std::string &base_name)
{
	add_input_port_mapping(base_name+"_data");
	add_input_port_mapping(base_name+"_valid");
	add_input_port_mapping(base_name+"_startofpacket");
	add_input_port_mapping(base_name+"_endofpacket");
	add_output_port_mapping(base_name+"_ready");
}
//add the names of the 3 ports of an av_st output to the list of
//declared input and output ports
void CoreWrapper::add_av_st_output_port_mapping(const std::string &base_name)
{
	add_output_port_mapping(base_name+"_data");
	add_output_port_mapping(base_name+"_valid");
	add_output_port_mapping(base_name+"_startofpacket");
	add_output_port_mapping(base_name+"_endofpacket");
	add_input_port_mapping(base_name+"_ready");
}

//add the names of an av_st mem-slave interface to the list of
//declared input and output ports
void CoreWrapper::add_av_mem_slave_port_mapping(const std::string &base_name)
{
	add_input_port_mapping(base_name+"_av_address");
	add_input_port_mapping(base_name+"_av_chipselect");
	add_input_port_mapping(base_name+"_av_write");
	add_input_port_mapping(base_name+"_av_writedata");
	add_input_port_mapping(base_name+"_test_writeack");
	add_output_port_mapping(base_name+"_av_readdata");
	add_output_port_mapping(base_name+"_test_writetog");
}

void CoreWrapper::add_av_mem_master_port_mapping(const std::string &base_name, bool read_ports, bool write_ports)
{
	assert(read_ports || write_ports);
	add_output_port_mapping(base_name+"_av_address");
	if (read_ports)
	{
		add_output_port_mapping(base_name+"_av_read");
		add_input_port_mapping(base_name+"_av_readdata");
		add_input_port_mapping(base_name+"_av_readdatavalid");
	}
	add_input_port_mapping(base_name+"_av_waitrequest");
	if (write_ports)
	{
		add_output_port_mapping(base_name+"_av_write");
		add_output_port_mapping(base_name+"_av_writedata");
	}
}

void CoreWrapper::inputs_changed_event()
{
	//A delta cycle to propagate new inputs to direct feedthrough cores
	sc_start(0);
	//An extra delta cycle to update all the output signals
	sc_start(0);
}

void CoreWrapper::clock_event()
{
	//Create a clock edge
	wrapper_core_clk.write(0);
	sc_start(1); 
	wrapper_core_clk.write(1);
	sc_start(1);
	//An extra delta cycle to update all the output signals
	sc_start(0);
}


/*
 * The core-specific functions of the DLL accessed by DSPBuilder
 */
extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_initialize_model()
{
	if (the_core_name_wrapper)
	{
		delete the_core_name_wrapper;
	}
	the_core_name_wrapper = new CoreWrapper();
}

extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_write_unsigned_input_value(unsigned int wire, const sc_ufix& value)
{
	the_core_name_wrapper->write_value(wire, value);
}

extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_write_signed_input_value(unsigned int wire, const sc_fix& value)
{
	the_core_name_wrapper->write_value(wire, value);
}

extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_read_unsigned_output_value(unsigned int wire, sc_ufix& value)
{
	the_core_name_wrapper->read_value(wire, value);
}

extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_read_signed_output_value(unsigned int wire, sc_fix& value)
{
	the_core_name_wrapper->read_value(wire, value);
}

//clock tick (called by Fast_Simulation_Megacore::update)
extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_clock_event() 
{
	the_core_name_wrapper->clock_event();
}

//new inputs (called by Fast_Simulation_Megacore::outputs if directfeedthrough)
extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_inputs_changed_event() 
{
	the_core_name_wrapper->inputs_changed_event();
}

extern "C" DLL_INTERFACE_FUNCTION
void the_core_name_terminate_model()
{
	delete the_core_name_wrapper;
	the_core_name_wrapper = NULL;
}
