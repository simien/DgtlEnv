# DgtlEnv Operations (ops/)

This directory contains operational scripts and tools for managing the DgtlEnv environment.

## 🤖 Prompt Router System

### Overview
The Prompt Router is a sophisticated system for managing and executing AI prompts within the DgtlEnv environment. It provides modular, configurable, and robust prompt routing with advanced features like chaining, context injection, and variable substitution.

### Available Scripts

#### `run-prompt.sh` - Enhanced Prompt Router
The current version of the Prompt Router with advanced features:

**Key Features:**
- ✅ **Modular Design** - Clean separation of concerns with specific function responsibilities
- ✅ **Dry-Run Mode** - Safe testing without clipboard interference
- ✅ **Chain Processing** - Execute multiple prompts in sequence
- ✅ **Variable Substitution** - Dynamic content with `{{date}}`, `{{user}}`, etc.
- ✅ **Alias Resolution** - Configured shortcuts for common prompts
- ✅ **Verbose Logging** - Detailed debugging information
- ✅ **Configuration Support** - JSON-based configuration system
- ✅ **Error Recovery** - Graceful handling of edge cases

**Usage:**
```bash
# Basic usage
./ops/run-prompt.sh diagnose-ci

# Dry-run mode for testing
./ops/run-prompt.sh --dry-run diagnose-ci

# Verbose mode for debugging
./ops/run-prompt.sh --verbose diagnose-ci

# Chain multiple prompts
./ops/run-prompt.sh --chain diagnose-ci git-commit-push

# List all available prompts
./ops/run-prompt.sh --list

# Search for specific prompts
./ops/run-prompt.sh --search docker
```

**Configuration:**
The router uses `config/prompt-router-config.json` for:
- Prompt directory configuration
- Output method settings
- Logging configuration
- Alias mappings
- RAG source definitions



### Testing

#### `tests/prompt-router-tests.sh` - Test Suite
Comprehensive testing for the Prompt Router:

```bash
# Run all tests
./tests/prompt-router-tests.sh

# Run with verbose output
./tests/prompt-router-tests.sh --verbose
```

**Test Coverage:**
- ✅ Help functionality
- ✅ List functionality
- ✅ Search functionality
- ✅ Dry-run functionality
- ✅ Valid prompt execution
- ✅ Invalid prompt handling
- ✅ No arguments handling
- ✅ Invalid option handling
- ✅ Search without term
- ✅ Verbose mode
- ✅ Logging functionality
- ✅ Performance testing

### Configuration

#### `config/prompt-router-config.json`
Configuration file for the enhanced Prompt Router:

```json
{
  "prompts_directory": "prompts/categories",
  "output_methods": {
    "clipboard": true,
    "file": false,
    "stdout": false
  },
  "logging": {
    "enabled": true,
    "level": "info",
    "file": "logs/prompt-router.log"
  },
  "aliases": {
    "diagnose-ci": ["diagnose-ci-failure"],
    "readme": ["refactor-readme-concise"],
    "docker": ["optimize-docker-settings", "generate-dockerfile"],
    "todo": ["create-todo-list", "enforce-todo-quality-control"],
    "git": ["git-commit-push", "generate-git-commit-message"],
    "docs": ["update-documentation-comprehensive", "refactor-readme-concise"]
  },
  "rag_sources": {
    "default_contexts": [
      "README.md",
      "docs/standards/ascii-style-guide.md",
      "todos/templates/todo-template.md"
    ],
    "category_contexts": {
      "system-optimization": [
        "ops/docker/docker-optimize.sh",
        "config/cursor-settings.json"
      ],
      "documentation-generation": [
        "docs/standards/unified-style-system.md",
      ],
      "workflow-management": [
      ]
    }
  }
}
```

### Features

#### 1. Modular Function Structure
- `find_latest_prompt()` - Handle prompt discovery and version detection
- `inject_context()` - Process context engineering and RAG sources
- `validate_input()` - Input validation and error checking
- `parse_arguments()` - Handle command-line arguments and flags
- `output_result()` - Manage output methods (clipboard, file, stdout)
- `resolve_alias()` - Resolve configured aliases
- `substitute_variables()` - Process dynamic variables

#### 2. Context Engineering
- **Include Syntax:** `{{include:path/to/file}}`
- **Variable Substitution:** `{{date}}`, `{{user}}`, `{{project}}`, `{{pwd}}`
- **RAG Integration:** Structured context injection from configuration

#### 3. Chain Processing
Execute multiple prompts in sequence:
```bash
./ops/run-prompt-v2.sh --chain diagnose-ci git-commit-push
```

#### 4. Error Handling
- Ambiguous alias resolution
- Missing context file warnings
- Graceful fallbacks for failed operations
- Comprehensive logging system

#### 5. Output Methods
- **Clipboard:** Default method (macOS `pbcopy`)
- **File:** Save to specified file
- **Stdout:** Print to terminal
- **Dry-run:** Preview without execution

### Standards Compliance

The Prompt Router follows DgtlEnv standards:
- **Naming:** kebab-case for all files and functions
- **Formatting:** ASCII style for output and logging
- **Documentation:** Clear, actionable documentation
- **Error Handling:** Comprehensive error recovery
- **Testing:** Full test coverage with automated validation

### Integration Points

- **Prompts System:** `prompts/categories/`
- **Configuration:** `config/prompt-router-config.json`
- **Logging:** `logs/prompt-router.log`
- **Testing:** `tests/prompt-router-tests.sh`
- **Documentation:** This README and inline comments

### Troubleshooting

#### Common Issues

1. **Prompt Not Found**
   ```bash
   # Check available prompts
   ./ops/run-prompt-v2.sh --list

   # Search for similar prompts
   ./ops/run-prompt-v2.sh --search <term>
   ```

2. **Context Injection Fails**
   ```bash
   # Enable verbose mode for debugging
   ./ops/run-prompt-v2.sh --verbose --dry-run <prompt>
   ```

3. **Configuration Issues**
   - Verify `config/prompt-router-config.json` exists and is valid JSON
   - Check file permissions for configuration and log directories

4. **Performance Issues**
   - Use dry-run mode for testing: `--dry-run`
   - Check log files for detailed information: `logs/prompt-router.log`

#### Log Files
- **Router Logs:** `logs/prompt-router.log`
- **Test Logs:** `logs/prompt-router-test.log`

### Development

#### Adding New Features
1. Follow the modular function structure
2. Add comprehensive error handling
3. Include verbose logging
4. Update tests in `tests/prompt-router-tests.sh`
5. Update documentation

#### Testing
```bash
# Run test suite
./tests/prompt-router-tests.sh --verbose

# Manual testing
./ops/run-prompt-v2.sh --dry-run <prompt>
```

### Performance

The enhanced Prompt Router is optimized for:
- **Speed:** Fast prompt discovery and processing
- **Memory:** Efficient context injection
- **Reliability:** Comprehensive error handling
- **Maintainability:** Modular design with clear separation of concerns

### Future Enhancements

Planned features for future versions:
- **Advanced RAG:** Structured context parsing from YAML frontmatter
- **Plugin System:** Extensible prompt processing
- **Remote Context:** Support for remote context sources
- **Advanced Chaining:** Conditional prompt execution
- **Performance Monitoring:** Detailed performance metrics

## 📁 Contents

### **Files**
- `run-prompt.sh` - Enhanced prompt router with modular design and configuration support

### **Subdirectories**
- `docker/` - [Description of contents]
- `cleanup/` - [Description of contents]
- `templates/` - [Description of contents]
- `monitoring/` - [Description of contents]
- `backup/` - [Description of contents]

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
