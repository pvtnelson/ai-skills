# Note Templates

Load the specific template matching the note type. Do not load all templates.

## General Note
```markdown
---
date: YYYY-MM-DD
tags: [note]
related: []
---

# Title

Content organized from the brain dump.

## Related
- [[Backlink Placeholder]]
```

## Decision
```markdown
---
date: YYYY-MM-DD
tags: [decision]
related: []
---

# Decision: Title

## Context
Why is this decision needed?

## Options Considered
1. **Option A** — pros/cons
2. **Option B** — pros/cons

## Decision
What was decided and why.

## Consequences
What changes as a result.
```

## Meeting
```markdown
---
date: YYYY-MM-DD
tags: [meeting]
related: []
---

# Meeting: Title

## Attendees
- Name

## Agenda
1. Topic

## Notes
Structured from the brain dump.

## Action Items
- [ ] Item — @owner — due date
```

## Debug
```markdown
---
date: YYYY-MM-DD
tags: [debug]
related: []
---

# Debug: Title

## Symptom
What was observed.

## Root Cause
What was actually wrong.

## Fix
What was done to resolve it.

## Prevention
How to avoid this in the future.
```

## Idea
```markdown
---
date: YYYY-MM-DD
tags: [idea]
related: []
---

# Idea: Title

## Summary
One-sentence description.

## Details
Expanded thoughts from the brain dump.

## Next Steps
- [ ] What to do with this idea
```
