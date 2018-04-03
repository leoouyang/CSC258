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

