# Architecture Diagrams - Usage Guide

This directory contains professional architecture diagrams for the AES-128 implementation in multiple formats.

## Files Included

1. **architecture_diagrams.md** - ASCII art diagrams (text-based, works everywhere)
2. **architecture_diagrams.tex** - LaTeX/TikZ diagrams (publication quality)
3. **architecture_diagrams.drawio** - Draw.io editable diagrams (visual editor)

## How to Use

### 1. ASCII Diagrams (Markdown)
**File**: `architecture_diagrams.md`

Simply view in any text editor or markdown viewer. Great for:
- Quick reference
- GitHub/GitLab documentation
- Plain text environments

```bash
# View in terminal
cat architecture_diagrams.md

# View in VS Code, vim, or any text editor
```

### 2. LaTeX/TikZ Diagrams
**File**: `architecture_diagrams.tex`

**To compile:**
```bash
# Install LaTeX (if not already installed)
sudo apt-get install texlive-full  # Ubuntu/Debian
# or
brew install --cask mactex          # macOS

# Compile to PDF
pdflatex architecture_diagrams.tex

# This generates: architecture_diagrams.pdf
```

**To include in your LaTeX document:**
```latex
\documentclass{article}
\usepackage{tikz}
\usetikzlibrary{shapes.geometric, arrows.meta, positioning, fit, backgrounds, calc}

\begin{document}

% Include specific page/diagram
\includegraphics[page=1,width=\textwidth]{architecture_diagrams.pdf}

\end{document}
```

**Or extract individual diagrams:**
```bash
# Split PDF into separate pages
pdftk architecture_diagrams.pdf burst output diagram_%02d.pdf

# Or use pdfseparate
pdfseparate architecture_diagrams.pdf diagram-%d.pdf
```

**Features:**
- Publication-quality vector graphics
- Scalable to any size without loss
- Professional appearance for papers/reports
- Three separate diagrams:
  1. On-the-fly Key Expansion Module
  2. 32-bit AES Datapath
  3. Round Processing Timeline

### 3. Draw.io Diagrams
**File**: `architecture_diagrams.drawio`

**To edit:**
1. **Online (easiest)**:
   - Go to https://app.diagrams.net/
   - File → Open From → Device
   - Select `architecture_diagrams.drawio`
   - Edit as needed
   - File → Export As → (PNG, PDF, SVG, etc.)

2. **Desktop App**:
   - Download from https://github.com/jgraph/drawio-desktop/releases
   - Install and open `architecture_diagrams.drawio`
   - Edit and export

3. **VS Code**:
   - Install "Draw.io Integration" extension
   - Open `architecture_diagrams.drawio` directly in VS Code
   - Edit inline

**Features:**
- Two separate diagrams (tabs):
  1. "Key Expansion Module"
  2. "32-bit Datapath"
- Fully editable - modify colors, positions, text, connections
- Export to PNG, PDF, SVG, JPEG
- Easy to update and maintain

**Export options:**
- **PNG**: Good for presentations, web, documents
  - File → Export as → PNG
  - Recommended: 300 DPI, transparent background

- **PDF**: Best for reports, LaTeX inclusion
  - File → Export as → PDF
  - Vector format, scales perfectly

- **SVG**: Best for web, further editing
  - File → Export as → SVG
  - Vector format, editable in other tools

## Diagrams Content

All three formats contain the same information:

### 1. On-the-Fly Key Expansion Module
- Shows current 4-word window (128 bits)
- RotWord and SubWord operations
- 4 S-boxes for key transformation
- XOR chain for next round generation
- Feedback loops
- Output multiplexer
- Control signals (start, next, ready)
- Highlights 91% memory savings

### 2. 32-bit AES Datapath
- 128-bit AES state register (4 columns)
- Column selector (processes one column at a time)
- Shared SubBytes module (4 S-boxes)
- ShiftRows (full 128-bit operation)
- MixColumns (32-bit, per column)
- AddRoundKey with XOR
- Key management system
- Control FSM with all states
- Feedback path to state register

### 3. Round Processing Timeline (LaTeX only)
- Encryption flow with cycle counts
- Decryption flow with cycle counts
- Round-by-round breakdown
- Total latency calculations

## Recommendations by Use Case

| Use Case | Best Format | Reasoning |
|----------|-------------|-----------|
| **Academic Paper** | LaTeX/TikZ | Publication quality, vector graphics |
| **Presentation** | Draw.io → PDF/PNG | Easy to customize, export high-res |
| **GitHub README** | Markdown (ASCII) | Works everywhere, version control friendly |
| **Technical Report** | LaTeX or Draw.io → PDF | Professional appearance |
| **Quick Reference** | Markdown (ASCII) | Fast to open, no special tools needed |
| **Web Documentation** | Draw.io → SVG | Scalable, interactive |
| **Further Editing** | Draw.io | Visual editor, easy modifications |

## Tips

### LaTeX Tips:
- Compile with `pdflatex` (not `latex`)
- Requires TikZ libraries (included in full TeXLive)
- Each diagram is on a separate page
- Can be included in Overleaf projects

### Draw.io Tips:
- Use layers for complex diagrams (View → Layers)
- Export with "Selection Only" to get individual components
- Use "Crop" option when exporting to remove excess whitespace
- Grid and snap-to-grid help with alignment

### Markdown Tips:
- Best viewed in monospace fonts
- Works in all text editors
- Can be included in GitHub wikis
- Good for code reviews and documentation

## Examples

### Including in LaTeX report:
```latex
\begin{figure}[h]
  \centering
  \includegraphics[width=0.9\textwidth,page=1]{architecture_diagrams.pdf}
  \caption{AES-128 On-the-Fly Key Expansion Module Architecture}
  \label{fig:key-expansion}
\end{figure}
```

### Converting Draw.io to PNG (command line):
```bash
# Install draw.io command line tool
npm install -g @mermaid-js/mermaid-cli

# Export to PNG
drawio -x -f png -o key_expansion.png architecture_diagrams.drawio --page-index 0
drawio -x -f png -o datapath.png architecture_diagrams.drawio --page-index 1
```

### Including in Markdown:
```markdown
# Architecture

See detailed ASCII diagrams in [architecture_diagrams.md](architecture_diagrams.md)

![Key Expansion](key_expansion.png)
```

## Customization

All formats are fully customizable:

- **LaTeX**: Edit the .tex file, modify TikZ styles, colors, positions
- **Draw.io**: Open and edit visually, change anything
- **Markdown**: Edit text directly, adjust ASCII art

## Questions?

For issues or modifications, refer to:
- TikZ documentation: https://tikz.dev/
- Draw.io help: https://www.diagrams.net/doc/
- LaTeX stackexchange: https://tex.stackexchange.com/

## License

These diagrams document the AES-128 implementation in this repository and are provided for educational and research purposes.
