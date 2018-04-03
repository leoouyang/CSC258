module finalproject(SW, KEY, CLOCK_50, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
	//wire [1:0] diffculty;
	//assign diffculty = SW[1:0];
	input [0:0]SW;
	input [1:0]KEY;
	input CLOCK_50;
	wire resetn;	
	assign resetn = KEY[0];
	wire go, start_counter, start_enemy, draw_enemy, draw_counter;
	wire increase;
	wire fire;
	assign fire = ~KEY[1];
	wire right;
	assign right = SW[0];
	
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
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
	
	FSM f0(
		.resetn(resetn),
		.clock(CLOCK_50),
		.go(go),
		.start_counter(start_counter),
		.start_enemy(start_enemy),
		.draw_enemy(draw_enemy),
		.draw_counter(draw_counter)
		);
		
	datapath2 d0(
		.resetn(resetn),
		.clock(CLOCK_50),
		.right(right),
		.fire(fire),
		.draw_enemy(draw_enemy),
		.draw_counter(draw_counter),
		.done(go),
		.start_counter(start_counter),
		.start_enemy(start_enemy),
		.x(x),
		.y(y),
		.colour(colour),
		.enable(writeEn)
		);

endmodule
module FSM(
	input resetn,
	input clock,
	input go,
	input start_counter,
	input start_enemy,
	output reg draw_enemy = 1'b0,
	output reg draw_counter = 1'b0
	);
	reg [3:0] current_state, next_state;
	localparam  START_ENEMY = 4'd0,
					DRAW_ENEMY		= 4'd1,
					START_COUNTER	= 4'd2,
					DRAW_COUNTER	= 4'd3;
					
	always @(*)
	begin: state_table 
            case (current_state)
				START_ENEMY: next_state = start_enemy ? DRAW_ENEMY : START_ENEMY;
            DRAW_ENEMY: next_state = go ? START_COUNTER : DRAW_ENEMY;
            START_COUNTER: next_state = start_counter ? DRAW_COUNTER : START_COUNTER;
				DRAW_COUNTER: next_state = go ? START_ENEMY : DRAW_COUNTER;
            default: next_state = START_ENEMY;
        endcase
    end 
	
	always @(*)
    begin: enable_signals
		draw_enemy	= 1'b0;
		draw_counter= 1'b0;

        case (current_state)
	    DRAW_ENEMY:begin
	    			draw_enemy	= 1'b1;
					end
        DRAW_COUNTER: begin
					draw_counter= 1'b1;
					end
        endcase
	end

	always@(posedge clock)
    	begin: state_FFs
        if(!resetn)
            current_state <= START_ENEMY;
        else
            current_state <= next_state;
    	end
endmodule

module datapath2(
	input resetn,
	input clock,
	input right,
	input fire,
	input draw_enemy,
	input draw_counter,
	output reg done,
	output reg start_counter = 1'b0,
	output reg start_enemy = 1'b0,
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour, 
	output reg enable
	);
	wire increase;
	wire [7:0] x_e0;
	wire [6:0] y_e0;
	wire [2:0] colour_e0;
	wire enable_e0;
	wire [7:0] x_c0;
	wire [6:0] y_c0;
	wire [2:0] colour_c0;
	wire enable_c0;
	reg  [17:0]out;
	laserenemiesv2 e0(
		.CLOCK_50(clock),
		.resetn(resetn),
		.right(right),
		.fire(fire),
		.increase(increase),
		.x(x_e0),
		.y(y_e0),
		.colour(colour_e0),
		.writeEn(enable_e0)
		);
	
	counter c0(
		.CLOCK_50(clock),
		.resetn(resetn),
		.increase(increase),
		.x(x_c0),
		.y(y_c0),
		.colour(colour_c0),
		.writeEn(enable_c0)
		);
	//NEED ADD THE PART	FOR COUNTER
	reg [7:0] write_e0 = 8'd80; //questionable
	reg [7:0] read_e0 = 8'd0;
	reg [6:0] write_c0 = 7'd0;
	reg [6:0] read_c0 = 7'd0;
	wire [17:0] data_e0;
	wire [17:0] out_e0;
	wire [17:0] data_c0;
	wire [17:0] out_c0;
	always @(posedge clock)begin
		if (draw_enemy)begin
			if (read_e0 == 8'd159)begin
				read_e0 <= 8'd0;
				done <= 1'b1;
			end
			else
				read_e0 <= read_e0 + 1;
			start_enemy <= 1'b0;
			out <= out_e0;
			enable <= 1'b1;
		end
		else if (draw_counter)begin
			if (read_c0 == 7'd89)begin
				read_c0 <= 7'd0;
				done <= 1'b1;
			end
			else
				read_c0 <= read_c0 + 1;
//			start_counter <= 1'b0;
			out <= out_c0;
			enable <= 1'b1;
		end
		else begin
			enable <= 0;
			done <= 0;
		end
		if (enable_e0)begin
			if (write_e0 == 8'd79)
				start_enemy <= 1'b1;
			else if (write_e0 == 8'd159)
				write_e0 <= 8'd0;
			else
				write_e0 <= write_e0 + 1;
		end
		if (enable_c0)begin
			if (write_c0 == 7'd89)begin
				write_c0 <= 7'd0;
				start_counter <= 1'b1;
			end
			else begin
				write_c0 <= write_c0 + 1;
			end
		end
	end
	assign data_e0 = {x_e0[7:0], y_e0[6:0], colour_e0[2:0]};
	ram160x18 r0(
		.clock(clock),
		.data(data_e0),
		.rdaddress(read_e0),
		.wraddress(write_e0),
		.wren(enable_e0),
		.q(out_e0)
		);
	assign data_c0 = {x_c0[7:0], y_c0[6:0], colour_c0[2:0]};
	ram90x18 r1(
		.clock(clock),
		.data(data_c0),
		.rdaddress(read_c0),
		.wraddress(write_c0),
		.wren(enable_c0),
		.q(out_c0)
		);
	assign x = out[17:10];
	assign y = out[9:3];
	assign colour = out[2:0];
endmodule

module ram160x18 (
	clock,
	data,
	rdaddress,
	wraddress,
	wren,
	q);

	input	  clock;
	input	[17:0]  data;
	input	[7:0]  rdaddress;
	input	[7:0]  wraddress;
	input	  wren;
	output	[17:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock;
	tri0	  wren;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [17:0] sub_wire0;
	wire [17:0] q = sub_wire0[17:0];

	altsyncram	altsyncram_component (
				.address_a (wraddress),
				.address_b (rdaddress),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.q_b (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({18{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 160,
		altsyncram_component.numwords_b = 160,
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = 8,
		altsyncram_component.widthad_b = 8,
		altsyncram_component.width_a = 18,
		altsyncram_component.width_b = 18,
		altsyncram_component.width_byteena_a = 1;


endmodule



module ram90x18 (
	clock,
	data,
	rdaddress,
	wraddress,
	wren,
	q);

	input	  clock;
	input	[17:0]  data;
	input	[6:0]  rdaddress;
	input	[6:0]  wraddress;
	input	  wren;
	output	[17:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock;
	tri0	  wren;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [17:0] sub_wire0;
	wire [17:0] q = sub_wire0[17:0];

	altsyncram	altsyncram_component (
				.address_a (wraddress),
				.address_b (rdaddress),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.q_b (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({18{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 90,
		altsyncram_component.numwords_b = 90,
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = 7,
		altsyncram_component.widthad_b = 7,
		altsyncram_component.width_a = 18,
		altsyncram_component.width_b = 18,
		altsyncram_component.width_byteena_a = 1;


endmodule


module counter
	(
		CLOCK_50,//	On Board 50 MHz
		increase,
		resetn,
		x,
		y,
		colour,
		writeEn
	);
	input	CLOCK_50;						//	50 MHz
//	input   [1:0]   KEY;
	input 	increase;
	input 	resetn;
	
	output [2:0] colour;
	output [7:0] x;
	output [6:0] y;
	output writeEn;
	
	
//	wire increase;
//	assign increase = ~KEY[1];

//	wire resetn;
//	assign resetn = KEY[0];
	wire ld, draw0, draw1, draw2, erase0, erase1, erase2, increase_sig;
	wire done;
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	wire [7:0] x_in = 8'd0;
	wire [6:0] y_in = 7'd0;

    
    // Instansiate datapath
	datapath1 d0(
		.ld(ld),
		.draw0(draw0),
		.draw1(draw1),
		.draw2(draw2),
		.erase0(erase0),
		.erase1(erase1),
		.erase2(erase2),
		.increase_sig(increase_sig),
		.resetn(resetn),
		.clock(CLOCK_50),
		.x_in(x_in),
		.y_in(y_in),
		.x(x),
		.y(y),
		.colour(colour),
		.done(done)
		);

    // Instansiate FSM control
    control1 c0(
		.resetn(resetn),
		.clock(CLOCK_50),
		.increase(increase),
		.done(done),
		.ld(ld),
		.draw0(draw0),
		.draw1(draw1),
		.draw2(draw2),
		.erase0(erase0),
		.erase1(erase1),
		.erase2(erase2),
		.increase_sig(increase_sig),
		.plot(writeEn)
		);
    
endmodule

	
module control1(
	input resetn,
	input clock,
	input increase, //when eliminate an enemy, increase is on for one cycle, increasing the counter by 1
	input done,
	output reg ld,
	output reg increase_sig,
	output reg draw0,
	output reg draw1,
	output reg draw2,
	output reg erase0,
	output reg erase1,
	output reg erase2,
	output reg plot
	);
	//max of num should be 999(10'b1111100111)
	reg [3:0] current_state, next_state;
//	reg	[6:0]y_original;
	
	localparam  	START    	= 4'd0,
			WAIT		= 4'd1,
			INCREASE	= 4'd2,
			ERASE0   	= 4'd3,
			ERASE1   	= 4'd4,
			ERASE2   	= 4'd5,
			DRAW0 		= 4'd6,
			DRAW1 		= 4'd7,
			DRAW2 		= 4'd8,
			WAIT2			= 4'd9;
	always @(*)
	begin: state_table 
            case (current_state)
				START: next_state = ERASE0;
                ERASE0: next_state = done ? ERASE1 : ERASE0;
                ERASE1: next_state = done ? ERASE2 : ERASE1;
                ERASE2: next_state = done ? DRAW0 : ERASE2;
                DRAW0: next_state = done ? DRAW1 : DRAW0;
                DRAW1: next_state = done ? DRAW2 : DRAW1;
                DRAW2: next_state = done ? WAIT : DRAW2;
				WAIT: next_state = increase ? INCREASE : WAIT;
				INCREASE: next_state = WAIT2;
				WAIT2: next_state = increase ? WAIT2 : ERASE0;
            default: next_state = START;
            endcase
    	end 
	
    	always @(*)
    	begin: enable_signals
		ld = 1'b0;
		draw0 = 1'b0;
		draw1 = 1'b0;
		draw2 = 1'b0;
		erase0 = 1'b0;
		erase1 = 1'b0;
		erase2 = 1'b0;
		plot = 1'b0;
		increase_sig = 1'b0;
        	case (current_state)
			START:begin
	    			ld = 1'b1;
			end
			INCREASE:begin
				increase_sig = 1'b1;
			end
        		ERASE0: begin
				erase0 = 1'b1;
				plot = 1'b1;
			end
			ERASE1: begin
				erase1 = 1'b1;
				plot = 1'b1;
			end
			ERASE2: begin
				erase2 = 1'b1;
				plot = 1'b1;
			end
        		DRAW0: begin
				draw0 = 1'b1;
				plot = 1'b1;
			end
        		DRAW1: begin
				draw1 = 1'b1;
				plot = 1'b1;
			end
        		DRAW2: begin
				draw2 = 1'b1;
				plot = 1'b1;
			end
        	endcase
    	end  
	
	always@(posedge clock)
    	begin: state_FFs
        if(!resetn)
            current_state <= START;
        else
            current_state <= next_state;
    	end // state_FFS
endmodule

module datapath1(
	input ld,
	input draw0,
	input draw1,
	input draw2,
	input erase0,	
	input erase1,	
	input erase2,
	input increase_sig,
	input clock,
   input resetn,
	input [7:0] x_in,
	input [6:0] y_in,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour,
	output reg done = 1'b0
	);
	reg [9:0] number = 10'd0;
	reg [7:0] x_original;
	reg [6:0] y_original;
	reg [7:0] x_now;
	reg [6:0] y_now;
	reg [4:0] x_counter = 2'd0;
	reg [2:0] y_counter = 3'd0;
	reg [3:0] num;
	wire [3:0] num_temp;
	assign num_temp = num;
	wire [14:0] pixels;
	wire [5:0] index;
	wire colour_indicator;
	dec_decoder d0(.dec_digit(num_temp), .pixels(pixels));
	always @ (posedge clock) begin //maybe add a reset so that number = 0 after reset
         if (ld)begin
					x_original <= x_in;
					y_original <= y_in;
				end
         else if (draw0|draw1|draw2|erase0|erase1|erase2) begin
					if(x_counter == 2)
						x_counter <= 0;
					else 
						x_counter <= x_counter + 1;
					if(y_counter == 4)
						y_counter <= 0;
					else 
						y_counter <= y_counter + 1;
				end
			else if(increase_sig)
					number <= number + 1;
    end
	always @(*)begin
		if(draw0|draw1|draw2|erase0|erase1|erase2)begin
			if(draw0|draw1|draw2)begin
				if(colour_indicator)
					colour = 3'b111;
				else
					colour = 3'b000;
			end
			else
				colour = 3'b000;
			if(draw0|erase0)
				x_now = x_original;
			else if(draw1|erase1)
				x_now = x_original + 4;
			else
				x_now = x_original + 8;
			y_now = y_original;
			x = x_now + x_counter;
			y = y_now + y_counter;
			done = (x_counter==2) & (y_counter==4);
		end
		else
			done = 1'b0;
	end
	always @(*)begin
		if(draw0)
			num = (number - number/10'd1000*10'd1000) / 7'd100;
		else if (draw1)
			num = (number - number/7'd100*7'd100) / 4'd10;
		else if (draw2)
			num = number - number/4'd10*4'd10;
		else if (!resetn)
			num = 10'd0;
	end
	assign index = x_counter + y_counter*3;
	assign colour_indicator = pixels[index];
	
endmodule

module dec_decoder(dec_digit, pixels);
    input [3:0] dec_digit;
    output reg [14:0] pixels;
   
    always @(*)
        case (dec_digit)
            4'd0: pixels = 15'b111101101101111;
            4'd1: pixels = 15'b100100100100100;
            4'd2: pixels = 15'b111001111100111;
            4'd3: pixels = 15'b111100111100111;
            4'd4: pixels = 15'b100100111101101;
            4'd5: pixels = 15'b111100111001111;
            4'd6: pixels = 15'b111101111001111;
            4'd7: pixels = 15'b100100100100111;
            4'd8: pixels = 15'b111101111101111;
            4'd9: pixels = 15'b111100111101111;
            default: pixels = 15'd0;
        endcase
endmodule

 // Part 2 skeleton
 // Part 2 skeleton

module laserenemiesv2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		resetn,
		fire,
		right,
		// The ports below are for the VGA output.  Do not change.
		increase,
		x,
		y,
		colour,
		writeEn
	);

	input			CLOCK_50;				//	50 MHz
	input  	right;
	
	wire	[7:0]	enemyx1 = 8'd30;
	wire	[6:0]	enemyy1 = 7'd0;

	wire	[7:0]	enemyx2 = 8'd60;
	wire	[6:0]	enemyy2 = 7'd5;
	
	wire	[7:0]	enemyx3 = 8'd95;
	wire	[6:0]	enemyy3 = 7'd10;

	
	input resetn;
	
	input fire;

	wire ld, draw1, draw2, draw3, draw4, draw5, uppos, erase1, erase2, erase3, erase4, erase5, edeath, player;
	wire [3:0] counter;
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	output increase;
	output [2:0] colour;
	output [7:0] x;
	output [6:0] y;
	output writeEn;
	
	reg [7:0] score;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	datapath d0(
		.ld(ld),
		.resetn(resetn),
		.clock(CLOCK_50),
		.fire_in(fire),
		.draw1(draw1),
		.draw2(draw2),
		.draw3(draw3),
		.draw4(draw4),
		.draw5(draw5),
		.erase1(erase1),
		.erase2(erase2),
		.erase3(erase3),
		.erase4(erase4),
		.erase5(erase5),
		.uppos(uppos),
		.sw(right),
		.enemyx1(enemyx1),
		.enemyy1(enemyy1),
		.enemyx2(enemyx2),
		.enemyy2(enemyy2),
		.enemyx3(enemyx3),
		.enemyy3(enemyy3),
		.player(player),
		.edeath(edeath),
		.counter(counter),
		.increase(increase),
		.x(x),
		.y(y)
		);

    // Instansiate FSM control
    control c0(
		.resetn(resetn),
		.clock(CLOCK_50),
		.ld(ld),
		.plot(writeEn),
		.uppos(uppos),
		.draw1(draw1),
		.draw2(draw2),
		.draw3(draw3),
		.draw4(draw4),
		.draw5(draw5),
		.erase1(erase1),
		.erase2(erase2),
		.erase3(erase3),
		.erase4(erase4),
		.erase5(erase5),
		.player(player),
		.edeath(edeath),
		.counter(counter),
		.colour(colour)
		);
endmodule

	
module control(
	input resetn,
	input clock,
	output reg ld,
	output reg plot,
	output reg uppos,
	output reg draw1,
	output reg draw2,
	output reg draw3,
	output reg draw4,
	output reg draw5,
	output reg erase1,
	output reg erase2,
	output reg erase3,
	output reg erase4,
	output reg erase5,
	output reg edeath,
	output reg player,
	output reg [3:0] counter = 4'b0000,
	output reg [2:0] colour = 3'b111
	);
	reg [4:0] current_state, next_state;
	wire done;
	localparam  	LOAD    	= 5'd0,
					DRAW1			= 5'd1,
					WAIT   		= 5'd2,
					ERASE 		= 5'd3,
					CHECK 		= 5'd4,
					START			= 5'd5,
					LOAD2    	= 5'd6,
					POSUP			= 5'd7,
					DRAW2			= 5'd8,
					EDEATH		= 5'd9,
					ERASE2		= 5'd10,
					DRAW3			= 5'd11,
					ERASE3		= 5'd12,
					DRAW4			= 5'd13,
					ERASE4		= 5'd14,
					DRAW5		= 5'd15,
					ERASE5		= 5'd16;

	reg [63:0] RateDivide2 = 64'd5000000;
	reg update = 1'b0;
	
	always @(posedge clock)
	begin
		if (current_state == WAIT)
		begin
			RateDivide2 <= RateDivide2 - 1'b1;
			if (RateDivide2 == 64'd4999900)
			begin
				update <= 1'b1;
				RateDivide2 <= 64'd5000000;
			end
		end
		else
			update = 1'b0;
	end
	
	always @(*)
	begin: state_table 
            case (current_state)
				START: next_state = POSUP;
				POSUP: next_state = EDEATH;
				EDEATH: next_state = DRAW1;
				DRAW1: next_state = done ? DRAW2 : DRAW1;
				DRAW2: next_state = done ? DRAW3 : DRAW2;
				DRAW3: next_state = done ? DRAW4 : DRAW3;
				DRAW4: next_state = done ? DRAW5 : DRAW4;
				DRAW5: next_state = done ? WAIT : DRAW5;
				WAIT: next_state = update ? ERASE : WAIT;
				ERASE: next_state = done ? ERASE2 : ERASE;
				ERASE2: next_state = done ? ERASE3 : ERASE2;
				ERASE3: next_state = done ? ERASE4 : ERASE3;
				ERASE4: next_state = done ? ERASE5 : ERASE4;
				ERASE5: next_state = done ? POSUP : ERASE5;
            default: next_state = START;
        endcase
    end
	
    always @(*)
    begin: enable_signals
		ld = 1'b0;
		plot = 1'b0;
		colour = 3'b000;
		uppos = 1'b0;
		draw1 = 1'b0;
		draw2 = 1'b0;
		draw3 = 1'b0;
		draw4 = 1'b0;
		erase1 = 1'b0;
		erase2 = 1'b0;
		erase3 = 1'b0;
		erase4 = 1'b0;
		player = 1'b0;
		edeath = 1'b0;
		draw5 = 1'b0;
		erase5 = 1'b0;

        case (current_state)
			START:begin
	    			ld = 1'b1;
					end
			POSUP:begin
					uppos = 1'b1;
					end
			EDEATH:begin
					edeath = 1'b1;
					end
			DRAW1: begin
					plot = 1'b1;
					colour = 3'b111;
					draw1 = 1'b1;
					end
			DRAW2: begin
					plot = 1'b1;
					colour = 3'b111;
					draw2 = 1'b1;
					end
			DRAW3: begin
					plot = 1'b1;
					colour = 3'b111;
					draw3 = 1'b1;
					end
			DRAW4: begin
					plot = 1'b1;
					colour = 3'b100;
					draw4 = 1'b1;
					player = 1'b1;
					end
			DRAW5: begin
					plot = 1'b1;
					colour = 3'b110;
					draw5 = 1'b1;
					end
			ERASE:begin
					plot = 1'b1;
					colour = 3'b000;
					erase1 = 1'b1;
					end
			ERASE2:begin
					plot = 1'b1;
					colour = 3'b000;
					erase2 = 1'b1;
					end
			ERASE3:begin
					plot = 1'b1;
					colour = 3'b000;
					erase3 = 1'b1;
					end
			ERASE4:begin
					plot = 1'b1;
					colour = 3'b000;
					erase4 = 1'b1;
					player = 1'b1;
					end
			ERASE5:begin
					plot = 1'b1;
					colour = 3'b000;
					erase5 = 1'b1;
					end
        endcase
    end
	
	always@(posedge clock)
    	begin
        if(!resetn) begin
            counter <= 4'b0000;
		  end
        else 
			if (plot == 1'b1) begin
				counter <= counter + 1'b1;
			end
    	end 
	assign done = (counter == 4'b1111);	
	
	always@(posedge clock)
    	begin: state_FFs
        if(!resetn)
            current_state <= START;
        else
            current_state <= next_state;
    	end // state_FFS
endmodule

module datapath(
	input ld,
	input clock,
    input resetn,
	input draw1,
	input draw2,
	input draw3,
	input draw4,
	input draw5,
	input erase1,
	input erase2,
	input erase3,
	input erase4,
	input erase5,
	input edeath,
	input player,
	input sw,
	input fire_in,
	input [7:0] enemyx1,
	input [6:0] enemyy1,
	
	input [7:0] enemyx2,
	input [6:0] enemyy2,
	
	input [7:0] enemyx3,
	input [6:0] enemyy3,
	
	input uppos,
	input [3:0] counter,
	output reg increase,
	output [7:0] x,
	output [6:0] y
	);
	
	reg laserexist;
	reg [7:0] laserx;
	reg [6:0] lasery;
	
	reg [7:0] enemx1;
	reg [6:0] enemy1;
	
	reg [7:0] enemx2;
	reg [6:0] enemy2;
	
	reg [7:0] enemx3;
	reg [6:0] enemy3;
	
	reg [7:0] playerx = 8'd80;
	reg [6:0] playery = 7'd100;
	
	reg [7:0] relevantx;
	reg [6:0] relevanty;
	
	reg [6:0] randoCount = 7'd11;
	
	always @ (posedge clock) begin
		if(randoCount == 7'd149)
			randoCount <= 7'd11;
		else
			randoCount <= randoCount + 1;
	
			if (ld)begin
					enemx1 <= enemyx1; 
					enemy1 <= enemyy1;
					
					enemx2 <= enemyx2;
					enemy2 <= enemyy2;
					
					enemx3 <= enemyx3;
					enemy3 <= enemyy3;
				end
			
			else if (edeath)begin
				if (enemy1 > 100) begin
					enemy1 <= 0;
					enemx1 <= randoCount + 10;
				end
				else if (((enemy1 - lasery) < 5) || ((lasery - enemy1) < 5))
					if (((enemx1 - laserx) < 5) || ((laserx - enemx1) < 5)) begin
						enemy1 <= 0;
						enemx1 <= randoCount + 10;
						laserexist <= 1'b0;
						increase <= 1'b1;
						end
				if (enemy2 > 100) begin
					enemy2 <= 0;
					enemx2 <= randoCount + 10;
				end
				else if (((enemy2 - lasery) < 5) || ((lasery - enemy2) < 5))
					if (((enemx2 - laserx) < 5) || ((laserx - enemx2) < 5)) begin
						enemy2 <= 0;
						enemx2 <= randoCount + 10;
						laserexist <= 1'b0;
						increase <= 1'b1;
						end
				if (enemy3 > 100) begin
					enemy3 <= 0;
					enemx3 <= randoCount + 10;
				end
				else if (((enemy3 - lasery) < 5) || ((lasery - enemy3) < 5))
					if (((enemx3 - laserx) < 5) || ((laserx - enemx3) < 5)) begin
						enemy3 <= 0;
						enemx3 <= randoCount + 10;
						laserexist <= 1'b0;
						increase <= 1'b1;
					end
			end

			else if (uppos)begin
				enemy1 <= enemy1 + 1;
				enemy2 <= enemy2 + 2;
				enemy3 <= enemy3 + 3;
				if (sw)
					playerx <= playerx + 4;
				else
					playerx <= playerx - 4;
				if (laserexist) begin
					if (laserx == 161) begin
						laserx <= playerx;
						lasery <= playery - 1;
					end
					lasery <= lasery - 1;
				end
				else
					lasery <= 0;
					laserx <= 161;
			end
			
			else begin
				if (fire_in == 1'b1)
					laserexist <= fire_in;
				increase <= 1'b0;
			end

			if (draw1 || erase1)begin
				relevantx <= enemx1;
				relevanty <= enemy1;
			end
			else if (draw2 || erase2)begin
				relevantx <= enemx2;
				relevanty <= enemy2;
			end
			else if (draw3 || erase3)begin
				relevantx <= enemx3;
				relevanty <= enemy3;
			end
			
			else if (draw4 || erase4)begin
				relevantx <= playerx - (counter[1:0] / 2);
				relevanty <= playery;
			end
			else if (draw5 || erase5)begin
				relevantx <= laserx - counter[1:0];
				relevanty <= lasery - counter[3:2];
			end
	end
	
	assign x = relevantx + counter[1:0];
	assign y = relevanty + counter[3:2];
endmodule

