# CLAUDE.md Template System

## Overview

The CLAUDE.md template system provides a standardized way to create project-specific Claude configuration files that integrate with universal workflow guides.

## Files

### 1. CLAUDE_MD_TEMPLATE.md
**Purpose**: Complete template for creating project CLAUDE.md files

**Contents**:
- Universal workflow enforcement framework
- References to shared workflow guides in ~/claude/
- Project-specific configuration sections
- Placeholder system for easy customization
- Examples for Python, Go, and Node.js projects

**Size**: 528 lines, ~19KB

### 2. CLAUDE_MD_TEMPLATE_USAGE.md
**Purpose**: Comprehensive guide for using the template

**Contents**:
- Quick start instructions
- Step-by-step customization guide
- Section-by-section documentation
- Real-world examples
- Best practices
- Troubleshooting guide

**Size**: 362 lines, ~11KB

## Architecture

```
~/claude/                          <- Shared workflow guides (universal)
├── PRE_COMMIT_WORKFLOW.md
├── PR_READINESS_CHECKLIST.md
├── BUG_HANDLING_WORKFLOW.md
├── CODING_STANDARDS.md
├── TESTING_STANDARDS.md
├── SELF_REVIEW_CHECKLIST.md
├── CODE_REVIEW_GUIDE.md
├── PR_RESPONSE_GUIDE.md
├── JIRA_ISSUE_CREATION_GUIDE.md
├── GIT_WORKFLOW.md
├── ...and more...
│
├── CLAUDE_MD_TEMPLATE.md         <- Template for projects
└── CLAUDE_MD_TEMPLATE_USAGE.md   <- Usage guide

/project1/CLAUDE.md                <- Project-specific config (references ~/claude/)
/project2/CLAUDE.md                <- Project-specific config (references ~/claude/)
/project3/CLAUDE.md                <- Project-specific config (references ~/claude/)
```

## Benefits

### 1. Single Source of Truth
- Workflow guides maintained in one place (`~/claude/`)
- Updates automatically apply to all projects
- No duplication of workflow documentation

### 2. Consistency
- All projects follow same workflow enforcement
- Standardized structure across projects
- Common terminology and patterns

### 3. Easy Adoption
- Copy template → Replace placeholders → Done
- Built-in examples for common languages
- Comprehensive usage guide included

### 4. Flexibility
- Universal sections (don't modify)
- Project-specific sections (customize freely)
- Optional sections (include/remove as needed)

### 5. Maintainability
- Update workflows once in `~/claude/`
- Projects reference, don't copy
- Clear separation of universal vs project-specific

## Quick Start

```bash
# 1. Copy template to your project
cd /path/to/your/project
cp ~/claude/CLAUDE_MD_TEMPLATE.md ./CLAUDE.md

# 2. Get your Jira Cloud ID (in Claude Code)
mcp__atlassian__getAccessibleAtlassianResources()

# 3. Replace placeholders (use find-and-replace)
# Key placeholders:
#   {PROJECT}, {PROJECT_KEY}, {JIRA_CLOUD_ID}
#   {ORG}/{REPO}, {MAIN_BRANCH}, {LANGUAGE}

# 4. Customize project-specific sections
#   - Project Status
#   - Environment Configuration
#   - Testing Configuration
#   - Essential Commands

# 5. Remove optional sections if not applicable

# 6. Add project-specific documentation at the end
```

## Reference Projects

See these real-world examples:
- **MLRun** (Python): `~/mlrun/CLAUDE.md`
- **Gibby** (Go): `~/gibby/CLAUDE.md`

## Key Concepts

### Universal Sections (Do Not Modify)
These sections are the same across all projects:
- Workflow Triggers
- Workflow Enforcement Rules
- TodoWrite requirements
- Verification checkpoints
- Workflow auto-detection
- Quick reference table

**Why**: These are proven, tested patterns that ensure workflow automation works correctly.

### Project-Specific Sections (Customize)
These sections vary by project:
- Project Status (current/recent work)
- Environment Configuration
- Testing Configuration
- Essential Commands
- Critical Patterns (language-specific)
- Project-specific documentation

**Why**: Every project has unique setup, commands, and domain knowledge.

### Reference System
Instead of copying workflow documentation, CLAUDE.md files **reference** shared guides:

```markdown
### [PRE-COMMIT] Protocol
**ACTION**: ALWAYS read and follow `~/claude/PRE_COMMIT_WORKFLOW.md`
```

**Benefits**:
- No duplication
- Automatic updates when guides improve
- Consistent behavior across projects

## Template Placeholders

The template uses a clear placeholder system:

| Placeholder | Example | Description |
|-------------|---------|-------------|
| `{PROJECT}` | MLRun | Project name |
| `{PROJECT_KEY}` | ML | Jira project key |
| `{PROJECT_NAME}` | MLRun Platform | Full project name |
| `{JIRA_CLOUD_ID}` | 1374a6f1-... | Atlassian cloud ID |
| `{ORG}/{REPO}` | mlrun/mlrun | GitHub path |
| `{MAIN_BRANCH}` | development | Main branch name |
| `{LANGUAGE}` | Python 3.9 | Language + version |
| `{REMOTE_NAME}` | upstream | Git remote name |

**See template for complete list**

## Workflow Integration

The template integrates with the complete workflow system:

### Pre-Commit Workflow
```
User: "commit"
Claude:
1. Creates TodoWrite with fmt → lint → self-review → tests
2. Shows verification checklist
3. Runs each step, marking complete
4. Only commits when all checkmarks green
```

### PR Readiness Workflow
```
User: "create pr"
Claude:
1. Creates TodoWrite with 8-step checklist
2. Shows verification checklist
3. Executes: fmt → lint → tests → review → commit → push → PR → Jira
4. Confirms all steps complete before finishing
```

### Bug Handling Workflow
```
User: "fix bug GIB-136"
Claude:
1. Reads BUG_HANDLING_WORKFLOW.md
2. Creates systematic approach
3. Implements fix with full workflow
4. Updates Jira, creates PR
```

## Verification

Before considering a CLAUDE.md file complete, verify:

- [ ] All `{PLACEHOLDERS}` replaced
- [ ] Jira Cloud ID correct (test with MCP tool)
- [ ] Project key matches Jira
- [ ] Commands work (test in terminal)
- [ ] No `[CUSTOMIZE]` markers remain
- [ ] Optional sections removed if N/A
- [ ] Project Status is current
- [ ] Last Updated date is today

## Maintenance

### When to Update Project CLAUDE.md
**High Priority**:
- Starting new work → Update "Current Work"
- Build/test commands change
- Environment setup changes

**Medium Priority**:
- New features → Add documentation
- Architecture changes

**Low Priority**:
- General improvements
- Adding examples

### When to Update ~/claude/ Guides
**Update workflow guides when**:
- Workflow improvements discovered
- New patterns established
- Better practices identified

**Projects automatically benefit** - no need to update individual CLAUDE.md files!

## Version History

### Version 1.0 (2025-11-20)
- Initial template release
- Supports Python, Go, Node.js projects
- Complete placeholder system
- Comprehensive usage guide
- Reference architecture established

## Support

### Getting Help
1. **Read the usage guide**: `CLAUDE_MD_TEMPLATE_USAGE.md`
2. **Check examples**: `~/mlrun/CLAUDE.md`, `~/gibby/CLAUDE.md`
3. **Ask Claude**: "Help me set up CLAUDE.md for my project"

### Contributing
Found an improvement? Update the template and usage guide:
- `~/claude/CLAUDE_MD_TEMPLATE.md`
- `~/claude/CLAUDE_MD_TEMPLATE_USAGE.md`
- `~/claude/README_TEMPLATE_SYSTEM.md` (this file)

---

**Created**: 2025-11-20
**Version**: 1.0
**Status**: Production Ready
