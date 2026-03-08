---
name: project-kickoff
description: Orchestrates the creation of a completely new project. Guides the user through scaffolding, architectural design, and planning before any code is written.
argument-hint: "[project name and brief description]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, Agent]
disable-model-invocation: true
---

# New Project Orchestrator

Scaffold, architect, plan, clear. No code is written until all three phases are approved.

When invoked, execute the following steps in exact order.

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) project-kickoff" >> ~/.claude/skill-usage.log
```

## Step 1: Gather Input

Ask the user for (skip any already provided in `$ARGUMENTS`):

1. **Project name** — lowercase, hyphenated (e.g. `invoice-api`)
2. **Project type** — one of: `web-app`, `cli-tool`, `library`
3. **Tech stack** — e.g. FastAPI + PostgreSQL, Next.js, Go CLI
4. **One-sentence purpose**

## Step 2: Scaffold

Create the project at `$PROJECTS_DIR/<project-name>/`.

### Directory structure by project type

| Type | Source dirs | Notes |
|------|-----------|-------|
| `web-app` | `src/`, `tests/` | Standard layout |
| `cli-tool` (Go) | `cmd/<name>/`, `internal/`, `tests/` | Go convention |
| `cli-tool` (other) | `src/`, `tests/` | Standard layout |
| `library` | `src/`, `tests/`, `examples/` | Include examples |

All types also get: `docs/plans/`, `docs/adr/`

### Files to generate

**`.gitignore`** — stack-appropriate, always including:
```
.env
*.pem
*.key
secrets/
credentials*
*.secret
```

**`README.md`**, **`CLAUDE.md`**, **`CHANGELOG.md`** — read and populate templates from:

```bash
cat ${CLAUDE_SKILL_DIR}/assets/README.tpl.md
cat ${CLAUDE_SKILL_DIR}/assets/CLAUDE.tpl.md
cat ${CLAUDE_SKILL_DIR}/assets/CHANGELOG.tpl.md
```

Replace `{{placeholders}}` with project-specific values from Step 1. README ~400 words max, CLAUDE.md ~200 words max.

### Init and commit

```bash
cd $PROJECTS_DIR/<project-name>
git init
source ~/.claude/skills-env.sh
gh repo create ${GITHUB_ORG}/<project-name> --source=. --remote=origin
git add .gitignore README.md CLAUDE.md CHANGELOG.md src/ tests/ docs/
git commit -m "chore: scaffold project structure

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push -u origin main
```

Stage files explicitly — never use `git add -A` to avoid committing `.env` or secrets. Do not create `.gitkeep` files.

Output: **"Scaffolding complete. Moving to architecture design."**

## Step 3: Architecture Design

If the user already stated the business goal in Step 1, confirm it. Otherwise ask: **"What is the core business goal?"**

Once confirmed:

1. Create `docs/adr/`
2. Apply the `/architect` evaluation framework. For **cli-tool** projects, evaluate only applicable 12-factor items (config, logs, disposability) and mark others N/A.
3. Draft `docs/adr/001-initial-architecture.md` using the template:

```bash
cat ${CLAUDE_SKILL_DIR}/assets/ADR-001.tpl.md
```

Replace `{{placeholders}}` with project-specific values.

4. Present to user: **"Review ADR-001. Reply APPROVED or tell me what to change."**

Do NOT proceed until user explicitly approves.

Once approved: update status to `Accepted`, backfill README.md Architecture section, commit:

```bash
git add docs/adr/001-initial-architecture.md README.md
git commit -m "docs: ADR-001 initial architecture — accepted

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push
```

Output: **"Architecture approved. Moving to MVP planning."**

## Step 4: The Build Blueprint

Invoke `/plan-review`:

1. Draft MVP plan based on ADR-001 and business goal.
2. Spawn Staff Engineer subagent. For the product review: adapt to the project's target audience — end-users for web-apps, operators/sysadmins for cli-tools, consuming developers for libraries.
3. Iterate per `/plan-review` rules (max 3 rounds).
4. Save to `docs/plans/mvp-plan.md`, commit:

```bash
git add docs/plans/mvp-plan.md
git commit -m "docs: MVP implementation plan — approved

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push
```

## Step 5: The Context Wipe

Output verbatim:

---

**Project kickoff complete. Three artifacts committed:**

1. **Scaffold** — project structure, README.md, CLAUDE.md, CHANGELOG.md
2. **ADR-001** — `docs/adr/001-initial-architecture.md`
3. **MVP Plan** — `docs/plans/mvp-plan.md`

**Type `/clear` to wipe context, then: "Read `docs/plans/mvp-plan.md` and execute step 1."**

---

Do NOT offer to begin implementation in this context.

## Related Skills

- `/architect` — system design evaluation (Step 3)
- `/plan-review` — staff engineer review (Step 4)
- `/doc-gen` — documentation with strict token budgets
- `/code-review` — review code after implementation
