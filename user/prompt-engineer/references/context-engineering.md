# Context Engineering Reference

On-demand reference for `/prompt-engineer`. Do NOT burn into every prompt — load when a specific technique is needed.

## Few-Shot Example Design

Choose density by task complexity:
- **1-shot**: Simple format or tone demonstration
- **3-shot**: Meaningful variation across input types
- **5+shot**: Complex classification or edge-case consistency

Selection criteria: diverse inputs, at least one edge case, exact output format in every example, simple-to-complex ordering.

Format-anchoring pattern:
```
**User:** [input]
**Assistant:**
[exact output format with structure and whitespace]
```

## Chain-of-Thought Scaffolding

**Use when:** multi-step logic, judgment calls, accuracy > speed, classification with nuanced criteria.
**Skip when:** simple lookups, small models (<8B), latency-sensitive tasks.

Scratchpad pattern (hidden reasoning):
```
Before responding, reason in a <thinking> block:
1. Identify the core question
2. List constraints
3. Evaluate options
4. Choose and justify

The <thinking> block is internal — your visible response starts after it.
```

## Persona Layering

Stack complementary roles: `You are a senior security engineer who explains findings to non-technical stakeholders.` (expert depth + communicator accessibility).

Calibration levers:
- **Register**: peer engineer vs consultant to executives
- **Density**: thorough with specifics vs concise one-paragraph
- **Tone anchor**: single exemplar sentence: *"Your tone sounds like: 'The deploy failed because the config mount is stale — here's the fix.'"*

Cross-turn consistency anchor: `Remember: you are direct, technical, and never speculative. If unsure, say so.`

## Prompt Compression Techniques

| Technique | Example |
|-----------|---------|
| Merge redundant rules | "Be concise. Keep it short. Don't ramble." -> "Respond in 1-3 sentences." |
| Imperative voice | "You should make sure to validate..." -> "Validate input before processing." |
| Cut meta-commentary | "It's important that you always..." -> Just state the rule |
| Semantic compression | "When the user asks and you don't know, tell them rather than making something up" -> "Say 'I don't know' rather than guess." |
| Priority ordering | Most important rules first — models attend more to the top |

## Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Contradictory instructions | Audit for conflicts, establish priority |
| Over-constraining | Remove low-value rules, keep essentials |
| Context pollution | Remove anything the model doesn't need |
| Instruction drift | Critical rules at top AND bottom (primacy + recency) |
| Vague guardrails | Replace "be careful" with specific criteria |
| Example overfit | Add variety, use different domains |
| Negative framing | Rewrite as positive instructions |

## Iterative Refinement Process

1. **Baseline**: Run prompt against 3-5 representative inputs
2. **Diagnose**: Identify the single worst failure mode
3. **Intervene**: Make ONE targeted change
4. **Verify**: Re-run same inputs, confirm no regression

Stop when 3 iterations produce no meaningful improvement.
