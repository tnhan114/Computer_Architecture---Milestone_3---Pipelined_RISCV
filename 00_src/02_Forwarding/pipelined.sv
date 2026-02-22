//----------------------------------------------------------------------//
//  Design Note
//----------------------------------------------------------------------//
//  1. Instruction Memory Depth (IMEM): At least 8  kiB to run the "isa_1b.hex" or "isa_4b.hex"
//  2. Data        Memory Depth (DMEM): At least 64 kiB (0x0000_0000 - 0x0000_FFFF)
//  3. IMEM and DMEM are separate memory blocks.

//***TOP***
module pipelined(
	input logic i_clk, // Xung nhịp đầu vào
	input logic i_reset, // Tín hiệu reset đầu vào (tích cực mức thấp)
	output logic [31:0] o_pc_debug, // Đầu ra PC để gỡ lỗi
	output logic o_insn_vld, // Tín hiệu báo lệnh hợp lệ
	output logic o_ctrl, // Tín hiệu điều khiển (branch/jump)
	output logic o_mispred, // Tín hiệu báo đoán sai nhánh
	output logic [31:0] o_io_ledr, // Đầu ra điều khiển LED đỏ
	output logic [31:0] o_io_ledg, // Đầu ra điều khiển LED xanh
	output logic [6:0] o_io_hex0, // Đầu ra LED 7 đoạn 0
	output logic [6:0] o_io_hex1, // Đầu ra LED 7 đoạn 1
	output logic [6:0] o_io_hex2, // Đầu ra LED 7 đoạn 2
	output logic [6:0] o_io_hex3, // Đầu ra LED 7 đoạn 3
	output logic [6:0] o_io_hex4, // Đầu ra LED 7 đoạn 4
	output logic [6:0] o_io_hex5, // Đầu ra LED 7 đoạn 5
	output logic [6:0] o_io_hex6, // Đầu ra LED 7 đoạn 6
	output logic [6:0] o_io_hex7, // Đầu ra LED 7 đoạn 7
	output logic [31:0] o_io_lcd, // Đầu ra điều khiển màn hình LCD
	input logic [31:0] i_io_sw // Đầu vào từ các công tắc
);

    // --- 1. KHAI BÁO TÍN HIỆU ---
    
    // Tín hiệu Hazard & Forwarding
    logic stall_pc; // Tín hiệu dừng PC
    logic stall_if_id; // Tín hiệu dừng thanh ghi IF/ID
    logic flush_if_id; // Tín hiệu xóa thanh ghi IF/ID
    logic flush_id_ex; // Tín hiệu xóa thanh ghi ID/EX
    
    logic [1:0] forward_a_ex; // Tín hiệu chọn nguồn dữ liệu A cho ALU (từ forwarding unit)
    logic [1:0] forward_b_ex; // Tín hiệu chọn nguồn dữ liệu B cho ALU (từ forwarding unit)

    // Tín hiệu Nhánh (Branch)
    logic pc_sel;           // 1: Nhảy/Rẽ nhánh thành công (Taken)
    logic br_equal_ex;      // Kết quả so sánh bằng tại EX
    logic br_less_ex;       // Kết quả so sánh nhỏ hơn tại EX

    // Tầng IF (Nạp lệnh)
    logic [31:0] pc_next, pc_if, inst_if, pc_4_if;
    
    // Tầng ID (Giải mã lệnh)
    logic [31:0] pc_id, inst_id, imm_id, rs1_id, rs2_id;
    logic insn_vld_id, o_ctrl_id;
    logic rd_wren_id, br_un_id, opa_sel_id, opb_sel_id, mem_wren_id, is_ld_id;
    logic [3:0] alu_op_id;
    logic [2:0] type_sel_id;
    logic [1:0] wb_sel_id;
    logic is_branch_id, is_jal_id, is_jalr_id;

    // Tầng EX (Thực thi)
    logic [31:0] pc_ex, inst_ex, imm_ex, rs1_ex, rs2_ex;
    logic insn_vld_ex, o_ctrl_ex;
    logic rd_wren_ex, br_un_ex, opa_sel_ex, opb_sel_ex, mem_wren_ex, is_ld_ex;
    logic [3:0] alu_op_ex;
    logic [2:0] type_sel_ex;
    logic [1:0] wb_sel_ex;
    logic is_branch_ex, is_jal_ex, is_jalr_ex;
    logic [31:0] operand_a, operand_b, alu_result_ex;
    
    // Dây Forwarding
    logic [31:0] src_a_fwd; // Dữ liệu RS1 sau khi forward
    logic [31:0] src_b_fwd; // Dữ liệu RS2 sau khi forward

    // Tầng MEM (Truy cập bộ nhớ)
    logic [31:0] pc_mem, inst_mem, alu_result_mem, rs2_mem, pc4_mem;
    logic insn_vld_mem, o_ctrl_mem, o_mispred_mem;
    logic rd_wren_mem, mem_wren_mem, is_ld_mem;
    logic [2:0] type_sel_mem;
    logic [1:0] wb_sel_mem;
    
    // Tín hiệu IO & Data Mem
    logic [31:0] i_io_switch_mem;
    logic [31:0] o_io_ledr_mem, o_io_ledg_mem, o_io_lcd_mem;
    logic [6:0] o_io_hex0_mem, o_io_hex1_mem, o_io_hex2_mem, o_io_hex3_mem;
    logic [6:0] o_io_hex4_mem, o_io_hex5_mem, o_io_hex6_mem, o_io_hex7_mem;
    logic [31:0] o_ld_data_mem; 

    // Tầng WB (Ghi hồi tiếp)
    logic [31:0] pc4_wb, inst_wb, alu_result_wb, data_wb, o_ld_data_wb;
    logic rd_wren_wb;
    logic [1:0] wb_sel_wb;

    // ========================================================================
    // 2. KHỐI PHÁT HIỆN HAZARD 
    // ========================================================================
    hazard_unit HAZARD_UNIT(
        .rs1_addr_ID(inst_id[19:15]), // Địa chỉ RS1 tại ID
        .rs2_addr_ID(inst_id[24:20]), // Địa chỉ RS2 tại ID
        .rd_EX(inst_ex[11:7]),      // Địa chỉ RD tại EX (Để kiểm tra Load-Use)
        .is_ld_EX(is_ld_ex),        // Tín hiệu báo lệnh trước là Load tại EX
	.pc_taken_EX(pc_sel),
        
        // Đầu ra
        .stall_PC(stall_pc),        // Dừng PC
		  .stall_IF_ID(stall_if_id),   // Dung ID/EX
        .flush_ID_EX(flush_id_ex),  // Xóa ID/EX khi Branch
        .flush_IF_ID(flush_if_id) // Xóa IF/ID khi Branch     
    );

    // ========================================================================
    // 3. KHỐI FORWARDING 
    // ========================================================================
    forwarding_unit FWD_UNIT(
        .rs1_addr_EX(inst_ex[19:15]), // Địa chỉ RS1 tại EX
        .rs2_addr_EX(inst_ex[24:20]), // Địa chỉ RS2 tại EX
        .rd_MEM(inst_mem[11:7]),      // Địa chỉ RD tại MEM
        .rd_wren_MEM(rd_wren_mem),    // Tín hiệu ghi RD tại MEM
        .rd_WB(inst_wb[11:7]),        // Địa chỉ RD tại WB
        .rd_wren_WB(rd_wren_wb),      // Tín hiệu ghi RD tại WB
        
        .forward_A(forward_a_ex),     // Tín hiệu điều khiển mux A
        .forward_B(forward_b_ex)      // Tín hiệu điều khiển mux B
    );

    // ========================================================================
    // 4. TẦNG IF 
    // ========================================================================
    mux_pc MUX_PC(
        .a(pc_4_if),
        .b(alu_result_ex), // Địa chỉ đích rẽ nhánh laays o mem
        .sel(pc_sel),      // Chọn nguồn PC
        .pc_next(pc_next)  // PC tiếp theo
    );

    pc_4_if PC4_IF( .pc_if(pc_if), .pc_4_if(pc_4_if) ); // Tính PC+4

    pc PC(
        .clk(i_clk), .rst(i_reset),
        .en(~stall_pc), // Dừng PC khi có tín hiệu Stall từ Hazard Unit
        .pc_next(pc_next),
        .pc_if(pc_if)   // PC hiện tại
    );  

    imem IMEM( .clock(i_clk), .addr(pc_if[15:2]), .q(inst_if) ); // Bộ nhớ lệnh
    
    IF_ID REG_IF_ID(
        .i_clk(i_clk), .i_rst(i_reset),
        .pc_IF(pc_if), .inst_IF(inst_if),
        .pc_ID(pc_id), .inst_ID(inst_id), .insn_vld_ID(insn_vld_id),
        .en_IF_ID(~stall_if_id), // Dừng IF/ID
        .flush_IF_ID(flush_if_id) // Xóa IF/ID
    );

    // ========================================================================
    // 5. TẦNG ID 
    // ========================================================================
    imm_gen IMM_GEN( .i_inst(inst_id), .o_imm(imm_id) ); // Tạo giá trị tức thời
    
    cu_id CU_ID( // Khối điều khiển
        .inst_ID(inst_id),
        .rd_wren_ID(rd_wren_id), .br_un_ID(br_un_id),
        .opa_sel_ID(opa_sel_id), .opb_sel_ID(opb_sel_id),
        .alu_op_ID(alu_op_id),   .mem_wren_ID(mem_wren_id),
        .type_sel_ID(type_sel_id), .wb_sel_ID(wb_sel_id),
        .is_branch_ID(is_branch_id), .is_jal_ID(is_jal_id), .is_jalr_ID(is_jalr_id),
        .o_ctrl_ID(o_ctrl_id), .is_ld_ID(is_ld_id) 
    );
    
    register REG_FILE( // Tập thanh ghi
        .i_clk(i_clk), .i_reset(i_reset),                     
        .i_rs1_addr(inst_id[19:15]), .i_rs2_addr(inst_id[24:20]),        
        .o_rs1_data(rs1_id), .o_rs2_data(rs2_id),     
        .i_rd_addr(inst_wb[11:7]), .i_rd_data(data_wb), .i_rd_wren(rd_wren_wb)                
    );
	 
	 
    ID_EX REG_ID_EX( // Thanh ghi pipeline ID/EX
        .i_clk(i_clk), .i_rst(i_reset),
        .flush_ID_EX(flush_id_ex), // Xóa ID/EX khi có Hazard
        // Đầu vào
        .alu_op_ID(alu_op_id), .opa_sel_ID(opa_sel_id), .opb_sel_ID(opb_sel_id), .br_un_ID(br_un_id),
        .is_branch_ID(is_branch_id), .is_jal_ID(is_jal_id), .is_jalr_ID(is_jalr_id),
        .type_sel_ID(type_sel_id), .mem_wren_ID(mem_wren_id), .is_ld_ID(is_ld_id),
        .rd_wren_ID(rd_wren_id), .wb_sel_ID(wb_sel_id),
        .pc_ID(pc_id), .inst_ID(inst_id), .imm_ID(imm_id),
        .rs1_ID(rs1_id), .rs2_ID(rs2_id), .insn_vld_ID(insn_vld_id), .o_ctrl_ID(o_ctrl_id),
        // Đầu ra
        .alu_op_EX(alu_op_ex), .opa_sel_EX(opa_sel_ex), .opb_sel_EX(opb_sel_ex), .br_un_EX(br_un_ex),
        .is_branch_EX(is_branch_ex), .is_jal_EX(is_jal_ex), .is_jalr_EX(is_jalr_ex),
        .type_sel_EX(type_sel_ex), .mem_wren_EX(mem_wren_ex), .is_ld_EX(is_ld_ex),
        .rd_wren_EX(rd_wren_ex), .wb_sel_EX(wb_sel_ex),
        .pc_EX(pc_ex), .inst_EX(inst_ex), .imm_EX(imm_ex),
        .rs1_EX(rs1_ex), .rs2_EX(rs2_ex), .insn_vld_EX(insn_vld_ex), .o_ctrl_EX(o_ctrl_ex)
    );

    // ========================================================================
    // 6. TẦNG EX 
    // ========================================================================
    
    // --- Các bộ Mux Forwarding (Bổ sung) ---
    // Chọn nguồn dữ liệu cho RS1: Từ ID/EX, MEM (Forward), hay WB (Forward)?
    mux3_1 MUX_FWD_A(
        .rs_EX(rs1_ex),
        .alu_result_MEM(alu_result_mem), // Forward từ MEM
        .data_WB(data_wb),               // Forward từ WB
        .forward(forward_a_ex),          // Tín hiệu điều khiển từ Forwarding Unit
        .rs_ex_true(src_a_fwd)           // Dữ liệu chuẩn để dùng
    );
    
    // Chọn nguồn dữ liệu cho RS2
    mux3_1 MUX_FWD_B(
        .rs_EX(rs2_ex),
        .alu_result_MEM(alu_result_mem),
        .data_WB(data_wb),
        .forward(forward_b_ex),
        .rs_ex_true(src_b_fwd)
    );

    // --- Các bộ Mux chọn toán hạng (Sửa đầu vào) ---
    // Chọn đầu vào A cho ALU (Reg/Forwarded hay PC)
    mux2_1_32bit MUX_A(
        .a(src_a_fwd),  // Dùng dữ liệu đã qua Forwarding
        .b(pc_ex), 
        .c(operand_a), 
        .sel(opa_sel_ex)
    );
    
    // Chọn đầu vào B cho ALU (Reg/Forwarded hay Imm)
    mux2_1_32bit MUX_B(
        .a(src_b_fwd),  // Dùng dữ liệu đã qua Forwarding
        .b(imm_ex), 
        .c(operand_b), 
        .sel(opb_sel_ex)
    );
    
    alu ALU( // Bộ tính toán số học và logic
        .i_alu_op(alu_op_ex), 
        .i_op_a(operand_a), 
        .i_op_b(operand_b), 
        .o_alu_data(alu_result_ex)
    );
    
    // Bộ so sánh nhánh dùng dữ liệu đã Forward
    brc BRC(
        .rs1_EX(src_a_fwd), 
        .rs2_EX(src_b_fwd), 
        .br_un_EX(br_un_ex), 
        .br_less_EX(br_less_ex), 
        .br_equal_EX(br_equal_ex)
    );
    
    branch_unit BRANCH_UNIT( // Khối xử lý rẽ nhánh
        .type_sel_EX(inst_ex[14:12]), 
        .br_less_EX(br_less_ex), 
        .br_equal_EX(br_equal_ex), 
        .is_branch_EX(is_branch_ex),
        .is_jal_EX(is_jal_ex), 
        .is_jalr_EX(is_jalr_ex), 
        .pc_sel(pc_sel) 
    );
    
    EX_MEM REG_EX_MEM( // Thanh ghi pipeline EX/MEM
        .i_clk(i_clk), .i_rst(i_reset),
        .pc_taken_EX(pc_sel),
        // Đầu vào
        .pc_EX(pc_ex), .inst_EX(inst_ex), .alu_result_EX(alu_result_ex), 
        .rs2_EX(src_b_fwd), // RS2 lưu vào MEM cũng phải là dữ liệu mới nhất (đã forward)
        .o_ctrl_EX(o_ctrl_ex), .insn_vld_EX(insn_vld_ex),
        .type_sel_EX(type_sel_ex), .mem_wren_EX(mem_wren_ex), .is_ld_EX(is_ld_ex),
        .rd_wren_EX(rd_wren_ex), .wb_sel_EX(wb_sel_ex),
        // Đầu ra
        .pc_MEM(pc_mem), .inst_MEM(inst_mem), .alu_result_MEM(alu_result_mem), .rs2_MEM(rs2_mem),
        .o_ctrl_MEM(o_ctrl_mem), .insn_vld_MEM(insn_vld_mem), .o_mispred_MEM(o_mispred_mem),
        .type_sel_MEM(type_sel_mem), .mem_wren_MEM(mem_wren_mem), .is_ld_MEM(is_ld_mem),
        .rd_wren_MEM(rd_wren_mem), .wb_sel_MEM(wb_sel_mem)
    );

    // ========================================================================
    // 7. TẦNG MEM 
    // ========================================================================
    pc4_mem PC4_MEM( .pc_MEM(pc_mem), .pc4_MEM(pc4_mem) ); // Tính PC+4 tại MEM
    
    lsu2 LSU( // Đơn vị Load/Store
        .i_clk(i_clk), .i_reset(i_reset),
        .i_lsu_addr(alu_result_mem), 
        .i_st_data(rs2_mem),
        .i_lsu_wren(mem_wren_mem),
        .i_io_sw(i_io_switch_mem),
        .type_sel(type_sel_mem),
        .o_ld_data(o_ld_data_mem),
        // IO
        .o_io_ledr(o_io_ledr_mem), .o_io_ledg(o_io_ledg_mem), .o_io_lcd(o_io_lcd_mem),
        .o_io_hex0(o_io_hex0_mem), .o_io_hex1(o_io_hex1_mem), .o_io_hex2(o_io_hex2_mem), .o_io_hex3(o_io_hex3_mem),
        .o_io_hex4(o_io_hex4_mem), .o_io_hex5(o_io_hex5_mem), .o_io_hex6(o_io_hex6_mem), .o_io_hex7(o_io_hex7_mem)
    );
    
    MEM_WB REG_MEM_WB( // Thanh ghi pipeline MEM/WB
        .i_clk(i_clk), .i_rst(i_reset),
        // IO
        .i_io_switch_MEM(i_io_switch_mem), .o_io_ledr_MEM(o_io_ledr_mem), .o_io_ledg_MEM(o_io_ledg_mem),
        .o_io_hex0_MEM(o_io_hex0_mem), .o_io_hex1_MEM(o_io_hex1_mem), .o_io_hex2_MEM(o_io_hex2_mem), .o_io_hex3_MEM(o_io_hex3_mem),
        .o_io_hex4_MEM(o_io_hex4_mem), .o_io_hex5_MEM(o_io_hex5_mem), .o_io_hex6_MEM(o_io_hex6_mem), .o_io_hex7_MEM(o_io_hex7_mem),
        .o_io_lcd_MEM(o_io_lcd_mem),
        // Dữ liệu
        .pc4_MEM(pc4_mem), .inst_MEM(inst_mem), .alu_result_MEM(alu_result_mem),
        .o_ctrl_MEM(o_ctrl_mem), .o_mispred_MEM(o_mispred_mem), .pc_MEM(pc_mem),
        .insn_vld_MEM(insn_vld_mem), .rd_wren_MEM(rd_wren_mem), .wb_sel_MEM(wb_sel_mem),
        .o_ld_data_MEM(o_ld_data_mem),
        // Đầu ra
        .pc4_WB(pc4_wb), .inst_WB(inst_wb), .alu_result_WB(alu_result_wb),
        .pc_WB(o_pc_debug), .o_ctrl_WB(o_ctrl), .o_mispred_WB(o_mispred),
        .insn_vld_WB(o_insn_vld), .rd_wren_WB(rd_wren_wb), .wb_sel_WB(wb_sel_wb),
        .o_ld_data_WB(o_ld_data_wb),
        // IO Outputs
        .i_io_switch_WB(i_io_sw), .o_io_ledr_WB(o_io_ledr), .o_io_ledg_WB(o_io_ledg),
        .o_io_hex0_WB(o_io_hex0), .o_io_hex1_WB(o_io_hex1), .o_io_hex2_WB(o_io_hex2), .o_io_hex3_WB(o_io_hex3),
        .o_io_hex4_WB(o_io_hex4), .o_io_hex5_WB(o_io_hex5), .o_io_hex6_WB(o_io_hex6), .o_io_hex7_WB(o_io_hex7),
        .o_io_lcd_WB(o_io_lcd)
    );
    
    // ========================================================================
    // 8. TẦNG WB 
    // ========================================================================
    mux4 MUX_WB( // Chọn dữ liệu để ghi vào thanh ghi
        .pc_four(pc4_wb),
        .alu_data(alu_result_wb),
        .ld_data(o_ld_data_wb),
        .wb_sel(wb_sel_wb),
        .wb_data(data_wb)
    );
    
endmodule
