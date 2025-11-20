# CLAUDE.md Template Usage Guide

## Purpose

The `CLAUDE_MD_TEMPLATE.md` provides a standardized framework for creating project-specific `CLAUDE.md` files that integrate with the universal workflow system in `~/claude/`.

## Benefits

1. **Consistency**: All projects follow the same workflow enforcement rules
2. **Reusability**: Leverage shared workflow guides from `~/claude/`
3. **Efficiency**: No need to recreate workflow documentation per project
4. **Maintainability**: Update workflows in one place (`~/claude/`), applies to all projects
5. **Onboarding**: New projects get best practices automatically

## Quick Start

### Step 1: Copy Template to Project
```bash
cd /path/to/your/project
cp ~/claude/CLAUDE_MD_TEMPLATE.md ./CLAUDE.md
```

### Step 2: Get Jira Cloud ID
```bash
# In Claude Code, run:
mcp__atlassian__getAccessibleAtlassianResources()
```

### Step 3: Replace Placeholders

Use find-and-replace in your editor to update these critical placeholders:

| Placeholder | Example | Where to Find |
|-------------|---------|---------------|
| `{PROJECT}` | MLRun | Project name |
| `{PROJECT_KEY}` | ML | Jira project settings |
| `{JIRA_CLOUD_ID}` | 1374a6f1-f268-... | MCP tool (step 2) |
| `{ORG}/{REPO}` | mlrun/mlrun | GitHub URL |
| `{MAIN_BRANCH}` | development | Git config |
| `{LANGUAGE}` | Python 3.9 | Project tech stack |

### Step 4: Customize Sections

Update these sections with project-specific details:

1. **Project Status** - Current and recent work
2. **Environment Configuration** - Setup instructions
3. **Testing Configuration** - Test commands
4. **Essential Commands** - Build, test, deploy
5. **Project-Specific Documentation** - Add custom sections

### Step 5: Remove Optional Sections

If not applicable, remove:
- `[DEPRECATION REMOVAL] Protocol` (if no API deprecation policy)
- `Database Configuration` (if no database)
- `Deployment Configuration` (if no deployment)
- `Memory MCP` section (if not using memory server)

## Example Customizations

### Python Project (like MLRun)

```markdown
### Development Environment
- **Language**: Python 3.9
- **Package Manager**: pip/conda
- **Working Directory**: `/home/user/mlrun`
- **Virtual Environment**: mlrun-base

### Code Quality
```bash
make fmt          # Format with black/ruff
make lint         # Lint with ruff/mypy
pytest            # Run tests
```

### Go Project (like Gibby)

```markdown
### Development Environment
- **Language**: Go 1.24.0
- **Package Manager**: Go modules
- **Working Directory**: `/home/user/gibby`
- **Build**: `go build -o gibctl ./cmd/gibctl/main.go`

### Code Quality
```bash
make fmt          # Format with gofmt
make lint         # Lint with golangci-lint
go test ./...     # Run tests
go build ./...    # Build all packages
```

### Node.js/TypeScript Project

```markdown
### Development Environment
- **Language**: TypeScript 5.x / Node.js 20.x
- **Package Manager**: npm
- **Working Directory**: `/home/user/myproject`
- **Build**: `npm run build`

### Code Quality
```bash
npm run format    # Format with prettier
npm run lint      # Lint with eslint
npm test          # Run tests with jest
npm run build     # Build project
```

## Section-by-Section Guide

### Workflow Triggers Section
**DO NOT MODIFY** - Keep as-is. These are universal across all projects.

**Exception**: Update project key in examples:
- Change `ML-XXXXX` to `{YOUR_PROJECT_KEY}-XXXXX`

### Workflow Enforcement Rules
**DO NOT MODIFY** - These rules are universal and critical.

### Workflow Guides Reference
**MINIMAL CHANGES**:
- Update language in "Coding Standards" description (Python/Go/TypeScript)
- Add/remove optional guides (DEPRECATION_REMOVAL, COMMON_TASKS)
- Update Domain Glossary filename if exists

### Project Status
**ALWAYS CUSTOMIZE** - This is the most frequently updated section:
```markdown
### Current Work
**Status**: [IN PROGRESS] **ML-11516: Add start_infer_time to _get_records() output**
- [DONE] Added START_INFER_TIME to metrics and app_results tables
- [DONE] Extended existing tests to verify column presence
- [IN PROGRESS] Addressing PR review feedback

### Recent Completed Work
- [DONE] **ML-11435**: Data-Flows Deprecations (1.8.0 -> 1.11.0)
- [DONE] **ML-11408**: Fix case sensitivity bug in model monitoring
```

**Best Practice**: Update this section:
- When starting new work
- After completing significant milestones
- After merging PRs

### Environment Configuration
**ALWAYS CUSTOMIZE** - Project-specific setup:

**Essential Fields**:
- Git repository details (branch, remote names)
- Development environment (language, version, paths)
- Testing configuration (commands, environment variables)
- Build/deployment commands

**Tips**:
- Be explicit about environment setup steps
- Include all required environment variables
- Document database connections (if applicable)
- Add troubleshooting notes for common setup issues

### Essential Commands
**ALWAYS CUSTOMIZE** - Daily commands:

**Categories to include**:
1. **Code Quality**: fmt, lint, test, build
2. **Git Operations**: Standard git workflows
3. **Jira Operations**: MCP tool examples (update cloud ID and project key)

**Format**:
```bash
# Clear description
command --with-flags arg1 arg2

# Include comments for complex commands
export ENV_VAR=value  # Explanation of why this is needed
```

### Critical Patterns & Reminders
**MINIMAL CHANGES**:
- Update language-specific reminders (Python → Go idioms)
- Update remote name if using fork workflow
- Keep all workflow requirements intact

### MCP Server Configuration
**OPTIONAL** - Document available MCP servers:

**Atlassian MCP**: Update cloud ID and project key
**Memory MCP**: Keep or remove based on usage

### Project-Specific Documentation
**ALWAYS CUSTOMIZE** - Add custom sections:

**Common additions**:
- Architecture overview
- Feature documentation
- API documentation
- Troubleshooting guides
- Common workflows
- Debugging tips
- Performance optimization notes
- Security considerations

## Verification Checklist

Before committing your new `CLAUDE.md`:

- [ ] All `{PLACEHOLDERS}` replaced with actual values
- [ ] Jira Cloud ID verified (run MCP tool to confirm)
- [ ] Project key matches Jira project
- [ ] Main branch name matches git config
- [ ] Test commands work in project environment
- [ ] Build commands are correct
- [ ] No `[CUSTOMIZE]` markers remain in production sections
- [ ] Optional sections removed if not applicable
- [ ] Project Status section has current work
- [ ] Last Updated date is current

## Examples

### Real-World Templates

Reference these projects for examples:
- **MLRun** (Python): `~/mlrun/CLAUDE.md`
- **Gibby** (Go): `~/gibby/CLAUDE.md`

## Maintenance

### When to Update CLAUDE.md

**High Priority** (Update immediately):
- Starting new work → Update "Current Work" section
- Completing work → Move to "Recent Completed Work"
- Changing build/test commands
- Adding new environment variables
- Updating Jira project/cloud ID

**Medium Priority** (Update when convenient):
- Adding new features → Add documentation section
- Architecture changes → Update architecture notes
- New common workflows → Add to project-specific sections

**Low Priority** (Update occasionally):
- General improvements to documentation
- Adding troubleshooting tips
- Expanding examples

### Workflow Guide Updates

**IMPORTANT**: You do NOT need to update individual `CLAUDE.md` files when workflow guides in `~/claude/` change. That's the whole point of the reference system!

**When workflow guides are updated in `~/claude/`**:
- All projects automatically use the new workflows
- No need to copy changes to project CLAUDE.md files
- The reference system keeps everything in sync

**Only update CLAUDE.md when**:
- Project-specific details change
- Adding custom sections
- Updating project status

## Best Practices

### 1. Keep Workflow Sections Intact
**Don't modify**:
- Workflow Triggers section
- Workflow Enforcement Rules
- TodoWrite examples
- Verification checklists

**Why**: These are tested, proven patterns. Modifications risk breaking workflow automation.

### 2. Be Explicit in Environment Config
```markdown
# Good - Explicit and complete
export MLRUN_DBPATH=postgres://user:pass@host:5432/db
export MLRUN_HTTPDB__HTTP__VERIFY=false
conda activate mlrun-base
pytest tests/model_monitoring/

# Bad - Vague and incomplete
Set up the database and run tests
```

### 3. Document Common Pitfalls
```markdown
### Common Issues

**Issue**: Tests fail with "database connection refused"
**Solution**: Check database is running with `docker ps` and restart if needed:
```bash
docker restart timescaledb
```

### 4. Keep Status Current
```markdown
# Good - Specific and actionable
**Status**: [IN PROGRESS] **GIB-136: Fix recovery mode state corruption**
- [DONE] Identified root cause: CreateDate vs Meta.ID mismatch
- [DONE] Implemented fix in pathmapper.go
- [IN PROGRESS] Writing integration tests
- [PENDING] Manual testing with crash simulation

# Bad - Vague and outdated
**Status**: Working on stuff
```

### 5. Make Commands Copy-Paste Ready
```markdown
# Good - Complete command ready to run
/usr/bin/env ~/miniconda3/envs/mlrun-base-vb/bin/python -m pytest tests/system/model_monitoring/test_app.py -v

# Bad - Requires user to figure out details
Run pytest on the test file
```

## Troubleshooting

### Template Placeholders Still Visible
**Problem**: Seeing `{PLACEHOLDER}` in your CLAUDE.md
**Solution**: Use find-and-replace to update all placeholders. Common ones:
- `{PROJECT_KEY}`, `{JIRA_CLOUD_ID}`, `{ORG}/{REPO}`, `{LANGUAGE}`

### Workflow Not Triggering
**Problem**: Claude not following PRE-COMMIT workflow when I say "commit"
**Solution**:
1. Check CLAUDE.md is in project root
2. Verify "Workflow Triggers" section is intact
3. Try explicit trigger: "Run the pre-commit workflow"

### Jira MCP Tools Not Working
**Problem**: `mcp__atlassian__*` tools returning errors
**Solution**:
1. Verify Jira Cloud ID with `mcp__atlassian__getAccessibleAtlassianResources()`
2. Check project key exists in Jira
3. Confirm MCP server is connected (check available tools)

### Build/Test Commands Failing
**Problem**: Commands in CLAUDE.md don't work
**Solution**:
1. Verify commands work manually first
2. Check environment variables are set
3. Confirm paths are correct (absolute vs relative)
4. Test in clean shell to catch missing setup steps

## Support

### Getting Help
1. **Check examples**: Look at `~/mlrun/CLAUDE.md` or `~/gibby/CLAUDE.md`
2. **Review workflow guides**: Read specific guides in `~/claude/` for details
3. **Ask Claude**: "Help me set up CLAUDE.md for my project"

### Feedback
Found issues with the template or have suggestions? Update:
- `~/claude/CLAUDE_MD_TEMPLATE.md` - The template itself
- `~/claude/CLAUDE_MD_TEMPLATE_USAGE.md` - This usage guide

---

**Last Updated**: 2025-11-20
**Template Version**: 1.0
