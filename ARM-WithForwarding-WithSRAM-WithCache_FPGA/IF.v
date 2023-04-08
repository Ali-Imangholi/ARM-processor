module IF
(
input clk,
input rst,
input [31:0]Branch_Address,
input Branch_Tacken,
input Freeze,
output [31:0]PC,
output [31:0]Inst_Out
);

wire [31:0] PC_reg_out;
wire [31:0] IF_mux_out;

Adder adder(.pc(PC_reg_out), .out(PC));
inst_mem mem(.addr(PC_reg_out), .inst(Inst_Out));
IF_MUX mux(.PC(PC), .Branch_Address(Branch_Address), .Branch_Tacken(Branch_Tacken), .IF_mux_out(IF_mux_out));
PC_reg pc_reg(.clk(clk), .rst(rst), .IF_mux_out(IF_mux_out), .PC_reg_out(PC_reg_out), .Freeze(Freeze));


endmodule


//------------------------------------//
//                ADDER
//------------------------------------//
module Adder (input [31:0] pc, output [31:0] out);
  assign out=pc+32'b00100;
endmodule

//------------------------------------//
//          Instruction_Memory
//------------------------------------//
module inst_mem(input [31:0] addr, output [31:0] inst);
  wire [7:0]inst_mem[0:187];
  assign inst={inst_mem[addr+3],inst_mem[addr+2],inst_mem[addr+1],inst_mem[addr+0]};
  
            assign {inst_mem[3], inst_mem[2], inst_mem[1], inst_mem[0]} = 32'b1110_00_1_1101_0_0000_0000_000000010100;      //  MOV R0 = 20           R0 = 20
            assign {inst_mem[7], inst_mem[6], inst_mem[5], inst_mem[4]} = 32'b1110_00_1_1101_0_0000_0001_101000000001;      //  MOV R1 ,#4096         R1 = 4096
            assign {inst_mem[11], inst_mem[10], inst_mem[9], inst_mem[8]} = 32'b1110_00_1_1101_0_0000_0010_000100000011;   //   MOV R2 ,#0xC0000000    R2 = -1073741824
            assign {inst_mem[15], inst_mem[14], inst_mem[13], inst_mem[12]} = 32'b1110_00_0_0100_1_0010_0011_000000000010; //   ADDS R3 ,R2,R2         R3 = -2147483648
            assign {inst_mem[19], inst_mem[18], inst_mem[17], inst_mem[16]} =  32'b1110_00_0_0101_0_0000_0100_000000000000; //ADC R4 ,R0,R0 //R4 = 41
            assign {inst_mem[23], inst_mem[22], inst_mem[21], inst_mem[20]} = 32'b1110_00_0_0010_0_0100_0101_000100000100; //SUB R5 ,R4,R4,LSL #2 //R5 = -123
            assign {inst_mem[27], inst_mem[26], inst_mem[25], inst_mem[24]} = 32'b1110_00_0_0110_0_0000_0110_000010100000; //SBC R6 ,R0,R0,LSR #1//R6 = 10
            assign {inst_mem[31], inst_mem[30], inst_mem[29], inst_mem[28]} = 32'b1110_00_0_1100_0_0101_0111_000101000010; //ORR R7,R5,R2,ASR #2//R7 = -123
            assign {inst_mem[35], inst_mem[34], inst_mem[33], inst_mem[32]} = 32'b1110_00_0_0000_0_0111_1000_000000000011; //AND R8,R7,R3   R8 = -2147483648
            assign {inst_mem[39], inst_mem[38], inst_mem[37], inst_mem[36]} = 32'b1110_00_0_1111_0_0000_1001_000000000110; //MVN R9,R6//R9 = -11
            assign {inst_mem[43], inst_mem[42], inst_mem[41], inst_mem[40]} = 32'b1110_00_0_0001_0_0100_1010_000000000101; //EOR R10,R4,R5//R10 = -84
            assign {inst_mem[47], inst_mem[46], inst_mem[45], inst_mem[44]} = 32'b1110_00_0_1010_1_1000_0000_000000000110; //CMP R8,R6
            assign {inst_mem[51], inst_mem[50], inst_mem[49], inst_mem[48]} = 32'b0001_00_0_0100_0_0001_0001_000000000001; //ADDNE R1,R1,R1//R1 = 8192
            assign {inst_mem[55], inst_mem[54], inst_mem[53], inst_mem[52]} = 32'b1110_00_0_1000_1_1001_0000_000000001000; //TST R9,R8
            assign {inst_mem[59], inst_mem[58], inst_mem[57], inst_mem[56]} = 32'b0000_00_0_0100_0_0010_0010_000000000010; //ADDEQ R2 ,R2,R2   //R2 = -1073741824
            assign {inst_mem[63], inst_mem[62], inst_mem[61], inst_mem[60]} = 32'b1110_00_1_1101_0_0000_0000_101100000001; //MOV R0,#1024//R0 = 1024
            assign {inst_mem[67], inst_mem[66], inst_mem[65], inst_mem[64]} = 32'b1110_01_0_0100_0_0000_0001_000000000000; //STR R1,[R0],#0//MEM[1024] = 8192
            assign {inst_mem[71], inst_mem[70], inst_mem[69], inst_mem[68]} = 32'b1110_01_0_0100_1_0000_1011_000000000000; //LDR R11,[R0],#0//R11 = 8192
            assign {inst_mem[75], inst_mem[74], inst_mem[73], inst_mem[72]} = 32'b1110_01_0_0100_0_0000_0010_000000000100; //STR R2,[R0],#4//MEM[1028] = -1073741824
            assign {inst_mem[79], inst_mem[78], inst_mem[77], inst_mem[76]} = 32'b1110_01_0_0100_0_0000_0011_000000001000; //STR    R3 ,[R0],#8//MEM[1032] = -2147483648
            assign {inst_mem[83], inst_mem[82], inst_mem[81], inst_mem[80]} = 32'b1110_01_0_0100_0_0000_0100_000000001101; //STR    R4 ,[R0],#13    //MEM[1036] = 41
            assign {inst_mem[87], inst_mem[86], inst_mem[85], inst_mem[84]} = 32'b1110_01_0_0100_0_0000_0101_000000010000; //STR R5,[R0],#16//MEM[1040] = -123
            assign {inst_mem[91], inst_mem[90], inst_mem[89], inst_mem[88]} = 32'b1110_01_0_0100_0_0000_0110_000000010100; //STR R6,[R0],#20 //MEM[1044] = 10
            assign {inst_mem[95], inst_mem[94], inst_mem[93], inst_mem[92]} = 32'b1110_01_0_0100_1_0000_1010_000000000100; //LDR R10,[R0],#4 //R10 = -1073741824
            assign {inst_mem[99], inst_mem[98], inst_mem[97], inst_mem[96]} = 32'b1110_01_0_0100_0_0000_0111_000000011000; //STR R7,[R0],#24    //MEM[1048] = -123
            assign {inst_mem[103], inst_mem[102], inst_mem[101], inst_mem[100]} = 32'b1110_00_1_1101_0_0000_0001_000000000100; //MOV R1,#4//R1 = 4
            assign {inst_mem[107], inst_mem[106], inst_mem[105], inst_mem[104]} = 32'b1110_00_1_1101_0_0000_0010_000000000000; //MOV R2,#0//R2 = 0
            assign {inst_mem[111], inst_mem[110], inst_mem[109], inst_mem[108]} = 32'b1110_00_1_1101_0_0000_0011_000000000000; //MOV R3,#0//R3 = 0
            assign {inst_mem[115], inst_mem[114], inst_mem[113], inst_mem[112]} = 32'b1110_00_0_0100_0_0000_0100_000100000011; //ADD R4,R0,R3,LSL #2
            assign {inst_mem[119], inst_mem[118], inst_mem[117], inst_mem[116]} = 32'b1110_01_0_0100_1_0100_0101_000000000000; //LDR R5,[R4],#0
            assign {inst_mem[123], inst_mem[122], inst_mem[121], inst_mem[120]} = 32'b1110_01_0_0100_1_0100_0110_000000000100; //LDR R6,[R4],#4
            assign {inst_mem[127], inst_mem[126], inst_mem[125], inst_mem[124]} = 32'b1110_00_0_1010_1_0101_0000_000000000110; //CMP R5,R6
            assign {inst_mem[131], inst_mem[130], inst_mem[129], inst_mem[128]} = 32'b1100_01_0_0100_0_0100_0110_000000000000; //STRGT R6,[R4],#0
            assign {inst_mem[135], inst_mem[134], inst_mem[133], inst_mem[132]} = 32'b1100_01_0_0100_0_0100_0101_000000000100; //STRGT R5,[R4],#4
            assign {inst_mem[139], inst_mem[138], inst_mem[137], inst_mem[136]} = 32'b1110_00_1_0100_0_0011_0011_000000000001; //ADD R3,R3,#1
            assign {inst_mem[143], inst_mem[142], inst_mem[141], inst_mem[140]} = 32'b1110_00_1_1010_1_0011_0000_000000000011; //CMP R3,#3
            assign {inst_mem[147], inst_mem[146], inst_mem[145], inst_mem[144]} = 32'b1011_10_1_0_111111111111111111110111  ; //BLT#-9
            assign {inst_mem[151], inst_mem[150], inst_mem[149], inst_mem[148]} = 32'b1110_00_1_0100_0_0010_0010_000000000001; //ADD R2,R2,#1
            assign {inst_mem[155], inst_mem[154], inst_mem[153], inst_mem[152]} = 32'b1110_00_0_1010_1_0010_0000_000000000001;//CMP R2,R1
            assign {inst_mem[159], inst_mem[158], inst_mem[157], inst_mem[156]} = 32'b1011_10_1_0_111111111111111111110011  ;//BLT#-13
            assign {inst_mem[163], inst_mem[162], inst_mem[161], inst_mem[160]} = 32'b1110_01_0_0100_1_0000_0001_000000000000;//LDR R1 ,[R0],#0//    R1 = -2147483648
            assign {inst_mem[167], inst_mem[166], inst_mem[165], inst_mem[164]} = 32'b1110_01_0_0100_1_0000_0010_000000000100;//LDR R2 ,[R0],#4//    R2 = -1073741824
            assign {inst_mem[171], inst_mem[170], inst_mem[169], inst_mem[168]} = 32'b1110_01_0_0100_1_0000_0011_000000001000;//STR R3 ,[R0],#8//    R3 = 41
            assign {inst_mem[175], inst_mem[174], inst_mem[173], inst_mem[172]} = 32'b1110_01_0_0100_1_0000_0100_000000001100;//STR R4 ,[R0],#12//   R4 = 8192
            assign {inst_mem[179], inst_mem[178], inst_mem[177], inst_mem[176]} = 32'b1110_01_0_0100_1_0000_0101_000000010000;//STR R5 ,[R0],#16//   R5= -123
            assign {inst_mem[183], inst_mem[182], inst_mem[181], inst_mem[180]} = 32'b1110_01_0_0100_1_0000_0110_000000010100;//STR R6 ,[R0],#20//   R6 = 10
            assign {inst_mem[187], inst_mem[186], inst_mem[185], inst_mem[184]} = 32'b1110_10_1_0_111111111111111111111111;//B#-1
  
endmodule

//------------------------------------//
//                MUX
//------------------------------------//
module IF_MUX
(
input [31:0]PC,
input [31:0]Branch_Address,
input Branch_Tacken, // mux select
output [31:0]IF_mux_out
);

assign IF_mux_out = (Branch_Tacken == 1'b0) ? PC : Branch_Address;
endmodule

//------------------------------------//
//                PC
//------------------------------------//
module PC_reg
(
input clk, 
input rst,
input [31:0]IF_mux_out,
input Freeze, // Reg Enable
output reg [31:0]PC_reg_out
);

always@(posedge clk, posedge rst)
begin
if(rst == 1'b1)
	PC_reg_out <= 32'b0;
else
begin
if(Freeze == 1'b1)
	PC_reg_out <= PC_reg_out;
else
	PC_reg_out <= IF_mux_out;
end
end
endmodule
