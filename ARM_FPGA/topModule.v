module ARM_FPGA(CLOCK_50, SW, LEDR);

input CLOCK_50;
input [3:0] SW;
output [15:0] LEDR;

ARM top(.clk(CLOCK_50),.rst(SW[0]));

endmodule