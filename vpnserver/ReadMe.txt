`timescale 1us/1ns
module clock(clk);
  output reg clk;
  
  initial
  begin
    clk = 0;
  end

  always  #5000 clk = ~clk;  
endmodule 


`timescale 1us/1ns
module watch(clk, h, m, s, ms);
  input clk;
  output reg [4:0] h;
  output reg [5:0] m,s;
  output reg [6:0] ms;
  reg clks, clkm, clkh;
  
  parameter INIT = 1;
  parameter COUNT_TIME = 1;
  parameter SET_TIME = 1;
  
  initial
  begin
    h = 0;
    m = 0;
    s = 0;
    ms = 0;
    clks = 0;
    clkm = 0;
    clkh = 0;
  end


  always @ (posedge clk)
  begin
    if(ms == 7'd99) 
      ms <= 0;
    else
      ms <= ms + 7'd1;

    clks <= (ms == 7'd99);
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
module test(clk, cnt);
  input clk;
  output reg [15:0] cnt;
  
  initial
  begin
	cnt = 0;
  end


  always @ (posedge clk)
  begin
	cnt <= cnt + 1;
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

`timescale 1us/1ns
module abcd();
  wire clk; 
  wire [4:0] h;
  wire [5:0] m,s;
  wire [6:0] ms;
  
  wire [7:0] HH,MM,SS,MS; 

  clock i1(clk);
  watch i2(clk, h, m, s, ms);

  encode i3({2'b0,h}, HH);
  encode i4({1'b0,m}, MM);
  encode i5({1'b0,s}, SS);
  encode i6(ms, MS);

endmodule 