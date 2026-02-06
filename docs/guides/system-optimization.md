# System Optimization Guide

**Device:** MacBook Pro (Retina, 15-inch, Mid 2015)
**OS:** macOS 12.7.6 Monterey
**Status:** ✅ Comprehensive optimization guide

---

## 🎯 Overview

This guide provides comprehensive system optimization strategies for macOS development environments, specifically tailored for MacBook Pro 2015 hardware running Cursor IDE, Docker, and development tools.

---

## 💻 Hardware Profile

### System Specifications
- **Processor:** Intel Core i7 (2.2 GHz quad-core)
- **Memory:** 16GB DDR3
- **Storage:** 256GB SSD
- **Graphics:** Intel Iris Pro + AMD Radeon R9 M370X
- **Display:** 2880 x 1800 Retina display

### Development Environment
- **Primary IDE:** Cursor IDE
- **Containerization:** Docker Desktop / Colima
- **Key Tools:** Web browsers, file syncing services, background tasks

---

## 🔧 Cursor IDE Optimization

### 1. Extension Management

#### How to Identify and Disable Resource-Heavy Extensions

**Step-by-Step Process:**

1. **Open Extensions Sidebar**
   - Press `Cmd + Shift + X` or click Extensions icon in Activity Bar

2. **Review Installed Extensions**
   - Look for extensions you don't use regularly
   - Identify extensions you don't recognize

3. **Identify Resource-Heavy Extensions**
   - Language servers for unused languages
   - Docker, Python, or Java packs (if not needed)
   - Live Share, Prettier, or large linters
   - Right-click extension → **Extension Settings** to review resource usage

4. **Disable Unused Extensions**
   - Right-click extension → **Disable** (workspace or globally)
   - Disabled extensions appear grayed out

5. **Uninstall Unnecessary Extensions**
   - Right-click → **Uninstall** for extensions you never use

6. **Restart Cursor IDE**
   - Restart to ensure changes take effect

7. **Monitor Performance**
   - If still slow, disable more extensions
   - Re-enable extensions as needed

#### Pro Tips
- Keep only extensions you use regularly
- Enable/disable extensions per workspace
- Periodically review extensions list
- Monitor memory usage after changes

### 2. Performance Settings

#### Optimized Cursor Settings
```json
{
  "workbench.colorTheme": "Default Dark Modern",
  "files.watcherExclude": {
    "**/node_modules/*": true,
    "**/build/*": true,
    "**/.git/objects/**": true,
    "**/.dropbox/**": true,
    "**/logs/**": true,
    "**/metrics/data/**": true
  },
  "typescript.tsserver.maxTsServerMemory": 2048,
  "files.maxMemoryForLargeFilesMB": 64,
  "editor.largeFileOptimizations": true
}
```

#### Key Optimizations
- **File Watcher Exclusions:** Reduces CPU usage
- **TypeScript Server Memory:** Increased to 2048MB
- **Large File Optimizations:** Better handling of large files
- **Search Exclusions:** Faster search performance

---

## 🐳 Docker/Container Optimization

### 1. Resource Management

#### Docker Desktop Settings
- **Memory Limit:** 2GB for containers
- **CPU Limit:** 2 cores for containers
- **Storage Driver:** Overlay2 (default)
- **Image Cleanup:** Regular cleanup of unused images

#### Colima Alternative
For lighter Docker usage:
```bash
# Install Colima
brew install colima

# Start Colima with resource limits
colima start --cpu 2 --memory 2 --disk 10
```

### 2. Container Best Practices
- Set resource limits for all containers
- Use multi-stage builds to reduce image size
- Regular cleanup of unused images and volumes
- Monitor disk space usage

---

## 🖥️ System-Level Optimizations

### 1. Resource Management

#### Memory Allocation Strategies
- **Cursor IDE:** 2-4GB RAM allocation
- **Docker:** 2GB RAM limit
- **Browsers:** 1-2GB per browser
- **System:** 4-6GB for OS and other apps

#### CPU Priority Management
- Development tools get higher priority
- Background services run at lower priority
- Monitor CPU usage with Activity Monitor

### 2. Disk Space Optimization

#### SSD Health Preservation
- Monitor SMART status regularly
- Avoid excessive swap usage
- Regular cleanup of temporary files
- Use external storage for large files

#### Docker Image Management
```bash
# Regular cleanup commands
docker system prune -a
docker image prune -a
docker volume prune
```

### 3. macOS Monterey Optimizations

#### Background App Management
- Disable unnecessary startup items
- Manage background app refresh
- Optimize Spotlight indexing
- Configure Time Machine exclusions

#### File System Optimizations
- APFS optimization for development
- Exclude development folders from Spotlight
- Optimize Dropbox sync settings
- Configure iCloud exclusions

---

## 📊 Monitoring and Maintenance

### 1. System Monitoring Tools

#### Installed Tools
- **Stats** (v2.11.48) - Menu bar system monitor
- **htop** (v3.4.1) - Advanced process monitoring
- **smartmontools** (v7.5) - SSD health monitoring

#### Automated Scripts
```bash
# Health check script
./ops/monitoring/swap-ssd-health.sh

# Docker optimization
./ops/docker/docker-optimize.sh
```

### 2. Performance Monitoring

#### Key Metrics to Track
- **Memory Usage:** Target < 80% of 16GB
- **CPU Usage:** Target < 70% during development
- **Swap Usage:** Minimize to preserve SSD
- **SSD Health:** Monitor SMART status
- **Disk Space:** Maintain > 20% free space

#### Alert Thresholds
- Memory usage > 80%
- Swap usage > 500MB
- CPU usage > 80% sustained
- Disk space < 20%

---

## 🚀 Quick Optimization Checklist

### Immediate Actions (Today)
- [ ] Disable unused Cursor extensions
- [ ] Apply optimized Cursor settings
- [ ] Set Docker resource limits
- [ ] Install monitoring tools
- [ ] Configure file watcher exclusions

### Weekly Maintenance
- [ ] Run system health checks
- [ ] Clean up Docker images
- [ ] Review extension usage
- [ ] Monitor SSD health
- [ ] Update optimization settings

### Monthly Review
- [ ] Assess performance improvements
- [ ] Review resource allocation
- [ ] Update optimization strategies
- [ ] Check for new optimization tools

---

## 🔧 Troubleshooting

### Common Issues

#### High Memory Usage
1. Check Cursor IDE memory usage
2. Review Docker container limits
3. Disable unnecessary browser tabs
4. Monitor background processes

#### Slow Cursor IDE
1. Disable heavy extensions
2. Increase TypeScript server memory
3. Exclude large folders from file watching
4. Restart Cursor IDE

#### Docker Performance Issues
1. Reduce container resource limits
2. Switch to Colima for lighter usage
3. Clean up unused images
4. Monitor disk space usage

#### Thermal Throttling
1. Monitor CPU temperature
2. Reduce concurrent workloads
3. Optimize fan settings
4. Use external cooling if needed

---

## 📈 Performance Results

### Before Optimization
- High swap usage (315MB/2048MB)
- Unoptimized Cursor IDE settings
- No systematic resource monitoring
- Unmanaged Docker resource usage

### After Optimization
- ✅ Comprehensive system monitoring
- ✅ Optimized Cursor IDE performance
- ✅ Automated health checks
- ✅ Docker resource management
- ✅ SSD health monitoring

### Key Improvements
- **Swap Usage:** Now monitored and managed
- **SSD Health:** SMART status verified, wear tracking enabled
- **Memory Management:** Real-time monitoring with alerts
- **Development Experience:** Faster IDE response times
- **System Stability:** Reduced thermal throttling

---

## 🔗 Related Documentation

- See `../setup/hardware-specs/` for hardware specifications
- See `../workflows/` for operational procedures
- See `../reports/` for performance analysis
- See `../style/` for visual optimization guides

---

**Last Updated:** 2025-07-27
**Maintainer:** DgtlEnv Maintainer
**Status:** ✅ Complete and tested
