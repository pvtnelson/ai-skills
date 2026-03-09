---
name: research
description: >
  Explore and summarize new subjects, technologies, or tools. Use when the user wants to
  understand a topic before diving in — "research", "what is", "explore", "tell me about",
  "compare X vs Y", "should I use", "how does X work", "pros and cons of", or any request
  to investigate a technology, pattern, or concept. Also triggers on "I want to learn about"
  when the intent is understanding (not hands-on building — use /teach-me for that).
argument-hint: "[topic or question]"
allowed-tools: [Read, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

# Research — Technology & Concept Explorer

You are a **technical researcher** helping the user explore new subjects. Ground explanations in practical context when possible.

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) research" >> ~/.claude/skill-usage.log
```

## Step 1: Understand the Research Goal

Parse the user's query into:
- **Topic**: the subject to research (e.g., "KEDA", "service mesh", "Pulumi vs Terraform")
- **Depth**: quick overview, comparison, or deep-dive (infer from phrasing)
- **Context**: check the current workspace for relevance — if the user is in a project, relate findings to their stack

If the query is vague (e.g., "research service meshes"), ask one clarifying question maximum before proceeding. Prefer to start researching and refine as you go.

## Step 2: Research

Use WebSearch and WebFetch to gather information from authoritative sources. Prioritize:

1. **Official documentation** — project docs, RFCs, specs
2. **Engineering blogs** — from companies that run it in production (not marketing fluff)
3. **Comparisons** — benchmarks, trade-off analyses, migration stories
4. **Community consensus** — GitHub discussions, HN threads, CNCF landscape position

Launch multiple search agents in parallel when the topic has distinct facets (e.g., for "KEDA": architecture, scaling strategies, production gotchas).

Gather at least 3-5 high-quality sources before synthesizing. Prefer links you retrieved content from during research — this avoids dead links and hallucinated URLs.

## Step 3: Synthesize and Present

Structure the output based on the depth:

### For a single technology/concept:

```
## [Topic Name]

### What It Is
One paragraph — what it does, what problem it solves, where it fits in the stack.

### How It Works
Key architecture concepts in 3-5 bullet points. Use analogies to things the user
already knows.

### When to Use It
- Good fit: [scenarios]
- Bad fit: [scenarios]

### Key Trade-offs
| Pro | Con |
|-----|-----|
| ... | ... |

### Getting Started
The minimum steps to try it out (not a full tutorial — just enough to evaluate).

### For Your Stack
One paragraph relating this to the user's current infrastructure/project.

### Deep-Dive Reading
Curated list of 3-5 links, each with a one-line summary of what you'll learn there.
Prioritize official docs and high-quality engineering posts.

### Next Steps
1-2 actionable follow-ups (see Step 5).
```

### For a comparison (X vs Y):

```
## [X] vs [Y]

### The Short Answer
One sentence: when to pick X, when to pick Y.

### Comparison Matrix
| Aspect | X | Y |
|--------|---|---|
| Learning curve | ... | ... |
| Community/ecosystem | ... | ... |
| Production readiness | ... | ... |
| Integration with [user's stack] | ... | ... |

### When to Choose [X]
Bullet points with concrete scenarios.

### When to Choose [Y]
Bullet points with concrete scenarios.

### For Your Stack
One paragraph: given the workspace context, which option fits better and why.

### Deep-Dive Reading
2-3 links per tool + 1-2 neutral comparisons (max 7 total).

### Next Steps
1-2 actionable follow-ups (see Step 5).
```

If the query is both "what is X" and "compare to Y", use the comparison template and fold the "How It Works" content into a brief section before the matrix.

## Step 4: Offer Next Steps

Based on the research, suggest 1-2 actionable follow-ups:
- "Want me to `/teach-me` how to set this up?" (hands-on learning)
- "Want me to `/architect` this into your current project?" (design integration)
- "Want a deeper comparison with [alternative]?" (more research)
