//SW[2:0] data inputs
//SW[9] select signal

//LEDR[0] output display
module lab2(LEDR, SW);
	input [9:0] SW;
	output [9:0] LEDR;
	
	wire outputUV;
	wire outputWX;
	
	mux2to1 m0(
		.x(SW[3]),
		.y(SW[2]),
		.s(SW[8]),
		.m(outputUV)
		);
		
	mux2to1 m1(
		.x(SW[1]),
		.y(SW[0]),
		.s(SW[8]),
		.m(outputWX)
		);
	
	mux2to1 m2(
		.x(outputUV),
		.y(outputWX),
		.s(SW[9]),
		.m(LEDR[0])
		);
	
endmodule

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;

endmodule
