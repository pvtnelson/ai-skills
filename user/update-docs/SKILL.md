---
name: update-docs
description: "Update CLAUDE.md and README.md after completing a feature or fix. Use mid-session when you finish a piece of work but aren't wrapping up yet. For end-of-session with commit and push, use /wrap-up instead."
argument-hint: "[project]"
allowed-tools: [Bash, Read, Edit, Glob, Grep]
---

# Update Project Documentation

Focused documentation update after completing a feature or fix. Use this mid-session when you finish a piece of work but aren't done for the day.

**Does NOT commit or push** — that's what `/wrap-up` does at session end.

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) update-docs" >> ~/.claude/skill-usage.log
```

## Steps

## Step 1: Analyze Recent Changes

```bash
git diff --stat
git log --oneline -5
```

Understand what was just completed.

## Step 2: Update CLAUDE.md

Read the current CLAUDE.md first, then make targeted edits:
- Update the features list with new/changed features
- Update migration references if new migrations were added
- Update architecture notes if the design changed
- Bump the date if there's a date field
- **Never overwrite the full file** — use Edit tool for surgical changes

## Step 3: Update README.md

Read the current README.md first, then make targeted edits:
- Update feature bullets for new functionality
- Update setup instructions if they changed
- Update test count if tests were added/removed
- Keep it short and practical

## Step 4: Show What Was Updated

Display a summary of what documentation was changed so the user can review.

## Related Skills

- `/wrap-up` — end-of-session: docs + commit + push
- `/doc-gen` — generate documentation from scratch
