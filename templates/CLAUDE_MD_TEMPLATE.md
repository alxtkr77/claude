# Claude Context

> **Template for Project CLAUDE.md Files**
>
> **Instructions**:
> 1. Copy this template to your project root as `CLAUDE.md`
> 2. Replace all `{PLACEHOLDERS}` with project-specific values
> 3. Update sections marked with `[CUSTOMIZE]` with project details
> 4. Remove sections marked `[OPTIONAL]` if not applicable
> 5. Keep the workflow framework sections intact - they're universal

---

## Universal Principles
**Reference**: `~/.claude/universal_principles.md` - Universal Code Quality Principles
**Apply**: Test quality standards, development workflow, and architecture philosophy from universal principles.

---

## Communication Guidelines
**Reference**: `~/claude/standards/COMMUNICATION_PREFERENCES.md`
**CRITICAL**: Use ASCII characters only in git commits and GitHub PR/review responses - NO emoji, NO Unicode symbols

---

## Workflow Triggers

### [PRE-COMMIT] Protocol ⚠️ ALWAYS RUN BEFORE EVERY COMMIT ⚠️
**TRIGGERS**: BEFORE running `git commit` (ANY commit, not just PRs)
**ACTION**: ALWAYS read and follow `~/claude/workflows/PRE_COMMIT_WORKFLOW.md`
**MANDATORY STEPS**: fmt → lint → self-review → tests → **USER_EDIT_WORKFLOW for commit message**
**APPLIES TO**: Initial commits, review response commits, bug fixes, ALL commits
**NO EXCEPTIONS**: Even for "small changes" or "just responding to feedback"
**CRITICAL**: MUST use `code --wait /tmp/commit_msg.txt` for user to edit commit message

### [PR READINESS] Protocol
**TRIGGERS**: "ready for PR", "create PR", "I want to PR", "submit PR"
**ACTION**: IMMEDIATELY read and follow `~/claude/workflows/PR_READINESS_CHECKLIST.md`
**MANDATORY STEPS**: fmt → lint → tests → self-review → commit → **rebase to {MAIN_BRANCH}** → push → PR creation → Jira update
**DO NOT SKIP**: Run ALL steps in the checklist systematically.
**CRITICAL**: Before pushing, MUST run `git fetch upstream && git rebase upstream/{MAIN_BRANCH}` to ensure no conflicts

### [BUG HANDLING] Protocol
**TRIGGERS**: "fix bug", "handle bug", "debug issue", "investigate bug", receiving bug ticket
**ACTION**: Follow `~/claude/workflows/BUG_HANDLING_WORKFLOW.md`
**WORKFLOW**: Triage → Root Cause Analysis → Fix Implementation → PR → Jira Update → Verification
**CRITICAL**: Evidence-based analysis ONLY - no speculation without logs/stack traces/code evidence

### [DEPRECATION REMOVAL] Protocol [OPTIONAL - Python projects with API deprecation]
**TRIGGERS**: "remove deprecations", "deprecation removal", "remove deprecated APIs"
**ACTION**: Follow `~/claude/workflows/DEPRECATION_REMOVAL_WORKFLOW.md`
**POLICY**: {PROJECT} uses {N}-release deprecation cycle (APIs deprecated in X.Y.0 removed after {N} releases)
**WORKFLOW**: Understand policy → Identify → Categorize → Verify usage → Remove → Test → PR → Jira

### [PR RESPONSE] Protocol
**TRIGGERS**: "respond to PR feedback", "address review comments", "PR review feedback"
**ACTION**: Follow `~/claude/guides/PR_RESPONSE_GUIDE.md`
**PRINCIPLES**: Accept & implement (most common), ask for clarification, provide explanation, discuss alternatives, push back respectfully (with good reason)

### [CODE REVIEW] Protocol
**TRIGGERS**: "review PR", "code review", "review code"
**ACTION**: Follow `~/claude/guides/CODE_REVIEW_GUIDE.md`
**CHECKLIST**: Code quality → Test quality → Architecture → Security → Performance → Documentation

### [SELF-REVIEW] Protocol
**TRIGGERS**: Before creating PR (part of PR readiness workflow)
**ACTION**: Follow `~/claude/workflows/SELF_REVIEW_CHECKLIST.md`
**STEPS**: Review code → Quality checks → Testing review → Security review → Performance review → Architecture review → PR description → Commit history → Dependencies → Breaking changes

### [JIRA WORKFLOW] Protocol
**TRIGGERS**: "create Jira issue", "update Jira", "Jira ticket"
**ACTION**: Follow `~/claude/workflows/JIRA_ISSUE_CREATION_GUIDE.md`
**CLOUDID**: `{JIRA_CLOUD_ID}` ({JIRA_INSTANCE}.atlassian.net)
**PROJECT**: `{PROJECT_KEY}` ({PROJECT_NAME} project)
**COMMON**: Use markdown format `[text](url)` for hyperlinks in Jira comments
**CRITICAL**: ALL Atlassian write operations (comments, transitions, issue creation) REQUIRE user confirmation before execution

### [START WORK] Protocol
**TRIGGERS**: "starting to work on", "work on case", "work on {PROJECT_KEY}-", "implement {PROJECT_KEY}-", "start {PROJECT_KEY}-"
**ACTION**: Follow initial steps from `~/claude/workflows/BUG_HANDLING_WORKFLOW.md`
**MANDATORY STEPS**:
1. Get Jira issue details (understand requirements) - BUG_HANDLING Step 1
2. Create feature branch: `git checkout -b {PROJECT_KEY}-XXXXX-short-description upstream/{MAIN_BRANCH}`
3. Transition Jira to "In Progress"
4. THEN start implementation
**CRITICAL**: Do NOT start coding before branch is created and Jira is updated

---

## WORKFLOW ENFORCEMENT RULES

### Rule 1: MANDATORY TodoWrite for ALL Workflows

**CRITICAL**: When ANY workflow is triggered, Claude MUST:

1. **IMMEDIATELY** create TodoWrite list with ALL workflow steps
2. Mark step as "in_progress" BEFORE executing it
3. Mark as "completed" AFTER successful execution
4. NEVER skip steps - if blocked, keep "in_progress" and explain blocker

**Example - PRE-COMMIT Workflow:**
```
TodoWrite([
    {"content": "Run make fmt", "status": "pending", "activeForm": "Running formatter"},
    {"content": "Run make lint on my changes", "status": "pending", "activeForm": "Running linter"},
    {"content": "Run relevant tests", "status": "pending", "activeForm": "Running tests"},
    {"content": "Security scan: Check git diff for secrets", "status": "pending", "activeForm": "Scanning for leaked credentials"},
    {"content": "Complete self-review checklist", "status": "pending", "activeForm": "Self-reviewing code"},
    {"content": "Generate commit message to /tmp/commit_msg.txt", "status": "pending", "activeForm": "Generating commit message"},
    {"content": "Open in VSCode for user editing (code --wait)", "status": "pending", "activeForm": "Waiting for user to edit message"},
    {"content": "Show preview and get user approval", "status": "pending", "activeForm": "Getting user approval"},
    {"content": "Commit with git commit -F", "status": "pending", "activeForm": "Committing changes"},
    {"content": "Cleanup /tmp/commit_msg.txt", "status": "pending", "activeForm": "Cleaning up temp file"}
])
```

**Example - PR READINESS Workflow:**
```
TodoWrite([
    {"content": "Run make fmt", "status": "pending", "activeForm": "Running formatter"},
    {"content": "Run make lint", "status": "pending", "activeForm": "Running linter"},
    {"content": "Run all relevant tests", "status": "pending", "activeForm": "Running tests"},
    {"content": "Complete self-review checklist", "status": "pending", "activeForm": "Self-reviewing"},
    {"content": "Commit changes", "status": "pending", "activeForm": "Committing changes"},
    {"content": "Push branch to origin", "status": "pending", "activeForm": "Pushing branch"},
    {"content": "Generate PR description to /tmp/pr_description.txt", "status": "pending", "activeForm": "Generating PR description"},
    {"content": "Open in VSCode for user editing (code --wait)", "status": "pending", "activeForm": "Waiting for user to edit PR"},
    {"content": "Show preview and get user approval", "status": "pending", "activeForm": "Getting user approval for PR"},
    {"content": "Create pull request with gh pr create", "status": "pending", "activeForm": "Creating PR"},
    {"content": "Generate Jira comment to /tmp/jira_comment.txt", "status": "pending", "activeForm": "Generating Jira comment"},
    {"content": "Open in VSCode for user editing (code --wait)", "status": "pending", "activeForm": "Waiting for user to edit Jira comment"},
    {"content": "Show preview and get user approval", "status": "pending", "activeForm": "Getting user approval for Jira"},
    {"content": "Update Jira with PR link", "status": "pending", "activeForm": "Updating Jira"},
    {"content": "Cleanup temp files", "status": "pending", "activeForm": "Cleaning up temp files"}
])
```

**Example - START WORK Workflow:**
```
TodoWrite([
    {"content": "Get Jira issue details", "status": "pending", "activeForm": "Reading Jira ticket"},
    {"content": "Create feature branch from upstream/{MAIN_BRANCH}", "status": "pending", "activeForm": "Creating feature branch"},
    {"content": "Transition Jira to In Progress", "status": "pending", "activeForm": "Updating Jira status"},
    {"content": "Start implementation", "status": "pending", "activeForm": "Starting implementation"}
])
```

**NO EXCEPTIONS**: Even for "quick fixes" or "small changes"

---

### Rule 2: Explicit Verification Checkpoints

**BEFORE EVERY COMMIT**, Claude MUST explicitly state:

```
PRE-COMMIT VERIFICATION:
[X] make fmt: PASSED
[X] make lint: PASSED (checked my changes only)
[X] Tests: X/X PASSED
[X] Security scan: NO SECRETS FOUND (API keys, passwords, credentials)
[X] Self-review: COMPLETED
[X] Commit message: Generated to /tmp/commit_msg.txt
[X] User editing: Opened with code --wait (waiting for user...)
[X] User approval: APPROVED
[ ] Ready to commit: YES/NO
```

**BEFORE CREATING PR**, Claude MUST show:

```
PR READINESS VERIFICATION:
[X] make fmt: PASSED
[X] make lint: PASSED
[X] Tests: X/X PASSED
[X] Security scan: NO SECRETS in any commits
[X] Self-review: COMPLETED
[X] Commits: Clean history, proper messages
[X] Branch: Pushed to origin
[X] PR description: Generated and user-edited
[X] PR approval: APPROVED
[X] PR: #XXXX created
[X] Jira comment: Generated and user-edited
[X] Jira approval: APPROVED
[X] Jira: Updated with PR link
[X] Temp files: Cleaned up
[ ] All steps complete: YES/NO
```

**If ANY checkpoint shows [ ] NO or FAILED, Claude MUST STOP and fix before proceeding.**

---

### Rule 3: Workflow Auto-Detection (ALWAYS Check First)

**BEFORE responding to ANY user request, check these high-priority triggers:**

#### PRE-COMMIT Detection (HIGHEST PRIORITY)
**User says ANY of these:**
- "commit" / "git commit" / "ready to commit" / "let's commit"
- "amend" / "git commit --amend"
- About to run: `git commit` command
- Just finished: making code changes

**ACTION**: Read `~/claude/workflows/PRE_COMMIT_WORKFLOW.md` BEFORE proceeding

#### PR READINESS Detection
**User says ANY of these:**
- "create pr" / "make pr" / "open pr" / "new pr"
- "pull request" / "ready for pr" / "submit pr"
- "pr" (as standalone command)

**ACTION**: Read `~/claude/workflows/PR_READINESS_CHECKLIST.md` BEFORE proceeding

#### BUG HANDLING Detection
**User says ANY of these:**
- "fix bug" / "bug fix" / "fix issue"
- "debug" / "investigate bug" / "handle bug"
- Provides bug ticket number (e.g., "{PROJECT_KEY}-XXXXX is a bug")

**ACTION**: Read `~/claude/workflows/BUG_HANDLING_WORKFLOW.md` BEFORE proceeding

#### START WORK Detection
**User says ANY of these:**
- "starting to work on" / "work on case" / "work on {PROJECT_KEY}-"
- "implement {PROJECT_KEY}-" / "start {PROJECT_KEY}-" / "working on ticket"
- Mentions Jira ticket for new feature/task (not bug)

**ACTION**: Follow [START WORK] Protocol - Get Jira details, create branch, update Jira status BEFORE coding

#### Context Clues (Auto-detect workflow needed)
- **Uncommitted changes exist** + user mentions commit → PRE-COMMIT workflow
- **Branch pushed but no PR** + user says "done" → PR READINESS workflow
- **PR exists but Jira not updated** → Complete Jira update step

---

### Rule 4: Workflow Completion Criteria

**A workflow is NOT complete until:**

1. **TodoWrite shows ALL steps completed**
2. **Verification checklist shows ALL checkmarks**
3. **Claude explicitly states**: "Workflow complete: [WORKFLOW_NAME]"

**If interrupted (session ends, error occurs):**
- On resume, check TodoWrite for incomplete workflows
- Continue from last incomplete step
- Never restart workflow from beginning if steps already done

---

### Rule 5: Always Read Workflow Files Before Executing

**CRITICAL**: When a workflow trigger is detected, ALWAYS read the workflow file from disk BEFORE executing.

**Never rely on cached knowledge of workflows - always read fresh from disk.**

| Trigger | File to Read First |
|---------|-------------------|
| "commit", "git commit", "make a commit" | `~/claude/workflows/PRE_COMMIT_WORKFLOW.md` |
| "create pr", "PR", "pull request" | `~/claude/workflows/PR_READINESS_CHECKLIST.md` |
| "fix bug", "debug", "investigate" | `~/claude/workflows/BUG_HANDLING_WORKFLOW.md` |
| "starting to work on", "work on {PROJECT_KEY}-" | `~/claude/workflows/BUG_HANDLING_WORKFLOW.md` (Steps 1+3) |
| "respond to PR", "address review" | `~/claude/guides/PR_RESPONSE_GUIDE.md` |
| "review PR", "code review" | `~/claude/guides/CODE_REVIEW_GUIDE.md` |
| "create Jira", "update Jira" | `~/claude/workflows/JIRA_ISSUE_CREATION_GUIDE.md` |

**Example**:
```python
# When user says "commit", FIRST read the workflow:
Read(file_path="~/claude/workflows/PRE_COMMIT_WORKFLOW.md")
# THEN follow the steps in the workflow
```

---

## Workflow Guides Reference

### Development Workflows
- **⚠️ Pre-Commit**: `~/claude/workflows/PRE_COMMIT_WORKFLOW.md` - **RUN BEFORE EVERY COMMIT** (fmt → lint → self-review → tests)
- **PR Submission**: `~/claude/workflows/PR_SUBMISSION_WORKFLOW.md` - Complete PR creation workflow
- **PR Template**: `~/claude/templates/PR_TEMPLATE.txt` - Standard PR description format
- **Git Workflow**: `~/claude/workflows/GIT_WORKFLOW.md` - Branch naming, commit messages, rebase/merge strategy
- **Bug Handling**: `~/claude/workflows/BUG_HANDLING_WORKFLOW.md` - Complete bug fix workflow from ticket to resolution
- **Deprecation Removal**: `~/claude/workflows/DEPRECATION_REMOVAL_WORKFLOW.md` - Systematic deprecation removal process [OPTIONAL]

### Code Quality Guides
- **Coding Standards**: `~/claude/standards/CODING_STANDARDS.md` - {LANGUAGE} conventions, naming, structure
- **Testing Standards**: `~/claude/standards/TESTING_STANDARDS.md` - Test quality principles and patterns
- **Self-Review**: `~/claude/workflows/SELF_REVIEW_CHECKLIST.md` - Pre-PR self-review checklist
- **Code Review**: `~/claude/guides/CODE_REVIEW_GUIDE.md` - How to conduct effective code reviews
- **PR Response**: `~/claude/guides/PR_RESPONSE_GUIDE.md` - How to respond to review feedback

### Architecture & Domain
- **Architecture Guide**: `~/claude/guides/ARCHITECTURE_GUIDE.md` - {PROJECT} architecture patterns and design principles
- **Domain Glossary**: `~/claude/project-{PROJECT}/{PROJECT}_DOMAIN_GLOSSARY.md` - {PROJECT} terminology and concepts [CUSTOMIZE]

### Task & Requirement Guides
- **Common Tasks**: `~/claude/project-{PROJECT}/COMMON_{PROJECT}_TASKS.md` - Frequently used {PROJECT} operations [OPTIONAL]
- **Requirements Validation**: `~/claude/standards/REQUIREMENTS_VALIDATION.md` - Validating requirements before implementation
- **Security Scanner**: `~/claude/standards/SECURITY_SCANNER.md` - Security scanning and vulnerability checking
- **Communication Preferences**: `~/claude/standards/COMMUNICATION_PREFERENCES.md` - ASCII-only output format guidelines

---

## Project Status

### Current Work [CUSTOMIZE - Update regularly]
**Status**: [{STATUS}] **{TICKET_ID}: {DESCRIPTION}**
- [STATUS] Item 1
- [STATUS] Item 2
- [STATUS] Item 3

### Recent Completed Work [CUSTOMIZE - Update regularly]
- [DONE] **{TICKET_ID}**: {DESCRIPTION}
- [DONE] **{TICKET_ID}**: {DESCRIPTION}
- [DONE] **{TICKET_ID}**: {DESCRIPTION}

---

## Environment Configuration

### Git Repository [CUSTOMIZE]
- **Branch**: Current development work branch (varies)
- **Main Branch**: `{MAIN_BRANCH}` (always use this for PRs)
- **Upstream Remote**: `{UPSTREAM_REMOTE}` for {ORG}/{REPO} (fetch from)
- **Origin Remote**: `{ORIGIN_REMOTE}` for your fork (push to, create PRs)

### Development Environment [CUSTOMIZE]
- **Language**: {LANGUAGE} {VERSION}
- **Package Manager**: {PACKAGE_MANAGER} (npm, pip, go modules, etc.)
- **Working Directory**: `{PROJECT_PATH}`
- **Virtual Environment**: {ENV_NAME} [OPTIONAL - Python projects]
- **Build Command**: `{BUILD_COMMAND}`

### Testing Configuration [CUSTOMIZE]

#### For Python Projects:
```bash
# Activate environment
conda activate {ENV_NAME}

# Set environment variables
export {ENV_VAR_1}={VALUE_1}
export {ENV_VAR_2}={VALUE_2}

# Run all tests
pytest

# Run specific test file
pytest tests/{path}/test_{name}.py

# Run specific test
pytest tests/{path}/test_{name}.py::test_{function}

# Run with verbose output
pytest -v {path}

# Run with coverage
pytest --cov={package}
```

#### For Go Projects:
```bash
# Run all tests
go test ./...

# Run specific package tests
go test ./pkg/{package}/...

# Run with verbose output
go test -v ./...

# Run specific test
go test -run TestSpecificFunction ./pkg/...

# Run with coverage
go test -cover ./...
```

#### For Node.js Projects:
```bash
# Install dependencies
npm install

# Run all tests
npm test

# Run specific test file
npm test -- {file_pattern}

# Run with coverage
npm run test:coverage
```

### Deployment Configuration [CUSTOMIZE - if applicable]
```bash
# Build commands
{BUILD_COMMAND}

# Deployment commands
{DEPLOY_COMMAND}

# Environment-specific configs
{ENVIRONMENT_CONFIGS}
```

### Database Configuration [OPTIONAL - if applicable]
- **Database Type**: {DB_TYPE}
- **Connection String**: {CONNECTION_STRING}
- **Database Host**: {HOST}
- **Database Reset**: {RESET_COMMAND}

---

## Essential Commands

### Code Quality [CUSTOMIZE]
```bash
make fmt          # Format code (ALWAYS run first)
make lint         # Check linting (run after fmt)
{TEST_COMMAND}    # Run tests
{BUILD_COMMAND}   # Build project
```

### Git Operations
```bash
# Pull latest changes (use correct remote!)
git pull {UPSTREAM_REMOTE} {MAIN_BRANCH}

# Create feature branch
git checkout -b feature/{PROJECT_KEY}-XXXXX-description

# Interactive rebase for cleanup
git rebase -i HEAD~N

# Push branch
git push {ORIGIN_REMOTE} feature/{PROJECT_KEY}-XXXXX-description
```

### Jira Operations
```
# Get cloud ID
mcp__atlassian__getAccessibleAtlassianResources()

# Create bug issue (see JIRA_ISSUE_CREATION_GUIDE.md for field values)
mcp__atlassian__createJiraIssue(
    cloudId="{JIRA_CLOUD_ID}",
    projectKey="{PROJECT_KEY}",
    issueTypeName="Bug",
    summary="...",
    description="...",
    additional_fields={...}  # See guide for required fields
)

# Add PR link to Jira (use markdown format!)
mcp__atlassian__addCommentToJiraIssue(
    cloudId="{JIRA_CLOUD_ID}",
    issueIdOrKey="{PROJECT_KEY}-XXXXX",
    commentBody="**PR Link**: [PR #YYYY](https://github.com/{ORG}/{REPO}/pull/YYYY)\n\n<summary>"
)
```

---

## Critical Patterns & Reminders

### PR Creation
- [REQUIRED] **Always** run PR_READINESS_CHECKLIST.md before creating PR
- [REQUIRED] **Always** use pr_template.txt format (from ~/claude/)
- [REQUIRED] **Never** include AI attribution in commits or PR descriptions
- [REQUIRED] **Remove** empty sections from PR description
- [REQUIRED] **Reference** Jira ticket in PR description

### Git Workflow
- [REQUIRED] **Always** pull/fetch from `{UPSTREAM_REMOTE}`, push to `{ORIGIN_REMOTE}`
- [REQUIRED] **Always** create branch from `{MAIN_BRANCH}`
- [REQUIRED] **Always** use imperative mood in commit messages ("Add" not "Added")
- [REQUIRED] **Always** reference Jira ticket in commit message
- [REQUIRED] **Always** include ticket reference: `[{PROJECT_KEY}-XXX]` prefix in commit message

### Jira Workflow
- [REQUIRED] **Always** use markdown format for hyperlinks: `[text](url)`
- [REQUIRED] **Always** update Jira with PR link after PR creation
- [REQUIRED] **Always** transition issue to "In Progress" when starting work

### CLAUDE.md Maintenance
- [REQUIRED] **When updating CLAUDE.md**: Check if change is generic (applies to all projects)
- [REQUIRED] **If generic**: Also update `~/claude/templates/CLAUDE_MD_TEMPLATE.md`
- [REQUIRED] **If workflow-related**: Also update `~/claude/workflows/WORKFLOW_ENFORCEMENT.md`

### Code Quality
- [REQUIRED] **Always** run `make fmt` before `make lint`
- [REQUIRED] **Always** commit ALL formatting changes (including line wraps)
- [REQUIRED] **Always** run tests before creating PR
- [REQUIRED] **Always** follow {LANGUAGE} best practices and idioms [CUSTOMIZE]

---

## QUICK REFERENCE: Workflow Enforcement

| When | Action Required |
|------|----------------|
| User says "starting to work on {PROJECT_KEY}-" | 1. Create TodoWrite with START WORK steps<br>2. Get Jira details<br>3. Create branch<br>4. Update Jira to "In Progress"<br>5. THEN start coding |
| User says "commit" | 1. Create TodoWrite with PRE-COMMIT steps<br>2. Show verification checklist<br>3. Run all steps before committing |
| User says "create pr" | 1. Create TodoWrite with PR READINESS steps<br>2. Show verification checklist<br>3. Run all steps systematically |
| Session resumes | 1. Check TodoWrite for incomplete workflows<br>2. Continue from last step<br>3. Show what's pending |
| Any step fails | 1. Keep step as "in_progress"<br>2. Fix the issue<br>3. Complete step, then continue |

**Remember**: TodoWrite is MANDATORY. Verification checklists are MANDATORY. No shortcuts, no exceptions.

---

## Sensitive Information & Credentials

### CRITICAL: Never Store in CLAUDE.md
**This file is typically committed to version control. NEVER include:**
- Passwords or passphrases
- API keys or tokens
- Private keys (SSH, SSL, PGP)
- Database credentials
- Cloud provider secrets (AWS, Azure, GCP)
- OAuth client secrets
- Personal email addresses

### Where to Store Credentials

**Option 1: Memory MCP (Recommended)**
```
# Store credential in Memory MCP
mcp__memory__create_entities([{
    "name": "db_credentials",
    "entityType": "credential",
    "observations": ["DB_HOST=192.168.1.100", "DB_USER=testuser", "DB_PASSWORD=secretpass"]
}])

# Retrieve when needed
mcp__memory__search_nodes(query="db_credentials")
```

**Option 2: Environment Variables**
```bash
# Set in shell before running Claude
export DB_PASSWORD="secretpass"
export API_KEY="sk-xxx..."

# Reference in CLAUDE.md
export DB_PASSWORD=$DB_PASSWORD  # Variable reference, not actual value
```

**Option 3: Private Project Files (only if repo is private)**
```bash
# Create .env file (add to .gitignore!)
echo "DB_PASSWORD=secretpass" >> .env
echo ".env" >> .gitignore
```

### How to Reference Credentials in CLAUDE.md

**DO:**
```yaml
# Reference by variable name
Database Password: Set in Memory MCP as "db_credentials"
SSH Credentials: Found in environment yaml at install.data_cluster.ssh_credentials
API Key: Set via $API_KEY environment variable
```

**DON'T:**
```yaml
# NEVER include actual values
Database Password: secretpass123  # WRONG!
SSH Password: mypassword          # WRONG!
API Key: sk-ant-xxx...            # WRONG!
```

### Files That Should Use .gitignore

Add these patterns to `.gitignore`:
```
.env
.env.local
.env.*.local
credentials.json
secrets.yaml
*.pem
*.key
id_rsa
```

---

## MCP Server Configuration

### Atlassian MCP (Active)
**Status**: ✅ Connected and operational
**Available Tools**:
- `mcp__atlassian__*` - Jira/Confluence integration
- Cloud ID: `{JIRA_CLOUD_ID}`
- Project: {PROJECT_KEY} ({PROJECT_NAME})

### Memory MCP (Available for Configuration) [OPTIONAL]
**Configuration**: `~/.claude/mcp.json`
```json
{
  "mcpServers": {
    "atlassian": {
      // ... existing atlassian config
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

**Purpose**: Persistent context storage across sessions
**Operations**:
- Store important project context and decisions
- Retrieve previously stored information
- Maintain continuity across sessions

**Note**: To enable memory MCP, ensure it's configured in `~/.claude/mcp.json` and restart Claude Code.

---

# Project-Specific Documentation [CUSTOMIZE]

> **Instructions**: Add project-specific sections below this line
> Examples: Architecture details, feature documentation, troubleshooting guides, etc.

## {Feature/Component Name}

### Overview
{Description of feature/component}

### Architecture
{Architecture details}

### Implementation Details
{Implementation details}

### Usage
{Usage examples}

### Testing
{Testing approach}

---

**Last Updated**: {DATE}
**Note**: For detailed workflow steps, always consult the specific guide in ~/claude/

---

## Template Placeholders Reference

Replace these placeholders when using this template:

**Project Info:**
- `{PROJECT}` - Project name (e.g., "MLRun", "Gibby")
- `{PROJECT_KEY}` - Jira project key (e.g., "ML", "GIB")
- `{PROJECT_NAME}` - Full project name (e.g., "MLRun Platform", "Gibby Backup Tool")
- `{ORG}` - GitHub organization (e.g., "mlrun", "iguazio")
- `{REPO}` - GitHub repository name (e.g., "mlrun", "gibby")

**Jira Config:**
- `{JIRA_CLOUD_ID}` - Atlassian cloud ID (get with `mcp__atlassian__getAccessibleAtlassianResources()`)
- `{JIRA_INSTANCE}` - Jira instance name (e.g., "jira.iguazeng", "iguazio")

**Git Config:**
- `{MAIN_BRANCH}` - Main branch name (e.g., "development", "main", "master")
- `{UPSTREAM_REMOTE}` - Remote to fetch/pull from (e.g., "upstream")
- `{ORIGIN_REMOTE}` - Remote to push to and create PRs (e.g., "origin")

**Environment:**
- `{LANGUAGE}` - Programming language (e.g., "Python", "Go", "TypeScript")
- `{VERSION}` - Language version (e.g., "3.9", "1.24.0", "20.x")
- `{PACKAGE_MANAGER}` - Package manager (e.g., "pip", "go modules", "npm")
- `{PROJECT_PATH}` - Full project path (e.g., "/home/user/project")
- `{ENV_NAME}` - Virtual environment name [Python only]

**Commands:**
- `{BUILD_COMMAND}` - Build command (e.g., "npm run build", "go build ./...", "python setup.py build")
- `{TEST_COMMAND}` - Test command (e.g., "pytest", "go test ./...", "npm test")
- `{DEPLOY_COMMAND}` - Deployment command (project-specific)

**Status Tracking:**
- `{STATUS}` - Work status (e.g., "IN PROGRESS", "DONE", "BLOCKED")
- `{TICKET_ID}` - Jira ticket ID (e.g., "ML-11516", "GIB-136")
- `{DESCRIPTION}` - Ticket/work description
- `{DATE}` - Current date (YYYY-MM-DD format)
