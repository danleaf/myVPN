module eth_sender
(
	input i_clk,i_rst_n,
	input [7:0] i_data,
	input i_wr,i_din,
	output o_full,
	
	output
);
	localparam PDU_SIZE = 1500 - 20 - 8 - 2;
	localparam ADDR_WIDTH = 13;
	localparam FRAME_COUNT_WIDTH = 4;
	localparam MEMSIZE = 1<<ADDR_WIDTH;
	localparam FRAME_COUNT = 1<<FRAME_COUNT_WIDTH;
	
	wire [12:0] wr_addr,wr_addrinc,rd_addr;
	wire [10:0] wr_size;
	reg [12:0] end_addr[0:3];
	reg [16:0] packet_id[0:3];
	reg [12:0] start_addr,curr_max_addr;
	reg [2:0] rd_idx,wr_idx;
	reg [7:0] packet_idx,packet_ident,rddata;
	reg wr_pck_id;

	reg full,empty,storing;
	
	wire send_over;
	wire wren = i_wr & !full & i_din;
	wire wr_one_yet = ((wr_size == PDU_SIZE-1'd1) && wren) || ((!i_wr & storing) && (wr_size != 0));
	wire rd = send_over;
	
	altdualram buffer(i_clk,i_data,rd_addr,wr_addr,wren,rddata);
	
	communication comu
	(
	input i_clk,i_rst_n,
	input [10:0] i_data_st,i_next_data_st,		// the start and end+1 of the data in data_send_req buffer
	input [7:0] i_pck_ident,i_pck_idx,
	input [7:0] i_cur_byte,									// the value of o_cur_addr to get in data_send_req buffer without clock delay
	output reg [10:0] o_cur_addr,
	input i_trig_send,
	output o_send_over,
	output reg [7:0] o_cmd,
	output reg [31:0] o_param,
	output reg o_cmd_come,
		.io_eth_mdio(io_eth_mdio),
		.o_eth_mdc(o_eth_mdc),
		.o_eth_txen(o_eth_txen),
		.o_eth_txer(o_eth_txer),
		.o_eth_txd(o_eth_txd),
		.i_eth_rxclk(i_eth_rxclk),
		.i_eth_rxdv(i_eth_rxdv),
		.i_eth_rxer(i_eth_rxer),
		.i_eth_rxd(i_eth_rxd),
		.i_eth_crs(i_eth_crs),
		.i_eth_col(i_eth_col)
	);
	
	counter16 wr_addr_cnt(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_en(wren),
		.q(wr_addr));
		
	counter16 #(16'd1) wr_addr_cnt2(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_en(wren),
		.q(wr_addrinc));
		
	counter16Mod #(16'd0,16'd0,PDU_SIZE-1'd1) wr_size_cnt(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_init(!i_wr),
		.i_en(wren),
		.q(wr_size));
		
	always@(posedge i_clk or negedge i_rst_n)
	if(!i_rst_n)
	begin
		full <= 0;
		empty <= 1'b1;
		wr_idx <= 0;
		storing <= 0;
		packet_ident <= 0;
		packet_idx <= 0;
		wr_pck_id <= 0;
	end
	else
	begin			
		if(wren)
		begin
			storing <= 1'b1;
			if(wr_size == PDU_SIZE-1'd1)
			begin
				wr_idx <= wr_idx + 1'b1;
				end_addr[wr_idx[1:0]] <= wr_addrinc;
				packet_id[wr_idx[1:0]] <= {packet_ident,packet_idx};
				packet_idx <= packet_idx + 1'd1;
				full <= (wr_idx + 1'b1 == {{~rd_idx[2],rd_idx[1:0]}});
			end
			
		end		
		
		if(!i_wr & storing)
		begin
			storing <= 0;
			if(wr_size != 0)
			begin
				wr_idx <= wr_idx + 1'b1;
				end_addr[wr_idx[1:0]] <= wr_addr;
				packet_id[wr_idx[1:0]] <= {packet_ident,packet_idx};
				full <= (wr_idx + 1'b1 == {{~rd_idx[2],rd_idx[1:0]}});
			end
		end
		
		if(rd)
		begin
			rd_idx <= rd_idx + 1'd1;
			empty <= (rd_idx + 1'd1 == wr_idx);
		end
		
		if(wr_one_yet && !rd)
			empty <= 0;
		else if(!wr_one_yet && rd)
			full <= 0;
	end
endmodule
