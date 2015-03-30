module sdramfifo
#(
	parameter BANK_WIDTH = 2,
	parameter ROW_WIDTH = 13,
	parameter COL_WIDTH = 9,
	parameter DATA_WIDTH = 16,
	parameter BURST_POW_SIZE = 3,
	parameter WAVE_SIZE = 16
)
(
	input i_clk,i_rst_n,i_wr,i_rd,
	input [DATA_WIDTH-1:0] i_wr_data,
	output reg [DATA_WIDTH-1:0] o_rd_data,
	output o_full,
	output o_rd_fail,		//read fail
	output o_rd_ef,		//o_rd_data effective
	output o_rd_done,	//read one wave request done
	
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
	reg full;
	reg [INCACHE_ASIZE-BURST_POW_SIZE:0]cach_cnt;
	
	wire hasdata,hasmoredata;	
	
	assign hasdata = |cach_cnt;
	assign hasmoredata = |cach_cnt[INCACHE_ASIZE-BURST_POW_SIZE:1];
	
	wire [INCACHE_ASIZE:0] inwaddr_next,inraddr_next;
	
	assign o_full = full;
	assign inwaddr_next = (i_wr && !full) ? inwaddr + 1'b1 : inwaddr;
	assign inraddr_next = (state==ST_ACCESS && wrrd) ? inraddr + 1'd1 : inraddr;
	
	always@(posedge i_clk or negedge i_rst_n)
	if(!i_rst_n)
	begin
		//hasdata <= 0;
		//hasmoredata <= 0;
		full <= 0;
		inwaddr  <=  0;
		cach_cnt <= 0;
	end
	else
	begin
		/*hasdata <= inwaddr_next[INCACHE_ASIZE:BURST_POW_SIZE] != inraddr_next[INCACHE_ASIZE:BURST_POW_SIZE];
		hasmoredata <= (inwaddr_next[INCACHE_ASIZE:BURST_POW_SIZE] != inraddr_next[INCACHE_ASIZE:BURST_POW_SIZE]) 
			&& (inwaddr_next[INCACHE_ASIZE:BURST_POW_SIZE] != inraddr_next[INCACHE_ASIZE:BURST_POW_SIZE] +  1'b1);
		full <= {!inraddr_next[INCACHE_ASIZE],inraddr_next[INCACHE_ASIZE-1:BURST_POW_SIZE]} == 
			{inwaddr_next[INCACHE_ASIZE],inwaddr_next[INCACHE_ASIZE-1:BURST_POW_SIZE]};
		inwaddr <= inwaddr_next;*/
		if((i_wr && !full) && !(state==ST_ACCESS && wrrd))
		begin
			if(&inwaddr[BURST_POW_SIZE-1:0])
				cach_cnt <= cach_cnt + 1'b1;
			if(&inwaddr[BURST_POW_SIZE-1:0] && cach_cnt == BURST_SIZE-1'b1) 
				full <= 1'b1;
		end
		else if(!(i_wr && !full) && (state==ST_ACCESS && wrrd))
		begin
			if(&inraddr[BURST_POW_SIZE-1:0])
			begin
				full <= 0;
				cach_cnt <= cach_cnt - 1'b1;		
			end
		end
		else if((i_wr && !full) && (state==ST_ACCESS && wrrd))
		begin
			if(&inwaddr[BURST_POW_SIZE-1:0] && !(&inraddr[BURST_POW_SIZE-1:0]))
			begin
				cach_cnt <= cach_cnt + 1'b1;
				if(cach_cnt == BURST_SIZE-1'b1)		
					full <= 1'b1;
			end
			if(!(&inwaddr[BURST_POW_SIZE-1:0]) && &inraddr[BURST_POW_SIZE-1:0])
			begin
				full <= 0;
				cach_cnt <= cach_cnt - 1'b1;		
			end
		end
		
		if(i_wr && !full)
		begin
			inwaddr <= inwaddr + 1'b1;
			incache[inwaddr[INCACHE_ASIZE-1:0]] <= i_wr_data;
		end
	end
	
	localparam tPower = 15'd2;	//Power on to ready cost clocks
	localparam tRCD = 2'd2;		//Active cost clocks
	localparam tRC = 3'd7;		//Refresh cost clocks
	localparam tRP = 2'd2;		//Pre charge cost clocks
	localparam tFT = 4'd8;		//Initialize fresh times
	localparam tCL = 2'd2;
	localparam tPreAct = BURST_SIZE - tRCD;	//the counter ticks witch the next bank should be active while the previous bank is being written or read
	localparam tOne = 5'd18;	//one full access cost clocks	
	localparam tRef = 10'd781;	//refresh cycle clocks, 100MHZ is 781, 133MHZ is 1038  ---7812us,refr_cycl_cnt < tRef-tOne
	localparam RefMin = 11'd1024-(tRef-tOne)+1'b1;
	localparam RefMax = 11'd1024 + tOne;
	
	
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
			init_fresh_cnt <= (init_fresh_cnt == tRC - 1'b1) ? 3'd0 : init_fresh_cnt + 1'b1;
			
		if(initstate != ST_INIT_REFRESH)
			init_fresh_times <= 0;
		else
			init_fresh_times <= (init_fresh_cnt == tRC - 1'b1) ? init_fresh_times + 1'b1 : init_fresh_times;
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
	
	localparam ST_IDEL = 8'b0000_0001;
	localparam ST_ACT = 8'b0000_0010;
	localparam ST_ACCESS = 8'b0000_0100;
	localparam ST_FINAL = 8'b0000_1000;
	localparam ST_REFRESH = 8'b0001_0000;
	localparam ST_INVALID = 8'b1000_0000;
	localparam RD = 1'b0;
	localparam WR = 1'b1;
	
	reg wrrd,rd_done,rd_done0,rd_done1,rd_data_on,rd_data_on0,rd_data_on1;
	reg [7:0] state,state_next;
	reg [1:0] act_cnt;
	reg [2:0] acc_cnt;
	reg [2:0] refr_cnt;
	//reg [9:0] refr_cycl_cnt;
	
	wire [11:0] refr_cycl_cnt,read_cnt;
	
	counter12Mod #(tRC+RefMin+1,RefMin,RefMax) refcyc_cntr(i_clk,(initstate == ST_INIT_SETREG),refr_cycl_cnt);
	
	counter12 read_cntr(i_clk,rd_done,
		acc_cnt == 0 && state == ST_ACCESS && !wrrd,
		read_cnt);
	
	reg actnext,readmore,empty;
	
	always@(posedge i_clk)
	begin
		state <= state_next;
		empty <= (r_addr == w_addr);
		
		if(state == ST_IDEL)
			if(hasdata)
				wrrd <= 1'b1;
			else
				wrrd <= 1'b0;
			
		if(state != ST_ACT)
			act_cnt <= 0;
		else 
			act_cnt <= act_cnt + 1'b1;
			
		if(state != ST_ACCESS)
			{acc_cnt,actnext,rd_data_on} <= 0;
		else
		begin
			readmore <= !((read_cnt == WAVE_SIZE) || (r_addr_next == w_addr));
			if(!wrrd)
				rd_data_on <= 1'b1;
			if(acc_cnt == tPreAct-1'b1)
				actnext <= (wrrd ? hasmoredata : readmore) && !refr_cycl_cnt[10];	//refr_cycl_cnt < tRef-tOne   ==>  refr_cycl_cnt < 1024
			else if(acc_cnt == BURST_SIZE-1)
				actnext <= 0;
			acc_cnt <= acc_cnt + 1'b1;
		end
			
		if(state != ST_REFRESH)
			refr_cnt <= 0;
		else
			refr_cnt <= refr_cnt + 1'b1;
			
		if(state == ST_FINAL && read_cnt == WAVE_SIZE)
			rd_done <= 1;
		else
			rd_done <= 0;
			
		{rd_done1,rd_done0} <= {rd_done0,rd_done};
		{rd_data_on1,rd_data_on0} <= {rd_data_on0,rd_data_on};
		
		//if(initstate == ST_INIT_SETREG)
			//refr_cycl_cnt <= tRC;
		//else
			//refr_cycl_cnt <= (refr_cycl_cnt == tRef - 1'b1) ? 10'd0 : refr_cycl_cnt + 1'b1;
	end
	
	assign o_rd_done = rd_done1;
	assign o_rd_ef = rd_data_on1;
	
	always@(*)
	if(initstate == ST_INIT_OK)
		case(state)
		ST_IDEL:
			if(refr_cycl_cnt == RefMax-1)
				state_next = ST_REFRESH;
			else if((hasdata || (i_rd & !empty)) && !refr_cycl_cnt[10]) //refr_cycl_cnt < tRef-tOne   ==>  refr_cycl_cnt < 1024
				state_next = ST_ACT;
			else
				state_next = ST_IDEL;
		ST_REFRESH:
			if(refr_cnt == tRC - 2'd2)
				state_next = ST_IDEL;
			else
				state_next = ST_REFRESH;
		ST_ACT: 
			state_next = (act_cnt == tRCD) ? ST_ACCESS : ST_ACT;
		ST_ACCESS:
			if(acc_cnt == BURST_SIZE-1)
				if(actnext)
					state_next = ST_ACCESS;
				else
					state_next = ST_FINAL;
			else
				state_next = ST_ACCESS;
		ST_FINAL:
			state_next = ST_IDEL;
		default:
			state_next = ST_IDEL;
		endcase
	else
		state_next = ST_INVALID;
	
	localparam RAM_ADDR_SIZE = ROW_WIDTH+COL_WIDTH-BURST_POW_SIZE+BANK_WIDTH;
	wire [RAM_ADDR_SIZE-1:0] w_addr,w_addr_next,r_addr,r_addr_next;
	
	wire [ROW_WIDTH-1:0] w_row_addr,r_row_addr,w_row_addr_next,r_row_addr_next;
	wire [COL_WIDTH-BURST_POW_SIZE-1:0] w_col_addr,r_col_addr;
	wire [BANK_WIDTH-1:0] w_bank,r_bank,w_bank_next,r_bank_next;
	
	wire [2:0] nouse1,nouse2,nouse3,nouse4;
	reg [DATA_WIDTH-1:0] wr_data;
	
	counter24 cnt_w_addr(i_clk,i_rst_n,
		acc_cnt == {BURST_POW_SIZE{1'b1}} && state == ST_ACCESS && wrrd,
		{nouse1,w_addr});
	counter24 #(1'b1) cnt_w_addr2(i_clk,i_rst_n,
		acc_cnt == {BURST_POW_SIZE{1'b1}} && state == ST_ACCESS && wrrd,
		{nouse2,w_addr_next});
	counter24 cnt_r_addr(i_clk,i_rst_n,
		acc_cnt == {BURST_POW_SIZE{1'b1}} && state == ST_ACCESS && !wrrd,
		{nouse3,r_addr});
	counter24 #(1'b1) cnt_r_addr2(i_clk,i_rst_n,
		acc_cnt == {BURST_POW_SIZE{1'b1}} && state == ST_ACCESS && !wrrd,
		{nouse4,r_addr_next});
		
	assign w_row_addr = w_addr[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH];
	assign w_row_addr_next = w_addr_next[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH];
	assign r_row_addr = r_addr[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH];
	assign r_row_addr_next = r_addr_next[RAM_ADDR_SIZE-1:RAM_ADDR_SIZE-ROW_WIDTH];
	assign w_bank = w_addr[BANK_WIDTH-1:0];
	assign w_bank_next = w_addr_next[BANK_WIDTH-1:0];
	assign r_bank = r_addr[BANK_WIDTH-1:0];
	assign r_bank_next = r_addr_next[BANK_WIDTH-1:0];
	assign w_col_addr = w_addr[RAM_ADDR_SIZE-ROW_WIDTH-1:BANK_WIDTH];
	assign r_col_addr = r_addr[RAM_ADDR_SIZE-ROW_WIDTH-1:BANK_WIDTH];
	
	assign io_sdram_data = wrrd ? wr_data : {DATA_WIDTH{1'bz}};
	
	always@(posedge i_clk)
	if(initstate != ST_INIT_OK)
		{o_sdram_ras,o_sdram_cas,o_sdram_we,o_sdram_ba,o_sdram_addr} <= {init_ras,init_cas,init_we,init_ba,init_addr};
	else
		case(state)
		ST_IDEL:
		begin
			{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b111;
			{o_sdram_ba,o_sdram_addr} <= {15{1'bx}};
		end
		ST_ACT:
		begin
			if(act_cnt == 0)
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b011;
				o_sdram_ba <= wrrd ? w_bank: r_bank;
				o_sdram_addr <= wrrd ? w_row_addr : r_row_addr;
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
				o_sdram_ba <= wrrd ? w_bank : r_bank;
				o_sdram_addr <= {1'b1,
					wrrd ? w_col_addr : r_col_addr,
					{BURST_POW_SIZE{1'b0}}};
			end
			else if(acc_cnt == tPreAct && actnext)
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b011;
				o_sdram_ba <= wrrd ? w_bank_next : r_bank_next;
				o_sdram_addr <= wrrd ? w_row_addr_next : r_row_addr_next;
			end
			else
			begin
				{o_sdram_ras,o_sdram_cas,o_sdram_we} <= 3'b111;
				{o_sdram_ba,o_sdram_addr} <= {15{1'bx}};
			end
		end
		ST_REFRESH:
		begin
			if(refr_cnt == 0) 
				{o_sdram_ras,o_sdram_cas,o_sdram_we} = 3'b001;
			else
				{o_sdram_ras,o_sdram_cas,o_sdram_we} = 3'b111;
			{o_sdram_ba,o_sdram_addr} = {15{1'bx}};
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
			else if(rd_data_on1)
				o_rd_data <= io_sdram_data;
		end
		endcase
		
endmodule