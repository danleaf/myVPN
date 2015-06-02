module test(input clk,input rst,input [1:0] a,output [127:0] q);
	
	reg [7:0] mem[0:63];
	integer i;
	reg [7:0] m[0:15];
	
	assign q = {m[0],m[1],m[2],m[3],m[4],m[5],m[6],m[7],m[8],m[9],m[10],m[11],m[12],m[13],m[14],m[15]};
	
	always@(posedge clk or negedge rst)
	if(!rst)
	begin
		for(i=0;i<64;i=i+1)
			mem[i] <= i;
		for(i=0;i<16;i=i+1)
			m[i] <= 0;
	end
	else
		case(a)
		2'd0:
			for(i=0;i<16;i=i+1)
				m[i] <= mem[i];
		2'd1:
			for(i=0;i<16;i=i+1)
				m[i] <= mem[i+16];
		2'd2:
			for(i=0;i<16;i=i+1)
				m[i] <= mem[i+32];
		2'd3:
			for(i=0;i<16;i=i+1)
				m[i] <= mem[i+48];
		endcase

		//dsdsd
		
endmodule
