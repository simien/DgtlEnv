#!/bin/bash

# PDF to Markdown Converter
# Converts PDF files to markdown format with metadata extraction

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
INCOMING_DIR="$DOCS_DIR/incoming"
METRICS_DIR="$PROJECT_ROOT/metrics"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== PDF to Markdown Converter ===${NC}"

# Check if pdftotext is installed
if ! command -v pdftotext &> /dev/null; then
    echo -e "${YELLOW}Installing pdftotext (poppler-utils)...${NC}"
    brew install poppler
fi

# Create directories if they don't exist
mkdir -p "$INCOMING_DIR"
mkdir -p "$METRICS_DIR"

# Function to convert PDF to Markdown
convert_pdf_to_markdown() {
    local pdf_file="$1"
    local pdf_name=$(basename "$pdf_file" .pdf)
    local md_file="$DOCS_DIR/${pdf_name}.md"
    
    echo -e "${BLUE}Converting: ${pdf_name}.pdf${NC}"
    
    # Extract text from PDF
    pdftotext -layout "$pdf_file" - | sed 's/\f/\n\n---\n\n/g' > "$md_file"
    
    # Add metadata header
    local file_size=$(du -h "$pdf_file" | cut -f1)
    local page_count=$(pdfinfo "$pdf_file" 2>/dev/null | grep "Pages:" | awk '{print $2}' || echo "Unknown")
    local creation_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create metadata header
    cat > "$md_file.tmp" << EOF
# ${pdf_name}

**Source:** ${pdf_name}.pdf  
**Original Size:** ${file_size}  
**Pages:** ${page_count}  
**Converted:** ${creation_date}  
**Status:** ✅ Converted

---

EOF
    
    # Append the converted content
    cat "$md_file" >> "$md_file.tmp"
    mv "$md_file.tmp" "$md_file"
    
    echo -e "${GREEN}✅ Converted: $md_file${NC}"
    return 0
}

# Function to process all PDFs in incoming directory
process_all_pdfs() {
    echo -e "${BLUE}Processing all PDFs in incoming directory...${NC}"
    
    local converted_count=0
    local total_pdfs=0
    
    for pdf_file in "$INCOMING_DIR"/*.pdf; do
        if [ -f "$pdf_file" ]; then
            total_pdfs=$((total_pdfs + 1))
            local pdf_name=$(basename "$pdf_file" .pdf)
            local md_file="$DOCS_DIR/${pdf_name}.md"
            
            # Check if markdown already exists and is newer
            if [ -f "$md_file" ] && [ "$md_file" -nt "$pdf_file" ]; then
                echo -e "${YELLOW}⏭️  Skipping ${pdf_name}.pdf (markdown is up to date)${NC}"
            else
                if convert_pdf_to_markdown "$pdf_file"; then
                    converted_count=$((converted_count + 1))
                fi
            fi
        fi
    done
    
    echo ""
    echo -e "${GREEN}📊 Conversion Summary:${NC}"
    echo -e "Total PDFs found: ${total_pdfs}"
    echo -e "Newly converted: ${converted_count}"
    echo -e "Skipped (up to date): $((total_pdfs - converted_count))"
    
    # Update metrics
    update_conversion_metrics "$converted_count" "$total_pdfs"
}

# Function to update conversion metrics
update_conversion_metrics() {
    local converted_count="$1"
    local total_pdfs="$2"
    local metrics_file="$METRICS_DIR/pdf-conversion-metrics.json"
    
    # Create metrics file if it doesn't exist
    if [ ! -f "$metrics_file" ]; then
        cat > "$metrics_file" << EOF
{
  "total_conversions": 0,
  "total_pdfs_processed": 0,
  "last_conversion_date": "",
  "conversion_history": []
}
EOF
    fi
    
    # Update metrics
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    local total_conversions=$(jq -r '.total_conversions' "$metrics_file" 2>/dev/null || echo "0")
    local total_processed=$(jq -r '.total_pdfs_processed' "$metrics_file" 2>/dev/null || echo "0")
    
    total_conversions=$((total_conversions + converted_count))
    total_processed=$((total_processed + total_pdfs))
    
    # Create updated metrics
    cat > "$metrics_file" << EOF
{
  "total_conversions": ${total_conversions},
  "total_pdfs_processed": ${total_processed},
  "last_conversion_date": "${current_date}",
  "conversion_history": [
    {
      "date": "${current_date}",
      "converted": ${converted_count},
      "total": ${total_pdfs}
    }
  ]
}
EOF
    
    echo -e "${GREEN}📈 Metrics updated: $metrics_file${NC}"
}

# Function to create metrics dashboard
create_metrics_dashboard() {
    local dashboard_file="$METRICS_DIR/dashboard.md"
    local metrics_file="$METRICS_DIR/pdf-conversion-metrics.json"
    
    if [ ! -f "$metrics_file" ]; then
        echo -e "${YELLOW}No metrics file found. Run conversion first.${NC}"
        return 1
    fi
    
    local total_conversions=$(jq -r '.total_conversions' "$metrics_file")
    local total_processed=$(jq -r '.total_pdfs_processed' "$metrics_file")
    local last_date=$(jq -r '.last_conversion_date' "$metrics_file")
    
    cat > "$dashboard_file" << EOF
# PDF Conversion Metrics Dashboard

**Last Updated:** ${last_date}  
**Total Conversions:** ${total_conversions}  
**Total PDFs Processed:** ${total_processed}  

## 📊 Conversion Statistics

- **Success Rate:** $((total_conversions * 100 / total_processed))%
- **Total Files Processed:** ${total_processed}
- **Total Successful Conversions:** ${total_conversions}

## 📁 Converted Files

EOF
    
    # List all converted files
    for md_file in "$DOCS_DIR"/*.md; do
        if [ -f "$md_file" ]; then
            local filename=$(basename "$md_file")
            local size=$(du -h "$md_file" | cut -f1)
            local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$md_file")
            echo "- **${filename}** (${size}, modified: ${modified})" >> "$dashboard_file"
        fi
    done
    
    echo "" >> "$dashboard_file"
    echo "## 🔄 Recent Activity" >> "$dashboard_file"
    echo "" >> "$dashboard_file"
    
    # Add recent conversion history
    jq -r '.conversion_history[] | "- **\(.date):** Converted \(.converted)/\(.total) files"' "$metrics_file" >> "$dashboard_file"
    
    echo -e "${GREEN}📊 Dashboard created: $dashboard_file${NC}"
}

# Main execution
case "${1:-all}" in
    "all")
        process_all_pdfs
        create_metrics_dashboard
        ;;
    "dashboard")
        create_metrics_dashboard
        ;;
    "convert")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a PDF file${NC}"
            echo "Usage: $0 convert <pdf-file>"
            exit 1
        fi
        convert_pdf_to_markdown "$2"
        create_metrics_dashboard
        ;;
    *)
        echo "Usage: $0 [all|dashboard|convert <pdf-file>]"
        echo ""
        echo "Commands:"
        echo "  all       - Convert all PDFs in docs directory"
        echo "  dashboard - Create/update metrics dashboard"
        echo "  convert   - Convert a specific PDF file"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ PDF conversion process completed!${NC}" 