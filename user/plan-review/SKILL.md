---
name: plan-review
description: Create an implementation plan and get it reviewed by a staff engineer subagent before coding
argument-hint: "[plan or feature description]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, Agent]
---

# Plan, Review, Clear, Execute

Two-Claude pattern: create a plan, spawn a staff engineer subagent (separate Opus context) to review it, persist the approved plan to a file, then instruct the user to `/clear` before execution. This prevents brainstorming context from polluting the execution phase.

When invoked, execute the following steps in exact order.

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) plan-review" >> ~/.claude/skill-usage.log
```

## Step 1: Gate Check

Determine if planning is appropriate for `$ARGUMENTS`:

- **Proceed** for: new features, refactors, architectural changes, multi-file changes, anything touching auth, RLS, encryption, or financial logic.
- **Skip** for: typos, single-line fixes, documentation-only changes. Output: "This change is too small for a formal plan. Just implement it." and stop.

## Step 2: Create the Plan

Read relevant existing code first to ground the plan in reality. Then create a detailed implementation plan for `$ARGUMENTS` using this structure:

```markdown
## Problem Statement
What problem are we solving? Why now?

## Proposed Solution
High-level approach.

## Implementation Steps
1. Step with specific files/functions
2. Step with specific files/functions

## Files Affected
- `path/to/file` — what changes

## Testing Strategy
- Unit tests for X
- Integration tests for Y
- Manual testing scenarios

## Rollback Plan
How to revert if this fails.
```

## Step 3: Staff Engineer Review

After creating the plan, read the review prompt template:

```bash
cat ${CLAUDE_SKILL_DIR}/references/review-prompt.md
```

Then spawn the review subagent using the Agent tool (`subagent_type: "general-purpose"`). Insert the plan from Step 2 where the template says `[INSERT PLAN HERE]`.

## Step 4: Iterate

| Verdict | Action |
|---------|--------|
| **APPROVED** | Proceed to Step 5 |
| **APPROVED WITH CHANGES** | Fix critical issues, resubmit to a new subagent |
| **NEEDS REVISION** | Rewrite plan addressing all feedback, resubmit |

Maximum 3 iterations. If still not approved, ask the user for guidance.

## Step 5: Persist the Approved Plan

Once the plan receives an **APPROVED** verdict:

1. Create the plan directory if it does not exist: `docs/plans/`
2. Write the final approved plan to `docs/plans/<feature-slug>.md` including:
   - The full plan from Step 2 (with any revisions from Step 4)
   - The final review verdict and summary from the staff engineer
   - A timestamp header: `# Plan: <feature> — Approved <date>`
3. Confirm the file path to the user.

## Step 6: Present Results and Instruct Context Clear

Output the following to the user:

1. Summarize what the review caught and what changed (technical AND product feedback).
2. State the plan file path.
3. Then output this mandatory block verbatim:

---

**Plan approved and saved to `docs/plans/<feature-slug>.md`.**

**Next step: type `/clear` to wipe your context window before executing.**

Clearing context is critical. Your current context contains brainstorming, rejected ideas, review back-and-forth, and intermediate reasoning — none of which should influence the execution phase. After clearing, reference the saved plan file to execute purely from the approved specification, free from planning-phase hallucinations.

After `/clear`, run: "Read `docs/plans/<feature-slug>.md` and implement the plan."

---

Do NOT offer to begin implementation in this same context. The clear boundary between planning and execution is the entire point of this workflow.

## Related Skills

**Recommended workflow: Explore -> Analyze -> Plan -> Execute**

1. `/codebase-analysis` — map the blast radius of a change (Explore)
2. `/decision-critic` — stress-test the proposed approach (Analyze)
3. `/plan-review` — create and approve the implementation plan (Plan)
4. `/clear` then execute from the saved plan file (Execute)

Other related skills:

- `/architect` — system design evaluation before planning implementation
- `/refactor-audit` — identify technical debt before planning fixes
- `/code-review` — review code after implementation
