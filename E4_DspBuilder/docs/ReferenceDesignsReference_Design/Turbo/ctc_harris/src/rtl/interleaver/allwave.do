onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/count
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/out_addr
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/rxc
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/addr_valid
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/seq_gen_done
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/start_load
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/enable
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/clk
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/reset
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/index
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/address_bin
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/itlv_bin
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/ditlv_bin
add wave -noupdate -divider -height 50 itlv
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/out_addr
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/rxc
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/blk_size
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/addr_valid
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/seq_gen_done
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/start_load
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/enable
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/clk
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/reset
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/blk_size_reg
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/count
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/max_count
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/rxc_int
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/msbs_and_lsbs
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/active
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/n_raw
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/n_exponent
add wave -noupdate -color gold -format Literal -itemcolor gold /tb_auk_dspip_ctc_umts2_itlv/dut/mult
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/table_out
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/five_lsbs
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/five_lsbs_delayed
add wave -noupdate -color gold -format Literal -itemcolor gold /tb_auk_dspip_ctc_umts2_itlv/dut/five_lsbs_br
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/msbs_plus_1_early
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/msbs_plus_1
add wave -noupdate -divider -height 50 LUT
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/n_exponent
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/five_lsbs
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/table_out
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/reset
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/enable
add wave -noupdate -format Logic /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/clk
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/n3_out
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/n4_out
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/n5_out
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/n6_out
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/n7_out
add wave -noupdate -format Literal /tb_auk_dspip_ctc_umts2_itlv/dut/auk_dspip_ctc_umtsitlv2_lut_inst/n8_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {110000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1897728 ps}
