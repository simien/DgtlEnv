# Tests and Validation

This directory contains a streamlined test suite for the DgtlEnv environment optimization system. The test suite provides comprehensive validation of environment optimization and management tools with interactive and non-interactive modes.

## Contents

- **Main test suite** - Comprehensive environment optimization validation
- **Interactive features** - User choice for optional components
- **Performance checkers** - Memory, CPU, and disk usage validation
- **Standalone tools** - Independent Cursor IDE sync utility

## Test Categories

### Environment Optimization Tests
- **System health monitoring** - Swap and SSD health checks
- **System cleanup** - Homebrew and Docker cleanup
- **IDE optimization** - Cursor IDE settings synchronization
- **Performance tracking** - Real-time dashboard monitoring

### Environment Management Tests
- **Security sanitization** - Personal information detection
- **Organization standards** - Directory structure validation
- **Documentation consistency** - README and terminology checks

### Performance Tests
- **Memory usage** - Validates memory usage < 80%
- **CPU usage** - Validates CPU usage < 70%
- **Disk usage** - Validates disk usage < 85%

## Usage

```bash
# Run comprehensive test suite (interactive)
./tests/quick-test.sh

# Run test suite without user prompts (non-interactive)
./tests/quick-test.sh --non-interactive

# Interactive Cursor IDE sync (standalone)
./tests/interactive-cursor-sync.sh

# Performance checkers (used by quick-test)
./tests/validation/check-memory-usage.sh
./tests/validation/check-cpu-usage.sh
./tests/validation/check-disk-usage.sh
```

### Test Modes

**Interactive Mode:**
- Prompts for user input on optional tests
- Allows choice for Cursor IDE synchronization
- Best for manual testing and development

**Non-interactive Mode:**
- Runs without user prompts
- Skips optional interactive tests
- Perfect for automated testing and CI/CD

## Test Structure

```
tests/
├── quick-test.sh                 # Main test suite (interactive)
├── interactive-cursor-sync.sh    # Standalone Cursor IDE sync
├── validation/                   # Performance checkers
│   ├── check-memory-usage.sh    # Memory usage checker
│   ├── check-cpu-usage.sh       # CPU usage checker
│   └── check-disk-usage.sh      # Disk usage checker
├── performance/                  # Performance and load testing
├── security/                    # Security and access testing
└── integration/                 # End-to-end workflow testing
```

## Test Features

### Interactive Features
- **Cursor IDE Sync** - Asks user if they want to sync VS Code settings to Cursor IDE
- **Optional Components** - Gracefully handles missing Docker, Cursor, or other optional tools
- **User Choice** - Allows users to skip certain tests based on their preferences
- **Non-interactive Mode** - Run with `--non-interactive` flag to skip user prompts

### Test Categories
- **Environment Optimization Tests** - Core system health and performance tests
- **Environment Management Tests** - Security and organization standards tests
- **Performance Tests** - Memory, CPU, and disk usage validation
- **Documentation Tests** - README and terminology consistency checks

### Test Results
- **Comprehensive reporting** - Detailed test execution results with color-coded output
- **Accurate success rates** - Excludes expected failures for meaningful metrics
- **Test categorization** - Distinguishes between passed, failed, skipped, and expected failures
- **Performance validation** - Real-time system metrics and thresholds

## Related Directories

- `../ops/` - Environment optimization scripts being tested
- `../scripts/` - Environment management scripts being tested
- `../metrics/` - Performance tracking and dashboard tools
- `../docs/` - Documentation being validated

## 📁 Contents

### **Files**
- `interactive-cursor-sync.sh` - [Description of purpose]
- `prompt-router-tests.sh` - [Description of purpose]
- `quick-test.sh` - [Description of purpose]

### **Subdirectories**
- `validation/` - [Description of contents]

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
