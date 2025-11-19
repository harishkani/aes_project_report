################################################################################
# Vivado Project Diagnostic Script for Canright AES
#
# Run this in your Vivado TCL console to check if all files are correctly added
#
# Usage: source check_vivado_project.tcl
################################################################################

puts "\n========================================="
puts "CANRIGHT AES - VIVADO PROJECT DIAGNOSTIC"
puts "=========================================\n"

# Required files list
set required_files {
    "aes_sbox.v"
    "aes_sbox_canright_verified.v"
    "aes_subbytes_32bit_canright.v"
    "aes_shiftrows_128bit.v"
    "aes_mixcolumns_32bit.v"
    "aes_key_expansion_otf.v"
    "aes_core_ultimate_canright.v"
}

puts "Step 1: Checking Design Sources..."
puts "-----------------------------------"

# Get all source files
if {[catch {set all_files [get_files -of_objects [get_filesets sources_1]]}]} {
    puts "ERROR: No design sources found! Please add source files."
    puts "=========================================\n"
    return
}

set found_files {}
foreach file $all_files {
    set filename [file tail $file]
    lappend found_files $filename
}

puts "Files currently in project:"
foreach f $found_files {
    puts "  ✓ $f"
}
puts ""

# Check for required files
puts "Step 2: Checking Required Files..."
puts "-----------------------------------"

set missing_files {}
set found_count 0

foreach req_file $required_files {
    if {[lsearch $found_files $req_file] >= 0} {
        puts "  ✓ $req_file - FOUND"
        incr found_count
    } else {
        puts "  ✗ $req_file - MISSING!"
        lappend missing_files $req_file
    }
}

puts ""
puts "Summary: $found_count / [llength $required_files] required files found"
puts ""

if {[llength $missing_files] > 0} {
    puts "⚠️  MISSING FILES DETECTED!"
    puts "You need to add these files:"
    foreach f $missing_files {
        puts "  - rtl/$f"
    }
    puts ""
}

# Check top module
puts "Step 3: Checking Top Module..."
puts "-----------------------------------"

if {[catch {set top_module [get_property top [current_fileset]]}]} {
    puts "ERROR: No top module set!"
} else {
    if {$top_module == "aes_core_ultimate_canright"} {
        puts "  ✓ Top module: $top_module - CORRECT"
    } else {
        puts "  ✗ Top module: $top_module - WRONG!"
        puts "    Expected: aes_core_ultimate_canright"
    }
}
puts ""

# Check for elaboration errors
puts "Step 4: Checking for Elaboration Issues..."
puts "-----------------------------------"

if {[llength $missing_files] == 0} {
    puts "Attempting to check compile order..."
    if {[catch {report_compile_order -missing_instance} err]} {
        puts "  ⚠️  Compile order check failed"
        puts "  Try: Flow → Run Synthesis to see detailed errors"
    } else {
        puts "  ✓ No missing instances detected"
    }
} else {
    puts "  ⚠️  Skipped (missing files must be added first)"
}
puts ""

# Check module hierarchy
puts "Step 5: Checking Module Hierarchy..."
puts "-----------------------------------"

if {[llength $missing_files] == 0} {
    puts "Expected hierarchy:"
    puts "  aes_core_ultimate_canright (top)"
    puts "    ├── aes_key_expansion_otf"
    puts "    │   └── aes_sbox [x4] instances"
    puts "    ├── aes_subbytes_32bit_canright"
    puts "    │   └── aes_sbox_canright_verified [x4] instances"
    puts "    ├── aes_shiftrows_128bit"
    puts "    └── aes_mixcolumns_32bit"
    puts ""
    puts "To view actual hierarchy:"
    puts "  → Check the 'Hierarchy' tab in Sources window"
    puts "  → Look for red 'X' marks (missing modules)"
    puts "  → Look for '?' symbols (unresolved references)"
} else {
    puts "  ⚠️  Skipped (fix missing files first)"
}
puts ""

# Critical file check - aes_sbox.v
puts "Step 6: Critical File Check..."
puts "-----------------------------------"

set has_aes_sbox 0
set has_canright_sbox 0

if {[lsearch $found_files "aes_sbox.v"] >= 0} {
    set has_aes_sbox 1
}
if {[lsearch $found_files "aes_sbox_canright_verified.v"] >= 0} {
    set has_canright_sbox 1
}

if {$has_aes_sbox && $has_canright_sbox} {
    puts "  ✓ BOTH S-box files present (hybrid design - correct!)"
    puts ""
    puts "  Explanation:"
    puts "    - aes_sbox.v: Used by key expansion (LUT-based)"
    puts "    - aes_sbox_canright_verified.v: Used by data path (Canright)"
} elseif {$has_aes_sbox && !$has_canright_sbox} {
    puts "  ✗ Missing Canright S-box!"
    puts "    Add: rtl/aes_sbox_canright_verified.v"
} elseif {!$has_aes_sbox && $has_canright_sbox} {
    puts "  ✗ Missing standard S-box!"
    puts "    Add: rtl/aes_sbox.v (required for key expansion)"
} else {
    puts "  ✗ BOTH S-box files missing!"
    puts "    Add: rtl/aes_sbox.v"
    puts "    Add: rtl/aes_sbox_canright_verified.v"
}
puts ""

# Final verdict
puts "========================================="
puts "DIAGNOSTIC SUMMARY"
puts "========================================="

set issues 0

if {[llength $missing_files] > 0} {
    puts "❌ Missing Files: [llength $missing_files]"
    incr issues
} else {
    puts "✓ All Required Files: Present"
}

if {[catch {set top_module [get_property top [current_fileset]]}] || $top_module != "aes_core_ultimate_canright"} {
    puts "❌ Top Module: Incorrect or not set"
    incr issues
} else {
    puts "✓ Top Module: Correct"
}

if {!$has_aes_sbox || !$has_canright_sbox} {
    puts "❌ S-box Files: Missing one or both"
    incr issues
} else {
    puts "✓ S-box Files: Both present"
}

puts ""

if {$issues == 0} {
    puts "✅ PROJECT LOOKS GOOD!"
    puts "You can proceed with synthesis."
    puts ""
    puts "Next steps:"
    puts "  1. Flow → Run Synthesis"
    puts "  2. Check reports in ./reports_canright/"
} else {
    puts "⚠️  PROJECT HAS ISSUES ($issues problems found)"
    puts ""
    puts "How to fix:"
    puts "  1. See missing files listed above"
    puts "  2. Add files: Right-click Design Sources → Add Sources"
    puts "  3. Or use: source synthesize_canright.tcl (auto-setup)"
    puts ""
    puts "Detailed instructions: VIVADO_PROJECT_FIX.md"
}

puts "=========================================\n"
