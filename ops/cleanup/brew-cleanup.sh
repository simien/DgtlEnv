#!/bin/bash
# Homebrew Cleanup Script for macOS
# Frees up disk space by removing old versions, cache, and unneeded packages
#
# 🎯 PERFORMANCE IMPACT:
# - Frees up significant disk space (typically 1-5GB)
# - Removes old package versions that consume storage
# - Clears Homebrew cache that accumulates over time
# - Improves Homebrew performance and update speed
# - BEFORE: Limited disk space, slow Homebrew operations
# - AFTER: More free space, faster package management

set -e

echo "[brew-cleanup] Cleaning up Homebrew..."
brew cleanup
brew autoremove

echo "[brew-cleanup] Homebrew cleanup complete."
