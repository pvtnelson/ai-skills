# Platform Conventions

Select the row matching the target platform. Apply these constraints when crafting or reviewing prompts.

| Platform | Key constraints |
|----------|----------------|
| **Claude** | Handles complex multi-step instructions, XML tags for structure (`<context>`, `<rules>`), strong with examples and CoT |
| **ChatGPT/Gemini** | Concise directives, numbered lists for sequences, avoid deep nesting |
| **Ollama (<8B)** | Simplest instructions only, 3-5 top rules max, concrete examples essential, short context window |
| **Custom agents** | Markdown system prompts, keep under 500 words for small models, concrete examples over abstract rules |
