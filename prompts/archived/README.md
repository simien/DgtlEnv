# Archived Prompts

This directory contains outdated versions of prompts that have been superseded by newer versions.

## Purpose

When a prompt is updated to a new version (e.g., v1.0.0 → v1.1.0), the old version is moved here to:

- **Maintain History**: Keep a record of previous versions for reference
- **Clean Organization**: Keep the main prompt directories focused on current versions
- **Version Control**: Provide access to previous implementations if needed
- **Quality Assurance**: Ensure only the latest versions are used by the router

## Current Archived Prompts

### Meta-Prompts
- `generate-chat-summary-title-v1.0.0.md` → Updated to v1.1.0 (six-word constraint, no project names)

## Archive Management

### Automatic Archiving
The system includes automated tools to manage outdated versions:

```bash
# Check for outdated versions (dry run)
./scripts/audit-prompts.sh --dry-run

# Automatically archive outdated versions
./scripts/audit-prompts.sh --archive
```

### Manual Archiving
To manually archive a prompt version:

```bash
# Move outdated version to archive
mv prompts/categories/category-name/prompt-name-v1.0.0.md prompts/archived/
```

## Validation Integration

The prompt validation system now includes checks for outdated versions:

```bash
# Run validation (includes outdated version warnings)
./scripts/validate-prompts.sh
```

Outdated versions will show warnings like:
```
⚠️  Outdated version: current=v1.0.0, latest=v1.1.0
```

## Best Practices

1. **Version Management**: Always create new versions rather than overwriting existing ones
2. **Naming Convention**: Use semantic versioning (v1.0.0, v1.1.0, v2.0.0)
3. **Documentation**: Update this README when archiving new versions
4. **Testing**: Verify the router picks up the latest version after archiving
5. **Cleanup**: Periodically review archived versions and remove truly obsolete ones

## Router Behavior

The prompt router automatically:
- Finds the latest version of any prompt
- Ignores archived versions
- Uses semantic versioning to determine the "latest"

Example:
```bash
# This will use the latest version (v1.1.0)
./ops/run-prompt.sh "generate chat summary title"
```

---

**Last Updated:** July 28, 2025
**Total Archived:** 1 prompt
**Archive Policy:** Automatic with manual review

## 📁 Contents

### **Files**
- `generate-chat-summary-title-v1.0.0.md` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
