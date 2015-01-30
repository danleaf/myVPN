module clock
#(
parameter KHZ=50000
)
(
  input clk,
  output reg [6:0] num,
  output reg [7:0] sel
);
  
	reg [4:0] h;
	reg [5:0] m,s;
	reg [9:0] ms;
	reg [31:0] counter;
 	reg clkms,clks, clkm, clkh;
	
   parameter INIT = 8'b11111111;
	parameter SHH = 8'b01111111;
	parameter SHL = 8'b10111111; 
	parameter SMH = 8'b11011111;
	parameter SML = 8'b11101111;
	parameter SSH = 8'b11110111;
	parameter SSL = 8'b11111011;
	parameter SMSH = 8'b11111101;
	parameter SMSL = 8'b11111110;
	
	wire [6:0] hh,hl,mh,ml,sh,sl,msh,msl;
	wire [3:0] _hl,_hh,_mh,_ml,_sh,_sl,_msh,_msl;
  
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
		sel = INIT;
	end
	
	
	always @ (posedge clk)
	begin
		if(counter == KHZ - 1) 
			counter <= 0;
		else
			counter <= counter + 1;

		clkms <= (counter == KHZ - 1);
	end  
	
	always@(sel or hh or hl or mh or ml or sh or sl or msh or msl)
	begin	
		case(sel)
		SHH:num = hh;
		SHL:num = hl;
		SMH:num = mh;
		SML:num = ml;
		SSH:num = sh;
		SSL:num = sl;
		SMSH:num = msh;
		SMSL:num = msl;
		default:num = 7'd0;
		endcase
	end


	always @ (posedge clkms)
	begin
		if(ms == 10'd999) 
			ms <= 0;
		else
			ms <= ms + 10'd1;

		clks <= (ms == 10'd999);
		case(sel)
		INIT:sel <= SHH;
		SHH:sel <= SHL;
		SHL:sel <= SMH;
		SMH:sel <= SML;
		SML:sel <= SSH;
		SSH:sel <= SSL;
		SSL:sel <= SMSH;
		SMSH:sel <= SMSL;
		SMSL:sel <= SHH;
		default:sel <= INIT;
		endcase
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
	
	
	assign _hh = h / 4'd10;
	assign _hl = h % 4'd10;
	assign _mh = m / 4'd10;
	assign _ml = m % 4'd10;
	assign _sh = s / 4'd10;
	assign _sl = s % 4'd10;
	assign _msh = ms / 7'd100;
	assign _msl = ms / 7'd10 % 7'd10;
	
	encode i0(_hh,hh);
	encode i1(_hl,hl);
	encode i2(_mh,mh);
	encode i3(_ml,ml);
	encode i4(_sh,sh);
	encode i5(_sl,sl);
	encode i6(_msh,msh);
	encode i7(_msl,msl);
	
endmodule 

module encode(raw, code);
	input [3:0] raw;
	output reg [6:0] code;
  /*
	0xc0,0xf9,0xa4,0xb0,//0~3
	0x99,0x92,0x82,0xf8,//4~7
	0x80,0x90,0x88,0x83,//8~b
	0xc6,0xa1,0x86,0x8e //c~f
*/
	always@(raw)
	begin
		case(raw)
			4'd0: code = 7'hC0;
			4'd1: code = 7'hF9;
			4'd2: code = 7'hA4;
			4'd3: code = 7'hB0;
			4'd4: code = 7'h99;
			4'd5: code = 7'h92;
			4'd6: code = 7'h82;
			4'd7: code = 7'hF8;
			4'd8: code = 7'h80;
			4'd9: code = 7'h90;
			default: code = 7'h86;
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
	reg [ASIZE:0] raddr_gray_wclk, waddr_gray_rclk;

	localparam RAMDEPTH = 1 << ASIZE;
	reg [DSIZE-1:0] mem [RAMDEPTH-1:0];
	
	
	waddrproc #(ASIZE) waddrproc_inst(
		.req(wreq),
		.full_now(full),
		.waddr_now(waddr),
		.raddr_gray_wclk(raddr_gray_wclk),
		.waddr_next(waddr_next),
		.waddr_next_gray(waddr_next_gray),
		.full_next(full_next));
	
	raddrproc #(ASIZE) raddrproc_inst(
		.req(rreq),
		.empty_now(empty),
		.raddr_now(raddr),
		.waddr_gray_rclk(waddr_gray_rclk),
		.raddr_next(raddr_next),
		.raddr_next_gray(raddr_next_gray),
		.empty_next(empty_next));
	
	always@(posedge wclk or negedge rst)
	if(!rst)
	begin
		waddr <= 0;
		waddr_gray <= 0;
		full <= 0;
		//_raddr_gray_wclk <= 0;
		raddr_gray_wclk <= 0;
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
		raddr_gray_wclk <= raddr_gray;
	end
	
	always@(posedge rclk or negedge rst)
	begin
		if(!rst)
		begin
			raddr <= 0;
			empty <= 1;
			//_waddr_gray <= 0;
			waddr_gray_rclk <= 0;
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
			waddr_gray_rclk <= waddr_gray;
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


