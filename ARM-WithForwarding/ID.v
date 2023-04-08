module ID
(
input clk,
input rst,
input [31:0] PC,
input [31:0] Instruction,
input Hazard,
input [3:0]WB_Dest,
input [31:0]WB_value,
input WB_WB_EN,
input [31:0]Status_out,
output S,
output B,
output [3:0]EXE_CMD,
output MEM_W_EN,
output MEM_R_EN,
output WB_EN,
output [31:0]PC_out,
output [31:0]Val_Rn, 
output [31:0]Val_Rm,
output imm,
output [11:0]Shift_Operand,
output [3:0]Dest,
output [23:0]Signed_imm_24,
output Two_src,
output [3:0]Rn, 
output [3:0]src2Hazard,
output [3:0] ExecuteCommand_2_hazard_Detection_Unit,
output [3:0]src_1_Rn_out,
output [3:0]src_2_mux_out // Instruction[3:0] or Instruction[15:12]
);

wire cond_out;
wire cond_not_out;
wire mux_select; // output: cond_not_out || hazard
wire [8:0]outID_CU; // all the outputs of CU
wire [8:0]outMUX_1;
wire [3:0] outMUX_2;
wire out_not_2;
wire WB_Enable_outputCU;
wire mem_read_outputCU;
wire mem_write_outputCU;
wire [3:0]ExecuteCommand_outputCU;
wire B_outputCU;
wire S_out_outputCU;

assign PC_out = PC;
assign outID_CU = {WB_Enable_outputCU, mem_read_outputCU, mem_write_outputCU, ExecuteCommand_outputCU, B_outputCU, S_out_outputCU};
assign imm = Instruction[25];
assign Shift_Operand = Instruction[11:0];
assign Signed_imm_24 = Instruction[23:0];
assign Dest = Instruction[15:12];
assign {WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD, B, S} = outMUX_1;
assign Rn = Instruction [19:16];
assign ExecuteCommand_2_hazard_Detection_Unit = ExecuteCommand_outputCU;
assign src2Hazard = outMUX_2;
assign src_1_Rn_out = Instruction[19:16];
assign src_2_mux_out = outMUX_2;

reg_file RF
(
.clk(clk),
.rst(rst),
.src1(Instruction[19:16]),
.src2(outMUX_2),
.Dest_wb(WB_Dest),
.Result_WB(WB_value),
.writeBackEn(WB_WB_EN),
.reg1(Val_Rn),
.reg2(Val_Rm)
);

ID_controlUnit ID_CU
(
.mode(Instruction[27:26]),
.opcode(Instruction[24:21]),
.S(Instruction[20]),
.ExecuteCommand(ExecuteCommand_outputCU),
.mem_read(mem_read_outputCU),
.mem_write(mem_write_outputCU),
.WB_Enable(WB_Enable_outputCU),
.B(B_outputCU),
.S_out(S_out_outputCU)
);

Condition_Check cond_check
(
.N(Status_out[31]),
.Z(Status_out[30]),
.V(Status_out[28]),
.C(Status_out[29]),
.cond(Instruction[31:28]),
.out(cond_out)
);

Not_1_bit not_1 // not1
(
.in(cond_out),
.out(cond_not_out)
);

Or_1_bit or_1 //or1
(
.in1(cond_not_out),
.in2(Hazard),
.out(mux_select)
);

Mux2_9_bit mux_1 // MUX 1
(
.in0(outID_CU),
.c(mux_select),
.out(outMUX_1)
);

Mux2_4_bit mux_2 // MUX 2: select between Rd and Rm. if the instruction want to store a value, it has to read Rd from Reg file.
(
.in0(Instruction[3:0]),
.in1(Instruction[15:12]),
.c(MEM_W_EN),
.out(outMUX_2)
);

Not_1_bit not_2 //not2
(
.in(Instruction[25]),
.out(out_not_2)
);

Or_1_bit or_2 //or2
(
.in1(out_not_2),
.in2(MEM_W_EN),
.out(Two_src)
);

endmodule 

//------------------------------------//
//        Register File (sync)
//------------------------------------//

module reg_file (input clk, rst, input [3:0] src1, src2, Dest_wb, input [31:0] Result_WB, input writeBackEn, output [31:0] reg1, reg2);
reg [31:0] Reg [14:0];

assign reg1 = Reg [src1];
assign reg2 = Reg [src2];

always@(posedge rst, negedge clk)
begin
	if (rst)begin
    Reg[0]   <= 32'b00000000_00000000_00000000_00000000;
    Reg[1]   <= 32'b00000000_00000000_00000000_00000001;
    Reg[2]   <= 32'b00000000_00000000_00000000_00000010;
    Reg[3]   <= 32'b00000000_00000000_00000000_00000011;
    Reg[4]   <= 32'b00000000_00000000_00000000_00000100;
    Reg[5]   <= 32'b00000000_00000000_00000000_00000101;
    Reg[6]   <= 32'b00000000_00000000_00000000_00000110;
    Reg[7]   <= 32'b00000000_00000000_00000000_00000111;
    Reg[8]   <= 32'b00000000_00000000_00000000_00001000;
    Reg[9]   <= 32'b00000000_00000000_00000000_00001001;
    Reg[10]  <= 32'b00000000_00000000_00000000_00001010;
    Reg[11]  <= 32'b00000000_00000000_00000000_00001011;
    Reg[12]  <= 32'b00000000_00000000_00000000_00001100;
    Reg[13]  <= 32'b00000000_00000000_00000000_00001101;
    Reg[14]  <= 32'b00000000_00000000_00000000_00001110;
	 end
 
	else if (writeBackEn)
		Reg[Dest_wb] <= Result_WB;
end

endmodule

//------------------------------------//
//        CONTROL UNIT(Async)
//------------------------------------//
module ID_controlUnit 
(
input [1:0] mode,
input [3:0] opcode,
input S,
output reg [3:0] ExecuteCommand,
output reg mem_read,
output reg mem_write,
output reg WB_Enable,
output reg B,
output reg S_out
);

// opcode
parameter[3:0]  MOV = 4'b1101, MVN = 4'b1111, ADD = 4'b0100, ADC = 4'b0101, SUB = 4'b0010,
				SBC = 4'b0110, AND = 4'b0000, ORR = 4'b1100, EOR = 4'b0001, CMP = 4'b1010,
				TST = 4'b10000, LDR = 4'b0100, STR = 4'b0100;

always@(*)
begin
	case(mode)
		2'b00:
			case(opcode)
				MOV:begin ExecuteCommand=4'b0001; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				MVN:begin ExecuteCommand=4'b1001; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				ADD:begin ExecuteCommand=4'b0010; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				ADC:begin ExecuteCommand=4'b0011; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				SUB:begin ExecuteCommand=4'b0100; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				SBC:begin ExecuteCommand=4'b0101; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				AND:begin ExecuteCommand=4'b0110; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				ORR:begin ExecuteCommand=4'b0111; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				EOR:begin ExecuteCommand=4'b1000; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=S; end
				CMP:begin ExecuteCommand=4'b0100; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b0; B=1'b0; S_out=1'b1; end
				TST:begin ExecuteCommand=4'b0110; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b0; B=1'b0; S_out=1'b1; end
				default:begin ExecuteCommand=4'b0000; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b0; B=1'b0; S_out=1'b0; end //NOP
			endcase
		2'b01:
			case(S)
				1'b1:begin ExecuteCommand=4'b0010; mem_read=1'b1; mem_write=1'b0; WB_Enable=1'b1; B=1'b0; S_out=1; end //LDR
				1'b0:begin ExecuteCommand=4'b0010; mem_read=1'b0; mem_write=1'b1; WB_Enable=1'b0; B=1'b0; S_out=0; end //STR
				default:begin ExecuteCommand=4'b0000; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b0; B=1'b0; S_out=1'b0; end //NOP
			endcase
		2'b10:begin ExecuteCommand=4'bxxxx; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b0; B=1'b1; S_out=1'b0; end //Branch
		
		default:begin ExecuteCommand=4'b0000; mem_read=1'b0; mem_write=1'b0; WB_Enable=1'b0; B=1'b0; S_out=1'b0; end //NOP
	endcase
end

endmodule


//------------------------------------//
//        CONDITION CHECK(Async)
//------------------------------------//

module Condition_Check(input N, Z, V, C, input [3:0]cond, output reg out);

always@(*)
begin
	case(cond)
		4'b0000: begin if(Z==1'b1) out=1'b1; else out=1'b0; end
		4'b0001: begin if(Z==1'b0) out=1'b1; else out=1'b0; end
		4'b0010: begin if(C==1'b1) out=1'b1; else out=1'b0; end
		4'b0011: begin if(C==1'b0) out=1'b1; else out=1'b0; end
		4'b0100: begin if(N==1'b1) out=1'b1; else out=1'b0; end
		4'b0101: begin if(N==1'b0) out=1'b1; else out=1'b0; end
		4'b0110: begin if(V==1'b1) out=1'b1; else out=1'b0; end
		4'b0111: begin if(V==1'b0) out=1'b1; else out=1'b0; end
		4'b1000: begin if(C==1'b1&&Z==1'b0) out=1'b1; else out=1'b0; end
		4'b1001: begin if(C==1'b0&&Z==1'b1) out=1'b1; else out=1'b0; end
		4'b1010: begin if(N==V) out=1'b1; else out=1'b0; end
		4'b1011: begin if(N!=V) out=1'b1; else out=1'b0; end
		4'b1100: begin if(N==V&&Z==1'b0) out=1'b1; else out=1'b0; end
		4'b1101: begin if(N!=V&&Z==1'b1) out=1'b1; else out=1'b0; end
		4'b1110: out=1'b1;
		4'b1111: out=1'b1;
		default: out=1'b1; // same as NOP, the default case happens when the cond is 4'bxxxx
	endcase
end

endmodule


//------------------------------------//
//     Combinational components
//------------------------------------//

module Not_1_bit(input in, output out);
assign out=~in;
endmodule

module Or_1_bit(input in1, in2, output out);
assign out=in1|in2;
endmodule

module Mux2_4_bit(input [3:0] in0, in1, input c, output [3:0] out);
assign out=(~c)?in0:in1;
endmodule

module Mux2_9_bit(input [8:0] in0, input c, output [8:0] out);
assign out=(~c)?in0:9'b0;
endmodule