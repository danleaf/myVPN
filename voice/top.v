module top
(
	input i_clk_sys50m,
	input i_red,
	
	output [6:0] o_num,
	output [7:0] o_sel,
	
	output o_sdram_clk,
	inout [15:0] io_sdram_data,
	output [1:0] o_sdram_ba,
	output [12:0] o_sdram_addr,
	output o_sdram_ras,
	output o_sdram_cas,
	output o_sdram_we,
	output o_sdram_cke,
	output o_sdram_cs,
	output o_sdram_udqm,
	output o_sdram_ldqm
);
	
	wire clk,clk_red_1us,clk_num_1ms,clk_500ms;
	wire intr,rd_ef;
	wire [15:0] nouse1,rd_data,get_data;
	wire [7:0] nouse2,data;
	reg int0,int1,int2,wr_req,cls_raddr;
	reg [15:0] wr_data;
	reg [5:0] rdcnt,wrcnt;
	
	assign o_sdram_udqm = 1'b0;
	assign o_sdram_ldqm = 1'b0;
	
	pll100m pll_inst(
	.inclk0(i_clk_sys50m),
	.c0(clk),
	.c1(o_sdram_clk),
	.locked());
	
	wire [7:0] state1,state2;
	wire [20:0] waddr,raddr;
	
	reg [6:0] cc;
	initial
	begin
		cc = 0;
		rdcnt = 0;
		wrcnt = 0;
		wr_req = 1;
		cls_raddr = 0;
		wr_data = 1;
	end
	
	always@(posedge clk)
	begin
	end
		
	
	sdramfifo sdramfifo_inst(
	.i_clk(clk),
	.i_rst_n(1'b1),
	.i_wr(wr_req),
	.i_rd(1'b1),
	.i_wr_data(wr_data),
	.o_rd_data(rd_data),
	.o_cach_full(),
	.o_rd_ef(rd_ef),		
	.o_rd_done(),	
	.io_sdram_data(io_sdram_data),
	.o_sdram_ba(o_sdram_ba),
	.o_sdram_addr(o_sdram_addr),
	.o_sdram_ras(o_sdram_ras),
	.o_sdram_cas(o_sdram_cas),
	.o_sdram_we(o_sdram_we),
	.o_sdram_cke(o_sdram_cke),
	.o_sdram_cs(o_sdram_cs),
	.state1(state1),
	.state2(state2),
	.waddr(waddr),
	.raddr(raddr),
	.i_cls_raddr(cls_raddr));
	
	
	wire [31:0] result;
	reg [7:0] rstate1,rstate2;
	reg chg;
	
	always@(posedge clk)
	begin
		{int0,int1,int2} <= {intr,int0,int1};
		if(int1 & !int2)
		begin
			wr_data <= 16'd1;
			wr_req <= 1'b1;
			//cls_raddr <= 1'b1;
		end
		//else
			//cls_raddr <= 0;
		
		if(wr_req)
		begin
			cc <= cc+1'b1;
			wr_req <= (cc==7'd127) ? 1'b0 : 1'b1;
			wr_data <= wr_data + 1'b1;
		end
		else
		   cc <= 0;
			
		/*cc <= (cc==7'd63) ? cc : cc+1'b1;
		wr_req <= (cc==7'd63) ? 1'b0 : 1'b1;
		if(wr_req)
			wr_data[6:0] <= wr_data[6:0] + 1'b1;*/
	end	
	
	DIVCLK #(50) divclk0 (i_clk_sys50m, clk_red_1us);
	DIVCLK #(50000) divclk1 (i_clk_sys50m, clk_num_1ms);
	DIVCLK #(25000000) divclk2 (i_clk_sys50m, clk_500ms);
	
	RED_RECV red(clk_red_1us,i_red,{nouse1,data,nouse2},intr);
	
	wire empty;
	
	fifo #(8,16) i0(
		.wclk(clk),
		.rclk(clk_500ms),
		.rst(1'b1),
		.rreq(1'b1),
		.wreq(rd_ef),    
		.wdata(rd_data),//({rstate1,rstate2}),   
		.rdata(get_data),
		.empty(empty));
		
		always@(posedge clk_500ms)
			rdcnt <= !empty ? rdcnt+1'b1 : rdcnt;
		always@(posedge clk)
			wrcnt <= rd_ef ? wrcnt+1'b1 : wrcnt;
	
		
	assign result = //wr_data[15:8] * 1000000 +  wr_data[7:0] * 10000 +
						rdcnt * 1000000 + wrcnt * 10000 +
						get_data[15:8] * 100 + get_data[7:0];
						//waddr[12:0]*10000 + raddr[12:0];
					
	NUMSHOW show(clk_num_1ms, result, o_num, o_sel);

endmodule
