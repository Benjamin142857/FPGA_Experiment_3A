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

vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts_mem.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_mult_seq_gen.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_multmod.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_mul_pipe.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_papbpc_table.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_prime_rom.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umtsitlv_setup_control.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts_ditlv_seq_gen.vhd}
vcom -work work {../src/rtl/interleaver/auk_dspip_ctc_umts_itlv.vhd}

vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_encoder_top.vhd}

vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_conv_encode.vhd}
vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_encode.vhd}
vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_encoder.vhd}
vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_enc_input.vhd}
vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_enc_input_ram.vhd}

vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_enc_ast_block_sink.vhd}
vcom  -work work {../src/rtl/encoder/auk_dspip_ctc_umts_enc_ast_block_src.vhd}

vcom  -work work {auk_dspip_ctc_umts_enc_ast_src_model.vhd}
vcom  -work work {auk_dspip_ctc_umts_enc_ast_sink_model.vhd}
vcom  -work work {../../lib/models/avalon_streaming/auk_dspip_avalon_streaming_monitor.vhd}
vcom  -work work {tb_auk_dspip_ctc_umts_encoder_top.vhd}

vsim -novopt -t 1ps -L lpm -L altera -L altera_mf -L sgate -L stratixiii -L work work.tb_auk_dspip_ctc_umts_encoder_top
set StdArithNoWarnings  1
set NumericStdNoWarnings  1
if {[file exists wave_enc.do]} {
	source wave_enc.do
}
view structure
view signals
run -all
