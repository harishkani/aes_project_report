###################################################################################
# AES Shift Register Optimization Constraints
# Ensures Vivado extracts shift registers into SRL primitives for area efficiency
###################################################################################

# Enable shift register extraction globally
set_property SHREG_EXTRACT YES [get_cells -hierarchical -filter {NAME =~ *rk_shift_reg*}]
set_property SRL_STYLE SRL [get_cells -hierarchical -filter {NAME =~ *rk_shift_reg*}]

# Pipeline shift registers
set_property SHREG_EXTRACT YES [get_cells -hierarchical -filter {NAME =~ *state_col_pipe*}]
set_property SRL_STYLE SRL [get_cells -hierarchical -filter {NAME =~ *state_col_pipe*}]

set_property SHREG_EXTRACT YES [get_cells -hierarchical -filter {NAME =~ *temp_col_pipe*}]
set_property SRL_STYLE SRL [get_cells -hierarchical -filter {NAME =~ *temp_col_pipe*}]

# ShiftRows pipeline
set_property SHREG_EXTRACT YES [get_cells -hierarchical -filter {NAME =~ *shiftrows_pipe*}]
set_property SRL_STYLE SRL [get_cells -hierarchical -filter {NAME =~ *shiftrows_pipe*}]

# MixColumns pipeline stages
set_property SHREG_EXTRACT YES [get_cells -hierarchical -filter {NAME =~ *mixcol_pipe*}]
set_property SRL_STYLE SRL [get_cells -hierarchical -filter {NAME =~ *mixcol_pipe*}]

# Prevent optimization from removing shift register structures
set_property KEEP_HIERARCHY SOFT [get_cells -hierarchical -filter {NAME =~ *core_optimized_srl*}]

###################################################################################
# Timing constraints remain same as original design
###################################################################################
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# Input/output delays
set_input_delay -clock clk 2.000 [get_ports {start enc_dec data_in[*] key_in[*] rst_n}]
set_output_delay -clock clk 2.000 [get_ports {data_out[*] ready}]

# False paths for reset
set_false_path -from [get_ports rst_n]

###################################################################################
# Optimization directives
###################################################################################
# Encourage SRL inference
set_property SHREG_MIN_SIZE 3 [current_design]

# Allow Vivado to use distributed RAM for small memories
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ *sbox*}]

# Report shift register extraction
set_property REPORT_METHODOLOGY 1 [current_design]
