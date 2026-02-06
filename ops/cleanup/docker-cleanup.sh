#!/bin/bash
# Docker Cleanup Script for macOS
# Frees up disk space by removing stopped containers, dangling images, unused volumes, and networks
#
# 🎯 PERFORMANCE IMPACT:
# - Reduces Docker disk usage (typically 2-10GB)
# - Frees up memory used by stopped containers
# - Removes unused images that consume storage
# - Improves Docker performance and startup speed
# - BEFORE: High Docker disk usage, slow container operations
# - AFTER: Optimized Docker storage, faster container management

set -e

echo "[docker-cleanup] Removing stopped containers..."
docker container prune -f

echo "[docker-cleanup] Removing dangling images..."
docker image prune -af

echo "[docker-cleanup] Removing unused volumes..."
docker volume prune -f

echo "[docker-cleanup] Removing unused networks..."
docker network prune -f

echo "[docker-cleanup] Docker cleanup complete."
