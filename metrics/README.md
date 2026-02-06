# metrics/

This directory contains performance tracking, metrics collection, and dashboard generation tools for monitoring environment optimization and PDF conversion progress.

## Structure
- `dashboards/` — Visual dashboard files and templates
- `data/` — Metrics data storage and configuration
- `reports/` — Generated performance reports
- `comprehensive-dashboard.sh` — Main dashboard generation script
- `system-metrics-tracker.sh` — System performance tracking
- `pdf-processing-dashboard.md` — PDF conversion progress tracking
- `pdf-conversion-metrics.json` — PDF conversion metrics data

## Scripts

### Dashboard Generation
- **`comprehensive-dashboard.sh`** — Main dashboard with system performance, PDF conversion, and optimization status
- **`system-metrics-tracker.sh`** — Baseline, current, and comparison metrics collection

### Usage Examples
```bash
# Generate comprehensive dashboard
./metrics/comprehensive-dashboard.sh dashboard

# Check real-time status
./metrics/comprehensive-dashboard.sh status

# Track system performance
./metrics/system-metrics-tracker.sh baseline
./metrics/system-metrics-tracker.sh current
./metrics/system-metrics-tracker.sh compare
```

## Dashboard Features

### System Performance Tracking
- Memory usage and trends
- CPU utilization monitoring
- Disk usage and health
- Swap activity tracking
- SSD health monitoring

### PDF Conversion Metrics
- Conversion progress tracking
- File processing status
- Error rate monitoring
- Processing time analysis

### Optimization Comparison
- Before/after performance metrics
- Visual progress indicators
- Improvement tracking
- Historical trend analysis

## Data Storage

### Metrics Data
- `pdf-conversion-metrics.json` — PDF conversion statistics
- `data/` — Additional metrics storage
- `reports/` — Generated performance reports

### Dashboard Output
- `dashboards/comprehensive-dashboard.md` — Main dashboard
- `dashboards/before-after-comparison.md` — Performance comparison
- `dashboards/progress-chart.md` — Visual progress tracking

## Integration

### Pre-Release Workflow
The metrics system integrates with the pre-release sanitizer:
```bash
# Check metrics before release
./metrics/comprehensive-dashboard.sh status

# Run security sanitization
./scripts/pre-release-sanitizer.sh --fix

# Verify metrics after sanitization
./metrics/comprehensive-dashboard.sh dashboard
```

### Automated Monitoring
- Weekly system health checks
- Monthly performance reviews
- Quarterly optimization assessments
- Pre-release security validation
- Organization standards enforcement

## Configuration

### Performance Targets
- **Memory Usage:** < 80% (Current: 34% ✅)
- **CPU Usage:** < 70% (Current: 14% ✅)
- **Disk Usage:** < 85% (Current: 21% ✅)
- **PDF Conversion:** 100% (Current: 100% ✅)

### Monitoring Schedule
- **Real-time:** Stats app menu bar monitoring
- **Weekly:** System health checks
- **Monthly:** Performance dashboard generation
- **Pre-release:** Security validation
- **Ongoing:** Organization standards compliance and todo quality control with smart migration detection

## Troubleshooting

### Common Issues
```bash
# Dashboard not updating
./metrics/comprehensive-dashboard.sh update

# Metrics collection errors
sudo ./metrics/system-metrics-tracker.sh current

# PDF conversion tracking issues
./ops/backup/simple-pdf-converter.sh dashboard
```

### Data Validation
```bash
# Verify metrics data integrity
cat metrics/pdf-conversion-metrics.json

# Check dashboard generation
./metrics/comprehensive-dashboard.sh status

# Validate system metrics
./metrics/system-metrics-tracker.sh compare
```

## Security Integration

The metrics system works with the pre-release sanitizer to ensure:
- No personal information in metrics data
- Secure logging practices
- Sanitized dashboard output
- Safe performance reporting

---

**Last Updated:** 2025-07-25
**Maintainer:** DgtlEnv Maintainer

## 📁 Contents

### **Files**
- `current-metrics.json` - [Description of purpose]
- `comprehensive-dashboard.sh` - [Description of purpose]
- `pdf-processing-dashboard.md` - [Description of purpose]
- `pdf-conversion-metrics.json` - [Description of purpose]
- `system-metrics-tracker.sh` - [Description of purpose]
- `baseline-metrics.json` - [Description of purpose]

### **Subdirectories**
- `prompt-analytics/` - [Description of contents]
- `dashboards/` - [Description of contents]
- `data/` - [Description of contents]
- `reports/` - [Description of contents]

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
