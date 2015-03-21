module fifo
 #(parameter ASIZE = 3,    
   parameter DSIZE = 16)    
(
    input wclk,rclk,rst,
    input rreq,wreq,    
    input [DSIZE-1:0] wdata,   
    output reg [DSIZE-1:0] rdata,
    output reg full,empty
);

	localparam RAMDEPTH = 1 << ASIZE;
	reg [DSIZE-1:0] mem [RAMDEPTH-1:0];

	wire empty_next,empty_next1,empty_next2;
	wire [ASIZE:0] raddr_next,raddr_next_gray;
	reg [ASIZE:0] raddr,raddr_gray;
	reg [ASIZE:0] _waddr_gray_rclk,waddr_gray_rclk;
	
	wire full_next,full_next1,full_next2;
	wire [ASIZE:0] waddr_next,waddr_next_gray;
	reg [ASIZE:0] waddr,waddr_gray;
	reg [ASIZE:0] _raddr_gray_wclk,raddr_gray_wclk;
	
	assign waddr_next = waddr + 1'b1;
	assign waddr_next_gray = (waddr_next >> 1) ^ waddr_next;
	assign full_next1 = (waddr_next_gray == {~raddr_gray_wclk[ASIZE:ASIZE-1],raddr_gray_wclk[ASIZE-2:0]});
	assign full_next2 = (waddr_gray == {~raddr_gray_wclk[ASIZE:ASIZE-1],raddr_gray_wclk[ASIZE-2:0]});	
	assign full_next = (!full && wreq) ? full_next1 : full_next2;

	
	assign raddr_next = raddr + 1'b1;
	assign raddr_next_gray = (raddr_next >> 1'b1) ^ raddr_next;
	assign empty_next1 = (raddr_next_gray == waddr_gray_rclk);
	assign empty_next2 = (raddr_gray == waddr_gray_rclk);
	assign empty_next = (!empty && rreq) ? empty_next1 : empty_next2;
	
	always@(posedge wclk or negedge rst)
	if(!rst)
	begin
		waddr <= 0;
		waddr_gray <= 0;
		full <= 0;
		_raddr_gray_wclk <= 0;
		raddr_gray_wclk <= 0;
	end
	else
	begin
		if(!full && wreq)
		begin
			waddr <= waddr_next;
			waddr_gray <= waddr_next_gray;
			mem[waddr[ASIZE-1:0]] <= wdata;
		end
		
		full <= full_next;
		{raddr_gray_wclk, _raddr_gray_wclk} <= {_raddr_gray_wclk, raddr_gray};
	end
	

		
	always@(posedge rclk or negedge rst)
	begin
		if(!rst)
		begin
			raddr <= 0;
			rdata <= 0;
			empty <= 1;
			_waddr_gray_rclk <= 0;
			waddr_gray_rclk <= 0;
		end
		else
		begin
			if(!empty && rreq)
			begin
				raddr <= raddr_next;
				raddr_gray <= raddr_next_gray;
				rdata <= mem[raddr[ASIZE-1:0]];
			end
			
			empty <= empty_next;
			{waddr_gray_rclk, _waddr_gray_rclk} <= {_waddr_gray_rclk, waddr_gray};
		end
	end

endmodule

