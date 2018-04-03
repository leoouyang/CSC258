module lab2part3(HEX0, SW);
	input [9:0] SW;
	output [6:0] HEX0;
	
	segdisplay s0 (
		.a(SW[3]),
		.b(SW[2]),
		.c(SW[1]),
		.d(SW[0]),
		.hex(HEX0)
		);
endmodule

module segdisplay(a, b, c, d, hex);
	input a;
	input b;
	input c;
	input d;
	
	output [6:0] hex;
	
	assign hex[0] = (~a & ~b & ~c & d) |
					(~a & b & ~c & ~d) |
					(a & b & ~c & d) | 
					(a & ~b & c & d);
					
	assign hex[1] = (a & b & ~c & ~d) |
					(~a & b & ~c & d) |
					(a & c & d) |
					(b & c & ~d);
					
	assign hex[2] = (~a & ~b & c & ~d) |
					(a & b & ~c & ~d) |
					(a & b & c);
					
	assign hex[3] = (~a & ~b & ~c & d) |
					(~a & b & ~c & ~d) |
					(b & c & d) |
					(a & ~b & c & ~d);
					
	assign hex[4] = (~a & b & ~c & ~d) |
					(~a & d) |
					(a & ~b & ~c & d);
					
	assign hex[5] = (~a & ~b & ~c & d) |
					(~a & ~b & c) |
					(~a & b & c & d) |
					(a & b & ~c & d);
					
	assign hex[6] = (~a & ~b & ~c) |
					(~a & b & c & d) |
					(a & b & ~c & ~d);
endmodule