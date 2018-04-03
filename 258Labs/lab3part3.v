module lab3part3(HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, SW, KEY);
	input [7:0] SW;
	input [2:0] KEY;
	
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [7:0] LEDR;

	segdisplay hex1 (
		.a(1'b0),
		.b(1'b0),
		.c(1'b0),
		.d(1'b0),
		.hex(HEX1)
		);
	
	segdisplay hex3 (
		.a(1'b0),
		.b(1'b0),
		.c(1'b0),
		.d(1'b0),
		.hex(HEX3)
		);
	
	reg [7:0] ALUOut;
	wire [4:0] adderresult;
	
	bit4adder b0 (
		.outputsig(adderresult),
		.inputsig(SW[7:0])
		);

	always @(*)
	begin
		case(KEY[2:0])
			3'b111: ALUOut = SW;
			3'b110: begin
						ALUOut[4:0] = adderresult;
						ALUOut[7:5] = 3'b000;
					end
			3'b101: begin
						ALUOut[4:0] = SW[7:4] + SW[3:0];
						ALUOut[7:5] = 3'b000;
					end
			3'b100: begin
						ALUOut[7] = SW[7] | SW[3];
						ALUOut[6] = SW[6] | SW[2];
						ALUOut[5] = SW[5] | SW[1];
						ALUOut[4] = SW[4] | SW[0];
						ALUOut[3] = SW[7] ^ SW[3];
						ALUOut[2] = SW[6] ^ SW[2];
						ALUOut[1] = SW[5] ^ SW[1];
						ALUOut[0] = SW[4] ^ SW[0];
					end
			3'b011: begin
						ALUOut[7:1] = 7'b0000000;
						ALUOut[0] = | SW[7:0];
					end
			3'b010: begin
						ALUOut[7:1] = 7'b0000000;
						ALUOut[0] = ~(^ SW[7:0]);
					end
			default: ALUOut = 8'b00000000;
		endcase
	end
	
	assign LEDR[7:0] = ALUOut;
	
	segdisplay hex0 (
		.a(SW[3]),
		.b(SW[2]),
		.c(SW[1]),
		.d(SW[0]),
		.hex(HEX0)
		);
		
	segdisplay hex2 (
		.a(SW[7]),
		.b(SW[6]),
		.c(SW[5]),
		.d(SW[4]),
		.hex(HEX2)
		);
	
	segdisplay hex4 (
		.a(ALUOut[3]),
		.b(ALUOut[2]),
		.c(ALUOut[1]),
		.d(ALUOut[0]),
		.hex(HEX4)
		);
	
	segdisplay hex5 (
		.a(ALUOut[7]),
		.b(ALUOut[6]),
		.c(ALUOut[5]),
		.d(ALUOut[4]),
		.hex(HEX5)
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
