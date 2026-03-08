---
name: take-note
description: Quick note-taking — takes unstructured brain dumps and formats them into strict Obsidian markdown with YAML frontmatter, standardized tags, and backlink placeholders. Use when capturing ideas, decisions, meetings, or debugging notes.
argument-hint: "[topic or brain dump]"
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
---

# Take Note

Takes an unstructured brain dump and formats it into Obsidian-compatible markdown.

`$ARGUMENTS` = the note content, brain dump, or topic

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) take-note" >> ~/.claude/skill-usage.log
```

## Step 1: Determine Note Type

Parse `$ARGUMENTS` to detect the type by prefix or keywords:

| Prefix / Keywords | Type | Tag |
|---|---|---|
| `decision:`, `decided:`, `adr:` | Decision | `#decision` |
| `meeting:` | Meeting | `#meeting` |
| `debug:`, `troubleshooting:`, `bug:` | Debug | `#debug` |
| `idea:` | Idea | `#idea` |
| Everything else | General note | `#note` |

Multiple tags can apply. Add contextual tags based on content — infer the project or domain from keywords (e.g., `#infrastructure`, `#frontend`, `#api`, `#deployment`).

## Step 2: Transform the Brain Dump

Load only the matching template from the reference file:

```bash
cat ${CLAUDE_SKILL_DIR}/references/templates.md
```

Extract the section for the detected note type. Then transform the raw input:

1. **Extract the title** — find the main topic or decision from the brain dump. Use it as the `# Title`.
2. **Group by theme** — scan for distinct topics in the input. Each topic becomes a section or bullet group under the appropriate template heading.
3. **Infer structure** — map raw thoughts to template sections:
   - Statements of fact → Context or Notes
   - Questions → mark with `?` or move to Next Steps / Action Items
   - Problems described → Symptom (debug) or Context (decision)
   - Solutions mentioned → Fix (debug) or Decision (decision)
   - People mentioned → Attendees (meeting) or @owner in Action Items
   - Dates/deadlines → due dates on action items
4. **Generate backlinks** — identify concepts that could link to other notes: project names, technologies, people, architectural patterns. Format as `[[Concept Name]]`.
5. **Fill frontmatter** — set `date` to today, `tags` from Step 1, `related` with backlink targets.

Do not invent information. If the brain dump is missing a template section (e.g., no "Root Cause" for a debug note), leave the section with a `TODO` placeholder.

## Step 3: Save

Determine the vault directory:

```bash
VAULT_DIR="${OBSIDIAN_VAULT:-$HOME/notes}"
mkdir -p "$VAULT_DIR"
```

Filename: `YYYY-MM-DD-<slug>.md` — slug is lowercase, hyphenated, derived from the title, max 50 chars.

Write the formatted note using the Write tool.

## Step 4: Output

Present:
1. The full formatted note (so the user can review it)
2. The saved file path
3. Related existing notes (search the vault for content matching the backlinks):

```bash
# Find related notes by keyword
```

Use Grep to search `$VAULT_DIR` for the main topic keywords. List up to 5 related notes with file paths.
