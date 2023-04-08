module MEM
(
input clk,
input rst,
input WB_EN,
input MEM_R_EN,
input MEM_W_EN,
input [31:0] ALU_Res,
input [31:0] Val_Rm,
input [3:0] Dest,
input [31:0] pc,
output WB_EN_out,
output MEM_R_EN_out,
output [31:0]ALU_Res_out,
output [31:0]DataMemory_out,
output [3:0] MEM_Dest,
output [31:0] pc_out,
// Sram Controller
output ready,
inout  [15:0] SRAM_DQ,
output [17:0] SRAM_ADDR,
output SRAM_WE_N
);

wire sram_ready;
wire [63:0] sram_rdata;
wire [31:0] sram_address;
wire write_enb;
wire read_enb;
wire [31:0] sram_wdata;

assign pc_out = pc;
assign WB_EN_out=(ready==1'b1)?WB_EN:1'b0; // freezing WB_EN_out based on ready signal of SRAM controller
assign MEM_R_EN_out = MEM_R_EN;
assign MEM_Dest = Dest;
assign ALU_Res_out = ALU_Res;

cache_controller CACHE_CONTROLLER(
.clk(clk),
.rst(rst),
.MEM_R_EN(MEM_R_EN),
.MEM_W_EN(MEM_W_EN),
.address(ALU_Res),
.wdata(Val_Rm),
.sram_rdata(sram_rdata),
.sram_ready(sram_ready),
.sram_address(sram_address),
.sram_wdata(sram_wdata),
.write_enb(write_enb),
.read_enb(read_enb),
.rdata(DataMemory_out),
.ready(ready)
);

Sram_Controller SRAM_CONTROLLER(
.clk(clk),
.rst(rst),
.wr_en(write_enb),
.rd_en(read_enb),
.address(sram_address),
.writData(sram_wdata),
.readData(sram_rdata),
.ready(sram_ready),
.SRAM_DQ(SRAM_DQ),
.SRAM_ADDR(SRAM_ADDR),
.SRAM_WE_N(SRAM_WE_N)
);

endmodule
