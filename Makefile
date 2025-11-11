# Makefile for AES-128 FPGA Documentation
# Compiles LaTeX reports and publication-quality figures

.PHONY: all report diagrams publication standalone hardware clean cleanall help

# Default target
all: report diagrams publication standalone hardware

# Compile main technical report
report:
	@echo "Compiling main technical report..."
	@pdflatex -interaction=nonstopmode aes_fpga_report.tex > /dev/null
	@pdflatex -interaction=nonstopmode aes_fpga_report.tex > /dev/null
	@echo "✓ Generated: aes_fpga_report.pdf"

# Compile architecture diagrams
diagrams:
	@echo "Compiling architecture diagrams..."
	@pdflatex -interaction=nonstopmode aes_architecture_diagrams.tex > /dev/null
	@echo "✓ Generated: aes_architecture_diagrams.pdf"

# Compile IEEE publication paper
publication:
	@echo "Compiling IEEE publication paper..."
	@pdflatex -interaction=nonstopmode aes_publication_diagrams.tex > /dev/null
	@pdflatex -interaction=nonstopmode aes_publication_diagrams.tex > /dev/null
	@echo "✓ Generated: aes_publication_diagrams.pdf"

# Compile standalone figures (one per page)
standalone:
	@echo "Compiling standalone figures..."
	@pdflatex -interaction=nonstopmode standalone_figures.tex > /dev/null
	@echo "✓ Generated: standalone_figures.pdf (7 pages)"

# Compile hardware architecture diagrams (RTL-level)
hardware:
	@echo "Compiling hardware architecture diagrams..."
	@pdflatex -interaction=nonstopmode hardware_architecture_diagrams.tex > /dev/null
	@pdflatex -interaction=nonstopmode hardware_architecture_diagrams.tex > /dev/null
	@echo "✓ Generated: hardware_architecture_diagrams.pdf"

# Extract individual figure PDFs
extract: standalone
	@echo "Extracting individual figures..."
	@if command -v pdftk > /dev/null; then \
		pdftk standalone_figures.pdf burst output figure_%02d.pdf; \
		rm -f doc_data.txt; \
		echo "✓ Extracted individual figures: figure_01.pdf - figure_07.pdf"; \
	elif command -v pdfseparate > /dev/null; then \
		pdfseparate standalone_figures.pdf figure_%02d.pdf; \
		echo "✓ Extracted individual figures: figure_01.pdf - figure_07.pdf"; \
	else \
		echo "✗ Error: pdftk or pdfseparate required for extraction"; \
		echo "  Install: sudo apt-get install pdftk-java or poppler-utils"; \
	fi

# Convert figures to PNG (300 DPI)
png: standalone
	@echo "Converting figures to PNG (300 DPI)..."
	@if command -v pdftoppm > /dev/null; then \
		pdftoppm -png -r 300 standalone_figures.pdf figure; \
		echo "✓ Generated PNG files: figure-1.png - figure-7.png"; \
	else \
		echo "✗ Error: pdftoppm required (install poppler-utils)"; \
		echo "  Ubuntu/Debian: sudo apt-get install poppler-utils"; \
	fi

# Convert figures to high-res PNG (600 DPI for posters)
png-hires: standalone
	@echo "Converting figures to high-resolution PNG (600 DPI)..."
	@if command -v pdftoppm > /dev/null; then \
		pdftoppm -png -r 600 standalone_figures.pdf figure-hires; \
		echo "✓ Generated high-res PNG files"; \
	else \
		echo "✗ Error: pdftoppm required (install poppler-utils)"; \
	fi

# Clean auxiliary files
clean:
	@echo "Cleaning auxiliary files..."
	@rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.fdb_latexmk *.fls *.synctex.gz
	@echo "✓ Cleaned auxiliary files"

# Clean everything (including PDFs)
cleanall: clean
	@echo "Removing all generated PDFs..."
	@rm -f *.pdf figure-*.png
	@echo "✓ Cleaned all generated files"

# Check required tools
check:
	@echo "Checking required tools..."
	@command -v pdflatex > /dev/null && echo "✓ pdflatex found" || echo "✗ pdflatex not found"
	@command -v pdftk > /dev/null && echo "✓ pdftk found" || echo "  pdftk not found (optional)"
	@command -v pdfseparate > /dev/null && echo "✓ pdfseparate found" || echo "  pdfseparate not found (optional)"
	@command -v pdftoppm > /dev/null && echo "✓ pdftoppm found" || echo "  pdftoppm not found (optional)"

# Show file information
info:
	@echo "Generated Documentation Files:"
	@echo "================================"
	@ls -lh *.pdf 2>/dev/null || echo "No PDF files found (run 'make all' first)"
	@echo ""
	@ls -lh figure*.png 2>/dev/null || echo "No PNG files found (run 'make png' to generate)"

# Package for distribution
package: all
	@echo "Creating distribution package..."
	@mkdir -p aes_fpga_docs
	@cp *.pdf aes_fpga_docs/ 2>/dev/null || true
	@cp *.tex aes_fpga_docs/
	@cp *.md aes_fpga_docs/
	@cp Makefile aes_fpga_docs/
	@tar -czf aes_fpga_documentation.tar.gz aes_fpga_docs/
	@rm -rf aes_fpga_docs/
	@echo "✓ Created: aes_fpga_documentation.tar.gz"

# Display help
help:
	@echo "AES-128 FPGA Documentation Build System"
	@echo "========================================"
	@echo ""
	@echo "Available targets:"
	@echo "  make all          - Build all documents (default)"
	@echo "  make report       - Build main technical report"
	@echo "  make diagrams     - Build architecture diagrams"
	@echo "  make publication  - Build IEEE publication paper"
	@echo "  make standalone   - Build standalone figures"
	@echo "  make hardware     - Build hardware RTL diagrams"
	@echo "  make extract      - Extract individual figure PDFs"
	@echo "  make png          - Convert to PNG (300 DPI)"
	@echo "  make png-hires    - Convert to PNG (600 DPI)"
	@echo "  make clean        - Remove auxiliary files"
	@echo "  make cleanall     - Remove all generated files"
	@echo "  make check        - Check for required tools"
	@echo "  make info         - Show generated file information"
	@echo "  make package      - Create distribution tarball"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make publication  # For IEEE paper submission"
	@echo "  make extract      # Get individual figure PDFs"
	@echo "  make png          # For MS Word documents"
	@echo ""

# Verbose compilation (for debugging)
verbose-report:
	pdflatex aes_fpga_report.tex
	pdflatex aes_fpga_report.tex

verbose-publication:
	pdflatex aes_publication_diagrams.tex
	pdflatex aes_publication_diagrams.tex
