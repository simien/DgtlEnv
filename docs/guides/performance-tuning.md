# Performance Tuning & Optimization Guide

**Date:** 2026-01-03
**Status:** Initial Assessment

## 📊 System Assessment (2026-01-03)

### 1. High Swap Usage (75%)
- **Symptoms:** High swap usage (~4GB) and active pageouts.
- **Root Cause:** Memory pressure from multiple browser processes and background services, compounded by Spotlight indexing.
- **Top Memory Consumers:**
    - `Brave Browser Helper (Renderer)` (Multiple instances)
    - `Antigravity Helper (Renderer)`
    - `Dropbox`

### 2. High CPU Usage
- **Root Cause:**
    - `corespotlightd`: macOS Spotlight is indexing files. This is temporary but resource-intensive.
    - `Antigravity Agent`: Active during this analysis.

## 🛠️ Recommendations

### Immediate Actions
1.  **Reduce Browser Load:** Close unused tabs or windows in Brave to free up RAM.
2.  **Let Indexing Finish:** Allow `corespotlightd` to complete its work. Do not force kill it as it will just restart.
3.  **Restart:** A system restart can clear out accumulating swap usage.
