# Jira Update Pattern

## Overview

Standard pattern for updating Jira tickets throughout the development workflow. This is the single source of truth for Jira operations in MLRun workflows.

**Cloud ID**: `1374a6f1-f268-4a06-909e-b3a9675a9bd1` (jira.iguazeng.com)

---

## When to Update Jira

### 1. Start Work
**When**: Beginning work on a ticket
**Action**: Transition to "In Progress"

### 2. Create PR
**When**: PR created and ready for review
**Action**: Add PR link comment

### 3. After Merge
**When**: PR merged to development
**Action**: Add merge details comment

### 4. Close Ticket
**When**: Work complete and verified
**Action**: Add final verification comment and close

---

## Standard Operations

### Get Cloud ID

```python
# Usually not needed (use hardcoded value), but if required:
mcp__atlassian__getAccessibleAtlassianResources()
```

**Result**: Cloud ID is `1374a6f1-f268-4a06-909e-b3a9675a9bd1`

---

### Transition Ticket to "In Progress"

```python
# When starting work on a ticket
mcp__atlassian__transitionJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    transition={"id": "741"}  # "Start Work" → "In Progress"
)
```

**Common transition IDs:**
- `"741"` - Start Work (To Do → In Progress)
- `"751"` - Resolve (In Progress → Done)
- `"761"` - Close (Done → Closed)

---

### Add PR Link Comment

**⚠️ CRITICAL**: Use markdown format `[text](url)` for clickable hyperlinks in Jira.

👉 **For comment text**: Use `USER_EDIT_WORKFLOW.md` pattern (generate → edit in VSCode → post)

```python
# When PR is created
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="**PR Link**: [PR #YYYY](https://github.com/mlrun/mlrun/pull/YYYY)\n\n<brief summary of changes>"
)
```

**Comment format:**
```markdown
**PR Link**: [PR #1234](https://github.com/mlrun/mlrun/pull/1234)

[Brief summary]:
- Added X functionality
- Fixed Y issue
- Updated Z documentation

Ready for review.
```

---

### Add Investigation Update (Bug Handling)

```python
# During bug investigation
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**Investigation Update:**

Reproduced the issue locally. Root cause identified:

- **File**: mlrun/path/to/file.py, line 245
- **Issue**: [description of root cause]
- **Introduced in**: Commit abc123 (PR #1234)

**Next Steps:**
- [planned fix approach]
- Target fix in next [timeframe]
"""
)
```

---

### Add Merge Notification

```python
# After PR is merged
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**Merged to development**

**PR**: [PR #1234](https://github.com/mlrun/mlrun/pull/1234)
**Commit**: abc123

Changes:
- [key change 1]
- [key change 2]

Will be included in next release.
"""
)
```

---

### Add Final Verification and Close

```python
# Final comment before closing
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**Resolved and Verified**

**Included in**: v1.7.0 (or next release)
**Commit**: abc123

**Verification:**
- [verification step 1]: ✅ Passed
- [verification step 2]: ✅ Passed
- [verification step 3]: ✅ Passed

Closing ticket as resolved.
"""
)

# Then transition to resolved/closed
mcp__atlassian__transitionJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    transition={"id": "751"}  # Resolve
)
```

---

## Workflow-Specific Patterns

### PR Creation Workflow

**Used in**: PR_READINESS_CHECKLIST.md, PR_SUBMISSION_WORKFLOW.md

```python
# Step 1: Add PR link
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="**PR Link**: [PR #YYYY](https://github.com/mlrun/mlrun/pull/YYYY)\n\nFix implemented and submitted for review."
)

# Step 2: Transition to In Progress (if not already)
mcp__atlassian__transitionJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    transition={"id": "741"}
)
```

---

### Bug Handling Workflow

**Used in**: BUG_HANDLING_WORKFLOW.md

```python
# During investigation
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**Investigation Update:**

Reproduced the issue locally. Root cause identified:
- **File**: mlrun/api/crud/endpoints.py, line 245
- **Issue**: Missing validation for empty endpoint_id
- **Introduced in**: Commit abc123 (PR #1234)

**Next Steps:**
- Add validation for empty endpoint_id
- Add None check after database query
- Add tests for both cases
- Target fix in next 2 days
"""
)

# After fix is merged
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**Fixed in [PR #1234](https://github.com/mlrun/mlrun/pull/1234)**

**Changes:**
- Added validation for empty endpoint_id
- Added None check after database query
- Added comprehensive tests

**Verification:**
1. Test case for empty endpoint_id: ✅ Passes
2. Test case for nonexistent endpoint: ✅ Passes
3. Full test suite: ✅ Passes

Waiting for code review. Will update when merged.
"""
)
```

---

## Comment Formatting Guidelines

### Use Markdown

**Hyperlinks** (CRITICAL):
```markdown
# ✅ CORRECT - Clickable link in Jira
[PR #1234](https://github.com/mlrun/mlrun/pull/1234)

# ❌ WRONG - Not clickable
https://github.com/mlrun/mlrun/pull/1234
PR #1234: https://github.com/mlrun/mlrun/pull/1234
```

**Formatting**:
```markdown
**Bold text**: For headers, emphasis
- Bullet lists: For organized info
✅ ❌ Checkmarks: For status (use sparingly in Jira)
`code`: For file names, commands
```

**Structure**:
```markdown
**Section Header:**

Paragraph of explanation.

- Bullet point 1
- Bullet point 2

**Next Section:**
...
```

---

## Error Handling

### If Jira Update Fails

**Common issues:**
1. **Invalid cloudId**: Use `1374a6f1-f268-4a06-909e-b3a9675a9bd1`
2. **Invalid transition ID**: Check available transitions first
3. **Insufficient permissions**: May need different credentials
4. **Invalid issue key**: Verify ML-XXXXX format

**Check available transitions:**
```python
mcp__atlassian__getTransitionsForJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX"
)
```

---

## Quick Reference

### PR Creation
```python
# Add PR link with markdown format
commentBody="**PR Link**: [PR #YYYY](https://github.com/mlrun/mlrun/pull/YYYY)\n\n<summary>"
```

### Bug Investigation
```python
# Structured investigation update
commentBody="**Investigation Update:**\n\nRoot cause: ...\n\n**Next Steps:**\n- ..."
```

### After Merge
```python
# Merge notification
commentBody="**Merged to development**\n\n**PR**: [PR #YYYY](...)\n**Commit**: abc123"
```

### Close Ticket
```python
# Final verification + transition
commentBody="**Resolved and Verified**\n\n**Included in**: v1.7.0\n..."
transition={"id": "751"}
```

---

## Referenced By

- PR_READINESS_CHECKLIST.md (Step 10)
- PR_SUBMISSION_WORKFLOW.md (Step 4)
- BUG_HANDLING_WORKFLOW.md (Steps 3, 5, 6)
- JIRA_ISSUE_CREATION_GUIDE.md (detailed operations guide)

---

**Last Updated**: 2025-11-20
**Purpose**: Single source of truth for Jira update operations
**Cloud ID**: 1374a6f1-f268-4a06-909e-b3a9675a9bd1
