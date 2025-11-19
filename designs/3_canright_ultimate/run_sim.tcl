# ==============================================================================
# Vivado XSim Simulation Script for AES Canright Ultimate Design
# ==============================================================================

# Create simulation project
puts "Creating simulation project..."

# Set design files directory
set design_dir [file normalize [file dirname [info script]]]
set rtl_dir "${design_dir}/rtl"
set tb_dir "${design_dir}/tb"

# Compile RTL files in dependency order
puts "Compiling RTL files..."

# S-box modules (base dependencies)
xvlog -sv "${rtl_dir}/aes_sbox.v"
xvlog -sv "${rtl_dir}/aes_sbox_canright_verified.v"

# AES transformation modules
xvlog -sv "${rtl_dir}/aes_subbytes_32bit_canright.v"
xvlog -sv "${rtl_dir}/aes_shiftrows_128bit.v"
xvlog -sv "${rtl_dir}/aes_mixcolumns_32bit.v"

# Key expansion
xvlog -sv "${rtl_dir}/aes_key_expansion_otf.v"

# Top-level core
xvlog -sv "${rtl_dir}/aes_core_ultimate_canright.v"

# Testbench
xvlog -sv "${tb_dir}/tb_aes_ultimate_canright.v"

# Elaborate design
puts "Elaborating design..."
xelab -debug typical tb_aes_ultimate_canright -s tb_aes_ultimate_canright_sim

# Run simulation
puts "Running simulation..."
xsim tb_aes_ultimate_canright_sim -runall

puts "Simulation complete!"
