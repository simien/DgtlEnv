# monitoring/

Scripts and helpers for monitoring system performance, resource usage, and early warning for resource exhaustion.

## Scripts
- `swap-ssd-health.sh` — Comprehensive system health monitoring (swap usage, SSD health, SMART status)
- `top-hogs.sh` — Quick script to show top CPU and memory consuming processes

## Usage
- Make scripts executable: `chmod +x scriptname.sh`
- Run with `./swap-ssd-health.sh` (interactive mode prompts for password for full stats)
- Automated usage: `./swap-ssd-health.sh` (skips password-protected checks if non-interactive)

## Installed Monitoring Tools

### Real-time Monitoring
- **Stats** (v2.11.48) — Menu bar system monitor
  - Location: Applications folder
  - Access: Click menu bar icon for detailed metrics
  - Monitors: CPU, Memory, Disk, Network usage

- **htop** (v3.4.1) — Advanced process monitoring
  - Command: `sudo htop`
  - Controls: Arrow keys, F6 (sort), F9 (kill), F10 (quit)
  - Features: Interactive process list with resource usage

### Health Monitoring
- **smartmontools** (v7.5) — SSD health monitoring
  - Command: `sudo smartctl -a disk0`
  - Monitors: SMART status, wear indicators, reallocated sectors

## Monitoring Swap Usage & SSD Health on macOS

### Why Monitor Swap and SSD?
- **Swap usage**: Excessive swap can slow your system and increase SSD wear.
- **SSD health**: Monitoring helps prevent data loss and performance drops as SSDs age.

---

## 1. Check Swap Usage (Terminal)

### View current swap usage:
```sh
vm_stat | grep swap
```
Or, for a summary:
```sh
sysctl vm.swapusage
```

- **Pageouts** or high swap usage means your system is running low on RAM and using disk as virtual memory.

### Live monitoring (updates every 5s):
```sh
watch -n 5 'sysctl vm.swapusage'
```

---

## 2. Monitor SSD Health

### View SMART status (basic):
```sh
diskutil info disk0 | grep SMART
```
- Should say: `SMART Status: Verified`

### Detailed SSD health (requires smartmontools):
Install if needed:
```sh
brew install smartmontools
```
Check SSD health:
```sh
sudo smartctl -a disk0
```
- Look for `Reallocated_Sector_Ct`, `Wear_Leveling_Count`, and `Media_Wearout_Indicator` (lower is worse).

---

## 3. Automated Health Monitoring

### Weekly Health Check
```bash
# Run comprehensive health check
./swap-ssd-health.sh

# Output: ~/Library/Logs/swap-ssd-health.log
# Features: Swap usage analysis, SSD health, warnings/notifications
```

### Sample Output
```bash
=== Swap & SSD Health Check - 2025-07-25 17:17:01 ===
--- Swap Usage ---
vm.swapusage: total = 2048.00M  used = 315.75M  free = 1732.25M  (encrypted)
⚠️  WARNING: High swap usage detected (100%)
   Consider closing unused apps or adding more RAM
--- Pageouts (Active Swapping) ---
✅ No active swapping detected
--- SSD Health ---
SMART Status: Verified
✅ SSD SMART status is verified
```

---

## 4. Tips to Reduce Swap & SSD Wear
- Close unused apps/tabs.
- Add RAM (if possible).
- Limit background services (Docker, browsers, sync tools).
- Use htop to spot memory hogs.
- Reboot occasionally to clear swap.

---

## 5. Maintenance Schedule

### Weekly Tasks
- Run health check: `./swap-ssd-health.sh`
- Review Stats menu bar for trends
- Check htop for resource hogs: `sudo htop`

### Monthly Tasks
- Review log files in `~/Library/Logs/`
- Check for new versions of monitoring tools
- Assess SSD health trends

### Quarterly Tasks
- Review and update monitoring scripts
- Adjust resource limits based on usage patterns
- Consider hardware upgrades if needed

---

## 6. Troubleshooting

### Common Issues
- **High swap usage**: Close unused applications, consider RAM upgrade
- **SSD warnings**: Monitor wear indicators, backup important data
- **Performance issues**: Use htop to identify resource hogs

### Performance Tips
- Keep Stats running in menu bar for real-time monitoring
- Use htop regularly to identify memory-intensive processes
- Run health checks weekly to catch issues early
## 📁 Contents

### **Files**
- `top-hogs.sh` - [Description of purpose]
- `swap-ssd-health.sh` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
