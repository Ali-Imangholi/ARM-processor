module EXE
(
input clk,
input rst,
input C,
input Branch_Tacken,
input WB_EN,
input MEM_R_EN,
input MEM_W_EN,
input [3:0]EXE_CMD,
input S,
input [31:0]Val_1,
input [31:0]PC,
input [31:0]Val2_in1, // Val_Rm
input Val2_in2, // imm
input [11:0]Val2_in3, // Shift_operand
input [3:0]Dest, 
input [23:0]Signed_EX_imm24,
input [1:0] sel_src1_out_forwarding,
input [1:0] sel_src2_out_forwarding,
input [31:0] ALU_Res_mem,
input [31:0] WB_Value_in,
input [3:0]src_1_Rn_in,
input [3:0]src_2_mux_in, // Instruction[3:0] or Instruction[15:12]
output [31:0]PC_out,
output [3:0]Dest_out,
output [31:0]Val_Rm,
output Branch_Tacken_out,
output WB_EN_out,
output MEM_R_EN_out,
output MEM_W_EN_out,
output [31:0]Branch_Address,
output [31:0] ALU_Res,
output [31:0]Status_Out,
output [3:0] src1_forwarding,
output [3:0] src2_forwarding
);

wire [31:0] Val_2;
wire [3:0] status_bits;
wire valGen_selector;
wire [31:0] mul4;
wire [31:0] sign_extend_24_32;
wire [31:0] out_mux1; // first input of AlU
wire [31:0] out_mux2; // first input of val generator


assign PC_out=PC;
assign sign_extend_24_32 = {{8{Signed_EX_imm24[23]}}, Signed_EX_imm24[23:0]};
assign mul4= {sign_extend_24_32[29:0], 2'b00};
assign Branch_Tacken_out = Branch_Tacken;
assign Dest_out = Dest;
assign Val_Rm = out_mux2;
assign WB_EN_out = WB_EN;
assign MEM_R_EN_out = MEM_R_EN;
assign MEM_W_EN_out = MEM_W_EN;
assign src1_forwarding = src_1_Rn_in;
assign src2_forwarding = src_2_mux_in;



ALU alu_exe(.EXE_CMD(EXE_CMD), .Val_1(out_mux1), .Val_2(Val_2), .Cin(C), .ALU_Res(ALU_Res), .Status_Bits(status_bits));
Status_Register status_reg(.clk(clk), .rst(rst), .S(S), .Status_Bits(status_bits), .Status_out(Status_Out));
Adder_32_EXE adder_32(.in1(PC), .in2(mul4), .out(Branch_Address));
Or_1_bit_EXE or_1(.in1(MEM_R_EN), .in2(MEM_W_EN), .out(valGen_selector));
mux_32_bit_3_to_1 mux1_exe(.in1(Val_1), .in2(ALU_Res_mem), .in3(WB_Value_in), .sel(sel_src1_out_forwarding), .out(out_mux1));
mux_32_bit_3_to_1 mux2_exe(.in1(Val2_in1), .in2(ALU_Res_mem), .in3(WB_Value_in), .sel(sel_src2_out_forwarding), .out(out_mux2));

Val_2Generate Val_2Gen
(
.Val_Rm(out_mux2),
.imm(Val2_in2),
.Shift_operand(Val2_in3),
.valGen_select(valGen_selector),
.Val_2(Val_2)
);
endmodule




//------------------------------------//
//                ALU
//------------------------------------//
module ALU (input [3:0] EXE_CMD, input [31:0] Val_1, Val_2, input Cin, output reg[31:0] ALU_Res, output [3:0] Status_Bits);

wire N, Z;
reg C, V;

assign N=ALU_Res[31];
assign Z=(ALU_Res==0) ? 1'b1 : 1'b0;

always@(*)
begin
    case(EXE_CMD)
      4'b0001: begin ALU_Res=Val_2; C=0; V=0; end
      4'b1001: begin ALU_Res=~Val_2; C=0; V=0; end
      4'b0010: begin {C,ALU_Res}=Val_1+Val_2; V=((Val_1[31] == Val_2[31]) & (ALU_Res[31] != Val_1[31])); end
      4'b0011: begin {C,ALU_Res}=Val_1+Val_2+{31'b0,Cin}; V=((Val_1[31] == Val_2[31]) & (ALU_Res[31] != Val_1[31])); end
      4'b0100: begin {C,ALU_Res}=Val_1-Val_2; V=((Val_1[31] == ~Val_2[31]) & (ALU_Res[31] != Val_1[31])); end
      4'b0101: begin {C,ALU_Res}=Val_1-Val_2-{31'b0,~Cin}; V=((Val_1[31] == ~Val_2[31]) & (ALU_Res[31] != Val_1[31])); end
      4'b0110: begin ALU_Res=Val_1 & Val_2; C=0; V=0; end
      4'b0111: begin ALU_Res=Val_1 | Val_2; C=0; V=0; end
      4'b1000: begin ALU_Res=Val_1 ^ Val_2; C=0; V=0; end
      default: begin ALU_Res=0; C=0; V=0; end
    endcase
  end

assign Status_Bits = {N,Z,C,V}; 

endmodule

//------------------------------------//
//          Status_Register
//------------------------------------//
module Status_Register(input clk, rst, S, input [3:0] Status_Bits, output reg [31:0] Status_out);
always @(negedge clk, posedge rst) begin
	if(rst)
	Status_out <= 32'b0;
	else if (S) 
	Status_out <= {Status_Bits, 28'b0};
end
endmodule

//------------------------------------//
//            Adder_32_EXE
//------------------------------------//
module Adder_32_EXE (input [31:0] in1, in2, output [31:0] out);
  assign out=in1+in2;
endmodule

//------------------------------------//
//            Or_1_bit_EXE
//------------------------------------//
module Or_1_bit_EXE(input in1, in2, output out);
assign out=in1|in2;
endmodule

//------------------------------------//
//            mux_32_bit_3_to_1_EXE
//------------------------------------/
module mux_32_bit_3_to_1 (input [31:0] in1, in2, in3, input [1:0] sel, output [31:0] out);
assign out= (sel==2'b00) ? in1 : (sel==2'b01) ? in2 : (sel==2'b10) ? in3 : 32'b0; 
endmodule


//------------------------------------//
//            Val_2Generate
//------------------------------------//

module Val_2Generate
(
input [31:0]Val_Rm,
input imm,
input [11:0]Shift_operand,
input valGen_select,
output reg [31:0]Val_2
);

reg [63:0]tmp;

always@(*)
begin
	if(valGen_select==1'b0) // immediate
	begin
		if(imm==1'b1) // 32-bit immediate
		begin
			tmp = {24'b0 ,Shift_operand[7:0], 24'b0 ,Shift_operand[7:0]};
			tmp = tmp >> (({{1'b0},Shift_operand[11:8]}) << 1);
			Val_2 = tmp[31:0];
		end
		else if(imm==1'b0 && Shift_operand[4]==1'b0) // Immediate shifts
		begin
			case(Shift_operand[6:5])
			2'b00: Val_2 = Val_Rm << Shift_operand[11:7]; //logical shift left
			2'b01: Val_2 = Val_Rm >> Shift_operand[11:7]; //Logical shift right
			2'b10: Val_2 = Val_Rm >>> Shift_operand[11:7]; //Arithmetic shift right
			2'b11: begin tmp = {Val_Rm, Val_Rm}>>Shift_operand[11:7] ; Val_2 = tmp[31:0]; end //Rotate right 
			endcase
		end
	end
	else if(valGen_select==1'b1) // LD/ST
		Val_2 = {{20{Shift_operand[11]}}, Shift_operand[11:0]};
end
endmodule

