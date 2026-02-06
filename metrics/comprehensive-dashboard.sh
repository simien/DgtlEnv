#!/bin/bash

# Comprehensive Dashboard Generator
# Combines system metrics, PDF conversion tracking, and optimization progress

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METRICS_DIR="$PROJECT_ROOT/metrics"
DOCS_DIR="$PROJECT_ROOT/docs"
CONVERTED_DIR="$DOCS_DIR/converted"
DASHBOARD_DIR="$METRICS_DIR/dashboards"
LOGS_DIR="$PROJECT_ROOT/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "$DASHBOARD_DIR"
mkdir -p "$LOGS_DIR"

# Function to get system status
get_system_status() {
    local memory_usage=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    local total_memory=$(sysctl -n hw.memsize | awk '{print $0/1024/1024/1024}')
    local page_size=4096
    local active_mb=$((memory_usage * page_size / 1024 / 1024))
    local total_mb=$(echo "$total_memory * 1024" | bc -l | cut -d. -f1)
    local usage_percent=$(echo "$active_mb * 100 / $total_mb" | bc -l | cut -d. -f1)
    
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' | cut -d. -f1)
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//' | cut -d. -f1)
    
    echo "$usage_percent|$cpu_usage|$disk_usage"
}

# Function to get PDF conversion stats
get_pdf_stats() {
    local total_pdfs=0
    local converted_pdfs=0
    
    # Count PDFs in docs directory
    for pdf_file in "$DOCS_DIR"/*.pdf; do
        if [ -f "$pdf_file" ]; then
            total_pdfs=$((total_pdfs + 1))
        fi
    done
    
    # Count converted markdown files
    if [ -d "$CONVERTED_DIR" ]; then
        for md_file in "$CONVERTED_DIR"/*.md; do
            if [ -f "$md_file" ]; then
                converted_pdfs=$((converted_pdfs + 1))
            fi
        done
    fi
    
    echo "$total_pdfs|$converted_pdfs"
}

# Function to create status indicators
create_status_indicator() {
    local value="$1"
    local threshold="$2"
    local label="$3"
    
    if [ "$value" -lt "$threshold" ]; then
        echo "✅ $label: ${value}%"
    else
        echo "⚠️  $label: ${value}%"
    fi
}

# Function to create progress bar
create_progress_bar() {
    local percentage="$1"
    local width=30
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
}

# Function to generate comprehensive dashboard
generate_comprehensive_dashboard() {
    local dashboard_file="$DASHBOARD_DIR/comprehensive-dashboard.md"
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get system status
    local system_status=$(get_system_status)
    local memory_usage=$(echo "$system_status" | cut -d'|' -f1)
    local cpu_usage=$(echo "$system_status" | cut -d'|' -f2)
    local disk_usage=$(echo "$system_status" | cut -d'|' -f3)
    
    # Get PDF stats
    local pdf_stats=$(get_pdf_stats)
    local total_pdfs=$(echo "$pdf_stats" | cut -d'|' -f1)
    local converted_pdfs=$(echo "$pdf_stats" | cut -d'|' -f2)
    local conversion_rate=$(echo "$converted_pdfs * 100 / $total_pdfs" | bc -l 2>/dev/null | cut -d. -f1 || echo "0")
    
    # Create visual bars
    local memory_bar=$(create_progress_bar $memory_usage)
    local cpu_bar=$(create_progress_bar $cpu_usage)
    local disk_bar=$(create_progress_bar $disk_usage)
    local conversion_bar=$(create_progress_bar $conversion_rate)
    
    cat > "$dashboard_file" << EOF
# DgtlEnv Comprehensive Dashboard

**Last Updated:** ${current_date}  
**Device:** MacBook Pro (Retina, 15-inch, Mid 2015)  
**OS:** macOS 12.7.6 Monterey  

---

## 🖥️ System Performance

### Memory Usage: ${memory_usage}%
\`\`\`
${memory_bar}
\`\`\`
$(create_status_indicator $memory_usage 80 "Memory Status")

### CPU Usage: ${cpu_usage}%
\`\`\`
${cpu_bar}
\`\`\`
$(create_status_indicator $cpu_usage 70 "CPU Status")

### Disk Usage: ${disk_usage}%
\`\`\`
${disk_bar}
\`\`\`
$(create_status_indicator $disk_usage 85 "Disk Status")

---

## 📄 PDF Conversion Progress

### Conversion Rate: ${conversion_rate}%
\`\`\`
${conversion_bar}
\`\`\`

**Statistics:**
- **Total PDFs:** ${total_pdfs}
- **Converted:** ${converted_pdfs}
- **Remaining:** $((total_pdfs - converted_pdfs))
- **Success Rate:** ${conversion_rate}%

### Recent Conversions:
$(if [ -d "$CONVERTED_DIR" ]; then
    echo "Recent markdown files:"
    ls -la "$CONVERTED_DIR"/*.md 2>/dev/null | tail -5 | while read line; do
        echo "- $line"
    done || echo "No converted files found"
else
    echo "No converted directory found"
fi)

---

## 📊 Optimization Progress

### ✅ Completed Optimizations
- [x] Cursor IDE performance optimization
- [x] System monitoring setup (Stats, htop)
- [x] Docker/Colima resource management
- [x] Automated cleanup scripts
- [x] PDF to markdown conversion system
- [x] Comprehensive metrics tracking

### 🎯 Performance Targets
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Memory | ${memory_usage}% | < 80% | $(if [ $memory_usage -lt 80 ]; then echo "✅ Good"; else echo "⚠️  High"; fi) |
| CPU | ${cpu_usage}% | < 70% | $(if [ $cpu_usage -lt 70 ]; then echo "✅ Good"; else echo "⚠️  High"; fi) |
| Disk | ${disk_usage}% | < 85% | $(if [ $disk_usage -lt 85 ]; then echo "✅ Good"; else echo "⚠️  High"; fi) |
| PDF Conversion | ${conversion_rate}% | 100% | $(if [ $conversion_rate -eq 100 ]; then echo "✅ Complete"; else echo "🔄 In Progress"; fi) |

---

## 🛠️ Available Tools & Scripts

### System Monitoring
- **Stats** (Menu Bar): Real-time system metrics
- **htop**: Advanced process monitoring
- **swap-ssd-health.sh**: Automated health checks

### PDF Management
- **pdf-to-markdown-converter.sh**: Convert PDFs to markdown
- **pdf-watcher.sh**: Automatic PDF conversion on changes
- **create-digitalenv-backup.sh**: Create project backups

### Optimization Scripts
- **system-metrics-tracker.sh**: Track performance improvements
- **docker-optimize.sh**: Docker resource management
- **brew-cleanup.sh**: System cleanup

---

## 📈 Improvement Tracking

### Before vs After Comparison
$(if [ -f "$METRICS_DIR/baseline-metrics.json" ] && [ -f "$METRICS_DIR/current-metrics.json" ]; then
    echo "✅ Baseline and current metrics available"
    echo "Run: \`./metrics/system-metrics-tracker.sh compare\` to generate comparison"
else
    echo "⚠️  No baseline metrics found"
    echo "Run: \`./metrics/system-metrics-tracker.sh baseline\` to capture baseline"
fi)

### Recent Activity
$(if [ -f "$LOGS_DIR/pdf-watcher.log" ]; then
    echo "Recent PDF conversions:"
    tail -5 "$LOGS_DIR/pdf-watcher.log" | while read line; do
        echo "- $line"
    done
else
    echo "No recent activity logged"
fi)

---

## 🎯 Recommendations

$(if [ $memory_usage -ge 80 ]; then
    echo "- **Memory Management:** Consider closing unused applications"
fi)

$(if [ $cpu_usage -ge 70 ]; then
    echo "- **CPU Optimization:** Review background processes"
fi)

$(if [ $disk_usage -ge 85 ]; then
    echo "- **Disk Space:** Clean up unnecessary files"
fi)

$(if [ $conversion_rate -lt 100 ]; then
    echo "- **PDF Conversion:** Run \`./ops/backup/pdf-to-markdown-converter.sh all\` to convert remaining PDFs"
fi)

---

## 📋 Quick Actions

### System Health Check
\`\`\`bash
./ops/monitoring/swap-ssd-health.sh
\`\`\`

### Convert All PDFs
\`\`\`bash
./ops/backup/pdf-to-markdown-converter.sh all
\`\`\`

### Generate Performance Report
\`\`\`bash
./metrics/system-metrics-tracker.sh current
./metrics/system-metrics-tracker.sh compare
\`\`\`

### Start PDF Watcher
\`\`\`bash
./ops/backup/pdf-watcher.sh watch
\`\`\`

---

## 📁 File Locations

- **Dashboard:** $DASHBOARD_DIR/
- **Metrics:** $METRICS_DIR/
- **Converted PDFs:** $CONVERTED_DIR/
- **Logs:** $LOGS_DIR/
- **Documentation:** $DOCS_DIR/

---

**Dashboard Status:** ✅ **ACTIVE**  
**System Health:** $(if [ $memory_usage -lt 80 ] && [ $cpu_usage -lt 70 ] && [ $disk_usage -lt 85 ]; then echo "✅ GOOD"; else echo "⚠️  NEEDS ATTENTION"; fi)  
**PDF Conversion:** $(if [ $conversion_rate -eq 100 ]; then echo "✅ COMPLETE"; else echo "🔄 IN PROGRESS"; fi)
EOF
    
    echo -e "${GREEN}📊 Comprehensive dashboard created: $dashboard_file${NC}"
}

# Function to show real-time status
show_real_time_status() {
    echo -e "${BLUE}=== Real-Time System Status ===${NC}"
    
    local system_status=$(get_system_status)
    local memory_usage=$(echo "$system_status" | cut -d'|' -f1)
    local cpu_usage=$(echo "$system_status" | cut -d'|' -f2)
    local disk_usage=$(echo "$system_status" | cut -d'|' -f3)
    
    local pdf_stats=$(get_pdf_stats)
    local total_pdfs=$(echo "$pdf_stats" | cut -d'|' -f1)
    local converted_pdfs=$(echo "$pdf_stats" | cut -d'|' -f2)
    
    echo -e "Memory: ${memory_usage}% $(if [ $memory_usage -lt 80 ]; then echo "✅"; else echo "⚠️"; fi)"
    echo -e "CPU: ${cpu_usage}% $(if [ $cpu_usage -lt 70 ]; then echo "✅"; else echo "⚠️"; fi)"
    echo -e "Disk: ${disk_usage}% $(if [ $disk_usage -lt 85 ]; then echo "✅"; else echo "⚠️"; fi)"
    echo -e "PDFs: ${converted_pdfs}/${total_pdfs} converted"
}

# Main execution
case "${1:-dashboard}" in
    "dashboard")
        generate_comprehensive_dashboard
        ;;
    "status")
        show_real_time_status
        ;;
    "update")
        generate_comprehensive_dashboard
        show_real_time_status
        ;;
    *)
        echo "Usage: $0 [dashboard|status|update]"
        echo ""
        echo "Commands:"
        echo "  dashboard - Generate comprehensive dashboard"
        echo "  status    - Show real-time system status"
        echo "  update    - Update dashboard and show status"
        exit 1
        ;;
esac 