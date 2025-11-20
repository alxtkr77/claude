# Workflow Enforcement Rules

## Overview

This guide defines mandatory workflow enforcement rules that Claude MUST follow for all MLRun development work. These rules ensure consistency, quality, and completeness across all workflows.

**CRITICAL**: These rules have NO EXCEPTIONS. They apply to all commits, PRs, and development tasks.

---

## Rule 1: MANDATORY TodoWrite for ALL Workflows

### Requirement

When ANY workflow is triggered (PRE-COMMIT, PR READINESS, BUG HANDLING, etc.), Claude MUST:

1. **IMMEDIATELY** create TodoWrite list with ALL workflow steps
2. Mark step as "in_progress" BEFORE executing it
3. Mark as "completed" AFTER successful execution
4. NEVER skip steps - if blocked, keep "in_progress" and explain blocker

### Why This Matters

- Provides visible progress tracking
- Prevents skipping steps
- Makes interruptions/resumes seamless
- User can see exactly what's happening

### Example: PRE-COMMIT Workflow

```python
TodoWrite([
    {"content": "Run make fmt", "status": "pending", "activeForm": "Running formatter"},
    {"content": "Run make lint on my changes", "status": "pending", "activeForm": "Running linter"},
    {"content": "Complete self-review checklist", "status": "pending", "activeForm": "Self-reviewing code"},
    {"content": "Run relevant tests", "status": "pending", "activeForm": "Running tests"}
])
```

**Then execute each step:**
```python
# Step 1 starts
TodoWrite([...{"content": "Run make fmt", "status": "in_progress"...}])
# Run make fmt
# Step 1 completes
TodoWrite([...{"content": "Run make fmt", "status": "completed"...}])

# Step 2 starts
TodoWrite([...{"content": "Run make lint on my changes", "status": "in_progress"...}])
# Run make lint
# And so on...
```

### Example: PR READINESS Workflow

```python
TodoWrite([
    {"content": "Run make fmt", "status": "pending", "activeForm": "Running formatter"},
    {"content": "Run make lint", "status": "pending", "activeForm": "Running linter"},
    {"content": "Run all relevant tests", "status": "pending", "activeForm": "Running tests"},
    {"content": "Complete self-review checklist", "status": "pending", "activeForm": "Self-reviewing"},
    {"content": "Commit changes", "status": "pending", "activeForm": "Committing changes"},
    {"content": "Push branch to origin", "status": "pending", "activeForm": "Pushing branch"},
    {"content": "Create pull request", "status": "pending", "activeForm": "Creating PR"},
    {"content": "Update Jira with PR link", "status": "pending", "activeForm": "Updating Jira"}
])
```

### NO EXCEPTIONS

Even for:
- "Quick fixes"
- "Small changes"
- "Just responding to feedback"
- "Tiny commit"

---

## Rule 2: Explicit Verification Checkpoints

### Requirement

Claude MUST show explicit verification checklists at key decision points.

### Before EVERY Commit

```
PRE-COMMIT VERIFICATION:
[X] make fmt: PASSED
[X] make lint: PASSED (checked my changes only)
[X] Self-review: COMPLETED
[X] Tests: X/X PASSED
[X] Ready to commit: YES
```

**If ANY item shows [ ] NO or FAILED, Claude MUST STOP and fix before proceeding.**

### Before Creating PR

```
PR READINESS VERIFICATION:
[X] make fmt: PASSED
[X] make lint: PASSED
[X] Tests: X/X PASSED
[X] Self-review: COMPLETED
[X] Commits: Clean history, proper messages
[X] Branch: Pushed to origin
[X] PR: #XXXX created
[X] Jira: Updated with PR link
[X] All steps complete: YES
```

**If ANY item shows [ ] NO or FAILED, Claude MUST STOP and fix before proceeding.**

### Why This Matters

- Makes decision criteria explicit
- Prevents premature commits/PRs
- Clear go/no-go signal
- Easy for user to verify

### Format Requirements

- Use exact format shown above
- Include actual pass/fail status
- Show test counts (e.g., "5/5 PASSED")
- Use checkmarks [X] or empty [ ]
- Always include "Ready to [action]: YES/NO" line

---

## Rule 3: Workflow Auto-Detection (ALWAYS Check First)

### Requirement

**BEFORE responding to ANY user request**, Claude MUST check if high-priority workflow triggers are present.

### Priority Order

1. **PRE-COMMIT** (highest priority)
2. **PR READINESS**
3. **START WORK** (new ticket/feature)
4. **BUG HANDLING**
5. **Other workflows**

### PRE-COMMIT Detection

**User says ANY of these:**
- "commit" / "git commit" / "ready to commit" / "let's commit"
- "amend" / "git commit --amend"
- About to run: `git commit` command
- Just finished: making code changes

**ACTION**:
1. Read `~/claude/PRE_COMMIT_WORKFLOW.md`
2. Create TodoWrite with all PRE-COMMIT steps
3. Execute steps in order
4. Show verification checklist

### PR READINESS Detection

**User says ANY of these:**
- "create pr" / "make pr" / "open pr" / "new pr"
- "pull request" / "ready for pr" / "submit pr"
- "pr" (as standalone command)

**ACTION**:
1. Read `~/claude/PR_READINESS_CHECKLIST.md`
2. Create TodoWrite with all 8 PR steps
3. Execute steps systematically
4. Show verification checklist

### BUG HANDLING Detection

**User says ANY of these:**
- "fix bug" / "bug fix" / "fix issue"
- "debug" / "investigate bug" / "handle bug"
- Provides bug ticket number (e.g., "ML-XXXXX is a bug")

**ACTION**:
1. Read `~/claude/BUG_HANDLING_WORKFLOW.md`
2. Follow triage → analysis → fix → PR → Jira workflow

### START WORK Detection

**User says ANY of these:**
- "starting to work on" / "work on case" / "work on ML-"
- "implement ML-" / "start ML-" / "working on ticket"
- Mentions Jira ticket for new feature/task (not bug)

**ACTION**:
1. Get Jira issue details (understand requirements)
2. Create feature branch: `git checkout -b ML-XXXXX-short-description upstream/development`
3. Transition Jira to "In Progress"
4. THEN start implementation

**CRITICAL**: Do NOT start coding before branch is created and Jira is updated

### Context Clues (Auto-detect workflow needed)

**Scenario: Uncommitted changes + commit mention**
- Git status shows modified files
- User says "commit" or related word
→ **Trigger PRE-COMMIT workflow**

**Scenario: Branch pushed but no PR**
- Current branch is pushed to origin
- User says "done" or "ready"
→ **Ask if they want to create PR, then trigger PR READINESS**

**Scenario: PR exists but Jira not updated**
- PR has been created
- Jira ticket mentioned but no PR link
→ **Complete Jira update step**

### Why This Matters

- Catches workflows before they're forgotten
- Proactive enforcement
- User doesn't have to remember trigger words
- Prevents incomplete workflows

---

## Rule 4: Workflow Completion Criteria

### When is a Workflow Complete?

A workflow is NOT complete until ALL of these are true:

1. ✅ **TodoWrite shows ALL steps completed**
   - Every step status is "completed"
   - No steps remain "pending" or "in_progress"

2. ✅ **Verification checklist shows ALL checkmarks**
   - Every item marked [X]
   - "Ready to [action]: YES" line present

3. ✅ **Claude explicitly states**: "Workflow complete: [WORKFLOW_NAME]"
   - Clear termination message
   - User knows work is done

### Example Completion Message

```
Workflow complete: PRE-COMMIT

All steps verified:
- make fmt: PASSED
- make lint: PASSED
- Self-review: COMPLETED
- Tests: 8/8 PASSED

Ready to commit!
```

### Handling Interruptions

**If session ends or error occurs:**

1. **On resume**: Check TodoWrite for incomplete workflows
2. **Identify**: Find last completed step
3. **Continue**: Resume from next incomplete step
4. **Never restart**: Don't redo completed steps

**Example Resume:**

```
Resuming PRE-COMMIT workflow:
- [X] make fmt: COMPLETED (previous session)
- [X] make lint: COMPLETED (previous session)
- [ ] Self-review: PENDING (resume here)
- [ ] Tests: PENDING

Continuing from self-review step...
```

### Why This Matters

- Clear completion signal
- Prevents abandoning partial workflows
- Seamless session interruption handling
- No repeated work

---

## Common Workflow Patterns

### Pattern: User Makes Code Changes

1. User edits files
2. User says "commit" or similar
3. Claude detects PRE-COMMIT trigger
4. Claude creates TodoWrite with PRE-COMMIT steps
5. Claude runs fmt → lint → self-review → tests
6. Claude shows verification checklist
7. Claude commits only if all checks pass
8. Claude states "Workflow complete: PRE-COMMIT"

### Pattern: User Wants to Create PR

1. User says "create pr" or similar
2. Claude detects PR READINESS trigger
3. Claude creates TodoWrite with all 8 steps
4. Claude runs each step systematically
5. Claude shows verification checklist after each major step
6. Claude creates PR only if all steps pass
7. Claude updates Jira with PR link
8. Claude states "Workflow complete: PR READINESS"

### Pattern: Session Interrupted During Workflow

1. Workflow starts, some steps complete
2. Session ends (network, timeout, etc.)
3. New session starts
4. Claude checks TodoWrite
5. Claude finds incomplete workflow
6. Claude resumes from last incomplete step
7. Claude completes remaining steps
8. Claude states "Workflow complete: [NAME]"

---

## Enforcement Checklist for Claude

Before responding to user, check:

- [ ] Did user say "commit", "pr", "bug", "starting to work on", or other trigger?
- [ ] Did user mention a Jira ticket (ML-XXXXX) for new work?
- [ ] Are there uncommitted changes + commit mention?
- [ ] Is there an incomplete workflow in TodoWrite?
- [ ] Should I create TodoWrite for new workflow?
- [ ] Should I show verification checklist?

If ANY answer is YES, take appropriate workflow action BEFORE responding to user request.

---

## Workflow Architecture

### Hierarchical Structure

The Claude workflows are organized in a **3-tier hierarchy** for maintainability and reusability:

```
TIER 1: BASE PATTERNS (Atomic, reusable)
├── QUALITY_CHECKS.md              # fmt → lint → test pattern
├── COMMIT_MESSAGE_FORMAT.md       # Standard commit format
├── BASE_CODE_QUALITY_CHECKLIST.md # Quality standards
├── JIRA_UPDATE_PATTERN.md         # Jira operations
└── PR_TEMPLATE.txt                # PR description template

TIER 2: CORE WORKFLOWS (Frequently used)
├── PRE_COMMIT_WORKFLOW.md         # Uses: QUALITY_CHECKS, COMMIT_MESSAGE_FORMAT
├── GIT_WORKFLOW.md                # Uses: COMMIT_MESSAGE_FORMAT
└── SELF_REVIEW_CHECKLIST.md       # Uses: BASE_CODE_QUALITY_CHECKLIST, QUALITY_CHECKS

TIER 3: COMPOSITE WORKFLOWS (Complex, orchestrate multiple workflows)
├── PR_READINESS_CHECKLIST.md
│   ├── Uses: PRE_COMMIT_WORKFLOW
│   ├── Uses: SELF_REVIEW_CHECKLIST
│   ├── Uses: PR_TEMPLATE
│   └── Uses: JIRA_UPDATE_PATTERN
│
├── BUG_HANDLING_WORKFLOW.md
│   ├── Uses: PRE_COMMIT_WORKFLOW
│   ├── Uses: PR_SUBMISSION_WORKFLOW
│   └── Uses: JIRA_UPDATE_PATTERN
│
└── PR_SUBMISSION_WORKFLOW.md
    ├── Uses: QUALITY_CHECKS, GIT_WORKFLOW
    ├── Uses: COMMIT_MESSAGE_FORMAT
    ├── Uses: PR_TEMPLATE
    └── Uses: JIRA_UPDATE_PATTERN

SUPPORTING GUIDES (Reference documentation)
├── CODE_REVIEW_GUIDE.md           # Uses: BASE_CODE_QUALITY_CHECKLIST
├── PR_RESPONSE_GUIDE.md           # Standalone guide
├── TESTING_STANDARDS.md           # Referenced by quality checks
├── CODING_STANDARDS.md            # Referenced by quality checks
└── ARCHITECTURE_GUIDE.md          # Referenced by reviews
```

### Design Principles

1. **Single Source of Truth**: Each pattern/format defined once, referenced everywhere
2. **Composability**: Higher-tier workflows reference lower-tier ones
3. **DRY (Don't Repeat Yourself)**: No duplication of content across files
4. **Clear Dependencies**: Each workflow explicitly references what it uses
5. **Independent Usage**: Base patterns can be used standalone or composed

### Benefits of This Architecture

**Maintainability:**
- Change once, affects all workflows automatically
- Clear dependencies make refactoring safer
- Easier to update standards across all workflows

**Consistency:**
- Everyone uses same base patterns
- No divergence between similar workflows
- Single source of truth prevents conflicts

**Usability:**
- Clear hierarchy makes workflows easy to find
- Can use base patterns directly for quick reference
- Composite workflows provide complete guidance

**Size Reduction:**
- **27% smaller** overall (758 lines removed)
- **Core workflows 40-70% smaller** through references
- Less reading, more doing

### How to Use This Architecture

**When starting work:**
1. Check if a TIER 3 workflow applies (PR_READINESS, BUG_HANDLING, etc.)
2. Follow that workflow - it will reference lower tiers automatically
3. If no composite workflow fits, use TIER 2 workflows directly
4. For quick reference, use TIER 1 patterns directly

**When updating workflows:**
1. Update TIER 1 base patterns first (affects everyone)
2. Update TIER 2 core workflows next
3. Update TIER 3 composite workflows last
4. Test that all references still work

**When adding new workflows:**
1. Check if base patterns can be reused
2. Reference existing workflows instead of duplicating
3. Add to appropriate tier based on complexity
4. Update this architecture diagram

---

**Last Updated**: 2025-11-20
**Major Refactor**: Added 3-tier hierarchical architecture with composable workflows

