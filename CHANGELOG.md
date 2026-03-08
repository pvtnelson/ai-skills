# Changelog

## [Unreleased]

### Changed
- `/sec-audit` — major overhaul: OSV.dev API vulnerability scanning (single + batch), OWASP Top 10 / CWE classification, CVE tracking table in output, infrastructure & container security checks, progressive disclosure with `references/` (owasp-top10.md, code-review-checks.md, iac-checks.md), local scanner fallback (trivy, grype, pip-audit, npm audit, govulncheck)
- `/iac-review` — replaced hardcoded bash grep with Grep tool instructions, broadened region patterns
- `/doc-gen` — API docs guide generalized beyond FastAPI
- `/plan-review` — review prompt now has dynamic project context placeholder; SKILL.md instructs populating it from CLAUDE.md/README.md
- `/mcp-builder` — replaced domain-specific examples with generic ones (GitHub API, Slack, Jira, Stripe)
- `docs/FRAMEWORK_STANDARDS.md` — replaced domain-specific scope examples and mutator skill list with generic placeholders
- `/prompt-engineer/references/conventions.md` — already clean (no changes needed)

### Added
- Project scaffolded with Claude Code skills framework
- 20 stack-agnostic skills across 5 categories
- setup.sh with automated validation and symlink management
- FRAMEWORK_STANDARDS.md constitution
- Post-merge git hook for auto-sync
