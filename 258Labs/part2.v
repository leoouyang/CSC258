// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	wire load_x;
	assign load_x = ~KEY[3];
	wire load_y;
	assign load_y = ~KEY[1];
	wire ld_x,ld_y,ld_colour,start_draw;
	wire [3:0] counter;
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	datapath d0(
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_colour(ld_colour),
		.start_draw(start_draw),
		.resetn(resetn),
		.clock(CLOCK_50),
		.data_in(SW[9:0]),
		.counter(counter),
		.colour(colour),
		.x(x),
		.y(y)
		);

    // Instansiate FSM control
    control c0(
		.resetn(resetn),
		.clock(CLOCK_50),
		.load_x(load_x),
		.load_y(load_y),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_colour(ld_colour),
		.start_draw(start_draw),
		.plot(writeEn),
		.counter(counter)
		);
    
endmodule

module control(
	input resetn,
	input clock,
	input load_x,
	input load_y,
	output reg ld_x, ld_y, ld_colour,
	output reg start_draw,
	output reg plot,
	output reg [3:0] counter = 4'b0001
	);
	reg [3:0] current_state, next_state;
	reg done;
	
	localparam  LOAD_X_WAIT     = 4'd0,
					LOAD_X		 	= 4'd1,
					LOAD_Y_WAIT   	= 4'd2,
					LOAD_Y_COLOUR 	= 4'd3,
					DRAW       	 	= 4'd4;
	always @(*)
	begin: state_table 
            case (current_state)
                LOAD_X_WAIT: next_state = load_x ? LOAD_X : LOAD_X_WAIT; // waiting for the load_x to become high
                LOAD_X: next_state = load_x ? LOAD_X : LOAD_Y_WAIT; // load the x value into datapath until load_x become low
                LOAD_Y_WAIT: next_state = load_y ? LOAD_Y_COLOUR : LOAD_Y_WAIT; // waiting for the load_y to become high
                LOAD_Y_COLOUR: next_state = load_y ? LOAD_Y_COLOUR : DRAW; // load y and colour into datapath, start drawing when load_y become low
                DRAW: next_state = done ? LOAD_X_WAIT : DRAW; // we had told the datapath it can start drawing and we are now waiting for the new X input.
            default: next_state = LOAD_X_WAIT;
        endcase
    end 
	
    always @(*)
    begin: enable_signals
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_colour = 1'b0;
		start_draw = 1'b0;
		plot = 1'b0;

        case (current_state)
            LOAD_X: begin
					ld_x = 1'b1;
					end
            LOAD_Y_COLOUR: begin
					ld_y = 1'b1;
					ld_colour = 1'b1;
					end
            DRAW: begin
					start_draw = 1'b1;
					plot = 1'b1;
					end
        endcase
    end 
	
	always@(posedge clock)
    begin
        if(!resetn) begin
            counter <= 4'b0001;
				done <= 1'b0;
		  end
        else 
			if (current_state == DRAW) begin
				if (counter == 4'b1111) 
					done <= 1'b1;
				counter <= counter + 1'b1;
			end	
			else
				done <= 1'b0;
    end 
	
	always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= LOAD_X_WAIT;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
	input ld_x, ld_y, ld_colour,
	input start_draw,
	input clock,
   input resetn,
	input [9:0] data_in,
	input [3:0] counter,
	output reg [2:0] colour,
	output reg [7:0] x,
	output reg [6:0] y
	);
	reg [7:0]x_original;
	reg [6:0]y_original;
	always @ (posedge clock) begin
        if (!resetn) begin
            x <= 8'b00000000; 
            y <= 7'b0000000; 
            colour <= 3'b000;
        end
        else begin
            if (ld_x)begin
					x_original <= {1'b0, data_in[6:0]};
					x <= {1'b0, data_in[6:0]};
				end
            if (ld_y && ld_colour) begin
					y <= data_in[6:0]; 
					y_original <= data_in[6:0]; 
					colour <= data_in[9:7];
				end
            if (start_draw) begin
					x <= x_original + counter[1:0];
					y <= y_original + counter[3:2];
				end
        end
    end
endmodule
