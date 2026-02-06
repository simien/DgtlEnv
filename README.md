# **DgtlEnv** - Digital Environment Optimization

> **Personal Experimental Project** - A personal toolkit for improving my environment to run modern products.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.7.6%20Monterey-blue.svg)](https://www.apple.com/macos/)
[![System Status](https://img.shields.io/badge/System%20Status-Optimized-brightgreen.svg)](https://github.com/dgtlenv-maintainer/DgtlEnv)

**Device:** MacBook Pro (Retina, 15-inch, Mid 2015) | **OS:** macOS 12.7.6 Monterey

---

## 🎯 What is DgtlEnv?

**DgtlEnv** is a personal experimental project focused on improving my environment to run modern products. It contains explorations for internal management and personal interests in design, development, context systems, and processes. Built as a shell script toolkit for maximum simplicity and extensibility.

**💡 Leverage what works well, share how you implement it, and please contribute if you would like to.**

### **Primary Focus: Environment Optimization**
> **Performance refinement** - Tools that directly improve your Mac's performance

- **System Health Monitoring** - Prevents slowdowns and data loss
- **System Cleanup** - Frees up disk space and memory
- **Docker Optimization** - Prevents resource hogging
- **IDE Performance** - Optimizes Cursor IDE for faster development
- **Performance Tracking** - Shows real-time improvements

### **Secondary Focus: Environment Management**
> **Environment orchestration** - Tools that help manage the development environment

- **PDF Management** - Automated document conversion
- **Security & Release** - Pre-release sanitization
- **Todo Management** - Quality control and organization
- **Contextual Workflows** - Structured prompts for optimization and automation
- **Comprehensive Testing** - Interactive and automated validation suite

---

## 🚀 Quick Start

### Installation
```bash
git clone https://github.com/dgtlenv-maintainer/DgtlEnv.git
cd DgtlEnv
chmod +x ops/monitoring/swap-ssd-health.sh
./ops/monitoring/swap-ssd-health.sh
# Note: You may be prompted for your password to see detailed SSD health stats
```

### Essential Environment Optimization Commands
> **Performance enhancement** - Start here to improve your Mac's performance

```bash
# System Health Check (Prevents slowdowns & data loss)
./ops/monitoring/swap-ssd-health.sh

# System Cleanup (Frees up disk space)
./ops/cleanup/brew-cleanup.sh
./ops/cleanup/docker-cleanup.sh

# Docker Optimization (Prevents resource hogging)
./ops/docker/docker-optimize.sh

# Cursor IDE Optimization (Faster performance)
./scripts/sync-cursor-settings.sh

# Performance Tracking (Shows improvements)
./metrics/system-metrics-tracker.sh baseline
./metrics/system-metrics-tracker.sh current
./metrics/system-metrics-tracker.sh compare

# Real-time System Dashboard
./metrics/comprehensive-dashboard.sh dashboard
```

### Environment Management Commands
> **Environment orchestration** - For managing the development environment

```bash
# PDF Management
./ops/backup/simple-pdf-converter.sh all
./ops/backup/pdf-watcher.sh watch

# Security & Release Management
./scripts/pre-release-sanitizer.sh --dry-run
./scripts/create-release.sh

# Todo Management & Quality Control
./scripts/enforce-organization-standards.sh
./scripts/migrate-todo-items.sh

# Comprehensive Testing
./tests/quick-test.sh
./tests/quick-test.sh --non-interactive
```

---

## 📊 Current System Status

> **System Health Dashboard** - Real-time performance metrics

```
📊 System Health Dashboard
==========================
Memory Usage: 40% ✅ (Target: < 80%)
██████████░░░░░░░░░░░░░░░░░░░░
✅ Memory Status: Excellent

CPU Usage: 22% ✅ (Target: < 70%)
████████░░░░░░░░░░░░░░░░░░░░░░
✅ CPU Status: Optimal

Disk Usage: 21% ✅ (Target: < 85%)
██████░░░░░░░░░░░░░░░░░░░░░░░░
✅ Disk Status: Healthy

📈 Performance Summary
=====================
✅ All systems operating within optimal ranges
✅ No performance bottlenecks detected
✅ System optimization targets achieved
```

**📖 See [docs/guides/computer-optimization-quick-reference.md](docs/guides/computer-optimization-quick-reference.md) for detailed environment optimization guide**

---

## 📋 Available Scripts

> **Comprehensive tooling** - Sophisticated scripts for environment optimization and management

### Environment Optimization (System Performance)
> **Performance refinement** - Tools that directly improve your Mac's performance

#### System Health & Monitoring
- **`./ops/monitoring/swap-ssd-health.sh`** - System health check (prevents slowdowns & data loss)
- **`./ops/monitoring/top-hogs.sh`** - Resource monitoring (identifies performance bottlenecks)

#### System Cleanup & Maintenance
- **`./ops/cleanup/brew-cleanup.sh`** - Homebrew cleanup (frees up disk space)
- **`./ops/cleanup/docker-cleanup.sh`** - Docker cleanup (reduces memory & disk usage)

#### Docker Optimization
- **`./ops/docker/docker-optimize.sh`** - Docker resource management (prevents resource hogging)

#### IDE Performance
- **`./scripts/sync-cursor-settings.sh`** - Cursor IDE optimization (faster performance, reduced memory usage)

#### Performance Tracking
- **`./metrics/system-metrics-tracker.sh`** - Performance tracking (shows before/after improvements)
- **`./metrics/comprehensive-dashboard.sh`** - Visual dashboards (real-time system status)

### Environment Management (Project Tools)
> **Environment orchestration** - Tools that help manage the development environment

#### PDF Management
- **`./ops/backup/simple-pdf-converter.sh`** - PDF to markdown conversion
- **`./ops/backup/pdf-watcher.sh`** - Automatic file watching
- **`./ops/backup/create-dgtlenv-backup.sh`** - Project backup

#### Security & Release Management
- **`./scripts/pre-release-sanitizer.sh`** - Security sanitization
- **`./scripts/create-release.sh`** - Release management
- **`./scripts/setup-github.sh`** - GitHub repository setup

#### Todo Management & Quality Control
- **`./scripts/migrate-todo-items.sh`** - ✅ **FIXED** - Automated todo migration with comprehensive reporting
- **`./scripts/enforce-organization-standards.sh`** - Organization standards enforcement

**📖 See [ops/README.md](ops/README.md) for detailed operations documentation**

---

## 🧠 Contextual Prompt Management System

> **Sophisticated prompt orchestration** - A refined system for contextual routing and quality control

### Prompt Router Features
- **Natural Language Support** - Type `"diagnose ci"` instead of remembering exact filenames
- **Fuzzy Matching** - Contextual prompt discovery with semantic suggestions
- **Context Injection** - Dynamic file inclusion with `{{include:path/to/file}}`
- **Version Management** - Automatic latest version selection with semantic versioning
- **Quality Control** - Comprehensive validation and analytics
- **Automated Version Management** - Outdated version detection and archiving

### Current Prompt Analytics (July 28, 2025)
> **Performance insights** - Comprehensive analytics for prompt system optimization

```
📊 Prompt Structure Analysis
==========================
Total prompts: 24 (active)
Archived prompts: 1 (properly managed)
Total categories: 5

Prompts by category:
  code-analysis               5 (20%)
  documentation-generation    5 (20%)
  meta-prompts                3 (12%)
  system-optimization         5 (20%)
  workflow-management         6 (25%)

📈 Quality Metrics
=================
Template Compliance: 100% ✅
Metadata Completeness: 100% ✅
Version Consistency: 100% ✅
File Naming Standards: 100% ✅
Validation Success Rate: 100% ✅
Outdated Version Management: 100% ✅

📦 Version Management
====================
Active prompts: 24 (clean, current versions only)
Archived prompts: 1 (outdated version)
Outdated versions: 0 (all handled)
Archive system: 100% operational
```

### Quick Prompt Usage
> **Contextual routing** - Natural language access to structured prompts

```bash
# Basic prompt routing
./ops/run-prompt.sh "diagnose ci"
./ops/run-prompt.sh "find bugs"
./ops/run-prompt.sh "create todo"

# Enhanced router with logging
./ops/run-prompt-enhanced.sh diagnose-ci
./ops/run-prompt-enhanced.sh --chain diagnose-ci generate-report

# Version management tools
./scripts/audit-prompts.sh --dry-run
./scripts/audit-prompts.sh --archive

# Analytics and validation
./scripts/analyze-prompts.sh
./scripts/validate-prompts.sh
```

**📖 See [prompts/README.md](prompts/README.md) for detailed prompt system documentation**

**📚 See [docs/prompt-system-overview.md](docs/prompt-system-overview.md) for comprehensive system architecture and advanced features**

---

## 🔄 Complete Optimization Workflow

> **Sophisticated orchestration** - A refined workflow for comprehensive optimization

```bash
# 1. Capture baseline metrics
./metrics/system-metrics-tracker.sh baseline

# 2. Run optimizations
./ops/monitoring/swap-ssd-health.sh
./ops/cleanup/brew-cleanup.sh
./ops/cleanup/docker-cleanup.sh
./ops/docker/docker-optimize.sh
./scripts/sync-cursor-settings.sh

# 3. Capture current metrics
./metrics/system-metrics-tracker.sh current

# 4. Generate comparison report
./metrics/system-metrics-tracker.sh compare

# 5. View comprehensive dashboard
./metrics/comprehensive-dashboard.sh dashboard
```

**📖 See [docs/guides/computer-optimization-quick-reference.md](docs/guides/computer-optimization-quick-reference.md) for detailed environment optimization guide**

---

## 📚 Documentation

> **Comprehensive knowledge base** - Documentation for all aspects of environment optimization

### Environment Optimization
> **Performance refinement** - Complete guides for system optimization and performance tuning

- **[Environment Optimization Quick Reference](docs/guides/computer-optimization-quick-reference.md)** - Complete optimization guide with cards and workflows
- **[Cursor IDE Optimization](ops/README.md#cursor-ide-performance-optimization-macos)** - IDE performance tuning guide

### Environment Management
> **Environment orchestration** - Tools and workflows for development environment management


### Performance & Metrics
> **Performance insights** - Monitoring and analytics systems

- **[Metrics & Monitoring](metrics/README.md)** - Performance tracking and dashboards
- **[Operations Documentation](ops/README.md)** - Environment optimization tools
- **[Scripts Documentation](scripts/README.md)** - Environment management tools
- **[Test Suite](tests/README.md)** - Validation and testing with interactive and automated modes

### Contextual Workflows
> **Advanced orchestration** - Prompt management and workflow automation

- **[Prompts System](prompts/README.md)** - Structured AI prompts for system optimization
- **[System Optimization Prompts](prompts/categories/system-optimization/)** - Performance tuning and resource management
- **[Meta-Prompts](prompts/categories/meta-prompts/)** - Conversation management and utilities

### Setup & Configuration
> **Configuration management** - Setup guides and development standards

- **[GitHub Setup Guide](docs/setup/github-setup.md)** - Repository configuration
- **[Contributing Guidelines](CONTRIBUTING.md)** - Development standards
- **[Security Policies](security/README.md)** - Security and audit information

---

## 🤝 Contributing

**💡 Leverage what works well, share how you implement it, and please contribute if you would like to.**

This is an experimental personal project, but I welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 🔒 Security

If you discover a security vulnerability, please report it privately. See our [Security Policy](SECURITY.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact Information

**Name:** DgtlEnv Maintainer
**Email:** maintainer@example.com
**Website:** [example.com](https://example.com/)
**GitHub:** [dgtlenv-maintainer](https://github.com/dgtlenv-maintainer)

## 📁 Project Structure

### **Core Files**
- `CHANGELOG.md` - Project version history and release notes
- `CONTRIBUTING.md` - Development standards and contribution guidelines
- `SECURITY.md` - Security policies and vulnerability reporting

### **Key Directories**
- `ops/` - Environment optimization tools (monitoring, cleanup, Docker)
- `metrics/` - Performance tracking and analytics dashboards
- `scripts/` - Environment management and automation tools
- `docs/` - Comprehensive documentation and guides
- `prompts/` - Structured AI prompts for system optimization
- `tests/` - Validation and testing suite
- `config/` - Project configuration and settings
- `security/` - Security policies and audit reports

### **Support Directories**
- `logs/` - Application and system logs
- `examples/` - Usage examples and demonstrations
- `.github/` - GitHub workflows and templates
