# Jira Workflow for MLRun Project

## CRITICAL: User Confirmation Required
**ALL Atlassian write operations REQUIRE explicit user confirmation before execution:**
- Adding comments to issues
- Creating new issues
- Transitioning issue status
- Any other modification

**Workflow for comments:**
1. Generate draft to `/tmp/jira_comment.txt`
2. Open with `code --wait /tmp/jira_comment.txt` for user editing
3. Show preview and ASK: "Should I proceed with posting this to Jira? (yes/no)"
4. Only execute after explicit "yes" from user

---

## Overview
Guide for creating and managing Jira issues in the MLRun project using the Atlassian MCP integration.

## Authentication Setup
The Atlassian MCP server is already configured with OAuth2 authentication. No additional setup required.

## Getting Cloud ID

**Recommended Approach**: Use site URL format (e.g., `https://yoursite.atlassian.net`) instead of UUID cloud ID to avoid permission issues.

```bash
# If you need the UUID cloud ID:
# Use the getAccessibleAtlassianResources tool
# Returns: cloudId for jira.iguazeng.com

# But prefer using site URL format directly:
cloudId="https://yoursite.atlassian.net"
```

## Creating Bug Issues

### Required Fields for Bug Issues in MLRun Project

When creating a Bug issue type in the ML (MLRun) project, the following fields are **required**:

1. **Project**: ML (MLRun)
2. **Issue Type**: Bug
3. **Summary**: Brief description of the bug
4. **Component**: Must specify at least one component
5. **Affects Version/s**: Which version(s) are affected
6. **Severity** (customfield_10037): Bug severity level
7. **Regression** (customfield_10039): When the regression occurred

### Component IDs

Common components in MLRun project:
- **Platform:Backend**: `10128` (most common for backend bugs)
- **Platform:UI**: For UI-related bugs
- **Platform:API**: For API-related bugs

To find component IDs, examine existing bugs in the project.

### Version IDs

Common version IDs:
- **1.11.0**: `10815` (current development version)
- **1.9.0**: `10815` (stable version)

Use `1.11.0` for bugs found in development/unstable branch.

### Severity IDs (customfield_10037)

- **S1 - Blocker**: `10024`
- **S2 - High**: `10025`
- **S3 - Medium**: `10027` (most common)
- **S4 - Low**: `10028`

**Guidance**:
- S1: System down, no workaround
- S2: Major functionality broken, difficult workaround
- S3: Moderate impact, workaround available (default choice)
- S4: Minor issue, cosmetic

### Regression IDs (customfield_10039)

- **New**: `10031` (feature never worked)
- **Between-Releases**: `10033` (most common - bug introduced between releases)
- **Within-Release**: `10034` (regression within same release)

**Guidance**:
- Use "Between-Releases" (`10033`) as default when unsure
- Use "New" if it's a bug in brand new feature

## Example: Creating a Bug Issue

```python
# Get cloud ID first
mcp__atlassian__getAccessibleAtlassianResources()

# Create bug issue
mcp__atlassian__createJiraIssue(
    cloudId="your-cloud-id",
    projectKey="ML",
    issueTypeName="Bug",
    summary="Fix AttributeError in patch_remote.py when overwrite_registry is None",
    description="""## Description
The `patch_remote.py` script crashes with AttributeError when `overwrite_registry` is None.

## Location
`automation/patch_igz/patch_remote.py:636`

## Current Code
```python
if overwrite_registry.endswith("/"):
    overwrite_registry = overwrite_registry[:-1]
```

## Issue
Missing None check causes AttributeError when overwrite_registry is None.

## Fix
```python
if overwrite_registry and overwrite_registry.endswith("/"):
    overwrite_registry = overwrite_registry[:-1]
```
""",
    additional_fields={
        "components": [{"id": "10128"}],           # Platform:Backend
        "versions": [{"id": "10815"}],             # 1.11.0
        "customfield_10037": {"id": "10027"},      # Severity: S3
        "customfield_10039": {"id": "10033"}       # Regression: Between-Releases
    }
)
```

## Finding Field Values

### Method 1: Examine Existing Bugs
Search for similar bugs and examine their field values:

```bash
# Search for recent bugs
mcp__atlassian__searchJiraIssuesUsingJql(
    cloudId="your-cloud-id",
    jql="project = ML AND type = Bug ORDER BY created DESC",
    maxResults=5
)
```

### Method 2: Get Issue Type Metadata
```bash
# Get metadata for Bug issue type
mcp__atlassian__getJiraIssueTypeMetaWithFields(
    cloudId="your-cloud-id",
    projectIdOrKey="ML",
    issueTypeId="1"  # Bug issue type ID
)
```

## Updating Jira Issues After PR Creation

### Adding PR Link to Jira Issue

👉 **MANDATORY**: Use USER_EDIT_WORKFLOW pattern for Jira comments

After creating a PR, you should:

1. **Add comment with PR link** (user-edited)
2. **Transition issue to "In Progress"**

**Steps:**

1. **Generate Jira comment draft** to temporary file:
   ```bash
   cat > /tmp/jira_comment.txt << 'EOF'
   **PR Link**: [PR #8905](https://github.com/mlrun/mlrun/pull/8905)

   Fix implemented and submitted for review.

   Summary of changes:
   - Change 1
   - Change 2
   EOF
   ```

2. **Open in VSCode for user editing** (MANDATORY):
   ```bash
   code --wait /tmp/jira_comment.txt
   ```

3. **Show preview and ask for approval**:
   ```bash
   cat /tmp/jira_comment.txt
   ```
   Ask: "Should I proceed with posting this to Jira? (yes/no)"

4. **Post comment with reviewed content**:
   ```python
   # ✅ CORRECT - Use site URL format (recommended - no permission issues)
   mcp__atlassian__addCommentToJiraIssue(
       cloudId="https://yoursite.atlassian.net",
       issueIdOrKey="ML-11462",
       commentBody="<content from /tmp/jira_comment.txt>"
   )

   # ❌ WRONG - Plain URL shows as plain text, not clickable
   commentBody="**PR Created**: https://github.com/mlrun/mlrun/pull/8905"
   ```

5. **Cleanup** (MANDATORY):
   ```bash
   rm /tmp/jira_comment.txt
   ```

**Important Notes**:
- Use **markdown format** `[Link Text](URL)` for clickable hyperlinks in Jira
- Use **site URL format** for cloudId to avoid permission issues

### Transitioning Issue Status

```python
# 1. Get available transitions
transitions = mcp__atlassian__getTransitionsForJiraIssue(
    cloudId="your-cloud-id",
    issueIdOrKey="ML-11462"
)

# 2. Find "In Progress" transition (usually id "741" for "Start Work")
# Look for: name="Start Work", to.name="In Progress"

# 3. Transition the issue
mcp__atlassian__transitionJiraIssue(
    cloudId="your-cloud-id",
    issueIdOrKey="ML-11462",
    transition={"id": "741"}  # "Start Work" transition
)
```

### Complete Workflow Example

After creating PR #8905, follow USER_EDIT_WORKFLOW pattern:

```bash
# 1. Generate comment draft
cat > /tmp/jira_comment.txt << 'EOF'
**PR Link**: [PR #8905](https://github.com/mlrun/mlrun/pull/8905)

Fix implemented and submitted for review.
EOF

# 2. Open for user editing
code --wait /tmp/jira_comment.txt

# 3. Show preview
cat /tmp/jira_comment.txt

# 4. Get approval from user
# Ask: "Should I proceed with posting this to Jira? (yes/no)"

# 5. Post comment (after user approval)
mcp__atlassian__addCommentToJiraIssue(
    cloudId="https://yoursite.atlassian.net",
    issueIdOrKey="ML-11462",
    commentBody="<content from /tmp/jira_comment.txt>"
)

# 6. Cleanup
rm /tmp/jira_comment.txt

# 7. Move to "In Progress" (if needed)
mcp__atlassian__transitionJiraIssue(
    cloudId="https://yoursite.atlassian.net",
    issueIdOrKey="ML-11462",
    transition={"id": "741"}
)
```

## Common Pitfalls

1. **Missing Required Fields**: Always include components, versions, severity, and regression
2. **Wrong Field Format**: Use `{"id": "value"}` format for custom fields
3. **Invalid Component ID**: Verify component IDs by examining existing bugs
4. **Wrong Version**: Use appropriate version based on where bug was found
5. **Plain URL in Comments**: Use markdown format `[text](url)` for clickable links, not plain URLs

## Workflow Integration

### When Creating Bug from Investigation

1. **Identify the bug** clearly with location and reproduction steps
2. **Determine severity**:
   - Does it crash the system? → S1 or S2
   - Is there a workaround? → S3 (most common)
   - Is it cosmetic? → S4

3. **Determine regression type**:
   - Existing feature broke? → Between-Releases
   - New feature never worked? → New

4. **Select appropriate component**:
   - Backend code? → Platform:Backend
   - API endpoints? → Platform:API
   - UI issues? → Platform:UI

5. **Choose affected version**:
   - Found in development/unstable? → 1.11.0
   - Found in production? → Latest stable version

6. **Create Jira issue** with all required fields

7. **Reference in PR**: Include `**Reference**: ML-XXXXX` in PR description

## Quick Reference

**Most Common Bug Configuration** (for backend bugs found during development):
- Component: Platform:Backend (`10128`)
- Version: 1.11.0 (`10815`)
- Severity: S3 - Medium (`10027`)
- Regression: Between-Releases (`10033`)

## Examples from Recent Work

### ML-11462: patch_remote.py AttributeError
- **Type**: Bug
- **Component**: Platform:Backend
- **Version**: 1.11.0
- **Severity**: S3 (has workaround - check before calling)
- **Regression**: Between-Releases (existing code, recently discovered)
- **PR**: #8905
- **Status**: In Progress

### ML-11455: Model Monitoring Investigation
- **Type**: Case (parent issue for investigation)
- **Child Issues**: Two bugs discovered during investigation
  - Controller deadlock (PR #8902)
  - Query filter bug (PR #8903)

## Related Documentation
- `~/claude/PR_SUBMISSION_WORKFLOW.md` - PR creation process requiring Jira case references
