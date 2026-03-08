---
name: update-docs
description: "Update CLAUDE.md and README.md after completing a feature or fix. Use mid-session when you finish a piece of work but aren't wrapping up yet. For end-of-session with commit and push, use /wrap-up instead."
argument-hint: "[project]"
allowed-tools: [Bash, Read, Edit, Glob, Grep]
---

# Update Project Documentation

Focused documentation update after completing a feature or fix. Use mid-session — does NOT commit or push (that's `/wrap-up`).

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) update-docs" >> ~/.claude/skill-usage.log
```

## Step 1: Analyze Recent Changes

```bash
git diff --stat
git log --oneline -5
```

If `git diff --stat` shows no changes, output "No changes to document" and stop.

Identify: what files changed, what features were added/modified, what patterns shifted.

## Step 2: CHANGELOG Gate

Check for `CHANGELOG.md` in the project root.

- If it exists but the current changes are not reflected under `[Unreleased]`, output: **"WARNING: CHANGELOG.md is not up to date. Update it before continuing."**
- If it does not exist, note the gap but proceed.

## Step 3: Update CLAUDE.md

Read the current CLAUDE.md. Compare its content against the `git diff` output to find stale or missing information:

- **New files or modules** not reflected in Key Paths → add routing entries
- **New architecture patterns** (new dependencies, new middleware, new services) → update relevant section
- **New commands** (build, test, deploy changes) → update Conventions/Development
- **Removed code** → remove stale references

Use the Edit tool for surgical changes. Never overwrite the full file. If CLAUDE.md does not exist, skip this step.

## Step 4: Update README.md

Read the current README.md. Compare against what changed:

- **New features** → add to feature list or Architecture section
- **Changed setup or dependencies** → update Setup/Installation
- **New or changed tests** → update testing instructions
- **Invariants** → update if new non-obvious rules were introduced

Keep it short and practical (~400 words max). If README.md does not exist, skip this step.

## Step 5: Output Summary

Present what was updated:

```markdown
## Documentation Update

| File | Status | Changes |
|------|--------|---------|
| CHANGELOG.md | [updated / warning: stale / not present] | [entries added] |
| CLAUDE.md | [updated / no changes needed / not present] | [sections changed] |
| README.md | [updated / no changes needed / not present] | [sections changed] |

**Not committed** — run `/wrap-up` when ready to commit and push.
```

## Related Skills

- `/wrap-up` — end-of-session: docs + commit + push
- `/doc-gen` — generate documentation from scratch (heavier, full analysis)
