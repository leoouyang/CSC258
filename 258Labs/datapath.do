# Set the working dir, where all compiled Verilog goes.
vlib lab7

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns datapath.v

# Load simulation using mux as the top level simulation module.
vsim datapath

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


#load x values
force {clock} 0 0 ns, 1 2 ns -repeat 4
force {ld_x} 0 0ns, 1 5ns
force {ld_y} 0
force {ld_colour} 0
force {start_draw} 0

force {resetn} 0 0, 1 5
force {data_in[9:0]} 'b0000001111
force {counter[3:0]} 'b0000
run 12ns

#load y and colour values
force {clock} 0 0 ns, 1 2 ns -repeat 4
force {ld_x} 0
force {ld_y} 1
force {ld_colour} 1
force {start_draw} 0

force {resetn} 1
force {data_in[9:0]} 'b1010101001
force {counter[3:0]} 'b0000
run 12ns

#start and keep drawing the first two line of the square
force {clock} 0 0 ns, 1 2 ns -repeat 4
force {ld_x} 0
force {ld_y} 0
force {ld_colour} 0
force {start_draw} 1

force {resetn} 1
force {data_in[9:0]} 'b1010101001
force {counter[3:0]} 'b0000 0, 'b0001 2, 'b0010 6, 'b0011 10, 'b0100 14, 'b0101 18, 'b0110 22, 'b0111 26
run 32ns