---
name: mcp-builder
description: Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).
argument-hint: "[service name or API to integrate]"
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, WebFetch, WebSearch, Agent]
---

# MCP Server Development Guide

Create MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. The quality of an MCP server is measured by how well it enables LLMs to accomplish real-world tasks.

`$ARGUMENTS` = the service or API to build an MCP server for (e.g., "GitHub API", "Slack", "Jira", "Stripe").

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) mcp-builder" >> ~/.claude/skill-usage.log
```

## Step 1: Deep Research and Planning

### 1.1 Understand Modern MCP Design

**API Coverage vs. Workflow Tools:**
Balance comprehensive API endpoint coverage with specialized workflow tools. When uncertain, prioritize comprehensive API coverage — it gives agents flexibility to compose operations.

**Tool Naming and Discoverability:**
Use consistent prefixes and action-oriented naming (e.g., `nextcloud_list_files`, `nextcloud_upload_file`).

**Context Management:**
Design tools that return focused, relevant data. Support filtering and pagination.

**Actionable Error Messages:**
Error messages should guide agents toward solutions with specific suggestions.

### 1.2 Study MCP Protocol Documentation

Start with the sitemap: `https://modelcontextprotocol.io/sitemap.xml`

Fetch specific pages with `.md` suffix (e.g., `https://modelcontextprotocol.io/specification/draft.md`).

Key areas: specification overview, transport mechanisms (streamable HTTP, stdio), tool/resource/prompt definitions.

### 1.3 Study Framework Documentation

**Recommended stack:** TypeScript with streamable HTTP for remote servers, stdio for local servers.

**Load framework documentation as needed:**

- **MCP Best Practices**: [View Best Practices](${CLAUDE_SKILL_DIR}/reference/mcp_best_practices.md) — core guidelines
- **TypeScript SDK**: Fetch `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- **TypeScript Guide**: [TypeScript patterns](${CLAUDE_SKILL_DIR}/reference/node_mcp_server.md)
- **Python SDK**: Fetch `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`
- **Python Guide**: [Python patterns](${CLAUDE_SKILL_DIR}/reference/python_mcp_server.md)

### 1.4 Plan the Implementation

1. Review the service's API documentation (use WebFetch/WebSearch as needed)
2. Identify key endpoints, authentication requirements, and data models
3. List tools to implement, starting with the most common operations
4. Choose transport: stdio for local CLI tools, streamable HTTP for remote services

## Step 2: Implementation

### 2.1 Set Up Project Structure

See the language-specific guides for project setup:
- [TypeScript Guide](${CLAUDE_SKILL_DIR}/reference/node_mcp_server.md) — project structure, package.json, tsconfig
- [Python Guide](${CLAUDE_SKILL_DIR}/reference/python_mcp_server.md) — module organization, dependencies

### 2.2 Implement Core Infrastructure

Create shared utilities:
- API client with authentication
- Error handling helpers
- Response formatting (JSON/Markdown)
- Pagination support

### 2.3 Implement Tools

For each tool:

**Input Schema:**
- Use Zod (TypeScript) or Pydantic (Python)
- Include constraints and clear descriptions
- Add examples in field descriptions

**Output Schema:**
- Define `outputSchema` where possible for structured data
- Use `structuredContent` in tool responses (TypeScript SDK)

**Tool Description:**
- Concise summary of functionality
- Parameter descriptions with types and constraints
- Return type documentation

**Implementation:**
- Async/await for all I/O operations
- Proper error handling with actionable messages
- Pagination support where applicable
- Return both text content and structured data

**Annotations:**
- `readOnlyHint`: true/false
- `destructiveHint`: true/false
- `idempotentHint`: true/false
- `openWorldHint`: true/false

## Step 3: Review and Test

### 3.1 Code Quality

Review for:
- No duplicated code (DRY)
- Consistent error handling
- Full type coverage
- Clear tool descriptions

### 3.2 Build and Test

**TypeScript:**
```bash
npm run build
npx @modelcontextprotocol/inspector
```

**Python:**
```bash
python -m py_compile your_server.py
```

See language-specific guides for detailed testing and quality checklists.

### 3.3 Create Evaluations

After implementation, create evaluations to test effectiveness.

**Load [Evaluation Guide](${CLAUDE_SKILL_DIR}/reference/evaluation.md) for complete guidelines.**

Create 10 evaluation questions that are:
- **Independent**: not dependent on other questions
- **Read-only**: only non-destructive operations
- **Complex**: requiring multiple tool calls
- **Realistic**: based on real use cases
- **Verifiable**: single, clear answer
- **Stable**: answer won't change over time

Output as XML:

```xml
<evaluation>
  <qa_pair>
    <question>Your question here</question>
    <answer>Single verifiable answer</answer>
  </qa_pair>
</evaluation>
```

Run evaluations with the provided harness:

```bash
cd ${CLAUDE_SKILL_DIR}/scripts
pip install -r requirements.txt
python evaluation.py -t stdio -c node -a /path/to/server.js eval.xml
```

## Step 4: Output

After building the MCP server, provide:
- **Service**: what API/service was integrated
- **Language**: TypeScript or Python
- **Transport**: stdio or streamable HTTP
- **Tools implemented**: list with brief descriptions
- **Testing status**: build result, inspector test, evaluation score
