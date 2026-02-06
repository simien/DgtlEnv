# cleanup/

Scripts for cleaning up system resources to maintain optimal performance and free up disk space.

## Scripts
- `brew-cleanup.sh` — Cleans up Homebrew cache, old versions, and unneeded packages.
- `docker-cleanup.sh` — Removes stopped containers, dangling images, unused volumes, and networks.

## Usage
- Make scripts executable: `chmod +x scriptname.sh`
- Run with `./brew-cleanup.sh` or `./docker-cleanup.sh`

## Integration with Optimization System

### Automated Cleanup
These scripts are part of the comprehensive optimization system and should be run regularly:

### Monthly Cleanup Schedule
```bash
# 1. Homebrew cleanup
./cleanup/brew-cleanup.sh

# 2. Docker cleanup
./cleanup/docker-cleanup.sh

# 3. Review results and free space
```

### Weekly Health Monitoring
```bash
# System health check (includes resource monitoring)
../monitoring/swap-ssd-health.sh

# Quick resource overview
../monitoring/top-hogs.sh
```

## Script Details

### brew-cleanup.sh
- Removes old Homebrew formulae and cached downloads
- Frees up significant disk space
- Safe to run regularly
- Output: Terminal confirmation of cleanup actions

### docker-cleanup.sh
- Removes stopped containers
- Cleans up dangling images
- Removes unused volumes and networks
- Safe to run regularly
- Output: Terminal confirmation of cleanup actions

## Best Practices

### When to Run Cleanup
- **Weekly**: Monitor resource usage with health checks
- **Monthly**: Run full cleanup scripts
- **As needed**: When disk space is low or performance degrades

### Before Running
- Ensure no critical containers are running (for Docker cleanup)
- Backup important data if needed
- Check available disk space

### After Running
- Verify system performance improvement
- Check available disk space
- Review any warnings or errors

## Troubleshooting

### Common Issues
- **Permission errors**: Ensure scripts are executable (`chmod +x`)
- **Docker not running**: Start Docker before running docker-cleanup.sh
- **Homebrew not found**: Install Homebrew if not already installed

### Performance Impact
- **Disk space**: Significant space freed up
- **System performance**: Improved after cleanup
- **Docker performance**: Faster container operations

## Integration with Other Tools

### Monitoring Integration
- Use `../monitoring/swap-ssd-health.sh` to monitor cleanup impact
- Check `../monitoring/top-hogs.sh` for resource usage before/after
- Review Stats menu bar for real-time metrics

### Docker Optimization
- Run `../docker/docker-optimize.sh` for comprehensive Docker optimization
- Includes cleanup plus Colima setup options

### Documentation
- Use `../templates/optimization-summary-template.md` to document cleanup results
- Track disk space improvements over time 
## 📁 Contents

### **Files**
- `brew-cleanup.sh` - [Description of purpose]
- `docker-cleanup.sh` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
