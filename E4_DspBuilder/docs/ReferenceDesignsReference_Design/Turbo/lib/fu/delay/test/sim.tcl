
# set up libraries
vlib altera_mf
vmap altera_mf altera_mf
vcom -work altera_mf C:/altera/quartus61/eda/sim_lib/altera_mf_components.vhd
vcom -work altera_mf C:/altera/quartus61/eda/sim_lib/altera_mf.vhd
vlib stratixii
vmap stratixii stratixii
vcom -work stratixii C:/altera/quartus61/eda/sim_lib/stratixii_atoms.vhd
vcom -work stratixii C:/altera/quartus61/eda/sim_lib/stratixii_components.vhd
vlib altera
vmap altera altera
vcom -work altera C:/altera/quartus61/eda/sim_lib/altera_primitives_components.vhd
vcom -work altera C:/altera/quartus61/eda/sim_lib/altera_primitives.vhd
vlib titan
vmap titan titan
vcom -work titan C:/altera/quartus61/eda/sim_lib/titan_atoms.vhd
vcom -work titan C:/altera/quartus61/eda/sim_lib/titan_components.vhd
vlib work
vmap work work
vlib vholib
vmap vholib vholib

# compile design
vcom -work work C:/data/Project/delay_fu/auk_dsp_delay/auk_dspip_math_pkg.vhd
vcom -work work C:/data/Project/delay_fu/auk_dsp_delay/auk_dspip_delay.vhd
vcom -work vholib C:/data/Project/delay_fu/auk_dsp_delay/quartus/simulation/modelsim/delay.vho
vcom -work work C:/data/Project/delay_fu/auk_dsp_delay/several_delays.vhd
vcom -work work C:/data/Project/delay_fu/auk_dsp_delay/tb_several_delays_vho_rtl.vhd
 

# simulate
vsim -t ps -sdfmax /DUT_vho_sdo=C:/data/Project/delay_fu/auk_dsp_delay/quartus/simulation/modelsim/delay_vhd.sdo work.tb_several_delays
add wave sim:/tb_several_delays/*
run -all

