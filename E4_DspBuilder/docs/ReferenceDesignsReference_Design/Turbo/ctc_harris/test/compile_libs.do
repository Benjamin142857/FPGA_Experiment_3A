transcript on

#if [file exists ../compiled_libs] {
#	vdel -lib ../compiled_libs -all
#}

set compiled 0
set quartus_rootdir [file join $env(QUARTUS_ROOTDIR) eda sim_lib]

if {!$compiled} {
vlib ../compiled_libs/lpm
vmap lpm ../compiled_libs/lpm
vcom -work lpm [file join ${quartus_rootdir} 220pack.vhd]
vcom -work lpm [file join ${quartus_rootdir} 220model.vhd]

vlib ../compiled_libs/altera
vmap altera ../compiled_libs/altera
vcom -work altera [file join ${quartus_rootdir} altera_primitives_components.vhd]
vcom -work altera [file join ${quartus_rootdir} altera_primitives.vhd]

vlib ../compiled_libs/altera_mf
vmap altera_mf ../compiled_libs/altera_mf
vcom -work altera_mf [file join ${quartus_rootdir} altera_mf_components.vhd]
vcom -work altera_mf [file join ${quartus_rootdir} altera_mf.vhd]

vlib ../compiled_libs/sgate
vmap sgate ../compiled_libs/sgate
vcom -work sgate [file join ${quartus_rootdir} sgate_pack.vhd]
vcom -work sgate [file join ${quartus_rootdir} sgate.vhd]

vlib ../compiled_libs/stratixiii
vmap stratixiii ../compiled_libs/stratixiii
vcom -work stratixiii [file join ${quartus_rootdir} stratixiii_atoms.vhd]
vcom -work stratixiii [file join ${quartus_rootdir} stratixiii_components.vhd]


vlib ../compiled_libs/auk_dspip_lib
vmap auk_dspip_lib ../compiled_libs/auk_dspip_lib
vcom -work auk_dspip_lib {../../lib/packages/auk_dspip_math_pkg.vhd}
vcom -work auk_dspip_lib {../../lib/packages/auk_dspip_lib_pkg.vhd}
vcom -work auk_dspip_lib {../../lib/fu/delay/rtl/auk_dspip_delay.vhd}
vcom -work auk_dspip_lib {../../lib/fu/roundsat/rtl/auk_dspip_roundsat.vhd}
}

vlib ../compiled_libs/auk_dspip_ctc_umts_lib
vmap auk_dspip_ctc_umts_lib ../compiled_libs/auk_dspip_ctc_umts_lib
vcom -work auk_dspip_ctc_umts_lib {../src/rtl/auk_dspip_ctc_umts_lib_pkg.vhd}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib ../compiled_libs/rtl_work
vmap work ../compiled_libs/rtl_work

vcom -work work {../src/rtl/auk_dspip_ctc_umts_ram.vhd}

vcom -work work {../src/rtl/map/auk_dspip_ctc_umts_map_alpha.vhd}
vcom -work work {../src/rtl/map/auk_dspip_ctc_umts_map_beta.vhd}
vcom -work work {../src/rtl/map/auk_dspip_ctc_umts_map_gamma.vhd}
vcom -work work {../src/rtl/map/auk_dspip_ctc_umts_map_llr.vhd}
vcom -work work {../src/rtl/map/auk_dspip_ctc_umts_map_maxlogmap.vhd}
vcom -work work {../src/rtl/map/auk_dspip_ctc_umts_map_maxlogmap_pipelined.vhd}
vcom -work work {../src/rtl/map/auk_dspip_ctc_umts_map_constlogmap_pipelined.vhd}

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

vcom -work work {../src/rtl/input/auk_dspip_ctc_umts_itlvr_ram.vhd}
vcom -work work {../src/rtl/input/auk_dspip_ctc_umts_input.vhd}
vcom -work work {../src/rtl/input/auk_dspip_ctc_umts_input_ram.vhd}

vcom -work work {../src/rtl/output/auk_dspip_ctc_umts_out_mem.vhd}
vcom -work work {../src/rtl/output/auk_dspip_ctc_umts_output.vhd}

vcom -work work {../src/rtl/decoder/auk_dspip_ctc_umts_siso.vhd}
vcom -work work {../src/rtl/decoder/auk_dspip_ctc_umts_fifo.vhd}
vcom -work work {../src/rtl/decoder/auk_dspip_ctc_umts_map_decoder.vhd}
vcom -work work {../src/rtl/decoder/auk_dspip_ctc_umts_decoder_top.vhd}


vcom -work work {../src/rtl/ast/auk_dspip_ctc_umts_ast_sink.vhd}

vcom -work work {tb_auk_dspip_ctc_umts_decoder_top.vhd}
vcom -work work {auk_dspip_avalon_streaming_source_model.vhd}
vcom -work work {auk_dspip_avalon_streaming_sink_model.vhd}
vcom -work work {../../lib/models/avalon_streaming/auk_dspip_avalon_streaming_monitor.vhd}