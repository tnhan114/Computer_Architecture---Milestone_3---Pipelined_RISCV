//**MEM STAGE**
module pc4_mem(
	input logic [31:0] pc_MEM,
	output logic [31:0] pc4_MEM
);
	logic [31:0] c_o;
	
	fa fa0(.a(pc_MEM[0]), .b(1'b0), .c_i(1'b0), .s(pc4_MEM[0]), .c_o(c_o[0]));
	fa fa1(.a(pc_MEM[1]), .b(1'b0), .c_i(c_o[0]), .s(pc4_MEM[1]), .c_o(c_o[1]));
	fa fa2(.a(pc_MEM[2]), .b(1'b1), .c_i(c_o[1]), .s(pc4_MEM[2]), .c_o(c_o[2]));
	fa fa3(.a(pc_MEM[3]), .b(1'b0), .c_i(c_o[2]), .s(pc4_MEM[3]), .c_o(c_o[3]));
	fa fa4(.a(pc_MEM[4]), .b(1'b0), .c_i(c_o[3]), .s(pc4_MEM[4]), .c_o(c_o[4]));
	fa fa5(.a(pc_MEM[5]), .b(1'b0), .c_i(c_o[4]), .s(pc4_MEM[5]), .c_o(c_o[5]));
	fa fa6(.a(pc_MEM[6]), .b(1'b0), .c_i(c_o[5]), .s(pc4_MEM[6]), .c_o(c_o[6]));
	fa fa7(.a(pc_MEM[7]), .b(1'b0), .c_i(c_o[6]), .s(pc4_MEM[7]), .c_o(c_o[7]));
	fa fa8(.a(pc_MEM[8]), .b(1'b0), .c_i(c_o[7]), .s(pc4_MEM[8]), .c_o(c_o[8]));
	fa fa9(.a(pc_MEM[9]), .b(1'b0), .c_i(c_o[8]), .s(pc4_MEM[9]), .c_o(c_o[9]));
	fa fa10(.a(pc_MEM[10]), .b(1'b0), .c_i(c_o[9]), .s(pc4_MEM[10]), .c_o(c_o[10]));
	fa fa11(.a(pc_MEM[11]), .b(1'b0), .c_i(c_o[10]), .s(pc4_MEM[11]), .c_o(c_o[11]));
	fa fa12(.a(pc_MEM[12]), .b(1'b0), .c_i(c_o[11]), .s(pc4_MEM[12]), .c_o(c_o[12]));
	fa fa13(.a(pc_MEM[13]), .b(1'b0), .c_i(c_o[12]), .s(pc4_MEM[13]), .c_o(c_o[13]));
	fa fa14(.a(pc_MEM[14]), .b(1'b0), .c_i(c_o[13]), .s(pc4_MEM[14]), .c_o(c_o[14]));
	fa fa15(.a(pc_MEM[15]), .b(1'b0), .c_i(c_o[14]), .s(pc4_MEM[15]), .c_o(c_o[15]));
	fa fa16(.a(pc_MEM[16]), .b(1'b0), .c_i(c_o[15]), .s(pc4_MEM[16]), .c_o(c_o[16]));
	fa fa17(.a(pc_MEM[17]), .b(1'b0), .c_i(c_o[16]), .s(pc4_MEM[17]), .c_o(c_o[17]));
	fa fa18(.a(pc_MEM[18]), .b(1'b0), .c_i(c_o[17]), .s(pc4_MEM[18]), .c_o(c_o[18]));
	fa fa19(.a(pc_MEM[19]), .b(1'b0), .c_i(c_o[18]), .s(pc4_MEM[19]), .c_o(c_o[19]));
	fa fa20(.a(pc_MEM[20]), .b(1'b0), .c_i(c_o[19]), .s(pc4_MEM[20]), .c_o(c_o[20]));
	fa fa21(.a(pc_MEM[21]), .b(1'b0), .c_i(c_o[20]), .s(pc4_MEM[21]), .c_o(c_o[21]));
	fa fa22(.a(pc_MEM[22]), .b(1'b0), .c_i(c_o[21]), .s(pc4_MEM[22]), .c_o(c_o[22]));
	fa fa23(.a(pc_MEM[23]), .b(1'b0), .c_i(c_o[22]), .s(pc4_MEM[23]), .c_o(c_o[23]));
	fa fa24(.a(pc_MEM[24]), .b(1'b0), .c_i(c_o[23]), .s(pc4_MEM[24]), .c_o(c_o[24]));
	fa fa25(.a(pc_MEM[25]), .b(1'b0), .c_i(c_o[24]), .s(pc4_MEM[25]), .c_o(c_o[25]));
	fa fa26(.a(pc_MEM[26]), .b(1'b0), .c_i(c_o[25]), .s(pc4_MEM[26]), .c_o(c_o[26]));
	fa fa27(.a(pc_MEM[27]), .b(1'b0), .c_i(c_o[26]), .s(pc4_MEM[27]), .c_o(c_o[27]));
	fa fa28(.a(pc_MEM[28]), .b(1'b0), .c_i(c_o[27]), .s(pc4_MEM[28]), .c_o(c_o[28]));
	fa fa29(.a(pc_MEM[29]), .b(1'b0), .c_i(c_o[28]), .s(pc4_MEM[29]), .c_o(c_o[29]));
	fa fa30(.a(pc_MEM[30]), .b(1'b0), .c_i(c_o[29]), .s(pc4_MEM[30]), .c_o(c_o[30]));
	fa fa31(.a(pc_MEM[31]), .b(1'b0), .c_i(c_o[30]), .s(pc4_MEM[31]), .c_o(c_o[31]));
	
endmodule

//LSU
module demux1_10(
	input logic [31:0] i_lsu_addr,
	output logic s_mem, //select mem
	output logic s_rs1,
	output logic s_led_r,
	output logic s_led_g,
	output logic s_svsm_3_0,
	output logic s_svsm_7_4,
	output logic s_lcd,
	output logic s_rs2,
	output logic s_switch,
	output logic s_rs3
);
	assign s_mem = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
              (~i_lsu_addr[28]) & (~i_lsu_addr[27]) & (~i_lsu_addr[26]) &
              (~i_lsu_addr[25]) & (~i_lsu_addr[24]) & (~i_lsu_addr[23]) &
              (~i_lsu_addr[22]) & (~i_lsu_addr[21]) & (~i_lsu_addr[20]) &
              (~i_lsu_addr[19]) & (~i_lsu_addr[18]) & (~i_lsu_addr[17]) &
              (~i_lsu_addr[16]);
				  
	assign s_rs1 = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) & (~i_lsu_addr[28]) &
                 (i_lsu_addr[27] | i_lsu_addr[26] | i_lsu_addr[25] | i_lsu_addr[24] | 
                  i_lsu_addr[23] | i_lsu_addr[22] | i_lsu_addr[21] | i_lsu_addr[20] |
                  i_lsu_addr[19] | i_lsu_addr[18] | i_lsu_addr[17] | i_lsu_addr[16]);
						
	assign s_led_r = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) & 
                  i_lsu_addr[28] &
                 (~i_lsu_addr[27]) & (~i_lsu_addr[26]) & (~i_lsu_addr[25]) &
                 (~i_lsu_addr[24]) & (~i_lsu_addr[23]) & (~i_lsu_addr[22]) &
                 (~i_lsu_addr[21]) & (~i_lsu_addr[20]) & (~i_lsu_addr[19]) &
                 (~i_lsu_addr[18]) & (~i_lsu_addr[17]) & (~i_lsu_addr[16]) &
                 (~i_lsu_addr[15]) & (~i_lsu_addr[14]) & (~i_lsu_addr[13]) &
                 (~i_lsu_addr[12]);
	assign s_led_g = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) & 
                    i_lsu_addr[28] &
                   (~i_lsu_addr[27]) & (~i_lsu_addr[26]) & (~i_lsu_addr[25]) &
                   (~i_lsu_addr[24]) & (~i_lsu_addr[23]) & (~i_lsu_addr[22]) &
                   (~i_lsu_addr[21]) & (~i_lsu_addr[20]) & (~i_lsu_addr[19]) &
                   (~i_lsu_addr[18]) & (~i_lsu_addr[17]) & (~i_lsu_addr[16]) &
                   (~i_lsu_addr[15]) & (~i_lsu_addr[14]) & (~i_lsu_addr[13]) &
                    i_lsu_addr[12];
	assign s_svsm_3_0 = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) & 
                            i_lsu_addr[28] &
                           (~i_lsu_addr[27]) & (~i_lsu_addr[26]) & (~i_lsu_addr[25]) &
                           (~i_lsu_addr[24]) & (~i_lsu_addr[23]) & (~i_lsu_addr[22]) &
                           (~i_lsu_addr[21]) & (~i_lsu_addr[20]) & (~i_lsu_addr[19]) &
                           (~i_lsu_addr[18]) & (~i_lsu_addr[17]) & (~i_lsu_addr[16]) &
                           (~i_lsu_addr[15]) & (~i_lsu_addr[14]) &
                            i_lsu_addr[13] & (~i_lsu_addr[12]);
	assign s_svsm_7_4 = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) & 
                            i_lsu_addr[28] &
                           (~i_lsu_addr[27]) & (~i_lsu_addr[26]) & (~i_lsu_addr[25]) &
                           (~i_lsu_addr[24]) & (~i_lsu_addr[23]) & (~i_lsu_addr[22]) &
                           (~i_lsu_addr[21]) & (~i_lsu_addr[20]) & (~i_lsu_addr[19]) &
                           (~i_lsu_addr[18]) & (~i_lsu_addr[17]) & (~i_lsu_addr[16]) &
                           (~i_lsu_addr[15]) & (~i_lsu_addr[14]) &
                            i_lsu_addr[13] &  i_lsu_addr[12];
	assign s_lcd = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) & 
              i_lsu_addr[28] &
             (~i_lsu_addr[27]) & (~i_lsu_addr[26]) & (~i_lsu_addr[25]) &
             (~i_lsu_addr[24]) & (~i_lsu_addr[23]) & (~i_lsu_addr[22]) &
             (~i_lsu_addr[21]) & (~i_lsu_addr[20]) & (~i_lsu_addr[19]) &
             (~i_lsu_addr[18]) & (~i_lsu_addr[17]) & (~i_lsu_addr[16]) &
             (~i_lsu_addr[15]) &  i_lsu_addr[14] &
             (~i_lsu_addr[13]) & (~i_lsu_addr[12]);
	
	assign s_rs2 = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) & i_lsu_addr[28] &
                (~i_lsu_addr[27]) & (~i_lsu_addr[26]) & (~i_lsu_addr[25]) &
                (~i_lsu_addr[24]) & (~i_lsu_addr[23]) & (~i_lsu_addr[22]) &
                (~i_lsu_addr[21]) & (~i_lsu_addr[20]) & (~i_lsu_addr[19]) &
                (~i_lsu_addr[18]) & (~i_lsu_addr[17]) & (~i_lsu_addr[16]) &
                 ( i_lsu_addr[15] |
                   ( i_lsu_addr[14] & ( i_lsu_addr[13] | i_lsu_addr[12] ) ) );
			
	assign s_switch = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
                 i_lsu_addr[28] &
                (~i_lsu_addr[27]) & (~i_lsu_addr[26]) & (~i_lsu_addr[25]) &
                (~i_lsu_addr[24]) & (~i_lsu_addr[23]) & (~i_lsu_addr[22]) &
                (~i_lsu_addr[21]) & (~i_lsu_addr[20]) & (~i_lsu_addr[19]) &
                (~i_lsu_addr[18]) & (~i_lsu_addr[17]) &
                 i_lsu_addr[16] &
                (~i_lsu_addr[15]) & (~i_lsu_addr[14]) & (~i_lsu_addr[13]) & (~i_lsu_addr[12]);
	
	assign s_rs3 = ~(s_mem | s_rs1 | s_led_r | s_led_g | s_svsm_3_0 | s_svsm_7_4 | s_lcd | s_rs2 | s_switch);
endmodule
/////////////////
module dmem_dual_ip (
    input  logic        clock,
    input  logic        wren_a,
    input  logic [13:0]  address_a,
    input  logic [31:0] data_a,
    output logic [31:0] q_a,
    input  logic        wren_b,
    input  logic [13:0]  address_b,
    input  logic [31:0] data_b,
    output logic [31:0] q_b
);
		//64kb
    logic [31:0] dmem [0:16383];
    initial begin
	 for (int i = 0; i < 16384 ;i++) begin
			dmem[i] = 32'h00000000;
    end
        $readmemh("dmem_4b.hex", dmem);
    end
	
    // Ghi đồng bộ
    always_ff @(posedge clock) begin
            if (wren_a)
                dmem[address_a] <= data_a;
            if (wren_b)
                dmem[address_b] <= data_b;
        end

    // Đọc bất đồng bộ
    assign q_a = dmem[address_a];
    assign q_b = dmem[address_b];
endmodule
//
module dmem(
    input  logic         i_clk,
    input  logic         i_reset,
    input  logic         i_wren,
    input  logic [31:0]  i_addr,
    input  logic [31:0]  i_wdata,
    input  logic [2:0]   type_sel,
    output logic [31:0]  data_mem
);

    // -----------------------
    // Word addresses
    logic [13:0] addr_word;
	 assign addr_word = i_addr[15:2];
    logic [13:0] addr_word_next;
	 assign addr_word_next = addr_word + 1'b1;

    // -----------------------
    // Word data từ dual-port RAM
    logic [31:0] word0, word1;
    logic [63:0] data_2_w, data_2_w_new;

    assign data_2_w = {word1, word0};
	 
	  // Dual-port RAM 
    dmem_dual_ip ram_inst (
    .clock(i_clk),
    .wren_a(i_wren),
    .address_a(addr_word),
    .data_a(data_2_w_new[31:0]),
    .q_a(word0),
    .wren_b(i_wren),
    .address_b(addr_word_next),
    .data_b(data_2_w_new[63:32]),
    .q_b(word1)
	 );
	 
    // Ghi dữ liệu misaligned trước vào data_2_w_new
    always_comb begin
        data_2_w_new = data_2_w; 
							  case(type_sel)//ghi mem
									3'b010: begin case(i_addr[1:0])       //sw
															2'b00: data_2_w_new[31:0] = i_wdata;
															2'b01: data_2_w_new[39:8] = i_wdata;
															2'b10: data_2_w_new[47:16] = i_wdata;
															2'b11: data_2_w_new[55:24] = i_wdata;
													  endcase
											  end
									3'b001: begin case (i_addr[1:0])     //shw
															 2'b00: begin data_2_w_new[15:0] = i_wdata[15:0]; end
															 2'b01: begin data_2_w_new[23:8] = i_wdata[15:0]; end
															 2'b10: begin data_2_w_new[31:16] = i_wdata[15:0]; end
															 2'b11: begin data_2_w_new[39:24] = i_wdata[15:0]; end
			   									  endcase
											  end
									3'b000: begin case (i_addr[1:0])//sb
													       2'b00: begin data_2_w_new[7:0] = i_wdata[7:0];end//luu vo byte 0
															 2'b01: begin data_2_w_new[15:8] = i_wdata[7:0];end//luu vo byte 1
															 2'b10: begin data_2_w_new[23:16] = i_wdata[7:0];end//luu vo byte 2
															 2'b11: begin data_2_w_new[31:24] = i_wdata[7:0];end//luu vo byte 3
													  endcase
											  end
									default: data_2_w_new = data_2_w;
							  endcase
    end
    // -----------------------
    // Read misaligned
    always_comb begin
		case(type_sel)//mem
			3'b010: begin case(i_addr[1:0])									//lw
								2'b00: data_mem = data_2_w[31:0];
								2'b01: data_mem = data_2_w[39:8];
								2'b10: data_mem = data_2_w[47:16];
								2'b11: data_mem = data_2_w[55:24];
								endcase
					  end
			3'b001: begin case(i_addr[1:0])                           //lh
									2'b00: begin data_mem = {{16{data_2_w[15]}}, data_2_w[15:0]};end 
									2'b01: begin data_mem = {{16{data_2_w[23]}}, data_2_w[23:8]};end
									2'b10: begin data_mem = {{16{data_2_w[31]}}, data_2_w[31:16]};end
									2'b11: begin data_mem = {{16{data_2_w[39]}}, data_2_w[39:24]};end
					  endcase
					  end
			3'b000: begin case(i_addr[1:0])											//lb 
									2'b00: begin data_mem = {{24{data_2_w[7]}}, data_2_w[7:0]};end//lay byte 0
									2'b01: begin data_mem = {{24{data_2_w[15]}}, data_2_w[15:8]};end//lay byte 1
									2'b10: begin data_mem = {{24{data_2_w[23]}},data_2_w[23:16]};end//lay byte 2
									2'b11: begin data_mem = {{24{data_2_w[31]}},data_2_w[31:24]};end//lay byte 3	 
					        endcase
					  end
			3'b101: begin case(i_addr[1:0]) 										 //lhu
									2'b00: begin data_mem = {16'b0, data_2_w[15:0]};end 
									2'b01: begin data_mem = {16'b0, data_2_w[23:8]};end
									2'b10: begin data_mem = {16'b0, data_2_w[31:16]};end
									2'b11: begin data_mem = {16'b0, data_2_w[39:24]};end
					        endcase
					  end
			3'b100: begin case(i_addr[1:0])//lbu 
									2'b00: begin data_mem = {24'b0, data_2_w[7:0]};end//lay byte 0
									2'b01: begin data_mem = {24'b0, data_2_w[15:8]};end//lay byte 1
									2'b10: begin data_mem = {24'b0, data_2_w[23:16]};end//lay byte 2
									2'b11: begin data_mem = {24'b0, data_2_w[31:24]};end//lay byte 3	 
					        endcase
					  end
			default: begin data_mem =  data_2_w[31:0];end
		endcase
	end

endmodule


//chon data doc ra o_ld_data
module data_read(
	input logic [31:0] data_mem,
	input logic [31:0] data_rs1,//32'b0
	input logic [31:0] data_ledr,//led_r_reg
	input logic [31:0] data_ledg,//leg_g_reg
	input logic [31:0] data_svsm_3_0,//{1'b0, hex_reg[3], 1'b0, hex_reg[2], 1'b0, hex_reg[1],1'b0,hex_reg[0]}
	input logic [31:0] data_svsm_7_4,//{1'b0, hex_reg[7], 1'b0, hex_reg[6], 1'b0, hex_reg[5],1'b0,hex_reg[4]}
	input logic [31:0] data_lcd,//lcd_reg
	input logic [31:0] data_rs2,//32'b0
	input logic [31:0] data_switch,//input_buffer
	input logic [31:0] data_rs3,//32'b0
	input logic [9:0] select,//{mem ,r_ser1, led_red, led_green, seven_segment_3_0, seven_segment_7_4, lcd, r_ser2, switch, r_ser3}
	output logic [31:0] o_data
);
	always_comb begin
		if (select[9]) o_data = data_mem; 
		else if (select[8]) o_data = data_rs1;
			  else if (select[7]) o_data = data_ledr;
				    else if (select[6]) o_data = data_ledg;
				         else if (select[5]) o_data = data_svsm_3_0;
				              else if (select[4]) o_data = data_svsm_7_4;
				                   else if (select[3]) o_data = data_lcd;
				                        else if (select[2]) o_data = data_rs2;
				                             else if (select[1]) o_data = data_switch;
				                                  else if (select[0]) o_data = data_rs3;
				                                       else o_data =32'b0;
	end
endmodule

//chon ngo ra cuoi cho o_ld_data
module mux2_1(
	input logic i_reset,
	input logic [31:0] o_data,
	output logic [31:0] o_ld_data
);
	assign o_ld_data = (~i_reset)? 32'b0:o_data;
endmodule

module write_output_buffer(
	input logic i_reset,
	input logic i_clk,
	input logic [31:0] i_lsu_addr,
	input logic i_lsu_wren,
	input logic [31:0] i_io_sw,
	input logic led_red,
	input logic led_green,
	input logic lcd,
	input logic seven_segment_3_0,
	input logic seven_segment_7_4,
	input logic [31:0] i_st_data,
	output logic [31:0] input_buffer,
	output logic [31:0] led_r_reg, led_g_reg, lcd_reg,//output buffer
   output logic [6:0]  hex_reg [0:7]//output buffer
);
	always_ff @(posedge i_clk) begin
		if (~i_reset) begin
			led_r_reg <= 32'b0;
         led_g_reg <= 32'b0;
         lcd_reg <= 32'b0;
			input_buffer <= 32'b0;
			hex_reg[0] <= 7'b0;
			hex_reg[1] <= 7'b0;
			hex_reg[2] <= 7'b0;
			hex_reg[3] <= 7'b0;
			hex_reg[4] <= 7'b0;
			hex_reg[5] <= 7'b0;
			hex_reg[6] <= 7'b0;
			hex_reg[7] <= 7'b0;
		end
		else begin
			  input_buffer <= i_io_sw; 
			  if (i_lsu_wren) begin
									if (led_red) begin led_r_reg <= i_st_data;end//ghi ra led red
										  else if (led_green) begin led_g_reg <= i_st_data;end//ghi ra led green
												 else if (lcd) begin lcd_reg <= i_st_data;end//ghi ra lcd
														else if (seven_segment_3_0) begin //ghi ra led 7 doan 3:0
															  hex_reg[0] <= i_st_data[6:0];
															  hex_reg[1] <= i_st_data[14:8];
															  hex_reg[2] <= i_st_data[22:16];
															  hex_reg[3] <= i_st_data[30:24];
															  end
															  else if (seven_segment_7_4) begin//ghi ra led 7 doan 7:4
															  hex_reg[4] <= i_st_data[6:0];
															  hex_reg[5] <= i_st_data[14:8];
															  hex_reg[6] <= i_st_data[22:16];
															  hex_reg[7] <= i_st_data[30:24];
															  end
									end
			  end
	 end
endmodule

//lsu
module lsu2(
	input logic i_clk,
	input logic i_reset,
	input logic [31:0] i_lsu_addr,
	input logic [31:0] i_st_data,
	input logic i_lsu_wren,
	input logic [31:0] i_io_sw,
	input logic [2:0] type_sel,
	output logic [31:0] o_ld_data,
	output logic [31:0] o_io_ledr,
	output logic [31:0] o_io_ledg,
	output logic [31:0] o_io_lcd,
	output logic [6:0] o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7
);	
	logic [31:0] input_buffer;
	logic [31:0] led_r_reg, led_g_reg, lcd_reg;//output buffer
   logic [6:0]  hex_reg [0:7];//output buffer
	//giai ma dia chi
	logic mem, r_ser1, led_red, led_green, seven_segment_3_0, seven_segment_7_4, lcd, r_ser2, switch, r_ser3;
	demux1_10 giai_ma_addr(.i_lsu_addr(i_lsu_addr), .s_mem(mem), .s_rs1(r_ser1), .s_led_r(led_red), .s_led_g(led_green),
									.s_svsm_3_0(seven_segment_3_0), .s_svsm_7_4(seven_segment_7_4), .s_lcd(lcd), .s_rs2(r_ser2),
									.s_switch(switch), .s_rs3(r_ser3));
	//dmem
	logic i_wren;
	assign i_wren = mem & i_lsu_wren;
	logic [31:0] data_mem;
	dmem DMEM(.i_clk(i_clk), .i_reset(i_reset), .i_wren(i_wren), .i_addr(i_lsu_addr), .i_wdata(i_st_data),
				 .type_sel(type_sel), .data_mem(data_mem));
	//chon data doc
	logic [31:0] o_data;
	logic [9:0] select;//chon vung
	assign select = {mem ,r_ser1, led_red, led_green, seven_segment_3_0, seven_segment_7_4, lcd, r_ser2, switch, r_ser3};
	data_read data_read(.data_mem(data_mem), .data_rs1(32'b0), .data_ledr(led_r_reg), .data_ledg(led_g_reg),
							.data_svsm_3_0({1'b0, hex_reg[3], 1'b0, hex_reg[2], 1'b0, hex_reg[1],1'b0,hex_reg[0]}),
							.data_svsm_7_4({1'b0, hex_reg[7], 1'b0, hex_reg[6], 1'b0, hex_reg[5],1'b0,hex_reg[4]}),
							.data_lcd(lcd_reg), .data_rs2(32'b0), .data_switch(input_buffer), .data_rs3(32'b0), .select(select),
							.o_data(o_data));
	mux2_1 mux2_1(.i_reset(i_reset), .o_data(o_data), .o_ld_data(o_ld_data));
	//ghi vao output buffer
	write_output_buffer wr_output_buffer (.i_clk(i_clk), .i_reset(i_reset), .i_lsu_addr(i_lsu_addr), .i_lsu_wren(i_lsu_wren),
													  .i_io_sw(i_io_sw), .led_red(led_red), .led_green(led_green), .lcd(lcd),
													  .seven_segment_3_0(seven_segment_3_0), .seven_segment_7_4(seven_segment_7_4),
													  .i_st_data(i_st_data), .input_buffer(input_buffer), .led_r_reg(led_r_reg), .led_g_reg(led_g_reg),
													  .lcd_reg(lcd_reg), .hex_reg(hex_reg));
	//ngo ra ngoai vi
	assign o_io_ledr = led_r_reg;
   assign o_io_ledg = led_g_reg;
   assign o_io_lcd  = lcd_reg;
   assign o_io_hex0 = hex_reg[0];
   assign o_io_hex1 = hex_reg[1];
   assign o_io_hex2 = hex_reg[2];
   assign o_io_hex3 = hex_reg[3];
   assign o_io_hex4 = hex_reg[4];
   assign o_io_hex5 = hex_reg[5];
   assign o_io_hex6 = hex_reg[6];
   assign o_io_hex7 = hex_reg[7];
endmodule

//reg pineline
module MEM_WB(
	input logic i_clk, i_rst,
	//ngoai vi
	output logic [31:0] i_io_switch_MEM,
	input logic [31:0] o_io_ledr_MEM,
	input logic [31:0] o_io_ledg_MEM,
	input logic [6:0] o_io_hex0_MEM,
	input logic [6:0] o_io_hex1_MEM,
	input logic [6:0] o_io_hex2_MEM,
	input logic [6:0] o_io_hex3_MEM,
	input logic [6:0] o_io_hex4_MEM,
	input logic [6:0] o_io_hex5_MEM,
	input logic [6:0] o_io_hex6_MEM,
	input logic [6:0] o_io_hex7_MEM,
	input logic [31:0] o_io_lcd_MEM,
	//
	input logic [31:0] o_ld_data_MEM,
	input logic [31:0] pc4_MEM,//=pc_MEM +4
	input logic [31:0] inst_MEM,
	input logic [31:0] alu_result_MEM,
	input logic o_ctrl_MEM,
	input logic o_mispred_MEM,
	input logic [31:0] pc_MEM,
	input logic insn_vld_MEM,
	//WBctrl
	input logic rd_wren_MEM,
	input logic [1:0] wb_sel_MEM,
	///
	output logic [31:0] o_ld_data_WB,
	output logic [31:0] pc4_WB,
	output logic [31:0] inst_WB,
	output logic [31:0] alu_result_WB,
	output logic [31:0] pc_WB,
	output logic o_ctrl_WB,
	output logic o_mispred_WB,
	output logic insn_vld_WB,
	//WBctrl
	output logic rd_wren_WB,
	output logic [1:0] wb_sel_WB,
	//ngoai vi
	input logic [31:0] i_io_switch_WB,
	output logic [31:0] o_io_ledr_WB,
	output logic [31:0] o_io_ledg_WB,
	output logic [6:0] o_io_hex0_WB,
	output logic [6:0] o_io_hex1_WB,
	output logic [6:0] o_io_hex2_WB,
	output logic [6:0] o_io_hex3_WB,
	output logic [6:0] o_io_hex4_WB,
	output logic [6:0] o_io_hex5_WB,
	output logic [6:0] o_io_hex6_WB,
	output logic [6:0] o_io_hex7_WB,
	output logic [31:0] o_io_lcd_WB
);
	
	always_ff @(posedge i_clk) begin
		if (~i_rst) begin
			i_io_switch_MEM <= 32'b0;
			o_ld_data_WB <= 32'b0;
			pc4_WB <= 32'b0;
			inst_WB <= 32'b0;
			alu_result_WB <= 32'b0;
			pc_WB <= 32'b0;
			rd_wren_WB <= 1'b0;
			wb_sel_WB <= 2'b0;
			o_io_ledr_WB <= 32'b0;
			o_io_ledg_WB <= 32'b0;
			o_io_hex0_WB <= 7'b0;
			o_io_hex1_WB <= 7'b0;
			o_io_hex2_WB <= 7'b0;
			o_io_hex3_WB <= 7'b0;
			o_io_hex4_WB <= 7'b0;
			o_io_hex5_WB <= 7'b0;
			o_io_hex6_WB <= 7'b0;
			o_io_hex7_WB <= 7'b0;
			o_io_lcd_WB <= 32'b0;
			o_ctrl_WB <= 1'b0;
			o_mispred_WB <= 1'b0;
			insn_vld_WB <= 1'b0;
		end
		else begin
			i_io_switch_MEM <= i_io_switch_WB;
			o_ld_data_WB <= o_ld_data_MEM;
			pc4_WB <= pc4_MEM;
			inst_WB <= inst_MEM;
			alu_result_WB <= alu_result_MEM;
			pc_WB <= pc_MEM;
			rd_wren_WB <= rd_wren_MEM;
			wb_sel_WB <= wb_sel_MEM;
			o_io_ledr_WB <= o_io_ledr_MEM;
			o_io_ledg_WB <= o_io_ledg_MEM;
			o_io_hex0_WB <= o_io_hex0_MEM;
			o_io_hex1_WB <= o_io_hex1_MEM;
			o_io_hex2_WB <= o_io_hex2_MEM;
			o_io_hex3_WB <= o_io_hex3_MEM;
			o_io_hex4_WB <= o_io_hex4_MEM;
			o_io_hex5_WB <= o_io_hex5_MEM;
			o_io_hex6_WB <= o_io_hex6_MEM;
			o_io_hex7_WB <= o_io_hex7_MEM;
			o_io_lcd_WB <= o_io_lcd_MEM;
			o_ctrl_WB <= o_ctrl_MEM;
			o_mispred_WB <= o_mispred_MEM;
			insn_vld_WB <= insn_vld_MEM;
		end
	end
endmodule
