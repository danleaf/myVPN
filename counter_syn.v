// megafunction wizard: %LPM_COUNTER%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_COUNTER 

// ============================================================
// File Name: counter.v
// Megafunction Name(s):
// 			LPM_COUNTER
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 10.1 Build 153 11/29/2010 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2010 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


//lpm_counter DEVICE_FAMILY="Cyclone II" lpm_direction="UP" lpm_port_updown="PORT_UNUSED" lpm_width=16 clock cnt_en q sclr
//VERSION_BEGIN 10.1 cbx_cycloneii 2010:11:29:22:18:02:SJ cbx_lpm_add_sub 2010:11:29:22:18:02:SJ cbx_lpm_compare 2010:11:29:22:18:02:SJ cbx_lpm_counter 2010:11:29:22:18:02:SJ cbx_lpm_decode 2010:11:29:22:18:02:SJ cbx_mgl 2010:11:29:22:19:52:SJ cbx_stratix 2010:11:29:22:18:02:SJ cbx_stratixii 2010:11:29:22:18:02:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = lut 16 reg 16 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  counter_cntr
	( 
	clock,
	cnt_en,
	q,
	sclr) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	input   cnt_en;
	output   [15:0]  q;
	input   sclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1   cnt_en;
	tri0   sclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_counter_comb_bita_0combout;
	wire  [0:0]   wire_counter_comb_bita_1combout;
	wire  [0:0]   wire_counter_comb_bita_2combout;
	wire  [0:0]   wire_counter_comb_bita_3combout;
	wire  [0:0]   wire_counter_comb_bita_4combout;
	wire  [0:0]   wire_counter_comb_bita_5combout;
	wire  [0:0]   wire_counter_comb_bita_6combout;
	wire  [0:0]   wire_counter_comb_bita_7combout;
	wire  [0:0]   wire_counter_comb_bita_8combout;
	wire  [0:0]   wire_counter_comb_bita_9combout;
	wire  [0:0]   wire_counter_comb_bita_10combout;
	wire  [0:0]   wire_counter_comb_bita_11combout;
	wire  [0:0]   wire_counter_comb_bita_12combout;
	wire  [0:0]   wire_counter_comb_bita_13combout;
	wire  [0:0]   wire_counter_comb_bita_14combout;
	wire  [0:0]   wire_counter_comb_bita_15combout;
	wire  [0:0]   wire_counter_comb_bita_0cout;
	wire  [0:0]   wire_counter_comb_bita_1cout;
	wire  [0:0]   wire_counter_comb_bita_2cout;
	wire  [0:0]   wire_counter_comb_bita_3cout;
	wire  [0:0]   wire_counter_comb_bita_4cout;
	wire  [0:0]   wire_counter_comb_bita_5cout;
	wire  [0:0]   wire_counter_comb_bita_6cout;
	wire  [0:0]   wire_counter_comb_bita_7cout;
	wire  [0:0]   wire_counter_comb_bita_8cout;
	wire  [0:0]   wire_counter_comb_bita_9cout;
	wire  [0:0]   wire_counter_comb_bita_10cout;
	wire  [0:0]   wire_counter_comb_bita_11cout;
	wire  [0:0]   wire_counter_comb_bita_12cout;
	wire  [0:0]   wire_counter_comb_bita_13cout;
	wire  [0:0]   wire_counter_comb_bita_14cout;
	wire  [15:0]   wire_counter_reg_bit1a_regout;
	wire  [15:0]   wire_counter_reg_bit1a_sdata;
	wire  aclr_actual;
	wire clk_en;
	wire [15:0]  data;
	wire  external_cin;
	wire  [15:0]  s_val;
	wire  [15:0]  safe_q;
	wire sload;
	wire sset;
	wire  updown_dir;

	cycloneii_lcell_comb   counter_comb_bita_0
	( 
	.cin(external_cin),
	.combout(wire_counter_comb_bita_0combout[0:0]),
	.cout(wire_counter_comb_bita_0cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[0:0]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_0.lut_mask = 16'h5A90,
		counter_comb_bita_0.sum_lutc_input = "cin",
		counter_comb_bita_0.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_1
	( 
	.cin(wire_counter_comb_bita_0cout[0:0]),
	.combout(wire_counter_comb_bita_1combout[0:0]),
	.cout(wire_counter_comb_bita_1cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[1:1]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_1.lut_mask = 16'h5A90,
		counter_comb_bita_1.sum_lutc_input = "cin",
		counter_comb_bita_1.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_2
	( 
	.cin(wire_counter_comb_bita_1cout[0:0]),
	.combout(wire_counter_comb_bita_2combout[0:0]),
	.cout(wire_counter_comb_bita_2cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[2:2]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_2.lut_mask = 16'h5A90,
		counter_comb_bita_2.sum_lutc_input = "cin",
		counter_comb_bita_2.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_3
	( 
	.cin(wire_counter_comb_bita_2cout[0:0]),
	.combout(wire_counter_comb_bita_3combout[0:0]),
	.cout(wire_counter_comb_bita_3cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[3:3]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_3.lut_mask = 16'h5A90,
		counter_comb_bita_3.sum_lutc_input = "cin",
		counter_comb_bita_3.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_4
	( 
	.cin(wire_counter_comb_bita_3cout[0:0]),
	.combout(wire_counter_comb_bita_4combout[0:0]),
	.cout(wire_counter_comb_bita_4cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[4:4]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_4.lut_mask = 16'h5A90,
		counter_comb_bita_4.sum_lutc_input = "cin",
		counter_comb_bita_4.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_5
	( 
	.cin(wire_counter_comb_bita_4cout[0:0]),
	.combout(wire_counter_comb_bita_5combout[0:0]),
	.cout(wire_counter_comb_bita_5cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[5:5]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_5.lut_mask = 16'h5A90,
		counter_comb_bita_5.sum_lutc_input = "cin",
		counter_comb_bita_5.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_6
	( 
	.cin(wire_counter_comb_bita_5cout[0:0]),
	.combout(wire_counter_comb_bita_6combout[0:0]),
	.cout(wire_counter_comb_bita_6cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[6:6]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_6.lut_mask = 16'h5A90,
		counter_comb_bita_6.sum_lutc_input = "cin",
		counter_comb_bita_6.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_7
	( 
	.cin(wire_counter_comb_bita_6cout[0:0]),
	.combout(wire_counter_comb_bita_7combout[0:0]),
	.cout(wire_counter_comb_bita_7cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[7:7]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_7.lut_mask = 16'h5A90,
		counter_comb_bita_7.sum_lutc_input = "cin",
		counter_comb_bita_7.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_8
	( 
	.cin(wire_counter_comb_bita_7cout[0:0]),
	.combout(wire_counter_comb_bita_8combout[0:0]),
	.cout(wire_counter_comb_bita_8cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[8:8]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_8.lut_mask = 16'h5A90,
		counter_comb_bita_8.sum_lutc_input = "cin",
		counter_comb_bita_8.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_9
	( 
	.cin(wire_counter_comb_bita_8cout[0:0]),
	.combout(wire_counter_comb_bita_9combout[0:0]),
	.cout(wire_counter_comb_bita_9cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[9:9]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_9.lut_mask = 16'h5A90,
		counter_comb_bita_9.sum_lutc_input = "cin",
		counter_comb_bita_9.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_10
	( 
	.cin(wire_counter_comb_bita_9cout[0:0]),
	.combout(wire_counter_comb_bita_10combout[0:0]),
	.cout(wire_counter_comb_bita_10cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[10:10]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_10.lut_mask = 16'h5A90,
		counter_comb_bita_10.sum_lutc_input = "cin",
		counter_comb_bita_10.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_11
	( 
	.cin(wire_counter_comb_bita_10cout[0:0]),
	.combout(wire_counter_comb_bita_11combout[0:0]),
	.cout(wire_counter_comb_bita_11cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[11:11]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_11.lut_mask = 16'h5A90,
		counter_comb_bita_11.sum_lutc_input = "cin",
		counter_comb_bita_11.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_12
	( 
	.cin(wire_counter_comb_bita_11cout[0:0]),
	.combout(wire_counter_comb_bita_12combout[0:0]),
	.cout(wire_counter_comb_bita_12cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[12:12]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_12.lut_mask = 16'h5A90,
		counter_comb_bita_12.sum_lutc_input = "cin",
		counter_comb_bita_12.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_13
	( 
	.cin(wire_counter_comb_bita_12cout[0:0]),
	.combout(wire_counter_comb_bita_13combout[0:0]),
	.cout(wire_counter_comb_bita_13cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[13:13]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_13.lut_mask = 16'h5A90,
		counter_comb_bita_13.sum_lutc_input = "cin",
		counter_comb_bita_13.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_14
	( 
	.cin(wire_counter_comb_bita_13cout[0:0]),
	.combout(wire_counter_comb_bita_14combout[0:0]),
	.cout(wire_counter_comb_bita_14cout[0:0]),
	.dataa(wire_counter_reg_bit1a_regout[14:14]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_14.lut_mask = 16'h5A90,
		counter_comb_bita_14.sum_lutc_input = "cin",
		counter_comb_bita_14.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_comb   counter_comb_bita_15
	( 
	.cin(wire_counter_comb_bita_14cout[0:0]),
	.combout(wire_counter_comb_bita_15combout[0:0]),
	.cout(),
	.dataa(wire_counter_reg_bit1a_regout[15:15]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_15.lut_mask = 16'h5A90,
		counter_comb_bita_15.sum_lutc_input = "cin",
		counter_comb_bita_15.lpm_type = "cycloneii_lcell_comb";
	cycloneii_lcell_ff   counter_reg_bit1a_0
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_0combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[0:0]),
	.sdata(wire_counter_reg_bit1a_sdata[0:0]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_1
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_1combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[1:1]),
	.sdata(wire_counter_reg_bit1a_sdata[1:1]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_2
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_2combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[2:2]),
	.sdata(wire_counter_reg_bit1a_sdata[2:2]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_3
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_3combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[3:3]),
	.sdata(wire_counter_reg_bit1a_sdata[3:3]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_4
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_4combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[4:4]),
	.sdata(wire_counter_reg_bit1a_sdata[4:4]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_5
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_5combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[5:5]),
	.sdata(wire_counter_reg_bit1a_sdata[5:5]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_6
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_6combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[6:6]),
	.sdata(wire_counter_reg_bit1a_sdata[6:6]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_7
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_7combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[7:7]),
	.sdata(wire_counter_reg_bit1a_sdata[7:7]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_8
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_8combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[8:8]),
	.sdata(wire_counter_reg_bit1a_sdata[8:8]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_9
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_9combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[9:9]),
	.sdata(wire_counter_reg_bit1a_sdata[9:9]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_10
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_10combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[10:10]),
	.sdata(wire_counter_reg_bit1a_sdata[10:10]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_11
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_11combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[11:11]),
	.sdata(wire_counter_reg_bit1a_sdata[11:11]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_12
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_12combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[12:12]),
	.sdata(wire_counter_reg_bit1a_sdata[12:12]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_13
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_13combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[13:13]),
	.sdata(wire_counter_reg_bit1a_sdata[13:13]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_14
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_14combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[14:14]),
	.sdata(wire_counter_reg_bit1a_sdata[14:14]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	cycloneii_lcell_ff   counter_reg_bit1a_15
	( 
	.aclr(aclr_actual),
	.clk(clock),
	.datain(wire_counter_comb_bita_15combout[0:0]),
	.ena((clk_en & (((sclr | sset) | sload) | cnt_en))),
	.regout(wire_counter_reg_bit1a_regout[15:15]),
	.sdata(wire_counter_reg_bit1a_sdata[15:15]),
	.sload(((sclr | sset) | sload)),
	.sclr(1'b0)
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	assign
		wire_counter_reg_bit1a_sdata = ({16{(~ sclr)}} & (({16{sset}} & s_val) | ({16{(~ sset)}} & data)));
	assign
		aclr_actual = 1'b0,
		clk_en = 1'b1,
		data = {16{1'b0}},
		external_cin = 1'b1,
		q = safe_q,
		s_val = {16{1'b1}},
		safe_q = wire_counter_reg_bit1a_regout,
		sload = 1'b0,
		sset = 1'b0,
		updown_dir = 1'b1;
endmodule //counter_cntr
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module counter (
	clock,
	cnt_en,
	sclr,
	q)/* synthesis synthesis_clearbox = 1 */;

	input	  clock;
	input	  cnt_en;
	input	  sclr;
	output	[15:0]  q;

	wire [15:0] sub_wire0;
	wire [15:0] q = sub_wire0[15:0];

	counter_cntr	counter_cntr_component (
				.clock (clock),
				.cnt_en (cnt_en),
				.sclr (sclr),
				.q (sub_wire0));

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ACLR NUMERIC "0"
// Retrieval info: PRIVATE: ALOAD NUMERIC "0"
// Retrieval info: PRIVATE: ASET NUMERIC "0"
// Retrieval info: PRIVATE: ASET_ALL1 NUMERIC "1"
// Retrieval info: PRIVATE: CLK_EN NUMERIC "0"
// Retrieval info: PRIVATE: CNT_EN NUMERIC "1"
// Retrieval info: PRIVATE: CarryIn NUMERIC "0"
// Retrieval info: PRIVATE: CarryOut NUMERIC "0"
// Retrieval info: PRIVATE: Direction NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone II"
// Retrieval info: PRIVATE: ModulusCounter NUMERIC "0"
// Retrieval info: PRIVATE: ModulusValue NUMERIC "0"
// Retrieval info: PRIVATE: SCLR NUMERIC "1"
// Retrieval info: PRIVATE: SLOAD NUMERIC "0"
// Retrieval info: PRIVATE: SSET NUMERIC "0"
// Retrieval info: PRIVATE: SSET_ALL1 NUMERIC "1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: PRIVATE: nBit NUMERIC "16"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_DIRECTION STRING "UP"
// Retrieval info: CONSTANT: LPM_PORT_UPDOWN STRING "PORT_UNUSED"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_COUNTER"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "16"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: cnt_en 0 0 0 0 INPUT NODEFVAL "cnt_en"
// Retrieval info: USED_PORT: q 0 0 16 0 OUTPUT NODEFVAL "q[15..0]"
// Retrieval info: USED_PORT: sclr 0 0 0 0 INPUT NODEFVAL "sclr"
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @cnt_en 0 0 0 0 cnt_en 0 0 0 0
// Retrieval info: CONNECT: @sclr 0 0 0 0 sclr 0 0 0 0
// Retrieval info: CONNECT: q 0 0 16 0 @q 0 0 16 0
// Retrieval info: GEN_FILE: TYPE_NORMAL counter.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL counter.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL counter.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL counter.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL counter_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL counter_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL counter_syn.v TRUE
// Retrieval info: LIB_FILE: lpm
