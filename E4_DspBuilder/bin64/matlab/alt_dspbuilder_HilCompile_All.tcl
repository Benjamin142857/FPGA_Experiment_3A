######################################################################################
#
# DSP Builder (Version 9.1)
# Quartus II development tool and MATLAB/Simulink Interface
#
# Copyright © 2007 Altera Corporation. All rights reserved.
#
# Your  use of Altera Corporation's  design tools, logic functions  and other software
# and  tools, and its  AMPP partner logic  functions, and any  output files any of the
# foregoing  (including  device  programming or  simulation files), and any associated
# documentation  or information are  expressly  subject to the terms and conditions of
# the Altera  Program License Subscription Agreement, Altera MegaCore Function License
# Agreement, or  other  applicable  license  agreement, including, without limitation,
# that your use is for the sole  purpose of programming logic  devices manufactured by
# Altera  and sold by  Altera or  its  authorized  distributors. Please  refer to  the
# applicable agreement for further details.
#
######################################################################################
#
# Command: quartus_sh -t c:\\altera\\dspbuilder\\altlib\\alt_dspbuilder_HilCompile_All.tcl <projectName> <DspBuilderAltlib>"
#
######################################################################################

package require ::quartus::flow

# TCL Input arguments
set OriginalProject  [lindex $quartus(args) 0]
set QpfProjectFullFilename  [lindex $quartus(args) 1]
set DspBuilderAltlib [lindex $quartus(args) 2]
set HilDeviceOnBoard [lindex $quartus(args) 3]
set ClockPinLocation [lindex $quartus(args) 4]

project_open $QpfProjectFullFilename
set original_revision [get_current_revision]

#Opening / Creating Quartus II project revision $HilDspBuilder
set HIL_ext "_HIL"
set HilDspBuilder $OriginalProject$HIL_ext
set HIL_REVISION_EXIST 0 

foreach revision [get_project_revisions] {
	if {$revision==$HilDspBuilder} {
		set HIL_REVISION_EXIST 1
	}
}
project_close

if {0==$HIL_REVISION_EXIST} {
	project_open -revision $original_revision $QpfProjectFullFilename
 	create_revision $HilDspBuilder -based_on $original_revision -set_current	
} else {
	project_open -revision $HilDspBuilder $OriginalProject
}

set_global_assignment -name VERILOG_FILE "$DspBuilderAltlib/hilaltr_node.v"
set_global_assignment -name VERILOG_FILE "$OriginalProject$HIL_ext.v"
set_global_assignment -name TOP_LEVEL_ENTITY "$OriginalProject$HIL_ext"

set_global_assignment -name DEVICE $HilDeviceOnBoard
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name FITTER_EFFORT "FAST FIT"
set_global_assignment -name OPTIMIZE_HOLD_TIMING OFF
set_global_assignment -name OPTIMIZE_TIMING OFF
set_global_assignment -name OPTIMIZE_IOC_REGISTER_PLACEMENT_FOR_TIMING OFF

if {$ClockPinLocation!="--"} {
	set_location_assignment $ClockPinLocation -to clk
}

if { [catch { execute_flow -compile } result] }  {
		set CompileOk 0 
		puts "ERROR: Compilation failed. See report files"
	} else {
		set CompileOk 1 
		puts "INFO: Compilation was successful"
	}

project_close
#project_open -revision $original_revision $OriginalProject
#project_close
