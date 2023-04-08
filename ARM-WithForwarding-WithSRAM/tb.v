`timescale 1ns/1ns
module tb();

reg CLK=1'b0;
reg RST=1'b0;

ARM arm(.clk(CLK), .rst(RST));

initial
begin
    #50 RST=1'b1;
    #50 RST=1'b0;
    #5000 $stop;
end 

always #5 CLK = ~CLK;

endmodule
