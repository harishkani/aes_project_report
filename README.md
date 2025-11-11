# AES-128 FPGA Implementation

Complete hardware implementation of AES-128 encryption/decryption from RTL design to FPGA deployment with publication-quality documentation.

## 📚 Documentation

### Technical Reports
- **`aes_fpga_report.tex`** - Comprehensive 40+ page technical report covering RTL to FPGA
- **`aes_architecture_diagrams.tex`** - 7 detailed TikZ architecture diagrams

### 🎯 Publication-Quality Figures (IEEE/ACM Ready)
- **`aes_publication_diagrams.tex`** - Complete IEEE conference paper with 9 figures
- **`standalone_figures.tex`** - Individual figures for easy paper inclusion
- **`hardware_architecture_diagrams.tex`** - RTL-level hardware diagrams (registers, muxes, datapaths) ⭐
- **See [PUBLICATION_FIGURES.md](PUBLICATION_FIGURES.md) for complete usage guide**

### Quick Start
```bash
# Build all documentation
make all

# For IEEE publication paper
make publication

# For hardware architecture diagrams (RTL-level)
make hardware

# Extract individual figures
make extract

# Or use the compilation script
./compile_latex.sh
```

## 🎯 Project Overview

Complete AES-128 FPGA implementation featuring:
- ✅ Full encryption and decryption modes
- ✅ On-the-fly key expansion (90% memory reduction)
- ✅ Column-wise processing architecture
- ✅ NIST FIPS 197 compliant (100% test pass rate)
- ✅ Low resource utilization (3.36% LUTs, 1.61% FFs)
- ✅ Synthesized for Xilinx Artix-7 XC7A100T (Nexys A7)
- ✅ Interactive demo with 7-segment display

## 📊 Key Results

| Metric | Value |
|--------|-------|
| **Target FPGA** | Xilinx Artix-7 XC7A100T |
| **LUT Utilization** | 2,132 / 63,400 (3.36%) |
| **FF Utilization** | 2,043 / 126,800 (1.61%) |
| **Clock Frequency** | 100 MHz |
| **Throughput** | 100 Mbps |
| **Power Consumption** | 172 mW |
| **Latency** | 128 cycles (1.28 μs) |
| **Verification** | 10/10 NIST tests passed |

## 📁 Repository Structure

```
aes_project_report/
├── RTL Design Files (Verilog)
│   ├── aes_fpga_top.v              # FPGA top-level module
│   ├── aes_core_fixed.v            # AES core with FSM
│   ├── aes_key_expansion_otf.v     # On-the-fly key expansion
│   ├── aes_subbytes_32bit.v        # SubBytes transformation
│   ├── aes_sbox.v / aes_inv_sbox.v # S-box lookup tables
│   ├── aes_shiftrows_128bit.v      # ShiftRows transformation
│   ├── aes_mixcolumns_32bit.v      # MixColumns transformation
│   └── seven_seg_controller.v      # Display controller
│
├── Constraints & Configuration
│   └── aes_con.xdc                 # Nexys A7 pin assignments
│
├── Verification
│   └── tb_aes_integration.v        # Comprehensive testbench
│
├── Implementation Results
│   ├── utilization.txt             # Resource utilization report
│   └── power.txt                   # Power analysis report
│
├── LaTeX Documentation
│   ├── aes_fpga_report.tex         # Full technical report
│   ├── aes_architecture_diagrams.tex # Architecture diagrams
│   ├── aes_publication_diagrams.tex  # IEEE paper format ⭐
│   ├── standalone_figures.tex       # Individual figures ⭐
│   ├── README_LATEX.md             # LaTeX compilation guide
│   └── PUBLICATION_FIGURES.md      # Publication guide ⭐
│
└── Build System
    ├── Makefile                    # Automated build system ⭐
    └── compile_latex.sh            # Compilation script
```

## 🚀 Quick Compilation

### Using Makefile (Recommended)
```bash
make publication     # IEEE paper with all figures
make standalone      # Individual figure pages
make extract         # Separate PDF per figure
make png            # Convert to 300 DPI PNG
make all            # Build everything
make clean          # Remove auxiliary files
```

### Using Compilation Script
```bash
chmod +x compile_latex.sh
./compile_latex.sh
```

### Manual Compilation
```bash
pdflatex aes_publication_diagrams.tex
pdflatex aes_publication_diagrams.tex  # Run twice
```

## 📖 Documentation Guides

- **[README_LATEX.md](README_LATEX.md)** - Complete LaTeX compilation instructions
- **[PUBLICATION_FIGURES.md](PUBLICATION_FIGURES.md)** - Using figures in research papers

## 🎨 Publication-Ready Figures

All figures meet IEEE/ACM publication standards:
- ✅ Vector graphics (scalable PDF)
- ✅ Grayscale-compatible color scheme
- ✅ Minimum 6pt font sizes
- ✅ Professional TikZ diagrams
- ✅ Proper captions and labels
- ✅ High-resolution exports available

### Available Figures

**Block-Level Diagrams** (publication_diagrams.tex):
1. High-level system architecture
2. AES core internal structure
3. FSM state machine diagram
4. Key expansion architecture
5. Column-wise processing datapath
6. Encryption/decryption data flows
7. Resource utilization chart
8. Performance comparison plot
9. Timing diagram

**Hardware Architecture Diagrams** (hardware_architecture_diagrams.tex - RTL level):
1. Complete datapath with registers, muxes, and control
2. Pipeline structure comparison (128-bit vs 32-bit)
3. Key expansion hardware (registers, XOR chains, S-boxes)
4. SubBytes S-box LUT implementation
5. MixColumns GF multipliers and XOR trees
6. Control FSM with state registers and counters

## 🔬 Implementation Highlights

### Architecture Features
- **Column-wise processing**: 32-bit datapath reduces logic by 75%
- **On-the-fly key expansion**: Stores only 4 words instead of 44 (90% reduction)
- **No RAM inference**: Uses explicit registers for predictable synthesis
- **Bidirectional operation**: Supports both encryption and decryption
- **State machine control**: 8-state FSM for round management

### Verification
- NIST FIPS 197 test vectors (100% pass rate)
- Round-trip testing (encrypt → decrypt verification)
- Corner case testing (all-zeros, all-ones, patterns)
- 10 comprehensive test cases included

### FPGA Implementation
- **Board**: Digilent Nexys A7-100T
- **Display**: 8× 7-segment displays showing 128-bit output
- **User Interface**: 4 buttons + 16 switches
- **Test Vectors**: 16 predefined patterns (including NIST)
- **Status LEDs**: Real-time state and mode indication

## 🛠️ Design Tools

- **HDL**: Verilog
- **Synthesis**: Xilinx Vivado 2024.1
- **Simulation**: ModelSim/QuestaSim
- **Documentation**: LaTeX + TikZ
- **Target**: Xilinx Artix-7 FPGA

## 📚 Related Documentation

- [NIST FIPS 197 Specification](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf)
- [Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)
- [Vivado Design Suite User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2024_1/ug901-vivado-synthesis.pdf)

## 📝 Citation

If you use this work in your research, please cite:

```bibtex
@misc{aes_fpga_implementation_2025,
    title={AES-128 FPGA Implementation: Architecture and Design},
    author={Your Name},
    year={2025},
    howpublished={\url{https://github.com/harishkani/aes_project_report}},
    note={Complete hardware implementation with on-the-fly key expansion}
}
```

## 🎓 Educational Use

This project serves as:
- Educational reference for AES hardware implementation
- Example of column-wise processing architecture
- Template for publication-quality technical documentation
- Case study in resource-optimized FPGA design

## 📄 License

This documentation and code are provided for educational and research purposes.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome. See the main repository for contribution guidelines.

---

**For detailed LaTeX compilation instructions**, see [README_LATEX.md](README_LATEX.md)

**For using figures in publications**, see [PUBLICATION_FIGURES.md](PUBLICATION_FIGURES.md)
