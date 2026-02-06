#!/bin/bash
set -euo pipefail

# CPU Usage Check Script
# Returns CPU usage percentage for performance testing

# Get CPU usage percentage using a more reliable method
CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' | sed 's/[^0-9.]//g' | cut -d. -f1)

# Output the percentage (just the number)
echo "$CPU_USAGE"
