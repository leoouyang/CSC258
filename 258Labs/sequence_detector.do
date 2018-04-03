# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns sequence_detector.v

# Load simulation using mux as the top level simulation module.
vsim sequence_detector

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# reset the FSM
force {KEY[0]} 0 0ns, 1 10ns
force {SW[0]} 0
force {SW[1]} 0
run 40ns

# test the case in figure 1 of part 1
force {KEY[0]} 0 0ns, 1 10ns -repeat 20ns
force {SW[0]} 1
force {SW[1]} 0 0ns, 1 38ns, 0 125ns, 1 145ns, 0 170ns 
run 200ns

# test the sequence 01011010
force {KEY[0]} 0 0ns, 1 10ns -repeat 20ns
force {SW[0]} 1
force {SW[1]} 0 0ns, 1 10ns, 0 30ns, 1 50ns, 1 70ns,  0 90ns, 1 110ns, 0 130ns
run 160ns

# test the sequence 01011111
force {KEY[0]} 0 0ns, 1 10ns -repeat 20ns
force {SW[0]} 1
force {SW[1]} 0 0ns, 1 10ns, 0 30ns, 1 50ns, 1 70ns,  1 90ns, 1 110ns, 1 130ns
run 160ns

# test reset
force {KEY[0]} 0 0ns, 1 10ns -repeat 20ns
force {SW[0]} 0
force {SW[1]} 1
run 40ns