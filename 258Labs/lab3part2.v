module lab3part2(LEDR, SW);
	input [8:0] SW;
	output [9:0] LEDR;
	
	bit4adder b1(
		.outputsig(LEDR),
		.inputsig(SW)
		);
		
endmodule

module bit4adder(outputsig, inputsig);

	input [8:0] inputsig;
	output [9:0] outputsig;
	
	wire cbit0;
	wire cbit1;
	wire cbit2;
	
	carryadder adder1(
		.cout(cbit0),
		.out(outputsig[0]),
		.c(inputsig[8]),
		.a(inputsig[4]),
		.b(inputsig[0])
		);

	carryadder adder2(
		.cout(cbit1),
		.out(outputsig[1]),
		.c(cbit0),
		.a(inputsig[5]),
		.b(inputsig[1])
		);
		
	carryadder adder3(
		.cout(cbit2),
		.out(outputsig[2]),
		.c(cbit1),
		.a(inputsig[6]),
		.b(inputsig[2])
		);
		
	carryadder adder4(
		.cout(outputsig[9]),
		.out(outputsig[3]),
		.c(cbit2),
		.a(inputsig[7]),
		.b(inputsig[3])
		);
		
endmodule

module carryadder(cout, out, c, a, b);
	input c;
	input b;
	input a;
	
	output cout;
	output out;
	
	assign cout = (b & a) | (a & c) | (b & c);
	assign out = (a & ~b & ~c) |
					 (~a & b & ~c)  |
					 (~a & ~b & c)  |
					 (a & b & c);
endmodule
