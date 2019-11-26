//                                                                                     
// DSP Builder (Version 11.0)
// Quartus II development tool and MATLAB/Simulink Interface                           
//                                                                                     
// Copyright © 2001-2011 Altera Corporation. All rights reserved.                      
//                                                                                     
// The DSP Builder software, including, without limitation, the clock-cycle limited    
// versions of the MegaCore© Logic Functions included therein, may only be used to     
// develop designs for programmable logic devices manufactured by Altera Corporation   
// and sold by Altera Corporation and its authorized distributors. IN NO EVENT MAY     
// SUCH SOFTWARE AND FUNCTIONS BE USED TO PROGRAM ANY PROGRAMMABLE LOGIC DEVICES, FIELD
// PROGRAMMABLE GATE ARRAYS, ASICS, STANDARD PRODUCTS, OR ANY OTHER SEMICONDUCTOR      
// DEVICE MANUFACTURED BY ANY COMPANY OR ENTITY OTHER THAN ALTERA.  For the complete   
// terms and conditions applicable to your use of the software and functions, please   
// refer to the Altera Program License directory                                       

module hilaltr_node
(
    output debug_clk,
    output reg debug_reset,
    
    output reg [DOWN_WIDTH-1:0] inputs,
    input  [UP_WIDTH-1:0]       outputs,
    output                      run_test
);

parameter DESIGN_STAMP = 0;
parameter DOWN_WIDTH = 8;
parameter UP_WIDTH   = 8;

localparam N_NODE_IR_BITS = 24;
localparam DATA_WIDTH = ((DOWN_WIDTH > UP_WIDTH ? DOWN_WIDTH : UP_WIDTH) + 1 + 7) & ~7;
localparam LOG2_WIDTH = $clog2(DATA_WIDTH);

wire [LOG2_WIDTH-1:0] max_data_width = DATA_WIDTH[LOG2_WIDTH-1:0] + { LOG2_WIDTH {1'b1} };

///////////////////////////////////////////////////////////////
// Internal Virtual JTAG Controller Signals
wire    tck;
wire    tdi;                // JTAG test data input (shared)
wire    tdo;                // Node i JTAG test data out
wire    test_logic_reset;
wire    update_vir;
wire    capture_dr;
wire    shift_dr;
wire    update_dr;

wire    [N_NODE_IR_BITS-1 : 0] ir_in; // Node IR

wire                             data_scan;
wire                             reset_scan;
wire                             setup_scan;
wire                             config_scan;

reg     [4:0]                    rom_index;
reg     [3:0]                    rom_data;

reg                              reset_strobe;

reg     [$clog2(DATA_WIDTH)-1:0] down_start;

reg     [$clog2(DATA_WIDTH)-1:0] up_count;
reg     [DATA_WIDTH-1:0]         sld_shift;

reg     [$clog2(DATA_WIDTH)-1:0] down_count;
reg     [DATA_WIDTH-1:0]         down_shift;
reg     [DOWN_WIDTH-1:0]         next_down;

reg                              in_strobe;
reg                              out_strobe;
reg                              run_strobe;

reg                              gotup;
reg     [UP_WIDTH-1:0]           up;

///////////////////////////////////////////////////////////////

sld_virtual_jtag_basic #(
	.sld_mfg_id(110),
	.sld_type_id(6),
	.sld_version(1),
	.sld_auto_instance_index("YES"),
	.sld_instance_index(0),
	.sld_ir_width(N_NODE_IR_BITS),
	.sld_sim_action(""),
	.sld_sim_n_scan(0),
	.sld_sim_total_length(0)
) sld_virtual_jtag_component (
	.tck (tck),
	.tms (),
	.tdi (tdi),
	.tdo (tdo),

	.ir_in (ir_in),
	.ir_out (DESIGN_STAMP),

	.virtual_state_cir (),
	.virtual_state_pdr (),
	.virtual_state_uir (update_vir),
	.virtual_state_sdr (shift_dr),
	.virtual_state_cdr (capture_dr),
	.virtual_state_udr (update_dr),
	.virtual_state_e1dr (),
	.virtual_state_e2dr (),
	
	.jtag_state_cdr (),
	.jtag_state_cir (),
	.jtag_state_e1dr (),
	.jtag_state_e1ir (),
	.jtag_state_e2dr (),
	.jtag_state_e2ir (),
	.jtag_state_pdr (),
	.jtag_state_pir (),
	.jtag_state_sdr  (),
	.jtag_state_sdrs (),
	.jtag_state_sir (),
	.jtag_state_sirs (),
	.jtag_state_tlr (test_logic_reset),
	.jtag_state_udr (),
	.jtag_state_uir ()
);

assign debug_clk = tck;

assign data_scan   = (ir_in[1:0] == 0);
assign reset_scan  = (ir_in[1:0] == 1);
assign setup_scan  = (ir_in[1:0] == 2);
assign config_scan = (ir_in[1:0] == 3);

always @(rom_index)
	case (rom_index)
		0: rom_data = 4'hE;
		1: rom_data = 4'h6;
		2: rom_data = DESIGN_STAMP[3:0];
		3: rom_data = DESIGN_STAMP[7:4];
		4: rom_data = DESIGN_STAMP[11:8];
		5: rom_data = DESIGN_STAMP[15:12];
		6: rom_data = DESIGN_STAMP[19:16];
		7: rom_data = DESIGN_STAMP[23:20];
		8: rom_data = DESIGN_STAMP[27:24];
		9: rom_data = DESIGN_STAMP[31:28];
		10: rom_data = DOWN_WIDTH[3:0];
		11: rom_data = DOWN_WIDTH[7:4];
		12: rom_data = DOWN_WIDTH[11:8];
		13: rom_data = DOWN_WIDTH[15:12];
		14: rom_data = UP_WIDTH[3:0];
		15: rom_data = UP_WIDTH[7:4];
		16: rom_data = DOWN_WIDTH[11:8];
		17: rom_data = DOWN_WIDTH[15:12];
		default: rom_data = 0;
	endcase

always @(posedge tck)
begin
	in_strobe <= 0;
	reset_strobe <= 0;

	if (capture_dr)
	begin
		up_count   <= max_data_width;
		down_count <= down_start;
		gotup      <= 0;
		
		down_shift <= 0;
		sld_shift <= 0;
		if (config_scan)
			sld_shift[3:0] <= rom_data;
		
	end
	else if (shift_dr && data_scan)
	begin
		if (down_count == 0)
			down_count <= max_data_width;
		else
			down_count <= down_count /* -1 */ + { LOG2_WIDTH {1'b1} };

		if (up_count == 0)
			up_count <= max_data_width;
		else
			up_count <= up_count + { LOG2_WIDTH {1'b1} };

		if (down_count == 0)
		begin
			next_down <= down_shift[DOWN_WIDTH-1:0];
			in_strobe <= down_shift[DATA_WIDTH-1];
		end
		down_shift  <= { tdi, down_shift[DATA_WIDTH-1:1] };

		if (up_count == 0)
		begin
			sld_shift <= 0;
			sld_shift[DATA_WIDTH-1] <= gotup; 
			sld_shift[UP_WIDTH-1:0] <= up;
			gotup <= 0;
		end
		else
		begin
			sld_shift <= { tdi, sld_shift[DATA_WIDTH-1:1] };
		end
	end
	else if (shift_dr && setup_scan)
	begin
		sld_shift[$clog2(DATA_WIDTH)-1:0] <= { tdi, sld_shift[$clog2(DATA_WIDTH)-1:1] };
	end
	else if (shift_dr && config_scan)
	begin
		sld_shift[3:0] <= { tdi, sld_shift[3:1] };
	end
	else if (update_dr && setup_scan)
	begin
		down_start <= sld_shift[$clog2(DATA_WIDTH)-1:0];
	end
	else if (test_logic_reset)
	begin
		down_start <= 0; // If host does not set an offset then use 0, the most common case
	end
			
	if (update_vir)
		rom_index <= 0;
	else if (update_dr && config_scan)
		rom_index <= rom_index - {5{1'b1}};

	if (update_vir)
	begin
		debug_reset <= reset_scan;
		if (reset_scan)
			reset_strobe <= 1;
	end
		
	out_strobe <= in_strobe | reset_strobe;
	run_strobe <= out_strobe;

	if (in_strobe)
	begin
		up <= outputs;
		gotup <= 1;
	end

	if (out_strobe)
	begin
		inputs <= next_down;
	end
end

assign tdo = sld_shift[0];
assign run_test = run_strobe;

endmodule

