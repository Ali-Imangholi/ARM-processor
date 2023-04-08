module WB
(
input [31:0] ALU_Res_in_1,
input [31:0] pc,
input [31:0] Data_Mem_out_in_2,
input MEM_R_EN,
input WB_WB_EN,
input [3:0] WB_Dest,
output WB_WB_EN_out,
output [3:0] WB_Dest_out,
output [31:0] WB_Value,
output [31:0] pc_out
);

assign WB_WB_EN_out = WB_WB_EN;
assign WB_Dest_out = WB_Dest;
assign WB_Value = (MEM_R_EN)?Data_Mem_out_in_2 : ALU_Res_in_1;
assign pc_out = pc;
endmodule
