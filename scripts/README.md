# scripts/

This directory contains utility scripts for environment management, setup, maintenance, and organization standards enforcement.

## 🎯 Script Categorization

### 🖥️ Environment Optimization Scripts
**Tools that directly improve your Mac's performance:**

- **`sync-cursor-settings.sh`** - 💻 Cursor IDE optimization (Faster performance, reduced memory usage)

### 📁 Environment Management Scripts
**Tools that help manage the development environment:**

- **`pre-release-sanitizer.sh`** - 🔒 Security sanitization
- **`enforce-organization-standards.sh`** - 📋 Organization standards enforcement
- **`migrate-todo-items.sh`** - ✅ **FIXED** - Todo migration with comprehensive reporting
- **`create-release.sh`** - 🚀 Release management
- **`setup-github.sh`** - 📦 GitHub repository setup
- **`export-chat-history.sh`** - 📝 Development history export
- **`update-project-name.sh`** - 🏷️ Project naming management
- **`convert-ascii-style.sh`** - 🎨 Documentation styling

## Scripts by Category

## Usage

### Pre-Release Sanitizer

The sanitizer automatically checks for and fixes personal information, credentials, and file permission issues before public releases.

```bash
# Check for issues without fixing (dry run)
./scripts/pre-release-sanitizer.sh --dry-run

# Check and automatically fix issues
./scripts/pre-release-sanitizer.sh --fix

# Show help
./scripts/pre-release-sanitizer.sh --help
```

**What it checks:**
- Personal information (usernames, email addresses, phone numbers)
- Credentials (API keys, passwords, tokens)
- File permissions (overly permissive files)
- Absolute paths with personal information
- **NEW:** Todo metrics and dashboard validation (master todo, ASCII charts, current dates)
- **NEW:** Active todo directory structure and completion status

**What it fixes:**
- Replaces absolute paths with relative paths
- Sanitizes personal information in documentation
- Fixes file permissions for security
- Generates detailed reports

### GitHub Setup

```bash
# Setup GitHub repository with best practices
./scripts/setup-github.sh -r https://github.com/username/repository.git
```

### Release Management

```bash
# Create a new release
./scripts/create-release.sh 1.1.0 "Add new features"

# Show help
./scripts/create-release.sh

# The script will:
# - Validate version format
# - Run pre-release security checks
# - Update CHANGELOG.md
# - Create and push git tag
# - Trigger GitHub Actions release workflow
```

### Cursor Settings Sync

```bash
# Sync Cursor IDE settings
./scripts/sync-cursor-settings.sh
```

### Organization Standards Enforcement

Check and enforce directory organization standards across the project:

```bash
# Check for violations
./scripts/enforce-organization-standards.sh

# Attempt automatic fixes
./scripts/enforce-organization-standards.sh --fix

# The script checks for:
# - Backup files (.bak, .backup)
# - System files (.DS_Store)
# - Scattered files in root directories
# - Missing README files
# - Required directory structure
# - Todo quality control (completed todos must be fully checked)
# - Dynamic symbol usage with proper outcome communication
# - **NEW:** Todo metrics and dashboard validation (master todo, ASCII charts, current dates)
# - **NEW:** Log directory organization and rotation
# - **NEW:** Active todo directory structure and completion status

### Todo Migration

Migrates non-completed todo items from completed files to appropriate active/planning todo files:

```bash
# Test migration without making changes (dry run)
./scripts/migrate-todo-items.sh --dry-run

# Run actual migration
./scripts/migrate-todo-items.sh

# Run with detailed output
./scripts/migrate-todo-items.sh --verbose
```

**What it does:**
- Scans completed todo files for dynamic symbols
- Categorizes items based on content keywords
- Creates appropriate target todo files
- Migrates items to active/ or planning/ directories
- Updates README files with new counts
- Maintains timestamps and source references
- Adds migration notes to completed files for audit trail
- Generates comprehensive migration reports in `logs/` directory
- Provides real-time progress tracking
- Handles errors gracefully with clean execution
```

### ASCII Style Converter

Generate ASCII art and visual elements for documentation:

```bash
# Show examples
./scripts/convert-ascii-style.sh examples

# Generate styled logo
./scripts/convert-ascii-style.sh logo styled

# Create system dashboard
./scripts/convert-ascii-style.sh dashboard

# Create performance chart
./scripts/convert-ascii-style.sh chart
```

### Project Name Management

Update and validate project naming consistency:

```bash
# Show current configuration
./scripts/update-project-name.sh config

# Validate naming consistency
./scripts/update-project-name.sh validate

# Create naming guidelines
./scripts/update-project-name.sh guidelines
```

## Pre-Release Workflow

Before any public release, run the sanitizer:

```bash
# 1. Check for issues
./scripts/pre-release-sanitizer.sh --dry-run

# 2. Fix issues automatically
./scripts/pre-release-sanitizer.sh --fix

# 3. Verify fixes
./scripts/pre-release-sanitizer.sh --dry-run

# 4. Review generated report
cat logs/sanitization-report-*.md
```

## Organization Standards Workflow

Regular maintenance to ensure clean organization:

```bash
# 1. Check for violations
./scripts/enforce-organization-standards.sh

# 2. Fix violations automatically
./scripts/enforce-organization-standards.sh --fix

# 3. Verify clean state
./scripts/enforce-organization-standards.sh
```

## Security Features

- **Automated Detection:** Scans for common personal information patterns
- **Safe Fixes:** Uses dry-run mode to preview changes
- **Comprehensive Coverage:** Checks all file types and locations
- **Detailed Reporting:** Generates detailed sanitization reports

## Organization Features

- **Standards Enforcement:** Automated checking of directory organization
- **Clean Structure:** Ensures files are in appropriate directories
- **Backup Management:** Removes unnecessary backup files
- **README Validation:** Ensures all directories have proper documentation
- **Todo Quality Control:** Validates completed todos and dynamic symbol usage
- **Smart Migration Detection:** Recognizes already-migrated items vs items needing migration
- **Outcome Communication:** Ensures non-completed tasks have proper status communication

## Related Documentation

- See `../docs/standards/` for ASCII style system documentation

---

**Last Updated:** 2025-07-27 (Migration Script Fixed)
**Maintainer:** DgtlEnv Maintainer

## 📁 Contents

### **Files**
- `manage-readmes.sh` - Unified tool for creating, updating, and validating README files
- `get-prompt-content.sh` - [Description of purpose]
- `audit-prompts.sh` - [Description of purpose]
- `start-promptrouter-migration.sh` - [Description of purpose]
- `convert-ascii-style.sh` - [Description of purpose]
- `analyze-prompts.sh` - [Description of purpose]
- `validate-prompts.sh` - [Description of purpose]
- `pre-release-sanitizer.sh` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
