# backup/

Scripts for creating backups of the DgtlEnv project and optimization configurations.

## PDF Conversion Workflow (Updated)

- **Drop PDFs in:** `docs/incoming/`
- **Converted Markdown output:** `docs/`
- **Original PDFs remain in:** `docs/incoming/`
- **No longer used:** `docs/converted/` (folder removed)
- **Migration:** Use `move-converted-files.sh` to move any old markdown files from `docs/converted/` to `docs/`

See `docs/pdf-incoming-workflow.md` for full details.

## Scripts
- `create-digitalenv-backup.sh` — Creates a timestamped zip archive of the entire DgtlEnv project
- `pdf-to-markdown-converter.sh` — Converts all PDFs in `docs/incoming/` to markdown in `docs/`
- `pdf-watcher.sh` — Watches `docs/incoming/` for new PDFs and auto-converts
- `simple-pdf-converter.sh` — Fallback/manual converter for PDFs
- `move-converted-files.sh` — Moves markdown files from old `docs/converted/` to `docs/`

## Usage
- Make scripts executable: `chmod +x scriptname.sh`
- Run from project root: `./ops/backup/create-digitalenv-backup.sh`

## Backup Features

### Automatic Timestamping
- Creates backups with format: `DgtlEnv_Backup_YYYYMMDD_HHMMSS.zip`
- Example: `DgtlEnv_Backup_20250725_143022.zip`

### Smart Exclusions
The backup script automatically excludes unnecessary files:
- `.git/` — Version control files
- `*.DS_Store` — macOS system files
- `*.log` — Log files
- `node_modules/` — Dependencies (can be reinstalled)
- `*.tmp`, `*.temp`, `*.cache` — Temporary files
- `*.swp`, `*.swo`, `*~` — Editor temporary files
- `.vscode/settings.json`, `.cursor/settings.json` — IDE settings (personal)
- `*.zip`, `*.tar.gz`, `*.backup` — Existing backup files
- `docs/converted/` — (no longer used)

### Backup Location
- **Default**: `~/Downloads/DgtlEnv-Backups/`
- **Format**: Timestamped zip files
- **Access**: Script can open backup location in Finder

## Integration with Optimization System

### When to Create Backups
- **Before major changes**: Before applying new optimizations
- **After successful optimizations**: To preserve working configurations
- **Before system updates**: To ensure configurations are preserved
- **Regular intervals**: Monthly or quarterly backups

### Backup Schedule
```bash
# Monthly backup (recommended)
./ops/backup/create-digitalenv-backup.sh

# Before optimization changes
./ops/backup/create-digitalenv-backup.sh

# After successful optimizations
./ops/backup/create-digitalenv-backup.sh
```

## Script Output

### Sample Output
```bash
=== DgtlEnv Backup Script ===
Project Root: ./DgtlEnv
Backup Name: DgtlEnv_Backup_20250725_143022.zip
Backup Path: ~/Downloads/DgtlEnv-Backups/DgtlEnv_Backup_20250725_143022.zip

Creating backup...
✅ Backup created successfully!
File: ~/Downloads/DgtlEnv-Backups/DgtlEnv_Backup_20250725_143022.zip
Size: 2.1M

Recent backups in ~/Downloads/DgtlEnv-Backups:
-rw-r--r--  1 user  staff   2.1M Jul 25 14:30 DgtlEnv_Backup_20250725_143022.zip
-rw-r--r--  1 user  staff   2.0M Jul 15 10:15 DgtlEnv_Backup_20250725_101500.zip

Open backup location in Finder? (y/n): y

Backup completed at Thu Jul 25 14:30:22 PDT 2025
```

## What Gets Backed Up

### Included Files
- ✅ All optimization scripts (`ops/` folder)
- ✅ Documentation (`docs/` folder)
- ✅ Templates (`ops/templates/` folder)
- ✅ Configuration examples
- ✅ README files and guides
- ✅ Todo lists and progress tracking

### Excluded Files
- ❌ Git repository (`.git/`)
- ❌ Log files (`*.log`)
- ❌ Temporary files (`*.tmp`, `*.cache`)
- ❌ IDE settings (personal configurations)
- ❌ Dependencies (`node_modules/`)
- ❌ Existing backup files
- ❌ `docs/converted/` (no longer used)

## Best Practices

### Before Creating Backups
- Ensure all optimization scripts are working
- Test monitoring tools and health checks
- Verify documentation is up to date
- Check that all templates are current

### After Creating Backups
- Verify backup file size is reasonable
- Test backup by extracting to a temporary location
- Keep backup location organized
- Consider cloud storage for important backups

### Backup Management
- **Keep recent backups**: Last 3-5 backups
- **Archive old backups**: Move to long-term storage
- **Test restores**: Periodically test backup restoration
- **Document changes**: Note what changed between backups

## Troubleshooting

### Common Issues
- **Permission errors**: Ensure script is executable (`chmod +x`)
- **Large backup size**: Check for large files that should be excluded
- **Missing files**: Verify you're running from project root
- **Backup location full**: Check available disk space

### Performance Tips
- **Run during low activity**: Avoid creating backups during heavy development
- **Clean up old backups**: Remove backups older than 6 months
- **Compress backups**: Consider additional compression for long-term storage
- **Verify integrity**: Check backup files after creation

## Integration with Other Tools

### Monitoring Integration
- Use with `../monitoring/swap-ssd-health.sh` to check disk space before backup
- Monitor backup creation with `../monitoring/top-hogs.sh`

### Documentation Integration
- Use `../templates/optimization-summary-template.md` to document backup contents
- Track backup history in optimization summaries

### Cleanup Integration
- Run `../cleanup/brew-cleanup.sh` before backup to reduce size
- Use `../cleanup/docker-cleanup.sh` to clean Docker resources 
## 📁 Contents

### **Files**
- `pdf-watcher.sh` - [Description of purpose]
- `pdf-to-markdown-converter.sh` - [Description of purpose]
- `move-converted-files.sh` - [Description of purpose]
- `simple-pdf-converter.sh` - [Description of purpose]
- `create-dgtlenv-backup.sh` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
