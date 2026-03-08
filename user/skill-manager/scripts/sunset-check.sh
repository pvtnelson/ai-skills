#!/usr/bin/env bash
# Sunset Protocol candidate detection
# Finds skills with zero invocations in the last 30 days.
# Usage: ./sunset-check.sh <skills-repo-path>
set -euo pipefail

SKILLS_REPO="${1:?Usage: sunset-check.sh <skills-repo-path>}"
USAGE_LOG="$HOME/.claude/skill-usage.log"

# Get all active skill names
active_skills=$(find "$SKILLS_REPO" -name "SKILL.md" -not -path "*/archive/*" \
  -exec head -10 {} \; | grep "^name:" | sed 's/^name: *//' | sort)

# Get skills invoked in the last 30 days
cutoff=$(date -u -d "30 days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
  || date -u -v-30d +%Y-%m-%dT%H:%M:%SZ)
recent_skills=$(awk -v cutoff="$cutoff" '$1 >= cutoff {print $2}' "$USAGE_LOG" 2>/dev/null | sort -u)

# Compare and output candidates
found=0
for skill in $active_skills; do
  if ! echo "$recent_skills" | grep -qx "$skill"; then
    echo "SUNSET CANDIDATE: /$skill — zero invocations in 30 days"
    echo "  → Run: /skill-manager archive $skill"
    found=$((found + 1))
  fi
done

if [ "$found" -eq 0 ]; then
  echo "No sunset candidates — all skills have been used in the last 30 days."
fi
