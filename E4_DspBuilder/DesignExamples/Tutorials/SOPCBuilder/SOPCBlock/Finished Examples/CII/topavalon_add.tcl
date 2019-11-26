set mdldir [file dirname [info script]]

puts "Adding DSP Builder System topavalon to project\n"

set_global_assignment -name "QIP_FILE" [file join $mdldir "topavalon.qip" ]

if { [file exist [file join $mdldir "topavalon_add_user.tcl" ]] } {
	source [file join $mdldir "topavalon_add_user.tcl" ]
}


# Add an index file for the Librarian
set ipDir "[get_project_directory]/ip/topavalon/";
if { ![file exists $ipDir] } {
	file mkdir $ipDir;
}
# Reference the file by relative path if possible
if { [file pathtype $mdldir] == "relative" } {
	set mdlIPX "../../$mdldir/topavalon.ipx"
} else {
	set mdlIPX "${mdldir}/topavalon.ipx"
}
set ipxFP [open "$ipDir/topavalon.ipx" w]
puts $ipxFP "<library><index file='$mdlIPX'/></library>"
close $ipxFP

