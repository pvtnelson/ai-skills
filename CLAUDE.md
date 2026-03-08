# ai-skills — Claude Context

## Key Paths
- `user/` — stack-agnostic skills (symlinked to ~/.claude/skills/)
- `docs/FRAMEWORK_STANDARDS.md` — constitution, source of truth for all skill standards
- `setup.sh` — validation + symlink pipeline
- `.env` — user configuration (gitignored)

## Before You Change
- Read `docs/FRAMEWORK_STANDARDS.md` before creating or modifying skills
- Every SKILL.md must follow Step 0-N protocol
- Never hardcode paths — use `${CLAUDE_SKILL_DIR}` and `$PROJECTS_DIR`
- SKILL.md hard limit: 500 lines — extract heavy content to assets/references/scripts/

## Conventions
- Branch: main (stable)
- Commits: imperative mood, concise
- Secrets: NEVER committed — use .env (gitignored)
- All skills validated by setup.sh before symlink deployment
- Post-merge hook auto-runs setup.sh after git pull
