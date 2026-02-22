//hazard unit
module compare_5bit (
    input  logic [4:0] a,
    input  logic [4:0] b,
    output logic       eq
);
    logic [4:0] diff;
    assign diff = a ^ b; 
    // Nếu tất cả bit diff = 0 -> Hai số bằng nhau
    assign eq = ~(diff[0] | diff[1] | diff[2] | diff[3] | diff[4]);
endmodule

module hazard_unit(
	//kiem tra 2 thanh ghi nguon o id stage
	input logic [4:0] rs1_addr_ID,
	input logic [4:0] rs2_addr_ID,
	//kiem tra thanh ghi rd nao o cac stage sau
	input logic [4:0] rd_EX,
	input logic rd_wren_EX,
	
	input logic [4:0] rd_MEM,
	input logic rd_wren_MEM,
	
	//kiem tra pc taken
	input logic pc_taken_EX,
	
	//tin hieu flush stall
	output logic stall_PC,
	output logic stall_IF_ID,
	output logic flush_IF_ID,
	output logic flush_ID_EX
);
	// Cờ báo trùng địa chỉ (Match)
   logic match_rs1_ex, match_rs1_mem;
   logic match_rs2_ex, match_rs2_mem;
	
	// Cờ báo thanh ghi đích khác 0 (Vì x0 luôn = 0, không bao giờ gây Hazard)
   logic rd_ex_not_zero, rd_mem_not_zero;
	
	// Các tín hiệu phát hiện Hazard
   logic hazard_rs1, hazard_rs2;
   logic data_hazard;    // Có va chạm dữ liệu
   logic control_hazard; // Có lệnh nhảy
	
	// Kiểm tra RS1
   compare_5bit cmp1a (.a(rs1_addr_ID), .b(rd_EX),  .eq(match_rs1_ex));
   compare_5bit cmp1b (.a(rs1_addr_ID), .b(rd_MEM), .eq(match_rs1_mem));
    
    // Kiểm tra RS2
   compare_5bit cmp2a (.a(rs2_addr_ID), .b(rd_EX),  .eq(match_rs2_ex));
   compare_5bit cmp2b (.a(rs2_addr_ID), .b(rd_MEM), .eq(match_rs2_mem));
	
	//kiem tra rd = x0
	assign rd_ex_not_zero  = |(rd_EX);
   assign rd_mem_not_zero = |(rd_MEM);
	
	// Kiểm tra va chạm nguồn 1 (RS1) với cả 3 tầng (EX, MEM, WB)
   assign hazard_rs1 = (match_rs1_ex & rd_wren_EX & rd_ex_not_zero) |
                       (match_rs1_mem & rd_wren_MEM & rd_mem_not_zero);
	// Kiểm tra va chạm nguồn 2 (RS2) với cả 3 tầng (EX, MEM, WB)
   assign hazard_rs2 = (match_rs2_ex & rd_wren_EX & rd_ex_not_zero) |
                       (match_rs2_mem & rd_wren_MEM & rd_mem_not_zero);
							  
	//Chỉ cần dính 1 trong 2 nguồn là bị Hazard
   assign data_hazard = hazard_rs1 | hazard_rs2;
	
	//Xảy ra khi có lệnh nhảy (ở EX) 
	assign control_hazard = pc_taken_EX; 
	
	//Tin hieu dau ra, stall khi data_hazard, flush khi co lenh nhay va data hazard
	assign stall_PC = data_hazard & ~(control_hazard);
	assign stall_IF_ID = data_hazard & ~(control_hazard);
	assign flush_ID_EX = data_hazard | control_hazard;
	assign flush_IF_ID = control_hazard;
endmodule
