//100MHZ
module triger(input clk, input rst_n,output q,output reg led);

	localparam fclk = 100000000;
	localparam tick = 10;
	localparam f = 1000;		//100HZ
	localparam th = 50000;		//100ns
	localparam div = fclk / f;	
	localparam divh = th / tick;
	
	assign q = s;
	
	reg [23:0] cnt;
	reg [7:0] cnt2;
	reg s;
	
	wire inclk;
	
	pll100m pll(clk,inclk);
	
	always@(posedge inclk or negedge rst_n)
	if(!rst_n)
	begin
		cnt <= 0;
		s <= 1'd1;
	end
	else
	begin
		if(cnt == divh || cnt == div)
			s <= ~s;
		if(cnt == div)
			cnt <= 0;
		else
			cnt <= cnt + 1'd1;
	end
	
	always@(posedge s or negedge rst_n)
	if(!rst_n)
	begin
		cnt2 <= 0;
		led <= 1'd1;
	end
	else
	begin
		if(cnt2 == 8'd49 || cnt2 == 8'd99)
			led <= ~led;
			
		if(cnt == 8'd99)
			cnt2 <= 0;
		else
			cnt2 <= cnt2 + 1'd1;
			
	end
	

endmodule

