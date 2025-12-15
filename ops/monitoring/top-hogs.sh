#!/bin/bash
# Top Resource Hogs Script for macOS
# Shows top CPU and memory consuming processes

set -e

# ANSI Color Codes
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BLUE}${BOLD}[top-hogs] Top 10 CPU-consuming processes:${RESET}"
ps aux | awk 'NR==1 {print; next} {print | "sort -nrk 3 | head -n 10"}'

echo -e "\n${BLUE}${BOLD}[top-hogs] Top 10 Memory-consuming processes:${RESET}"
ps aux | awk 'NR==1 {print; next} {print | "sort -nrk 4 | head -n 10"}'
