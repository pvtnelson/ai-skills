---
name: skill-manager
description: Manage the claude-skills framework — validate, usage stats, archive unused skills (Sunset Protocol), restore archived skills, improve skills, and update the CHANGELOG. Use when managing, auditing, or maintaining the skills framework.
argument-hint: "[validate|usage|list|improve|archive|restore|changelog] [args]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, Agent]
---

# Skill Manager Protocol

Meta-skill for managing the claude-skills framework. Subcommands: `validate`, `usage`, `list`, `improve`, `archive`, `restore`, `changelog`.

For feedback logging and optimization, use `/skill-optimizer`.

`$ARGUMENTS` = subcommand and optional arguments

## Step 0: Usage Logging and Environment

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) skill-manager" >> ~/.claude/skill-usage.log
source ~/.claude/skills-env.sh
SKILLS_REPO="$PROJECTS_DIR/claude-skills"
```

## Step 1: Parse Subcommand

Extract from `$ARGUMENTS`:
- `validate` — run spec validation
- `usage` — usage report with sunset candidates
- `list` — list all active and archived skills
- `improve <skill-name>` — invoke skill-creator
- `archive <skill-name>` — sunset a skill (move to archive/)
- `restore <skill-name> <scope>` — restore from archive
- `changelog [description]` — read or update CHANGELOG

## Step 2: Execute Subcommand

### validate

```bash
cd $SKILLS_REPO && bash setup.sh 2>&1 | grep -E '\[FAIL\]|\[WARN\]|\[ok\]|\[removed\]|\[archived\]'
```

Report: total active skills, passed, warnings, failures, archived count.

### usage

```bash
cat ~/.claude/skill-usage.log 2>/dev/null || echo "No usage data yet"
```

Generate: total invocations, top 5 skills, last 10 invocations, weekly trend (4 weeks).

Then identify **Sunset Protocol candidates** by executing:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/sunset-check.sh "$SKILLS_REPO"
```

### list

```bash
find $SKILLS_REPO -name "SKILL.md" -not -path "*/archive/*" | sort
find $SKILLS_REPO/archive -name "SKILL.md" 2>/dev/null | sort
```

Group by scope (user-level, then per-project). Show name and description.

### improve

`improve <skill-name>`:

1. Locate the skill in `$SKILLS_REPO/`
2. Read its current SKILL.md
3. Check usage stats and git log: `git log --oneline -5 -- <skill-path>/`
4. Invoke the `/skill-creator` workflow to propose improvements
5. Present changes to the user before applying

### archive (Sunset Protocol)

`archive <skill-name>`:

1. Locate: `find $SKILLS_REPO -name "SKILL.md" -not -path "*/archive/*" -path "*/$SKILL_NAME/SKILL.md"`
2. Confirm with user: show name, description, last usage date, invocation count
3. Move: `mv "$skill_dir" $SKILLS_REPO/archive/`
4. Update CHANGELOG.md under `[Unreleased]` → `Deprecated`
5. Run: `cd $SKILLS_REPO && bash setup.sh` (severs symlinks)
6. Report: skill moved, symlink removed, restorable via `/skill-manager restore`

### restore

`restore <skill-name> <target-scope>` where scope is: `user` or any project-scoped directory at the repo root.

1. Locate in archive: `find $SKILLS_REPO/archive -path "*/$SKILL_NAME/SKILL.md"`
2. Move: `mv "$archived_dir" "$SKILLS_REPO/$TARGET_SCOPE/$SKILL_NAME"`
3. Update CHANGELOG.md under `[Unreleased]` → `Added`
4. Run: `cd $SKILLS_REPO && bash setup.sh` (creates symlinks)
5. Report: skill restored, symlink created

### changelog

```bash
cat $SKILLS_REPO/CHANGELOG.md
```

If `$ARGUMENTS` includes a description, add a dated entry.

## Step 3: CHANGELOG Gate

Applies to ALL subcommands that modify skills (`archive`, `restore`, `improve`).

Before any git commit, verify CHANGELOG.md reflects the changes. Refuse to commit without an updated CHANGELOG.

## Related Skills

- `/skill-optimizer` — feedback logging and self-learning optimization loop
- `/skill-creator` — Anthropic eval loop for creating new skills
- `/skill-refiner` — rewrite drafts to match framework standards
