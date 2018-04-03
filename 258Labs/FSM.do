# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns FSM.v

# Load simulation using mux as the top level simulation module.
vsim FSM

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# load the first set of values and draw the first square
force {clock} 0 0 ns, 1 2 ns -repeat 4
force {load_y} 0 0ns, 1 30ns, 0 40ns
force {load_x} 0 0ns, 1 10ns, 0 20ns
force {resetn} 0 0ns, 1 5ns
run 200ns


#load the second set of values and draw the second square
force {clock} 0 0 ns, 1 2 ns -repeat 4
force {load_y} 0 0ns, 1 30ns, 0 40ns
force {load_x} 0 0ns, 1 10ns, 0 20ns
force {resetn} 1
run 200ns