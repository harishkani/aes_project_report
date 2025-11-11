# Publication-Quality Figures for AES-128 FPGA Implementation

This directory contains publication-ready diagrams suitable for IEEE, ACM, Springer, and other research paper submissions.

## 📁 Files

### Main Documents
- **`aes_publication_diagrams.tex`** - Complete IEEE conference paper format with all figures and tables
- **`standalone_figures.tex`** - Individual figures as separate pages (for easy extraction)

### Features
- ✅ IEEE conference paper format (IEEEtran class)
- ✅ Grayscale-friendly color scheme (prints well in B&W)
- ✅ Professional TikZ diagrams with publication standards
- ✅ High-resolution vector graphics (scalable)
- ✅ Proper figure captions and labels
- ✅ Publication-ready tables
- ✅ Performance comparison charts
- ✅ Resource utilization plots

## 🎨 Figure List

### System Architecture Diagrams
1. **Figure 1**: High-level system architecture
   - Top-level block diagram
   - I/O interfaces and main functional blocks
   - Clean, professional layout

2. **Figure 2**: AES core architecture
   - Detailed internal structure
   - FSM and datapath components
   - Key expansion module
   - Signal flow annotations

### Control and Processing
3. **Figure 3**: FSM state machine diagram
   - 8-state machine with transitions
   - Encryption and decryption paths
   - Condition labels

4. **Figure 4**: Key expansion architecture
   - On-the-fly generation mechanism
   - Storage comparison (90% reduction)
   - SubWord/RotWord operations

5. **Figure 5**: Column-wise datapath processing
   - State matrix representation
   - Sequential column processing
   - Timing diagram

### Performance Analysis
6. **Figure 6**: Encryption/Decryption data flows
   - Side-by-side comparison
   - Round structure
   - Subfigures for both modes

7. **Figure 7**: Resource utilization chart
   - Bar chart (LUTs, FFs, BRAM, DSP)
   - Publication-quality pgfplots

8. **Figure 8**: Performance comparison scatter plot
   - Throughput vs. LUT count
   - Comparison with other designs

9. **Figure 9**: Timing diagram
   - Complete encryption cycle
   - State transitions over time
   - Cycle-accurate representation

### Tables
- **Table I**: Implementation comparison with related work
- **Table II**: Detailed resource breakdown

## 🔨 Compilation Instructions

### Method 1: Using Make (Recommended)

```bash
make publication    # Compile IEEE paper with all figures
make standalone     # Compile individual figures
make all           # Compile everything
make clean         # Remove auxiliary files
```

### Method 2: Manual Compilation

```bash
# IEEE Conference Paper
pdflatex aes_publication_diagrams.tex
pdflatex aes_publication_diagrams.tex  # Run twice for references
bibtex aes_publication_diagrams        # If using citations

# Standalone Figures
pdflatex standalone_figures.tex
```

### Method 3: Individual Figure Extraction

The standalone document creates one figure per page. To extract individual PDFs:

```bash
# After compiling standalone_figures.tex
pdfseparate standalone_figures.pdf figure_%d.pdf

# Or use pdftk
pdftk standalone_figures.pdf burst output figure_%02d.pdf
```

## 📊 Using Figures in Your Paper

### LaTeX Integration

```latex
\documentclass[conference]{IEEEtran}
\usepackage{graphicx}

\begin{document}

% Include a figure
\begin{figure}[t]
\centering
\includegraphics[width=\columnwidth]{figure_01.pdf}
\caption{High-level system architecture showing...}
\label{fig:system_arch}
\end{figure}

% Reference in text
As shown in Fig.~\ref{fig:system_arch}, the system...

\end{document}
```

### Microsoft Word Integration

1. Compile the standalone figures: `pdflatex standalone_figures.tex`
2. Convert to high-resolution PNG:
   ```bash
   pdftoppm -png -r 300 standalone_figures.pdf figure
   ```
3. Insert PNG files into Word document

### Overleaf Integration

1. Upload `aes_publication_diagrams.tex` to Overleaf
2. Set compiler to PDFLaTeX
3. Compile and download PDF
4. Or copy individual figure code into your existing project

## 🎨 Customization

### Changing Colors

Edit color definitions at the top of the document:

```latex
\definecolor{blockfill}{RGB}{240,240,240}      % Light gray fill
\definecolor{emphasisfill}{RGB}{200,200,200}   % Darker gray
\definecolor{signalcolor}{RGB}{80,80,80}       % Dark gray lines
```

### Modifying Figure Sizes

For IEEE single-column:
```latex
\includegraphics[width=\columnwidth]{figure.pdf}
```

For IEEE double-column:
```latex
\begin{figure*}[t]
\includegraphics[width=\textwidth]{figure.pdf}
\end{figure*}
```

### Font Sizes

Standard publication fonts are already configured:
- `\footnotesize` for block labels
- `\scriptsize` for annotations
- `\small` for captions (automatic)

## 📐 Publication Standards

### IEEE Standards Compliance
- ✅ Single-column figures: Maximum width 3.5 inches (89 mm)
- ✅ Double-column figures: Maximum width 7.16 inches (181 mm)
- ✅ Minimum font size: 6pt (achieved with \scriptsize)
- ✅ Line thickness: Minimum 0.5pt (thick style in TikZ)
- ✅ Grayscale compatibility: All figures print clearly in B&W

### ACM Standards Compliance
- ✅ Vector graphics (PDF format)
- ✅ Embedded fonts
- ✅ Accessible color schemes
- ✅ Proper figure captions

### Figure Quality Checklist
- ✅ All text is readable when scaled
- ✅ Line weights are consistent
- ✅ Colors work in grayscale
- ✅ Captions are descriptive
- ✅ Labels are clear and unambiguous
- ✅ Aspect ratios are appropriate

## 🔧 Advanced Usage

### Creating Variants

To create a color version for presentations:

```latex
% Add vibrant colors
\definecolor{blockfill}{RGB}{100,149,237}     % Cornflower blue
\definecolor{emphasisfill}{RGB}{255,140,0}    % Dark orange
```

### Exporting to EPS

Some journals require EPS format:

```bash
pdftops -eps figure_01.pdf figure_01.eps
```

### High-Resolution Raster

For posters or presentations:

```bash
pdftoppm -png -r 600 standalone_figures.pdf figure_hires
```

## 📝 Citation

If using these figures in your publication, consider this citation format:

```bibtex
@misc{aes_fpga_2025,
    title={AES-128 FPGA Implementation: Architecture and Design},
    author={Your Name},
    year={2025},
    note={Hardware implementation with on-the-fly key expansion}
}
```

## 🐛 Troubleshooting

### Missing Packages

```bash
# Ubuntu/Debian
sudo apt-get install texlive-full texlive-science

# Or install individual packages
tlmgr install pgfplots tikz IEEEtran
```

### Compilation Errors

1. **"IEEEtran.cls not found"**
   ```bash
   tlmgr install IEEEtran
   ```

2. **PGFPlots errors**
   ```bash
   tlmgr install pgfplots
   ```

3. **Font warnings**
   - These are usually safe to ignore
   - Or install: `tlmgr install cm-super`

### Figure Not Appearing

- Ensure you compile **twice** for references
- Check file paths are correct
- Verify figure environment syntax

## 📚 Resources

### LaTeX Documentation
- TikZ & PGF Manual: http://mirrors.ctan.org/graphics/pgf/base/doc/pgfmanual.pdf
- PGFPlots Manual: http://mirrors.ctan.org/graphics/pgf/contrib/pgfplots/doc/pgfplots.pdf
- IEEEtran: http://www.ctan.org/pkg/ieeetran

### IEEE Author Guidelines
- Graphics: https://www.ieee.org/publications/authors/authors-journals.html
- Template: https://template-selector.ieee.org/

### Online Tools
- Overleaf IEEE Template: https://www.overleaf.com/latex/templates/ieee-conference-template
- TikZ Editor: https://www.mathcha.io/

## 💡 Tips for Best Results

1. **Always use vector graphics** - Never convert to raster unless required
2. **Keep it simple** - Less clutter = clearer message
3. **Test in grayscale** - Print preview in B&W to check readability
4. **Consistent styling** - Use same colors/fonts across all figures
5. **Self-contained captions** - Readers should understand without reading text
6. **Label everything** - All axes, blocks, and signals should be labeled
7. **Use subfigures** - For related diagrams, use (a), (b), (c) subfigures

## 🎯 Quick Start Example

```bash
# 1. Compile IEEE paper
pdflatex aes_publication_diagrams.tex
pdflatex aes_publication_diagrams.tex

# 2. View result
# Opens aes_publication_diagrams.pdf with all figures

# 3. Extract figure 1 for your paper
pdftk standalone_figures.pdf cat 1 output system_architecture.pdf

# 4. Use in your LaTeX paper
# \includegraphics[width=\columnwidth]{system_architecture.pdf}
```

## 📦 What's Included

- **9 publication-ready figures**
- **2 formatted tables**
- **IEEE conference paper template**
- **Standalone extraction version**
- **Makefile for automation**
- **Full documentation**

All figures are:
- ✅ Peer-review ready
- ✅ Print-quality (vector)
- ✅ Grayscale compatible
- ✅ Standards compliant
- ✅ Professionally styled
- ✅ Fully customizable

Perfect for submissions to IEEE, ACM, Elsevier, Springer, and other technical publishers!
