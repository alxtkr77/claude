# CLAUDE.md Quick Start Card

> **Goal**: Set up CLAUDE.md for a new project in 5 minutes

## 1. Copy Template (30 seconds)

```bash
cd /path/to/your/project
cp ~/claude/CLAUDE_MD_TEMPLATE.md ./CLAUDE.md
```

## 2. Get Jira Cloud ID (30 seconds)

In Claude Code, run:
```
mcp__atlassian__getAccessibleAtlassianResources()
```

Copy the `id` value that matches your Jira instance.

## 3. Find-and-Replace Core Placeholders (2 minutes)

Open `CLAUDE.md` and replace:

| Find | Replace With | Example |
|------|--------------|---------|
| `{PROJECT}` | Project name | `MLRun` |
| `{PROJECT_KEY}` | Jira project key | `ML` |
| `{PROJECT_NAME}` | Full project name | `MLRun Platform` |
| `{JIRA_CLOUD_ID}` | Cloud ID from step 2 | `1374a6f1-f268-4a06-909e-b3a9675a9bd1` |
| `{ORG}/{REPO}` | GitHub org/repo | `mlrun/mlrun` |
| `{MAIN_BRANCH}` | Main branch name | `development` |
| `{LANGUAGE}` | Language + version | `Python 3.9` or `Go 1.24` |

## 4. Update Key Sections (2 minutes)

### Project Status (line ~210)
```markdown
### Current Work
**Status**: [IN PROGRESS] **ML-11516: Add start_infer_time field**
- [IN PROGRESS] Implementing database schema changes
```

### Testing Configuration (line ~236)
```bash
# Python example
pytest tests/

# Go example
go test ./...

# Node.js example
npm test
```

### Essential Commands (line ~265)
```bash
make fmt          # Your format command
make lint         # Your lint command
pytest            # Your test command (or go test, npm test)
```

## 5. Remove Optional Sections (30 seconds)

If not applicable, delete:
- Line ~32: `[DEPRECATION REMOVAL] Protocol` (if no deprecation policy)
- Line ~252: `Database Configuration` section (if no database)
- Line ~614: `Memory MCP` section (if not using memory MCP)

## 6. Verify (30 seconds)

Run these checks:
```bash
# Check no placeholders remain
grep -n '{.*}' CLAUDE.md

# Verify commands work
make fmt
make lint
# ... test command from step 4
```

## Done!

Your project now has:
- ✅ Universal workflow enforcement
- ✅ Pre-commit workflow integration
- ✅ PR readiness checklist
- ✅ Jira integration
- ✅ Code quality standards

## What Next?

### Update Project Status Regularly
When starting new work:
```markdown
### Current Work
**Status**: [IN PROGRESS] **{TICKET}: {Description}**
- [IN PROGRESS] Current task
- [PENDING] Next task
```

### Add Project-Specific Documentation
At the end of CLAUDE.md, add:
```markdown
# Project-Specific Documentation

## Architecture Overview
{Your architecture details}

## Common Workflows
{Project-specific workflows}

## Troubleshooting
{Common issues and solutions}
```

### Test Workflow Integration
Try these commands with Claude:
- "commit" → Should trigger pre-commit workflow
- "create pr" → Should trigger PR readiness workflow
- "fix bug {TICKET}" → Should trigger bug handling workflow

## Need Help?

**Full guide**: `~/claude/CLAUDE_MD_TEMPLATE_USAGE.md`
**Examples**:
- `~/mlrun/CLAUDE.md` (Python)
- `~/gibby/CLAUDE.md` (Go)

**Ask Claude**: "Help me customize CLAUDE.md for my {language} project"

---

**Template Version**: 1.0
**Last Updated**: 2025-11-20
