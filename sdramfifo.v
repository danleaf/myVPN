module sdramfifo
#(
	parameter BANK_WIDTH = 2,
	parameter ROW_WIDTH = 13,
	parameter COL_WIDTH = 9,
	parameter DATA_WIDTH = 16,
	parameter BURST_POW_SIZE = 3,
	parameter INCACHE_POW_SIZE = 3
)
(
	input i_clk,i_rst_n,i_wr,
	input [DATA_WIDTH-1:0] i_data,
	output o_busy,o_full,
	
	//connect with SDRAM chip
	output [BANK_WIDTH-1:0] o_sdram_ba,
	output [ROW_WIDTH-1:0] o_sdram_addr,
	inout [DATA_WIDTH-1:0] io_sdram_data,
	output o_sdram_clk,
	output o_sdram_udqm,
	output o_sdram_ldqm,
	output o_sdram_ras,
	output o_sdram_cas,
	output o_sdram_we,
	output o_sdram_cke,
	output o_sdram_cs
);
	localparam INCACHE_SIZE = (1 << INCACHE_POW_SIZE) * (1 << BURST_POW_SIZE);
	localparam INCACHE_ASIZE = BURST_POW_SIZE + INCACHE_POW_SIZE;
	
	reg [DATA_WIDTH-1:0] incache[INCACHE_SIZE-1:0];
	reg [INCACHE_ASIZE:0] inwaddr,inraddr;
	reg full;
	
	wire inwaddr_next;
	
	assign inwaddr_next = inwaddr + 1'b1;
	
	always@(posedge i_clk)
	if(i_wr && !full)
	begin
		incache[inwaddr[INCACHE_ASIZE-1:0]] <= i_data;
		inwaddr <= inwaddr_next;
		full <= inwaddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE] == inraddr[INCACHE_ASIZE:INCACHE_POW_SIZE];
	end

endmodule
