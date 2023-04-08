module EXE_MEM
(
input clk,
input rst,
input WB_EN,
input MEM_R_EN,
input MEM_W_EN,
input [31:0]Val_Rm,
input [3:0]Dest,
input [31:0] ALU_Res,
input [31:0]pc,
output reg WB_EN_out,
output reg MEM_R_EN_out,
output reg MEM_W_EN_out,
output reg [31:0]Val_Rm_out,
output reg [3:0]Dest_out,
output reg [31:0] ALU_Res_out,
output reg [31:0] pc_out
);

always @(posedge clk, posedge rst)
begin
    if (rst)
	begin
		WB_EN_out <= 1'b0;
		MEM_R_EN_out <= 1'b0;
		MEM_W_EN_out <= 1'b0;
		ALU_Res_out <= 32'd0;
		Val_Rm_out <= 32'd0;
		Dest_out <= 4'd0;
    end
	else
	begin
		WB_EN_out<=WB_EN;
		MEM_R_EN_out<=MEM_R_EN;
		MEM_W_EN_out<=MEM_W_EN;
		ALU_Res_out<=ALU_Res;
		Val_Rm_out<=Val_Rm;
		Dest_out<=Dest;
		pc_out <= pc;
    end
end

endmodule
