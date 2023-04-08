module MEM_WB
(
input clk,
input rst,
input WB_EN,
input MEM_R_EN,
input [31:0] ALU_Res,
input [31:0] DataMemory,
input [3:0] Dest,
input [31:0] pc,
input Freeze,
output reg [31:0] DataMemory_out,
output reg [31:0] ALU_Res_out,
output reg MEM_R_EN_out,
output reg WB_WB_EN,
output reg [3:0] WB_Dest,
output reg [31:0] pc_out
);

always @(posedge clk)
begin
	if (rst)
	begin
		DataMemory_out <= 32'd0;
		ALU_Res_out <= 32'd0;
		MEM_R_EN_out <= 1'b0;
		WB_WB_EN <= 1'b0;
		WB_Dest <= 4'd0;
	end
	else if(Freeze==1'b0)
	begin
		DataMemory_out <= DataMemory;
		ALU_Res_out <= ALU_Res;
		WB_Dest <= Dest;
		MEM_R_EN_out <= MEM_R_EN;
		WB_WB_EN <= WB_EN;
		pc_out <= pc;
	end
end

endmodule
