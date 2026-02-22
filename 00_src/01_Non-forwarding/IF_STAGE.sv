//**IF STAGE**
module mux_pc(
	input logic [31:0] a,
	input logic [31:0] b,
	input logic sel,
	output logic [31:0] pc_next
);
	assign pc_next = (sel)? b:a;
endmodule

module pc_4_if(
	input logic [31:0] pc_if,
	output logic [31:0] pc_4_if
);
	logic [31:0] c_o;
	
	fa fa0(.a(pc_if[0]), .b(1'b0), .c_i(1'b0), .s(pc_4_if[0]), .c_o(c_o[0]));
	fa fa1(.a(pc_if[1]), .b(1'b0), .c_i(c_o[0]), .s(pc_4_if[1]), .c_o(c_o[1]));
	fa fa2(.a(pc_if[2]), .b(1'b1), .c_i(c_o[1]), .s(pc_4_if[2]), .c_o(c_o[2]));
	fa fa3(.a(pc_if[3]), .b(1'b0), .c_i(c_o[2]), .s(pc_4_if[3]), .c_o(c_o[3]));
	fa fa4(.a(pc_if[4]), .b(1'b0), .c_i(c_o[3]), .s(pc_4_if[4]), .c_o(c_o[4]));
	fa fa5(.a(pc_if[5]), .b(1'b0), .c_i(c_o[4]), .s(pc_4_if[5]), .c_o(c_o[5]));
	fa fa6(.a(pc_if[6]), .b(1'b0), .c_i(c_o[5]), .s(pc_4_if[6]), .c_o(c_o[6]));
	fa fa7(.a(pc_if[7]), .b(1'b0), .c_i(c_o[6]), .s(pc_4_if[7]), .c_o(c_o[7]));
	fa fa8(.a(pc_if[8]), .b(1'b0), .c_i(c_o[7]), .s(pc_4_if[8]), .c_o(c_o[8]));
	fa fa9(.a(pc_if[9]), .b(1'b0), .c_i(c_o[8]), .s(pc_4_if[9]), .c_o(c_o[9]));
	fa fa10(.a(pc_if[10]), .b(1'b0), .c_i(c_o[9]), .s(pc_4_if[10]), .c_o(c_o[10]));
	fa fa11(.a(pc_if[11]), .b(1'b0), .c_i(c_o[10]), .s(pc_4_if[11]), .c_o(c_o[11]));
	fa fa12(.a(pc_if[12]), .b(1'b0), .c_i(c_o[11]), .s(pc_4_if[12]), .c_o(c_o[12]));
	fa fa13(.a(pc_if[13]), .b(1'b0), .c_i(c_o[12]), .s(pc_4_if[13]), .c_o(c_o[13]));
	fa fa14(.a(pc_if[14]), .b(1'b0), .c_i(c_o[13]), .s(pc_4_if[14]), .c_o(c_o[14]));
	fa fa15(.a(pc_if[15]), .b(1'b0), .c_i(c_o[14]), .s(pc_4_if[15]), .c_o(c_o[15]));
	fa fa16(.a(pc_if[16]), .b(1'b0), .c_i(c_o[15]), .s(pc_4_if[16]), .c_o(c_o[16]));
	fa fa17(.a(pc_if[17]), .b(1'b0), .c_i(c_o[16]), .s(pc_4_if[17]), .c_o(c_o[17]));
	fa fa18(.a(pc_if[18]), .b(1'b0), .c_i(c_o[17]), .s(pc_4_if[18]), .c_o(c_o[18]));
	fa fa19(.a(pc_if[19]), .b(1'b0), .c_i(c_o[18]), .s(pc_4_if[19]), .c_o(c_o[19]));
	fa fa20(.a(pc_if[20]), .b(1'b0), .c_i(c_o[19]), .s(pc_4_if[20]), .c_o(c_o[20]));
	fa fa21(.a(pc_if[21]), .b(1'b0), .c_i(c_o[20]), .s(pc_4_if[21]), .c_o(c_o[21]));
	fa fa22(.a(pc_if[22]), .b(1'b0), .c_i(c_o[21]), .s(pc_4_if[22]), .c_o(c_o[22]));
	fa fa23(.a(pc_if[23]), .b(1'b0), .c_i(c_o[22]), .s(pc_4_if[23]), .c_o(c_o[23]));
	fa fa24(.a(pc_if[24]), .b(1'b0), .c_i(c_o[23]), .s(pc_4_if[24]), .c_o(c_o[24]));
	fa fa25(.a(pc_if[25]), .b(1'b0), .c_i(c_o[24]), .s(pc_4_if[25]), .c_o(c_o[25]));
	fa fa26(.a(pc_if[26]), .b(1'b0), .c_i(c_o[25]), .s(pc_4_if[26]), .c_o(c_o[26]));
	fa fa27(.a(pc_if[27]), .b(1'b0), .c_i(c_o[26]), .s(pc_4_if[27]), .c_o(c_o[27]));
	fa fa28(.a(pc_if[28]), .b(1'b0), .c_i(c_o[27]), .s(pc_4_if[28]), .c_o(c_o[28]));
	fa fa29(.a(pc_if[29]), .b(1'b0), .c_i(c_o[28]), .s(pc_4_if[29]), .c_o(c_o[29]));
	fa fa30(.a(pc_if[30]), .b(1'b0), .c_i(c_o[29]), .s(pc_4_if[30]), .c_o(c_o[30]));
	fa fa31(.a(pc_if[31]), .b(1'b0), .c_i(c_o[30]), .s(pc_4_if[31]), .c_o(c_o[31]));
endmodule

//PC
module pc(
	input logic clk, rst, en,
	input logic [31:0] pc_next,
	output logic [31:0] pc_if
);
	always_ff @(posedge clk) begin
		if(~rst) begin
			pc_if <= 32'b0;
		end
		else if (en) begin
			pc_if <= pc_next;
		end
	end
endmodule

//imem 64kb
module imem (
    input logic clock,
    input logic [13:0] addr,//pc>>2
    output logic [31:0] q //inst_IF
);
    (* ramstyle = "M4K" *)
    // 64kb
	logic [31:0] imem [0:16383];
	 initial begin
	for (int i = 0; i < 16384; i++) begin

            imem[i] = 32'h00000000;

        end
        $readmemh("/home/yellow/ktmt_l01_l02_19/ktmt_l01_l02_19/milestone3/non-forwarding/02_test/isa_4b.hex", imem);
    end
    
    assign q = imem[addr];
endmodule

//reg pineline
module IF_ID(
	input logic i_clk, i_rst, 
	input logic flush_IF_ID, en_IF_ID,
	input logic [31:0] pc_IF,
	input logic [31:0] inst_IF,
	output logic [31:0] pc_ID,
	output logic [31:0] inst_ID,
	output logic insn_vld_ID
);
	always_ff @(posedge i_clk) begin
		if (~i_rst | flush_IF_ID) begin
			pc_ID <= 32'b0;
			inst_ID <= 32'b0;
			insn_vld_ID <= 1'b0;
		end
		else if (en_IF_ID) begin
			pc_ID <= pc_IF;
			inst_ID <= inst_IF;
			insn_vld_ID <= 1'b1;
		end
	end
endmodule
