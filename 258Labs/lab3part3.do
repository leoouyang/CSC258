# Set the working dir, where all compiled Verilog goes.
vlib lab3work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns lab3part3.v

# Load simulation using mux as the top level simulation module.
vsim lab3part3

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

#Test ALUOut is SW[7:0]
force {KEY[2]} 1
force {KEY[1]} 1
force {KEY[0]} 1

force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 1
force {SW[4]} 0
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 1
run 10ns

#Test 1011 + 1011 = 00010110
force {KEY[2]} 1
force {KEY[1]} 1
force {KEY[0]} 0

force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 1
force {SW[4]} 1
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns

# Test same as above but with verilog adder
force {KEY[2]} 1
force {KEY[1]} 0
force {KEY[0]} 1

force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 1
force {SW[4]} 1
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns

#Test the 4bit OR, 4bit XOR with 1111 and 1010 => 11110101
force {KEY[2]} 1
force {KEY[1]} 0
force {KEY[0]} 0

force {SW[7]} 1
force {SW[6]} 1
force {SW[5]} 1
force {SW[4]} 1
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0
run 10ns

#Testing above again, but with 0001 and 0010 => 00110011
force {KEY[2]} 1
force {KEY[1]} 0
force {KEY[0]} 0

force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0
force {SW[4]} 1
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0
run 10ns

#Test the single OR operator with all off
force {KEY[2]} 0
force {KEY[1]} 1
force {KEY[0]} 1

force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0
force {SW[4]} 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
run 10ns

#Test with a couple of 1s
force {KEY[2]} 0
force {KEY[1]} 1
force {KEY[0]} 1

force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 1
force {SW[4]} 0
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 0
run 10ns

# Test parity with even 1s
force {KEY[2]} 0
force {KEY[1]} 1
force {KEY[0]} 0

force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 1
force {SW[4]} 0
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0
run 10ns

# Test parity with odd amount of 1s
force {KEY[2]} 0
force {KEY[1]} 1
force {KEY[0]} 0

force {SW[7]} 1
force {SW[6]} 1
force {SW[5]} 1
force {SW[4]} 1
force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 0
run 10ns