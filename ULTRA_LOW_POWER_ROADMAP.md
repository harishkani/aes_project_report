# Ultra-Low Power AES Implementation Roadmap

**Target**: Push AES design into **microwatt (μW) range** for energy harvesting IoT

**Current Status**: ~120-140 mW (estimated)
**Target Status**: **<1 mW** (1000× reduction goal)

---

## 1. State-of-the-Art Benchmarks

### Current Best Published Results:

| Design | Power | Energy/bit | Voltage | Year | Notes |
|--------|-------|------------|---------|------|-------|
| **Sub-threshold AES** | - | **0.83 pJ/bit** | 0.32V | 2023 | 7× better than SOTA |
| Standard AES ASIC | ~100 mW | ~5-10 pJ/bit | 1.0V | 2020 | Typical implementation |
| Your current design | ~120-140 mW | ~8-12 pJ/bit | 1.0V | 2025 | FPGA, estimated |
| **Target** | **<1 mW** | **<1 pJ/bit** | 0.3-0.5V | 2026 | Ultra-low power goal |

### Energy Harvesting Context:

**Available Power from Energy Harvesting**:
- **Indoor solar**: 10-100 μW/cm²
- **RF harvesting**: 1-100 μW
- **Vibration**: 10-1000 μW
- **Thermal**: 10-100 μW

**Typical IoT Device Budget**: **100-500 μW total**

**Implication**: Cryptography must consume **<10-50 μW** on average!

---

## 2. Power Consumption Breakdown (Current Design)

### Estimated Power Distribution:

```
Total: ~120-140 mW @ 100 MHz, 1.0V

┌─────────────────────────────────────┐
│ S-boxes (LUT/Canright): 40-50 mW   │ 35%
├─────────────────────────────────────┤
│ Key Expansion: 20-25 mW             │ 18%
├─────────────────────────────────────┤
│ MixColumns: 15-20 mW                │ 14%
├─────────────────────────────────────┤
│ State Registers: 15-20 mW           │ 14%
├─────────────────────────────────────┤
│ Clock Network: 15-18 mW             │ 13%
├─────────────────────────────────────┤
│ Control FSM: 8-10 mW                │  7%
└─────────────────────────────────────┘
```

### Power Types:

1. **Dynamic Power** (60-70%): P = α × C × V² × f
   - Switching activity
   - Clock frequency dependent
   - Voltage squared dependent

2. **Static Power** (30-40%): P = V × I_leakage
   - Leakage currents
   - Temperature dependent
   - Always present

---

## 3. Ultra-Low Power Optimization Techniques

### Phase 1: Aggressive Clock Management (Target: 30-40% reduction)

#### A. Multi-Level Clock Gating

**Current**: Basic clock gating on 3 modules
**Proposed**: Fine-grained clock gating on every register bank

```verilog
// Ultra-fine-grained clock gating
module ultra_low_power_aes_core(
    input wire clk,
    input wire rst_n,
    // ... other ports
);

// Generate enable signals for each major block
wire sbox_en;
wire key_exp_en;
wire mixcol_en;
wire state_reg_en;

// Fine-grained clock gates
wire sbox_clk;
wire key_clk;
wire mixcol_clk;
wire state_clk;

// FPGA clock gating cells
(* CLOCK_GATE_TYPE = "LATCH" *)
always @(*) begin
    if (!sbox_en) sbox_clk = 1'b0;
    else sbox_clk = clk;
end

// Apply to every register bank
always @(posedge state_clk or negedge rst_n) begin
    if (!rst_n) state_reg <= 0;
    else if (state_reg_en) state_reg <= next_state;
    // No else - holds value when disabled
end

endmodule
```

**Expected Savings**: 15-20 mW (clock network power)

#### B. Dynamic Frequency Scaling

**Concept**: Run slower when throughput not needed

```verilog
// Frequency modes
localparam FREQ_ULTRA_LOW = 2'd0;  // 1 MHz   (µW range)
localparam FREQ_LOW       = 2'd1;  // 10 MHz  (100s µW)
localparam FREQ_NORMAL    = 2'd2;  // 50 MHz  (mW range)
localparam FREQ_HIGH      = 2'd3;  // 100 MHz (full power)

reg [1:0] freq_mode;
reg [7:0] clk_divider;

// Dynamic clock divider
always @(posedge clk) begin
    case (freq_mode)
        FREQ_ULTRA_LOW: clk_divider <= 8'd100; // /100
        FREQ_LOW:       clk_divider <= 8'd10;  // /10
        FREQ_NORMAL:    clk_divider <= 8'd2;   // /2
        FREQ_HIGH:      clk_divider <= 8'd1;   // /1
    endcase
end
```

**Expected Savings**: 40-50 mW (at low frequencies)

---

### Phase 2: Serial Architecture (Target: 50-60% area/power reduction)

#### A. 8-bit Datapath Design

**Current**: 32-bit datapath (4 S-boxes)
**Proposed**: 8-bit datapath (1 S-box)

**Tradeoff**:
- **Area**: 50-75% reduction
- **Power**: 40-60% reduction
- **Latency**: 4× increase
- **Throughput**: 1/4 (acceptable for low-rate IoT)

```verilog
// Serial 8-bit AES core
module aes_serial_8bit(
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,   // Serial input
    input wire [7:0] key_in,    // Serial key
    output reg [7:0] data_out,  // Serial output
    output reg valid
);

// Single shared S-box (reused 16 times per round)
wire [7:0] sbox_out;
aes_sbox_ultra_compact sbox(.in(byte_to_process), .out(sbox_out));

// State stored in distributed RAM (not registers)
reg [7:0] state_mem [0:15];
reg [3:0] byte_counter;
reg [3:0] round_counter;

// Process one byte per clock
always @(posedge clk) begin
    state_mem[byte_counter] <= sbox_out ^ round_key_byte;
    byte_counter <= byte_counter + 1;
end

endmodule
```

**Expected Results**:
- **LUTs**: 150-200 (vs 500-700 currently)
- **Power**: 20-40 mW @ 10 MHz
- **Throughput**: 0.5 Mbps (sufficient for sensor data)

---

### Phase 3: Sub-Threshold Operation (Target: 10× power reduction)

#### A. Voltage Scaling

**Normal Operation**: 1.0V @ 100 MHz = 120-140 mW
**Sub-threshold**: 0.3-0.4V @ 1-10 MHz = **10-30 μW**

**Implementation Challenges**:
- ❌ FPGA doesn't support sub-threshold directly
- ✅ ASIC implementation required
- ⚠️ Increased sensitivity to process variation
- ⚠️ Higher error rates (need ECC)

**Practical Approach for FPGA**:
- Reduce core voltage to minimum: 0.85-0.95V (Artix-7)
- Expected: 30-40% power reduction
- Power: **70-90 mW** @ 0.9V

#### B. Error Correction for Low Voltage

```verilog
// Add parity checking for low-voltage operation
module aes_with_ecc(
    input wire [127:0] data_in,
    input wire [127:0] key_in,
    output reg [127:0] data_out,
    output reg error_detected
);

// Calculate parity
wire [7:0] parity_in = ^data_in;  // XOR of all bits

// AES core
aes_core_low_voltage core(
    .data_in(data_in),
    .key_in(key_in),
    .data_out(data_out_raw)
);

// Verify parity
wire [7:0] parity_out = ^data_out_raw;
assign error_detected = (parity_out != expected_parity);

// Retry on error
always @(posedge clk) begin
    if (error_detected)
        // Retry encryption
    else
        data_out <= data_out_raw;
end

endmodule
```

---

### Phase 4: Power Gating & Sleep Modes (Target: 90-99% idle power reduction)

#### A. Deep Sleep Mode

**Idle State**: Turn off everything except wake-up logic

```verilog
// Power states
localparam PWR_DEEP_SLEEP = 3'd0;  // <1 µW
localparam PWR_LIGHT_SLEEP = 3'd1; // ~10 µW
localparam PWR_STANDBY = 3'd2;     // ~100 µW
localparam PWR_ACTIVE = 3'd3;      // Full power

reg [2:0] power_state;

// Power gating control
always @(*) begin
    case (power_state)
        PWR_DEEP_SLEEP: begin
            aes_core_enable = 1'b0;
            clock_enable = 1'b0;
            retain_state = 1'b1;  // Keep critical registers
        end

        PWR_LIGHT_SLEEP: begin
            aes_core_enable = 1'b0;
            clock_enable = 1'b1;   // Clock running
            retain_state = 1'b1;
        end

        PWR_ACTIVE: begin
            aes_core_enable = 1'b1;
            clock_enable = 1'b1;
            retain_state = 1'b1;
        end
    endcase
end

// Wake-up on interrupt (ultra-low power comparator)
always @(posedge wake_interrupt) begin
    power_state <= PWR_ACTIVE;
end
```

**Expected Idle Power**: **<10 μW** (vs 120 mW active)

---

### Phase 5: Algorithmic Optimizations

#### A. On-Demand Key Expansion

**Current**: Generate all round keys upfront
**Proposed**: Generate only when needed, then discard

**Savings**: 20-25% key expansion power

#### B. Partial Encryption (For Sensors)

**Concept**: Encrypt only critical data fields

```verilog
// Lightweight mode: encrypt only 64 bits
module aes_lightweight_mode(
    input wire [127:0] data_in,
    input wire [127:0] key_in,
    input wire lightweight_mode,
    output reg [127:0] data_out
);

always @(*) begin
    if (lightweight_mode) begin
        // Encrypt only upper 64 bits
        data_out[127:64] = aes_encrypt(data_in[127:64], key_in);
        data_out[63:0] = data_in[63:0];  // Pass through
    end else begin
        // Full 128-bit encryption
        data_out = aes_encrypt(data_in, key_in);
    end
end
```

**Power Savings**: ~50% for lightweight mode

---

## 4. Implementation Roadmap

### **Level 1**: FPGA Optimizations (Immediate)

**Techniques**:
✅ Fine-grained clock gating
✅ Dynamic frequency scaling
✅ Sleep modes
✅ 8-bit serial datapath option

**Expected Power**:
- Active: **20-40 mW** @ 10 MHz
- Standby: **1-5 mW**
- Deep Sleep: **10-100 μW**

**Average** (1% duty cycle): **~150-500 μW** ✓ Energy harvesting compatible!

**Timeline**: 2-4 weeks
**Feasibility**: **HIGH** (no new tools needed)

---

### **Level 2**: ASIC Implementation (Advanced)

**Techniques**:
✅ Sub-threshold operation (0.3-0.4V)
✅ Dual-VT transistors
✅ Multi-VDD domains
✅ Advanced power gating

**Expected Power**:
- Active: **50-200 μW** @ 1 MHz
- Standby: **1-10 μW**
- Deep Sleep: **10-100 nW**

**Average** (1% duty cycle): **1-20 μW** ✓✓ Ultra-low power IoT!

**Timeline**: 6-12 months
**Feasibility**: **MEDIUM** (requires ASIC tools & fabrication)

---

### **Level 3**: Hybrid Approach (Balanced)

**Proposal**:
1. **FPGA prototype** with Level 1 optimizations
2. **Measure and validate** power savings
3. **Migrate to ASIC** if power targets not met

**Advantages**:
✅ Rapid prototyping
✅ Proven design before ASIC
✅ Lower risk

---

## 5. Estimated Power Consumption

### Current Design (Baseline):
```
Operating Mode: Continuous @ 100 MHz
Power: 120-140 mW
Energy per encryption: 12 nJ (100 cycles)
```

### Level 1 Optimized (FPGA):
```
Operating Mode: Burst @ 10 MHz, 1% duty cycle
Active Power: 30 mW @ 10 MHz
Sleep Power: 50 μW
Average Power: 350 μW ← Energy harvesting compatible!
Energy per encryption: 30 nJ (1000 cycles @ 10 MHz)
```

### Level 2 Optimized (ASIC):
```
Operating Mode: Ultra-low @ 1 MHz, 0.3V, 1% duty cycle
Active Power: 100 μW @ 1 MHz, 0.3V
Sleep Power: 100 nW
Average Power: 2 μW ← Battery-free operation!
Energy per encryption: 1 nJ (10,000 cycles @ 1 MHz)
```

---

## 6. Practical Implementation Steps

### Step 1: Add Fine-Grained Clock Gating (Week 1)

**Modify**: `aes_core_ultimate.v`

```verilog
// Add clock enable signals to every process
always @(posedge clk) begin
    if (module_enable) begin  // ← Add this
        // existing logic
    end
end
```

**Expected**: 15-20% power reduction

---

### Step 2: Implement 8-bit Serial Mode (Week 2-3)

**Create**: `aes_core_serial_8bit.v`

**Features**:
- 1 S-box instead of 4
- Serial processing
- Distributed RAM for state

**Expected**: 60% area reduction, 50% power reduction

---

### Step 3: Add Sleep Modes (Week 3-4)

**Modify**: Top-level wrapper

```verilog
module aes_with_power_management(
    input wire clk,
    input wire sleep_request,
    input wire wake_interrupt,
    // ... other ports
);

// Power state machine
always @(posedge clk) begin
    case (power_state)
        SLEEP: if (wake_interrupt) power_state <= ACTIVE;
        ACTIVE: if (sleep_request) power_state <= SLEEP;
    endcase
end

// Gate everything in sleep
assign aes_clk = (power_state == ACTIVE) ? clk : 1'b0;
```

**Expected**: <100 μW idle power

---

### Step 4: Dynamic Frequency Scaling (Week 4)

**Add**: Frequency controller

```verilog
// Select frequency based on workload
always @(posedge clk) begin
    if (high_priority) freq_mode <= FREQ_HIGH;
    else if (normal_priority) freq_mode <= FREQ_NORMAL;
    else freq_mode <= FREQ_ULTRA_LOW;
end
```

**Expected**: 40-50% average power reduction

---

## 7. Validation & Measurement

### Power Measurement Methods:

#### A. FPGA Power Estimation (Vivado)
```tcl
# After synthesis
report_power -file power_report.txt

# Toggle rate analysis
set_switching_activity -default_toggle_rate 0.1

# Re-run power analysis
report_power -toggle_rate 0.1
```

#### B. Actual Measurement (Hardware)
```
Equipment needed:
- INA219 current sensor
- Oscilloscope
- Artix-7 evaluation board

Measure:
1. Core voltage rail (VCCINT)
2. I/O voltage rail (VCCO)
3. Auxiliary rail (VCCAUX)

Total Power = V_INT × I_INT + V_CCO × I_CCO + V_AUX × I_AUX
```

#### C. Energy per Encryption
```
Energy = Power × Time
E = P × (Cycles / Frequency)
E = 30 mW × (1000 cycles / 10 MHz)
E = 30 mW × 100 μs = 3 μJ
```

---

## 8. Research Contribution Potential

### Novel Aspects:

1. **Ultra-low power AES on FPGA** (current gap)
   - Most research focuses on ASIC
   - FPGA prototyping enables faster iteration

2. **Hybrid serial/parallel architecture**
   - Dynamically switch based on power budget
   - Novel adaptive approach

3. **Energy harvesting compatibility**
   - <500 μW average
   - Enables battery-free AES encryption

4. **Comparison study**:
   - LUT vs Composite vs Serial architectures
   - Power-throughput-area tradeoffs

### Publication Targets:

📄 **"Ultra-Low Power AES for Energy Harvesting IoT: A Serial Architecture Approach"**
- Target: IEEE Transactions on VLSI Systems
- Contribution: <500 μW average power on FPGA

📄 **"Adaptive Power Management for AES in Resource-Constrained IoT Devices"**
- Target: ACM Transactions on Embedded Computing
- Contribution: Dynamic switching between modes

---

## 9. Comparison with State-of-the-Art

| Metric | This Work (Target) | Current SOTA | Improvement |
|--------|-------------------|--------------|-------------|
| **Active Power** | 20-40 mW @ 10 MHz | 100-150 mW | **2.5-7.5×** |
| **Sleep Power** | 50-100 μW | 1-5 mW | **10-100×** |
| **Average Power** | 200-500 μW | 10-20 mW | **20-100×** |
| **Energy/Encryption** | 3-5 μJ | 10-20 μJ | **2-7×** |
| **Platform** | FPGA (Artix-7) | FPGA | Same |
| **Energy Harvesting** | ✅ Yes | ❌ No | **Novel** |

---

## 10. Next Steps

### Immediate Actions:

1. ✅ **Survey complete** - understand ultra-low power landscape
2. ⏭️ **Implement Level 1** - FPGA optimizations
3. ⏭️ **Measure power** - validate estimates
4. ⏭️ **Compare architectures** - LUT vs serial
5. ⏭️ **Document results** - prepare publication

### Decision Point:

**After Level 1 validation**:
- If Power < 500 μW average → **SUCCESS!** Publish results
- If Power > 500 μW average → Consider Level 2 (ASIC path)

---

## Conclusion

**YES, we can push your project into ultra-low power!**

**Realistic Target** (Level 1 - FPGA):
- **Active**: 20-40 mW @ 10 MHz
- **Average**: 200-500 μW (1% duty cycle)
- **Energy Harvesting**: ✅ Compatible
- **Timeline**: 2-4 weeks
- **Feasibility**: ✅ **HIGH**

**Aggressive Target** (Level 2 - ASIC):
- **Active**: 50-200 μW @ 1 MHz
- **Average**: 1-20 μW (1% duty cycle)
- **Battery-Free**: ✅ Enabled
- **Timeline**: 6-12 months
- **Feasibility**: ⚠️ **MEDIUM** (requires ASIC)

**Recommendation**: Start with **Level 1** (FPGA optimizations) to:
1. Prove the concept
2. Measure actual power
3. Validate energy harvesting compatibility
4. Generate publishable results

This positions your work at the **cutting edge of ultra-low power IoT cryptography!**

---

**Next File**: `aes_ultra_low_power_serial_8bit.v` (if you want to proceed)
