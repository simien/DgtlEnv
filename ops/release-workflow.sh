#!/bin/bash
set -e

echo "Starting release workflow..."

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Commit local changes
echo "Committing changes..."
git add .
git commit -m "chore: codebase cleanup and centralized config" || echo "No changes to commit"

# Push current branch
echo "Pushing $CURRENT_BRANCH..."
git push origin "$CURRENT_BRANCH"

# Merge to development if not already on it
if [ "$CURRENT_BRANCH" != "development" ]; then
    echo "Merging $CURRENT_BRANCH into development..."
    git checkout development
    git pull origin development
    git merge "$CURRENT_BRANCH"
    git push origin development
fi

# Merge to production
echo "Merging development into production..."
git checkout production
git pull origin production
git merge development
git push origin production

# Return to development
echo "Returning to development..."
git checkout development

echo "Release workflow complete!"
