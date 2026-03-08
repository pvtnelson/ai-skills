---
name: take-note
description: Quick note-taking — takes unstructured brain dumps and formats them into strict Obsidian markdown with YAML frontmatter, standardized tags, and backlink placeholders. Use when capturing ideas, decisions, meetings, or debugging notes.
argument-hint: "[topic or brain dump]"
allowed-tools: [Bash, Read, Write, Edit, Glob]
---

# Take Note

Takes an unstructured brain dump and formats it into Obsidian-compatible markdown.

`$ARGUMENTS` = the note content, brain dump, or topic

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) take-note" >> ~/.claude/skill-usage.log
```

## Step 1: Determine Note Type

Parse `$ARGUMENTS` to detect the type:

| Prefix / Keywords | Type | Tag |
|---|---|---|
| `decision:`, `decided:`, `adr:` | Decision | `#decision` |
| `meeting:` | Meeting | `#meeting` |
| `debug:`, `troubleshooting:`, `bug:` | Debug | `#debug` |
| `idea:` | Idea | `#idea` |
| Everything else | General note | `#note` |

Multiple tags can apply (e.g., a project meeting gets both `#meeting` and a project tag).

Add domain-specific tags based on content (e.g., `#infrastructure`, `#ai`, `#deployment`).

## Step 2: Load Template and Format

Load only the matching template from the reference file:

```bash
cat ${CLAUDE_SKILL_DIR}/references/templates.md
```

Extract the section for the detected note type. Then:

- Extract the main topic/title from the brain dump
- Organize loose thoughts into the template sections
- Add context from the conversation if available
- Generate backlink placeholders for related concepts (e.g., `[[Project Name]]`, `[[Architecture]]`)

## Step 3: Save

```bash
VAULT_DIR="${OBSIDIAN_VAULT:-$HOME/notes}"
mkdir -p "$VAULT_DIR"
```

Filename: `YYYY-MM-DD-<slug>.md` — slug is lowercase, hyphenated, max 50 chars.

Write the formatted note, then:

- Confirm the file path
- Show the formatted note
- Suggest related existing notes: `ls "$VAULT_DIR"/*.md 2>/dev/null | head -10`
