# (C) 2001-2010 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.

#------------------------------------------------------------------------------
# Directory locations
#------------------------------------------------------------------------------
set quartusdir    "$env(QUARTUS_ROOTDIR)//eda/sim_lib"
set quartus_lib       "$env(QUARTUS_ROOTDIR)"
set proj_topdir       "C:/p4_workspace/Design_Example/HDL_Design/SVFIR/interpolation_fir"
set srcdir           $proj_topdir
#set simdir           "$proj_topdir/sim"
set family "stratixv"

#set workdir to the path setting where design files are installed
set workdir        $srcdir

#Will recompile the libraries regardless of whether the libraries exist
set bForceRecompile 0

# Project name
set proj_nam  "fir_test" 

# Close existing ModelSim simulation 
quit -sim

if {[file exist [project env]] > 0} {project close}
cd $workdir

if {[file exist "${workdir}//${proj_nam}.mpf"] == 0} {
  project new ${workdir}// ${proj_nam} 
} else	{
project open ${proj_nam}
}

# Create work lib  
if {[file exist work] ==0} 	{
  exec vlib work
  exec vmap work work
}

if {([file exist lpm] ==0)||($bForceRecompile>0)} {
				exec vlib lpm
				exec vmap lpm lpm
				vcom -explicit -93 -work lpm "$quartusdir/220pack.vhd"
				vcom -explicit -93 -work lpm "$quartusdir/220model.vhd"
				}
exec vmap lpm lpm

if {([file exist altera_mf] ==0)||($bForceRecompile>0)} {
				exec vlib altera_mf
				exec vmap altera_mf altera_mf
				vcom -explicit -93 -work altera_mf "$quartusdir/altera_mf_components.vhd"
				vcom -explicit -93 -work altera_mf "$quartusdir/altera_mf.vhd"
				}
exec vmap altera_mf altera_mf

 if {([file exist altera] ==0)||($bForceRecompile>0)} {
 				exec vlib altera
 				exec vmap altera altera
 				vcom -explicit -93 -work altera "$quartusdir/altera_primitives_components.vhd"
 				vcom -explicit -93 -work altera "$quartusdir/altera_primitives.vhd"
 				}
 exec vmap altera altera


if {([file exist $family] ==0)||($bForceRecompile>0)} {
    vlib $family
    vmap $family $family
    #encrypted version doesn't work with mixed language simulation?!
    if [file exists $quartus_lib/eda/sim_lib/mentor/${family}_atoms_ncrypt.v] {
    	vlog -vlog01compat -work ${family} $quartus_lib/eda/sim_lib/mentor/${family}_atoms_ncrypt.v
    }
    #vlog -vlog01compat -work ${family} $quartus_lib/common/not_shipped/eda/sim_lib/mentor/rtl/${family}_atoms.v
    vcom -93 -work ${family} $quartus_lib/eda/sim_lib/${family}_atoms.vhd
    vcom -93 -work ${family} $quartus_lib/eda/sim_lib/${family}_components.vhd
}

# compile the design file
vcom -work work -93 -explicit $srcdir/interpolation_type_pkg.vhd
vcom -work work -93 -explicit $srcdir/shift_taps.vhd
vcom -work work -93 -explicit $srcdir/delay_tap_chain.vhd
vcom -work work -93 -explicit $srcdir/interpolation_fir.vhd
#                                                                                                                                                                                   
# compiling the testbench
vcom -work work $srcdir/tb_interpolation_fir.vhd

# simulate the design
vsim -t ps work.tb_interpolation_fir

add wave *
add wave tb_interpolation_fir/interpolation_fir_inst/*
add wave tb_interpolation_fir/interpolation_fir_inst/delay_chain_inst/*
# add wave tb_interpolation_fir/interpolation_fir_inst/parallel_add/*

run 10 us