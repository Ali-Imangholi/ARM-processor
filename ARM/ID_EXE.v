module ID_EXE
(
input clk,
input rst,
input WB_EN,
input MEM_R_EN,
input MEM_W_EN,
input [3:0]EXE_CMD,
input B,
input S,
input [31:0]PC,
input [31:0]Val_Rn,
input [31:0]Val_Rm,
input imm,
input [11:0]shift_operand,
input [23:0]Signed_imm_24,
input [3:0]Dest,
input C_StatusRegister_ID_EXE_in,
input Flush,
output reg C_StatusRegister_ID_EXE_out,
output reg WB_EN_out,
output reg MEM_R_EN_out,
output reg MEM_W_EN_out,
output reg [3:0]EXE_CMD_out,
output reg Branch_Tacken,
output reg S_out,
output reg [31:0]PC_out,
output reg [31:0]Val_1,
output reg [31:0]Val_2_Generate_in_1,
output reg Val_2_Generate_in_2,
output reg [11:0]Val_2_Generate_in_3,
output reg [23:0]Signed_EX_imm24,
output reg [3:0]Dest_out
);


always@(posedge clk, posedge rst)
begin
	if(rst == 1'b1 || Flush == 1'b1)
	begin
		WB_EN_out <= 1'b0;
		MEM_R_EN_out <= 1'b0;
		MEM_W_EN_out <= 1'b0;
		EXE_CMD_out <= 4'd0;
		Branch_Tacken <= 1'b0;
		S_out <= 1'b0;
		PC_out <= 32'd0;
		Val_1 <= 32'd0;
		Val_2_Generate_in_1 <= 32'd0;
		Val_2_Generate_in_2 <= 1'b0;
		Val_2_Generate_in_3 <= 12'd0;
		Signed_EX_imm24 <= 24'd0;
		Dest_out <= 4'd0;
		C_StatusRegister_ID_EXE_out <= 1'b0;
	end
	
	else
	begin
		C_StatusRegister_ID_EXE_out <= C_StatusRegister_ID_EXE_in;
		WB_EN_out <= WB_EN;
		MEM_R_EN_out <= MEM_R_EN;
		MEM_W_EN_out <= MEM_W_EN;
		EXE_CMD_out <= EXE_CMD;
		Branch_Tacken <= B;
		S_out <= S;
		PC_out <= PC;
		Val_1 <= Val_Rn;
		Val_2_Generate_in_1 <= Val_Rm;
		Val_2_Generate_in_2 <= imm;
		Val_2_Generate_in_3 <= shift_operand;
		Signed_EX_imm24 <= Signed_imm_24;
		Dest_out <= Dest;
	end
end
endmodule

