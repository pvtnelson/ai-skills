# Contributing to ai-skills

Thanks for your interest in contributing! This project is a framework for building custom Claude Code skills — reusable slash commands that extend Claude's capabilities.

## Before You Start

Every skill in this repo must comply with the [Framework Standards](docs/FRAMEWORK_STANDARDS.md). Read it before writing anything. The key rules:

1. **Step 0-N Protocol** — every skill must have Step 0 (usage logging), followed by numbered steps for gates, core logic, and output
2. **Portability** — use `${CLAUDE_SKILL_DIR}` for internal file references and `$PROJECTS_DIR` for external paths. Never hardcode absolute paths
3. **Progressive Disclosure** — SKILL.md is capped at 500 lines. Move heavy content (checklists, templates, guides) to `references/`, `assets/`, or `scripts/` subdirectories
4. **Domain Isolation** — `user/` skills must be stack-agnostic. Project-specific logic belongs in a project-scoped directory
5. **Safety Gates** — skills that mutate files or deploy code must default to dry-run and require explicit user confirmation

## Creating a Skill

The fastest way to create a well-formatted skill:

```
/skill-creator my-skill
```

This walks you through intent capture, SKILL.md generation, and optional eval testing.

To clean up an existing draft:

```
/skill-refiner my-skill
```

Both tools enforce the framework standards automatically.

### Manual creation

```bash
mkdir -p user/my-skill
# Write user/my-skill/SKILL.md following the framework standards
./setup.sh  # Validate and deploy
```

### Skill directory structure

```
user/my-skill/
├── SKILL.md              # Main instruction file (required, ≤500 lines)
├── assets/               # Templates, scaffolds (loaded on demand)
├── references/           # Checklists, guides (loaded on demand)
└── scripts/              # Executable scripts (loaded on demand)
```

## Pull Request Checklist

- [ ] Skill passes `./setup.sh` validation (CI runs this automatically — PRs that fail are rejected)
- [ ] SKILL.md has valid frontmatter (`name`, `description`, `allowed-tools`)
- [ ] `name` field matches the directory name (lowercase + hyphens, max 64 chars)
- [ ] Step 0 usage logging is present
- [ ] No hardcoded paths (`/root/projects/...`, `/home/user/...`)
- [ ] CHANGELOG.md updated under `[Unreleased]`
- [ ] If adding reference files, they are loaded conditionally via `cat ${CLAUDE_SKILL_DIR}/references/...`

## CI Pipeline

Every push and PR triggers the [validate workflow](.github/workflows/validate.yml), which runs `setup.sh`. This checks:

- **agentskills.io spec** — frontmatter fields, naming conventions, description length
- **Framework standards** — no hardcoded paths, Step 0 present, proper `${CLAUDE_SKILL_DIR}` usage

If validation fails, the PR cannot be merged.

## Code Style

- **Positive framing** — "Do X because [reason]" instead of "NEVER do X"
- **Imperative mood** — "Read the file" not "You should read the file"
- **Explain the why** — models follow instructions better when they understand the reasoning

## Questions?

Open an issue or check the existing skills in `user/` for examples. `/take-note` and `/update-docs` are good starting points — small, self-contained, and demonstrate the full protocol.
