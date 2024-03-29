# Package reguired
load_package device

set quartus_device_info_xml_file "quartus_supported_device_info.xml"

set fhandle [open $quartus_device_info_xml_file w]

puts $fhandle "<?xml version=\"1.0\"?>"
puts $fhandle "<!--DSP Builder version 8.0.0 Quartus supported device information-->"

set device_info "device_info"
set part_info "part_info"

puts $fhandle "<$device_info>"

foreach part_name [get_part_list] {
    set family  [lindex [get_part_info -family $part_name] 0]
    set dv_name [get_part_info -device $part_name]
    set package [get_part_info -package $part_name]
    set pinnums [get_part_info -pin_count $part_name]
    set speedgd [get_part_info -speed_grade $part_name]
    puts $fhandle "    <$part_info name=\"$part_name\" family=\"$family\" device=\"$dv_name\" package=\"$package\" pin_count=\"$pinnums\" speed_grade=\"$speedgd\"/>"
}

puts $fhandle "</$device_info>"
close $fhandle
