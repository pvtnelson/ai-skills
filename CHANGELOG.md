# Changelog

## [Unreleased]

### Changed
- `/iac-review` — rewritten: Glob instead of find, Grep with concrete patterns for hardcoded values, graceful skip when terraform CLI unavailable, checklists extracted to `references/iac-checklist.md`, broader IaC support (Pulumi, CloudFormation), structured output with state management table
- `/wrap-up` — rewritten: CHANGELOG gate, concrete diff-based doc update instructions, structured session summary output, commit message format with Co-Authored-By, gate check for empty changes
- `/update-docs` — rewritten: CHANGELOG gate, concrete diff-comparison instructions, gate check for empty changes, structured output summary table
- `/take-note` — rewritten: concrete 5-step brain dump transformation (extract title, group by theme, infer structure, generate backlinks, fill frontmatter), Grep for related note search, added Grep to allowed-tools
- `/sec-audit` — major overhaul: OSV.dev API vulnerability scanning (single + batch), OWASP Top 10 / CWE classification, CVE tracking table in output, infrastructure & container security checks, progressive disclosure with `references/` (owasp-top10.md, code-review-checks.md, iac-checks.md), local scanner fallback (trivy, grype, pip-audit, npm audit, govulncheck)
- `/iac-review` — replaced hardcoded bash grep with Grep tool instructions, broadened region patterns
- `/doc-gen` — API docs guide generalized beyond FastAPI
- `/plan-review` — review prompt now has dynamic project context placeholder; SKILL.md instructs populating it from CLAUDE.md/README.md
- `/mcp-builder` — replaced domain-specific examples with generic ones (GitHub API, Slack, Jira, Stripe)
- `docs/FRAMEWORK_STANDARDS.md` — replaced domain-specific scope examples and mutator skill list with generic placeholders
- `/prompt-engineer/references/conventions.md` — already clean (no changes needed)
- `/code-review` — softened CHANGELOG gate (proceed without CHANGELOG), added `gh pr diff` for PR workflow
- `/doc-gen` — fixed step numbering (5→7 skip → 5→6), replaced domain-specific CLAUDE.md template examples with generic ones
- `/codebase-analysis` — replaced "Explore agent" with "Agent tool" (correct tool name)
- `/init-repo` — removed BookStack reference, clarified /project-kickoff overlap in description
- `/prompt-engineer` — renumbered Step 2.5 → Step 3, Step 3 → Step 4 (consistent Step 0-N protocol)
- `/skill-creator` — fixed `python -m` module paths to direct script paths, removed `/cx-code-review` reference
- `/skill-optimizer` — decoupled workspace path from skill-creator directory (now `user/$SKILL_NAME/$SKILL_NAME-workspace`)

### Removed
- `docs/adr/001-initial-architecture.md` — internal planning document, not needed in public repo
- `docs/plans/mvp-plan.md` — internal planning document, not needed in public repo

### Added
- Project scaffolded with Claude Code skills framework
- 20 stack-agnostic skills across 5 categories
- setup.sh with automated validation and symlink management
- FRAMEWORK_STANDARDS.md constitution
- Post-merge git hook for auto-sync
