# templates/

This folder contains configuration and best-practice examples for optimizing your development environment.

## Templates Available

### Performance Optimization
- `cursor-settings-performance.json` — Optimized Cursor IDE settings for macOS
- `docker-compose-resource-limits-example.yml` — Example for adding CPU and memory limits to your docker-compose.yml services

### Documentation
- `optimization-summary-template.md` — Template for documenting optimization projects and results

## Usage

### Cursor IDE Settings
1. Copy `cursor-settings-performance.json` content
2. Open Cursor IDE settings (Cmd + ,)
3. Open settings.json (Cmd + Shift + P → "Preferences: Open Settings (JSON)")
4. Paste and merge with existing settings
5. Restart Cursor IDE

### Docker Resource Limits
1. Copy relevant sections from `docker-compose-resource-limits-example.yml`
2. Add to your existing docker-compose.yml
3. Adjust limits based on your system capabilities
4. Test with `docker-compose up`

### Optimization Documentation
1. Copy `optimization-summary-template.md` to your project's docs folder
2. Replace placeholder values `[like this]` with your actual data
3. Customize system specifications and performance metrics
4. Update file paths if your project structure differs

## Template Details

### cursor-settings-performance.json
**Purpose**: Optimize Cursor IDE performance on macOS
**Features**:
- File watcher exclusions for large folders
- TypeScript server memory optimization
- Large file handling improvements
- Search exclusions for better performance

**Example Usage**:
```json
{
  "files.watcherExclude": {
    "**/node_modules/*": true,
    "**/build/*": true,
    "**/.git/objects/**": true,
    "**/.dropbox/**": true
  },
  "typescript.tsserver.maxTsServerMemory": 2048,
  "files.maxMemoryForLargeFilesMB": 64,
  "editor.largeFileOptimizations": true
}
```

### docker-compose-resource-limits-example.yml
**Purpose**: Add resource limits to Docker containers
**Features**:
- CPU and memory limits per service
- Examples for different container types
- Swarm mode and standalone configurations

**Example Usage**:
```yaml
services:
  app:
    image: your_app_image
    mem_limit: 512m      # Limit to 512MB RAM
    cpus: 0.5            # Limit to half a CPU core
```

### optimization-summary-template.md
**Purpose**: Document optimization projects comprehensively
**Features**:
- System specifications tracking
- Performance improvements documentation
- Maintenance schedules
- File structure organization
- Anonymized examples for guidance

**Sections Include**:
- Optimization overview and goals
- Completed optimizations with details
- Performance improvements (before/after)
- Maintenance scripts and procedures
- Monitoring tools and output examples
- Verification checklists

## Best Practices

### When to Use Templates
- **New projects**: Start with optimized settings from the beginning
- **Performance issues**: Apply relevant optimizations as needed
- **Documentation**: Use summary template for tracking improvements
- **Team sharing**: Share optimized configurations across team members

### Customization Guidelines
- **System-specific**: Adjust resource limits based on your hardware
- **Workflow-specific**: Modify exclusions based on your project structure
- **Performance goals**: Focus on optimizations that match your objectives
- **Maintenance**: Update templates as tools and requirements evolve

### Integration with Other Tools
- **Monitoring**: Use with `../monitoring/` scripts for health tracking
- **Cleanup**: Combine with `../cleanup/` scripts for maintenance
- **Docker**: Use with `../docker/` optimization tools
- **Documentation**: Track results using the summary template

## Troubleshooting

### Common Issues
- **Settings conflicts**: Merge carefully with existing configurations
- **Resource limits**: Start conservative and adjust based on performance
- **Template customization**: Replace all placeholders before using
- **Version compatibility**: Check tool versions match template requirements

### Performance Tips
- **Test incrementally**: Apply optimizations one at a time
- **Monitor impact**: Use monitoring tools to measure improvements
- **Document changes**: Track what works for future reference
- **Regular updates**: Keep templates current with tool updates 
## 📁 Contents

### **Files**
- `optimization-summary-template.md` - [Description of purpose]
- `docker-compose-resource-limits-example.yml` - [Description of purpose]
- `cursor-settings-performance.json` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
