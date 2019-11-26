set quartus_lib       "$env(QUARTUS_ROOTDIR)"

transcript on
if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}

set compiled 1

if {!$compiled} {
vlib vhdl_libs/lpm
vmap lpm vhdl_libs/lpm
vcom -work lpm "$quartus_lib/eda/sim_lib/220pack.vhd"
vcom -work lpm "$quartus_lib/eda/sim_lib/220model.vhd"

vlib vhdl_libs/altera
vmap altera vhdl_libs/altera
vcom -work altera "$quartus_lib/eda/sim_lib/altera_primitives_components.vhd"
vcom -work altera "$quartus_lib/eda/sim_lib/altera_primitives.vhd"

vlib vhdl_libs/altera_mf
vmap altera_mf vhdl_libs/altera_mf
vcom -work altera_mf "$quartus_lib/eda/sim_lib/altera_mf_components.vhd"
vcom -work altera_mf "$quartus_lib/eda/sim_lib/altera_mf.vhd"

vlib vhdl_libs/sgate
vmap sgate vhdl_libs/sgate
vcom -work sgate "$quartus_lib/eda/sim_lib/sgate_pack.vhd"
vcom -work sgate "$quartus_lib/eda/sim_lib/sgate.vhd"

vlib vhdl_libs/stratixiii
vmap stratixiii vhdl_libs/stratixiii
vcom -work stratixiii "$quartus_lib/eda/sim_lib/stratixiii_atoms.vhd"
vcom -work stratixiii "$quartus_lib/eda/sim_lib/stratixiii_components.vhd"


vlib vhdl_libs/auk_dspip_lib
vmap auk_dspip_lib vhdl_libs/auk_dspip_lib
vcom -work auk_dspip_lib {../../lib/packages/auk_dspip_math_pkg.vhd}
vcom -work auk_dspip_lib {../../lib/packages/auk_dspip_lib_pkg.vhd}
vcom -work auk_dspip_lib {../../lib/fu/delay/rtl/auk_dspip_delay.vhd}
vcom -work auk_dspip_lib {../../lib/fu/roundsat/rtl/auk_dspip_roundsat.vhd}
}

vlib vhdl_libs/auk_dspip_ctc_umts_lib
vmap auk_dspip_ctc_umts_lib vhdl_libs/auk_dspip_ctc_umts_lib

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom  -work auk_dspip_ctc_umts_lib {../src/rtl/auk_dspip_ctc_umts_lib_pkg.vhd}
vcom  -work work {../src/rtl/auk_dspip_ctc_umts_ram.vhd}

vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_llr.vhd}
#vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_logmap.vhd}
vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_maxlogmap.vhd}
vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_maxlogmap_pipelined.vhd}
#vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_constlogmap.vhd}
vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_constlogmap_pipelined.vhd}
vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_alpha.vhd}
vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_beta.vhd}
vcom  -work work {../src/rtl/map/auk_dspip_ctc_umts_map_gamma.vhd}

vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts_mem.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_mult_seq_gen.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_multmod.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_mul_pipe.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_papbpc_table.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_prime_rom.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_setup_control.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts_ditlv_seq_gen.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv2_lut.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts2_itlv.vhd}
#vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts_itlv.vhd}

vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv2_lut.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts2_itlv.vhd}

vcom  -work work {../src/rtl/input/auk_dspip_ctc_umts_itlvr_ram.vhd}
vcom  -work work {../src/rtl/input/auk_dspip_ctc_umts_input.vhd}
vcom  -work work {../src/rtl/input/auk_dspip_ctc_umts_input_ram.vhd}

vcom  -work work {../src/rtl/output/auk_dspip_ctc_umts_out_mem.vhd}
vcom  -work work {../src/rtl/output/auk_dspip_ctc_umts_output.vhd}

vcom  -work work {../src/rtl/decoder/auk_dspip_ctc_umts_siso.vhd}
vcom  -work work {../src/rtl/decoder/auk_dspip_ctc_umts_fifo.vhd}
vcom  -work work {../src/rtl/decoder/auk_dspip_ctc_umts_map_decoder.vhd}
vcom  -work work {../src/rtl/decoder/auk_dspip_ctc_umts_decoder_top.vhd}


vcom  -work work {../src/rtl/ast/auk_dspip_ctc_umts_ast_sink.vhd}

vcom  -work work {tb_auk_dspip_ctc_umts_decoder_top.vhd}
vcom  -work work {auk_dspip_avalon_streaming_source_model.vhd}
vcom  -work work {auk_dspip_avalon_streaming_sink_model.vhd}
vcom -work work {../../lib/models/avalon_streaming/auk_dspip_avalon_streaming_monitor.vhd}

vsim -t 1ps -L lpm -L altera -L altera_mf -L sgate -L stratixiii -L work work.tb_auk_dspip_ctc_umts_decoder_top
set StdArithNoWarnings  1
set NumericStdNoWarnings  1
if {[file exists itlv_wave.do]} {
	source itlv_wave.do
}

view structure
view signals

add wave *
add wave tb_auk_dspip_ctc_umts_decoder_top/DUT/ctc_map_decoder_inst/input_buffer/*
add wave tb_auk_dspip_ctc_umts_decoder_top/DUT/ctc_map_decoder_inst/*

run -all
