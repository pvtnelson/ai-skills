---
name: decision-critic
description: Stress-test proposed architectures and technical decisions. Acts as a hostile Red Team to find flaws before execution.
argument-hint: "[proposal, ADR, or technical decision to challenge]"
allowed-tools: [Bash, Read, Glob, Grep, Agent]
---

# Decision Critic (Red Team)

Adversarial review of a technical proposal. Finds flaws, misaligned priorities, and hidden risks before any code is written. Does not build — tears down assumptions.

When invoked, execute the following steps in exact order.

`$ARGUMENTS` = the proposal, ADR, plan, or technical decision to challenge

## Step 0: Usage Logging

Silently run this command first:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) decision-critic" >> ~/.claude/skill-usage.log
```

## Step 1: The Simplicity & Value Check

Every technical decision must survive these questions:

- **User benefit** — Does this proposal directly improve the experience for its target users? Name the specific action that becomes easier, faster, or unnecessary.
- **Complexity tax** — What is the maintenance cost? Every abstraction, config option, and service boundary is a tax on every future change. Is the benefit worth the tax?
- **Simplicity over cleverness** — Could this be achieved with fewer moving parts? Does it add surface area (more settings, more failure modes) without proportional value?
- **Measurable justification** — If the proposal is purely technical (refactor, security, performance), it must justify the investment with measurable outcomes. "Clean code" and "best practices" are not justifications.

Output a clear **PASS** or **FAIL** for objective alignment, with explanation.

## Step 2: Red Team Analysis

Attack the proposal from every angle:

### Failure Modes
- **Single points of failure** — What happens when this component goes down? Fallback or full stop?
- **Data integrity** — Can this cause data loss, corruption, or inconsistency? Partial failures mid-operation?
- **Race conditions** — Concurrent access patterns? Simultaneous request behavior?
- **Cascading failures** — If this fails, what else fails? Map the blast radius.

### Scalability
- **The 10x question** — What breaks first under 10x load? Obvious bottleneck or architectural?
- **State management** — In-memory (lost on restart), local disk (breaks clustering), or proper store?
- **Resource exhaustion** — Unbounded queues, connection pool limits, disk growth, memory leaks?

### Security
- **Attack surface** — What new inputs exposed? Validated at the boundary?
- **Auth bypass** — Could this circumvent existing auth, middleware, or permission checks?
- **Data exposure** — Could this leak PII, tokens, or internal state?

### Operational Reality
- **3 AM debuggability** — Diagnosable with existing logs/metrics, or requires a debugger?
- **Rollback** — Config change, migration rollback, or "restore from backup"?
- **Deployment** — Deploy-order dependency, breaking migration, or flag day?

## Step 3: Output Tear Down

```markdown
## Decision Critique: <proposal title>

### Objective Alignment
**[PASS / FAIL]** — <explanation>

### Critical Risks (Will Cause Harm)
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| <risk> | <what breaks> | <high/medium/low> | <fix or avoid> |

### Concerns (Could Cause Harm)
- <concern>: <why it matters>

### Unnecessary Complexity
- <element removable or simplifiable without losing value>

### Recommended Pivots
- <alternative achieving the same outcome with less risk>

### What Survives Scrutiny
- <sound elements to keep>

### Verdict
**[PROCEED / PROCEED WITH CHANGES / REJECT]**
<one-paragraph critical path forward>
```

## Step 4: Hard Stop

Output verbatim:

**This is an adversarial review only. No files have been modified. Address the critical risks above before proceeding to `/plan-review`.**

Do NOT offer to fix the proposal or begin implementation.

## Related Skills

- Create project-scoped variants for domain-specific Red Team reviews
- `/codebase-analysis` — map impact before critiquing
- `/plan-review` — plan after addressing critique
- `/architect` — evaluate system design
