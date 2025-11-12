# AES-128 FPGA Architecture Diagrams

This directory contains 6 clean, publication-quality hardware architecture diagrams for the AES-128 FPGA implementation.

## Generated Figures

### Figure 1: Complete AES Datapath
**File:** `fig1_datapath.png`

Shows the complete RTL-level datapath architecture with:
- FSM control and counters
- State registers (Input, State, Temp, Output)
- 32-bit column-wise processing with MUX 4:1
- SubBytes (4 parallel S-boxes)
- ShiftRows operation
- MixColumns GF(2^8) operations
- AddRoundKey XOR
- DEMUX for column reassembly
- Round key input
- Control signal paths (dashed lines)
- Data paths (solid arrows)

**Key Feature:** 32-bit column-wise processing reduces area by 75% compared to 128-bit datapath

---

### Figure 2: Pipeline Comparison
**File:** `fig2_pipeline.png`

Side-by-side comparison showing:
- **(a) Traditional 128-bit Pipeline:** Full-width datapath, 1 cycle/round, high area
- **(b) Column-wise 32-bit (This Work):** Optimized datapath, 4 cycles/round, low area

**Key Feature:** Shows the architectural tradeoff between throughput and area

---

### Figure 3: On-the-Fly Key Expansion
**File:** `fig3_keyexp.png`

Shows the key expansion architecture with:
- 4-word sliding window (w0, w1, w2, w3) - 128 bits total
- RotWord operation
- SubWord with 4 S-boxes
- Rcon (round constant) addition
- XOR chain for word generation
- Feedback paths for window update
- Output MUX for round key selection

**Key Feature:** 90% memory reduction - stores only 4 words instead of all 44 round key words

---

### Figure 4: SubBytes Operation
**File:** `fig4_subbytes.png`

Shows 32-bit SubBytes implementation with:
- Input byte extraction (4 bytes from 32-bit column)
- 4 parallel 256×8 S-box LUTs
- enc/dec mode control
- Output byte reassembly
- Vertical dataflow for clarity

**Key Feature:** Parallel processing of 4 bytes with configurable encryption/decryption

---

### Figure 5: MixColumns Operation
**File:** `fig5_mixcol.png`

Shows GF(2^8) arithmetic implementation with:
- 4 input bytes (s0, s1, s2, s3)
- GF multipliers (×02, ×03)
- XOR trees for matrix multiplication
- Detail box explaining xtime operation
- First two rows shown in detail, remaining indicated with "..."

**Key Feature:** Demonstrates Galois Field arithmetic for MixColumns matrix multiplication

---

### Figure 6: Control FSM
**File:** `fig6_fsm.png`

Shows the control state machine with:
- State register (4-bit)
- Next state logic
- Output decode logic
- Three counters: round_cnt (4-bit), col_cnt (2-bit), phase (2-bit)
- Increment logic (+1)
- External inputs (start, enc_dec, data_valid)
- Control outputs (mux_sel, key_sel, enables, ready, valid)

**Key Feature:** Complete FSM showing state management and counter control for round/column processing

---

## File Formats

Each figure is available in three formats:

1. **`.tex`** - Standalone LaTeX source (TikZ)
2. **`.pdf`** - Compiled PDF (vector graphics)
3. **`.png`** - High-resolution PNG (300 DPI) for easy viewing

## Compilation

To recompile any figure:

```bash
pdflatex fig1_datapath.tex
pdflatex fig2_pipeline.tex
pdflatex fig3_keyexp.tex
pdflatex fig4_subbytes.tex
pdflatex fig5_mixcol.tex
pdflatex fig6_fsm.tex
```

To regenerate PNG images:

```bash
pdftoppm fig1_datapath.pdf fig1_datapath -png -singlefile -r 300
pdftoppm fig2_pipeline.pdf fig2_pipeline -png -singlefile -r 300
pdftoppm fig3_keyexp.pdf fig3_keyexp -png -singlefile -r 300
pdftoppm fig4_subbytes.pdf fig4_subbytes -png -singlefile -r 300
pdftoppm fig5_mixcol.pdf fig5_mixcol -png -singlefile -r 300
pdftoppm fig6_fsm.pdf fig6_fsm -png -singlefile -r 300
```

## Architecture Verification

All diagrams have been verified against the actual Verilog implementation:
- ✓ `aes_core_fixed.v` - Main AES core with column-wise processing
- ✓ `aes_key_expansion_otf.v` - On-the-fly key expansion with 4-word window
- ✓ `aes_subbytes_32bit.v` - 32-bit SubBytes with 4 parallel S-boxes
- ✓ `aes_mixcolumns_32bit.v` - MixColumns with GF(2^8) multipliers
- ✓ FSM states and counters match implementation

## Design Features Highlighted

1. **Area Optimization:** Column-wise processing (32-bit vs 128-bit)
2. **Memory Reduction:** On-the-fly key expansion (4 words vs 44 words)
3. **Parallel Processing:** 4 S-boxes operating simultaneously
4. **Configurable Operation:** Support for both encryption and decryption
5. **Control Flow:** FSM-based round and column management

---

**Generated:** November 12, 2025
**Tool:** LaTeX + TikZ (standalone class)
**Resolution:** 300 DPI PNG images
