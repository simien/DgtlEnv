# DgtlEnv Coding Standards

This document defines the mandatory coding standards for the DgtlEnv project. These standards are enforced to ensure maintainability, reliability, and security.

## 1. Bash Scripting Standards

### 1.1 Boilerplate & Safety
All bash scripts MUST start with the following boilerplate to ensure safe execution:

```bash
#!/bin/bash
set -euo pipefail
```

- `-e`: Exit immediately if a command exits with a non-zero status.
- `-u`: Treat unset variables as an error.
- `-o pipefail`: Return the exit status of the last command in the pipe that failed.

### 1.2 Error Handling
- **Trap Errors**: Major scripts should implement a `cleanup` function trapped on EXIT/ERR.
- **Checks**: Always check for dependencies at the start of the script.
- **Fail Early**: Exit immediately if required files or directories are missing.

### 1.3 Logging
- DO NOT use raw `echo` for status updates.
- Use a dedicated logging function or library (e.g., `log "info" "Message"`).
- Distinguish between `[INFO]`, `[WARN]`, and `[ERROR]`.

## 2. File & Directory naming

- **Kebab-Case**: Use `kebab-case` for all file and directory names (e.g., `my-script.sh`, `user-profile.md`).
- **Extensions**: Always use proper file extensions (`.sh` for shell, `.md` for markdown).
- **Executable Bits**: Scripts in `scripts/` or `ops/` should be executable (`chmod +x`).

## 3. Security

- **Inputs**: Validate all script arguments.
- **Paths**: Avoid hardcoded absolute paths (especially those containing user names like `/Users/username/`). Use dynamic paths or `$HOME`.
- **Sensitive Data**: Never commit API keys or secrets.

## 4. Documentation

- **Headers**: Every script files must have a header comment block explaining its purpose and usage.
- **Inline Comments**: Explain *why* complex logic exists, not just *what* it does.
