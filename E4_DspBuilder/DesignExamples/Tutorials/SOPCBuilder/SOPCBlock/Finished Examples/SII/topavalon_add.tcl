set ModelName "topavalon"
set mdldir [file dirname [info script]]
set importdir "$mdldir/DSPBuilder_${ModelName}_import/"

puts "Adding ${ModelName}.mdl in $mdldir to the current Quartus project"

# Add the MDL file to the Quartus Project.
set_global_assignment -name "SOURCE_FILE" "$mdldir/${ModelName}.mdl"
set_global_assignment -name "USER_LIBRARIES" "$mdldir;[get_global_assignment -name USER_LIBRARIES]"

#Add the import directory if it exists and run any Quartus add scripts.
if { [file exists $importdir] } {
	set_global_assignment -name USER_LIBRARIES "$importdir;[get_global_assignment -name USER_LIBRARIES]"
	foreach g [glob -nocomplain "$importdir/*_add.tcl"] {
		source $g
	}
}

