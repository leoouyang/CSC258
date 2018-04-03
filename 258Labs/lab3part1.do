# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns lab3part1.v

# Load simulation using mux as the top level simulation module.
vsim lab3part1

log {/*}
add wave {/*}

force {SW[6]} 1 0, 0 10
force {SW[5]} 0 0, 1 10, 0 20
force {SW[4]} 0 0, 1 20, 0 30
force {SW[3]} 0 0, 1 30, 0 40
force {SW[2]} 0 0, 1 40, 0 50
force {SW[1]} 0 0, 1 50, 0 60
force {SW[0]} 0 0, 1 60, 0 70

force {SW[9]} 0 0, 1 40 -r 80
force {SW[8]} 0 0, 1 20 -r 40
force {SW[7]} 0 0, 1 10 -r 20
run 80ns

force {SW[6]} 0 0, 1 10
force {SW[5]} 1 0, 0 10, 1 20
force {SW[4]} 1 0, 0 20, 1 30
force {SW[3]} 1 0, 0 30, 1 40
force {SW[2]} 1 0, 0 40, 1 50
force {SW[1]} 1 0, 0 50, 1 60
force {SW[0]} 1 0, 0 60, 1 70

force {SW[9]} 0 0, 1 40 -r 80
force {SW[8]} 0 0, 1 20 -r 40
force {SW[7]} 0 0, 1 10 -r 20
run 80ns
