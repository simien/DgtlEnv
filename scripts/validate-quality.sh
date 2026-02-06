#!/bin/bash

# DgtlEnv Quality Control Validator
# usage: ./scripts/validate-quality.sh

set -euo pipefail

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILURES=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[FAIL]${NC} $1"; ((FAILURES++)); }

check_bash_standards() {
    local file="$1"

    # Check Shebang
    if ! grep -q "^#!/bin/bash" "$file"; then
        error "$file: Missing #!/bin/bash shebang"
    fi

    # Check Safe Mode
    if ! grep -q "set -.*e" "$file" && ! grep -q "set -.*u" "$file"; then
         # Check for combined or separate flags. Simplistic check.
         if ! grep -q "set -euo pipefail" "$file"; then
             error "$file: Missing strict mode (set -euo pipefail)"
         fi
    fi

    # Check for hardcoded user paths (Security)
    if grep -q "/Users/" "$file"; then
        # Exclude this script itself from the check if it happens to match valid uses
        if [[ "$file" != *"validate-quality.sh"* ]]; then
             error "$file: Contains hardcoded user path '/Users/'"
        fi
    fi
}

log "Starting Quality Control Validation..."
echo "----------------------------------------"

# Find all shell scripts
while IFS= read -r file; do
    check_bash_standards "$file"
done < <(find "$PROJECT_ROOT" -type f -name "*.sh" -not -path "*/.git/*" -not -path "*/node_modules/*")

echo "----------------------------------------"
if [[ $FAILURES -eq 0 ]]; then
    log "Quality Check PASSED"
    exit 0
else
    echo -e "${RED}Quality Check FAILED with $FAILURES errors.${NC}"
    exit 1
fi
