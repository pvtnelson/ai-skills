# ADR-001: Initial Architecture

## Status
Accepted

## Context

We want a public, open-source framework that lets developers build custom Claude Code skills — reusable slash commands that extend Claude's capabilities with domain-specific workflows. The framework must be:

1. **Self-contained** — clone, configure, run `setup.sh`, and skills are immediately available
2. **Extensible** — adding a new skill is as simple as creating a directory with a `SKILL.md`
3. **Quality-enforced** — automated validation prevents broken or non-compliant skills from being deployed
4. **Self-improving** — a feedback loop that tracks underperforming skills and generates improved versions
5. **Portable** — no hardcoded paths; works on any machine with Claude Code installed

The primary audience is developers who use Claude Code and want to systematize their workflows.

## Decision

### Architecture: Flat directory structure with convention-over-configuration

```
ai-skills/
├── user/              # Global skills (symlinked to ~/.claude/skills/)
│   └── <skill>/       # Each skill is a self-contained directory
│       ├── SKILL.md   # Main instruction file (≤500 lines)
│       ├── assets/    # Templates, scaffolds (loaded on demand)
│       ├── references/# Checklists, guides (loaded on demand)
│       └── scripts/   # Executable scripts (loaded on demand)
├── <project>/         # Project-scoped skills (symlinked to <project>/.claude/skills/)
├── archive/           # Sunset skills (preserved but unlinked)
├── docs/              # Framework standards, ADRs, plans
├── examples/          # Example skills for new users
├── setup.sh           # Single-command validation + deployment
└── .env               # User-specific configuration (gitignored)
```

### Key architectural decisions:

**1. Skills as markdown, not code**
Skills are SKILL.md files — markdown with YAML frontmatter — not executable code. Claude Code's runtime injects them into context. This means:
- No build step, no compilation, no runtime dependencies
- Version control via git (full diff history)
- Human-readable by design

**2. Progressive disclosure via subdirectories**
SKILL.md is a lightweight router (≤500 lines). Heavy content (templates, reference docs, scripts) lives in subdirectories and is loaded on demand via `cat ${CLAUDE_SKILL_DIR}/...`. This keeps the context window lean — every token in SKILL.md is injected on every invocation.

**3. Convention-based deployment via setup.sh**
A single script handles validation, environment generation, and symlink creation. No package manager, no registry. The git repo IS the package. Post-merge hooks keep symlinks in sync after `git pull`.

**4. Constitution-driven quality**
`FRAMEWORK_STANDARDS.md` defines 5 mandatory standards. `setup.sh` enforces them automatically:
- `[FAIL]` — hardcoded paths, missing Step 0 (blocks deployment)
- `[WARN]` — missing `${CLAUDE_SKILL_DIR}` in internal references

**5. Two-tier skill scoping**
- `user/` — stack-agnostic skills available in all projects
- `<project>/` — domain-specific skills scoped to a single project

This prevents domain pollution while allowing specialization.

**6. Self-learning loop (human-in-the-loop)**
Feedback → pattern analysis → V2 generation → diff review → human approval → deploy. No autonomous changes — every skill modification requires explicit human approval.

### Alternatives Considered

- **npm/pip package** — rejected because skills are markdown, not code. A package manager adds unnecessary complexity and a build step.
- **Central registry / marketplace** — rejected because it adds hosting, auth, and curation overhead. Git repos are already a distribution mechanism.
- **Fork-based templating (GitHub template repo)** — considered but rejected for v1. A template repo loses upstream improvements. Clean clone + configure is simpler. Can revisit if adoption grows.
- **Monorepo with domain skills included** — rejected because domain skills contain personal infrastructure details. Clean separation (public generic + private domain) is safer and more useful to others.

## Consequences

### Easier
- Adding skills: create dir + SKILL.md, run `setup.sh`
- Sharing skills: copy a skill directory into another repo
- Quality enforcement: automated by setup.sh on every deploy
- Upstream improvements: `git pull` + post-merge hook handles everything

### Harder
- Discovery: no central index of available skills (mitigated by README table)
- Cross-repo skill sharing: requires manual copy (no package manager)
- Skill dependencies: no formal dependency system between skills (by design — keeps them independent)

### Risks
- **Context window pressure**: each invoked skill consumes tokens. Progressive disclosure mitigates but doesn't eliminate this.
- **Claude Code API changes**: skills depend on Claude Code's skill loading mechanism (SKILL.md frontmatter format). Breaking changes upstream would require migration.
- **Skill sprawl**: without discipline, the repo can accumulate low-value skills. Mitigated by sunset protocol (archive after 30 days of zero usage).
