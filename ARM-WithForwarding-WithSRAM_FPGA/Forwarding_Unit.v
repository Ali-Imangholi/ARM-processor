module Forwarding_Unit(
input [3:0] Dest_mem,
input [3:0] Dest_wb,
input WB_EN_mem,
input WB_EN_wb,
input [3:0] src1,
input [3:0] src2,
output reg[1:0] sel_src1,
output reg[1:0] sel_src2
);

always@(*) //sel_src1
begin
	if(src1==Dest_mem && WB_EN_mem==1'b1)
		sel_src1=2'b01;
	else if(src1== Dest_wb && WB_EN_wb==1'b1)
		sel_src1=2'b10;
	else
		sel_src1=2'b00;
end

always@(*) //sel_src2
begin
	if(src2==Dest_mem && WB_EN_mem==1'b1)
		sel_src2=2'b01;
	else if(src2== Dest_wb && WB_EN_wb==1'b1)
		sel_src2=2'b10;
	else
		sel_src2=2'b00;
end

endmodule