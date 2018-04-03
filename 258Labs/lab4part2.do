# Start at B = 4'b000
# A is at 4'b1010
force {KEY[0]} 1
force {SW[9]} 1

force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0

force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

run 10 ns

# Add 4'b0000 + 4'b1010 which returns 8'b00001010
# B will be 1010 on next posedge
force {KEY[0]} 0
force {SW[9]} 0

force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 1

force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

run 10 ns

#Should return 8'b00010100
#Set B to be 4'b1010
force {KEY[0]} 1
force {SW[9]} 0

force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0

force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

run 10 ns

# Use another adder, with b at 4'b1010
#Should return 8'b00010100
force {KEY[0]} 0
force {SW[9]} 0

force {SW[7]} 0
force {SW[6]} 1
force {SW[5]} 0

force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

run 10 ns

# ALUOut should be 8'b11011001
# B should be 0100
force {KEY[0]} 0
force {SW[9]} 1

force {SW[7]} 0
force {SW[6]} 1
force {SW[5]} 1

force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 1

run 10 ns

# Should return 8'b00000001
# B should be 0100
force {KEY[0]} 0
force {SW[9]} 0

force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 0

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0

run 10 ns

# Re-test function with reset, should be 8'b00000000
force {KEY[0]} 1
force {SW[9]} 1

force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 0

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0

run 10 ns

# Basically just setting B = 4'b1010
force {KEY[0]} 0
force {SW[9]} 0

force {SW[7]} 0
force {SW[6]} 1
force {SW[5]} 0

force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

run 10 ns

#Shift left by 2, returning 8'b00101000
#B = 4'b1010
force {KEY[0]} 0
force {SW[9]} 1

force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 1

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

run 10 ns

#Shift right by 2, returning 8'b00000010
force {KEY[0]} 0
force {SW[9]} 0

force {SW[7]} 1
force {SW[6]} 1
force {SW[5]} 0

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

run 10 ns

# 4'b0011 * 4'b1010
force {KEY[0]} 0
force {SW[9]} 0

force {SW[7]} 1
force {SW[6]} 1
force {SW[5]} 1

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1

run 10 ns