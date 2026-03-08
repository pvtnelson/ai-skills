---
name: wrap-up
description: "End-of-session wrap-up — update CLAUDE.md, README.md, CHANGELOG.md, then commit and push. Use when finishing a work session, closing out for the day, or the user says 'wrap up', 'done for now', or 'let's commit everything'."
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep]
disable-model-invocation: true
---

# End-of-Session Wrap-Up

Mandatory end-of-session routine: review changes, update docs, commit, push.

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) wrap-up" >> ~/.claude/skill-usage.log
```

## Step 1: Review What Changed

Run these commands to understand the session's work:

```bash
git diff --stat
git log --oneline -10
git status
```

Identify: new features, bug fixes, refactors, config changes. If `git diff --stat` shows no changes and there are no untracked files, output "No changes to wrap up" and stop.

## Step 2: CHANGELOG Gate

Check for `CHANGELOG.md` in the project root.

- If it exists, read it. Verify the current changes are reflected under `[Unreleased]`. If not, add entries using [Keep a Changelog](https://keepachangelog.com/) format: `Added`, `Changed`, `Fixed`, `Removed`.
- If it does not exist, note the gap in the output summary. Do not create one unless the user asks.

## Step 3: Update CLAUDE.md

Read the current CLAUDE.md. Compare its content against the `git diff` output:

- **New files or modules** not listed in Key Paths → add them
- **Changed architecture** (new dependencies, new services, new patterns) → update Architecture/Conventions
- **New commands** (test, build, deploy changes) → update Development section
- **Removed features** → remove stale references

Use the Edit tool for surgical changes. Never overwrite the full file.

## Step 4: Update README.md

Read the current README.md. Compare against what changed:

- **New features** → add to feature list or Architecture section
- **Changed setup** → update Setup/Installation
- **New tests** → update test count or testing instructions
- **Changed dependencies** → update tech stack section

Keep it short and practical. Do not exceed ~400 words.

## Step 5: Commit and Push

```bash
git status
git diff --stat
```

Present the summary to the user, then:

1. Stage changed files explicitly (never `git add -A` — list specific files)
2. Commit with a descriptive message following this format:

```bash
git commit -m "$(cat <<'EOF'
<type>: <concise summary of session work>

<optional body: key changes in bullet points>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`

3. Push to remote (ask user first if pushing to a shared branch)

## Step 6: Output Summary

Present this structured summary:

```markdown
## Session Summary

### Changes
- [bullet list of what was accomplished]

### Docs Updated
| File | What changed |
|------|-------------|
| CLAUDE.md | [changes or "no update needed"] |
| README.md | [changes or "no update needed"] |
| CHANGELOG.md | [changes or "not present"] |

### Commit
`<hash>` — <commit message first line>

### Deploy Reminders
- [list any services that need redeploying, or "none"]
```

## Related Skills

- `/update-docs` — mid-session documentation updates (no commit)
- `/doc-gen` — generate documentation from scratch
