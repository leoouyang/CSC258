
module lab4part3(LEDR, KEY, SW);
	input [3:0] KEY;
	input [9:0] SW;
	output [7:0] LEDR;
	
	EightBitShift e1(
			.LoadVal(SW[7:0]),
			.Load_n(KEY[1]),
			.ShiftRight(KEY[2]),
			.ASR(KEY[3]),
			.clk(KEY[0]),
			.reset_n(SW[9]),
			.Q(LEDR[7:0])
	);
	
endmodule

module EightBitShift(LoadVal, Load_n, ShiftRight, ASR, clk, reset_n, Q);
	input[7:0] LoadVal;
	input Load_n;
	input ShiftRight;
	input ASR;
	input clk;
	input reset_n;
	output [7:0] Q;
	
	wire [7:0] out_to_in;
	wire connector;

	mux2to1 m0(
		.x(1'b0),
		.y(out_to_in[7]),
		.s(ASR),
		.m(connector),
		);
		
	shifterbit s7(
		.load_val(LoadVal[7]),
		.in(connector),
		.out(out_to_in[7]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);

	shifterbit s6(
		.load_val(LoadVal[6]),
		.in(out_to_in[7]),
		.out(out_to_in[6]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);
	
	shifterbit s5(
		.load_val(LoadVal[5]),
		.in(out_to_in[6]),
		.out(out_to_in[5]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);
	
	shifterbit s4(
		.load_val(LoadVal[4]),
		.in(out_to_in[5]),
		.out(out_to_in[4]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);
	
	shifterbit s3(
		.load_val(LoadVal[3]),
		.in(out_to_in[4]),
		.out(out_to_in[3]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);
	
	shifterbit s2(
		.load_val(LoadVal[2]),
		.in(out_to_in[3]),
		.out(out_to_in[2]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);
	
	shifterbit s1(
		.load_val(LoadVal[1]),
		.in(out_to_in[2]),
		.out(out_to_in[1]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);
	
	shifterbit s0(
		.load_val(LoadVal[0]),
		.in(out_to_in[1]),
		.out(out_to_in[0]),
		.shift(ShiftRight),
		.load_n(Load_n),
		.clk(clk),
		.reset_n(reset_n)
	);
	assign Q = out_to_in;
endmodule	

module shifterbit(load_val, in, out, shift, load_n, clk, reset_n);
	input load_val;
	input in;
	input shift;
	input load_n;
	input clk;
	input reset_n;
	output out;

	wire data_from_other_mux;
	wire data_to_dff;

	mux2to1 m0(
		.x(out),
		.y(in),
		.s(shift),
		.m(data_from_other_mux)
	);
	
	mux2to1 m1(
		.x(load_val),
		.y(data_from_other_mux),
		.s(load_n),
		.m(data_to_dff)
	);
		
	flipflop f0(
		.d(data_to_dff),
		.q(out),
		.clock(clk),
		.reset_n(reset_n)
	);
endmodule

module flipflop(d, q, clock, reset_n);
	input d;
	input reset_n;
	input clock;
	output reg q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 0; 
		else
			q <= d;
	end
	
endmodule


module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;


endmodule
