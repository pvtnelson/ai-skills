---
name: skill-optimizer
description: Handles the Self-Learning Loop for skills — log execution failures via feedback, then optimize skills via A/B benchmarking. Use when a skill underperforms or needs data-driven improvement.
argument-hint: "[feedback|optimize] <skill-name> [args]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, Agent]
---

# Skill Optimizer (Self-Learning Loop)

Two subcommands: `feedback` (log failures) and `optimize` (generate improved V2 from accumulated feedback). The optimize flow NEVER auto-overwrites — human approval is mandatory.

`$ARGUMENTS` = subcommand and arguments

## Step 0: Usage Logging and Environment

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) skill-optimizer" >> ~/.claude/skill-usage.log
source ~/.claude/skills-env.sh
SKILLS_REPO="$PROJECTS_DIR/claude-skills"
```

## Step 1: Parse Subcommand

- `feedback <skill-name> "<context>"` — log a skill failure or underperformance
- `optimize <skill-name>` — analyze feedback, generate V2, present for approval

## Step 2: Execute

### feedback

Log a skill failure for later analysis by `optimize`.

1. Validate the skill exists:
   ```bash
   skill_path=$(find $SKILLS_REPO -name "SKILL.md" -not -path "*/archive/*" \
     -path "*/$SKILL_NAME/SKILL.md" | head -1)
   ```
   If not found, report error and list available skills.

2. Append to feedback log:
   ```bash
   echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $SKILL_NAME $FEEDBACK_CONTEXT" >> ~/.claude/skill-feedback.log
   ```

3. Report: confirm logged, show total feedback count for this skill:
   ```bash
   grep -c "^[^ ]* $SKILL_NAME " ~/.claude/skill-feedback.log 2>/dev/null || echo "0"
   ```
   Remind: run `/skill-optimizer optimize <skill-name>` when 3+ entries have accumulated.

### optimize

Analyze accumulated feedback, generate an improved V2, and present for human approval.

**Step 2a: Validate and gather feedback**

Locate the skill. Then read unresolved feedback:

```bash
grep -v "^\[RESOLVED\]" ~/.claude/skill-feedback.log 2>/dev/null | grep " $SKILL_NAME " || true
```

**Minimum threshold: 3 entries.** Fewer than 3 is noise — abort with: "Only N feedback entries (minimum 3 required). Use `/skill-optimizer feedback` to log more."

Parse into: total entries, date range, recurring patterns, most recent 10 verbatim.

**Step 2b: Prepare workspace**

```bash
workspace="$SKILLS_REPO/user/skill-creator/$SKILL_NAME-workspace"
mkdir -p "$workspace"
cp "$skill_path" "$workspace/v1-baseline.md"
```

**Step 2c: Generate V2 via subagent**

Spawn a subagent (Agent tool):

```
You are improving the skill "$SKILL_NAME" based on real-world failure data.

## Current Skill (V1 Baseline)
[Insert contents of $skill_path]

## Failure Feedback (from skill-feedback.log)
[Insert structured feedback summary]

## Your Task
1. Analyze failure patterns. Identify what the SKILL.md is missing or getting wrong.
2. Write an improved V2 preserving Step 0-N protocol, frontmatter, and structure.
3. Be surgical — fix what's broken, preserve what works. Map each change to a feedback entry.

Output the complete V2 SKILL.md content.
```

Save to `$workspace/v2-candidate.md`.

**Step 2d: Present diff**

1. Show diff: `diff -u "$workspace/v1-baseline.md" "$workspace/v2-candidate.md"`
2. Map each feedback entry to whether V2 addresses it
3. Highlight removed or significantly changed lines

**Step 2e: Optional benchmark (only with `--benchmark` flag)**

If passed, run full A/B evaluation:
1. Construct eval cases from feedback, save to `$workspace/evals.json`
2. Spawn parallel subagents for V1 and V2
3. Grade with `$SKILLS_REPO/user/skill-creator/agents/grader.md`
4. Aggregate and analyze results
5. Present alongside diff

Without `--benchmark`, the diff and feedback mapping are sufficient.

**Step 2f: STOP — Human confirmation required**

```
## Optimization Summary for /$SKILL_NAME

- Feedback entries analyzed: N
- Key changes in V2: [bullet list]
- Workspace: $workspace

**Options:**
1. **Apply V2** — overwrites SKILL.md (V1 backed up in workspace)
2. **Reject V2** — keeps V1, workspace preserved
3. **Edit V2** — tweak v2-candidate.md before applying

Which option? (1/2/3)
```

**DO NOT write to the skill's SKILL.md until the user explicitly chooses option 1 or 3.**

**Step 2g: Apply (only after confirmation)**

1. Backup: `cd $SKILLS_REPO && git add "$skill_path" && git commit -m "pre-optimize backup: $SKILL_NAME"`
2. Overwrite: `cp "$workspace/v2-candidate.md" "$skill_path"`
3. Validate: `cd $SKILLS_REPO && bash setup.sh`
4. Update CHANGELOG.md under `[Unreleased]` → `Changed`
5. Mark resolved: `sed -i "s/^\([^ ]* $SKILL_NAME \)/[RESOLVED] \1/" ~/.claude/skill-feedback.log`
6. Report: changes applied, rollback via `git revert HEAD`

## Step 3: CHANGELOG Gate

Before any git commit, verify CHANGELOG.md reflects the changes. Refuse to commit without it.

## Related Skills

- `/skill-manager` — framework management (validate, usage, archive, restore)
- `/skill-creator` — create new skills with Anthropic eval loop
- `/skill-refiner` — rewrite drafts to framework standards
