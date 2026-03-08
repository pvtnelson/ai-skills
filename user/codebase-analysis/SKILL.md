---
name: codebase-analysis
description: Systematically map out the impact of a proposed change across the codebase before planning begins. Read-only.
argument-hint: "[feature or change to analyze]"
allowed-tools: [Bash, Read, Glob, Grep, Agent]
---

# Codebase Impact Analysis (Read-Only)

Map the blast radius of a proposed change before any planning or coding begins. This skill traces execution paths, identifies boundaries, and surfaces hidden complexities. It produces a structured impact report and stops — it never modifies files.

When invoked, execute the following steps in exact order.

`$ARGUMENTS` = the feature, component, or change to analyze

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) codebase-analysis" >> ~/.claude/skill-usage.log
```

## Step 1: Trace Execution

Systematically find every touchpoint related to `$ARGUMENTS`:

1. **Entry points** — Glob for files matching the feature name, route definitions, CLI commands, or event handlers that initiate the flow.
2. **Call sites** — Grep for every function, class, or module that references the target. Follow the chain: who calls the caller?
3. **Data layer** — Find database models, migrations, queries, and ORM references. Check for RLS policies, indexes, and constraints that govern this data.
4. **Configuration** — Search for environment variables, feature flags, config files, and constants that control behavior.
5. **Tests** — Identify existing test coverage: which tests exercise this code path? Which boundary conditions are tested?

Use the Explore agent for broad searches. Use direct Glob/Grep for targeted lookups. Cast a wide net — false positives are acceptable; missed dependencies are not.

## Step 2: Map Boundaries

Identify the architectural seams where this change crosses boundaries:

| Boundary | What to find |
|----------|-------------|
| **Frontend <-> API** | Route handlers, request/response shapes, query parameters, error codes |
| **API <-> Database** | ORM models, raw SQL, migration files, RLS policies, stored procedures |
| **Service <-> Service** | Inter-service calls, shared queues, webhooks, event buses |
| **Internal <-> External** | Third-party API calls, SDK usage, webhook receivers, DNS dependencies |
| **Auth <-> Business logic** | Middleware, decorators, permission checks, token validation touching this flow |

For each boundary crossed, note:

- The contract (what shape of data crosses the boundary)
- The coupling (how tightly are the two sides linked)
- The risk (what breaks if one side changes independently)

## Step 3: Output Impact Map

Generate the following structured report:

```markdown
## Impact Analysis: <feature/change>

### Files Affected
| File | Role | Change Type |
|------|------|-------------|
| `path/to/file` | <what it does> | <direct / transitive / test> |

### Boundary Crossings
- **<boundary>**: <contract description> — Risk: <low/medium/high>

### External Dependencies
- <library, service, or API> — version/constraint, what breaks if it changes

### Hidden Complexities
- <non-obvious coupling, implicit ordering, shared mutable state, race condition risk>

### Existing Test Coverage
- <N> tests directly cover this path
- <gaps>: <untested scenarios>

### Recommended Investigation Before Planning
- [ ] <specific question that needs answering before a plan can be written>
```

## Step 4: Hard Stop

Output this statement verbatim:

**This is a read-only analysis. No files have been modified. Use this impact map as input to `/plan-review` or `/decision-critic` before writing any code.**

Do NOT propose solutions, suggest refactors, or offer to implement anything. The purpose of this skill is to inform, not to act.

## Related Skills

- `/decision-critic` — stress-test a proposed approach using this impact map
- `/plan-review` — create and review an implementation plan informed by this analysis
- `/refactor-audit` — scan for structural debt in a specific directory
