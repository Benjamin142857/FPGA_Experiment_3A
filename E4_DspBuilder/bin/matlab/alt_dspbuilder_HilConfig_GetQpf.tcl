######################################################################################
#
# DSP Builder (Version 7.1)
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
# Command: quartus_sh -t c:\\altera\\dspbuilder\\altlib\\alt_dspbuilder_HilConfig_GetQpf.tcl -project <projectName> <HilConfigInfo.xml>"
#
######################################################################################

proc update_pin_info { args } {

	set opts { \
		{ "name.arg" "" "The name of the pin" } \
		{ "index.arg" "" "A numeric index for a bus" } \
		{ "direction.arg" "" "input, output, or bidir" } \
	}
	array set lopts [::cmdline::getoptions args $opts ""]

	global pins

	# If the index is blank, the pin is just a single pin, with width
	# 1 (index is 0). If index is not blank, the pin is part of a bus.
	if { [string equal "" $lopts(index)] } {
		set lopts(index) 0
		set is_bus 0
	} else {
		set is_bus 1
	}
	
	# If the name already exists in the pins array, it's probably
	# because it's part of a bus. If it doesn't, it's either the
	# first time the bus name has been encountered, or the pin is
	# just a single-pin I/O
	if { [info exists pins($lopts(name))] } {
		
		# Get the data structure that stores the maximum bus index and
		# whether it is a bus, for comparison with the data just passed
		# in.
		array set temp_pin_info $pins($lopts(name))
		
		# If the bus index passed in is greater than the one that's stored,
		# update the one that's stored. 
		if { $lopts(index) > $temp_pin_info(index) } {
			set temp_pin_info(index) $lopts(index)
			set pins($lopts(name)) [array get temp_pin_info]
		}
		
	} else {
		
		# The pin name doesn't exist already. Set up the datastructure and
		# write it in.
		array set temp_pin_info [list index $lopts(index) is_bus $is_bus \
			direction $lopts(direction) ]
		set pins($lopts(name)) [array get temp_pin_info]
	}
	
	return
}

# Two packages are required.
package require cmdline
load_package report

# You can specify -project <project name> and 
# -revision <revision name> when you run the script.
set opts { \
	{ "project.arg" "" "" } \
	{ "revision.arg" "" "" } \
}
array set lopts [::cmdline::getoptions ::quartus(args) $opts ""]

# Open the project and optionally specified revision.
if { [string equal "" $lopts(revision)] } {
	project_open $lopts(project)
} else {
	project_open $lopts(project) -revision $lopts(revision)
}

# The pins array is a global data structure to hold pin information
array set pins {}

# Start work from here
load_report


# These panel name and column names should be the only items
# that would have to be updated (if the report structure changes)
set input_pin_panel_name {Fitter||Resource Section||Input Pins}
set output_pin_panel_name {Fitter||Resource Section||Output Pins}
set bidir_pin_panel_name {Fitter||Resource Section||Bidir Pins}
set pin_name_column_name {Name}

set input_pin_panel_id [get_report_panel_id $input_pin_panel_name]
set output_pin_panel_id [get_report_panel_id $output_pin_panel_name]
set bidir_pin_panel_id [get_report_panel_id $bidir_pin_panel_name]

# Use the same procedure to check inputs, outputs, and bidirs.
foreach { direction panel_id } [list input $input_pin_panel_id output \
	$output_pin_panel_id bidir $bidir_pin_panel_id ] {
		
	# Check whether each panel (input pins, output pins, bidir pins)
	# exists.
	if { -1 != $panel_id } {

		# Get the number of rows in the panel, and the column index
		# for the column that has the pin name.
		set num_rows [get_number_of_rows -id $panel_id]
		set pin_name_col_index [get_report_panel_column_index -id \
			$panel_id $pin_name_column_name]
		
		# For every row in the selected report panel, get the pin name.
		# Separate it if applicable, into bus name and bus index.
		for { set i 1 } { $i < $num_rows } { incr i } {
			set pin_name [get_report_panel_data -id $panel_id -row $i \
				-col $pin_name_col_index]
			regexp {^(.*?)(\[([[:digit:]]+)\])?$} $pin_name match item \
				bracketed_index numeric_index
			update_pin_info -name $item -index $numeric_index \
				-direction $direction
		}
	}	
}

# =====================================================
# This section extracts the clock names from the report
# =====================================================
#
# The clock is listed in the control singal panel
# Set the panel name and get it id

set control_signal_panel_name {Fitter||Resource Section||Control Signals}
set control_signal_panel_id [get_report_panel_id $control_signal_panel_name]


# Initialize the number of clocks and resets
set num_clocks 0
set num_resets 0

# Make sure that the panel has been found
if {-1 != $control_signal_panel_id } {

    # Define the column names for the "Usage" and "Name
    set clock_name_column {Name}
    set clock_usage_column {Usage}
    set clock_location_column {Location}

    # Get total number of row in this panel
    set num_rows [get_number_of_rows -id $control_signal_panel_id]

    # Get index for the "Usage", "Location", and "Name" Columns
    set usage_column_id [get_report_panel_column_index -id \
        $control_signal_panel_id $clock_usage_column]
    set clock_name_id [get_report_panel_column_index -id \
        $control_signal_panel_id $clock_name_column]
    set location_id [get_report_panel_column_index -id \
        $control_signal_panel_id $clock_location_column]

    # For every row in the selected report panel, get the pin name.
    set usage_clock "Clock"
    set usage_reset "Async. clear"
    set pin_location "PIN_"
    for { set i 1 } { $i < $num_rows } { incr i } {
        # Get the clock usage - it could be Clock or Async. Clear
        set usage [get_report_panel_data -id $control_signal_panel_id \
            -row $i -col $usage_column_id]

        # Check to see if it is a Clock
        if {[string compare $usage $usage_clock] == 0} {
            set location [get_report_panel_data -id $control_signal_panel_id \
                -row $i -col $location_id]

            # We are interested only in pinned out clocks, not internal ones
            if {[string first $pin_location $location] >= 0} {
                set clk_name [get_report_panel_data -id $control_signal_panel_id \
                    -row $i -col $clock_name_id]
                set num_clocks [expr $num_clocks + 1]
                set clocks($num_clocks) $clk_name
            }

        # Or a reset
        } elseif {[string compare $usage $usage_reset] == 0} {
            # Get location
            set location [get_report_panel_data -id $control_signal_panel_id \
                -row $i -col $location_id]

            # We are interested only in pinned out resets, not internal ones
            if {[string first $pin_location $location] >= 0} {
                # Get reset name
                set rst_name [get_report_panel_data -id $control_signal_panel_id \
                    -row $i -col $clock_name_id]
                set num_resets [expr $num_resets + 1]
                set resets($num_resets) $rst_name
            }
        }
    }
}


#########################################################################
# Reporting section
# The data structure is built now and you can use it.
# All the IO names are available as the array names of $pins
# Here are some sample ways to access it. First, we'll just
# print everything out.


set hdlconfig_xml_info_file [lindex $quartus(args) 0]

set fhandle [open $hdlconfig_xml_info_file w]

puts $fhandle "<?xml version=\"1.0\"?>"
puts $fhandle "<!--DSP Builder version 3.0.0 HIL Block Configuration information-->"

set TOP_LEVEL_ENTITY [get_global_assignment -name TOP_LEVEL_ENTITY]
puts $fhandle "<$TOP_LEVEL_ENTITY>"

puts $fhandle "   <pin_info>"
set SCLRPPIN 0
foreach pin [array names pins] {
	array set pin_info $pins($pin)
	if { $pin_info(is_bus) } {
		set width [expr { $pin_info(index) + 1 }]
		puts $fhandle "      <$pin_info(direction)_pin name=\"$pin\" width=\"$width\"/>"

	} else {
		puts $fhandle "      <$pin_info(direction)_pin name=\"$pin\" width=\"1\"/>"
		if {[string match "*aclr*" $pin] || [string match "*sclr*" $pin]} {
		    set SCLRPPIN 1
		}

	}
}
puts $fhandle "   </pin_info>"

# Write out the clock names into the XML file
if {$num_clocks > 0} {
    puts $fhandle "   <clock_info>"
    for {set i 1} { $i <= $num_clocks } { incr i } {
        puts $fhandle "      <clock name=\"$clocks($i)\"/>"
    }
    puts $fhandle "   </clock_info>"
}

# Write out the reset names into the XML file
if {$num_resets > 0} {
    puts $fhandle "   <reset_info>"
    for {set i 1} { $i <= $num_resets } { incr i } {
        puts $fhandle "      <reset name=\"$resets($i)\"/>"
    }
    puts $fhandle "   </reset_info>"
}


set DEVICE [get_global_assignment -name DEVICE]
puts $fhandle "   <device_info name=\"$DEVICE\"/>"

# Finding Top level file
set TOP_LEVEL_FILE ""
foreach_in_collection file_asgn [get_all_global_assignments -name SOURCE_FILE] {

	if [string match "*$TOP_LEVEL_ENTITY*" [lindex $file_asgn 2]] {
	    set TOP_LEVEL_FILE [lindex $file_asgn 2]
	}
}

set DSPBUILDERRESET "off"
if {$SCLRPPIN == 1} {
    set DSPBUILDERRESET "on"
}

puts $fhandle "   <top_level_entity name=\"$TOP_LEVEL_ENTITY\"/>"

if [string length $TOP_LEVEL_FILE]>1 {
	puts $fhandle "   <top_level_file name=\"$TOP_LEVEL_FILE\" dspbuilder_reset=\"$DSPBUILDERRESET\"/>"
} else {
	puts $fhandle "   <top_level_file name=\"UNABLE_LOCATE_TOP_LEVEL\"/>"
}

puts $fhandle "</$TOP_LEVEL_ENTITY>"
close $fhandle

unload_report
project_close



