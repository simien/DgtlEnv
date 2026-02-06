#!/bin/bash
set -euo pipefail

# Docker Optimization Script for MacBook Pro 2015
# Handles cleanup, resource monitoring, and Colima setup
#
# 🎯 PERFORMANCE IMPACT:
# - Prevents Docker from consuming all system resources
# - Sets up Colima with optimal resource limits
# - Monitors Docker resource usage and provides warnings
# - Optimizes container performance for development
# - BEFORE: Docker resource hogging, slow system performance
# - AFTER: Controlled Docker resources, optimal system performance

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/docker/docker-optimize.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== Docker Optimization - $DATE ===" | tee -a "$LOG_FILE"

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker is not running or not accessible" | tee -a "$LOG_FILE"
        return 1
    fi
    echo "✅ Docker is running" | tee -a "$LOG_FILE"
    return 0
}

# Function to check Docker resource usage
check_docker_usage() {
    echo "--- Docker Resource Usage ---" | tee -a "$LOG_FILE"

    # Check disk usage
    echo "Disk Usage:" | tee -a "$LOG_FILE"
    docker system df | tee -a "$LOG_FILE"

    # Check running containers
    RUNNING_CONTAINERS=$(docker ps -q | wc -l)
    echo "Running containers: $RUNNING_CONTAINERS" | tee -a "$LOG_FILE"

    if [ $RUNNING_CONTAINERS -gt 3 ]; then
        echo "⚠️  WARNING: Many containers running ($RUNNING_CONTAINERS)" | tee -a "$LOG_FILE"
        echo "   Consider stopping unused containers" | tee -a "$LOG_FILE"
    fi
}

# Function to perform Docker cleanup
cleanup_docker() {
    echo "--- Docker Cleanup ---" | tee -a "$LOG_FILE"

    # Remove stopped containers
    STOPPED_CONTAINERS=$(docker container ls -a -q -f status=exited | wc -l)
    if [ $STOPPED_CONTAINERS -gt 0 ]; then
        echo "Removing $STOPPED_CONTAINERS stopped containers..." | tee -a "$LOG_FILE"
        docker container prune -f | tee -a "$LOG_FILE"
    fi

    # Remove unused images
    UNUSED_IMAGES=$(docker images -q -f dangling=true | wc -l)
    if [ $UNUSED_IMAGES -gt 0 ]; then
        echo "Removing $UNUSED_IMAGES unused images..." | tee -a "$LOG_FILE"
        docker image prune -f | tee -a "$LOG_FILE"
    fi

    # Remove unused volumes
    UNUSED_VOLUMES=$(docker volume ls -q -f dangling=true | wc -l)
    if [ $UNUSED_VOLUMES -gt 0 ]; then
        echo "Removing $UNUSED_VOLUMES unused volumes..." | tee -a "$LOG_FILE"
        docker volume prune -f | tee -a "$LOG_FILE"
    fi

    # Remove unused networks
    UNUSED_NETWORKS=$(docker network ls -q -f dangling=true | wc -l)
    if [ $UNUSED_NETWORKS -gt 0 ]; then
        echo "Removing $UNUSED_NETWORKS unused networks..." | tee -a "$LOG_FILE"
        docker network prune -f | tee -a "$LOG_FILE"
    fi

    echo "✅ Docker cleanup completed" | tee -a "$LOG_FILE"
}

# Function to check Colima status
check_colima() {
    if command -v colima &> /dev/null; then
        echo "--- Colima Status ---" | tee -a "$LOG_FILE"
        colima status | tee -a "$LOG_FILE"
    else
        echo "ℹ️  Colima not installed" | tee -a "$LOG_FILE"
        echo "   Install with: brew install colima" | tee -a "$LOG_FILE"
    fi
}

# Function to setup Colima (if requested)
setup_colima() {
    if command -v colima &> /dev/null; then
        echo "--- Setting up Colima ---" | tee -a "$LOG_FILE"

        # Check if Colima is already running
        if colima status | grep -q "RUNNING"; then
            echo "✅ Colima is already running" | tee -a "$LOG_FILE"
        else
            echo "Starting Colima with resource limits..." | tee -a "$LOG_FILE"
            colima start --cpu 2 --memory 2048 --disk 20 | tee -a "$LOG_FILE"
            echo "✅ Colima started successfully" | tee -a "$LOG_FILE"
        fi
    else
        echo "❌ Colima not installed. Install with: brew install colima" | tee -a "$LOG_FILE"
    fi
}

# Main execution
echo "Starting Docker optimization..." | tee -a "$LOG_FILE"

# Check Docker status
if check_docker; then
    # Check current usage
    check_docker_usage

    # Perform cleanup
    cleanup_docker

    # Check Colima
    check_colima

    # Ask about Colima setup
    echo ""
    read -p "Would you like to setup Colima for lighter Docker usage? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_colima
    fi
else
    echo "❌ Cannot proceed without Docker running" | tee -a "$LOG_FILE"
fi

echo "--- End of Docker Optimization ---" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
