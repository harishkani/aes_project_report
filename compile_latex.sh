#!/bin/bash
# LaTeX Compilation Script for AES-128 FPGA Documentation

echo "======================================"
echo "AES-128 FPGA Documentation Compiler"
echo "======================================"
echo ""

# Check if pdflatex is available
if ! command -v pdflatex &> /dev/null; then
    echo "ERROR: pdflatex not found!"
    echo "Please install LaTeX:"
    echo "  Ubuntu/Debian: sudo apt-get install texlive-full"
    echo "  macOS: Install MacTeX from https://www.tug.org/mactex/"
    echo "  Windows: Install MiKTeX from https://miktex.org/"
    exit 1
fi

# Function to compile LaTeX document
compile_doc() {
    local doc=$1
    local name=$(basename "$doc" .tex)

    echo "Compiling $doc..."
    pdflatex -interaction=nonstopmode "$doc" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        # Compile twice for references
        pdflatex -interaction=nonstopmode "$doc" > /dev/null 2>&1
        echo "✓ Successfully compiled: ${name}.pdf"
        return 0
    else
        echo "✗ Failed to compile: $doc"
        echo "  Run 'pdflatex $doc' to see error details"
        return 1
    fi
}

# Compile main report
echo ""
echo "1. Compiling main technical report..."
compile_doc "aes_fpga_report.tex"

# Compile architecture diagrams
echo ""
echo "2. Compiling architecture diagrams..."
compile_doc "aes_architecture_diagrams.tex"

# Clean up auxiliary files
echo ""
echo "3. Cleaning auxiliary files..."
rm -f *.aux *.log *.out *.toc *.lof *.lot 2>/dev/null
echo "✓ Cleanup complete"

# Display results
echo ""
echo "======================================"
echo "Compilation Complete!"
echo "======================================"
echo ""
echo "Generated PDFs:"
if [ -f "aes_fpga_report.pdf" ]; then
    size=$(ls -lh aes_fpga_report.pdf | awk '{print $5}')
    echo "  • aes_fpga_report.pdf ($size)"
fi
if [ -f "aes_architecture_diagrams.pdf" ]; then
    size=$(ls -lh aes_architecture_diagrams.pdf | awk '{print $5}')
    echo "  • aes_architecture_diagrams.pdf ($size)"
fi
echo ""
