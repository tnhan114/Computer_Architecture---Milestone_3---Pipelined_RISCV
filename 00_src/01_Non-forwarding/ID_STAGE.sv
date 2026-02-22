//**ID STAGE**
//imm generate
module imm_gen(
		input logic [31:0] i_inst,//inst_ID
		output logic [31:0] o_imm //imm_ID
);
		parameter I_type_layout = 7'b0010011;
		parameter I_type_load = 7'b0000011;
		parameter S_type = 7'b0100011;
		parameter B_type = 7'b1100011;
		parameter U_type = 7'b0110111;
		parameter J_type = 7'b1101111;
		parameter auipc = 7'b0010111;
		parameter Jalr = 7'b1100111;

		always_comb begin
						o_imm = 32'b0;
						case(i_inst[6:0])
								I_type_layout: begin
													o_imm[4:0] = i_inst[24:20];
													o_imm[10:5] = i_inst[30:25];
													o_imm[11] = i_inst[31];
													o_imm[31:12] = {20{i_inst[31]}};
													end
								S_type: begin
										  o_imm[4:0] = i_inst[11:7];
										  o_imm[10:5] = i_inst[30:25];
										  o_imm[31:12] = {20{i_inst[31]}};
										  end
								B_type: begin
										  o_imm[0] = 1'b0;
										  o_imm[4:1] = i_inst[11:8];
										  o_imm[10:5] = i_inst[30:25];
										  o_imm[11] = i_inst[7];
										  o_imm[31:12] = {20{i_inst[31]}};
										  end
								J_type: begin
										  o_imm[0] = 1'b0;
										  o_imm[4:1] = i_inst[24:21];
										  o_imm[10:5] = i_inst[30:25];
										  o_imm[11] = i_inst[20];
										  o_imm[19:12] = i_inst[19:12];
										  o_imm[31:20] = {12{i_inst[31]}};
										  end
								U_type: begin
										  o_imm[31:12] = i_inst[31:12];
										  o_imm[11:0] = 12'b0;
										  end
								I_type_load: begin
												 o_imm[11:0] = i_inst[31:20];
												 o_imm[31:12] = {20{i_inst[31]}};
												 end
								auipc: begin
										 o_imm[31:12] = i_inst[31:12];
										 o_imm[11:0] = 12'b0;
                               end
								Jalr: begin 
									   o_imm[11:0] = i_inst[31:20];
								      o_imm[31:12] = {20{i_inst[31]}};
										end
										default: o_imm[31:0] = 32'b0;
						endcase
						end
endmodule

//decoder cu
module cu_id (
	input logic [31:0]  inst_ID,       // mã lệnh 32-bit
	output logic        rd_wren_ID,     // 0: không cho phép ghi vào rd, 1: cho phép ghi
	output logic        br_un_ID,       // 0: so sánh có dấu, 1: so sánh không dấu
	output logic        opa_sel_ID,     // chọn toán hạng A của ALU (0: rs1, 1: PC)
	output logic        opb_sel_ID,     // Chọn toán hạng Bcuar ALU (0: rs2, 1: immediate)
	output logic [3:0]  alu_op_ID,      // chọn loại phép toán ALU (add, sub, and, or, v.v.)
	output logic        mem_wren_ID,    // 1: ghi bộ nhớ, 0: đọc bộ nhớ
	output logic [2:0]  type_sel_ID,    //  kiểu dữ liệu truy cập bộ nhớ::
                                 //   000: byte
                                 //   001: half word
                                 //   010: word
                                 //   100: byte unsigned
                                 //   101: half word unsigned
                                 //   111: reserved
	output logic [1:0]  wb_sel_ID, 	//  chọn dữ liệu ghi về register file:
                                 //   00: pc_4 (PC + 4)
                                 //   01: alu_data (kết quả từ ALU)
                                 //   10: ld_data (dữ liệu load từ memory)
	output logic is_branch_ID, is_jal_ID, is_jalr_ID, //nhan biet 3 loai lenh co anh huong den pc 
	output logic o_ctrl_ID,//nhan biet lnh jal, jalr, branch
	output logic is_ld_ID //nhan biet lenh load
);
	assign o_ctrl_ID = is_jal_ID | is_jalr_ID | is_branch_ID;
// tach opcode / funct3 / funct7
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;

	assign opcode = inst_ID[6:0];
	assign funct3 = inst_ID[14:12];
	assign funct7 = inst_ID[31:25];

// mac dinh cac tin hieu (reset cac tin hieu)
	always_comb begin
					rd_wren_ID  = 0;
					br_un_ID    = 0;
					opa_sel_ID  = 0;
					opb_sel_ID  = 0;
					alu_op_ID   = 4'b0000;
					mem_wren_ID = 0;
					type_sel_ID = 3'b111;
					wb_sel_ID   = 2'b11; //khong lam gi
					is_branch_ID = 1'b0;
					is_jal_ID = 1'b0;
					is_jalr_ID = 1'b0;
					is_ld_ID = 1'b0;
					
		case (opcode)

// R-format (add, sub, and, or, xor, sll, srl, sra, slt, sltu)
				7'b0110011: begin
								rd_wren_ID = 1;
								opa_sel_ID  = 0; opb_sel_ID = 0;
								mem_wren_ID = 0; wb_sel_ID  = 2'b01;
								case (funct3)
										3'b000: alu_op_ID = (funct7[5])? 4'b0001:4'b0000; // add hoac sub
										3'b010: alu_op_ID = 4'b0010; // slt
										3'b011: alu_op_ID = 4'b0011; // sltu
										3'b100: alu_op_ID = 4'b0100; // xor
										3'b110: alu_op_ID = 4'b0101; // or
										3'b111: alu_op_ID = 4'b0110; // and
										3'b001: alu_op_ID = 4'b0111; // sll
										3'b101: alu_op_ID = (funct7[5])? 4'b1001:4'b1000; // sra hoac srl
										default: alu_op_ID = 4'b1010;
								endcase
								end


// I-format layout (addi, andi, ori, xori, slti, sltiu, slli, srli, srai)
				7'b0010011: begin
								rd_wren_ID = 1;
								opa_sel_ID  = 0; opb_sel_ID = 1;
								mem_wren_ID = 0; wb_sel_ID  = 2'b01;
								case (funct3)
										3'b000: alu_op_ID = 4'b0000; // addi
										3'b010: alu_op_ID = 4'b0010; // slti
										3'b011: alu_op_ID = 4'b0011; // sltiu
										3'b100: alu_op_ID = 4'b0100; // xori
										3'b110: alu_op_ID = 4'b0101; // ori
										3'b111: alu_op_ID = 4'b0110; // andi
										3'b001: alu_op_ID = 4'b0111; // slli
										3'b101: alu_op_ID = (funct7[5])? 4'b1001:4'b1000; // srai hoac srli
										default: alu_op_ID = 4'b1111;         // nop
								endcase
								end 

// I- format: Load (lb, lh, lw, lbu, lhu)
					7'b0000011: begin
									rd_wren_ID = 1; is_ld_ID = 1'b1;
									opa_sel_ID  = 0; opb_sel_ID = 1;
									mem_wren_ID = 0; wb_sel_ID = 2'b10; 
									alu_op_ID = 4'b0000;
									case (funct3)
											3'b000:  type_sel_ID = 3'b000;
											3'b001:  type_sel_ID = 3'b001;
											3'b010:  type_sel_ID = 3'b010; 
											3'b100:  type_sel_ID = 3'b100;
											3'b101:  type_sel_ID = 3'b101; 
											default: type_sel_ID = 3'b111; //reserved 
									endcase 
									end

// S - format: Store (sb, sh, sw)
					7'b0100011: begin
									rd_wren_ID = 0;
									opa_sel_ID  = 0; opb_sel_ID = 1;
									mem_wren_ID = 1; wb_sel_ID = 2'b11; 
									alu_op_ID = 4'b0000;
									case (funct3)
											3'b000:  type_sel_ID = 3'b000;
											3'b001:  type_sel_ID = 3'b001;
											3'b010:  type_sel_ID = 3'b010; 
											default: type_sel_ID = 3'b111; //reserved 
									endcase 
									end

// B - format (beq, bne, blt, bge, bltu, bgeu)
					7'b1100011: begin
									rd_wren_ID = 0; is_branch_ID = 1;
									opa_sel_ID  = 1; opb_sel_ID = 1;
									mem_wren_ID = 0; wb_sel_ID = 2'b11; 
									alu_op_ID = 4'b0000;
									br_un_ID = funct3[1];  // 1: khÃ´ng dáº¥u (BLTU, BGEU); 0: cÃ³ dáº¥u (BLT, BGE)
									case (funct3)
											3'b000: type_sel_ID = 3'b000;
											3'b001: type_sel_ID = 3'b001;
											3'b100: type_sel_ID = 3'b100;
											3'b101: type_sel_ID = 3'b101; 
											3'b110: type_sel_ID = 3'b110;
											3'b111: type_sel_ID = 3'b111;
											default: type_sel_ID = 3'b111;
									endcase 
									end

// J - format (jal)
					7'b1101111: begin
									rd_wren_ID = 1; is_jal_ID = 1;
									opa_sel_ID  = 1; opb_sel_ID = 1;
									mem_wren_ID = 0; wb_sel_ID  = 2'b00; 
									alu_op_ID = 4'b0000;
									end

// U - format (lui)
					7'b0110111: begin
									rd_wren_ID = 1;
									opa_sel_ID  = 0; opb_sel_ID = 1;
									mem_wren_ID = 0; wb_sel_ID  = 2'b01; 
									alu_op_ID = 4'b1111; //nop: ko dÃ¹ng ALU 
									end

// U - format (auipc)
					7'b0010111: begin
									rd_wren_ID = 1;
									opa_sel_ID  = 1; opb_sel_ID = 1;
									mem_wren_ID = 0; wb_sel_ID  = 2'b01; 
									alu_op_ID = 4'b0000;
									end

// jalr
					7'b1100111: begin
									rd_wren_ID = 1; is_jalr_ID = 1;
									opa_sel_ID  = 0; opb_sel_ID = 1;
									mem_wren_ID = 0; wb_sel_ID  = 2'b00; 
									alu_op_ID = 4'b0000;
									end
           

					default: begin
								rd_wren_ID  = 0;
								end
					endcase
					end
endmodule


//regfile
module mux2_1_32bit(
	input logic  [31:0] a,
	input logic  [31:0] b,
	input logic sel,
	output logic  [31:0] c
	);
	assign c = sel? b:a;
endmodule


module mux32_1(
	input logic [4:0] sel,//chan select
	output logic [31:0] y, //ngo ra
	input logic [31:0] s0,	//ngo vao
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
	input logic [31:0] s16,
	input logic [31:0] s17,
	input logic [31:0] s18,
	input logic [31:0] s19,
	input logic [31:0] s20,
	input logic [31:0] s21,
	input logic [31:0] s22,
	input logic [31:0] s23,
	input logic [31:0] s24,
	input logic [31:0] s25,
	input logic [31:0] s26,
	input logic [31:0] s27,
	input logic [31:0] s28,
	input logic [31:0] s29,
	input logic [31:0] s30,
	input logic [31:0] s31
);
	logic [31:0] c0; //ngo ra tang 1
	logic [31:0] c1;
	logic [31:0] c2;
	logic [31:0] c3;
	logic [31:0] c4;
	logic [31:0] c5;
	logic [31:0] c6;
	logic [31:0] c7;
	logic [31:0] c8;
	logic [31:0] c9;
	logic [31:0] c10;
	logic [31:0] c11;
	logic [31:0] c12;
	logic [31:0] c13;
	logic [31:0] c14;
	logic [31:0] c15;
	//tang1; x_y: x la tang, y la con mux thu y trong tang x
	mux2_1_32bit mux1_0 (.a(s0), .b(s1), .sel(sel[0]), .c(c0));
	mux2_1_32bit mux1_1 (.a(s2), .b(s3), .sel(sel[0]), .c(c1));
	mux2_1_32bit mux1_2 (.a(s4), .b(s5), .sel(sel[0]), .c(c2));
	mux2_1_32bit mux1_3 (.a(s6), .b(s7), .sel(sel[0]), .c(c3));
	mux2_1_32bit mux1_4 (.a(s8), .b(s9), .sel(sel[0]), .c(c4));
	mux2_1_32bit mux1_5 (.a(s10), .b(s11), .sel(sel[0]), .c(c5));
	mux2_1_32bit mux1_6 (.a(s12), .b(s13), .sel(sel[0]), .c(c6));
	mux2_1_32bit mux1_7 (.a(s14), .b(s15), .sel(sel[0]), .c(c7));
	mux2_1_32bit mux1_8 (.a(s16), .b(s17), .sel(sel[0]), .c(c8));
	mux2_1_32bit mux1_9 (.a(s18), .b(s19), .sel(sel[0]), .c(c9));
	mux2_1_32bit mux1_10 (.a(s20), .b(s21), .sel(sel[0]), .c(c10));
	mux2_1_32bit mux1_11 (.a(s22), .b(s23), .sel(sel[0]), .c(c11));
	mux2_1_32bit mux1_12 (.a(s24), .b(s25), .sel(sel[0]), .c(c12));
	mux2_1_32bit mux1_13 (.a(s26), .b(s27), .sel(sel[0]), .c(c13));
	mux2_1_32bit mux1_14 (.a(s28), .b(s29), .sel(sel[0]), .c(c14));
	mux2_1_32bit mux1_15 (.a(s30), .b(s31), .sel(sel[0]), .c(c15));
	
	logic [31:0] d0; //ngo ra tang 2
	logic [31:0] d1;
	logic [31:0] d2;
	logic [31:0] d3;
	logic [31:0] d4;
	logic [31:0] d5;
	logic [31:0] d6;
	logic [31:0] d7;
	//tang 2; B hieu la tang 2 
	mux2_1_32bit muxB_1 (.a(c0), .b(c1), .sel(sel[1]), .c(d0));
	mux2_1_32bit muxB_2 (.a(c2), .b(c3), .sel(sel[1]), .c(d1));
	mux2_1_32bit muxB_3 (.a(c4), .b(c5), .sel(sel[1]), .c(d2));
	mux2_1_32bit muxB_4 (.a(c6), .b(c7), .sel(sel[1]), .c(d3));
	mux2_1_32bit muxB_5 (.a(c8), .b(c9), .sel(sel[1]), .c(d4));
	mux2_1_32bit muxB_6 (.a(c10), .b(c11), .sel(sel[1]), .c(d5));
	mux2_1_32bit muxB_7 (.a(c12), .b(c13), .sel(sel[1]), .c(d6));
	mux2_1_32bit muxB_8 (.a(c14), .b(c15), .sel(sel[1]), .c(d7)); 
	
	logic [31:0] e0; //ngo ra tang 3
	logic [31:0] e1;
	logic [31:0] e2;
	logic [31:0] e3;
	//tang3
	mux2_1_32bit mux3_1 (.a(d0), .b(d1), .sel(sel[2]), .c(e0));
	mux2_1_32bit mux3_2 (.a(d2), .b(d3), .sel(sel[2]), .c(e1));
	mux2_1_32bit mux3_3 (.a(d4), .b(d5), .sel(sel[2]), .c(e2));
	mux2_1_32bit mux3_4 (.a(d6), .b(d7), .sel(sel[2]), .c(e3));
	
	logic [31:0] f0;// ngo ra tang 4
	logic [31:0] f1;
	//tang 4
	mux2_1_32bit mux4_1 (.a(e0), .b(e1), .sel(sel[3]), .c(f0));
	mux2_1_32bit mux4_2 (.a(e2), .b(e3), .sel(sel[3]), .c(f1));
	
	//tang5 
	mux2_1_32bit mux5_1 (.a(f0), .b(f1), .sel(sel[4]), .c(y));
endmodule

module de2_4 (
    input  logic       a, b,
	 input  logic       en,
    output logic [3:0] y
);
    assign y[0] = ~a & ~b & en;
    assign y[1] = ~a &  b & en;
    assign y[2] =  a & ~b & en;
    assign y[3] =  a &  b & en;
endmodule

module de3_8 (
    input  logic       a, b, c,
	 input  logic       en,
    output logic [7:0] y
	 
);
    assign y[0] = ~a & ~b & ~c & en;
    assign y[1] = ~a & ~b &  c & en;
    assign y[2] = ~a &  b & ~c & en;
    assign y[3] = ~a &  b &  c & en;
    assign y[4] =  a & ~b & ~c & en;
    assign y[5] =  a & ~b &  c & en;
    assign y[6] =  a &  b & ~c & en;
    assign y[7] =  a &  b &  c & en;
endmodule

module decoder5_32 (
    input  logic [4:0] rsW,  // A,B,C,D,E (5 bit đầu vào)
    input  logic        en,  // enable tổng
    output logic [31:0] y    // 32 đầu ra
);

    // 4 tín hiệu enable từ decoder 2-to-4
    logic [3:0] en_3to8;

    // decoder 2-to-4: điều khiển enable cho 4 con 3-to-8
    de2_4 de (.a (rsW[4]), .b (rsW[3]), .en (en), .y (en_3to8));

    de3_8 de0 (.a (rsW[2]), .b (rsW[1]), .c (rsW[0]), .en(en_3to8[0]), .y(y[7:0]));
	 
	 de3_8 de1 (.a (rsW[2]), .b (rsW[1]), .c (rsW[0]), .en(en_3to8[1]), .y(y[15:8]));
	 
	 de3_8 de2 (.a (rsW[2]), .b (rsW[1]), .c (rsW[0]), .en(en_3to8[2]), .y(y[23:16]));
	 
	 de3_8 de3 (.a (rsW[2]), .b (rsW[1]), .c (rsW[0]), .en(en_3to8[3]), .y(y[31:24]));
endmodule
		
	//tạo d_ff có tín hiệu reset thap, cạnh len
module d_ff_rs(
	input logic D, clk, reset,
	output logic Q
);
	always_ff @(posedge clk) begin
		if (~reset)
			Q <= 1'b0;
		else 
			Q <= D;
	end
endmodule

	//tạo 1 thanh ghi
module reg_single(
	input logic [31:0] D,
	input logic CLK,
	input logic RST,
	input logic EN, //cho phép ghi
	output logic [31:0] Q
);
	logic [31:0] d_i;
	assign d_i = EN? D:Q; //nếu chưa ghi thì vẫn giữ giá trị cũ
	d_ff_rs ff0 (.D(d_i[0]), .clk(CLK), .reset(RST), .Q(Q[0]));
	d_ff_rs ff1 (.D(d_i[1]), .clk(CLK), .reset(RST), .Q(Q[1]));
	d_ff_rs ff2 (.D(d_i[2]), .clk(CLK), .reset(RST), .Q(Q[2]));
	d_ff_rs ff3 (.D(d_i[3]), .clk(CLK), .reset(RST), .Q(Q[3]));
	d_ff_rs ff4 (.D(d_i[4]), .clk(CLK), .reset(RST), .Q(Q[4]));
	d_ff_rs ff5 (.D(d_i[5]), .clk(CLK), .reset(RST), .Q(Q[5]));
	d_ff_rs ff6 (.D(d_i[6]), .clk(CLK), .reset(RST), .Q(Q[6]));
	d_ff_rs ff7 (.D(d_i[7]), .clk(CLK), .reset(RST), .Q(Q[7]));
	d_ff_rs ff8 (.D(d_i[8]), .clk(CLK), .reset(RST), .Q(Q[8]));
	d_ff_rs ff9 (.D(d_i[9]), .clk(CLK), .reset(RST), .Q(Q[9]));
	d_ff_rs ff10 (.D(d_i[10]), .clk(CLK), .reset(RST), .Q(Q[10]));
	d_ff_rs ff11 (.D(d_i[11]), .clk(CLK), .reset(RST), .Q(Q[11]));
	d_ff_rs ff12 (.D(d_i[12]), .clk(CLK), .reset(RST), .Q(Q[12]));
	d_ff_rs ff13 (.D(d_i[13]), .clk(CLK), .reset(RST), .Q(Q[13]));
	d_ff_rs ff14 (.D(d_i[14]), .clk(CLK), .reset(RST), .Q(Q[14]));
	d_ff_rs ff15 (.D(d_i[15]), .clk(CLK), .reset(RST), .Q(Q[15]));
	d_ff_rs ff16 (.D(d_i[16]), .clk(CLK), .reset(RST), .Q(Q[16]));
	d_ff_rs ff17 (.D(d_i[17]), .clk(CLK), .reset(RST), .Q(Q[17]));
	d_ff_rs ff18 (.D(d_i[18]), .clk(CLK), .reset(RST), .Q(Q[18]));
	d_ff_rs ff19 (.D(d_i[19]), .clk(CLK), .reset(RST), .Q(Q[19]));
	d_ff_rs ff20 (.D(d_i[20]), .clk(CLK), .reset(RST), .Q(Q[20]));
	d_ff_rs ff21 (.D(d_i[21]), .clk(CLK), .reset(RST), .Q(Q[21]));
	d_ff_rs ff22 (.D(d_i[22]), .clk(CLK), .reset(RST), .Q(Q[22]));
	d_ff_rs ff23 (.D(d_i[23]), .clk(CLK), .reset(RST), .Q(Q[23]));
	d_ff_rs ff24 (.D(d_i[24]), .clk(CLK), .reset(RST), .Q(Q[24]));
	d_ff_rs ff25 (.D(d_i[25]), .clk(CLK), .reset(RST), .Q(Q[25]));
	d_ff_rs ff26 (.D(d_i[26]), .clk(CLK), .reset(RST), .Q(Q[26]));
	d_ff_rs ff27 (.D(d_i[27]), .clk(CLK), .reset(RST), .Q(Q[27]));
	d_ff_rs ff28 (.D(d_i[28]), .clk(CLK), .reset(RST), .Q(Q[28]));
	d_ff_rs ff29 (.D(d_i[29]), .clk(CLK), .reset(RST), .Q(Q[29]));
	d_ff_rs ff30 (.D(d_i[30]), .clk(CLK), .reset(RST), .Q(Q[30]));
	d_ff_rs ff31 (.D(d_i[31]), .clk(CLK), .reset(RST), .Q(Q[31]));
endmodule

	//tạo băng thanh ghi
module register(
	input logic i_clk,               //xung clock
	input logic i_reset,					//tín hiệu reset
	input logic [4:0] i_rs1_addr,		//địa chỉ thanh ghi nguồn 1; rs1_ID
	input logic [4:0] i_rs2_addr,		//địa chỉ thanh ghi nguồn 2; rs2_ID
	output logic [31:0] o_rs1_data,	//data đọc ra từ thanh ghi nguồn 1; rs1_
	output logic [31:0] o_rs2_data,	//data đọc ra từ thanh ghi nguồn 2
	input logic [4:0] i_rd_addr,		//địa chỉ thanh ghi đích
	input logic [31:0] i_rd_data,		//dữ liệu cần ghi vào thanh ghi đích
	input logic i_rd_wren				//cho phép ghi dữ liệu vào thanh ghi đích
);
	//32 tín hiệu ghi
	logic [31:0] w_en;
	//giair mã địa chỉ cần ghi
	decoder5_32 decoder_write (.rsW(i_rd_addr), .en(i_rd_wren), .y(w_en));
	//chứa dữ liệu 32 thanh ghi
	logic [31:0] reg_data_0;
	logic [31:0] reg_data_1;
	logic [31:0] reg_data_2;
	logic [31:0] reg_data_3;
	logic [31:0] reg_data_4;
	logic [31:0] reg_data_5;
	logic [31:0] reg_data_6;
	logic [31:0] reg_data_7;
	logic [31:0] reg_data_8;
	logic [31:0] reg_data_9;
	logic [31:0] reg_data_10;
	logic [31:0] reg_data_11;
	logic [31:0] reg_data_12;
	logic [31:0] reg_data_13;
	logic [31:0] reg_data_14;
	logic [31:0] reg_data_15;
	logic [31:0] reg_data_16;
	logic [31:0] reg_data_17;
	logic [31:0] reg_data_18;
	logic [31:0] reg_data_19;
	logic [31:0] reg_data_20;
	logic [31:0] reg_data_21;
	logic [31:0] reg_data_22;
	logic [31:0] reg_data_23;
	logic [31:0] reg_data_24;
	logic [31:0] reg_data_25;
	logic [31:0] reg_data_26;
	logic [31:0] reg_data_27;
	logic [31:0] reg_data_28;
	logic [31:0] reg_data_29;
	logic [31:0] reg_data_30;
	logic [31:0] reg_data_31;
	//thanh ghi 0 luôn bằng 0
	assign reg_data_0 = 32'b0;
	//tao 31 thanh ghi 
	reg_single reg_1 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[1]), .Q(reg_data_1));
	reg_single reg_2 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[2]), .Q(reg_data_2));
	reg_single reg_3 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[3]), .Q(reg_data_3));
	reg_single reg_4 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[4]), .Q(reg_data_4));
	reg_single reg_5 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[5]), .Q(reg_data_5));
	reg_single reg_6 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[6]), .Q(reg_data_6));
	reg_single reg_7 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[7]), .Q(reg_data_7));
	reg_single reg_8 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[8]), .Q(reg_data_8));
	reg_single reg_9 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[9]), .Q(reg_data_9));
	reg_single reg_10 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[10]), .Q(reg_data_10));
	reg_single reg_11 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[11]), .Q(reg_data_11));
	reg_single reg_12 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[12]), .Q(reg_data_12));
	reg_single reg_13 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[13]), .Q(reg_data_13));
	reg_single reg_14 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[14]), .Q(reg_data_14));
	reg_single reg_15 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[15]), .Q(reg_data_15));
	reg_single reg_16 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[16]), .Q(reg_data_16));
	reg_single reg_17 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[17]), .Q(reg_data_17));
	reg_single reg_18 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[18]), .Q(reg_data_18));
	reg_single reg_19 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[19]), .Q(reg_data_19));
	reg_single reg_20 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[20]), .Q(reg_data_20));
	reg_single reg_21 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[21]), .Q(reg_data_21));
	reg_single reg_22 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[22]), .Q(reg_data_22));
	reg_single reg_23 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[23]), .Q(reg_data_23));
	reg_single reg_24 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[24]), .Q(reg_data_24));
	reg_single reg_25 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[25]), .Q(reg_data_25));
	reg_single reg_26 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[26]), .Q(reg_data_26));
	reg_single reg_27 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[27]), .Q(reg_data_27));
	reg_single reg_28 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[28]), .Q(reg_data_28));
	reg_single reg_29 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[29]), .Q(reg_data_29));
	reg_single reg_30 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[30]), .Q(reg_data_30));
	reg_single reg_31 (.D(i_rd_data), .CLK(i_clk), .RST(i_reset), .EN(w_en[31]), .Q(reg_data_31));
	 
	//2 mux32_1 de doc data
	logic [31:0] rs1_data_old, rs2_data_old;
	mux32_1 mux_rs1_ (.sel(i_rs1_addr), .y(rs1_data_old),
	.s0(reg_data_0), .s1(reg_data_1), .s2(reg_data_2), .s3(reg_data_3), .s4(reg_data_4), .s5(reg_data_5), .s6(reg_data_6), .s7(reg_data_7),
	.s8(reg_data_8), .s9(reg_data_9), .s10(reg_data_10), .s11(reg_data_11), .s12(reg_data_12), .s13(reg_data_13), .s14(reg_data_14), .s15(reg_data_15),
	.s16(reg_data_16), .s17(reg_data_17), .s18(reg_data_18), .s19(reg_data_19), .s20(reg_data_20), .s21(reg_data_21), .s22(reg_data_22), .s23(reg_data_23),
	.s24(reg_data_24), .s25(reg_data_25), .s26(reg_data_26), .s27(reg_data_27), .s28(reg_data_28), .s29(reg_data_29), .s30(reg_data_30), .s31(reg_data_31));
		
	mux32_1 mux_rs2_ (.sel(i_rs2_addr), .y(rs2_data_old),
	.s0(reg_data_0), .s1(reg_data_1), .s2(reg_data_2), .s3(reg_data_3), .s4(reg_data_4), .s5(reg_data_5), .s6(reg_data_6), .s7(reg_data_7),
	.s8(reg_data_8), .s9(reg_data_9), .s10(reg_data_10), .s11(reg_data_11), .s12(reg_data_12), .s13(reg_data_13), .s14(reg_data_14), .s15(reg_data_15),
	.s16(reg_data_16), .s17(reg_data_17), .s18(reg_data_18), .s19(reg_data_19), .s20(reg_data_20), .s21(reg_data_21), .s22(reg_data_22), .s23(reg_data_23),
	.s24(reg_data_24), .s25(reg_data_25), .s26(reg_data_26), .s27(reg_data_27), .s28(reg_data_28), .s29(reg_data_29), .s30(reg_data_30), .s31(reg_data_31));
	//
	logic eq_rs1, eq_rs2;
	compare_5bit cmpa (.a(i_rs1_addr), .b(i_rd_addr), .eq(eq_rs1));
	compare_5bit cmpb (.a(i_rs2_addr), .b(i_rd_addr), .eq(eq_rs2));
	logic rd_not_zero;
	assign rd_not_zero = |(i_rd_addr);
	//NGO RA
	assign o_rs1_data = (eq_rs1 & rd_not_zero & i_rd_wren)? i_rd_data : rs1_data_old;
	assign o_rs2_data = (eq_rs2 & rd_not_zero & i_rd_wren)? i_rd_data : rs2_data_old;
endmodule

//
module ID_EX(
	input logic i_clk, i_rst,
	input logic flush_ID_EX,
	//EX_ctrl
	input logic [3:0]  alu_op_ID,
	input logic opa_sel_ID,
	input logic opb_sel_ID,
	input logic br_un_ID,
	input logic is_branch_ID, is_jal_ID, is_jalr_ID,
	//EX ctrl va MEM ctrl
	input logic [2:0] type_sel_ID,
	//MEM_ctrl
	input logic mem_wren_ID,
	input logic is_ld_ID,
	//WB_ctrl
	input logic rd_wren_ID,
	input logic [1:0]  wb_sel_ID,
	//
	input logic [31:0] pc_ID,
	input logic [31:0] inst_ID,
	input logic [31:0] imm_ID,
	input logic [31:0] rs1_ID,
	input logic [31:0] rs2_ID,
	input logic insn_vld_ID,
	input logic o_ctrl_ID,
	///
	//EX_ctrl
	output logic [3:0]  alu_op_EX,
	output logic opa_sel_EX,
	output logic opb_sel_EX,
	output logic br_un_EX,
	output logic is_branch_EX, is_jal_EX, is_jalr_EX,
	//EX ctrl va MEM ctrl
	output logic [2:0] type_sel_EX,
	//MEM_ctrl
	output logic mem_wren_EX,
	output logic is_ld_EX,
	//WB_ctrl
	output logic rd_wren_EX,
	output logic [1:0]  wb_sel_EX,
	////
	output logic [31:0] pc_EX,
	output logic [31:0] inst_EX,
	output logic [31:0] imm_EX,
	output logic [31:0] rs1_EX,
	output logic [31:0] rs2_EX,
	output logic insn_vld_EX,
	output logic o_ctrl_EX
);
	always_ff @(posedge i_clk) begin
		if (~i_rst | flush_ID_EX) begin
			pc_EX <= 32'b0;
			inst_EX <= 32'b0;
			imm_EX <= 32'b0;
			rs1_EX <= 32'b0;
			rs2_EX <= 32'b0;
			wb_sel_EX <= 2'b0;
			rd_wren_EX <= 1'b0;
			mem_wren_EX <= 1'b0;
			type_sel_EX <= 3'b0;
			br_un_EX <= 1'b0;
			is_branch_EX <= 1'b0;
			is_jal_EX <= 1'b0;
			is_jalr_EX <= 1'b0;
			opb_sel_EX <= 1'b0;
			opa_sel_EX <= 1'b0;
			alu_op_EX <= 1'b0;
			insn_vld_EX <= 1'b0;
			is_ld_EX <= 1'b0;
			o_ctrl_EX <= 1'b0;
		end
		else begin
			pc_EX <= pc_ID;
			inst_EX <= inst_ID;
			imm_EX <= imm_ID;
			rs1_EX <= rs1_ID;
			rs2_EX <= rs2_ID;
			wb_sel_EX <= wb_sel_ID;
			rd_wren_EX <= rd_wren_ID;
			mem_wren_EX <= mem_wren_ID;
			type_sel_EX <= type_sel_ID;
			br_un_EX <= br_un_ID;
			is_branch_EX <= is_branch_ID;
			is_jal_EX <= is_jal_ID;
			is_jalr_EX <= is_jalr_ID;
			opb_sel_EX <= opb_sel_ID;
			opa_sel_EX <= opa_sel_ID;
			alu_op_EX <= alu_op_ID;
			insn_vld_EX <= insn_vld_ID;
			is_ld_EX <= is_ld_ID;
			o_ctrl_EX <= o_ctrl_ID;
		end
	end
endmodule
