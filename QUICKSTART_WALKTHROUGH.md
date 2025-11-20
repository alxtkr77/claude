# Claude Code Quickstart Walkthrough

A step-by-step guide to install and configure Claude Code CLI.

---

## 1. Install Claude Code

```bash
# Install Claude Code globally via npm
npm install -g @anthropic-ai/claude-code
```

**Why**: Installs the `claude` command-line tool.

---

## 2. Clone the Workflows Repository

```bash
# Clone shared workflows and templates
git clone git@github.com:alxtkr77/claude.git ~/claude
```

**Why**: Gets pre-built workflows, standards, and templates for consistent development practices.

---

## 3. Start Claude in Your Project

```bash
# Navigate to your project
cd ~/your-project

# Start Claude Code
claude
```

**Why**: Launches the interactive Claude CLI in your project directory.

---

## 4. First-Time Authentication

On first run, Claude will prompt you to authenticate:
1. Opens browser to Anthropic login
2. Authorize Claude Code
3. Returns to terminal ready to use

---

## 5. Essential Claude Commands

Inside the Claude CLI, use these commands:

| Command | Description |
|---------|-------------|
| `/help` | Show all available commands |
| `/clear` | Clear conversation history |
| `/compact` | Summarize conversation to save context |
| `/cost` | Show token usage and cost |
| `/quit` or `Ctrl+C` | Exit Claude |

---

## 6. Set Up Project with Workflows

```bash
# Inside your project, tell Claude:
Set up this project using ~/claude/README.md
```

**Why**: Claude will create a `CLAUDE.md` file with project-specific configuration and workflow triggers.

---

## 7. Install MCP Servers (via Claude)

Claude can install MCP servers for you using the `/mcp` command.

### Install Memory MCP

```bash
# Start Claude
claude

# Inside Claude, type:
/mcp add memory
```

Follow the prompts - Claude will configure the Memory MCP server.

**Why**: Persistent storage for context, decisions, and credentials across sessions.

### Install Atlassian MCP

```bash
# Inside Claude, type:
/mcp add atlassian
```

First time triggers browser authentication:
1. Opens Atlassian login page
2. Grant permissions to Claude MCP
3. Returns to terminal with access

**Why**: Jira integration - create, update, and comment on tickets.

### Install Chroma MCP

```bash
# Inside Claude, type:
/mcp add chroma
```

Follow the prompts to configure persistent storage location.

**Why**: Vector database for semantic code search and documentation retrieval.

### Add Projects to Chroma

After installing Chroma, index your codebase for semantic search:

```bash
# Inside Claude, type:
Index this project in Chroma
```

Or index specific directories:

```bash
# Inside Claude, type:
Add ~/mlrun to Chroma collection called "mlrun"
```

**Query your indexed code:**

```bash
# Inside Claude, type:
Search Chroma for "error handling in API endpoints"
```

**Why**: Enables finding code by meaning, not just keywords.

---

## 8. Verify Installation

```bash
# Check Claude version
claude --version

# Start Claude
claude
```

**Inside Claude, verify MCP servers:**

```
/mcp
```

Expected output: Shows connected MCP servers (atlassian, memory, chroma).

**Verify each MCP server:**

| Server | Test Command (type in Claude) | Expected Result |
|--------|-------------------------------|-----------------|
| Atlassian | "Get accessible Atlassian resources" | Shows cloud IDs |
| Memory | "Store a test entity in memory" | Confirms entity created |
| Chroma | "List Chroma collections" | Shows collections (may be empty) |

---

## Quick Reference: Common Workflows

Once set up, use these trigger phrases:

| Say This | Claude Does |
|----------|-------------|
| "commit" | Runs pre-commit checks (fmt, lint, tests) then commits |
| "create PR" | Full PR workflow with Jira update |
| "fix bug ML-1234" | Bug handling workflow |
| "work on ML-1234" | Creates branch, updates Jira, starts work |

---

## Project Structure After Setup

```
~/your-project/
├── CLAUDE.md           # Project config (created by Claude)
├── .mcp.json           # Project MCP servers (optional)
└── .claude/
    └── settings.local.json  # Local permissions (auto-created)

~/claude/               # Shared workflows (cloned repo)
├── workflows/          # Development workflows
├── standards/          # Code quality standards
├── templates/          # Reusable templates
└── guides/             # Reference documentation

~/.claude/              # Global Claude config
└── mcp.json            # Global MCP servers
```

---

## Troubleshooting

```bash
# MCP servers not loading? Restart Claude:
claude

# Check if Node.js is installed (required for memory MCP):
node --version

# Check if npm is installed:
npm --version
```

---

**Total setup time**: ~5 minutes
