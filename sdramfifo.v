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
	output reg o_sdram_clk,
	output reg o_sdram_udqm,
	output reg o_sdram_ldqm,
	output reg o_sdram_ras,
	output reg o_sdram_cas,
	output reg o_sdram_we,
	output reg o_sdram_cke,
	output reg o_sdram_cs
);
	localparam BURST_SIZE = 1 << BURST_POW_SIZE;
	localparam INCACHE_SIZE = (1 << INCACHE_POW_SIZE) * (1 << BURST_POW_SIZE);
	localparam INCACHE_ASIZE = BURST_POW_SIZE + INCACHE_POW_SIZE;
	
	//incache fifo
	
	reg [DATA_WIDTH-1:0] incache[INCACHE_SIZE-1:0];
	reg [INCACHE_ASIZE:0] inwaddr,inraddr;
	reg full,hasdata,hasmoredata;
	
	wire [INCACHE_ASIZE:0] inwaddr_next,inwaddr_next_next,inraddr_next;
	
	assign inwaddr_next = (i_wr && !full) ? inwaddr + 1'b1 : inwaddr;
	assign inwaddr_next_next = (i_wr && !full) ? inwaddr + 2'd2 : inwaddr + 1'b1;
	assign inraddr_next = inraddr + 1'b1;
	
	always@(posedge i_clk)
	begin
		hasdata <= inwaddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE] != inraddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE];
		hasmoredata <= inwaddr_next_next[INCACHE_ASIZE:INCACHE_POW_SIZE] != inraddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE];
		full <= {!inraddr_next[INCACHE_ASIZE],inraddr_next[INCACHE_ASIZE-1:INCACHE_POW_SIZE]} == 
			{inwaddr_next[INCACHE_ASIZE],inwaddr_next[INCACHE_ASIZE-1:INCACHE_POW_SIZE]};
		inwaddr <= inwaddr_next;
		inraddr <= inraddr_next;
					
		if(i_wr && !full)
			incache[inwaddr[INCACHE_ASIZE-1:0]] <= i_data;
	end
	
	
	//state machine
	//initial: power on (200us)-> pre charge -> 8 times refresh -> set register -> initial ok
	
	localparam ST_WAIT = 8'b0000_0001;
	localparam ST_PREWRT = 8'b0000_0010;
	localparam ST_WRT_PRE = 8'b0000_0100;
	localparam ST_WRT = 8'b0000_1000;
	localparam ST_INVALID = 8'b0001_0000;
	
	
	localparam ST_INIT_START = 8'b0000_0001;
	localparam ST_INIT_PRECHARGE = 8'b0000_0010;
	localparam ST_INIT_REFRESH = 8'b0000_0100;
	localparam ST_INIT_SETREG = 8'b0000_1000;
	localparam ST_INIT_OK = 8'b0001_0000;
	
	localparam tRCD = 2'd2;
	localparam tRC = 3'd7;
	localparam tRP = 2'd2;
	localparam tPreAct = BURST_SIZE - tRCD - 2;	//the counter ticks witch the next bank should be active while the previous bank is being written or read
	
	reg [7:0] initstate,state;
	wire [7:0] initstate_next,state_next;
	reg [1:0] prewrt_cnt;
	reg [2:0] wrt_cnt,initfresh_cnt,initfresh_times;
	reg [3:0] rd_cnt;
	reg [14:0] power_cnt;
		
	always@(posedge i_clk)
	begin
		initstate = initstate_next;
		if(initstate != ST_INIT_START)
			power_cnt <= 0;
		else
			power_cnt <= power_cnt + 1'b1;
	end
	
	always@(posedge i_clk)
	begin
		state <= state_next;
		if(state != ST_WRT && state != ST_WRT_PRE)
			wrt_cnt <= 0;
		if(state != ST_PREWRT)
			prewrt_cnt <= 0;
	end
	
	
	always@(*)
	case(initstate)
	ST_INIT_START:
		initstate_next = (power_cnt == 15d'20000) ? ST_INIT_PRECHARGE : ST_INIT_START;
	ST_INIT_PRECHARGE:
		
	ST_INIT_OK:
		initstate_next = ST_INIT_OK;		
	default:
		initstate_next = ST_INIT_START;

	always@(*)
	if(initstate == ST_INIT_OK)
		case(state)
		ST_WAIT:
			if(hasdata) 
				state_next = ST_PREWRT;
		ST_PREWRT: 
			state_next = (prewrt_cnt == tRCD) ? ST_WRT : ST_PREWRT;
		ST_WRT:
			if(wrt_cnt == tPreAct)
				if(hasmoredata)
					state_next = ST_WRT_PRE;
				else
					state_next = ST_WRT;
			else if(wrt_cnt == BURST_SIZE - 1'b1)
				state_next = ST_WAIT;
			else 
				state_next = ST_WRT;
		ST_WRT_PRE:
			if(wrt_cnt == BURST_SIZE - 1'b1)
				state_next = ST_WRT;
			else 
				state_next = ST_WRT_PRE;
		default:
			state_next = ST_WAIT;
	else
		state_next = ST_INVALID;
		
endmodule
