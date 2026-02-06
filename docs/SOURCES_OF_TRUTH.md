# Sources of Truth

> **Central Reference** - The definitive guide to DgtlEnv's configuration, structure, and standards.

This document serves as the primary index for the project's "Sources of Truth". It consolidates contact information, directory structures, prompt systems, and configuration variables into a single reference point to ensure consistency across the codebase.

## 1. Contact Information

The following contact details are the official project standards. They are programmatically defined in `config/variables.sh` and `config/project-config.json`.

| Field           | Value                     | Variable (Bash)   | Key (JSON)           |
| --------------- | ------------------------- | ----------------- | -------------------- |
| **Name**        | DgtlEnv Maintainer       | `CONTACT_NAME`    | `project.author`     |
| **Email**       | maintainer@example.com        | `CONTACT_EMAIL`   | `project.email`      |
| **Website**     | https://example.com/ | `CONTACT_WEBSITE` | `project.website`    |
| **GitHub User** | dgtlenv-maintainer                    | `CONTACT_GITHUB`  | *N/A*                |
| **Repository**  | dgtlenv-maintainer/DgtlEnv            | *N/A*             | `project.repository` |

> **Note**: To update these values, modify `config/project-config.json` and `config/variables.sh`.

## 2. Variable Directory & Configuration

The `config/` directory is the single source of truth for all project-wide variables and settings.

*   **`config/project-config.json`**: The master configuration file. Contains metadata, system targets, feature flags, and file paths.
*   **`config/variables.sh`**: Shell environment variables (derived from the JSON config where possible) for use in scripts.
*   **`config/cursor-settings.json`**: IDE-specific settings for Cursor.
*   **`config/prompt-router-config.json`**: Configuration for the prompt orchestration system.

## 3. Directory Structure & Prompts

The project follows a strict structure to maintain organization. The `prompts/` directory contains the AI interaction layer.

| Directory      | Purpose                         | Source of Truth File |
| -------------- | ------------------------------- | -------------------- |
| **`config/`**  | Configuration files & variables | `config/README.md`   |
| **`docs/`**    | Documentation & guides          | `docs/README.md`     |
| **`ops/`**     | Operational scripts & tools     | `ops/README.md`      |
| **`prompts/`** | **AI Prompts & Instructions**   | `prompts/README.md`  |
| **`scripts/`** | Utility & maintenance scripts   | `scripts/README.md`  |
| **`tests/`**   | detailed testing suites         | `tests/README.md`    |

### Prompt System
The **Prompts System** (`prompts/`) is the source of truth for AI interactions, ensuring consistent context and behavior.
*   **Categories**: Prompts are organized by function (e.g., `system-optimization`, `code-analysis`).
*   **Templates**: All prompts are built from `prompts/prompt-format-template-v1.0.0.md`.

## 4. Operational Standards
*   **Time**: All timestamps use ISO 8601 format.
*   **Versioning**: Semantic Versioning (SemVer) `MAJOR.MINOR.PATCH`.
*   **Scripts**: All scripts in `ops/` and `scripts/` must source `config/variables.sh` to use accurate contact and project info.

## 5. Workflow Standards

To maintain stability, the project enforces strict branching rules.

| Branch            | Purpose               | Rules                                                                             |
| ----------------- | --------------------- | --------------------------------------------------------------------------------- |
| **`development`** | **Primary Workspace** | All active work, testing, and new features MUST start here.                       |
| **`production`**  | Releases Only         | **NEVER** work directly on logic here. Only merge stable code from `development`. |

> [!IMPORTANT]
> **Always Work in Development**: Never commit or test directly on the `production` branch. Switch to `development` for all tasks.
