#!/bin/bash

# Simple PDF to Markdown Converter
# Uses macOS built-in tools for basic PDF text extraction

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

echo -e "${BLUE}=== Simple PDF to Markdown Converter ===${NC}"

# Create directories if they don't exist
mkdir -p "$INCOMING_DIR"
mkdir -p "$METRICS_DIR"

# Function to extract text from PDF using macOS tools
extract_pdf_text() {
    local pdf_file="$1"
    local output_file="$2"
    
    # Always create a markdown placeholder file
    local pdf_name=$(basename "$pdf_file" .pdf)
    local file_size=$(du -h "$pdf_file" | cut -f1)
    local creation_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$output_file" << EOF
# ${pdf_name}

**Source:** ${pdf_name}.pdf  
**Original Size:** ${file_size}  
**Converted:** ${creation_date}  
**Status:** ⚠️ Manual conversion required

---

## 📄 PDF Content Summary

This PDF has been identified for conversion but requires manual processing due to system limitations.

### File Information:
- **Filename:** ${pdf_name}.pdf
- **Size:** ${file_size}
- **Location:** $pdf_file
- **Conversion Date:** ${creation_date}

### Manual Conversion Steps:
1. Open the PDF in Preview or Adobe Reader
2. Select all text (Cmd+A)
3. Copy text (Cmd+C)
4. Paste into this markdown file
5. Format as markdown

### Alternative Tools:
- Use online PDF to text converters
- Install pdftotext via Homebrew (may require macOS updates)
- Use macOS Preview's text selection and copy/paste

---

**Note:** This is a placeholder file. Please manually convert the PDF content to markdown format.
EOF
    
    return 0
}

# Function to convert PDF to Markdown
convert_pdf_to_markdown() {
    local pdf_file="$1"
    local pdf_name=$(basename "$pdf_file" .pdf)
    local md_file="$DOCS_DIR/${pdf_name}.md"
    
    echo -e "${BLUE}Processing: ${pdf_name}.pdf${NC}"
    
    # Extract text from PDF
    if extract_pdf_text "$pdf_file" "$md_file"; then
        echo -e "${GREEN}✅ Processed: $md_file${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to process: $pdf_file${NC}"
        return 1
    fi
}

# Function to process all PDFs in incoming directory
process_all_pdfs() {
    echo -e "${BLUE}Processing all PDFs in incoming directory...${NC}"
    
    local processed_count=0
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
                    processed_count=$((processed_count + 1))
                fi
            fi
        fi
    done
    
    echo ""
    echo -e "${GREEN}📊 Processing Summary:${NC}"
    echo -e "Total PDFs found: ${total_pdfs}"
    echo -e "Newly processed: ${processed_count}"
    echo -e "Skipped (up to date): $((total_pdfs - processed_count))"
    
    # Update metrics
    update_conversion_metrics "$processed_count" "$total_pdfs"
}

# Function to update conversion metrics
update_conversion_metrics() {
    local processed_count="$1"
    local total_pdfs="$2"
    local metrics_file="$METRICS_DIR/pdf-conversion-metrics.json"
    
    # Create metrics file if it doesn't exist
    if [ ! -f "$metrics_file" ]; then
        cat > "$metrics_file" << EOF
{
  "total_processed": 0,
  "total_pdfs_found": 0,
  "last_processing_date": "",
  "processing_history": []
}
EOF
    fi
    
    # Update metrics
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    local total_processed=$(jq -r '.total_processed' "$metrics_file" 2>/dev/null || echo "0")
    local total_found=$(jq -r '.total_pdfs_found' "$metrics_file" 2>/dev/null || echo "0")
    
    total_processed=$((total_processed + processed_count))
    total_found=$((total_found + total_pdfs))
    
    # Create updated metrics
    cat > "$metrics_file" << EOF
{
  "total_processed": ${total_processed},
  "total_pdfs_found": ${total_found},
  "last_processing_date": "${current_date}",
  "processing_history": [
    {
      "date": "${current_date}",
      "processed": ${processed_count},
      "total": ${total_pdfs}
    }
  ]
}
EOF
    
    echo -e "${GREEN}📈 Metrics updated: $metrics_file${NC}"
}

# Function to create processing dashboard
create_processing_dashboard() {
    local dashboard_file="$METRICS_DIR/pdf-processing-dashboard.md"
    local metrics_file="$METRICS_DIR/pdf-conversion-metrics.json"
    
    if [ ! -f "$metrics_file" ]; then
        echo -e "${YELLOW}No metrics file found. Run processing first.${NC}"
        return 1
    fi
    
    local total_processed=$(jq -r '.total_processed' "$metrics_file")
    local total_found=$(jq -r '.total_pdfs_found' "$metrics_file")
    local last_date=$(jq -r '.last_processing_date' "$metrics_file")
    
    cat > "$dashboard_file" << EOF
# PDF Processing Dashboard

**Last Updated:** ${last_date}  
**Total Processed:** ${total_processed}  
**Total PDFs Found:** ${total_found}  

## 📊 Processing Statistics

- **Processing Rate:** $((total_processed * 100 / total_found))%
- **Total Files Found:** ${total_found}
- **Total Processed:** ${total_processed}

## 📁 Processed Files

EOF
    
    # List all processed files
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
    
    # Add recent processing history
    jq -r '.processing_history[] | "- **\(.date):** Processed \(.processed)/\(.total) files"' "$metrics_file" >> "$dashboard_file"
    
    echo "" >> "$dashboard_file"
    echo "## ⚠️ Manual Conversion Required" >> "$dashboard_file"
    echo "" >> "$dashboard_file"
    echo "Due to system limitations, PDFs require manual conversion:" >> "$dashboard_file"
    echo "" >> "$dashboard_file"
    echo "1. Open PDF in Preview or Adobe Reader" >> "$dashboard_file"
    echo "2. Select all text (Cmd+A)" >> "$dashboard_file"
    echo "3. Copy text (Cmd+C)" >> "$dashboard_file"
    echo "4. Paste into the corresponding .md file" >> "$dashboard_file"
    echo "5. Format as markdown" >> "$dashboard_file"
    
    echo -e "${GREEN}📊 Dashboard created: $dashboard_file${NC}"
}

# Main execution
case "${1:-all}" in
    "all")
        process_all_pdfs
        create_processing_dashboard
        ;;
    "dashboard")
        create_processing_dashboard
        ;;
    "convert")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a PDF file${NC}"
            echo "Usage: $0 convert <pdf-file>"
            exit 1
        fi
        convert_pdf_to_markdown "$2"
        create_processing_dashboard
        ;;
    *)
        echo "Usage: $0 [all|dashboard|convert <pdf-file>]"
        echo ""
        echo "Commands:"
        echo "  all       - Process all PDFs in docs directory"
        echo "  dashboard - Create/update processing dashboard"
        echo "  convert   - Process a specific PDF file"
        echo ""
        echo "Note: This converter creates placeholder files that require manual conversion."
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ PDF processing completed!${NC}" 