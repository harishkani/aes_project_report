## Nexys A7-100T Board Constraints for AES LUT Ultimate FPGA Design
## Artix-7 XC7A100T FPGA
## AES-128 LUT Ultimate Implementation with S-box Sharing and SRL Optimization

################################################################################
## Clock Signal (100 MHz)
################################################################################
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

################################################################################
## Reset Button (active-low) - CPU_RESETN
################################################################################
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports rst_n]

################################################################################
## Push Buttons (active-high on Nexys A7)
################################################################################
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports btnC]     # Center: Start AES
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports btnU]     # Up: Toggle encrypt/decrypt
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports btnL]     # Left: Previous display group
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports btnR]     # Right: Next display group

################################################################################
## Switches (Test Vector Selection)
################################################################################
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]
set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS18 } [get_ports {sw[8]}]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS18 } [get_ports {sw[9]}]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports {sw[10]}]
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports {sw[11]}]
set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports {sw[12]}]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports {sw[13]}]
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports {sw[14]}]
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports {sw[15]}]

################################################################################
## LEDs (Status Indicators)
################################################################################
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {led[7]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports {led[15]}]

################################################################################
## 7-Segment Display (Common Anode on Nexys A7)
################################################################################
# Segment outputs (active-low)
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]  # a
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]  # b
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]  # c
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]  # d
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]  # e
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]  # f
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]  # g

# Anode outputs (active-low, digit selection)
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports {an[4]}]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports {an[5]}]
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports {an[6]}]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports {an[7]}]

################################################################################
## Configuration Options
################################################################################
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

################################################################################
## Bitstream Configuration
################################################################################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

################################################################################
## Timing Constraints
################################################################################
# Allow buttons to be used as control signals (not clocks)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets btnC_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets btnU_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets btnL_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets btnR_IBUF]

# False paths for asynchronous inputs
set_false_path -from [get_ports btnC]
set_false_path -from [get_ports btnU]
set_false_path -from [get_ports btnL]
set_false_path -from [get_ports btnR]
set_false_path -from [get_ports {sw[*]}]

# False paths for outputs
set_false_path -to [get_ports {led[*]}]
set_false_path -to [get_ports {seg[*]}]
set_false_path -to [get_ports {an[*]}]

################################################################################
## LUT Ultimate Specific Optimizations
################################################################################
# The LUT Ultimate design uses shared LUT-based S-boxes and SRL storage
# These constraints help optimize the implementation

# Ensure critical paths in SubBytes are optimized
set_max_delay -from [get_pins -hier -filter {NAME =~ *aes_inst/subbytes_inst/*}] \
              -to [get_pins -hier -filter {NAME =~ *aes_inst/temp_state_reg*}] 8.0

# LUT S-box timing optimization (faster than composite field)
set_max_delay -from [get_pins -hier -filter {NAME =~ *aes_sbox/*}] 5.0
set_max_delay -from [get_pins -hier -filter {NAME =~ *aes_inv_sbox/*}] 5.0

# Multi-cycle paths for state register updates
set_multicycle_path -setup 2 -from [get_pins -hier -filter {NAME =~ *aes_inst/aes_state_reg*}] \
                              -to [get_pins -hier -filter {NAME =~ *aes_inst/aes_state_reg*}]
set_multicycle_path -hold 1  -from [get_pins -hier -filter {NAME =~ *aes_inst/aes_state_reg*}] \
                              -to [get_pins -hier -filter {NAME =~ *aes_inst/aes_state_reg*}]

################################################################################
## SRL Optimization for Round Key Storage
################################################################################
# Enable SRL extraction for shift register-based round key storage
set_property SHREG_EXTRACT YES [get_cells -hier -filter {NAME =~ *rk_shift_reg*}]
set_property SRL_STYLE SRL [get_cells -hier -filter {NAME =~ *rk_shift_reg*}]

################################################################################
## Power Optimization
################################################################################
# Enable clock gating for shared S-boxes (reduces dynamic power)
set_property CLOCK_GATING TRUE [get_cells -hier -filter {REF_NAME == aes_core_ultimate}]

################################################################################
## Placement Constraints (Optional - for better area utilization)
################################################################################
# Group shared S-boxes together for better routing
# set_property LOC SLICE_X10Y50 [get_cells -hier -filter {NAME =~ *subbytes_inst*}]

################################################################################
## Synthesis Strategy
################################################################################
# Optimize for area (LUT Ultimate design focuses on area + sharing)
# These settings should be applied in Vivado synthesis settings:
# -strategy: Area_Explore
# -flatten_hierarchy: rebuilt
# -resource_sharing: auto (important for S-box sharing!)
# -shreg_min_size: 3 (for SRL optimization)
