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
	input i_clk,i_rst_n,i_wr,i_rd,
	input [DATA_WIDTH-1:0] i_data,
	output o_full,
	
	//connect with SDRAM chip
	inout [DATA_WIDTH-1:0] io_sdram_data,
	output reg [BANK_WIDTH-1:0] o_sdram_ba,
	output reg [ROW_WIDTH-1:0] o_sdram_addr,
	output reg o_sdram_ras,
	output reg o_sdram_cas,
	output reg o_sdram_we,
	output o_sdram_cke,
	output o_sdram_cs,
	output o_sdram_clk
);
	localparam BURST_SIZE = 4'd8;
	localparam INCACHE_SIZE = 64;
	localparam INCACHE_ASIZE = 6;
	
	assign o_sdram_cs = 1'b0;
	assign o_sdram_cke = 1'b1;
	
	//in_cache FIFO
	
	reg [DATA_WIDTH-1:0] incache[INCACHE_SIZE-1:0];
	reg [INCACHE_ASIZE:0] inwaddr,inraddr;
	reg full,hasdata,hasmoredata;
	
	wire [INCACHE_ASIZE:0] inwaddr_next,inraddr_next;
	
	assign o_full = full;
	assign inwaddr_next = (i_wr && !full) ? inwaddr + 1'b1 : inwaddr;
	assign inraddr_next = (state==ST_ACCESS && wrrd) ? inraddr + 1'd1 : inraddr;
	
	always@(posedge i_clk or negedge i_rst_n)
	if(!i_rst_n)
	begin
		hasdata <= 0;
		hasmoredata <= 0;
		full <= 0;
		inwaddr  <=  0;
	end
	else
	begin
		hasdata <= inwaddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE] != inraddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE];
		hasmoredata <= (inwaddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE] != inraddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE]) 
			&& (inwaddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE] != inraddr_next[INCACHE_ASIZE:INCACHE_POW_SIZE] +  1'b1);
		full <= {!inraddr_next[INCACHE_ASIZE],inraddr_next[INCACHE_ASIZE-1:INCACHE_POW_SIZE]} == 
			{inwaddr_next[INCACHE_ASIZE],inwaddr_next[INCACHE_ASIZE-1:INCACHE_POW_SIZE]};
		inwaddr <= inwaddr_next;
					
		if(i_wr && !full)
			incache[inwaddr[INCACHE_ASIZE-1:0]] <= i_data;
	end
	
	localparam tPower = 15'd2;	//Power on to ready cost clocks
	localparam tRCD = 2'd2;		//Active cost clocks
	localparam tRC = 3'd7;		//Refresh cost clocks
	localparam tRP = 2'd2;		//Pre charge cost clocks
	localparam tFT = 4'd8;		//Initialize fresh times
	localparam tPreAct = BURST_SIZE - tRCD - 1'b1;	//the counter ticks witch the next bank should be active while the previous bank is being written or read
		
	
	//initialize: power on (200us)-> pre charge -> 8 times refresh -> set register -> initial OK
	
	localparam ST_INIT_START = 8'b0000_0001;
	localparam ST_INIT_PRECHARGE = 8'b0000_0010;
	localparam ST_INIT_REFRESH = 8'b0000_0100;
	localparam ST_INIT_SETREG = 8'b0000_1000;
	localparam ST_INIT_OK = 8'b0001_0000;
	
	reg [7:0] initstate,initstate_next;
	reg [1:0] init_prechg_cnt;
	reg [2:0] init_fresh_cnt;
	reg [3:0] init_fresh_times;
	reg [14:0] power_on_cnt;
	
	reg [1:0] init_ba;
	reg [12:0] init_addr;
	reg init_ras,init_cas,init_we;
		
	always@(posedge i_clk or negedge i_rst_n)
	if(!i_rst_n)
	begin
		initstate<=0;
		power_on_cnt <= 0;
		init_prechg_cnt <= 0;
		init_fresh_cnt <= 0;
		init_fresh_times <= 0;
	end
	else
	begin
		initstate <= initstate_next;
		if(initstate != ST_INIT_START)
			power_on_cnt <= 0;
		else
			power_on_cnt <= power_on_cnt + 1'b1;
			
		if(initstate != ST_INIT_PRECHARGE)
			init_prechg_cnt <= 0;
		else
			init_prechg_cnt <= init_prechg_cnt + 1'b1;
			
		if(initstate != ST_INIT_REFRESH)
			init_fresh_cnt <= 0;
		else
			init_fresh_cnt <= (init_fresh_cnt == tRC) ? 3'd0 : init_fresh_cnt + 1'b1;
			
		if(initstate != ST_INIT_REFRESH)
			init_fresh_times <= 0;
		else
			init_fresh_times <= (init_fresh_cnt == tRC) ? init_fresh_times + 1'b1 : init_fresh_times;
	end
	
	
	always@(*)
	case(initstate)
	ST_INIT_START:
		initstate_next = (power_on_cnt == tPower) ? ST_INIT_PRECHARGE : ST_INIT_START;
	ST_INIT_PRECHARGE:
		initstate_next = (init_prechg_cnt == tRP) ? ST_INIT_REFRESH : ST_INIT_PRECHARGE;
	ST_INIT_REFRESH:
		initstate_next = (init_fresh_times == tFT) ? ST_INIT_SETREG : ST_INIT_REFRESH;
	ST_INIT_SETREG:
		initstate_next = ST_INIT_OK;		
	ST_INIT_OK:
		initstate_next = ST_INIT_OK;		
	default:
		initstate_next = ST_INIT_START;
	endcase
		
	always@(*)
	case(initstate)
	ST_INIT_PRECHARGE:
	begin
		{init_ras,init_cas,init_we} = 3'b010;
		init_addr[10] = 1'b1;
		{init_ba,init_addr[12:11],init_addr[9:0]} = {14{1'bx}};
	end
	ST_INIT_REFRESH:
	begin
		if(init_fresh_cnt == 0) 
			{init_ras,init_cas,init_we} = 3'b001;
		else
			{init_ras,init_cas,init_we} = 3'b111;
		{init_ba,init_addr} = {15{1'bx}};
	end
	ST_INIT_SETREG:
	begin
		{init_ras,init_cas,init_we} = 3'b000;
		init_ba = 0;
		init_addr[12:7] = 0;
		init_addr[6:4] = 3'd2;
		init_addr[3:0] = 4'd3;
	end	
	default:
	begin
		{init_ras,init_cas,init_we,init_ba,init_addr} = {18{1'bx}};
	end	
	endcase
		
	//write and read
	
	localparam ST_WAIT = 8'b0000_0001;
	localparam ST_ACT = 8'b0000_0010;
	localparam ST_PRE_ACT = 8'b0000_0100;
	localparam ST_ACCESS = 8'b0000_1000;
	localparam ST_INVALID = 8'b1000_0000;
	localparam RD = 1'b0;
	localparam WR = 1'b1;
	
	reg wrrd;
	reg [7:0] state,state_next;
	reg [1:0] act_cnt;
	reg [2:0] acc_cnt;
	
	always@(posedge i_clk)
	begin
		state <= state_next;
		
		if(state == ST_WAIT && state_next == ST_ACT)
			if(hasdata)
				wrrd <= 1'b1;
			else
				wrrd <= 1'b0;
			
		if(state != ST_ACCESS && state != ST_PRE_ACT)
			acc_cnt <= 0;
		else
			acc_cnt <= (acc_cnt==3'd7 ? 3'd0 : acc_cnt + 1'b1);
			
		if(state != ST_ACT)
			act_cnt <= 0;
		else
			act_cnt <= act_cnt + 1'b1;
	end
	
	always@(*)
	if(initstate == ST_INIT_OK)
		case(state)
		ST_WAIT:
			if(hasdata || i_rd) 
				state_next = ST_ACT;
			else
				state_next = ST_WAIT;
		ST_ACT: 
			state_next = (act_cnt == tRCD) ? ST_ACCESS : ST_ACT;
		ST_ACCESS:
			if(acc_cnt == BURST_SIZE - 1'b1)
				if(!hasmoredata)
					state_next = ST_WAIT;
				else 
					state_next = ST_ACCESS;
			else
				state_next = ST_ACCESS;
		default:
			state_next = ST_WAIT;
		endcase
	else
		state_next = ST_INVALID;
	
	localparam RAM_ADDR_SIZE = ROW_WIDTH+COL_WIDTH-BURST_POW_SIZE+BANK_WIDTH;
	reg [RAM_ADDR_SIZE-1:0] waddr,raddr;
	reg [DATA_WIDTH-1:0] wr_data;
	
	assign io_sdram_data = wrrd ? wr_data : {DATA_WIDTH{1'bz}};
	
	always@(posedge i_clk)
	if(initstate != ST_INIT_OK)
		{o_sdram_ras,o_sdram_cas,o_sdram_we,o_sdram_ba,o_sdram_addr} <= {init_ras,init_cas,init_we,init_ba,init_addr};
	else
		case(state)
		ST_WAIT:
		begin
			{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b111;
			{o_sdram_ba,o_sdram_addr} <= {15{1'bx}};
		end
		ST_ACT:
		begin
			if(act_cnt == 0)
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b011;
				o_sdram_ba <= wrrd ? waddr[BANK_WIDTH-1:0] : raddr[BANK_WIDTH-1:0];
				o_sdram_addr <= wrrd ? waddr[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH] : raddr[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH];
			end
			else
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b111;
				{o_sdram_ba,o_sdram_addr} <= {15{1'bx}};
			end
		end
		ST_ACCESS:
		begin
			if(acc_cnt == 0)
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= wrrd ? 3'b100 : 3'b101;
				o_sdram_ba <= wrrd ? waddr[BANK_WIDTH-1:0] : raddr[BANK_WIDTH-1:0];
				o_sdram_addr <= {1'b1,waddr[RAM_ADDR_SIZE-ROW_WIDTH-1:BANK_WIDTH],{BURST_POW_SIZE{1'b0}}};
			end
			else if(acc_cnt == tPreAct && hasmoredata)
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b011;
				o_sdram_ba <= wrrd ? waddr[BANK_WIDTH-1:0]+1'b1 : raddr[BANK_WIDTH-1:0]+1'b1;
				o_sdram_addr <= (wrrd ? waddr[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH] : raddr[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH]) + 
					(waddr[BANK_WIDTH-1:0]==2'b11 ? 1'b1 : 1'b0);
			end
			else
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b111;
				{o_sdram_ba,o_sdram_addr} <= {15{1'bx}};
			end
		end
		
		default:
		begin
			{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b111;
			{o_sdram_ba,o_sdram_addr} <= {15{1'bx}};
		end
		endcase
		
		
	always@(posedge i_clk or negedge i_rst_n)
	if(!i_rst_n)
	begin
		inraddr <= 0;
		waddr <=0;
		raddr <= 0;
	end
	else
		case(state)
		ST_ACCESS:
		begin			
			if(wrrd)
			begin
				wr_data <= incache[inraddr];
				inraddr <= inraddr + 1'b1;
			end
			
			if(acc_cnt == {BURST_POW_SIZE{1'b1}})
				if(wrrd) 
					waddr <= waddr + 1'b1;
				else
					raddr <= raddr + 1'b1;
		end
		endcase
		
endmodule
