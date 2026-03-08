---
name: hello-world
description: A minimal example skill that greets the user and demonstrates the Step 0-N protocol. Use this as a starting point for creating your own skills.
---

# Hello World

A minimal skill to demonstrate the framework structure.

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) hello-world" >> ~/.claude/skill-usage.log
```

## Step 1: Gate

No prerequisites. This skill works in any context.

## Step 2: Greet

Output a friendly greeting that includes:
1. The current working directory
2. The current date and time
3. A brief explanation of what skills are and how to create one

## Step 3: Output

End with:

> To create your own skill, run `/skill-creator` or see the [Framework Standards](docs/FRAMEWORK_STANDARDS.md).
