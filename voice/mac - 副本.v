module mac
#(
	parameter ADDR_WIDTH = 11
)
(
	input i_gclk,i_rst_n,
	input [ADDR_WIDTH-1:0] i_data_st,i_data_ed,
	input i_tx_trig,
	output [ADDR_WIDTH-1:0] o_rd_addr,o_wr_addr,
	input [7:0] i_cur_byte,
	
	inout io_eth_mdio,
	output o_eth_mdc,
	output o_eth_txen,
	output o_eth_txer,
	output [7:0] o_eth_txd,
	input i_eth_rxclk,
	input i_eth_rxdv,
	input i_eth_rxer,
	input [7:0] i_eth_rxd,
	input i_eth_crs,i_eth_col
);
	localparam HEADER_LENGTH = 4'd14;
	
	localparam ST_IDEL = 8'd1;
	localparam ST_SEND_PDU = 8'd4;
	localparam ST_SEND_PRE_FCS = 8'd8;
	localparam ST_SEND_FCS = 8'd16;
	localparam ST_SEND_OVER = 8'd32;
	
	reg tx,tx_trig;
	reg [7:0] tx_state,tx_state_next;
	
	reg eth_txen,txen;
	reg [7:0] eth_txd,txd;
	reg [7:0] header[HEADER_LENGTH-1:0];
	reg [3:0] hdr_idx;
	reg [1:0] crc_idx;
	
	wire [7:0] crc0,crc1,crc2,crc3,rddata;
	
	assign o_eth_txen = eth_txen;
	assign o_eth_txer = 0;
	assign o_eth_txd = eth_txd;
	
	wire lastPdu = (o_rd_addr == i_data_ed);
	wire lastFcs = (crc_idx == 2'd3);
	wire calcCrc = (tx_state == ST_SEND_PDU || tx_state == ST_SEND_PRE_FCS);
		
	
	always@(posedge i_gclk or negedge i_rst_n)
	if(!i_rst_n)
		{tx,tx_trig} <= 2'd0;
	else
	begin
		tx_trig <= i_tx_trig;
		if(tx_state == ST_SEND_OVER)
			tx <= 0;
		else if(!tx_trig & i_tx_trig)
			tx <= 1'b1;
	end
	
	always@(*)
	case(tx_state)
	ST_IDEL:
		tx_state_next = ST_SEND_PDU;
	ST_SEND_PDU:
		if(lastPdu)
			tx_state_next = ST_SEND_PRE_FCS;
		else
			tx_state_next = ST_SEND_PDU;
	ST_SEND_PRE_FCS:
		tx_state_next = ST_SEND_FCS;
	ST_SEND_FCS:
		if(lastFcs)
			tx_state_next = ST_SEND_OVER;
		else
			tx_state_next = ST_SEND_FCS;
	default:
		tx_state_next = ST_IDEL;
	endcase
	
	always@(posedge i_gclk or negedge i_rst_n)
	if(!i_rst_n)
		tx_state <= 0;
	else if(tx)
		tx_state <= tx_state_next;
	else
		tx_state <= ST_IDEL;
		
	wire [16-ADDR_WIDTH-1:0] nouse;
		
	counter16 rd_addr_cnt(
		.i_clk(i_gclk),
		.i_rst_n(tx_state == ST_SEND_PDU),
		.i_en(tx_state == ST_SEND_PDU),
		.q({nouse,o_rd_addr}));
		
	always@(posedge i_gclk or negedge i_rst_n)
	if(!i_rst_n)
	begin
		eth_txen <= 0;
		eth_txd <= 0;
	end
	else
	begin
		case(tx_state)
		ST_SEND_PDU:
		begin
			{eth_txd,txd} <= {txd,i_cur_byte};	
			{eth_txen,txen} <= {txen,1'b1};
		end
		ST_SEND_PRE_FCS:
			eth_txd <= txd;
		ST_SEND_FCS:
		begin
			case(crc_idx)
			2'd0:eth_txd <= crc0;
			2'd1:eth_txd <= crc1;
			2'd2:eth_txd <= crc2;
			2'd3:eth_txd <= crc3;
			endcase
			crc_idx <= crc_idx + 1'b1;
		end
		ST_SEND_OVER:
			eth_txen <= 0;
		endcase
		
		if(tx_state != ST_SEND_FCS)
			crc_idx <= 0;
	end
	
	crc crc_inst(i_gclk,i_rst_n&tx_state!=ST_SEND_OVER,calcCrc,txd,{crc0,crc1,crc2,crc3});
	
endmodule







