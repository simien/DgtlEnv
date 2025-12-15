#!/bin/bash

# Swap & SSD Health Check Script for MacBook Pro 2015
# Run this script periodically to monitor system health
#
# 🎯 PERFORMANCE IMPACT:
# - Prevents system slowdowns by detecting high swap usage
# - Identifies SSD health issues before data loss
# - Monitors memory pressure and provides early warnings
# - Helps maintain optimal system performance
# - BEFORE: System lag, high swap activity, potential data loss
# - AFTER: Proactive monitoring, early warning system, optimal performance

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

LOG_DIR="$HOME/Library/Logs"
LOG_FILE="$LOG_DIR/swap-ssd-health.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Ensure log directory exists
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR" 2>/dev/null || {
        # Fallback to current directory if can't create in Library
        LOG_DIR="."
        LOG_FILE="./swap-ssd-health.log"
    }
fi

# Helper function for logging
# Usage: log "Message" [COLOR]
log() {
    local message="$1"
    local color="${2:-$RESET}"

    # Print to console with color
    echo -e "${color}${message}${RESET}"

    # Strip color codes for log file
    echo "$message" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

log "=== Swap & SSD Health Check - $DATE ===" "$BOLD$BLUE"

# Check Swap Usage
log "--- Swap Usage ---" "$BOLD"

if command -v sysctl &> /dev/null; then
    SWAP_INFO=$(sysctl vm.swapusage 2>/dev/null)
    log "$SWAP_INFO"

    # Extract swap usage values efficiently using awk
    # vm.swapusage: total = 1024.00M  used = 512.50M ...
    # awk gets fields $4 (total) and $7 (used)
    read -r TOTAL_SWAP USED_SWAP <<< $(echo "$SWAP_INFO" | awk '{
        gsub(/M/,"",$4); gsub(/\..*/,"",$4);
        gsub(/M/,"",$7); gsub(/\..*/,"",$7);
        print $4, $7
    }')

    # Check if swap usage is high (>50% of total)
    if [ ! -z "$TOTAL_SWAP" ] && [ ! -z "$USED_SWAP" ] && [ "$TOTAL_SWAP" -gt 0 ]; then
        SWAP_PERCENT=$((USED_SWAP * 100 / TOTAL_SWAP))
        if [ $SWAP_PERCENT -gt 50 ]; then
            log "⚠️  WARNING: High swap usage detected ($SWAP_PERCENT%)" "$YELLOW"
            log "   Consider closing unused apps or adding more RAM"
        else
            log "✅ Swap usage is normal ($SWAP_PERCENT%)" "$GREEN"
        fi
    else
        log "ℹ️  Swap usage info not parsable or swap is 0"
    fi
else
    log "ℹ️  sysctl not available (not on macOS?)" "$YELLOW"
fi

# Check Pageouts (indicates active swapping)
log "--- Pageouts (Active Swapping) ---" "$BOLD"

if command -v vm_stat &> /dev/null; then
    # Case-insensitive grep matching for 'Pageouts' or 'pageouts'
    # Use awk to handle parsing cleanly
    PAGEOUTS=$(vm_stat | grep -i 'pageouts' | awk '{print $2}' | sed 's/\.//')
    if [ ! -z "$PAGEOUTS" ] && [ $PAGEOUTS -gt 0 ]; then
        log "⚠️  WARNING: Active swapping detected ($PAGEOUTS pageouts)" "$YELLOW"
        log "   System is using disk as virtual memory"
    else
        log "✅ No active swapping detected" "$GREEN"
    fi
else
    log "ℹ️  vm_stat not available" "$YELLOW"
fi

# Check SSD SMART Status
log "--- SSD Health ---" "$BOLD"

# Basic SMART status
if command -v diskutil &> /dev/null; then
    # diskutil output has "SMART Status: Verified"
    SMART_STATUS=$(diskutil info disk0 | awk '/SMART Status/ {print $3}')
    if [ ! -z "$SMART_STATUS" ]; then
        log "SMART Status: $SMART_STATUS"

        if [ "$SMART_STATUS" != "Verified" ]; then
            log "⚠️  WARNING: SSD SMART status is not verified" "$YELLOW"
        else
            log "✅ SSD SMART status is verified" "$GREEN"
        fi
    else
        log "ℹ️  Could not retrieve SMART status via diskutil" "$YELLOW"
    fi
else
    log "ℹ️  diskutil not available" "$YELLOW"
fi

# Detailed SSD health (if smartctl is available)
if command -v smartctl &> /dev/null; then
    log "--- Detailed SSD Health ---" "$BOLD"

    # Get SSD wear indicators
    SMART_OUTPUT=$(sudo smartctl -a disk0 2>/dev/null)

    # Parse SMART attributes efficiently
    # We want Wear_Leveling_Count (173), Reallocated_Sector_Ct (5), Media_Wearout_Indicator (169)
    # The output format is: ID# ATTRIBUTE_NAME FLAG VALUE WORST THRESH TYPE UPDATED WHEN_FAILED RAW_VALUE

    # We use awk to parse everything in one pass
    # Output format: WEAR_COUNT REALLOCATED MEDIA_WEAR
    # Use -1 or N/A for missing values to ensure column alignment
    read -r WEAR_COUNT REALLOCATED MEDIA_WEAR <<< $(echo "$SMART_OUTPUT" | awk '
        /Wear_Leveling_Count/ { wc = $10 }
        /Reallocated_Sector_Ct/ { rs = $10 }
        /Media_Wearout_Indicator/ { mw = $10 }
        END {
            print (wc != "" ? wc : "NA"), (rs != "" ? rs : "NA"), (mw != "" ? mw : "NA")
        }
    ')

    if [ "$WEAR_COUNT" != "NA" ]; then
        log "Wear Leveling Count: $WEAR_COUNT"
        if [ $WEAR_COUNT -lt 10 ]; then
            log "⚠️  WARNING: SSD wear leveling count is low" "$YELLOW"
        fi
    fi

    if [ "$REALLOCATED" != "NA" ] && [ $REALLOCATED -gt 0 ]; then
        log "⚠️  WARNING: Reallocated sectors detected ($REALLOCATED)" "$YELLOW"
    fi

    if [ "$MEDIA_WEAR" != "NA" ]; then
        log "Media Wearout Indicator: $MEDIA_WEAR"
        if [ $MEDIA_WEAR -lt 10 ]; then
            log "⚠️  WARNING: SSD media wearout indicator is low" "$YELLOW"
        fi
    fi
else
    log "ℹ️  smartctl not available - install with: brew install smartmontools" "$YELLOW"
fi

log "--- End of Health Check ---" "$BOLD$BLUE"
log ""

# Optional: Send notification if warnings were found
if [ -f "$LOG_FILE" ] && grep -q "WARNING" "$LOG_FILE"; then
    if command -v osascript &> /dev/null; then
        # Send macOS notification
        osascript -e 'display notification "System health issues detected. Check logs for details." with title "Swap & SSD Health Check"'
    fi
fi
