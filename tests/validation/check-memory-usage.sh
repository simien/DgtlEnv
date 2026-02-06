#!/bin/bash
set -euo pipefail

# Memory Usage Check Script
# Returns memory usage percentage for performance testing

# Get memory usage percentage
MEMORY_USAGE=$(top -l 1 | grep "PhysMem" | awk '{print $2}' | sed 's/%//' | sed 's/[^0-9]//g')

# Output the percentage (just the number)
echo "$MEMORY_USAGE"
