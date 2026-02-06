# DgtlEnv Prompt Router System Guide

## Overview

> **Contextual orchestration** - A comprehensive prompt management system for semantic routing and context injection

The DgtlEnv Prompt Router is a comprehensive prompt management system that provides semantic routing, context injection, and extensible features for managing structured prompts across the project.

## System Architecture

> **Refined orchestration** - A sophisticated architecture for contextual prompt management

### Core Components

1. **Basic Router** (`ops/run-prompt.sh`)
   - Simple, fast prompt routing
   - Fuzzy matching with semantic language support
   - Clipboard integration

2. **Enhanced Router** (`ops/run-prompt-enhanced.sh`)
   - Configuration-driven architecture
   - Comprehensive logging
   - Variable substitution
   - Prompt chaining
   - Multiple output methods

3. **Configuration System** (`config/prompt-router-config.json`)
   - Centralized configuration management
   - Alias definitions
   - Category metadata
   - Output method configuration

4. **Validation System** (`scripts/validate-prompts.sh`)
   - Template compliance checking
   - Metadata validation
   - Auto-fix capabilities
   - Quality assurance

5. **Analytics System** (`scripts/analyze-prompts.sh`)
   - Usage pattern analysis
   - Complexity metrics
   - Version tracking
   - Performance insights

## Usage Patterns

> **Contextual patterns** - Natural language access to sophisticated prompt orchestration

### Basic Usage
> **Natural language access** - Simple and intuitive prompt routing

```bash
# Simple prompt routing
./ops/run-prompt.sh diagnose-ci
./ops/run-prompt.sh "diagnose ci"
./ops/run-prompt.sh "DIAGNOSE CI"

# Enhanced router with logging
./ops/run-prompt-enhanced.sh diagnose-ci
./ops/run-prompt-enhanced.sh --chain diagnose-ci generate-report
```

### Advanced Features
> **Sophisticated orchestration** - Advanced features for complex workflow management

```bash
# Configuration management
./ops/run-prompt-enhanced.sh --config custom-config.json

# Prompt chaining
./ops/run-prompt-enhanced.sh --chain diagnose-ci generate-report create-todo

# Analytics and insights
./scripts/analyze-prompts.sh
./scripts/analyze-prompts.sh --report

# Validation and quality control
./scripts/validate-prompts.sh
./scripts/validate-prompts.sh --fix
```

## Configuration Management

> **Refined configuration** - Sophisticated alias and output management

### Alias Configuration

The system supports multiple aliases for the same prompt:

```json
{
  "aliases": {
    "diagnose-ci": ["diagnose ci", "ci diagnose", "debug ci", "fix ci"],
    "generate-dockerfile": ["generate docker", "create docker", "docker generate"]
  }
}
```

### Output Methods

Configure how prompts are delivered:

```json
{
  "output_methods": {
    "clipboard": true,
    "file": false,
    "stdout": false
  }
}
```

### Category Metadata

Define category-specific information:

```json
{
  "categories": {
    "system-optimization": {
      "description": "System performance and optimization prompts",
      "keywords": ["performance", "optimize", "system", "docker", "ci"]
    }
  }
}
```

## Template System

### Variable Substitution

Prompts support dynamic variable substitution:

- `{{date}}` - Current date (YYYY-MM-DD)
- `{{time}}` - Current time (HH:MM:SS)
- `{{timestamp}}` - Full timestamp (YYYYMMDD-HHMMSS)
- `{{project}}` - Project name (DgtlEnv)
- `{{user}}` - Current user
- `{{pwd}}` - Current working directory

### Include Syntax

Inject live context from files:

```markdown
System Logs: {{include:logs/system.log}}
Error Details: {{include:logs/error.log}}
```

## Best Practices

### 1. Prompt Organization

- Use semantic versioning for all prompts
- Follow kebab-case naming conventions
- Organize by functional categories
- Maintain README files in each category

### 2. Template Compliance

- Use the standard template format
- Include all required metadata fields
- Follow the diagnostic framework structure
- Ensure proper markdown formatting

### 3. Version Management

- Always increment version numbers for changes
- Keep only the latest version in active use
- Archive old versions in a separate directory
- Use semantic versioning (major.minor.patch)

### 4. Quality Assurance

- Run validation before committing changes
- Use analytics to identify improvement opportunities
- Monitor usage patterns for optimization
- Regular cleanup of outdated prompts

## Integration Points

### Cursor IDE Integration

```json
{
  "tasks": [
    {
      "label": "Prompt Router: Diagnose CI",
      "type": "shell",
      "command": "./ops/run-prompt.sh",
      "args": ["diagnose-ci"]
    }
  ]
}
```

### Keyboard Shortcuts

```json
{
  "key": "cmd+shift+p",
  "command": "workbench.action.tasks.runTask",
  "args": "Prompt Router: Diagnose CI"
}
```

### CI/CD Integration

```yaml
# .github/workflows/prompt-validation.yml
- name: Validate Prompts
  run: ./scripts/validate-prompts.sh

- name: Generate Analytics
  run: ./scripts/analyze-prompts.sh --report
```

## Troubleshooting

### Common Issues

1. **Prompt Not Found**
   - Check spelling and case sensitivity
   - Use `--search` to find similar prompts
   - Verify the prompt exists in the correct category

2. **Include Files Missing**
   - Ensure referenced files exist
   - Check file paths are relative to project root
   - Verify file permissions

3. **Configuration Errors**
   - Validate JSON syntax in config file
   - Check for required fields
   - Ensure proper file paths

### Debug Mode

Enable detailed logging:

```bash
# Set log level to debug
jq '.logging.level = "debug"' config/prompt-router-config.json > config/debug-config.json
./ops/run-prompt-enhanced.sh --config config/debug-config.json diagnose-ci
```

## Performance Optimization

### Caching

The system automatically caches:
- Configuration files
- Prompt file metadata
- Alias mappings

### Parallel Processing

For large prompt collections:
- Use `--chain` for batch processing
- Enable parallel validation with `--parallel`
- Use analytics to identify bottlenecks

## Future Enhancements

### Planned Features

1. **Contextual Routing**
   - Semantic prompt matching
   - Intent recognition
   - Semantic suggestions

2. **Collaborative Features**
   - Multi-user prompt sharing
   - Version control integration
   - Review and approval workflows

3. **Advanced Analytics**
   - Performance metrics
   - Success rate tracking
   - A/B testing capabilities

4. **Plugin System**
   - Custom output formatters
   - External integrations
   - Extensible validation rules

## Conclusion

The DgtlEnv Prompt Router System provides a robust, extensible foundation for prompt management. By following the established patterns and best practices, you can create a highly efficient and maintainable prompt ecosystem that scales with your project needs.

For additional support or feature requests, refer to the project documentation or create an issue in the repository.
