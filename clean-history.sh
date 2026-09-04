#!/usr/bin/env bash
#
# Every run: takes the CURRENT working tree state (including any
# uncommitted/new changes) and replaces all of git history with a single
# fresh "Initial commit", then force-pushes it. Previous history is
# discarded — irreversible for anyone who doesn't have a copy of it.
#
# Usage: ./clean-history.sh [--yes]
#   --yes   skip the confirmation prompt (for non-interactive use)

set -euo pipefail

REMOTE="origin"
BRANCH="main"
TMP_BRANCH="clean-history"

cd "$(git rev-parse --show-toplevel)"

if [[ "${1:-}" != "--yes" ]]; then
  read -r -p "This will DELETE all git history on '$BRANCH' and force-push to '$REMOTE/$BRANCH'. Continue? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# Clean up a leftover tmp branch from a previous interrupted run.
git branch -D "$TMP_BRANCH" 2>/dev/null || true

git checkout --orphan "$TMP_BRANCH"
git add -A
git commit -m "Initial commit"

git branch -D "$BRANCH"
git branch -m "$BRANCH"

git push --force "$REMOTE" "$BRANCH"

echo "Done. History squashed and force-pushed to $REMOTE/$BRANCH."
