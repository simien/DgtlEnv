# DgtlEnv Naming Guidelines

## 📋 Project Name Standards

### Primary Name: DgtlEnv
- **Official Name:** DgtlEnv
- **Full Name:** DgtlEnv - Digital Environment Management
- **Source of Truth:** `README.md` (line 1)
- **Configuration:** `config/project-config.json`

### Usage Guidelines

#### ✅ Correct Usage
- "DgtlEnv" (primary name)
- "DgtlEnv - Digital Environment Management" (full name)
- "DgtlEnv project"
- "DgtlEnv system"

#### ❌ Incorrect Usage
- "DigitalEnv" (old name)
- "Digital Environment" (without DgtlEnv)
- "DgtlEnv" (inconsistent casing)

### File Naming Conventions

#### Scripts
- Use lowercase with hyphens: `create-dgtlenv-backup.sh`
- Avoid camelCase or snake_case for script names

#### Directories
- Use lowercase with hyphens: `dgtlenv-config`
- Keep existing directory structure

#### Configuration
- Use kebab-case: `dgtlenv-settings.json`
- Maintain consistency with existing patterns

### Implementation

#### Shell Scripts
```bash
# Get project name from config
PROJECT_NAME=$(jq -r '.project.name' config/project-config.json)
```

#### Documentation
```markdown
# **DgtlEnv** - Digital Environment Management
```

### Validation

Run the naming validation script:
```bash
./scripts/update-project-name.sh validate
```

This will check for:
- Remaining "DigitalEnv" references
- Consistent "DgtlEnv" usage
- Proper casing and formatting

### Migration Notes

- All "DigitalEnv" references should be updated to "DgtlEnv"
- Script names should use lowercase with hyphens
- Configuration files should reference the centralized config
- README.md serves as the authoritative source of truth
