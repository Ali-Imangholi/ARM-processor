module MEM
(
input clk,
input rst,
input WB_EN,
input MEM_R_EN,
input MEM_W_EN,
input [31:0] ALU_Res,
input [31:0] Val_Rm,
input [3:0] Dest,
input [31:0] pc,
output WB_EN_out,
output MEM_R_EN_out,
output [31:0]ALU_Res_out,
output [31:0]DataMemory_out,
output [3:0] MEM_Dest,
output [31:0] pc_out
);

assign pc_out = pc;
assign WB_EN_out = WB_EN;
assign MEM_R_EN_out = MEM_R_EN;
assign MEM_Dest = Dest;
assign ALU_Res_out = ALU_Res;

reg[31:0] memory[0:63];
wire[31:0] address;

assign address= (ALU_Res-32'd1024) >> 2; //memory starts @1024 address  
assign DataMemory_out = MEM_R_EN ? memory[address] : 32'd0;

always@(negedge clk) //write
begin
	if(MEM_W_EN)
		memory[address] = Val_Rm;
end

endmodule
