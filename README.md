# ai-skills

A framework for building, managing, and evolving custom [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills — reusable slash commands that extend Claude's capabilities with domain-specific workflows.

## What Are Skills?

Skills are markdown files (`SKILL.md`) that get injected into Claude Code's context when triggered. Each skill is a self-contained instruction set that tells Claude *how* to perform a specific task — from architecture reviews to security audits to project scaffolding.

Unlike one-off prompts, skills are:
- **Structured** — follow a Step 0-N protocol with logging, gates, and outputs
- **Portable** — no hardcoded paths, use runtime variables
- **Measurable** — usage tracking and feedback loops for continuous improvement
- **Self-managing** — meta skills create, refine, optimize, and archive other skills

## Skills Included (20)

### Architecture & Review
| Skill | Description |
|-------|-------------|
| `/architect` | System design evaluator — 12-factor compliance, modularity, ADRs |
| `/code-review` | Strict code review enforcing SOLID, DRY, CHANGELOG updates |
| `/sec-audit` | Security audit — secrets, dependencies, access control |
| `/iac-review` | Terraform/IaC reviewer — state management, hardcoded values |
| `/decision-critic` | Red Team stress-test for proposed architectures |
| `/plan-review` | Implementation plan + Staff Engineer subagent review |
| `/refactor-audit` | Identify technical debt without hallucinating rewrites (read-only) |
| `/codebase-analysis` | Map impact of a proposed change across the codebase (read-only) |

### Creation & Documentation
| Skill | Description |
|-------|-------------|
| `/doc-gen` | Generate or update README.md and inline docs with strict token budgets |
| `/prompt-engineer` | Craft and optimize system prompts for any LLM platform |
| `/take-note` | Quick notes formatted as strict Obsidian markdown |
| `/mcp-builder` | Guide for creating MCP servers (Python FastMCP / Node SDK) |
| `/update-docs` | Update CLAUDE.md and README.md after completing a feature |

### Meta (Framework Management)
| Skill | Description |
|-------|-------------|
| `/skill-creator` | Create new skills with eval and benchmark |
| `/skill-refiner` | Rewrite skills to match framework spec |
| `/skill-manager` | Validate, usage stats, archive, feedback, optimize |
| `/skill-optimizer` | A/B benchmarking via self-learning loop |

### Project Lifecycle
| Skill | Description |
|-------|-------------|
| `/init-repo` | Scaffold a new project with git, README, CLAUDE.md |
| `/project-kickoff` | Full orchestrator: scaffold → architecture → plan → context wipe |
| `/wrap-up` | End-of-session: update docs, commit, push |

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/<your-org>/ai-skills.git
cd ai-skills
cp .env.example .env
# Edit .env with your paths and preferences
```

### 2. Run setup

```bash
./setup.sh
```

This will:
- Validate all skills against the framework standards
- Generate `~/.claude/skills-env.sh` (shared environment)
- Symlink skills to `~/.claude/skills/` (where Claude Code finds them)
- Report results: `[ok]`, `[FAIL]`, `[WARN]` per skill

### 3. Use skills

In any Claude Code session:
```
/architect          # evaluate a system design
/code-review        # review code changes
/skill-creator      # create a new custom skill
```

## Adding Your Own Skills

### Create a new skill

```bash
mkdir user/my-skill
```

Then either write `SKILL.md` manually following the [Framework Standards](docs/FRAMEWORK_STANDARDS.md), or use the meta skill:

```
/skill-creator my-skill
```

### Skill structure

```
user/my-skill/
├── SKILL.md              # Main instruction file (≤500 lines)
├── assets/               # Templates, scaffolds (loaded on demand)
├── references/           # Checklists, guides (loaded on demand)
└── scripts/              # Executable scripts (loaded on demand)
```

### Project-scoped skills

For domain-specific skills tied to a particular project, create a directory at the repo root:

```
my-project/
├── my-project-skill/
│   └── SKILL.md
```

`setup.sh` will symlink these to the project's `.claude/skills/` directory.

## Framework Standards

Every skill must comply with the [constitution](docs/FRAMEWORK_STANDARDS.md):

1. **Step 0-N Protocol** — mandatory structure (logging → gate → core → output)
2. **Portability** — use `${CLAUDE_SKILL_DIR}` and `$PROJECTS_DIR`, never hardcode paths
3. **Progressive Disclosure** — SKILL.md is a lightweight router, heavy content in subdirs
4. **Domain Isolation** — `user/` for generic skills, project dirs for domain-specific
5. **Safety Gates** — mutator skills default to dry-run, require human confirmation

Automated enforcement runs via `setup.sh`:
- `[FAIL]` — hardcoded paths, missing Step 0
- `[WARN]` — internal refs without `${CLAUDE_SKILL_DIR}`

## Self-Learning Loop

Skills improve over time through a closed feedback loop:

```
Skill underperforms → /skill-manager feedback → ≥3 entries →
/skill-optimizer analyzes → generates V2 → diff review →
HUMAN APPROVAL → apply or reject
```

No changes are applied without explicit human approval.

## Architecture

```
ai-skills/
├── user/                      # 21 stack-agnostic global skills
│   ├── architect/
│   ├── code-review/
│   ├── ...
│   └── wrap-up/
├── docs/
│   ├── FRAMEWORK_STANDARDS.md # Constitution — source of truth
│   ├── adr/                   # Architecture Decision Records
│   └── plans/                 # Implementation plans
├── examples/                  # Example custom skills
├── setup.sh                   # Validation + symlink pipeline
├── .env.example               # Configuration template
└── CHANGELOG.md
```

## License

[MIT](LICENSE)
