module eth_commu
(
	input i_clk_wr,i_clk_eth,i_rst_n,
	input [7:0] i_data,
	
	//connected with 88e1111
	output o_eth_txen,
	output o_eth_txer,
	output [7:0] o_eth_txd,
	input i_eth_rxclk,
	input i_eth_rxdv,
	input i_eth_rxer,
	input [7:0] i_eth_rxd,
	input i_eth_crs,i_eth_col,
	inout io_eth_mdio,
	output o_eth_mdc
);

endmodule
