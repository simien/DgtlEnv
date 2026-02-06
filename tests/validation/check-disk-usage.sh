#!/bin/bash
set -euo pipefail

# Disk Usage Check Script
# Returns disk usage percentage for performance testing

# Get disk usage percentage for the current directory
DISK_USAGE=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')

# Output the percentage (just the number)
echo "$DISK_USAGE"
