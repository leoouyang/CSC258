module FSM(resetn, clock, load_x, load_y, ld_x, ld_y, ld_colour, start_draw, plot, counter);
	input resetn;
	input clock;
	input load_x;
	input load_y;
	output reg ld_x, ld_y, ld_colour;
	output reg start_draw;
	output reg plot;
	output reg [3:0] counter = 4'b0001;
	
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