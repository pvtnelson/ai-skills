---
name: doc-gen
description: Generate or update README.md and inline documentation for a project
argument-hint: "[project or directory]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep]
---

# Documentation Generator

Generate or refresh project documentation with strict token budgets. README.md captures invisible knowledge (the why, not the what). CLAUDE.md is a routing table, not a manual.

When invoked, execute the following steps in exact order.

`$ARGUMENTS` = project path or specific doc task (e.g., `$PROJECTS_DIR/my-project`, `readme`, `api-docs`)

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) doc-gen" >> ~/.claude/skill-usage.log
```

## Step 1: The CHANGELOG Gate

Check the project root for a `CHANGELOG.md` file.

- If the file exists but does not document the current changes under an `[Unreleased]` section, output: **WARNING: CHANGELOG.md is not up to date. Update it before or after generating docs.**
- If the file does not exist, note this in the output and recommend creating one.

## Step 2: Analyze the Project

Read the project structure and key files:

- Directory tree (max depth 3, excluding node_modules, .git, __pycache__, .next, venv)
- Existing README.md, CLAUDE.md
- Package manifests (package.json, requirements.txt, pyproject.toml)
- API route definitions (if applicable)

Determine the **scope**:

- **Project root** — generating top-level README.md and CLAUDE.md
- **Subdirectory** — generating a localized CLAUDE.md index (see Step 4)

## Step 3: Generate README.md (~400 words max)

If the task is `readme` or no specific task given, generate or update README.md.

**Budget: ~400 words maximum.** This is a hard limit. README.md captures invisible knowledge — architecture decisions, invariants, and the "why" that cannot be inferred from reading the code.

Required structure:

```markdown
# project-name

One-line description.

## Architecture

Key components and how they connect. Document the WHY behind structural
decisions (e.g., "PostgreSQL RLS chosen over application-layer auth because
multi-tenant isolation must survive ORM bugs"). Reference ADRs if they exist.

## Invariants

Non-obvious rules that must hold true (e.g., "All PII fields use MultiFernet
encryption — never store plaintext", "RLS policies require set_config per
request — middleware handles this").

## Setup

Minimal setup steps in a code block.

## Development

How to run tests, build, deploy. Commands only, no prose.
```

Rules:

- Do NOT document what the code already says (no function lists, no API route tables in README)
- Do NOT add badges, shields, or decorative elements
- Do NOT exceed ~400 words — if you need more, the README is explaining too much
- Focus on decisions, constraints, and gotchas that a new developer would not discover from reading code alone
- Use code blocks for all commands

## Step 4: Generate CLAUDE.md (~150 words max)

**Budget: ~150 words maximum.** CLAUDE.md is a routing table, not documentation. It tells Claude where to look, not what the code does.

### Project-root CLAUDE.md

For a top-level project CLAUDE.md:

```markdown
# project-name — Claude Context

## Key Paths
- `src/` — Application source code
- `tests/` — Test suite
- `config/` — Configuration files

## Before You Change
- Auth: read README.md § Invariants first
- DB schema: check migration history before modifying models
- Frontend: rebuild after component changes

## Conventions
- Commit style: imperative mood, concise
- Tests required for new functionality
```

Rules:

- Only routing and trigger conditions — never explain code
- Each entry answers: "If you are about to do X, read Y first"
- ~150 words maximum

### Subdirectory (localized) CLAUDE.md

If `/doc-gen` is invoked inside a specific subdirectory (not the project root), generate a tiny localized CLAUDE.md that acts purely as an index:

```markdown
# src/api/ — Claude Context

- Modifying models → read ../../README.md § Architecture
- Adding a new route → follow pattern in routes/example.py
- Changing auth flow → read ../../README.md § Authentication
```

Rules:

- Maximum 5 routing entries
- Relative paths only
- No explanations — only trigger conditions pointing elsewhere
- Under 50 words

## Step 5: Inline Comments & API Docs (on demand)

If the task is `api-docs`, `comments`, or `inline`, read the formatting rules:

```bash
cat ${CLAUDE_SKILL_DIR}/references/api-docs-guide.md
```

Otherwise, skip this step.

## Step 6: Output Summary

Present what was generated or updated:

- List each file created/modified with its word count
- Flag any file that exceeded its budget (README >400 words, CLAUDE.md >150 words) and trim it
- Note any missing CHANGELOG entry from Step 1

## Related Skills

- `/code-review` — enforces CHANGELOG gate on code changes
- `/update-docs` — lighter-weight mid-session doc refresh
