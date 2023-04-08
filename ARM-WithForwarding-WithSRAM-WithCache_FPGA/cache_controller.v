`define WAY_1_DATA   150:87
`define WAY_1_TAG    86:77
`define WAY_1_VALID  76
`define WAY_1_BLK_0  118:87
`define WAY_1_BLK_1  150:119

`define WAY_0_DATA   75:12
`define WAY_0_TAG    11:2
`define WAY_0_VALID  1
`define WAY_0_BLK_0  43:12
`define WAY_0_BLK_1  75:44

`define LRU          0

module cache_controller
(
input clk,
input rst,
input MEM_R_EN,
input MEM_W_EN,
input [31:0] address,
input [31:0] wdata,
input [63:0]sram_rdata,
input sram_ready,
output [31:0] sram_address,
output [31:0] sram_wdata,
output reg write_enb,
output reg read_enb,
output [31:0] rdata,
output reg ready
);

reg [150:0] cache [0:63]; //[WAY_1_DATA(BLK_0+BLK_1),WAY_1_TAG,WAY_1_VALID]+[WAY_0_DATA(BLK_0+BLK_1),WAY_0_TAG,WAY_0_VALID]+[LRU]

// Extracting Address Elements
wire [16:0]cacheAddress;   //[tag,index,wordOffset]
wire       wordOffset;
wire [5:0] index;
wire [9:0] tag;
assign cacheAddress=((address-32'd1024)>>2);
assign wordOffset=address[0]; //word offset
assign index=address[6:1];    //index 
assign tag=address[16:7];     //tag 

// Hit/Miss
wire Hit_way_0;
wire Hit_way_1;
wire Miss;
assign Hit_way_0=(cache[index][`WAY_0_VALID]==1'b1)?(tag==cache[index][`WAY_0_TAG])?1'b1:1'b0 :1'b0;
assign Hit_way_1=(cache[index][`WAY_1_VALID]==1'b1)?(tag==cache[index][`WAY_1_TAG])?1'b1:1'b0 :1'b0;
assign Miss= ~Hit_way_0 & ~Hit_way_1;

// Reading From Cache: If the cache has the data, it will send it on rdata, otherwise, rdata will be drived by SRAM
assign rdata=(Hit_way_0==1'b1)?(wordOffset==1'b0)?cache[index][`WAY_0_BLK_0]:cache[index][`WAY_0_BLK_1]:
		     (Hit_way_1==1'b1)?(wordOffset==1'b0)?cache[index][`WAY_1_BLK_0]:cache[index][`WAY_1_BLK_1]:
			 (wordOffset==1'b0)?sram_rdata[31:0]:sram_rdata[63:32];

// Update LRU based on Last Use
always@(*)
begin
	if(Hit_way_0==1'b1)
		cache[index][`LRU]=1'b0;
		
	else if(Hit_way_1==1'b1)
		cache[index][`LRU]=1'b1;
	
	else
		cache[index][`LRU]=cache[index][`LRU];
end

// Total Ready Signal
always@(*)
begin
	if(MEM_W_EN==1'b1)
		ready=sram_ready;
	else if(MEM_R_EN==1'b1)
	begin
		if(Hit_way_0==1'b1 || Hit_way_1==1'b1)
			ready=1'b1;
		else
			ready=sram_ready;
	end
	
	else
		ready=1'b1;
	
end

// Set SRAM Signals
assign sram_address=address;
assign sram_wdata=wdata;

// These signals control "wr_en" and "rd_en" of the SRAM controller
always@(*)
begin
	read_enb=1'b0;
	write_enb=1'b0;
	
	if(MEM_R_EN==1'b1&&Miss==1'b1)
		read_enb=1'b1;
	else if(MEM_W_EN==1'b1)
		write_enb=1'b1;
	
end

integer i;
always@(posedge clk, posedge rst)
begin
	if(rst==1'b1)
	begin
		// Reset LRU, WAY_0_VALID, and WAY_1_VALID
		for(i=0; i<64; i=i+1)
		begin
			cache[i][`LRU]  = 1'b0;
			cache[i][`WAY_0_VALID]  = 1'b0;
			cache[i][`WAY_1_VALID] = 1'b0;
		end
	end
/*
	//Update Cache by SRAM because of Miss
	else if(MEM_R_EN==1'b1 && Miss==1'b1 && sram_ready==1'b1)
	begin
		if(cache[index][`LRU]==1'b0)
		begin
			cache[index][`WAY_1_VALID]=1'b1;
			cache[index][`WAY_1_TAG]=tag;
			cache[index][`WAY_1_DATA]=sram_rdata;
			cache[index][`LRU]=1'b1;
		end
		
		else //cache[index][LRU]==1'b1
		begin
			cache[index][`WAY_0_VALID]=1'b1;
			cache[index][`WAY_0_TAG]=tag;
			cache[index][`WAY_0_DATA]=sram_rdata;
			cache[index][`LRU]=1'b0;
		end
	end
	*/
	// In case of writing data into storge: first of all, data will be written into the SRAM, and meanwhile, if the address is exist in the Cache, it will be invalid
	//-because it won't be point to the new data @ SRAM
	else if(Hit_way_0==1'b1)
	begin
		if(MEM_W_EN==1'b1)
		begin
			cache[index][`WAY_0_VALID]=1'b0;
		end
	end
	
	else if(Hit_way_1==1'b1)
	begin
		if(MEM_W_EN==1'b1)
		begin
			cache[index][`WAY_1_VALID]=1'b0;
		end
	end
	
end

endmodule