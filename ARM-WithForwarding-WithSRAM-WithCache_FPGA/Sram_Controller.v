module Sram_Controller(
input clk,
input rst,
//From Memory Stage
input wr_en,
input rd_en,
input [31:0] address,
input [31:0] writData,
//To Next Stage
output reg [63:0] readData,
//For freeze Other Stage
output reg ready,
inout  [15:0] SRAM_DQ,
output reg [17:0] SRAM_ADDR,
output SRAM_UB_N,
output SRAM_LB_N,
output reg SRAM_WE_N,
output SRAM_CE_N,
output SRAM_OE_N
);

assign {SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N} = 4'b1111;


// controller stages
reg [2:0] ns, ps;
parameter [2:0] S_0 = 3'b000,
				S_1 = 3'b001,
				S_2 = 3'b010,
				S_3 = 3'b011,
				S_4 = 3'b100,
				S_5 = 3'b101;
				
always@(posedge clk, posedge rst)
begin
	if(rst==1'b1)
		ps<=S_0;
	else
		ps<=ns;
end

always@(ps, wr_en, rd_en)
begin
	case(ps)
		S_0: if(wr_en | rd_en) ns <= S_1; else ns <= S_0; // if wr_en=1 or rd_en=1 next stage is S_1 otherwise is S_0
		S_1: ns=S_2;
		S_2: ns=S_3;
		S_3: ns=S_4;
		S_4: ns=S_5;
		S_5: ns=S_0;
	endcase
end

always@(ps, wr_en, rd_en)
begin
	//initial vlaue
	ready=1'b0;
	SRAM_WE_N=1'b1; // deactive high
	
	case(ps)
		S_0:
		begin
		if(wr_en | rd_en)
			ready=1'b0;
		else
			ready=1'b1;
		end
		
		S_1:
		begin
			if(wr_en==1'b1)
			begin
				SRAM_ADDR=(address-32'd1024)>>1; //low address
				SRAM_WE_N=1'b0; // active low
				ready=1'b0;
			end
			else // rd_en==1'b1
			begin
				SRAM_ADDR=(address-32'd1024)>>1; //low address
				SRAM_WE_N=1'b1; // deactive high
				ready=1'b0;
			end
		end
		
		S_2:
		begin
			if(wr_en==1'b1)
			begin
				SRAM_ADDR=((address-32'd1024)>>1)+3'd1; //high address=low address+1
				SRAM_WE_N=1'b0; // active low
				ready=1'b0;
			end
			else // rd_en==1'b1
			begin
				SRAM_ADDR=((address-32'd1024)>>1)+3'd1; //high address=low address+1
				SRAM_WE_N=1'b1; // deactive high
				readData[15:0]=SRAM_DQ;
				ready=1'b0;				
			end
		end
		
		S_3:
		begin
			if(rd_en==1'b1)
			begin
				SRAM_ADDR=((address-32'd1024)>>1)+3'd2; //high address=low address+1
				SRAM_WE_N=1'b1; // deactive high
				readData[31:16]=SRAM_DQ;
			end			
			ready=1'b0;
		end
		
		S_4:
		begin
			if(rd_en==1'b1)
			begin
				SRAM_ADDR=((address-32'd1024)>>1)+3'd3; //high address=low address+1
				SRAM_WE_N=1'b1; // deactive high
				readData[47:32]=SRAM_DQ;
			end			
			ready=1'b0;
		end
		
		S_5:
		begin
			if(rd_en==1'b1)
				readData[63:48]=SRAM_DQ;
				
			ready=1'b1;
		end
		
	endcase
end

assign SRAM_DQ=(SRAM_WE_N==1'b0 && ps==S_1)?writData[15:0]:// write low data
               (SRAM_WE_N==1'b0 && ps==S_2)?writData[31:16]:// write high data
			    16'dz;
				
endmodule