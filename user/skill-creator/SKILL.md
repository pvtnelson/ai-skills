---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
argument-hint: "[skill-name]"
allowed-tools: [Bash, Read, Write, Glob, Agent]
---

# Skill Creator

Create new skills and iteratively improve existing ones through evaluation and benchmarking.

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) skill-creator" >> ~/.claude/skill-usage.log
```

## Step 0.5: Read the Constitution

Before drafting, generating, or modifying any skill, read and strictly adhere to:

```bash
cat ${CLAUDE_SKILL_DIR}/../../docs/FRAMEWORK_STANDARDS.md
```

This defines the mandatory Step 0-N protocol, portability rules, progressive disclosure, domain isolation, and safety gates. Every skill you create must comply.

## Overview

The skill creation workflow:

1. Capture intent — understand what the skill should do
2. Write a SKILL.md draft with proper structure
3. Create test prompts and run them (with-skill vs baseline)
4. Evaluate results qualitatively and quantitatively
5. Iterate based on feedback
6. Optimize the description for reliable triggering

Figure out where the user is in this process and help them progress. If they say "I want a skill for X", start from step 1. If they already have a draft, jump to evaluation. If they say "just vibe with me", skip the formal eval loop.

## Step 1: Capture Intent

Start by understanding what the user wants. The conversation may already contain a workflow to capture (e.g., "turn this into a skill"). If so, extract the tools used, sequence of steps, corrections made, and input/output formats.

Ask (or extract from context):
1. What should this skill enable Claude to do?
2. When should this skill trigger? (phrases, contexts)
3. What's the expected output format?
4. Which **scope** should it live in?
   - `user/` — general-purpose, available everywhere
   - `<project>/` — project-specific (create a directory at repo root matching the project name)
5. Should we set up test cases? (suggest based on skill type — objective outputs benefit from tests, subjective ones often don't)

## Step 2: Interview and Research

Ask about edge cases, input/output formats, example files, success criteria, and dependencies. Wait to write test prompts until this is clear.

Check available MCPs for research (docs, similar skills, best practices). Use subagents for parallel research when available.

## Step 3: Write the SKILL.md

### Skill Directory Structure

```
<scope>/<skill-name>/
  SKILL.md          (required)
  scripts/           (optional — executable code for deterministic tasks)
  references/        (optional — docs loaded into context as needed)
  assets/            (optional — templates, icons, fonts used in output)
```

Place the skill in the correct scope directory:
```bash
source ~/.claude/skills-env.sh
mkdir -p "$SKILLS_REPO/$SCOPE/$SKILL_NAME"
```

### Frontmatter (required)

```yaml
---
name: skill-name
description: What the skill does and when to trigger it. Include specific contexts and phrases. Make descriptions slightly "pushy" to combat under-triggering — e.g., "Use this skill whenever the user mentions dashboards, data visualization, or metrics, even if they don't explicitly ask for a dashboard."
allowed-tools: [Bash, Read, Write]
---
```

### Body Structure

Follow the protocol pattern used across the framework:

- **Step 0**: Usage logging (`echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $SKILL_NAME" >> ~/.claude/skill-usage.log`)
- **Step 1**: Gate/validation (check preconditions)
- **Step 2**: Core logic (the actual work)
- **Step 3**: Output/report

### Writing Guidelines

- Use imperative form in instructions
- Use positive framing ("do X when Y") instead of negative constraints
- Explain the reasoning behind instructions so the model understands intent
- Keep SKILL.md under 500 lines; use `references/` for overflow with clear pointers
- For large reference files (>300 lines), include a table of contents
- For multi-domain skills, organize by variant in `references/` (e.g., `aws.md`, `gcp.md`)

### Output Format Pattern

```markdown
## Report structure
Use this exact template:
# [Title]
## Summary
## Findings
## Recommendations
```

### Examples Pattern

```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

## Step 4: Integrate with Framework

After writing the skill, register it:

```bash
cd "$SKILLS_REPO" && bash setup.sh
```

This validates the SKILL.md against the agentskills.io spec and creates the symlink in `~/.claude/skills/`.

## Step 5: Create Test Cases

Write 2-3 realistic test prompts — what a real user would actually say. Share them with the user for confirmation before running.

Save test cases to `<skill-dir>/evals/evals.json`. See `${CLAUDE_SKILL_DIR}/references/schemas.md` for the full schema.

## Step 6: Run and Evaluate

This section is one continuous sequence. Put results in `<skill-name>-workspace/` as a sibling to the skill directory. Organize by iteration (`iteration-1/`, `iteration-2/`) and eval (`eval-0/`, `eval-1/`).

### 6a: Spawn runs

For each test case, spawn two subagents in the same turn — one with the skill, one without (baseline).

### 6b: Draft assertions

While runs are in progress, draft quantitative assertions. Update `eval_metadata.json` files and `evals/evals.json`.

### 6c: Capture timing

Save `total_tokens` and `duration_ms` from task notifications to `timing.json`.

### 6d: Grade and aggregate

1. Grade each run using `${CLAUDE_SKILL_DIR}/agents/grader.md`
2. Aggregate: `python ${CLAUDE_SKILL_DIR}/scripts/aggregate_benchmark.py <workspace>/iteration-N --skill-name <name>`
3. Analyze using `${CLAUDE_SKILL_DIR}/agents/analyzer.md`
4. Launch viewer: `python ${CLAUDE_SKILL_DIR}/eval-viewer/generate_review.py <workspace>/iteration-N --skill-name "my-skill" --benchmark <workspace>/iteration-N/benchmark.json`

### 6e: Read feedback

Read `feedback.json` after user review. Empty feedback means it was fine.

## Step 7: Iterate

1. Generalize from feedback — avoid overfitting to specific test cases
2. Keep the prompt lean — remove things that aren't pulling their weight
3. Explain the why — help the model understand reasoning behind instructions
4. Look for repeated work across test cases — bundle common scripts

## Step 8: Optimize Description

Run the optimization loop to improve skill triggering:

```bash
python ${CLAUDE_SKILL_DIR}/scripts/run_loop.py \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id> \
  --max-iterations 5 \
  --verbose
```

## Step 9: CHANGELOG Gate

After creating or modifying a skill, update the project's `CHANGELOG.md` under `[Unreleased]`. Add the skill name and what changed. This is enforced by `/code-review`.

## Dependencies

- **`claude` CLI**: Required for `${CLAUDE_SKILL_DIR}/scripts/run_eval.py` (uses `claude -p` for eval runs)
- **Python 3**: Required for all scripts in `scripts/`
- **`setup.sh`**: Run after creating/modifying skills to validate and symlink

## Reference Files

- `${CLAUDE_SKILL_DIR}/agents/grader.md` — Evaluate assertions against outputs
- `${CLAUDE_SKILL_DIR}/agents/comparator.md` — Blind A/B comparison between two outputs
- `${CLAUDE_SKILL_DIR}/agents/analyzer.md` — Analyze why one version beat another
- `${CLAUDE_SKILL_DIR}/references/schemas.md` — JSON structures for evals.json, grading.json, benchmark.json, etc.
