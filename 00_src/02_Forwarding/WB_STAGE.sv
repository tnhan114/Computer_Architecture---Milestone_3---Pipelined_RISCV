//**WB STAGE**
module mux4(
	input logic [31:0] pc_four,
	input logic [31:0] alu_data,
	input logic [31:0] ld_data,
	input logic [1:0] wb_sel,
	output logic [31:0] wb_data
);
	always_comb begin
    case (wb_sel)
        2'b00: wb_data = pc_four;    
        2'b01: wb_data = alu_data;   
        2'b10: wb_data = ld_data;    
        default: wb_data = 32'b0;       
	endcase
	end
endmodule
