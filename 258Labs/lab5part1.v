module lab5part1(HEX0, HEX1, KEY, SW);
	input [0:0]KEY;
	input [1:0] SW;
	output [6:0] HEX0, HEX1;
	
	wire [7:0] Q;
		
	Counter c1(
		.Enable(SW[1]),
		.clock(KEY[0]),
		.Clear_b(SW[0]),
		.Q(Q[7:0])
		);
			
	segdisplay hex0 (
		.a(Q[3]),
		.b(Q[2]),
		.c(Q[1]),
		.d(Q[0]),
		.hex(HEX0)
		);
	
	segdisplay hex1 (
		.a(Q[7]),
		.b(Q[6]),
		.c(Q[5]),
		.d(Q[4]),
		.hex(HEX1)
		);
endmodule

module Counter(Enable, clock, Clear_b, Q);
	input Enable;
	input clock;
	input Clear_b;
	output [7:0]Q;
	
	wire [6:0]andconnector;
	
	assign andconnector[0] = Enable & Q[0];
	assign andconnector[1] = andconnector[0] & Q[1];
	assign andconnector[2] = andconnector[1] & Q[2];
	assign andconnector[3] = andconnector[2] & Q[3];
	assign andconnector[4] = andconnector[3] & Q[4];
	assign andconnector[5] = andconnector[4] & Q[5];
	assign andconnector[6] = andconnector[5] & Q[6];
	
	Tflipflop t0(
			.t(Enable),
			.q(Q[0]),
			.clock(clock),
			.Clear_b(Clear_b)
			);
	
	Tflipflop t1(
			.t(andconnector[0]),
			.q(Q[1]),
			.clock(clock),
			.Clear_b(Clear_b)
			);

	Tflipflop t2(
			.t(andconnector[1]),
			.q(Q[2]),
			.clock(clock),
			.Clear_b(Clear_b)
			);

	Tflipflop t3(
			.t(andconnector[2]),
			.q(Q[3]),
			.clock(clock),
			.Clear_b(Clear_b)
			);

	Tflipflop t4(
			.t(andconnector[3]),
			.q(Q[4]),
			.clock(clock),
			.Clear_b(Clear_b)
			);

	Tflipflop t5(
			.t(andconnector[4]),
			.q(Q[5]),
			.clock(clock),
			.Clear_b(Clear_b)
			);

	Tflipflop t6(
			.t(andconnector[5]),
			.q(Q[6]),
			.clock(clock),
			.Clear_b(Clear_b)
			);

	Tflipflop t7(
			.t(andconnector[6]),
			.q(Q[7]),
			.clock(clock),
			.Clear_b(Clear_b)
			);


endmodule

module Tflipflop(t, q, clock, Clear_b);
	input t;
	input clock;
	input Clear_b;
	output reg q;

	always @(posedge clock, negedge Clear_b)
	begin
		if (Clear_b == 1'b0)
			q <= 0; 
		else if(t == 1'b1)
			q <= ~q;
		else
			q <= q;
	end
	
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
