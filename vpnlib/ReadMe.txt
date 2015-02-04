
module red
#(
	parameter NEG = 1'b1,
	parameter CLKMHZ = 50,
	parameter BOOT = 13500,
	parameter PULSEWIDTH = 565,
	parameter WIDTH0 = 1125,
	parameter WIDTH1 = 2250
)
(
  input clk,
  input red,
  output [31:0] data,
  output reg red_now,red_last,
  output reg intr,
  output reg [15:0] ticks,
  output reg [5:0] state
);

	//reg red_now,red_last;
	reg [31:0] code;
	
	wire chg,rbit,intr_next,newbit;
	wire [5:0] state_next;
	wire [15:0] ticks_next;
	
	initial
	begin
		ticks = 0;
		state = 0;
		intr = 0;
	end
	
	//divclk1us #(CLKMHZ) clk1us(rawclk, clk);

	caclstate i0(
		.chg(chg),
		.ticks(ticks),
		.state_now(state),
		.state_next(state_next),
		.ticks_next(ticks_next),
		.rbit(rbit),
		.intr(intr_next),
		.newbit(newbit));

	assign chg = (red_last && !red_now);
	
	always@(posedge clk)
	begin
		red_now <= red;
		red_last <= red_now;
		code <= newbit ? {code[30:0],rbit} : code;
		state <= state_next;
		ticks <= ticks_next;
		intr <= intr_next;
	end
	
	assign data = code;
endmodule

module caclstate
#(
	parameter STATE_WIDTH = 6,
	parameter TICKS_WIDTH = 16,
	parameter BOOT = 13500,
	parameter WIDTH0 = 1125,
	parameter WIDTH1 = 2250
)
(
	input chg,
	input [TICKS_WIDTH-1:0] ticks,
	input [STATE_WIDTH-1:0] state_now,
	output reg [STATE_WIDTH-1:0] state_next,
	output [TICKS_WIDTH-1:0] ticks_next,
	output rbit,intr,newbit
);
	localparam IDEL = 6'd0;
	localparam BOOTSTART = 6'd1;
	localparam BIT0START = 6'd2;
	localparam BIT30START = 6'd32;
	localparam BIT31START = 6'd33;
	localparam DATAOK = 6'd34;
	
	wire bit0,bit1,bootok;
	reg illegal;
	
	assign rbit = bit1 ? 1'b1 : 1'b0;
	assign bit0 = (ticks[TICKS_WIDTH-1:3] == WIDTH0[TICKS_WIDTH-1:3]);
	assign bit1 = (ticks[TICKS_WIDTH-1:3] == WIDTH1[TICKS_WIDTH-1:3]);
	assign bootok = (ticks[TICKS_WIDTH-1:3] == BOOT[TICKS_WIDTH-1:3]);
	assign ticks_next = (state_next == IDEL) ? 1'b0 : (chg ? 1'b0 : ticks + 1'b1);
	assign intr = (state_next == DATAOK);
	assign newbit = (state_next != state_now && state_next > BIT0START  && state_next <= DATAOK);
	
	always@(state_now or ticks)
	if(state_now == DATAOK)
		illegal = 1;
	else if(state_now == BOOTSTART && ticks[TICKS_WIDTH-1:3] > BOOT[TICKS_WIDTH-1:3])
		illegal = 1;
	else if(state_now >= BIT0START && state_now <= BIT31START && ticks[TICKS_WIDTH-1:3] > WIDTH1[TICKS_WIDTH-1:3])
		illegal = 1;
	else
		illegal = 0;	
	
	always@(state_now or ticks or bit0 or bit1 or chg or illegal or bootok)
	if(illegal)
		state_next = IDEL;
	else if(!chg)
		state_next = state_now;
	else if(state_now == IDEL)
	begin
		state_next = BOOTSTART;
	end
	else if(state_now == BOOTSTART)
	begin
		if(bootok)
			state_next = BIT0START;
		else
			state_next = IDEL;
	end
	else if(state_now >= BIT0START && state_now <= BIT31START)
	begin
		if(bit1 || bit0)
			state_next = state_now + 1'b1;
		else
			state_next = IDEL;
	end
	else
		state_next = IDEL;

endmodule

module divclk1us
#(parameter CLKMHZ = 50)
(
  input clk,
  output reg outclk
);
	reg [31:0] counter;
	
	initial
	begin
		counter = 0;
		outclk = 0;
	end
	
	always@(posedge clk)
	begin
		if(counter == CLKMHZ - 1)
			counter <= 0;
		else
			counter <= counter + 1;
			
		outclk <= (counter == CLKMHZ - 1);
	end

endmodule
