//forwarding unit
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

module forwarding_unit(
    input logic [4:0] rs1_addr_EX,
    input logic [4:0] rs2_addr_EX,
    input logic [4:0] rd_MEM,
    input logic       rd_wren_MEM,
    input logic [4:0] rd_WB,
    input logic       rd_wren_WB,
    
    output logic [1:0] forward_A, // Chọn nguồn cho RS1
    output logic [1:0] forward_B  // Chọn nguồn cho RS2
);
	// Cờ báo trùng địa chỉ (Match)
    logic match_rs1_mem, match_rs1_wb;
    logic match_rs2_mem, match_rs2_wb;
	// Kiểm tra RS1
   compare_5bit cmp1a (.a(rs1_addr_EX), .b(rd_MEM), .eq(match_rs1_mem));
   compare_5bit cmp1b (.a(rs1_addr_EX), .b(rd_WB),  .eq(match_rs1_wb));
    // Kiểm tra RS2
   compare_5bit cmp2a (.a(rs2_addr_EX), .b(rd_MEM), .eq(match_rs2_mem));
   compare_5bit cmp2b (.a(rs2_addr_EX), .b(rd_WB),  .eq(match_rs2_wb));
	
	 // Cờ báo thanh ghi đích khác 0 (Vì x0 luôn = 0, không bao giờ gây Hazard)
	 logic rd_mem_not_zero, rd_wb_not_zero;
	 
	 assign rd_mem_not_zero = |(rd_MEM);
	 assign rd_wb_not_zero = |(rd_WB);
	 
    // forward_A encoding:
    // 00: Lấy từ ID/EX (Mặc định - RS1 cũ)
    // 10: Forward từ MEM (Ưu tiên cao nhất - EX Hazard)
    // 01: Forward từ WB (Ưu tiên nhì - MEM Hazard)

    always_comb begin
        // 1. Forward A (RS1)
        forward_A = 2'b00; // Default
       
		  // EX Hazard (MEM -> EX) - Ghi đè nếu có cả 2 hazard (ưu tiên cái mới nhất)
        if (rd_wren_MEM & rd_mem_not_zero & match_rs1_mem) begin
            forward_A = 2'b10;
        end

        // MEM Hazard (WB -> EX)
        else if (rd_wren_WB & rd_wb_not_zero & match_rs1_wb) begin
            forward_A = 2'b01;
        end
     end 
       
	  always_comb begin
        // 2. Forward B (RS2)
        forward_B = 2'b00; // Default
         
        // EX Hazard
        if (rd_wren_MEM & rd_mem_not_zero & match_rs2_mem) begin
            forward_B = 2'b10;
        end
		  
        // MEM Hazard
        else if (rd_wren_WB & rd_wb_not_zero & match_rs2_wb) begin
            forward_B = 2'b01;
        end
      end 
endmodule
