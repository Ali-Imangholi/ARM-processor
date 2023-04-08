module ARM(input clk, input rst);

/* 
   Do not forget Freeze & Hazard as an output from Hazard-Unit, they both are the same. (1-bit)
   Do not forget Branch_Address as an output from EXE-Unit. (32-bit)
   Do not forget wb_dest & wb_value & wb_wb_en as outputs from WB-Unit. (4-bit, 32-bit, 1-bit)
   Do not forget status register's output. (4-bit)
   
*/
// wire naming policy
//(stage)-out-> |pipeline| -in->(stage)
wire wb_en_id_out;
wire mem_r_en_id_out;
wire mem_w_en_id_out;
wire [3:0]exe_cmd_id_out;
wire [31:0]rn_id_out;
wire [31:0]rm_id_out;
wire [11:0]shift_operand_id_out;
wire imm_id_out;
wire [23:0]signed_imm_24_id_out; // note that this wire should be sigend extend in EXE-stage, so it will be 32 bit rather than 24 bit.
wire [3:0]dest_id_out;
wire [31:0]instruction_if_out; // IF output or IF-ID pipeline input
wire [31:0]instruction_id_in; // ID input or IF-ID pipeline output
wire s_id_out;
wire b_id_out;
wire two_src;
wire [31:0] PC_if_out;
wire [31:0] PC_id_in;
wire [31:0] PC_id_out;
wire [31:0] pc_exe_in;
wire [31:0] pc_exe_out;
 
// exe wires
wire wb_en_exe_in;
wire mem_r_en_exe_in;
wire mem_w_en_exe_in;
wire [3:0]exec_cmd_exe_in;
wire [31:0]rn_exe_in;
wire [31:0]rm_exe_in;
wire [11:0]shift_operand_exe_in;
wire imm_exe_in;
wire [23:0]signed_imm_24_exe_in; 
wire [3:0]dest_exe_in;
wire Branch_Tacken_exe_out; // this is output wire of exec stage and it will feedback to previous stages.
wire [31:0]Branch_Address_exe_out;
wire Branch_Tacken_exe_in;
wire C_StatusRegister_exe_in;
wire [3:0] src1;
wire [3:0] src2;
wire [3:0] src_1_Rn_out_exe_in;
wire [3:0] src_2_mux_out_exe_in;


//exe_mem wires
wire wb_en_exe_out;
wire mem_r_en_exe_out;
wire mem_w_en_exe_out;
wire [31:0] val_rm_exe_out;
wire [3:0] dest_exe_out;
wire [31:0] alu_out_exe;
wire wb_en_mem_in;
wire mem_r_en_mem_in;
wire mem_w_en_mem_in;
wire [31:0] val_rm_mem_in;
wire [3:0] dest_mem_in;
wire [31:0] alu_out_mem_in;
wire [31:0]pc_mem_in;

//ID_wires
wire [31:0] Status_Out;
wire [3:0] src2Hazard;

// hazard unit wires
wire hazard_detected;
wire [3:0] Rn;
wire [3:0] Rd;
wire [3:0] ExecuteCommand;
// mem wire
wire wb_en_mem_out;
wire mem_r_en_mem_out;
wire [31:0]alu_res_mem_out;
wire [31:0]datamemory_mem_out;
wire [3:0]dest_mem_out;
wire [31:0]pc_mem_out;

wire [31:0]dataMemory_wb_in;
wire [31:0]alu_res_wb_in;
wire mem_r_en_wb_in;
wire wb_wb_en_wb_in;
wire [3:0]wb_dest_wb_in;
wire [31:0]pc_wb_in;

//wb wires
wire [31:0]pc_wb_out;
wire wb_wb_en_wb_out;
wire [3:0]wb_dest_wb_out;
wire [31:0]wb_value_wb_out;

//Forwarding Unit wires
wire [1:0] sel_src1;
wire [1:0] sel_src2;

wire[3:0] src_1_Rn_id_out;
wire[3:0] src_2_mux_id_out;


//------------------------------------//
//             IF stage
//------------------------------------//
IF if_stage
(
.clk(clk),
.rst(rst),
.Branch_Address(Branch_Address_exe_out),
.Branch_Tacken(Branch_Tacken_exe_out),
.Freeze(hazard_detected),
.PC(PC_if_out),
.Inst_Out(instruction_if_out)
);

//------------------------------------//
//           IF-ID pipeline
//------------------------------------//
IF_ID if_id
(
.clk(clk),
.rst(rst),
.Freeze(hazard_detected),
.Flush(Branch_Tacken_exe_out),
.PC(PC_if_out),
.inst_mem_out(instruction_if_out),
.PC_out(PC_id_in),
.instruction(instruction_id_in)
);

//------------------------------------//
//             HAZARD_UNIT 
//------------------------------------//

hazard_Detection_Unit HazardDetectionUnit
(
.src1(Rn),
.src2(src2Hazard),
.Exe_Dest(dest_exe_out),
.Exe_WB_EN(wb_en_exe_out),
.Mem_R_EN(mem_r_en_exe_out),
.Mem_Dest(dest_mem_out),
.Mem_WB_EN(wb_en_mem_out),
.Two_src(two_src),
.ExecuteCommand(ExecuteCommand),
.hasForwarding(1'b1), // enable/disable forwarding unit effect
.hazard_detected(hazard_detected)
);

//------------------------------------//
//              ID stage
//------------------------------------//
ID id_stage
(
.clk(clk),
.rst(rst),
.PC(PC_id_in),
.Instruction(instruction_id_in),
.Hazard(hazard_detected),
.WB_Dest(wb_dest_wb_out),
.WB_value(wb_value_wb_out),
.WB_WB_EN(wb_wb_en_wb_out),
.Status_out(Status_Out),
.S(s_id_out),
.B(b_id_out),
.EXE_CMD(exe_cmd_id_out),
.MEM_W_EN(mem_w_en_id_out),
.MEM_R_EN(mem_r_en_id_out),
.WB_EN(wb_en_id_out),
.PC_out(PC_id_out), 
.Val_Rn(rn_id_out),
.Val_Rm(rm_id_out),
.imm(imm_id_out),
.Shift_Operand(shift_operand_id_out),
.Dest(dest_id_out),
.Signed_imm_24(signed_imm_24_id_out),
.Two_src(two_src),
.Rn(Rn),
.src2Hazard(src2Hazard),
.ExecuteCommand_2_hazard_Detection_Unit(ExecuteCommand),
.src_1_Rn_out(src_1_Rn_id_out),
.src_2_mux_out(src_2_mux_id_out)
);
//------------------------------------//
//           ID-Exe pipeline
//------------------------------------//
ID_EXE id_exe
(
.clk(clk),
.rst(rst),
.WB_EN(wb_en_id_out),
.MEM_R_EN(mem_r_en_id_out),
.MEM_W_EN(mem_w_en_id_out),
.EXE_CMD(exe_cmd_id_out),
.B(b_id_out),
.S(s_id_out),
.PC(PC_id_out), 
.Val_Rn(rn_id_out),
.Val_Rm(rm_id_out),
.imm(imm_id_out),
.shift_operand(shift_operand_id_out),
.Signed_imm_24(signed_imm_24_id_out),
.Dest(dest_id_out), 
.C_StatusRegister_ID_EXE_in(Status_Out[31]),
.Flush(Branch_Tacken_exe_out),
.src_1_Rn_in(src_1_Rn_id_out),
.src_2_mux_in(src_2_mux_id_out),
.C_StatusRegister_ID_EXE_out(C_StatusRegister_exe_in),
.WB_EN_out(wb_en_exe_in),
.MEM_R_EN_out(mem_r_en_exe_in),
.MEM_W_EN_out(mem_w_en_exe_in),
.EXE_CMD_out(exec_cmd_exe_in),
.Branch_Tacken(Branch_Tacken_exe_in),
.S_out(s_exe_in),
.PC_out(pc_exe_in),
.Val_1(rn_exe_in),
.Val_2_Generate_in_1(rm_exe_in),
.Val_2_Generate_in_2(imm_exe_in),
.Val_2_Generate_in_3(shift_operand_exe_in),
.Signed_EX_imm24(signed_imm_24_exe_in), // we have to extend it in the exec stage.
.Dest_out(dest_exe_in),
.src_1_Rn_out(src_1_Rn_out_exe_in),
.src_2_mux_out(src_2_mux_out_exe_in)
);

//------------------------------------//
//             EXEC stage
//------------------------------------//
EXE exec_stage
(
.clk(clk),
.rst(rst),
.C(C_StatusRegister_exe_in),
.Branch_Tacken(Branch_Tacken_exe_in),
.WB_EN(wb_en_exe_in),
.MEM_R_EN(mem_r_en_exe_in),
.MEM_W_EN(mem_w_en_exe_in),
.EXE_CMD(exec_cmd_exe_in),
.S(s_exe_in),
.Val_1(rn_exe_in),
.PC(pc_exe_in),
.Val2_in1(rm_exe_in), // Val_Rm
.Val2_in2(imm_exe_in), // imm
.Val2_in3(shift_operand_exe_in), // Shift_operand
.Dest(dest_exe_in), 
.Signed_EX_imm24(signed_imm_24_exe_in),
.sel_src1_out_forwarding(sel_src1),
.sel_src2_out_forwarding(sel_src2),
.ALU_Res_mem(alu_out_mem_in),
.WB_Value_in(wb_value_wb_out),
.src_1_Rn_in(src_1_Rn_out_exe_in),
.src_2_mux_in(src_2_mux_out_exe_in),
.PC_out(pc_exe_out),
.Dest_out(dest_exe_out),
.Val_Rm(val_rm_exe_out),
.Branch_Tacken_out(Branch_Tacken_exe_out),
.WB_EN_out(wb_en_exe_out),
.MEM_R_EN_out(mem_r_en_exe_out),
.MEM_W_EN_out(mem_w_en_exe_out),
.Branch_Address(Branch_Address_exe_out),
.ALU_Res(alu_out_exe),
.Status_Out(Status_Out),
.src1_forwarding(src1),
.src2_forwarding(src2)
);


//------------------------------------//
//           EXE_MEM Pipeline
//------------------------------------//
EXE_MEM exe_mem
(
.clk(clk), 
.rst(rst),
.pc(pc_exe_out),
.pc_out(pc_mem_in), 
.WB_EN(wb_en_exe_out), 
.MEM_R_EN(mem_r_en_exe_out), 
.MEM_W_EN(mem_w_en_exe_out), 
.Val_Rm(val_rm_exe_out), 
.Dest(dest_exe_out),  
.ALU_Res(alu_out_exe),
.WB_EN_out(wb_en_mem_in), 
.MEM_R_EN_out(mem_r_en_mem_in), 
.MEM_W_EN_out(mem_w_en_mem_in), 
.Val_Rm_out(val_rm_mem_in),  
.Dest_out(dest_mem_in), 
.ALU_Res_out(alu_out_mem_in)
);

//------------------------------------//
//             MEM Stage
//------------------------------------//
MEM mem_stage
(
.clk(clk),
.rst(rst),
.WB_EN(wb_en_mem_in),
.MEM_R_EN(mem_r_en_mem_in),
.MEM_W_EN(mem_w_en_mem_in),
.ALU_Res(alu_out_mem_in),
.Val_Rm(val_rm_mem_in),
.Dest(dest_mem_in),
.pc(pc_mem_in),
.WB_EN_out(wb_en_mem_out),
.MEM_R_EN_out(mem_r_en_mem_out),
.ALU_Res_out(alu_res_mem_out),
.DataMemory_out(datamemory_mem_out),
.MEM_Dest(dest_mem_out),
.pc_out(pc_mem_out)
);

//------------------------------------//
//             MEM_WB Pipeline
//------------------------------------//
MEM_WB mem_wb
(
.clk(clk),
.rst(rst),
.WB_EN(wb_en_mem_out),
.MEM_R_EN(mem_r_en_mem_out),
.ALU_Res(alu_res_mem_out),
.DataMemory(datamemory_mem_out),
.Dest(dest_mem_out),
.pc(pc_mem_out),
.DataMemory_out(dataMemory_wb_in),
.ALU_Res_out(alu_res_wb_in),
.MEM_R_EN_out(mem_r_en_wb_in),
.WB_WB_EN(wb_wb_en_wb_in),
.WB_Dest(wb_dest_wb_in),
.pc_out(pc_wb_in)
);

//------------------------------------//
//             Forwarding_Unit
//------------------------------------//
Forwarding_Unit forwardingUnit
(
.Dest_mem(dest_mem_in), 
.Dest_wb(wb_dest_wb_in), 
.WB_EN_mem(wb_en_mem_in), 
.WB_EN_wb(wb_wb_en_wb_in), 
.src1(src1), 
.src2(src2),
.sel_src1(sel_src1), 
.sel_src2(sel_src2)
); 
//------------------------------------//
//             WB Stage
//------------------------------------//
WB wb_stage
(
.ALU_Res_in_1(alu_res_wb_in),
.pc(pc_wb_in),
.pc_out(pc_wb_out),
.Data_Mem_out_in_2(dataMemory_wb_in),
.MEM_R_EN(mem_r_en_wb_in),
.WB_WB_EN(wb_wb_en_wb_in),
.WB_Dest(wb_dest_wb_in),
.WB_WB_EN_out(wb_wb_en_wb_out),
.WB_Dest_out(wb_dest_wb_out),
.WB_Value(wb_value_wb_out)
);

endmodule

