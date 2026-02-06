# Shell Script Libraries

This directory contains shared shell script libraries used for sourcing common functions across the codebase.

## Libraries
- `core.sh`: Fundamental definitions, color codes, and environment checks.
- `logging.sh`: Standardized logging functions (`log_info`, `log_error`, etc.) to ensure consistent output format.
- `ui.sh`: User interface helpers, including spinners, progress bars, and formatted headers.

## Usage
Source these libraries in your scripts:
```bash
source "$PROJECT_ROOT/ops/lib/core.sh"
source "$PROJECT_ROOT/ops/lib/logging.sh"
```
