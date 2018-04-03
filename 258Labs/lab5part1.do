# Set the working dir, where all compiled Verilog goes.
vlib csc258

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns lab5part1.v

# Load simulation using mux as the top level simulation module.
vsim lab5part1

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

#reset counter
force {SW[0]} 0
force {SW[1]} 0
force {KEY[0]} 1
run 10ns

#start counting
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0 0 ns, 1 5 ns -repeat 10
run 100ns

#stop counting
force {SW[0]} 1
force {SW[1]} 0
force {KEY[0]} 0
run 20ns

#restart counting
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0 0 ns, 1 5 ns -repeat 10
run 100ns

#test asynchronous reset
force {SW[0]} 0
force {SW[1]} 0
force {KEY[0]} 0
run 20ns
