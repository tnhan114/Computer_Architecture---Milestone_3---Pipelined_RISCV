//hazard_unit
module hazard_unit(
	input logic mispredict_EX, //=mispredict
	input logic is_ld_EX,
	input logic [4:0] rd_EX,
	input logic [4:0] rs1_addr_ID,
	input logic [4:0] rs2_addr_ID,
	//lenh load
	output logic stall_PC,
	output logic stall_IF_ID,
	output logic flush_ID_EX,
	//lenh nhay brc, jal, jalr
	output logic flush_IF_ID	
);
	// Các tín hiệu phát hiện Hazard
   logic hazard_rs1, hazard_rs2;
   logic data_hazard;    // Có va chạm dữ liệu lenh load
   logic control_hazard; // Có lệnh nhảy
	
	// Cờ báo trùng địa chỉ (Match)
   logic match_rs1_EX;
   logic match_rs2_EX;
	
	// Cờ báo thanh ghi đích khác 0 (Vì x0 luôn = 0, không bao giờ gây Hazard)
   logic rd_EX_not_zero;
	assign rd_EX_not_zero = |(rd_EX);
	
	// Kiểm tra RS1
   compare_5bit cmp1b (.a(rs1_addr_ID), .b(rd_EX), .eq(match_rs1_EX));
	// Kiểm tra RS2
   compare_5bit cmp2b (.a(rs2_addr_ID), .b(rd_EX), .eq(match_rs2_EX));
	
	// Kiểm tra va chạm nguồn 1 (RS1) với tầng EX
   assign hazard_rs1 = match_rs1_EX & is_ld_EX & rd_EX_not_zero;             
	// Kiểm tra va chạm nguồn 2 (RS2) với tầng EX
   assign hazard_rs2 = match_rs2_EX & is_ld_EX & rd_EX_not_zero;
	
	//Chỉ cần dính 1 trong 2 nguồn là bị Hazard
   assign data_hazard = hazard_rs1 | hazard_rs2;
	
	//Xảy ra khi có lệnh nhảy (ở EX) 
	assign control_hazard = mispredict_EX; 
	
	//tin hieu dau ra
	//lenh load
	assign stall_PC = data_hazard;
	assign stall_IF_ID = data_hazard; 
	assign flush_ID_EX = data_hazard | control_hazard; 
	//lenh nhay
	assign flush_IF_ID = control_hazard;	
endmodule
