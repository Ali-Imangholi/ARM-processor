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

reg [150:0] cache [0:63]; //[150:87(BLK_0+BLK_1),86:77,76]+[75:12(BLK_0+BLK_1),11:2,1]+[0]

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
assign Hit_way_0=(cache[index][1]==1'b1)?(tag==cache[index][11:2])?1'b1:1'b0 :1'b0;
assign Hit_way_1=(cache[index][76]==1'b1)?(tag==cache[index][86:77])?1'b1:1'b0 :1'b0;
assign Miss= ~Hit_way_0 & ~Hit_way_1;

// Reading From Cache: If the cache has the data, it will send it on rdata, otherwise, rdata will be drived by SRAM
assign rdata=(Hit_way_0==1'b1)?(wordOffset==1'b0)?cache[index][43:12]:cache[index][75:44]:
		     (Hit_way_1==1'b1)?(wordOffset==1'b0)?cache[index][118:87]:cache[index][150:119]:
			 (wordOffset==1'b0)?sram_rdata[31:0]:sram_rdata[63:32];

// Update 0 based on Last Use
always@(*)
begin
	if(Hit_way_0==1'b1)
		cache[index][0]=1'b0;
		
	else if(Hit_way_1==1'b1)
		cache[index][0]=1'b1;
	
	else
		cache[index][0]=cache[index][0];
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
		// Reset 0, 1, and 76
		for(i=0; i<64; i=i+1)
		begin
			cache[i][0]  = 1'b0;
			cache[i][1]  = 1'b0;
			cache[i][76] = 1'b0;
		end
	end
	
	//Update Cache by SRAM because of Miss
	else if(MEM_R_EN==1'b1 && Miss && sram_ready)
	begin
		if(cache[index][0]==1'b0)
		begin
			cache[index][76]=1'b1;
			cache[index][86:77]=tag;
			cache[index][150:87]=sram_rdata;
			cache[index][0]=1'b1;
		end
		
		else //cache[index][0]==1'b1
		begin
			cache[index][1]=1'b1;
			cache[index][11:2]=tag;
			cache[index][75:12]=sram_rdata;
			cache[index][0]=1'b0;
		end
	end
	
	// In case of writing data into storge: first of all, data will be written into the SRAM, and meanwhile, if the address is exist in the Cache, it will be invalid
	//-because it won't be point to the new data @ SRAM
	else if(Hit_way_0==1'b1)
	begin
		if(MEM_W_EN==1'b1)
		begin
			cache[index][1]=1'b0;
		end
	end
	
	else if(Hit_way_1==1'b1)
	begin
		if(MEM_W_EN==1'b1)
		begin
			cache[index][76]=1'b0;
		end
	end
	
end

endmodule