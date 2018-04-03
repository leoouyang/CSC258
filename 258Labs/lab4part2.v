module lab4part2(LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, SW, KEY);
	input [9:0] SW;
	input [0:0] KEY;
	
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	wire [7:0] ALUOut;
	
	reg [7:0] q;
	
	always@(posedge KEY[0])
	begin
		if (SW[9] == 1'b1)
			q <= 8'b00000000;
		else
			q <= ALUOut;
	end
	
	ALUUnit a1 (	
		.sigA(SW[3:0]),
		.sigB(q[3:0]),
		.func_in(SW[7:5]),
		.ALUOut(ALUOut)
		);
		
	segdisplay hex0 (
		.a(SW[3]),
		.b(SW[2]),
		.c(SW[1]),
		.d(SW[0]),
		.hex(HEX0)
		);
		
	segdisplay hex1 (
		.a(1'b0),
		.b(1'b0),
		.c(1'b0),
		.d(1'b0),
		.hex(HEX1)
		);
		
	segdisplay hex2 (
		.a(1'b0),
		.b(1'b0),
		.c(1'b0),
		.d(1'b0),
		.hex(HEX2)
		);
		
	segdisplay hex3 (
		.a(1'b0),
		.b(1'b0),
		.c(1'b0),
		.d(1'b0),
		.hex(HEX3)
		);
		
	segdisplay hex4 (
		.a(q[3]),
		.b(q[2]),
		.c(q[1]),
		.d(q[0]),
		.hex(HEX4)
		);
	
	segdisplay hex5 (
		.a(q[7]),
		.b(q[6]),
		.c(q[5]),
		.d(q[4]),
		.hex(HEX5)
		);
	
	assign LEDR[7:0] = ALUOut;
	
endmodule

module ALUUnit(sigA, sigB, func_in, ALUOut);
	input [3:0] sigA;
	input [3:0] sigB;
	input [2:0] func_in;
	
	output [7:0] ALUOut;

	wire [4:0] adderresult;
	
	bit4adder b0 (
		.outputsig(adderresult),
		.inputsig({sigA, sigB})
		);
		
	reg [7:0] ALUOut;
	
	always @(*)
	begin
		case(func_in[2:0])
			3'b000: ALUOut <= {sigA, sigB};
			3'b001: begin
						ALUOut[4:0] <= adderresult;
						ALUOut[7:5] <= 3'b000;
					end
			3'b010: begin
						ALUOut[4:0] <= sigA + sigB;
						ALUOut[7:5] <= 3'b000;
					end
			3'b011: begin
						ALUOut[7] <= sigA[3] | sigB[3];
						ALUOut[6] <= sigA[2] | sigB[2];
						ALUOut[5] <= sigA[1] | sigB[1];
						ALUOut[4] <= sigA[0] | sigB[0];
						ALUOut[3] <= sigA[3] ^ sigB[3];
						ALUOut[2] <= sigA[2] ^ sigB[2];
						ALUOut[1] <= sigA[1] ^ sigB[1];
						ALUOut[0] <= sigA[0] ^ sigB[0];
					end
			3'b100: begin
						ALUOut[7:1] <= 7'b0000000;
						ALUOut[0] <= | {sigA, sigB};
					end
			3'b101: ALUOut <= sigB << sigA;
			3'b110: ALUOut <= sigB >> sigA;
			3'b111: ALUOut <= sigA * sigB;
			default: ALUOut <= 8'b00000000;
		endcase
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

module bit4adder(outputsig, inputsig);

	input [7:0] inputsig;
	output [4:0] outputsig;
	
	wire cbit0;
	wire cbit1;
	wire cbit2;
	
	carryadder adder1(
		.cout(cbit0),
		.out(outputsig[0]),
		.c(1'b0),
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
		.cout(outputsig[4]),
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
