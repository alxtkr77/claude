# Claude Workflows & Guides

## Directory Structure

```
~/claude/
├── workflows/           # Development workflows (pre-commit, PR, bug handling)
├── standards/           # Code quality, testing, security standards
├── templates/           # Reusable templates (CLAUDE.md, PR, tasks)
├── guides/              # Reference documentation (review, architecture)
├── QUICKSTART_WALKTHROUGH.md  # Installation & setup guide
└── README.md
```

---

## Sharing Guidelines

Files are categorized by shareability:

**All files in ~/claude are shareable.** No project-specific or credential-containing files.

- **workflows/** - Development workflows
- **standards/** - Code quality standards
- **templates/** - Reusable templates (with placeholders)
- **guides/** - Reference documentation

Project-specific files (with credentials) should live in the project itself, e.g., `~/myproject/.claude/`

---

## New Project Setup

**Tell Claude**: "Set up this project using ~/claude/README.md"

**Claude will:**
1. Read `templates/CLAUDE_MD_TEMPLATE.md`
2. Ask you for the placeholder values (see table below)
3. Create `CLAUDE.md` in your project root
4. Optionally create `.claude/` for project-specific files

---

## Quick Start

**New to Claude Code?** Start with `QUICKSTART_WALKTHROUGH.md` for installation and setup.

**Pick your workflow:**

- **Committing code?** → `workflows/PRE_COMMIT_WORKFLOW.md`
- **Creating PR?** → `workflows/PR_READINESS_CHECKLIST.md`
- **Fixing bug?** → `workflows/BUG_HANDLING_WORKFLOW.md`
- **Removing deprecations?** → `workflows/DEPRECATION_REMOVAL_WORKFLOW.md`
- **Responding to feedback?** → `guides/PR_RESPONSE_GUIDE.md`
- **Reviewing code?** → `guides/CODE_REVIEW_GUIDE.md`

**Need format reference?**

- **Commit format?** → `standards/COMMIT_MESSAGE_FORMAT.md`
- **PR description?** → `templates/PR_TEMPLATE.txt`
- **Jira operations?** → `workflows/JIRA_UPDATE_PATTERN.md`

---

## File Reference by Directory

### workflows/

| File | Description | When to Use |
|------|-------------|-------------|
| `PRE_COMMIT_WORKFLOW.md` | Pre-commit quality checks | **Before every commit** |
| `PR_READINESS_CHECKLIST.md` | Complete PR creation workflow | Ready to create PR |
| `PR_SUBMISSION_WORKFLOW.md` | Detailed PR creation guide | Creating PR |
| `BUG_HANDLING_WORKFLOW.md` | Bug triage to resolution | Fixing bugs |
| `DEPRECATION_REMOVAL_WORKFLOW.md` | API deprecation workflow | Removing deprecated code |
| `GIT_WORKFLOW.md` | Branch naming, rebase/merge | Git operations |
| `SELF_REVIEW_CHECKLIST.md` | Pre-PR self-review | Before creating PR |
| `WORKFLOW_ENFORCEMENT.md` | Meta-rules for workflows | Understanding enforcement |
| `USER_EDIT_WORKFLOW.md` | User-editable text pattern | Commit msgs, PR descriptions |
| `JIRA_UPDATE_PATTERN.md` | Jira operations pattern | Updating Jira tickets |
| `JIRA_ISSUE_CREATION_GUIDE.md` | Creating Jira issues | New Jira tickets |

### standards/

| File | Description |
|------|-------------|
| `QUALITY_CHECKS.md` | fmt/lint/test patterns |
| `COMMIT_MESSAGE_FORMAT.md` | Commit message standards |
| `BASE_CODE_QUALITY_CHECKLIST.md` | Quality standards |
| `CODING_STANDARDS.md` | Code conventions |
| `TESTING_STANDARDS.md` | Test quality principles |
| `COMMUNICATION_PREFERENCES.md` | Output format (ASCII-only) |
| `SECURITY_SECRETS_SCAN.md` | Pre-commit security scan |
| `SECURITY_SCANNER.md` | Vulnerability checking |
| `REQUIREMENTS_VALIDATION.md` | Requirements validation |

### templates/

| File | Description |
|------|-------------|
| `CLAUDE_MD_TEMPLATE.md` | Template for project CLAUDE.md |
| `CLAUDE_MD_QUICKSTART.md` | Quick setup guide |
| `CLAUDE_MD_TEMPLATE_USAGE.md` | Detailed usage instructions |
| `README_TEMPLATE_SYSTEM.md` | Template system documentation |
| `COMMON_TASKS_TEMPLATE.md` | Template for common tasks |
| `PR_TEMPLATE.txt` | PR description template |

### guides/

| File | Description |
|------|-------------|
| `CODE_REVIEW_GUIDE.md` | Maintainer review guide |
| `PR_RESPONSE_GUIDE.md` | Responding to feedback |
| `ARCHITECTURE_GUIDE.md` | Architecture patterns |

---

## Workflow Architecture

The workflows follow a **3-tier hierarchy**:

```
TIER 1: BASE PATTERNS (Atomic, reusable)
├── standards/QUALITY_CHECKS.md
├── standards/COMMIT_MESSAGE_FORMAT.md
├── standards/BASE_CODE_QUALITY_CHECKLIST.md
├── workflows/JIRA_UPDATE_PATTERN.md
└── templates/PR_TEMPLATE.txt

TIER 2: CORE WORKFLOWS (Frequently used)
├── workflows/PRE_COMMIT_WORKFLOW.md
├── workflows/GIT_WORKFLOW.md
└── workflows/SELF_REVIEW_CHECKLIST.md

TIER 3: COMPOSITE WORKFLOWS (Complex, orchestrate multiple)
├── workflows/PR_READINESS_CHECKLIST.md
├── workflows/BUG_HANDLING_WORKFLOW.md
└── workflows/PR_SUBMISSION_WORKFLOW.md
```

**See `workflows/WORKFLOW_ENFORCEMENT.md`** for complete architecture documentation.

---

## Usage Tips

**Starting a new task:**
1. Check if a TIER 3 workflow applies (PR_READINESS, BUG_HANDLING)
2. Follow that workflow - it references lower tiers automatically
3. If no composite workflow fits, use TIER 2 workflows directly
4. For quick reference, use TIER 1 patterns directly

**Setting up a new project:**
1. Copy `templates/CLAUDE_MD_TEMPLATE.md` to your project as `CLAUDE.md`
2. Replace placeholders (see below)
3. Optionally copy `templates/COMMON_TASKS_TEMPLATE.md` for project tasks
4. Create `.claude/` in project for project-specific files with credentials

**Placeholders to replace:**

| Variable | Description | Example |
|----------|-------------|---------|
| `{PROJECT}` | Project name | MLRun |
| `{PROJECT_KEY}` | Jira project key | ML |
| `{ORG}` | GitHub organization | mlrun |
| `{REPO}` | Repository name | mlrun |
| `{MAIN_BRANCH}` | Main branch | development, main |
| `{UPSTREAM_REMOTE}` | Remote to fetch from | upstream |
| `{ORIGIN_REMOTE}` | Remote to push/PR | origin |
| `{JIRA_CLOUD_ID}` | Atlassian cloud ID | Use `mcp__atlassian__getAccessibleAtlassianResources()` |
| `{JIRA_INSTANCE}` | Jira instance | jira.iguazeng |
| `{LANGUAGE}` | Programming language | Python, Go, TypeScript |
| `{VERSION}` | Language version | 3.9, 1.24.0 |
| `{PROJECT_PATH}` | Project directory | ~/myproject |
| `{ENV_NAME}` | Virtual env (Python) | myproject-venv |
| `{TEST_COMMAND}` | Test command | pytest, go test ./... |
| `{BUILD_COMMAND}` | Build command | make build |

**Finding what you need:**
- **Format/pattern reference?** → `standards/`
- **Common operation?** → `workflows/`
- **Complete end-to-end workflow?** → `workflows/` (TIER 3)
- **Domain knowledge?** → `guides/`
- **Starting new project?** → `templates/`

---

## MCP Server Setup

Install MCP servers directly from Claude using `/mcp add`:

| Command | Purpose |
|---------|---------|
| `/mcp add memory` | Persistent storage for context, decisions, credentials |
| `/mcp add atlassian` | Jira integration (create, update, comment on tickets) |
| `/mcp add chroma` | Vector database for semantic code search |

**Verify installation**: `/mcp` shows connected servers.

See `QUICKSTART_WALKTHROUGH.md` for detailed setup instructions.

---

## Context Storage: When to Use What

| Storage | Scope | Persistence | Best For |
|---------|-------|-------------|----------|
| `~/claude/` | Global (all projects) | Git-tracked files | Workflows, standards, templates - shared across all projects |
| `CLAUDE.md` | Per-project | Git-tracked file | Project config, triggers, environment setup - committed to repo |
| `.mcp.json` | Per-project | Git-tracked file | Project-specific MCP servers - committed to repo |
| Memory MCP | Per-session* | File-based | Credentials, decisions, context - survives restarts, NOT in git |
| Chroma MCP | Per-collection | File-based | Code embeddings, semantic search - large data, NOT in git |

*Memory MCP persists to disk but data location depends on configuration.

**Quick decision guide**:
- **Reusable across projects?** -> `~/claude/`
- **Project-specific config?** -> `CLAUDE.md` or `.mcp.json`
- **Sensitive data (passwords, tokens)?** -> Memory MCP (never in files)
- **Need semantic/similarity search?** -> Chroma MCP
- **Remember decisions/context?** -> Memory MCP

---

**Last Updated**: 2025-12-02
**Total Files**: 29 files in 4 directories
**Architecture**: 3-tier hierarchical structure
