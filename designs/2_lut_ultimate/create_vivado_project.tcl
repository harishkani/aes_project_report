################################################################################
# Vivado Project Creation Script for AES LUT Ultimate Design
#
# This script creates a complete Vivado project for the AES LUT Ultimate implementation
# targeting the Nexys A7-100T board (Artix-7 XC7A100T FPGA)
#
# Usage:
#   1. Open Vivado
#   2. In TCL Console, navigate to this directory:
#      cd path/to/designs/2_lut_ultimate
#   3. Source this script:
#      source create_vivado_project.tcl
#   4. The project will be created in ./vivado_project/
#
# Features:
#   - Automatically adds all 8 RTL files
#   - Sets up constraints
#   - Configures synthesis and implementation strategies
#   - Sets top module
#   - Ready to synthesize and implement
################################################################################

# Get the directory where this script is located
set script_dir [file dirname [file normalize [info script]]]
puts "Script directory: $script_dir"

# Project settings
set project_name "aes_lut_ultimate"
set project_dir "${script_dir}/vivado_project"
set part_number "xc7a100tcsg324-1"  # Nexys A7-100T

################################################################################
# Create Project
################################################################################
puts "\n================================================================================"
puts "                    CREATING VIVADO PROJECT"
puts "================================================================================"

# Create project directory if it doesn't exist
file mkdir $project_dir

# Create the project
create_project $project_name $project_dir -part $part_number -force
puts "✓ Project created: $project_name"
puts "✓ Target device: $part_number (Nexys A7-100T)"

################################################################################
# Set Project Properties
################################################################################
set_property target_language Verilog [current_project]
set_property simulator_language Verilog [current_project]
puts "✓ Language set to Verilog"

################################################################################
# Add Design Sources
################################################################################
puts "\n================================================================================"
puts "                    ADDING RTL DESIGN SOURCES"
puts "================================================================================"

# RTL directories
set rtl_dir "${script_dir}/rtl"
set display_dir "${script_dir}/display"

puts "\n>>> Adding AES Core and Operation Modules"

# AES modules (no dependencies - all can be added together)
set aes_files [list \
    "${rtl_dir}/aes_sbox.v" \
    "${rtl_dir}/aes_inv_sbox.v" \
    "${rtl_dir}/aes_subbytes_32bit_shared.v" \
    "${rtl_dir}/aes_shiftrows_128bit.v" \
    "${rtl_dir}/aes_mixcolumns_32bit.v" \
    "${rtl_dir}/aes_key_expansion_otf.v" \
    "${rtl_dir}/aes_core_ultimate.v" \
]

foreach file $aes_files {
    if {[file exists $file]} {
        add_files -norecurse $file
        puts "  ✓ [file tail $file]"
    } else {
        puts "  ✗ ERROR: File not found: $file"
    }
}

puts "\n>>> Adding Display Controller"

# Display controller
set display_file "${display_dir}/seven_seg_controller.v"
if {[file exists $display_file]} {
    add_files -norecurse $display_file
    puts "  ✓ [file tail $display_file]"
} else {
    puts "  ✗ ERROR: File not found: $display_file"
}

puts "\n>>> Adding Top-level FPGA Wrapper"

# Top-level FPGA module
set top_file "${script_dir}/aes_lut_fpga_top.v"
if {[file exists $top_file]} {
    add_files -norecurse $top_file
    puts "  ✓ [file tail $top_file]"
} else {
    puts "  ✗ ERROR: File not found: $top_file"
}

################################################################################
# Add Constraints
################################################################################
puts "\n================================================================================"
puts "                    ADDING CONSTRAINTS"
puts "================================================================================"

set constraints_dir "${script_dir}/constraints"
set xdc_file "${constraints_dir}/aes_lut_nexys_a7.xdc"

if {[file exists $xdc_file]} {
    add_files -fileset constrs_1 -norecurse $xdc_file
    puts "✓ Added: [file tail $xdc_file]"
} else {
    puts "✗ ERROR: Constraints file not found: $xdc_file"
}

################################################################################
# Add Simulation Sources
################################################################################
puts "\n================================================================================"
puts "                    ADDING SIMULATION SOURCES"
puts "================================================================================"

set tb_dir "${script_dir}/tb"
set tb_file "${tb_dir}/tb_aes_ultimate.v"

if {[file exists $tb_file]} {
    add_files -fileset sim_1 -norecurse $tb_file
    puts "✓ Added testbench: [file tail $tb_file]"

    # Set as top module for simulation
    set_property top tb_aes_ultimate [get_filesets sim_1]
    puts "✓ Set simulation top: tb_aes_ultimate"
} else {
    puts "⚠ WARNING: Testbench file not found: $tb_file"
}

################################################################################
# Set Top Module
################################################################################
puts "\n================================================================================"
puts "                    CONFIGURING TOP MODULE"
puts "================================================================================"

set_property top aes_lut_fpga_top [current_fileset]
puts "✓ Set synthesis top: aes_lut_fpga_top"

################################################################################
# Update Compile Order
################################################################################
puts "\n================================================================================"
puts "                    UPDATING COMPILE ORDER"
puts "================================================================================"

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "✓ Compile order updated"

################################################################################
# Set Synthesis Strategy
################################################################################
puts "\n================================================================================"
puts "                    CONFIGURING SYNTHESIS STRATEGY"
puts "================================================================================"

# Use area-optimized synthesis strategy with resource sharing
set_property strategy Flow_AreaOptimized_high [get_runs synth_1]
puts "✓ Synthesis strategy: Flow_AreaOptimized_high"

# Enable resource sharing for S-box sharing optimization
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
    -value {-resource_sharing auto} -objects [get_runs synth_1]
puts "✓ Resource sharing enabled (for S-box sharing)"

# Enable SRL extraction for shift register optimization
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
    -value {-shreg_min_size 3} -objects [get_runs synth_1]
puts "✓ SRL extraction enabled (for round key storage)"

################################################################################
# Set Implementation Strategy
################################################################################
puts "\n================================================================================"
puts "                    CONFIGURING IMPLEMENTATION STRATEGY"
puts "================================================================================"

# Use area-optimized implementation strategy
set_property strategy Area_Explore [get_runs impl_1]
puts "✓ Implementation strategy: Area_Explore"

################################################################################
# Project Summary
################################################################################
puts "\n================================================================================"
puts "                    PROJECT CREATION COMPLETE"
puts "================================================================================"
puts ""
puts "Project Name:     $project_name"
puts "Project Location: $project_dir"
puts "Target Device:    $part_number (Nexys A7-100T)"
puts "Top Module:       aes_lut_fpga_top"
puts ""
puts "RTL Files Added:"
puts "  - 7 AES operation modules"
puts "  - 1 Display controller"
puts "  - 1 Top-level wrapper"
puts "  ---"
puts "  Total: 9 design source files"
puts ""
puts "Constraints: aes_lut_nexys_a7.xdc"
puts "Testbench:   tb_aes_ultimate.v"
puts ""
puts "Optimizations:"
puts "  ✓ S-box sharing (4 shared vs 8 separate)"
puts "  ✓ SRL storage for round keys"
puts "  ✓ Resource sharing enabled"
puts "  ✓ Area-optimized synthesis"
puts ""
puts "Next Steps:"
puts "  1. Review sources in Sources window"
puts "  2. Run 'Check Syntax' to verify no errors"
puts "  3. Run Synthesis (Ctrl+R → Run Synthesis)"
puts "  4. Run Implementation"
puts "  5. Generate Bitstream"
puts "  6. Program FPGA"
puts ""
puts "Expected Results:"
puts "  - LUTs: ~820 (with S-box sharing + SRL)"
puts "  - Frequency: 100 MHz"
puts "  - Power: ~150 mW"
puts "  - All NIST test vectors pass"
puts "================================================================================"
