//**EX STAGE**
//ALU
module mux16_1( //32bit
	input logic [31:0] s0,
	input logic [31:0] s1,
	input logic [31:0] s2,
	input logic [31:0] s3,
	input logic [31:0] s4,
	input logic [31:0] s5,
	input logic [31:0] s6,
	input logic [31:0] s7,
	input logic [31:0] s8,
	input logic [31:0] s9,
	input logic [31:0] s10,
	input logic [31:0] s11,
	input logic [31:0] s12,
	input logic [31:0] s13,
	input logic [31:0] s14,
	input logic [31:0] s15,
	output logic [31:0] y,
	input logic [3:0] sel
);
	//ngo ra tang 1
	logic [31:0] c0;
	logic [31:0] c1;
	logic [31:0] c2;
	logic [31:0] c3;
	logic [31:0] c4;
	logic [31:0] c5;
	logic [31:0] c6;
	logic [31:0] c7;
	//tang 1
	mux2_1_32bit mux1_0 (.a(s0), .b(s1), .sel(sel[0]), .c(c0));
	mux2_1_32bit mux1_1 (.a(s2), .b(s3), .sel(sel[0]), .c(c1));
	mux2_1_32bit mux1_2 (.a(s4), .b(s5), .sel(sel[0]), .c(c2));
	mux2_1_32bit mux1_3 (.a(s6), .b(s7), .sel(sel[0]), .c(c3));
	mux2_1_32bit mux1_4 (.a(s8), .b(s9), .sel(sel[0]), .c(c4));
	mux2_1_32bit mux1_5 (.a(s10), .b(s11), .sel(sel[0]), .c(c5));
	mux2_1_32bit mux1_6 (.a(s12), .b(s13), .sel(sel[0]), .c(c6));
	mux2_1_32bit mux1_7 (.a(s14), .b(s15), .sel(sel[0]), .c(c7));
	
	//ngo ta tang 2
	logic [31:0] d0;
	logic [31:0] d1;
	logic [31:0] d2;
	logic [31:0] d3;
	//tang 2
	mux2_1_32bit muxB_0 (.a(c0), .b(c1), .sel(sel[1]), .c(d0));
	mux2_1_32bit muxB_1 (.a(c2), .b(c3), .sel(sel[1]), .c(d1));
	mux2_1_32bit muxB_2 (.a(c4), .b(c5), .sel(sel[1]), .c(d2));
	mux2_1_32bit muxB_3 (.a(c6), .b(c7), .sel(sel[1]), .c(d3));
	
	//ngo ra tang 3
	logic [31:0] e0;
	logic [31:0] e1;
	//tang 3
	mux2_1_32bit mux3_1 (.a(d0), .b(d1), .sel(sel[2]), .c(e0));
	mux2_1_32bit mux3_2 (.a(d2), .b(d3), .sel(sel[2]), .c(e1));
	//tang 4
	mux2_1_32bit mux4_0 (.a(e0), .b(e1), .sel(sel[3]), .c(y));
endmodule

module fa(
		input logic a, b, c_i,
		output logic s, c_o
);
	assign s = a ^ b ^c_i;
	assign c_o = a&b | (a ^ b) & c_i;
endmodule

//

module fa_sub(
		input logic [3:0] i_alu_op,
		input logic [31:0] i_op_a,
		input logic [31:0] i_op_b,
		output logic [31:0] sum,
		output logic slt,
		output logic sltu
);
		//
		logic sub_en;
		assign sub_en = (~i_alu_op[3] & ~i_alu_op[2] & i_alu_op[1]) | (~i_alu_op[3] & ~i_alu_op[2] & ~i_alu_op[1] & i_alu_op[0]);
		//
		logic [31:0] i_op_b_sub;
		assign i_op_b_sub = sub_en? ~i_op_b:i_op_b;
		//
		logic [31:0] c;

		fa fa0 (.a(i_op_a[0]), .b(i_op_b_sub [0]), .c_i(sub_en), .s(sum[0]), .c_o(c[0]));
		//
		genvar i;
		generate for (i=1; i<32; i++) begin:
		fa_chain
		fa fa_inst(
		.a (i_op_a[i]),
		.b (i_op_b_sub[i]),
		.c_i (c[i-1]),
		.s (sum[i]),
		.c_o (c[i])
		);
		end
		endgenerate
		//
		assign sltu = ~c[31];
		assign slt = ~sum[31]&~c[30]&c[31] | ~sum[31]&c[30]&~c[31] | sum[31]&~c[30]&~c[31] | sum[31]&c[30]&c[31];
endmodule

//
module sll(
		input logic [31:0] i_op_a,
		input logic [4:0] i_op_b,
		output logic [31:0] sll
);
		logic [31:0] s0;
		logic [31:0] s1;
		logic [31:0] s2;
		logic [31:0] s3;
		logic [31:0] s4;
	
	always_comb begin
		//tang 1
		s0 = i_op_b[0]? {i_op_a[30:0], 1'b0} : i_op_a;
		//tang 2
		s1 = i_op_b[1]? {s0[29:0], 2'b0} : s0;
		//tang 3
		s2 = i_op_b[2]? {s1[27:0], 4'b0} : s1;
		//tang 4
		s3 = i_op_b[3]? {s2[23:0], 8'b0} : s2;
		//tang 5
		s4 = i_op_b[4]? {s3[15:0], 16'b0} : s3;
	end
	
		assign sll=s4;
endmodule

//
module srl(
		input logic [31:0] i_op_a,
		input logic [4:0] i_op_b,
		output logic [31:0] srl
);
		logic [31:0] s0;
		logic [31:0] s1;
		logic [31:0] s2;
		logic [31:0] s3;
		logic [31:0] s4;
		
	always_comb begin
		//tang 1
		s0 = i_op_b[0]? {1'b0, i_op_a[31:1]} : i_op_a;
		//tang 2
		s1 = i_op_b[1]? {2'b0, s0[31:2]} : s0;
		//tang 3
		s2 = i_op_b[2]? {4'b0, s1[31:4]} : s1;
		//tang 4
		s3 = i_op_b[3]? {8'b0, s2[31:8]} : s2;
		//tang 5
		s4 = i_op_b[4]? {16'b0, s3[31:16]} : s3;
	end
	
	assign srl = s4;
endmodule

//
module sra(
		input logic [31:0] i_op_a,
		input logic [4:0] i_op_b,
		output logic [31:0] sra
);
		logic [31:0] s0;
		logic [31:0] s1;
		logic [31:0] s2;
		logic [31:0] s3;
		logic [31:0] s4;
		
		always_comb begin
		//tang 1
		s0 = i_op_b[0]? {i_op_a[31], i_op_a[31:1]} : i_op_a;
		//tang 2
		s1 = i_op_b[1]? {{2{i_op_a[31]}}, s0[31:2]} : s0;
		//tang 3
		s2 = i_op_b[2]? {{4{i_op_a[31]}}, s1[31:4]} : s1;
		//tang 4
		s3 = i_op_b[3]? {{8{i_op_a[31]}}, s2[31:8]} : s2;
		//tang 5
		s4 = i_op_b[4]? {{16{i_op_a[31]}}, s3[31:16]} : s3;
	end
	
	assign sra = s4;
endmodule 


//
module shift_32bit(
	input logic [31:0] i_op_a,
	input logic [4:0] i_op_b,
	output logic [31:0] sll, srl, sra
);
	sll sll_32bit(.i_op_a(i_op_a), .i_op_b(i_op_b), .sll(sll));
	srl srl_32bit(.i_op_a(i_op_a), .i_op_b(i_op_b), .srl(srl));
	sra sra_32bit(.i_op_a(i_op_a), .i_op_b(i_op_b), .sra(sra));
endmodule

//
module or_gate (
		input logic [31:0] i_op_a,
		input logic [31:0] i_op_b,
		output logic [31:0] or_result
);
		assign or_result = i_op_a | i_op_b;
endmodule

//
module and_gate (
		input logic [31:0] i_op_a,
		input logic [31:0] i_op_b,
		output logic [31:0] and_result
);
		assign and_result = i_op_a & i_op_b;
endmodule

//
module xor_gate (
		input logic [31:0] i_op_a,
		input logic [31:0] i_op_b,
		output logic [31:0] xor_result
);
		assign xor_result = (~i_op_a & i_op_b) | (i_op_a & ~i_op_b);
endmodule

module logic_32bit(
	input logic [31:0] i_op_a,
	input logic [31:0] i_op_b,
	output logic [31:0] or_result, and_result, xor_result
);
	or_gate or_gate_32bit(.i_op_a(i_op_a), .i_op_b(i_op_b), .or_result(or_result));
	and_gate and_gate_32bit(.i_op_a(i_op_a), .i_op_b(i_op_b), .and_result(and_result));
	xor_gate xor_gate_32bit(.i_op_a(i_op_a), .i_op_b(i_op_b), .xor_result(xor_result));
endmodule

//
module alu(
		input logic [31:0] i_op_a,
		input logic [31:0] i_op_b,
		input logic [3:0] i_alu_op,
		output logic [31:0] o_alu_data
);
	
	//conng, tru, so sanh
	logic [31:0] sum;
	logic slt;
	logic sltu;
	fa_sub cong_tru_ss (.i_alu_op(i_alu_op), .i_op_a(i_op_a), .i_op_b(i_op_b), .sum(sum), .slt(slt), .sltu(sltu));
	
	//logic 32 bit
	logic [31:0] and_result;
	logic [31:0] or_result;
	logic [31:0] xor_result;
	logic_32bit logic_32bit (.i_op_a(i_op_a), .i_op_b(i_op_b), .and_result(and_result), .or_result(or_result), .xor_result(xor_result));
	
	//3 phep dich bit
	logic [31:0] sll;
	logic [31:0] srl;
	logic [31:0] sra;
	shift_32bit shift_32bit (.i_op_a(i_op_a), .i_op_b(i_op_b[4:0]), .sll(sll), .srl(srl), .sra(sra));
	
		
	//chon du lieu xuat
	mux16_1 mux_result (.s0(sum), .s1(sum), .s2({31'b0, slt}), .s3({31'b0, sltu}), .s4(xor_result),
								.s5(or_result), .s6(and_result), .s7(sll), .s8(srl), .s9(sra), .s10(32'b0),
								.s11(32'b0), .s12(32'b0), .s13(32'b0), .s14(32'b0), .s15(i_op_b),
								.y(o_alu_data), .sel(i_alu_op));	
endmodule

//brc
//equal
module equal(
	input logic [31:0] i_rs1_data,
	input logic [31:0] i_rs2_data,
	output logic o_br_equal
);
	//kiem tra bang
	logic [31:0] bang;
	assign bang = (~i_rs1_data & i_rs2_data) | (i_rs1_data & ~i_rs2_data); //cac bit giong nhau tung cap thi xor =0 
	assign o_br_equal = ~(|bang);
endmodule

//nho hon
module less(
	input logic [31:0] i_rs1_data,
	input logic [31:0] i_rs2_data,
	input logic i_br_un,
	output logic o_br_less
);
	logic sub_en;
	assign sub_en = 1'b1;
	logic [31:0] sum; //ket qua phep tru
	logic [31:0] c; //co nho cua phep tru tung cap bit
	logic less_unsigned;
	logic less_signed;
	fa fa0 (.a(i_rs1_data[0]), .b(~i_rs2_data[0]), .c_i(sub_en), .s(sum[0]), .c_o(c[0]));
   fa fa1 (.a(i_rs1_data[1]), .b(~i_rs2_data[1]), .c_i(c[0]), .s(sum[1]), .c_o(c[1]));
   fa fa2 (.a(i_rs1_data[2]), .b(~i_rs2_data[2]), .c_i(c[1]), .s(sum[2]), .c_o(c[2]));
   fa fa3 (.a(i_rs1_data[3]), .b(~i_rs2_data[3]), .c_i(c[2]), .s(sum[3]), .c_o(c[3]));
   fa fa4 (.a(i_rs1_data[4]), .b(~i_rs2_data[4]), .c_i(c[3]), .s(sum[4]), .c_o(c[4]));
   fa fa5 (.a(i_rs1_data[5]), .b(~i_rs2_data[5]), .c_i(c[4]), .s(sum[5]), .c_o(c[5]));
   fa fa6 (.a(i_rs1_data[6]), .b(~i_rs2_data[6]), .c_i(c[5]), .s(sum[6]), .c_o(c[6]));
   fa fa7 (.a(i_rs1_data[7]), .b(~i_rs2_data[7]), .c_i(c[6]), .s(sum[7]), .c_o(c[7]));
   fa fa8 (.a(i_rs1_data[8]), .b(~i_rs2_data[8]), .c_i(c[7]), .s(sum[8]), .c_o(c[8]));
   fa fa9 (.a(i_rs1_data[9]), .b(~i_rs2_data[9]), .c_i(c[8]), .s(sum[9]), .c_o(c[9]));
   fa fa10 (.a(i_rs1_data[10]), .b(~i_rs2_data[10]), .c_i(c[9]), .s(sum[10]), .c_o(c[10]));
   fa fa11 (.a(i_rs1_data[11]), .b(~i_rs2_data[11]), .c_i(c[10]), .s(sum[11]), .c_o(c[11]));
   fa fa12 (.a(i_rs1_data[12]), .b(~i_rs2_data[12]), .c_i(c[11]), .s(sum[12]), .c_o(c[12]));
   fa fa13 (.a(i_rs1_data[13]), .b(~i_rs2_data[13]), .c_i(c[12]), .s(sum[13]), .c_o(c[13]));
   fa fa14 (.a(i_rs1_data[14]), .b(~i_rs2_data[14]), .c_i(c[13]), .s(sum[14]), .c_o(c[14]));
   fa fa15 (.a(i_rs1_data[15]), .b(~i_rs2_data[15]), .c_i(c[14]), .s(sum[15]), .c_o(c[15]));
   fa fa16 (.a(i_rs1_data[16]), .b(~i_rs2_data[16]), .c_i(c[15]), .s(sum[16]), .c_o(c[16]));
   fa fa17 (.a(i_rs1_data[17]), .b(~i_rs2_data[17]), .c_i(c[16]), .s(sum[17]), .c_o(c[17]));
   fa fa18 (.a(i_rs1_data[18]), .b(~i_rs2_data[18]), .c_i(c[17]), .s(sum[18]), .c_o(c[18]));
   fa fa19 (.a(i_rs1_data[19]), .b(~i_rs2_data[19]), .c_i(c[18]), .s(sum[19]), .c_o(c[19]));
   fa fa20 (.a(i_rs1_data[20]), .b(~i_rs2_data[20]), .c_i(c[19]), .s(sum[20]), .c_o(c[20]));
   fa fa21 (.a(i_rs1_data[21]), .b(~i_rs2_data[21]), .c_i(c[20]), .s(sum[21]), .c_o(c[21]));
   fa fa22 (.a(i_rs1_data[22]), .b(~i_rs2_data[22]), .c_i(c[21]), .s(sum[22]), .c_o(c[22]));
   fa fa23 (.a(i_rs1_data[23]), .b(~i_rs2_data[23]), .c_i(c[22]), .s(sum[23]), .c_o(c[23]));
   fa fa24 (.a(i_rs1_data[24]), .b(~i_rs2_data[24]), .c_i(c[23]), .s(sum[24]), .c_o(c[24]));
   fa fa25 (.a(i_rs1_data[25]), .b(~i_rs2_data[25]), .c_i(c[24]), .s(sum[25]), .c_o(c[25]));
   fa fa26 (.a(i_rs1_data[26]), .b(~i_rs2_data[26]), .c_i(c[25]), .s(sum[26]), .c_o(c[26]));
   fa fa27 (.a(i_rs1_data[27]), .b(~i_rs2_data[27]), .c_i(c[26]), .s(sum[27]), .c_o(c[27]));
   fa fa28 (.a(i_rs1_data[28]), .b(~i_rs2_data[28]), .c_i(c[27]), .s(sum[28]), .c_o(c[28]));
   fa fa29 (.a(i_rs1_data[29]), .b(~i_rs2_data[29]), .c_i(c[28]), .s(sum[29]), .c_o(c[29]));
   fa fa30 (.a(i_rs1_data[30]), .b(~i_rs2_data[30]), .c_i(c[29]), .s(sum[30]), .c_o(c[30]));
   fa fa31 (.a(i_rs1_data[31]), .b(~i_rs2_data[31]), .c_i(c[30]), .s(sum[31]), .c_o(c[31]));
	
	assign less_unsigned = ~c[31];
	assign less_signed = ~sum[31]&~c[30]&c[31] | ~sum[31]&c[30]&~c[31] | sum[31]&~c[30]&~c[31] | sum[31]&c[30]&c[31];
	assign o_br_less = (i_br_un)? less_unsigned : less_signed;
endmodule


module brc(
	input logic [31:0] rs1_EX,
	input logic [31:0] rs2_EX,
	input logic br_un_EX,
	output logic br_less_EX,
	output logic br_equal_EX
	);
	//kiem tra bang
	equal kiem_tra_bang(.i_rs1_data(rs1_EX), .i_rs2_data(rs2_EX), .o_br_equal(br_equal_EX));

	//kiem tra nho hon 
	less kiem_tra_nho_hon(.i_rs1_data(rs1_EX), .i_rs2_data(rs2_EX), .i_br_un(br_un_EX), .o_br_less(br_less_EX));
endmodule
//branch unit
module branch_unit(
	input logic [2:0] type_sel_EX,
	input logic br_less_EX,
	input logic br_equal_EX,
	input logic is_jal_EX, is_jalr_EX, is_branch_EX,
	output logic pc_sel
);
	logic branch_taken;
	
	always_comb begin
		branch_taken = 1'b0;
		if (is_branch_EX) begin
			case (type_sel_EX)
				3'b000: branch_taken = br_equal_EX;  // beq
				3'b001: branch_taken = ~br_equal_EX; // bne
				3'b100: branch_taken = br_less_EX;   // blt
				3'b101: branch_taken = ~br_less_EX;  // bge
				3'b110: branch_taken = br_less_EX;   // bltu
				3'b111: branch_taken = ~br_less_EX;  // bgeu
				default: branch_taken = 1'b0;
			endcase
		end
	end
	
	assign pc_sel = branch_taken | is_jal_EX | is_jalr_EX;
endmodule 

//reg pineline
module EX_MEM(
	input logic i_clk, i_rst,
	input logic pc_taken_EX,//=pc_sel de tao tin hieu cho o_mispred
	///
	input logic [31:0] pc_EX,
	input logic [31:0] inst_EX,
	input logic [31:0] alu_result_EX,
	input logic [31:0] rs2_EX,
	input logic o_ctrl_EX,
	input logic insn_vld_EX,
	//MEMctrl
	input logic [2:0] type_sel_EX,
	input logic mem_wren_EX,
	input logic is_ld_EX,
	//WBctrl
	input logic rd_wren_EX,
	input logic [1:0] wb_sel_EX,
	///
	output logic [31:0] pc_MEM,
	output logic [31:0] inst_MEM,
	output logic [31:0] alu_result_MEM,
	output logic [31:0] rs2_MEM,
	output logic o_ctrl_MEM,
	output logic insn_vld_MEM,
	output logic o_mispred_MEM,
	//MEMctrl
	output logic [2:0] type_sel_MEM,
	output logic mem_wren_MEM,
	output logic is_ld_MEM,
	//WBctrl
	output logic rd_wren_MEM,
	output logic [1:0] wb_sel_MEM
);
	always_ff @(posedge i_clk) begin
		if (~i_rst) begin
			pc_MEM <= 32'b0;
			inst_MEM <= 32'b0;
			alu_result_MEM <= 32'b0;
			rs2_MEM <= 32'b0;
			o_ctrl_MEM <= 1'b0;
			type_sel_MEM <= 3'b0;
			mem_wren_MEM <= 1'b0;
			is_ld_MEM <= 1'b0;
			rd_wren_MEM <= 1'b0;
			wb_sel_MEM <= 2'b11;
			insn_vld_MEM <= 1'b0;
			o_mispred_MEM <= 1'b0;
		end
		else begin
			pc_MEM <= pc_EX;
			inst_MEM <= inst_EX;
			alu_result_MEM <= alu_result_EX;
			rs2_MEM <= rs2_EX;
			o_ctrl_MEM <= o_ctrl_EX;
			type_sel_MEM <= type_sel_EX;
			mem_wren_MEM <= mem_wren_EX;
			is_ld_MEM <= is_ld_EX;
			rd_wren_MEM <= rd_wren_EX;
			wb_sel_MEM <= wb_sel_EX;
			insn_vld_MEM <= insn_vld_EX;
			o_mispred_MEM <= pc_taken_EX;
		end
	end
endmodule
