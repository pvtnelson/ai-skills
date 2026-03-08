---
name: skill-refiner
description: Standards guardian — takes a rough skill draft and rewrites it to match agentskills.io spec, positive framing, 500-line limit, proper directory structure, and usage logging convention. Use when creating or cleaning up a skill. For creating skills from scratch with evaluation, use /skill-creator instead.
argument-hint: "[skill-name]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep]
---

# Skill Refiner

Takes a rough skill draft and rewrites it to match framework standards.

`$ARGUMENTS` = path to a draft SKILL.md, or a description of the skill to create

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) skill-refiner" >> ~/.claude/skill-usage.log
```

## Step 0.5: Read the Constitution

Before modifying any skill, read and strictly adhere to:

```bash
cat ${CLAUDE_SKILL_DIR}/../../docs/FRAMEWORK_STANDARDS.md
```

This defines the mandatory Step 0-N protocol, portability rules, progressive disclosure, domain isolation, and safety gates.

## Step 1: Read the Input

If `$ARGUMENTS` is a file path, read it. If it's a description, use it as the basis for a new skill.

Determine target scope (`user/` for global skills, or a project-scoped directory). Ask the user if unclear.

## Step 2: Refine

### Frontmatter

Ensure YAML frontmatter complies with agentskills.io:

| Field | Rule |
|-------|------|
| `name` | Required. Lowercase + hyphens, no consecutive hyphens, max 64 chars, must match dir name |
| `description` | Required. Max 1024 chars. What it does AND when to use it (slightly "pushy" for triggering) |
| `argument-hint` | Optional. Short hint for skills that accept `$ARGUMENTS` |
| `allowed-tools` | Optional. List of Claude Code tools the skill needs |
| `disable-model-invocation` | Optional. `true` for action skills with side effects (deploy, migrate, build) |

Remove non-spec fields: `user-invocable`, `compatibility`, `metadata`.

### Positive Framing

Rewrite negative instructions as positive ones with reasoning. "NEVER do X" becomes "Do Y because [reason]". Models follow instructions better when they understand the why.

### Protocol Structure

Restructure body to: Step 0 (logging) → Step 1 (gate/validation) → Step 2 (core work) → Step 3 (output).

### Size Limit

If body exceeds 500 lines: move reference material to `references/`, scripts to `scripts/`, keep SKILL.md as orchestration with pointers.

### Directory Structure

```
<scope>/skill-name/
  SKILL.md              # Required
  scripts/              # Optional — only if needed
  references/           # Optional — on-demand context
  assets/               # Optional — templates, static files
```

No empty subdirectories. Verify correct scope directory under `$PROJECTS_DIR/claude-skills/`.

### Validation

```bash
cd "$PROJECTS_DIR/claude-skills" && bash setup.sh 2>&1 | grep -E "$(basename "$SKILL_DIR")"
```

## Step 3: Output and CHANGELOG

Present the refined skill, list changes from the original, run validation.

Update `$PROJECTS_DIR/claude-skills/CHANGELOG.md` under `[Unreleased]`.

### Final Checklist

- [ ] Frontmatter: `name` + `description` (spec-compliant), name matches dir
- [ ] Description says what AND when, body follows Step 0-N protocol
- [ ] Positive framing, under 500 lines, usage logging in Step 0
- [ ] Clean directory structure, correct scope, CHANGELOG updated
- [ ] Passes `setup.sh` validation
