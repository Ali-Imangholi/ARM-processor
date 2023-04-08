module IF_ID
(
input clk,
input rst,
input Freeze,
input Flush,
input [31:0] PC,
input [31:0] inst_mem_out,
output reg [31:0] PC_out,
output reg [31:0] instruction
);

always @(posedge clk) 
begin
	if(rst==1'b1||Flush==1'b1)  
		{PC_out,instruction} <= 64'd0;
		
	else if(Freeze==1'b0) 
	begin
		PC_out <= PC;
		instruction <= inst_mem_out;
	end
end

endmodule
       