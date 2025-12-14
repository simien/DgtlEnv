#!/bin/bash

# System Metrics Tracker
# Tracks system performance improvements and creates visual dashboards
#
# 🎯 PERFORMANCE IMPACT:
# - Tracks before/after optimization metrics
# - Provides visual proof of performance improvements
# - Helps identify optimization opportunities
# - Creates dashboards showing real performance gains
# - BEFORE: No visibility into system performance trends
# - AFTER: Clear metrics showing optimization effectiveness

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METRICS_DIR="$PROJECT_ROOT/metrics"
LOGS_DIR="$PROJECT_ROOT/logs"
DASHBOARD_DIR="$METRICS_DIR/dashboards"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "$METRICS_DIR"
mkdir -p "$LOGS_DIR"
mkdir -p "$DASHBOARD_DIR"

# Function to get current system metrics
get_system_metrics() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Memory usage
    # Optimize: Parse vm_stat once instead of multiple grep/awk calls
    local memory_vars=$(vm_stat | awk '
        /Pages free/ { printf "local free_memory=%s;", $3 }
        /Pages active/ { printf "local active_memory=%s;", $3 }
        /Pages inactive/ { printf "local inactive_memory=%s;", $3 }
        /Pages wired down/ { printf "local wired_memory=%s;", $4 }
    ' | tr -d '.')

    local free_memory active_memory inactive_memory wired_memory
    eval "$memory_vars"

    local total_memory=$(sysctl -n hw.memsize | awk '{print $0/1024/1024/1024}')

    # Convert to MB
    local page_size=4096
    local free_mb=$((free_memory * page_size / 1024 / 1024))
    local active_mb=$((active_memory * page_size / 1024 / 1024))
    local inactive_mb=$((inactive_memory * page_size / 1024 / 1024))
    local wired_mb=$((wired_memory * page_size / 1024 / 1024))
    local used_mb=$((active_mb + wired_mb))
    local total_mb=$(echo "$total_memory * 1024" | bc -l | cut -d. -f1)

    # CPU usage
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')

    # Swap usage
    local swap_info=$(vm_stat | grep "Swapouts")
    local swapouts=$(echo "$swap_info" | awk '{print $2}' | sed 's/\.//')

    # Disk usage
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')

    # Temperature (if available)
    local temperature=$(sudo powermetrics -n 1 -i 1000 | grep "CPU die temperature" | awk '{print $4}' | head -1 || echo "N/A")

    # Create metrics JSON
    cat > "$METRICS_DIR/current-metrics.json" << EOF
{
  "timestamp": "$timestamp",
  "memory": {
    "total_mb": $total_mb,
    "used_mb": $used_mb,
    "free_mb": $free_mb,
    "active_mb": $active_mb,
    "inactive_mb": $inactive_mb,
    "wired_mb": $wired_mb,
    "usage_percent": $((used_mb * 100 / total_mb))
  },
  "cpu": {
    "usage_percent": $cpu_usage
  },
  "swap": {
    "swapouts": $swapouts
  },
  "disk": {
    "usage_percent": $disk_usage
  },
  "temperature": "$temperature"
}
EOF

    echo "$METRICS_DIR/current-metrics.json"
}

# Function to create before/after comparison
create_comparison() {
    local before_file="$1"
    local after_file="$2"
    local comparison_file="$DASHBOARD_DIR/before-after-comparison.md"

    if [ ! -f "$before_file" ] || [ ! -f "$after_file" ]; then
        echo -e "${RED}Error: Before and after metrics files not found${NC}"
        return 1
    fi

    local before_timestamp=$(jq -r '.timestamp' "$before_file")
    local after_timestamp=$(jq -r '.timestamp' "$after_file")

    # Extract metrics
    local before_memory_usage=$(jq -r '.memory.usage_percent' "$before_file")
    local after_memory_usage=$(jq -r '.memory.usage_percent' "$after_file")
    local before_cpu_usage=$(jq -r '.cpu.usage_percent' "$before_file")
    local after_cpu_usage=$(jq -r '.cpu.usage_percent' "$after_file")
    local before_swapouts=$(jq -r '.swap.swapouts' "$before_file")
    local after_swapouts=$(jq -r '.swap.swapouts' "$after_file")
    local before_disk_usage=$(jq -r '.disk.usage_percent' "$before_file")
    local after_disk_usage=$(jq -r '.disk.usage_percent' "$after_file")

    # Calculate improvements
    local memory_improvement=$((before_memory_usage - after_memory_usage))
    local cpu_improvement=$((before_cpu_usage - after_cpu_usage))
    local swap_improvement=$((before_swapouts - after_swapouts))
    local disk_improvement=$((before_disk_usage - after_disk_usage))

    # Create comparison dashboard
    cat > "$comparison_file" << EOF
# System Performance Comparison

**Before Optimization:** ${before_timestamp}
**After Optimization:** ${after_timestamp}
**Analysis Date:** $(date '+%Y-%m-%d %H:%M:%S')

---

## 📊 Performance Metrics Comparison

### Memory Usage
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Memory Usage | ${before_memory_usage}% | ${after_memory_usage}% | ${memory_improvement}% |
| Status | $(if [ $memory_improvement -gt 0 ]; then echo "✅ Improved"; else echo "⚠️  Increased"; fi) |

### CPU Usage
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| CPU Usage | ${before_cpu_usage}% | ${after_cpu_usage}% | ${cpu_improvement}% |
| Status | $(if [ $cpu_improvement -gt 0 ]; then echo "✅ Improved"; else echo "⚠️  Increased"; fi) |

### Swap Activity
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Swapouts | ${before_swapouts} | ${after_swapouts} | ${swap_improvement} |
| Status | $(if [ $swap_improvement -gt 0 ]; then echo "✅ Improved"; else echo "⚠️  Increased"; fi) |

### Disk Usage
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Disk Usage | ${before_disk_usage}% | ${after_disk_usage}% | ${disk_improvement}% |
| Status | $(if [ $disk_improvement -gt 0 ]; then echo "✅ Improved"; else echo "⚠️  Increased"; fi) |

---

## 📈 Improvement Summary

$(if [ $memory_improvement -gt 0 ] || [ $cpu_improvement -gt 0 ] || [ $swap_improvement -gt 0 ] || [ $disk_improvement -gt 0 ]; then
    echo "### ✅ Positive Improvements"
    [ $memory_improvement -gt 0 ] && echo "- Memory usage reduced by ${memory_improvement}%"
    [ $cpu_improvement -gt 0 ] && echo "- CPU usage reduced by ${cpu_improvement}%"
    [ $swap_improvement -gt 0 ] && echo "- Swap activity reduced by ${swap_improvement} operations"
    [ $disk_improvement -gt 0 ] && echo "- Disk usage reduced by ${disk_improvement}%"
else
    echo "### ⚠️  No Improvements Detected"
    echo "Consider reviewing optimization strategies or running additional tests."
fi)

---

## 🎯 Recommendations

$(if [ $memory_improvement -lt 0 ]; then
    echo "- **Memory Management:** Consider closing unused applications or adding more RAM"
fi)

$(if [ $cpu_improvement -lt 0 ]; then
    echo "- **CPU Optimization:** Review background processes and consider disabling heavy services"
fi)

$(if [ $swap_improvement -lt 0 ]; then
    echo "- **Swap Management:** High swap activity indicates memory pressure. Consider memory upgrades"
fi)

$(if [ $disk_improvement -lt 0 ]; then
    echo "- **Disk Space:** Consider cleaning up unnecessary files or upgrading storage"
fi)

---

## 📋 Detailed Metrics

### Before Optimization (${before_timestamp})
\`\`\`json
$(cat "$before_file")
\`\`\`

### After Optimization (${after_timestamp})
\`\`\`json
$(cat "$after_file")
\`\`\`
EOF

    echo -e "${GREEN}📊 Comparison dashboard created: $comparison_file${NC}"
}

# Function to create visual progress chart
create_progress_chart() {
    local metrics_file="$1"
    local chart_file="$DASHBOARD_DIR/progress-chart.md"

    if [ ! -f "$metrics_file" ]; then
        echo -e "${RED}Error: Metrics file not found${NC}"
        return 1
    fi

    local memory_usage=$(jq -r '.memory.usage_percent' "$metrics_file")
    local cpu_usage=$(jq -r '.cpu.usage_percent' "$metrics_file")
    local disk_usage=$(jq -r '.disk.usage_percent' "$metrics_file")

    # Create visual progress bars
    local memory_bar=$(create_progress_bar $memory_usage)
    local cpu_bar=$(create_progress_bar $cpu_usage)
    local disk_bar=$(create_progress_bar $disk_usage)

    cat > "$chart_file" << EOF
# System Performance Progress Chart

**Last Updated:** $(date '+%Y-%m-%d %H:%M:%S')

---

## 📊 Current System Status

### Memory Usage: ${memory_usage}%
\`\`\`
${memory_bar}
\`\`\`

### CPU Usage: ${cpu_usage}%
\`\`\`
${cpu_bar}
\`\`\`

### Disk Usage: ${disk_usage}%
\`\`\`
${disk_bar}
\`\`\`

---

## 🎯 Performance Targets

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Memory | ${memory_usage}% | < 80% | $(if [ $memory_usage -lt 80 ]; then echo "✅ Good"; else echo "⚠️  High"; fi) |
| CPU | ${cpu_usage}% | < 70% | $(if [ $cpu_usage -lt 70 ]; then echo "✅ Good"; else echo "⚠️  High"; fi) |
| Disk | ${disk_usage}% | < 85% | $(if [ $disk_usage -lt 85 ]; then echo "✅ Good"; else echo "⚠️  High"; fi) |

---

## 📈 Trend Analysis

$(if [ $memory_usage -lt 80 ] && [ $cpu_usage -lt 70 ] && [ $disk_usage -lt 85 ]; then
    echo "### ✅ System Performance is Optimal"
    echo "All metrics are within target ranges. Continue current optimization practices."
elif [ $memory_usage -ge 80 ] || [ $cpu_usage -ge 70 ] || [ $disk_usage -ge 85 ]; then
    echo "### ⚠️  Performance Improvements Needed"
    [ $memory_usage -ge 80 ] && echo "- Memory usage is high. Consider closing unused applications."
    [ $cpu_usage -ge 70 ] && echo "- CPU usage is high. Review background processes."
    [ $disk_usage -ge 85 ] && echo "- Disk usage is high. Clean up unnecessary files."
fi)
EOF

    echo -e "${GREEN}📈 Progress chart created: $chart_file${NC}"
}

# Function to create progress bar
create_progress_bar() {
    local percentage="$1"
    local width=50
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))

    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
}

# Function to capture baseline metrics
capture_baseline() {
    echo -e "${BLUE}Capturing baseline system metrics...${NC}"
    local baseline_file=$(get_system_metrics)
    mv "$baseline_file" "$METRICS_DIR/baseline-metrics.json"
    echo -e "${GREEN}✅ Baseline captured: $METRICS_DIR/baseline-metrics.json${NC}"
}

# Function to capture current metrics
capture_current() {
    echo -e "${BLUE}Capturing current system metrics...${NC}"
    local current_file=$(get_system_metrics)
    mv "$current_file" "$METRICS_DIR/current-metrics.json"
    echo -e "${GREEN}✅ Current metrics captured: $METRICS_DIR/current-metrics.json${NC}"
}

# Function to generate all reports
generate_reports() {
    echo -e "${BLUE}Generating performance reports...${NC}"

    if [ -f "$METRICS_DIR/baseline-metrics.json" ] && [ -f "$METRICS_DIR/current-metrics.json" ]; then
        create_comparison "$METRICS_DIR/baseline-metrics.json" "$METRICS_DIR/current-metrics.json"
    fi

    if [ -f "$METRICS_DIR/current-metrics.json" ]; then
        create_progress_chart "$METRICS_DIR/current-metrics.json"
    fi

    echo -e "${GREEN}✅ All reports generated in $DASHBOARD_DIR${NC}"
}

# Main execution
case "${1:-help}" in
    "baseline")
        capture_baseline
        ;;
    "current")
        capture_current
        ;;
    "compare")
        generate_reports
        ;;
    "full")
        capture_baseline
        sleep 5
        capture_current
        generate_reports
        ;;
    "chart")
        if [ -f "$METRICS_DIR/current-metrics.json" ]; then
            create_progress_chart "$METRICS_DIR/current-metrics.json"
        else
            echo -e "${YELLOW}No current metrics found. Run 'current' first.${NC}"
        fi
        ;;
    *)
        echo "Usage: $0 [baseline|current|compare|full|chart]"
        echo ""
        echo "Commands:"
        echo "  baseline - Capture baseline system metrics"
        echo "  current  - Capture current system metrics"
        echo "  compare  - Generate before/after comparison"
        echo "  full     - Capture baseline, wait, capture current, and compare"
        echo "  chart    - Create visual progress chart"
        echo ""
        echo "Example workflow:"
        echo "  1. $0 baseline    # Capture initial state"
        echo "  2. [run optimizations]"
        echo "  3. $0 current     # Capture optimized state"
        echo "  4. $0 compare     # Generate comparison report"
        exit 1
        ;;
esac
