# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns lab2.v

# Load simulation using mux as the top level simulation module.
vsim lab2

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# Make sure when all 0, output is 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
force {SW[9]} 0
force {SW[8]} 0
run 10ns

# Make sure when selected, u (SW[3]) is output
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
force {SW[9]} 0
force {SW[8]} 0
run 10ns

force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 0
force {SW[9]} 0
force {SW[8]} 1
run 10ns

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0
force {SW[9]} 1
force {SW[8]} 0
run 10ns


force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1
force {SW[9]} 1
force {SW[8]} 1
run 10ns

#Ensure on signal is not sent when selected is off
force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 1
force {SW[9]} 1
force {SW[8]} 0
run 10ns

#Ensure on signal is not sent when selected is off
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 1
force {SW[9]} 0
force {SW[8]} 0
run 10ns
