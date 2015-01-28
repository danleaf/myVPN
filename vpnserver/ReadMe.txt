module clock
#(
parameter KHZ=50000
)
(
  input clk,
  output reg [4:0] h,
  output reg [5:0] m,s,
  output reg [9:0] ms
);
  
	reg [31:0] counter;
 	reg clkms,clks, clkm, clkh;
  
	initial
	begin
		h = 0;
		m = 0;
		s = 0;
		ms = 0;
		clkms = 0;
		clks = 0;
		clkm = 0;
		clkh = 0;
		counter = 0;
	end
	
	
	always @ (posedge clk)
	begin
		if(counter == KHZ - 1) 
			counter <= 0;
		else
			counter <= counter + 1;

		clkms <= (counter == KHZ - 1);
	end  


	always @ (posedge clkms)
	begin
		if(ms == 10'd999) 
			ms <= 0;
		else
			ms <= ms + 10'd1;

		clks <= (ms == 10'd999);
	end  

	always @ (posedge clks)
	begin
		if(s == 6'd59) 
			s <= 0;
		else 
			s <= s + 6'd1;

		clkm <= (s == 6'd59);
	end  

	always @ (posedge clkm)
	begin
		if(m == 6'd59) 
			m <= 0;
		else
			m <= m + 6'd1;

		clkh <= (m == 6'd59);
	end  

	always @ (posedge clkh)
	begin
		if(h == 5'd23) 
			h <= 0;
		else
			h <= h + 5'd1;
	end 
endmodule 



`timescale 1us/1ns
module encode(raw, code);
	input [3:0] raw;
	output reg [6:0] code;
  
	always@(raw)
	begin
		case(raw)
			4'd0: code = 7'b1110111;
			4'd1: code = 7'b0100100;
			4'd2: code = 7'b1011101;
			4'd3: code = 7'b1101101;
			4'd4: code = 7'b0101110;
			4'd5: code = 7'b1101011;
			4'd6: code = 7'b1111011;
			4'd7: code = 7'b0100101;
			4'd8: code = 7'b1111111;
			4'd9: code = 7'b1101111;
			default: code = 7'b1011011;
		endcase
	end

endmodule



module fifo
 #(parameter ASIZE = 3,    
   parameter DSIZE = 8)    
(
    input wclk,rclk,rst,
    input rreq,wreq,    
    input [DSIZE-1:0] wdata,   
    output reg [DSIZE-1:0] rdata,
    output reg full,empty
);
	wire [ASIZE:0] raddr_next, waddr_next,raddr_next_gray, waddr_next_gray;
	wire full_next,empty_next;
	
	reg [ASIZE:0] raddr,raddr_gray,waddr,waddr_gray;
	//reg [ASIZE:0] _raddr_gray_wclk, _waddr_gray_wclk;
	//reg [ASIZE:0] raddr_gray_wclk, waddr_gray_rclk;

	localparam RAMDEPTH = 1 << ASIZE;
	reg [DSIZE-1:0] mem [RAMDEPTH-1:0];
	
	
	waddrproc #(ASIZE) waddrproc_inst(
		.req(wreq),
		.full_now(full),
		.waddr_now(waddr),
		.raddr_gray_wclk(4'b0),
		.waddr_next(waddr_next),
		.waddr_next_gray(waddr_next_gray),
		.full_next(full_next));
	
	always@(posedge wclk or negedge rst)
	if(!rst)
	begin
		waddr <= 0;
		waddr_gray <= 0;
		full <= 0;
		//_raddr_gray_wclk <= 0;
		//raddr_gray_wclk <= 0;
	end
	else
	begin
		waddr <= waddr_next;
		full <= full_next;
		waddr_gray <= waddr_next_gray;
		if(wreq && !full)
		begin 
			mem[waddr[ASIZE-1:0]] <= wdata;
		end
		
		//{raddr_gray_wclk, _raddr_gray} <= {_raddr_gray, raddr_gray};
	end
	
	always@(posedge rclk or negedge rst)
	begin
		if(!rst)
		begin
			raddr <= 0;
			//_waddr_gray <= 0;
			//waddr_gray_rclk <= 0;
		end
		else
		begin
			raddr <= raddr_next;
			empty <= empty_next;
			raddr_gray <= raddr_next_gray;
			if(rreq && !empty)
			begin
				rdata <= mem[raddr[ASIZE-1:0]];
			end
			
			//{waddr_gray_rclk, _waddr_gray} <= {_waddr_gray, waddr_gray};
		end
	end

endmodule

module waddrproc
 #(parameter ASIZE = 3)
(
	input req,full_now,
	input [ASIZE:0] waddr_now,raddr_gray_wclk,
	output [ASIZE:0] waddr_next,waddr_next_gray,
	output full_next
);
	
	assign waddr_next = full_now ? waddr_now : waddr_now + req;
	assign waddr_next_gray = (waddr_next >> 1'b1) ^ waddr_next;
	assign full_next = (waddr_next_gray == {~raddr_gray_wclk[ASIZE:ASIZE-1],raddr_gray_wclk[ASIZE-2:0]});
	
endmodule

module raddrproc
 #(parameter ASIZE = 3)
(
	input req,empty_now,
	input [ASIZE:0] raddr_now,waddr_gray_rclk,
	output [ASIZE:0] raddr_next,raddr_next_gray,
	output empty_next
);
	
	assign raddr_next = empty_now ? raddr_now : raddr_now + req;
	assign raddr_next_gray = (raddr_next >> 1'b1) ^ raddr_next;
	assign empty_next = (raddr_next == waddr_gray_rclk);
	
endmodule



