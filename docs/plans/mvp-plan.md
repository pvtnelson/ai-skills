# MVP Plan — ai-skills Public Template Repository

**Date:** 2026-03-08
**Status:** Draft
**Goal:** Make the repo ready for public consumption as a quality template that new users can clone and use immediately.

---

## 1. Sanitize Remaining pvtnelson References

**Priority:** P0 (blocking)

Several skills still reference the private `claude-skills` repo name and pvtnelson-specific tooling.

### Issues Found

| File | Issue |
|------|-------|
| `user/skill-manager/SKILL.md` | `SKILLS_REPO="$PROJECTS_DIR/claude-skills"` — hardcoded repo name |
| `user/skill-optimizer/SKILL.md` | `SKILLS_REPO="$PROJECTS_DIR/claude-skills"` — hardcoded repo name |
| `user/skill-creator/SKILL.md` | `mkdir -p "$PROJECTS_DIR/claude-skills/$SCOPE/$SKILL_NAME"` and CHANGELOG ref |
| `user/skill-refiner/SKILL.md` | `$PROJECTS_DIR/claude-skills/` in 3 places |
| `user/skill-creator/SKILL.md` | References `/cx-code-review` (private project-scoped skill) |
| `user/init-repo/SKILL.md` | "documentation lives in BookStack" (2 references) |
| `user/mcp-builder/SKILL.md` | Example mentions "BookStack", "Proxmox API" |
| `docs/FRAMEWORK_STANDARDS.md` | Section 4 example scopes reference complexr, homelab, website, gameservers |
| `docs/FRAMEWORK_STANDARDS.md` | Section 5 references private skill names: /hl-deploy, /hl-bump-config, /cx-build-deploy, /cx-migrate, /gsm, /write-blog |
| `user/prompt-engineer/SKILL.md` | References "claude-skills protocol" |
| `user/skill-manager/SKILL.md` | Description says "claude-skills framework" |
| `user/skill-optimizer/SKILL.md` | Description says "claude-skills" |

### Fix

- Replace `$PROJECTS_DIR/claude-skills` with `$PROJECTS_DIR/ai-skills` throughout (or better: make the repo name configurable via `.env` with a `SKILLS_REPO_NAME` variable).
- Replace BookStack references in `init-repo` with generic phrasing ("your documentation platform" or remove the opinionated stance entirely).
- Replace `/cx-code-review` reference in `skill-creator` with just `/code-review`.
- Make FRAMEWORK_STANDARDS.md section 4 examples generic (e.g., "my-webapp/", "infra/") or clearly label them as illustrative.
- Generalize FRAMEWORK_STANDARDS.md section 5 skill name references to use generic examples.
- Replace mcp-builder examples with generic ones (e.g., "GitHub API", "Slack API").
- Replace "claude-skills" naming in skill-manager and skill-optimizer descriptions.

### Acceptance Criteria

- `grep -r 'claude-skills' user/` returns zero matches
- `grep -r 'BookStack' user/` returns zero matches
- `grep -ri 'pvtnelson\|complexr' user/ docs/ examples/` returns zero matches (excluding this plan and illustrative examples in FRAMEWORK_STANDARDS.md)
- All 20 skills pass `./setup.sh` validation after changes

---

## 2. Test setup.sh on a Fresh Clone

**Priority:** P0 (blocking)

setup.sh was adapted from the private repo and must work for a first-time user who has never run it.

### Test Procedure

1. Create a temp directory, clone the repo fresh
2. Run `./setup.sh` without an existing `.env` — verify it copies `.env.example`, prints a message, and exits cleanly
3. Edit the generated `.env` with valid paths, re-run `./setup.sh`
4. Verify: all 20 skills show `[ok]`, symlinks exist in `~/.claude/skills/`, `skills-env.sh` is generated
5. Run `./setup.sh` a second time (idempotent) — verify all show `[ok] (already linked)`
6. Delete one skill symlink, re-run — verify it recreates it

### Issues to Check and Fix

- **MUST FIX:** The `.env.example` has `/path/to/your/projects` — `setup.sh` silently proceeds with this placeholder. Add a guard after sourcing `.env` that warns if `PROJECTS_DIR` doesn't exist as a directory or is still the placeholder value.
- The post-merge hook assumes `.git` exists — already handled with the `if [ -d "$REPO_DIR/.git" ]` guard. OK.
- `GITHUB_ORG` can be empty — verify this doesn't break anything.

### Acceptance Criteria

- Fresh clone + first run produces clear instructions
- Second run with configured `.env` succeeds with all `[ok]`
- No errors when `GITHUB_ORG` is empty
- Idempotent on repeated runs

---

## 3. Skill Audit — Implicit Dependencies

**Priority:** P1 (important)

Some skills reference scripts, agents, or reference files in subdirectories. Verify these all exist and are committed.

### Skills with Subdirectories

| Skill | Subdirs | Status |
|-------|---------|--------|
| `architect` | `references/` | Verify `cloud-adoption-framework.md`, `design-principles.md` exist |
| `doc-gen` | `references/` | Verify contents |
| `init-repo` | `assets/` | Verify `README.tpl.md`, `CHANGELOG.tpl.md` exist |
| `mcp-builder` | `scripts/` | Verify contents |
| `plan-review` | `references/` | Verify contents |
| `project-kickoff` | `assets/` | Verify contents |
| `prompt-engineer` | `references/` | Verify `context-engineering.md`, `conventions.md` exist |
| `skill-creator` | `agents/`, `assets/`, `references/`, `scripts/` | Verify all referenced files exist |
| `skill-manager` | `scripts/` | Verify contents |
| `take-note` | `references/` | Verify contents |

### Also Check

- `skill-creator` references `scripts.aggregate_benchmark` and `scripts.run_loop` as Python modules — verify these scripts exist and have no private dependencies.
- `skill-creator` references an `eval-viewer/generate_review.py` — verify it exists.
- `skill-creator` references `agents/grader.md`, `agents/comparator.md`, `agents/analyzer.md` — verify they exist.

### Acceptance Criteria

- Every file referenced by `cat ${CLAUDE_SKILL_DIR}/...` or `bash ${CLAUDE_SKILL_DIR}/...` in any SKILL.md exists in the repo
- No broken references

---

## 4. README Polish

**Priority:** P1 (important)

The README is solid. Minor improvements:

### Changes

- **Quick Start step 1:** Replace `<your-org>` with `pvtnelson` (the actual GitHub org) and add a note about the template button.
- **Add prerequisites section:** Claude Code must be installed. Mention minimum version if relevant.
- **Add "How It Works" one-liner:** Briefly explain that skills are markdown files symlinked to `~/.claude/skills/` where Claude Code picks them up. Currently the Architecture section covers this but it's buried.
- **Trim the Architecture section:** The README currently duplicates information from ADR-001. Keep a 2-3 sentence summary and link to the ADR.

### Do NOT Add

- No badges (adds maintenance burden for no value on a template repo)
- No screenshots or GIFs (skills are text-based)
- No extensive "philosophy" section

### Acceptance Criteria

- Prerequisites are listed
- Clone URL points to `pvtnelson/ai-skills`
- A new user can go from zero to working skills in under 5 minutes by following the README

---

## 5. CONTRIBUTING.md

**Priority:** P2 (nice-to-have)

A short CONTRIBUTING.md is warranted since this is public and MIT-licensed. Keep it minimal.

### Contents

1. How to add a skill (create dir, write SKILL.md, run setup.sh)
2. Framework standards link (must comply)
3. PR requirements: pass `./setup.sh` validation, update CHANGELOG.md
4. Skill naming conventions (from FRAMEWORK_STANDARDS.md section 6)
5. No CoC link needed for a template repo this size — add later if community grows

### Acceptance Criteria

- File exists at `CONTRIBUTING.md`
- Under 80 lines
- References FRAMEWORK_STANDARDS.md as source of truth

---

## 6. GitHub Repo Polish

**Priority:** P2 (nice-to-have)

### Actions

- **Mark as template repo:** Enable "Template repository" in Settings. This gives users a "Use this template" button that creates a clean copy (no fork relationship, no commit history). This is the right model for a skills framework — users want their own copy, not a fork.
- **Description:** "A framework for building custom Claude Code skills — reusable slash commands for any workflow"
- **Topics:** `claude-code`, `claude`, `ai-skills`, `developer-tools`, `cli`, `prompt-engineering`
- **No social preview image** — not worth creating for a template repo
- **No issue templates yet** — add if/when issues start coming in

### Acceptance Criteria

- Template repo enabled
- Description and topics set
- Repo is public (already done)

---

## 7. README: Point Users at Real Skills as Learning References

**Priority:** P3 (optional)

~~Second example skill~~ — **Cut per staff review.** The 20 included skills ARE the showcase. Adding toy examples dilutes the value.

Instead: add a "Your First Skill" section to the README that points at `user/take-note/` or `user/update-docs/` as learning references (simple, self-contained, demonstrates the full protocol).

Also: trim the "Self-Learning Loop" section in the README — it's premature for new users. Move it below Architecture or reduce to one sentence with a link.

### Acceptance Criteria

- README has a "Your First Skill" or similar section pointing at a real skill
- Self-Learning Loop section is trimmed or repositioned

---

## Execution Order

| Phase | Steps | Estimated Effort |
|-------|-------|-----------------|
| **Phase 1** (must-ship) | 1. Sanitize references, 2. Test setup.sh, 3. Skill audit | ~2 hours |
| **Phase 2** (should-ship) | 4. README polish, 5. CONTRIBUTING.md | ~45 min |
| **Phase 3** (nice-to-have) | 6. GitHub repo polish, 7. README learning refs | ~30 min |

Total: ~3 hours of focused work. Phase 1 is blocking — do not ship without it. Phase 2 is strongly recommended. Phase 3 can happen post-launch.

---

## Out of Scope

These are explicitly **not** part of the MVP:

- CI/CD pipeline (no tests to run — setup.sh IS the validator)
- Skill marketplace or registry
- Version pinning or dependency management between skills
- npm/pip packaging
- Documentation site (README + FRAMEWORK_STANDARDS.md + ADR is sufficient)
- Social preview image or marketing materials
- Automated skill testing framework (skill-creator has eval support, that's enough)

---

## Staff Engineer Review

**Verdict: APPROVED WITH CHANGES** (changes incorporated above)

Key feedback incorporated:
1. Added `setup.sh` guard requirement for unconfigured `.env` (Step 2)
2. Added FRAMEWORK_STANDARDS.md section 5 private skill names to sanitization list (Step 1)
3. Added `prompt-engineer` and `skill-manager`/`skill-optimizer` "claude-skills" references to sanitization list (Step 1)
4. Cut Step 7 second example — replaced with "point users at real skills as learning references"
5. Added note to trim Self-Learning Loop in README (Step 7)
