# AES-128 FPGA Implementation - LaTeX Documentation

This directory contains comprehensive LaTeX documentation for the AES-128 FPGA project.

## Files

### Main Documentation
- **`aes_fpga_report.tex`** - Complete technical report (40+ pages)
  - Algorithm background
  - RTL design architecture
  - Module descriptions
  - FPGA implementation details
  - Synthesis results
  - Verification and testing
  - Performance analysis

- **`aes_architecture_diagrams.tex`** - Detailed architecture diagrams (7 pages)
  - Top-level system architecture
  - AES core internal structure
  - State machine diagram
  - Key expansion module
  - Data path and round operations
  - Column-wise processing details
  - Module interface summary

## Compilation Instructions

### Prerequisites
Install a LaTeX distribution:
- **Linux**: `sudo apt-get install texlive-full`
- **macOS**: Install MacTeX from https://www.tug.org/mactex/
- **Windows**: Install MiKTeX from https://miktex.org/

### Compiling the Main Report

```bash
# Compile main report (run twice for table of contents)
pdflatex aes_fpga_report.tex
pdflatex aes_fpga_report.tex

# Output: aes_fpga_report.pdf
```

### Compiling the Architecture Diagrams

```bash
# Compile diagrams
pdflatex aes_architecture_diagrams.tex

# Output: aes_architecture_diagrams.pdf
```

### Full Compilation Script

```bash
#!/bin/bash
# compile_all.sh

echo "Compiling main report..."
pdflatex -interaction=nonstopmode aes_fpga_report.tex
pdflatex -interaction=nonstopmode aes_fpga_report.tex

echo "Compiling architecture diagrams..."
pdflatex -interaction=nonstopmode aes_architecture_diagrams.tex

echo "Cleaning auxiliary files..."
rm -f *.aux *.log *.out *.toc *.lof *.lot

echo "Done! PDFs generated:"
ls -lh *.pdf
```

## Required LaTeX Packages

The documents use the following packages (included in most full LaTeX distributions):

- **Core**: inputenc, geometry, graphicx
- **Math**: amsmath, amssymb
- **Code**: listings, xcolor
- **Tables**: booktabs, multirow
- **Figures**: caption, subcaption, float
- **Formatting**: fancyhdr, titlesec, enumitem
- **Links**: hyperref
- **Diagrams**: tikz (with libraries: shapes.geometric, arrows.meta, positioning, fit, calc, backgrounds, shapes.multipart, decorations.pathreplacing)

## Online Compilation

If you don't have LaTeX installed locally, you can use online editors:

1. **Overleaf** (https://www.overleaf.com)
   - Upload both `.tex` files
   - Click "Recompile"
   - Download PDFs

2. **Papeeria** (https://papeeria.com)
   - Create new project
   - Upload files
   - Compile and download

## Document Structure

### Main Report Contents
1. Introduction
2. AES Algorithm Background
3. RTL Design Architecture
4. Module Descriptions (9 modules)
5. FPGA Implementation
6. Synthesis and Implementation Results
7. Verification and Testing
8. Performance Analysis
9. Conclusion
10. Appendices (File structure, Synthesis settings, Test vectors)
11. References

### Diagram Pages
1. Top-Level System Architecture
2. AES Core Internal Architecture
3. State Machine (8 states)
4. Key Expansion (On-the-fly)
5. Data Path and Round Operations
6. Column-wise Processing
7. Module Interface Summary

## Customization

### Changing Colors
Edit the color definitions in the preamble:
```latex
\definecolor{moduleblue}{RGB}{100,149,237}
\definecolor{statecolor}{RGB}{255,218,185}
```

### Modifying Diagrams
The TikZ diagrams can be customized by editing:
- Node positions: `at (x,y)` coordinates
- Sizes: `minimum width`, `minimum height`
- Colors: `fill=color`
- Fonts: `font=\size\style`

### Adding Content
To add sections, use standard LaTeX:
```latex
\section{New Section}
\subsection{Subsection}
Content here...
```

## Troubleshooting

### Missing Packages
If compilation fails with "File X.sty not found":
```bash
# Update LaTeX package database
sudo tlmgr update --self
sudo tlmgr install <package-name>
```

### TikZ Errors
- Ensure all TikZ libraries are loaded
- Check for unclosed braces `{}` or brackets `[]`
- Verify node references are defined before use

### Long Compilation Time
- TikZ diagrams can be slow to compile
- Consider using `\includeonly{}` for partial compilation
- Use draft mode: `\documentclass[draft]{article}`

## Output Specifications

- **Paper Size**: A4 (210 × 297 mm)
- **Main Report**: Portrait orientation
- **Diagrams**: Landscape orientation
- **Font**: Computer Modern (LaTeX default)
- **Code Font**: Typewriter (monospace)

## Integration with Report

To include diagrams in the main report:
```latex
\usepackage{pdfpages}
\includepdf[pages=-]{aes_architecture_diagrams.pdf}
```

## License and Usage

These documents are provided as technical documentation for the AES-128 FPGA implementation project. Feel free to:
- Modify for your own projects
- Use as templates for similar reports
- Include in academic submissions
- Present in technical meetings

## Contact and Contributions

For questions or improvements:
- Check the main project repository
- Review Verilog source files for implementation details
- Refer to NIST FIPS 197 for AES specifications

## Version History

- **v1.0** (2025-01-11): Initial comprehensive report and diagrams
  - Complete RTL to FPGA documentation
  - 7 detailed architecture diagrams
  - NIST-compliant implementation details
  - Synthesis and verification results
