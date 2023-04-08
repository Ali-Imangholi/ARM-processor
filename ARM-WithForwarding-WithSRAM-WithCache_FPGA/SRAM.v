`timescale 1ns/1ns
module SRAM(
input clk,
input rst,
input SRAM_WE_N,
input [17:0]SRAM_ADDR,
inout [15:0]SRAM_DQ
);

reg[15:0] memory[0:511];
assign #5 SRAM_DQ=(SRAM_WE_N==1'b1)?memory[SRAM_ADDR]:16'dz;

always@(negedge clk) //write
begin
	if(SRAM_WE_N==1'b0)
		memory[SRAM_ADDR] = SRAM_DQ;
end

endmodule


