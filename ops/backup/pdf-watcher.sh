#!/bin/bash

# PDF File Watcher
# Automatically converts PDFs to markdown when added or modified

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
INCOMING_DIR="$DOCS_DIR/incoming"
CONVERTER_SCRIPT="$(dirname "$0")/simple-pdf-converter.sh"
LOG_FILE="$PROJECT_ROOT/logs/backup/pdf-watcher.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create logs directory
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Function to check if fswatch is installed
check_fswatch() {
    if ! command -v fswatch &> /dev/null; then
        echo -e "${YELLOW}Installing fswatch for file watching...${NC}"
        brew install fswatch
    fi
}

# Function to convert a single PDF
convert_single_pdf() {
    local pdf_file="$1"
    local pdf_name=$(basename "$pdf_file")

    log_message "🔄 Detected change in: $pdf_name"

    # Run the converter script
    if "$CONVERTER_SCRIPT" convert "$pdf_file"; then
        log_message "✅ Successfully converted: $pdf_name"
    else
        log_message "❌ Failed to convert: $pdf_name"
    fi
}

# Function to start watching
start_watcher() {
    echo -e "${BLUE}=== PDF File Watcher ===${NC}"
    echo -e "Watching directory: ${GREEN}$INCOMING_DIR${NC}"
    echo -e "Log file: ${GREEN}$LOG_FILE${NC}"
    echo -e "Press Ctrl+C to stop watching"
    echo ""

    log_message "🚀 Starting PDF file watcher"

    # Use fswatch to monitor the incoming directory
    fswatch -o "$INCOMING_DIR" | while read f; do
        # Check for PDF files that have been modified
        for pdf_file in "$INCOMING_DIR"/*.pdf; do
            if [ -f "$pdf_file" ]; then
                # Check if this PDF was recently modified (within last 5 seconds)
                local file_time=$(stat -f "%m" "$pdf_file")
                local current_time=$(date +%s)
                local time_diff=$((current_time - file_time))

                if [ $time_diff -le 5 ]; then
                    convert_single_pdf "$pdf_file"
                fi
            fi
        done
    done
}

# Function to run initial conversion
run_initial_conversion() {
    echo -e "${BLUE}Running initial conversion of existing PDFs...${NC}"
    "$CONVERTER_SCRIPT" all
    echo ""
}

# Function to show status
show_status() {
    echo -e "${BLUE}=== PDF Watcher Status ===${NC}"
    echo -e "Watching directory: $INCOMING_DIR"
    echo -e "Converter script: $CONVERTER_SCRIPT"
    echo -e "Log file: $LOG_FILE"
    echo ""

    # Show recent log entries
    if [ -f "$LOG_FILE" ]; then
        echo -e "${YELLOW}Recent activity:${NC}"
        tail -10 "$LOG_FILE" | while read line; do
            echo "  $line"
        done
    else
        echo -e "${YELLOW}No log file found yet${NC}"
    fi
}

# Main execution
case "${1:-watch}" in
    "watch")
        check_fswatch
        run_initial_conversion
        start_watcher
        ;;
    "convert")
        run_initial_conversion
        ;;
    "status")
        show_status
        ;;
    "stop")
        # Find and kill fswatch processes
        pkill -f "fswatch.*docs" || echo "No fswatch processes found"
        log_message "🛑 PDF watcher stopped"
        ;;
    *)
        echo "Usage: $0 [watch|convert|status|stop]"
        echo ""
        echo "Commands:"
        echo "  watch   - Start watching for PDF changes (default)"
        echo "  convert - Convert all existing PDFs once"
        echo "  status  - Show watcher status and recent activity"
        echo "  stop    - Stop the file watcher"
        exit 1
        ;;
esac
