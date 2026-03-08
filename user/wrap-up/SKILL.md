---
name: wrap-up
description: "End-of-session wrap-up — update CLAUDE.md, README.md, MEMORY.md, then commit and push. Use when finishing a work session, closing out for the day, or the user says 'wrap up', 'done for now', or 'let's commit everything'."
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep]
disable-model-invocation: true
---

# End-of-Session Wrap-Up

This is the **mandatory end-of-session routine**. Run this every time before closing a session.

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) wrap-up" >> ~/.claude/skill-usage.log
```

## Steps

## Step 1: Review What Was Accomplished

- Run `git diff --stat` and `git log --oneline -10` to see what changed this session
- Identify the key changes: new features, bug fixes, refactors, config changes

## Step 2: Update CLAUDE.md

Read the current CLAUDE.md in the project root first, then make targeted edits:
- Add/update feature descriptions for new work
- Update migration list if new migrations were added
- Update key architecture notes, dates, version numbers
- Remove outdated information
- **Never overwrite the full file** — use Edit tool for surgical changes

## Step 3: Update README.md

Read the current README.md first, then make targeted edits:
- Update feature list if new features were added
- Update setup instructions if they changed
- Update test count if tests were added
- Keep it short and practical

## Step 4: Update MEMORY.md

If new stable knowledge was gained (architecture decisions, gotchas, patterns):
- Read `~/.claude/projects/-root/memory/MEMORY.md` (the canonical copy — the other location is a symlink)
- Make targeted edits to add new information
- Never duplicate existing entries — update in place
- Keep under 200 lines

## Step 5: Show Changes and Commit

```
git status
git diff --stat
```

- Stage all changed files (be specific, avoid staging secrets)
- Commit with a descriptive message summarizing the session's work
- Push to remote

## Step 6: Deployment Reminder

If deployed services were changed (systemd units, Docker stacks, config files):
- Remind the user which services need redeploying
- Show the relevant deploy command

## Related Skills

- `/update-docs` — mid-session documentation updates (no commit)
