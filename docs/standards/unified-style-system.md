# DgtlEnv Unified Style System

A comprehensive guide to the unified monochromatic ASCII style system and centralized naming approach for the DgtlEnv project.

## 🎨 Overview

DgtlEnv uses a **unified monochromatic ASCII-first** approach that creates a consistent, professional, and universally compatible visual identity across all documentation and outputs.

## 📋 Project Name Standards

### Primary Name: DgtlEnv
- **Official Name:** DgtlEnv
- **Full Name:** DgtlEnv - Digital Environment Management
- **Source of Truth:** `README.md` (line 1)
- **Configuration:** `config/project-config.json`

### Naming Guidelines

#### ✅ Correct Usage
- "DgtlEnv" (primary name)
- "DgtlEnv - Digital Environment Management" (full name)
- "DgtlEnv project"
- "DgtlEnv system"

#### ❌ Incorrect Usage
- "DgtlEnv" (old name)
- "Digital Environment" (without DgtlEnv)
- "DgtlEnv" (inconsistent casing)

## 🎯 ASCII Style System

### Design Philosophy

DgtlEnv uses a **monochromatic ASCII-first** approach that prioritizes:
- **Consistency** across all documentation and outputs
- **Readability** in any terminal or text editor
- **Universality** - works everywhere without special fonts
- **Performance** - lightweight and fast rendering
- **Accessibility** - clear and unambiguous symbols

### Core ASCII Elements

#### Status Indicators
```
✅  PASS/SUCCESS    ⚠️  WARNING    ❌  FAIL/ERROR    🔄  IN PROGRESS
🟢  GOOD           🟡  WARNING     🔴  CRITICAL      ⚪  NEUTRAL
```

#### Progress Bars
```
██████████████████████████████  (100% - Filled)
██████████░░░░░░░░░░░░░░░░░░░░  (33% - Partial)
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  (0% - Empty)
```

#### System Health Dashboard
```
┌─────────────────────────────────────┐
│  DgtlEnv System Health              │
├─────────────────────────────────────┤
│  🖥️  System:    ✅ OPERATIONAL     │
│  💾 Memory:    ✅ 34% (Target: <80%)│
│  🔥 CPU:       ✅ 14% (Target: <70%)│
│  💿 Disk:      ✅ 21% (Target: <85%)│
│  📊 Metrics:   ✅ ACTIVE            │
│  📄 PDF Conv:  ✅ COMPLETE          │
└─────────────────────────────────────┘
```

### Icon Set

#### System Components
```
🖥️  SYSTEM      💾 MEMORY      🔥 CPU         💿 DISK
📊 METRICS      📈 DASHBOARD    📄 DOCUMENT    🔧 TOOL
🛡️  SECURITY    🔒 LOCK        ⚡ PERFORMANCE  🎯 TARGET
```

#### File Types
```
📁 DIRECTORY    📄 MARKDOWN     📊 JSON         ⚙️  CONFIG
🔧 SCRIPT       📋 LOG          📈 METRIC       🎨 TEMPLATE
```

#### Actions & States
```
▶️  START        ⏹️  STOP         🔄 RESTART     📝 EDIT
📤 EXPORT       📥 IMPORT       🔍 SEARCH       🎯 TARGET
✅ COMPLETE     ⚠️  WARNING      ❌ ERROR       🔄 PROCESSING
```

#### Development Tools
```
💻 CURSOR       🐳 DOCKER       🍺 HOMEBREW    📊 STATS
🔧 SCRIPT       ⚙️  CONFIG       📈 METRICS     🛠️  TOOLS
```

## 🎨 DgtlEnv Logo Variations

### Simple Logo
```
DgtlEnv
```



### ASCII Art Logo
```
DgtlEnv
```

### Minimal Logo
```
DgtlEnv
Digital Environment Management
```

## 📊 Chart Styles

### Bar Charts
```
Memory Usage: 34% ✅
██████████░░░░░░░░░░░░░░░░░░░░
Target: < 80% | Current: 34%

CPU Usage: 14% ✅
████░░░░░░░░░░░░░░░░░░░░░░░░░░
Target: < 70% | Current: 14%
```

### Progress Indicators
```
PDF Conversion: 100% ✅
██████████████████████████████
Status: Complete | Files: 3/3

System Optimization: 85% 🔄
██████████████████████░░░░░░░░
Status: In Progress | Remaining: 3 tasks
```

### Status Tables
```
┌─────────────────────────────────────┐
│  COMPONENT    │ STATUS │ PROGRESS  │
├─────────────────────────────────────┤
│  System       │ ✅     │ 100%      │
│  PDF Convert  │ ✅     │ 100%      │
│  Monitoring   │ ✅     │ 100%      │
│  Security     │ 🔄     │ 85%       │
└─────────────────────────────────────┘
```

## 🔧 Implementation

### Centralized Configuration

The project uses `config/project-config.json` as the centralized configuration:

```json
{
  "project": {
    "name": "DgtlEnv",
    "fullName": "DgtlEnv - Digital Environment Management",
    "description": "A personal experimental project focused on improving my environment to run modern products...",
    "version": "1.0.0"
  },
  "ascii": {
    "logo": {
      "simple": "DgtlEnv",
      "styled": "...",
      "art": "...",
      "minimal": "..."
    },
    "icons": {
      "system": "🖥️",
      "memory": "💾",
      "cpu": "🔥"
    }
  }
}
```

### Shell Script Integration

```bash
# Get project name from config
PROJECT_NAME=$(jq -r '.project.name' config/project-config.json)

# Create progress bar
create_progress_bar() {
    local percentage="$1"
    local width=30
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))

    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
}

# Status indicators
echo "✅ System health check completed"
echo "⚠️  Memory usage above threshold"
echo "❌ PDF conversion failed"
```

### Markdown Integration

```markdown
### System Status
```
Memory Usage: 34% ✅
██████████░░░░░░░░░░░░░░░░░░░░
```
```

## 📋 Usage Guidelines

### 1. Status Reporting
Always use consistent status indicators:
- ✅ for success/completion
- ⚠️ for warnings/attention needed
- ❌ for errors/failures
- 🔄 for in-progress operations

### 2. Progress Visualization
Use progress bars for:
- System resource usage
- Task completion percentages
- File conversion progress
- Optimization status

### 3. File Structure
Use tree-style ASCII for:
- Directory structures
- Component hierarchies
- System architecture
- File organization

### 4. Data Visualization
Use ASCII charts for:
- Performance metrics
- Resource usage
- Comparison data
- Trend analysis

## 🎯 Best Practices

### 1. Consistency
- Use the same symbols across all documentation
- Maintain consistent spacing and alignment
- Follow established patterns for similar data types

### 2. Readability
- Keep ASCII art simple and clear
- Use appropriate spacing for visual separation
- Ensure symbols are unambiguous

### 3. Performance
- Prefer simple ASCII over complex art
- Use efficient rendering methods
- Cache frequently used patterns

### 4. Accessibility
- Provide text alternatives for ASCII art
- Use clear, descriptive symbols
- Maintain high contrast for visibility

## 🔧 Available Tools

### ASCII Style Converter
```bash
./scripts/convert-ascii-style.sh [command]
```

Commands:
- `convert` - Convert existing files to ASCII style
- `examples` - Show ASCII style examples
- `logo [style]` - Generate ASCII logo
- `dashboard` - Create system health dashboard
- `chart` - Create performance comparison chart
- `structure` - Show file structure tree

### Project Name Update Script
```bash
./scripts/update-project-name.sh [command]
```

Commands:
- `update` - Update all files to use DgtlEnv
- `header` - Update README header with source of truth
- `config` - Show current project configuration
- `validate` - Validate naming consistency
- `guidelines` - Create naming guidelines document
- `full` - Run complete update process

## 📊 Examples

### System Health Dashboard
```
┌─────────────────────────────────────┐
│  DgtlEnv System Health              │
├─────────────────────────────────────┤
│  🖥️  System:    ✅ OPERATIONAL     │
│  💾 Memory:    🟢 34% (Target: <80%)│
│  🔥 CPU:       🟢 14% (Target: <70%)│
│  💿 Disk:      🟢 21% (Target: <85%)│
│  📊 Metrics:   ✅ ACTIVE            │
│  📄 PDF Conv:  ✅ COMPLETE          │
└─────────────────────────────────────┘
```

### Performance Chart
```
Before vs After Optimization
┌─────────────────────────────────────┐
│  Metric    │ Before │ After │ Δ     │
├─────────────────────────────────────┤
│  Memory    │  85%   │  34%  │ -51%  │
│  CPU       │  65%   │  14%  │ -51%  │
│  Swap      │  45%   │   0%  │ -45%  │
│  Response  │ 2.3s   │ 0.8s  │ -65%  │
└─────────────────────────────────────┘
```

### File Structure
```
DgtlEnv/
├── 📁 docs/                    # Documentation
│   ├── 📄 README.md           # Main documentation
│   ├── 📊 optimization-summary.md
│   └── 📄 pdf-conversion-and-metrics-system.md
├── 🛠️  ops/                   # Operations
│   ├── 🔧 backup/             # Backup scripts
│   ├── 🔧 cleanup/            # Cleanup scripts
│   ├── 🐳 docker/             # Docker optimization
│   └── 📈 monitoring/         # System monitoring
├── 📊 metrics/                # Performance tracking
│   ├── 📈 dashboards/         # Visual dashboards
│   └── 📊 system-metrics-tracker.sh
├── 🔒 security/               # Security policies
├── 📋 todos/                  # Task management
└── 🔧 scripts/                # Utility scripts
```

## 📚 Related Documentation

- **ASCII Style Guide:** `docs/ascii-style-guide.md` - Detailed ASCII art system
- **Naming Guidelines:** `docs/naming-guidelines.md` - Project naming standards
- **Project Configuration:** `config/project-config.json` - Centralized configuration
- **Source of Truth:** `README.md` - Authoritative project name reference

This unified style system ensures consistent, professional, and universally compatible visual elements throughout the DgtlEnv project while maintaining a single source of truth for the project name.
