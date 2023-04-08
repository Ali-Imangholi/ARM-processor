module hazard_Detection_Unit
(
input [3:0]src1,
input [3:0]src2,
input [3:0]Exe_Dest,
input Exe_WB_EN,
input [3:0] Mem_Dest,
input Mem_WB_EN,
input Two_src,
input [3:0]ExecuteCommand, // ExecuteCommand[Id stage] in order to check weather a source of a command is important or not.
output reg hazard_detected
);

parameter[3:0]  MOV = 4'b0001, MVN = 4'b1001; // MOV and MVN execution code

always@(*)
begin
	if(src1 == Exe_Dest && Exe_WB_EN==1'b1 && ExecuteCommand != MOV && ExecuteCommand != MVN)
		hazard_detected = 1'b1;
	else if(src1 == Mem_Dest && Mem_WB_EN==1'b1 && ExecuteCommand != MOV && ExecuteCommand != MVN)
		hazard_detected = 1'b1;
	else if(src2 == Exe_Dest && Exe_WB_EN==1'b1 && Two_src==1'b1)
		hazard_detected = 1'b1;
	else if(src2 == Mem_Dest && Mem_WB_EN==1'b1 && Two_src==1'b1)
		hazard_detected = 1'b1;
	else
		hazard_detected = 1'b0;
end


endmodule