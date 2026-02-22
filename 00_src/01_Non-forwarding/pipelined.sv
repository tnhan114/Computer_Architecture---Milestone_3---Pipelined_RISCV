//----------------------------------------------------------------------//
//  Design Note
//----------------------------------------------------------------------//
//  1. Instruction Memory Depth (IMEM): At least 8  kiB to run the "isa_1b.hex" or "isa_4b.hex"
//  2. Data        Memory Depth (DMEM): At least 64 kiB (0x0000_0000 - 0x0000_FFFF)
//  3. IMEM and DMEM are separate memory blocks.

//***TOP***
module pipelined(
	input logic i_clk,
	input logic i_reset,
	output logic [31:0] o_pc_debug,
	output logic o_insn_vld,
	output logic o_ctrl,
	output logic o_mispred,
	output logic [31:0] o_io_ledr,
	output logic [31:0] o_io_ledg,
	output logic [6:0] o_io_hex0,
	output logic [6:0] o_io_hex1,
	output logic [6:0] o_io_hex2,
	output logic [6:0] o_io_hex3,
	output logic [6:0] o_io_hex4,
	output logic [6:0] o_io_hex5,
	output logic [6:0] o_io_hex6,
	output logic [6:0] o_io_hex7,
	output logic [31:0] o_io_lcd,
	input logic [31:0] i_io_sw
);

    // --- 1. KHAI BÁO DÂY TÍN HIỆU (WIRES) ---

    // Hazard Control Signals
    logic stall_pc;
    logic stall_if_id;
    logic flush_if_id;
    logic flush_id_ex;

    // Branch Control Signals
    logic pc_sel;           // 1: Nhảy (Taken), 0: Không (Not Taken)
    logic br_equal_ex;      // Kết quả so sánh Bằng
    logic br_less_ex;       // Kết quả so sánh Bé hơn
    logic pc_taken_mem;     // Tín hiệu nhảy trễ (từ MEM stage)

    // IF Stage Wires
    logic [31:0] pc_next;
    logic [31:0] pc_if;
    logic [31:0] inst_if;
    logic [31:0] pc_4_if;

    // ID Stage Wires
    logic [31:0] pc_id, inst_id, imm_id, rs1_id, rs2_id;
    logic insn_vld_id, o_ctrl_id;
    logic rd_wren_id, br_un_id, opa_sel_id, opb_sel_id, mem_wren_id, is_ld_id;
    logic [3:0] alu_op_id;
    logic [2:0] type_sel_id;
    logic [1:0] wb_sel_id;
    logic is_branch_id, is_jal_id, is_jalr_id;

    // EX Stage Wires
    logic [31:0] pc_ex, inst_ex, imm_ex, rs1_ex, rs2_ex;
    logic insn_vld_ex, o_ctrl_ex;
    logic rd_wren_ex, br_un_ex, opa_sel_ex, opb_sel_ex, mem_wren_ex, is_ld_ex;
    logic [3:0] alu_op_ex;
    logic [2:0] type_sel_ex;
    logic [1:0] wb_sel_ex;
    logic is_branch_ex, is_jal_ex, is_jalr_ex;
    logic [31:0] operand_a, operand_b, alu_result_ex;

    // MEM Stage Wires
    logic [31:0] pc_mem, inst_mem, alu_result_mem, rs2_mem, pc4_mem;
    logic insn_vld_mem, o_ctrl_mem, o_mispred_mem;
    logic rd_wren_mem, mem_wren_mem, is_ld_mem;
    logic [2:0] type_sel_mem;
    logic [1:0] wb_sel_mem;
    // IO Wires at MEM
    logic [31:0] i_io_switch_mem;
    logic [31:0] o_io_ledr_mem, o_io_ledg_mem, o_io_lcd_mem;
    logic [6:0] o_io_hex0_mem, o_io_hex1_mem, o_io_hex2_mem, o_io_hex3_mem;
    logic [6:0] o_io_hex4_mem, o_io_hex5_mem, o_io_hex6_mem, o_io_hex7_mem;
    logic [31:0] o_ld_data_mem; // Output từ LSU

    // WB Stage Wires
    logic [31:0] pc4_wb, inst_wb, alu_result_wb, data_wb, o_ld_data_wb;
    logic rd_wren_wb;
    logic [1:0] wb_sel_wb;


    // ========================================================================
    // 2. HAZARD DETECTION UNIT 
    // ========================================================================
    hazard_unit HAZARD_UNIT(
        // Inputs từ ID (Lệnh đang nạp)
        .rs1_addr_ID(inst_id[19:15]),
        .rs2_addr_ID(inst_id[24:20]),
        
        // Inputs từ các tầng trước (Để check Data Hazard)
        .rd_EX(inst_ex[11:7]),   .rd_wren_EX(rd_wren_ex),
        .rd_MEM(inst_mem[11:7]), .rd_wren_MEM(rd_wren_mem),
        
        // Inputs Control Hazard (Nhảy)
        .pc_taken_EX(pc_sel),
        
        // Outputs Điều khiển
        .stall_PC(stall_pc),
        .stall_IF_ID(stall_if_id),
        .flush_IF_ID(flush_if_id),
        .flush_ID_EX(flush_id_ex)
    );

    // ========================================================================
    // 3. IF STAGE
    // ========================================================================
    
    // Logic chọn PC Next: 
    // - Nếu pc_sel=1 (Branch/Jump): Lấy địa chỉ đích từ ALU (alu_result_ex)
    // - Nếu pc_sel=0 (Tuần tự): Lấy PC+4
    assign pc_next = (pc_sel) ? alu_result_ex : pc_4_if;

    pc_4_if pc4_IF(
        .pc_if(pc_if), 
        .pc_4_if(pc_4_if)
    );
    
    pc PC(
        .clk(i_clk), 
        .rst(i_reset), 
        .en(~stall_pc), // Stall Active High -> Enable Active Low
        .pc_next(pc_next), 
        .pc_if(pc_if)
    );  
   
  

    imem IMEM(
        .clock(i_clk), 
        .addr(pc_if[15:2]), 
        .q(inst_if)
    );
    
    IF_ID reg_IF_ID(
        .i_clk(i_clk), 
        .i_rst(i_reset), 
        .pc_IF(pc_if), 
        .inst_IF(inst_if ), 
        .pc_ID(pc_id), 
        .inst_ID(inst_id), 
        .insn_vld_ID(insn_vld_id),
        .en_IF_ID(~stall_if_id),   // Kết nối Stall
        .flush_IF_ID(flush_if_id)  // Kết nối Flush
    );


    // ========================================================================
    // 4. ID STAGE
    // ========================================================================
    imm_gen IMM_GEN( .i_inst(inst_id), .o_imm(imm_id) );
    
    cu_id CU_ID(
        .inst_ID(inst_id),
        .rd_wren_ID(rd_wren_id), .br_un_ID(br_un_id),
        .opa_sel_ID(opa_sel_id), .opb_sel_ID(opb_sel_id),
        .alu_op_ID(alu_op_id),   .mem_wren_ID(mem_wren_id),
        .type_sel_ID(type_sel_id), .wb_sel_ID(wb_sel_id),
        .is_branch_ID(is_branch_id), .is_jal_ID(is_jal_id), .is_jalr_ID(is_jalr_id),
        .o_ctrl_ID(o_ctrl_id), .is_ld_ID(is_ld_id) 
    );
    
    register REG_FILE(
        .i_clk(i_clk), .i_reset(i_reset),                    
        .i_rs1_addr(inst_id[19:15]), .i_rs2_addr(inst_id[24:20]),        
        .o_rs1_data(rs1_id), .o_rs2_data(rs2_id),    
        .i_rd_addr(inst_wb[11:7]), .i_rd_data(data_wb), .i_rd_wren(rd_wren_wb)                
    );
    
    ID_EX reg_ID_EX(
        .i_clk(i_clk), .i_rst(i_reset),
        .flush_ID_EX(flush_id_ex), // Kết nối Flush từ Hazard Unit
        // ... Inputs ...
        .alu_op_ID(alu_op_id), .opa_sel_ID(opa_sel_id), .opb_sel_ID(opb_sel_id), .br_un_ID(br_un_id),
        .is_branch_ID(is_branch_id), .is_jal_ID(is_jal_id), .is_jalr_ID(is_jalr_id),
        .type_sel_ID(type_sel_id), .mem_wren_ID(mem_wren_id), .is_ld_ID(is_ld_id),
        .rd_wren_ID(rd_wren_id), .wb_sel_ID(wb_sel_id),
        .pc_ID(pc_id), .inst_ID(inst_id), .imm_ID(imm_id),
        .rs1_ID(rs1_id), .rs2_ID(rs2_id), .insn_vld_ID(insn_vld_id), .o_ctrl_ID(o_ctrl_id),
        // ... Outputs ...
        .alu_op_EX(alu_op_ex), .opa_sel_EX(opa_sel_ex), .opb_sel_EX(opb_sel_ex), .br_un_EX(br_un_ex),
        .is_branch_EX(is_branch_ex), .is_jal_EX(is_jal_ex), .is_jalr_EX(is_jalr_ex),
        .type_sel_EX(type_sel_ex), .mem_wren_EX(mem_wren_ex), .is_ld_EX(is_ld_ex),
        .rd_wren_EX(rd_wren_ex), .wb_sel_EX(wb_sel_ex),
        .pc_EX(pc_ex), .inst_EX(inst_ex), .imm_EX(imm_ex),
        .rs1_EX(rs1_ex), .rs2_EX(rs2_ex), .insn_vld_EX(insn_vld_ex), .o_ctrl_EX(o_ctrl_ex)
    );


    // ========================================================================
    // 5. EX STAGE
    // ========================================================================
    
    // MUX Chọn Operand A: RS1 hoặc PC
    mux2_1_32bit MUX_A(
        .a(rs1_ex), 
        .b(pc_ex), 
        .c(operand_a), 
        .sel(opa_sel_ex)
    );
    
    // MUX Chọn Operand B: RS2 hoặc Imm
    mux2_1_32bit MUX_B(
        .a(rs2_ex), 
        .b(imm_ex), 
        .c(operand_b), 
        .sel(opb_sel_ex)
    );
    
    // ALU: Tính toán data hoặc Địa chỉ nhảy (Target Address)
    // Khi nhảy: Target = (PC hoặc RS1) + Imm. Mux A và B sẽ chọn đúng giá trị này.
    alu ALU(
        .i_alu_op (alu_op_ex), 
        .i_op_a(operand_a), 
        .i_op_b(operand_b), 
        .o_alu_data(alu_result_ex)
    );
    
    // Bộ so sánh nhánh (BRC)
    brc BRC(
        .rs1_EX(rs1_ex), 
        .rs2_EX(rs2_ex), 
        .br_un_EX(br_un_ex), 
        .br_less_EX(br_less_ex), 
        .br_equal_EX(br_equal_ex)
    );
    
    // Bộ quyết định nhảy (Branch Unit)
    branch_unit BRANCH_UNIT(
        .type_sel_EX(type_sel_ex), 
        .br_less_EX(br_less_ex), 
        .br_equal_EX(br_equal_ex), 
        .is_branch_EX(is_branch_ex),
        .is_jal_EX(is_jal_ex), 
        .is_jalr_EX(is_jalr_ex), 
        .pc_sel(pc_sel) // Output: 1 nếu cần nhảy
    );
    
    EX_MEM reg_EX_MEM(
        .i_clk(i_clk), .i_rst(i_reset),
        .pc_taken_EX(pc_sel),
        
        // ... Data ...
        .pc_EX(pc_ex), .inst_EX(inst_ex), .alu_result_EX(alu_result_ex), .rs2_EX(rs2_ex),
        .o_ctrl_EX(o_ctrl_ex), .insn_vld_EX(insn_vld_ex),
        .type_sel_EX(type_sel_ex), .mem_wren_EX(mem_wren_ex), .is_ld_EX(is_ld_ex),
        .rd_wren_EX(rd_wren_ex), .wb_sel_EX(wb_sel_ex),
        
        // ... Outputs ...
        .pc_MEM(pc_mem), .inst_MEM(inst_mem), .alu_result_MEM(alu_result_mem), .rs2_MEM(rs2_mem),
        .o_ctrl_MEM(o_ctrl_mem), .insn_vld_MEM(insn_vld_mem), .o_mispred_MEM(o_mispred_mem),
        .type_sel_MEM(type_sel_mem), .mem_wren_MEM(mem_wren_mem), .is_ld_MEM(is_ld_mem),
        .rd_wren_MEM(rd_wren_mem), .wb_sel_MEM(wb_sel_mem)
    );
    
    // ========================================================================
    // 6. MEM STAGE
    // ========================================================================
    
    pc4_mem pc4_MEM(
        .pc_MEM(pc_mem),
        .pc4_MEM(pc4_mem)
    );
    
    lsu2 LSU(
        .i_clk(i_clk), .i_reset(i_reset),
        .i_lsu_addr(alu_result_mem), // Địa chỉ tính từ ALU
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
    
    MEM_WB reg_MEM_WB(
        .i_clk(i_clk), .i_rst(i_reset),
        // IO
        .i_io_switch_MEM(i_io_switch_mem), .o_io_ledr_MEM(o_io_ledr_mem), .o_io_ledg_MEM(o_io_ledg_mem),
        .o_io_hex0_MEM(o_io_hex0_mem), .o_io_hex1_MEM(o_io_hex1_mem), .o_io_hex2_MEM(o_io_hex2_mem), .o_io_hex3_MEM(o_io_hex3_mem),
        .o_io_hex4_MEM(o_io_hex4_mem), .o_io_hex5_MEM(o_io_hex5_mem), .o_io_hex6_MEM(o_io_hex6_mem), .o_io_hex7_MEM(o_io_hex7_mem),
        .o_io_lcd_MEM(o_io_lcd_mem),
        // Data
        .pc4_MEM(pc4_mem), .inst_MEM(inst_mem), .alu_result_MEM(alu_result_mem),
        .o_ctrl_MEM(o_ctrl_mem), .o_mispred_MEM(o_mispred_mem), .pc_MEM(pc_mem),
        .insn_vld_MEM(insn_vld_mem), .rd_wren_MEM(rd_wren_mem), .wb_sel_MEM(wb_sel_mem),
		  .o_ld_data_MEM(o_ld_data_mem),
        // Outputs
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
    // 7. WB STAGE
    // ========================================================================
    mux4 mux_WB(
        .pc_four(pc4_wb),
        .alu_data(alu_result_wb),
        .ld_data(o_ld_data_wb),
        .wb_sel(wb_sel_wb),
        .wb_data(data_wb)
    );

endmodule
