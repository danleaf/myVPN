
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
  output reg [31:0] data,
  output intr
);
	reg rednow,redlast;
	//reg [31:0] counter;
	reg [31:0] ticks;
	reg [5:0] state;
	reg [31:0] code;
	reg code0,code1;
	
	wire chg,bit0,bit1,b;
	wire [5:0] state_next;
	
	/*localparam IDEL = 40'h0;
	localparam BOOTSTART = 40'h1;
	localparam BIT0START = 40'h2;
	localparam BIT1START = 40'h4;
	localparam BIT2START = 40'h8;
	localparam BIT3START = 40'h10;
	localparam BIT4START = 40'h20;
	localparam BIT5START = 40'h40;
	localparam BIT6START = 40'h80;
	localparam BIT7START = 40'h100;
	localparam BIT8START = 40'h200;
	localparam BIT9START = 40'h400;
	localparam BIT10START = 40'h800;
	localparam BIT11START = 40'h1000;
	localparam BIT12START = 40'h2000;
	localparam BIT13START = 40'h4000;
	localparam BIT14START = 40'h8000;
	localparam BIT15START = 40'h10000;
	localparam BIT16START = 40'h20000;
	localparam BIT17START = 40'h40000;
	localparam BIT18START = 40'h80000;
	localparam BIT19START = 40'h100000;
	localparam BIT20START = 40'h200000;
	localparam BIT21START = 40'h400000;
	localparam BIT22START = 40'h800000;
	localparam BIT23START = 40'h1000000;
	localparam BIT24START = 40'h2000000;
	localparam BIT25START = 40'h4000000;
	localparam BIT26START = 40'h8000000;
	localparam BIT27START = 40'h10000000;
	localparam BIT28START = 40'h20000000;
	localparam BIT29START = 40'h40000000;
	localparam BIT30START = 40'h80000000;
	localparam BIT31START = 40'h100000000;*/
	
	localparam BIT0START = 6'd0;
	localparam BIT1START = 6'd1;
	localparam BIT2START = 6'd2;
	localparam BIT3START = 6'd3;
	localparam BIT4START = 6'd4;
	localparam BIT5START = 6'd5;
	localparam BIT6START = 6'd6;
	localparam BIT7START = 6'd7;
	localparam BIT8START = 6'd8;
	localparam BIT9START = 6'd9;
	localparam BIT10START = 6'd10;
	localparam BIT11START = 6'd11;
	localparam BIT12START = 6'd12;
	localparam BIT13START = 6'd13;
	localparam BIT14START = 6'd14;
	localparam BIT15START = 6'd15;
	localparam BIT16START = 6'd16;
	localparam BIT17START = 6'd17;
	localparam BIT18START = 6'd18;
	localparam BIT19START = 6'd19;
	localparam BIT20START = 6'd20;
	localparam BIT21START = 6'd21;
	localparam BIT22START = 6'd22;
	localparam BIT23START = 6'd23;
	localparam BIT24START = 6'd24;
	localparam BIT25START = 6'd25;
	localparam BIT26START = 6'd26;
	localparam BIT27START = 6'd27;
	localparam BIT28START = 6'd28;
	localparam BIT29START = 6'd29;
	localparam BIT30START = 6'd30;
	localparam BIT31START = 6'd31;
	localparam BOOTSTART = 6'd32;
	localparam IDEL = 6'd33;
	localparam DATAOK = 6'd34;
	
	initial
	begin
		ticks = 0;
		//clk = 0;
		//counter = 0;
		state  = IDEL;
	end
	
	
	/*always@(posedge rawclk)
	begin
		if(counter == CLKMHZ - 1)
			counter <= 0;
		else
			counter <= counter + 1;
			
		clk <= (counter == CLKMHZ - 1);
	end*/

	caclstate i0(.state_now(state),.state_next(state_next),.ticks(ticks),.b(b));
	
	
	always@(posedge clk)
	begin
		rednow <= red;
		redlast <= rednow;
	end
	
	assign chg = NEG[0] ? (redlast && !rednow) : (!redlast && rednow);
	
	always@(posedge clk)
	if(chg)
		ticks <= 0;
	else
		ticks <= ticks + 1;
	
	always@(posedge clk)
	if(chg)
	begin
		code[31:0] <= {code[30:0],b};
		state <= state_next;
		
		if(state == IDEL)
		begin
			code[0] <= 1'bx;
			state <= BOOTSTART;
		end
		else if(state == BOOTSTART)
		begin
			code[0] <= 1'bx;
			if(ticks[31:3] == BOOT[31:3])
				state <= BIT0START;
			else
				state <= IDEL;
		end
		else if(state >= BIT0START && state <= BIT30START)
		begin
			state <= (bit0 || bit1) ? state + 1'b1 : IDEL;
			code[0] <= bit1 ? 1'b1 : 1'b0;
		end		
		else if(state == BIT31START)
		begin
			state <= (bit0 || bit1) ? DATAOK : IDEL;
			code[0] <= bit1 ? 1'b1 : 1'b0;
		end	
		else
		begin
			code[0] <= 1'bx;
			state <= IDEL;
		end		
	end
	
	
	always@(posedge clk)
	if(intr)
	begin
		data <= code;
	end
	
	assign intr = (state == DATAOK);
	assign bit0 = (ticks[31:3] == WIDTH0[31:3]);
	assign bit1 = (ticks[31:3] == WIDTH1[31:3]);	

endmodule

module caclstate
#(
	parameter STATE_WIDTH = 6,
	parameter TICKS_WIDTH = 32,
	parameter BOOT = 13500,
	parameter WIDTH0 = 1125,
	parameter WIDTH1 = 2250
)
(
  input [STATE_WIDTH-1:0] state_now,
  input [TICKS_WIDTH-1:0] ticks,
  output reg [STATE_WIDTH-1:0] state_next,
  output b
);
	localparam BIT0START = 6'd0;
	localparam BIT1START = 6'd1;
	localparam BIT2START = 6'd2;
	localparam BIT3START = 6'd3;
	localparam BIT4START = 6'd4;
	localparam BIT5START = 6'd5;
	localparam BIT6START = 6'd6;
	localparam BIT7START = 6'd7;
	localparam BIT8START = 6'd8;
	localparam BIT9START = 6'd9;
	localparam BIT10START = 6'd10;
	localparam BIT11START = 6'd11;
	localparam BIT12START = 6'd12;
	localparam BIT13START = 6'd13;
	localparam BIT14START = 6'd14;
	localparam BIT15START = 6'd15;
	localparam BIT16START = 6'd16;
	localparam BIT17START = 6'd17;
	localparam BIT18START = 6'd18;
	localparam BIT19START = 6'd19;
	localparam BIT20START = 6'd20;
	localparam BIT21START = 6'd21;
	localparam BIT22START = 6'd22;
	localparam BIT23START = 6'd23;
	localparam BIT24START = 6'd24;
	localparam BIT25START = 6'd25;
	localparam BIT26START = 6'd26;
	localparam BIT27START = 6'd27;
	localparam BIT28START = 6'd28;
	localparam BIT29START = 6'd29;
	localparam BIT30START = 6'd30;
	localparam BIT31START = 6'd31;
	localparam BOOTSTART = 6'd32;
	localparam IDEL = 6'd33;
	localparam DATAOK = 6'd34;
	
	wire bit0,bit1;
	
	assign b = bit1 ? 1'b1 : 1'b0;
	
	assign bit0 = (ticks[31:3] == WIDTH0[31:3]);
	assign bit1 = (ticks[31:3] == WIDTH1[31:3]);
	
	always@(state_now or ticks or bit0 or bit1)
	if(state_now == IDEL)
	begin
		state_next = BOOTSTART;
	end
	else if(state_now == BOOTSTART)
	begin
		if(ticks[31:3] == BOOT[31:3])
			state_next = BIT0START;
		else
			state_next = IDEL;
	end
	else if(state_now >= BIT0START && state_now <= BIT30START)
	begin
		state_next = (bit0 || bit1) ? state_now + 1'b1 : IDEL;
	end		
	else if(state_now == BIT31START)
	begin
		state_next = (bit0 || bit1) ? DATAOK : IDEL;
	end	
	else
	begin
		state_next = IDEL;
	end

endmodule

/*BIT0START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[31]} <= {BIT1START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[31]} <= {BIT1START,1'b1};
			else
				state <= IDEL;
				
		BIT1START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[30]} <= {BIT2START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[30]} <= {BIT2START,1'b1};
			else
				state <= IDEL;
				
		BIT2START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[29]} <= {BIT3START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[29]} <= {BIT3START,1'b1};
			else
				state <= IDEL;
				
		BIT3START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[28]} <= {BIT4START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[28]} <= {BIT4START,1'b1};
			else
				state <= IDEL;
				
		BIT4START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[27]} <= {BIT5START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[27]} <= {BIT5START,1'b1};
			else
				state <= IDEL;
				
		BIT5START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[26]} <= {BIT6START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[26]} <= {BIT6START,1'b1};
			else
				state <= IDEL;
				
		BIT6START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[25]} <= {BIT7START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[25]} <= {BIT7START,1'b1};
			else
				state <= IDEL;
				
		BIT7START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[24]} <= {BIT8START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[24]} <= {BIT8START,1'b1};
			else
				state <= IDEL;
				
		BIT8START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[23]} <= {BIT9START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[23]} <= {BIT9START,1'b1};
			else
				state <= IDEL;
				
		BIT9START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[22]} <= {BIT10START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[22]} <= {BIT10START,1'b1};
			else
				state <= IDEL;
				
		BIT10START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[21]} <= {BIT11START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[21]} <= {BIT11START,1'b1};
			else
				state <= IDEL;
				
		BIT11START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[20]} <= {BIT12START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[20]} <= {BIT12START,1'b1};
			else
				state <= IDEL;
				
		BIT12START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[19]} <= {BIT13START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[19]} <= {BIT13START,1'b1};
			else
				state <= IDEL;
				
		BIT13START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[18]} <= {BIT14START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[18]} <= {BIT14START,1'b1};
			else
				state <= IDEL;
				
		BIT14START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[17]} <= {BIT15START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[17]} <= {BIT15START,1'b1};
			else
				state <= IDEL;
				
		BIT15START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[16]} <= {BIT16START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[16]} <= {BIT16START,1'b1};
			else
				state <= IDEL;
				
		BIT16START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[15]} <= {BIT17START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[15]} <= {BIT17START,1'b1};
			else
				state <= IDEL;
				
		BIT17START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[14]} <= {BIT18START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[14]} <= {BIT18START,1'b1};
			else
				state <= IDEL;
				
		BIT18START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[13]} <= {BIT19START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[13]} <= {BIT19START,1'b1};
			else
				state <= IDEL;
				
		BIT19START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[12]} <= {BIT20START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[12]} <= {BIT20START,1'b1};
			else
				state <= IDEL;
				
		BIT20START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[11]} <= {BIT21START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[11]} <= {BIT21START,1'b1};
			else
				state <= IDEL;
				
		BIT21START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[10]} <= {BIT22START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[10]} <= {BIT22START,1'b1};
			else
				state <= IDEL;
				
		BIT22START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[9]} <= {BIT23START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[9]} <= {BIT23START,1'b1};
			else
				state <= IDEL;
				
		BIT23START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[8]} <= {BIT24START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[8]} <= {BIT24START,1'b1};
			else
				state <= IDEL;
				
		BIT24START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[7]} <= {BIT25START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[7]} <= {BIT25START,1'b1};
			else
				state <= IDEL;
				
		BIT25START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[6]} <= {BIT26START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[6]} <= {BIT26START,1'b1};
			else
				state <= IDEL;
				
		BIT26START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[5]} <= {BIT27START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[5]} <= {BIT27START,1'b1};
			else
				state <= IDEL;
				
		BIT27START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[4]} <= {BIT28START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[4]} <= {BIT28START,1'b1};
			else
				state <= IDEL;
				
		BIT28START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[3]} <= {BIT29START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[3]} <= {BIT29START,1'b1};
			else
				state <= IDEL;
				
		BIT29START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[2]} <= {BIT30START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[2]} <= {BIT30START,1'b1};
			else
				state <= IDEL;
				
		BIT30START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,code[1]} <= {BIT31START,1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,code[1]} <= {BIT31START,1'b1};
			else
				state <= IDEL;
				
		BIT31START:
			if(ticks[31:3] == WIDTH0[31:3])
				{state,data} <= {IDEL,code[31:1],1'b0};
			else if(ticks[31:3] == WIDTH1[31:3])
				{state,data} <= {IDEL,code[31:1],1'b1};
			else
				state <= IDEL;*/