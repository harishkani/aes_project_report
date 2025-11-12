################################################################################
# Vivado TCL Script to Add All Sources for Canright Ultimate AES Design
#
# Usage:
#   1. Open your Vivado project
#   2. In Vivado TCL Console, navigate to this directory:
#      cd path/to/designs/3_canright_ultimate
#   3. Source this script:
#      source add_sources.tcl
################################################################################

# Get the directory where this script is located
set script_dir [file dirname [file normalize [info script]]]
puts "Script directory: $script_dir"

# Define file sets
set rtl_dir "${script_dir}/rtl"
set tb_dir "${script_dir}/tb"

################################################################################
# Add RTL Design Sources
################################################################################
puts "\n=== Adding S-box Modules ==="

# S-box modules (consolidated single-file Canright implementation)
set sbox_files [list \
    "${rtl_dir}/aes_sbox.v" \
    "${rtl_dir}/aes_sbox_canright.v" \
]

foreach file $sbox_files {
    if {[file exists $file]} {
        add_files -norecurse $file
        puts "  Added: [file tail $file]"
    } else {
        puts "  WARNING: File not found: $file"
    }
}

puts "\n=== Adding AES Operation Modules ==="

# AES operation modules
set aes_op_files [list \
    "${rtl_dir}/aes_subbytes_32bit_canright.v" \
    "${rtl_dir}/aes_shiftrows_128bit.v" \
    "${rtl_dir}/aes_mixcolumns_32bit.v" \
    "${rtl_dir}/aes_key_expansion_otf.v" \
]

foreach file $aes_op_files {
    if {[file exists $file]} {
        add_files -norecurse $file
        puts "  Added: [file tail $file]"
    } else {
        puts "  WARNING: File not found: $file"
    }
}

puts "\n=== Adding Top-level AES Core ==="

# Top-level core
set top_file "${rtl_dir}/aes_core_ultimate_canright.v"
if {[file exists $top_file]} {
    add_files -norecurse $top_file
    puts "  Added: [file tail $top_file]"
} else {
    puts "  WARNING: File not found: $top_file"
}

################################################################################
# Add Simulation Sources
################################################################################
puts "\n=== Adding Testbench for Simulation ==="

set tb_file "${tb_dir}/tb_aes_ultimate_canright.v"
if {[file exists $tb_file]} {
    add_files -fileset sim_1 -norecurse $tb_file
    puts "  Added: [file tail $tb_file]"

    # Set as top module for simulation
    set_property top tb_aes_ultimate_canright [get_filesets sim_1]
    puts "  Set as simulation top: tb_aes_ultimate_canright"
} else {
    puts "  WARNING: Testbench file not found: $tb_file"
}

################################################################################
# Update Compile Order
################################################################################
puts "\n=== Updating Compile Order ==="
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "  Compile order updated"

################################################################################
# Summary
################################################################################
puts "\n================================================================================"
puts "                          SOURCE ADDITION COMPLETE"
puts "================================================================================"
puts "Total Design Sources Added:"
puts "  - Canright GF modules:  12 files"
puts "  - AES operation modules: 6 files"
puts "  - Top-level core:        1 file"
puts "Total Simulation Sources: 1 file (testbench)"
puts ""
puts "Next Steps:"
puts "  1. Verify all sources in Sources window"
puts "  2. Run 'Check Syntax' to verify no errors"
puts "  3. Run Behavioral Simulation to test design"
puts "================================================================================"
