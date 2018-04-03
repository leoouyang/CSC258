# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns FSMwithdatapath.v

# Load simulation using mux as the top level simulation module.
vsim FSMwithdatapath

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# load the first set of values and draw the first square
force {CLOCK_50} 0 0 ns, 1 2 ns -repeat 4
force {KEY[1]} 1 0ns, 0 30ns, 1 40ns
force {KEY[3]} 1 0ns, 0 10ns, 1 20ns
force {KEY[0]} 0 0ns, 1 5ns

force {SW[9]} 1 0, 0 25
force {SW[8]} 1 0, 0 25
force {SW[7]} 1 0, 1 25
force {SW[6]} 0 0, 0 25
force {SW[5]} 1 0, 0 25
force {SW[4]} 0 0, 1 25
force {SW[3]} 0 0, 1 25
force {SW[2]} 1 0, 1 25
force {SW[1]} 1 0, 0 25
force {SW[0]} 1 0, 1 25
run 200ns


#load the second set of values and draw the second square
force {CLOCK_50} 0 0 ns, 1 2 ns -repeat 4
force {KEY[1]} 1 0ns, 0 30ns, 1 40ns
force {KEY[3]} 1 0ns, 0 10ns, 1 20ns
force {KEY[0]} 1

force {SW[9]} 1 0, 1 25
force {SW[8]} 1 0, 0 25
force {SW[7]} 1 0, 1 25
force {SW[6]} 1 0, 0 25
force {SW[5]} 0 0, 1 25
force {SW[4]} 0 0, 1 25
force {SW[3]} 1 0, 1 25
force {SW[2]} 1 0, 0 25
force {SW[1]} 0 0, 1 25
force {SW[0]} 1 0, 0 25
run 200ns