---
name: prompt-engineer
description: Craft, analyze, and optimize system prompts and agent instructions for any LLM platform. Enforces Context Engineering principles — minimal high-signal tokens, progressive disclosure, context rot resistance.
argument-hint: "[task or existing prompt file]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep]
---

# Prompt Engineer

Craft effective prompts and agent instructions using Context Engineering: curate the smallest set of high-signal tokens that reliably produce the desired behavior.

`$ARGUMENTS` = task description, file path to existing prompt, or target platform/model.

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) prompt-engineer" >> ~/.claude/skill-usage.log
```

## Step 1: Understand the Target

Determine from `$ARGUMENTS` and conversation context:

1. **Platform**: Claude system prompt, ChatGPT, Gemini, Ollama, or generic
2. **Model**: Which model runs this prompt (affects context window, reasoning, tool use)
3. **Purpose**: What the agent/prompt must accomplish
4. **Mode**: Create new, analyze existing, or optimize existing

If improving an existing prompt, read the file first.

## Step 2: Craft or Optimize the Prompt

### Design Principles

- **Identity first** — open with who/what and core purpose in 1-2 sentences
- **Show, don't tell** — concrete examples over abstract descriptions
- **Positive framing** — state what to do, not what to avoid
- **Explain the why** — models follow instructions better when they understand the reasoning
- **Specificity** — "Respond in under 200 words" beats "Keep it short"
- **Structured output** — define exact format when consistency matters
- **Least privilege** — only grant capabilities genuinely needed
- **Fail gracefully** — define behavior for missing information or edge cases

### Advanced Techniques (on demand)

For few-shot design, chain-of-thought scaffolding, persona layering, compression techniques, anti-patterns, and iterative refinement — read the reference file:

```bash
cat ${CLAUDE_SKILL_DIR}/references/context-engineering.md
```

Load this only when a specific technique is needed. Do not internalize the entire reference for every prompt.

### Platform Conventions

For platform-specific constraints (Claude, ChatGPT/Gemini, Ollama, custom agents), read:

```bash
cat ${CLAUDE_SKILL_DIR}/references/conventions.md
```

### Prompt Structure Template

```markdown
# [Agent Name]
[1-2 sentence identity and purpose]

## Core Behavior
[3-5 behavioral rules, priority-ordered]

## Output Format
[Expected structure with inline example]

## Guardrails
[Scope boundaries, privacy, failure modes]
```

### Analyzing an Existing Prompt

Evaluate against these criteria (score each 1-10):

| Criterion | What "10" looks like |
|-----------|---------------------|
| **Clarity** | Every instruction has exactly one interpretation |
| **Specificity** | All rules are concrete with examples or thresholds |
| **Structure** | Scannable hierarchy, priority-ordered, no redundancy |
| **Token economy** | Every sentence earns its tokens — nothing cuttable |
| **Model fit** | Leverages model-specific features appropriately |
| **Examples** | Edge cases covered, format-anchoring, graduated complexity |
| **Guardrails** | Edge cases handled, graceful degradation defined |

Severity levels: **CRIT** (causes incorrect output, fix before deploy), **WARN** (degrades quality, fix soon), **INFO** (minor improvement).

Analysis output format:

```
## Prompt Analysis: [name]
**Target:** [platform / model] | **Length:** [word count] words | **Overall: X/10**

### Scorecard
| Criterion | Score | Sev | Notes |
|-----------|-------|-----|-------|

### Critical Issues
1. **[Title]** — Where: [ref] | Problem: [what] | Fix: `[before]` -> `[after]`

### Quick Wins
- [ ] [actionable change]
```

## Step 3: Context Engineering Gate

**Every prompt must pass this checklist before delivery. No exceptions.**

- [ ] **Token economy**: Is this the smallest set of high-signal tokens? Can any section be cut without losing behavior?
- [ ] **Context rot resistance**: Will critical instructions survive long conversations? Are key rules anchored at top and bottom (primacy/recency)?
- [ ] **Progressive disclosure**: Does the prompt load everything upfront, or does it defer detail to tool calls and reference files?
- [ ] **Goldilocks altitude**: Are instructions flexible heuristics ("respond in 2-4 sentences") rather than brittle hardcoding ("respond in exactly 3 sentences")?
- [ ] **Tool output hygiene**: If tools are involved, do definitions return minimal data? Are large payloads truncated or summarized?
- [ ] **No redundancy**: Is every instruction stated exactly once? No rephrasing of the same rule?

If any check fails, revise the prompt before proceeding. State which items failed and what was changed.

## Step 4: Deliver and Deploy

Present the prompt in a markdown code block, ready to copy-paste.

If the target is a Claude skill (SKILL.md), write it following the skills framework protocol (Step 0-N, frontmatter, 500-line limit) and run `setup.sh` to validate.

For all other platforms, output the prompt with platform-specific deployment notes.

### Save Prompt to File

Save the prompt alongside the project or to a user-specified location:

```bash
SLUG=$(echo "<platform>-<short-purpose>" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
FILENAME="$(date +%Y-%m-%d)-${SLUG}.md"
# Default save location — override with user preference
SAVE_DIR="${PROMPTS_DIR:-./prompts}"
mkdir -p "$SAVE_DIR"
cat > "${SAVE_DIR}/${FILENAME}" <<'PROMPT'
[prompt content]
PROMPT
```

Ask the user where to save if no default is configured.

### Output Summary

- **Target**: platform and model
- **Word count**: total prompt length
- **Context Engineering gate**: all checks passed / which items were revised
- **Key design choices**: 2-3 bullets on the most important decisions
- **Saved to**: file path
