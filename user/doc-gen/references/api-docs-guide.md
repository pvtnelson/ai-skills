# API Documentation & Inline Comments Guide

Load this reference only when the user explicitly requests `api-docs`, `comments`, or `inline`.

## Inline Comments

- Add docstrings to public functions that lack them
- Use the convention matching the project's language (Google-style for Python, JSDoc for TypeScript, GoDoc for Go, etc.)
- Only add comments where the logic is non-obvious
- Never add comments that restate the code
- Remove stale or misleading comments

## API Documentation

Search for all API route definitions (framework decorators, router handlers, endpoint registrations) and generate a route table:

```markdown
| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/v1/... | ... |
```

This goes in a separate `docs/api-routes.md` file, NOT in README.md (to stay within the word budget).
