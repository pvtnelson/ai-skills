---
name: init-repo
description: Scaffolds a new repository with standard directories, git initialization, and template-based documentation (README, CHANGELOG). Use this when starting a new project in an empty directory. Complements /project-kickoff (which handles planning and architecture decisions) — use /init-repo for the actual repo setup.
argument-hint: "[project-name] [stack]"
allowed-tools: [Bash, Read, Write, Glob]
disable-model-invocation: true
---

# Repository Initialization Protocol

When invoked to initialize a repository, execute the following steps.

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) init-repo" >> ~/.claude/skill-usage.log
```

## Step 1: Gather Input

If not provided via `$ARGUMENTS`, ask the user:
1. **Project name** (kebab-case, e.g. `my-project`)
2. **Tech stack** — one of: Python, Node/Next.js, Go, Terraform, Rust, Docker, or Other
3. **One-line description** of what the project does

## Step 2: Create GitHub Repository

Load environment and create a repo under the user's GitHub org:

```bash
source ~/.claude/skills-env.sh
cd "$PROJECTS_DIR"
gh repo create ${GITHUB_ORG}/$PROJECT_NAME --private --clone
cd $PROJECT_NAME
```

If the directory already exists or the user wants to init locally only, fall back to `git init`.

## Step 3: Directory Structure

Create standard directories:

```bash
mkdir -p src/ tests/
```

## Step 4: Generate .gitignore

**Base (always included):**
```
.env
!.env.example
*.pem
*.key
secrets/
credentials*
*.secret
.DS_Store
```

**Stack-specific additions:**

| Stack | Additional patterns |
|-------|-------------------|
| Python | `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`, `.pytest_cache/`, `.mypy_cache/`, `.coverage`, `htmlcov/` |
| Node/Next.js | `node_modules/`, `.next/`, `out/`, `dist/`, `.turbo/`, `coverage/` |
| Go | `/bin/`, `/vendor/`, `*.exe` |
| Terraform | `.terraform/`, `*.tfstate`, `*.tfstate.*`, `*.tfvars`, `!*.tfvars.example`, `crash.log` |
| Rust | `target/`, `Cargo.lock` (for libraries only) |
| Docker | `*.tar`, `.docker/` |

## Step 5: Scaffold Documentation

1. Read `${CLAUDE_SKILL_DIR}/assets/README.tpl.md` and create `README.md`, filling in:
   - `[Project Name]` with the project name
   - `[description]` with the one-line description
   - `[stack]` with the chosen tech stack

2. Read `${CLAUDE_SKILL_DIR}/assets/CHANGELOG.tpl.md` and create `CHANGELOG.md`.

3. Create `.env.example` with a placeholder:
```
# Environment variables for $PROJECT_NAME
# Copy to .env and fill in values
```

4. Create `CLAUDE.md`:
```markdown
# $PROJECT_NAME — Claude Code Instructions

## Project
$DESCRIPTION

## Tech Stack
$STACK

## Conventions
- All code changes require CHANGELOG.md updates under [Unreleased]
- Tests required for new functionality
```

## Step 6: Update Parent CLAUDE.md

Append the new project to the Projects list in `$PROJECTS_DIR/CLAUDE.md`:

```bash
# Add entry: - `project-name/` — One-line description
```

Read `$PROJECTS_DIR/CLAUDE.md` first, then use Edit to add the entry under the `## Projects` section.

## Step 7: Initial Commit

Stage specific files (never `git add -A`):

```bash
git add src/ tests/ .gitignore .env.example README.md CHANGELOG.md CLAUDE.md
git commit -m "$(cat <<'EOF'
Initial project setup

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

If a GitHub remote exists, ask the user before pushing.

## Step 8: Report

Show the created structure and next steps:

```bash
find . -not -path './.git/*' -not -path './.git' | sort
```

Remind the user:
- Run `/doc-gen` periodically to keep documentation current
- Keep README.md concise — detailed docs belong in your team's documentation platform
