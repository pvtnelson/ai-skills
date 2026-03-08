---
name: refactor-audit
description: Identify technical debt and structural issues across a directory without hallucinating massive code rewrites. Read-only.
argument-hint: "[directory or module to audit]"
allowed-tools: [Bash, Read, Glob, Grep, Agent]
---

# Refactor Audit (Read-Only Scout)

Scan a directory for technical debt and structural issues. This skill produces a prioritized hit-list of concrete problems — not a wishlist of "improvements." It reads code, measures it, and reports. It never modifies files.

When invoked, execute the following steps in exact order.

`$ARGUMENTS` = the directory or module to audit

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) refactor-audit" >> ~/.claude/skill-usage.log
```

## Step 1: Multi-Dimensional Scan

Read every source file in `$ARGUMENTS` (excluding generated files, node_modules, __pycache__, .next, venv, dist, build). Evaluate across these dimensions:

### DRY Violations
- Grep for duplicated logic: identical or near-identical blocks across files (same function body, same query pattern, same validation sequence repeated 3+ times).
- Flag copy-paste code that should be a shared utility — but only if it is genuinely duplicated, not just structurally similar.

### Typing Strictness
- **Python**: Check for missing type annotations on public function signatures. Flag bare `dict`, `list`, `Any` where a concrete type is possible. Check for `# type: ignore` comments that suppress real issues.
- **TypeScript**: Check for `any` usage, missing return types on exported functions, loose object shapes (`Record<string, any>`) where an interface exists.
- Flag only public API surfaces — internal helper typing is lower priority.

### Component / Module Size
- Identify files exceeding 300 lines (warning) or 500 lines (problem). These are candidates for splitting.
- Identify functions exceeding 50 lines. Long functions typically violate single responsibility.
- Identify classes or modules with more than 7 public methods (interface is too wide).

### Separation of Concerns
- Business logic mixed with I/O (database calls inside validation functions, HTTP calls inside data transformers).
- Presentation logic mixed with data fetching (API calls in React components, SQL in route handlers).
- Configuration mixed with code (hardcoded URLs, magic numbers, inline SQL strings).

### Dead Code
- Unused imports, unreachable branches, commented-out blocks, functions with zero call sites.
- Exported symbols that are never imported elsewhere in the project.

## Step 2: Priority Ranking

Group every finding into exactly one tier:

### High Impact (Fix Soon)
Issues that actively cause bugs, block scaling, or make changes dangerous:
- Security-adjacent debt (unvalidated inputs, missing auth checks, SQL injection risk)
- Data integrity risks (missing constraints, race conditions, inconsistent state)
- Files so large they cause merge conflicts on every PR
- Duplicated logic where a bug fix in one copy was missed in another

### Medium Impact (Fix When Nearby)
Issues that slow development but do not actively cause harm:
- Missing types on public APIs
- Functions over 50 lines that are hard to test
- Moderate duplication (2 copies, not yet causing drift)
- Mixed concerns that make unit testing difficult

### Low Impact (Track, Do Not Prioritize)
Issues that are technically imperfect but not worth fixing in isolation:
- Minor style inconsistencies
- Internal helper functions missing types
- Slightly large files that are still readable
- Dead code that is harmless (old feature flags, unused utils)

## Step 3: Output Hit-List

Generate the following structured report:

```markdown
## Refactor Audit: <directory>

### Summary
- Files scanned: <N>
- High impact findings: <N>
- Medium impact findings: <N>
- Low impact findings: <N>

### High Impact
| # | File:Line | Issue | Category |
|---|-----------|-------|----------|
| 1 | `path/to/file:42` | <specific description> | <DRY/Typing/Size/SoC/Dead> |

### Medium Impact
| # | File:Line | Issue | Category |
|---|-----------|-------|----------|
| 1 | `path/to/file:88` | <specific description> | <category> |

### Low Impact
| # | File:Line | Issue | Category |
|---|-----------|-------|----------|
| 1 | `path/to/file:15` | <specific description> | <category> |

### Patterns
<1-3 sentences identifying recurring themes across the findings, e.g., "Most
duplication is in validation logic — a shared validator module would address
findings #1, #3, and #7 simultaneously.">
```

## Step 4: Hard Stop

Output this statement verbatim:

**I have not modified any files. Use this report to guide targeted execution — fix high-impact items first, medium when you are already editing nearby code, and track low-impact items for future cleanup.**

Do NOT offer to fix anything. Do NOT propose a refactoring plan. The purpose of this skill is to inform, not to rewrite.

## Related Skills

- `/codebase-analysis` — trace the impact of a specific change across the codebase
- `/code-review` — review code that has already been written
- `/plan-review` — plan a refactoring effort informed by this audit
