# Configuration Files

This directory contains configuration files and templates for the DgtlEnv environment optimization system.
For a comprehensive overview of how these configurations fit into the wider project, see the **[Sources of Truth](../docs/SOURCES_OF_TRUTH.md)**.

## Contents

- **Environment configurations** - System-specific settings
- **Application configs** - Tool and service configurations
- **Template files** - Reusable configuration examples
- **Default settings** - Standard configuration files

## Configuration Types

### System Configuration
- **Environment variables** - System-wide settings
- **Path configurations** - Directory and file path settings
- **Resource limits** - Memory, CPU, and storage limits

### Application Configuration
- **IDE settings** - Cursor IDE and VS Code configurations
- **Docker settings** - Container and resource configurations
- **Monitoring configs** - Health check and metrics settings

### Template Files
- **Configuration templates** - Reusable configuration examples
- **Best practice examples** - Recommended settings
- **Documentation templates** - Standard documentation formats

## Usage

```bash
# Copy configuration template
cp config/template-name.conf config/local-name.conf

# Apply configuration
source config/environment.sh

# Validate configuration
./config/validate-config.sh
```

## File Naming Convention

- **`*.conf`** - Configuration files
- **`*.template`** - Template files
- **`*.env`** - Environment files
- **`*.json`** - JSON configuration files
- **`*.yml`** - YAML configuration files

## Related Directories

- `../ops/templates/` - Operation script templates
- `../docs/` - Configuration documentation
- `../examples/` - Usage examples

## 📁 Contents

### **Files**
- `cursor-settings.json` - [Description of purpose]
- `prompt-router-config.json` - [Description of purpose]
- `project-config.json` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
