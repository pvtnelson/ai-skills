---
name: code-review
description: Performs a strict, stack-agnostic code review enforcing SOLID principles, DRY, and mandatory CHANGELOG updates. Use this when reviewing PRs or finalized code in any project.
argument-hint: "[file, directory, or PR]"
allowed-tools: [Bash, Read, Glob, Grep]
---

# Code Review Protocol

When invoked to review code, execute the following steps in exact order.

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) code-review" >> ~/.claude/skill-usage.log
```

## Step 1: The CHANGELOG Gate

Check the root directory for a `CHANGELOG.md` file.

- If the file exists but does not document the current changes under an `[Unreleased]` section, immediately stop the review and output: **CHANGES REQUESTED: Update CHANGELOG.md before this code can be approved.**
- If the file does not exist, instruct the user to create one (or invoke `/init-repo` to scaffold it) before proceeding.

This gate is non-negotiable. No code review proceeds without a current CHANGELOG.

## Step 2: Gather the Changes

`$ARGUMENTS` = file path, directory, or git diff range (e.g., `HEAD~3..HEAD`, `src/`)

If a git range is given:

```bash
git diff $ARGUMENTS --stat
git diff $ARGUMENTS
```

If a path is given, read the files directly.

## Step 3: Stack-Agnostic Review

Evaluate the code against these principles:

- **Single Responsibility** — each function, class, and module does one thing well
- **DRY** — repeated logic is extracted into shared functions; no copy-paste patterns
- **Modularity** — components are sufficiently decoupled; dependencies flow in one direction
- **Testing** — adequate test coverage for new logic; bug fixes include regression tests
- **Clarity** — variable names are descriptive; complex blocks have concise comments explaining *why*
- **Error handling** — specific exceptions; errors are actionable, not swallowed
- **No dead code** — unused imports, variables, and functions are removed
- **No hardcoded secrets** — passwords, tokens, and keys belong in environment variables

## Step 4: Verdict

Output a structured review:

```markdown
## Code Review: [Subject]

### CHANGELOG Status
[PASS: Updated under [Unreleased] / FAIL: Not updated — list what's missing]

### Summary
[1-2 sentence overview]

### Issues Found

#### Critical (must fix)
- `file:line` — [description]

#### Warning (should fix)
- `file:line` — [description]

#### Nit (optional)
- `file:line` — [description]

### What's Good
- [Genuine positive feedback]

### Verdict
**[APPROVED / CHANGES REQUESTED / NEEDS DISCUSSION]**
```
