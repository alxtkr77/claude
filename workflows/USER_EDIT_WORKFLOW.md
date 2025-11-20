# User Edit Workflow

## Pattern: Generate → Edit → Execute

For operations requiring free-form text from the user, follow this workflow:

---

## When to Use This Pattern

Use this workflow for operations that require user-written content:

1. **Git commit messages** - Commit descriptions
2. **PR descriptions** - Pull request body text
3. **Jira updates** - Issue comments, descriptions, status updates
4. **PR/Issue comments** - Responding to reviews or questions
5. **Documentation** - Any text that benefits from user review

---

## Workflow Steps

### Step 1: Generate Draft Text

Create a temporary file with AI-generated content:

```python
# Example: PR comment reply
draft_file = "~/mlrun/temp_reply.txt"
content = """Good point! I've removed the redundant test.

The existing test already covers this functionality.

Thanks for the feedback!"""

Write(file_path=draft_file, content=content)
```

### Step 2: Open in VSCode for User Editing

```bash
code --wait /path/to/temp_file.txt
```

**Key flag**: `--wait` makes Claude wait until the user closes the file.

**User actions**:
- Edit the text as needed
- Save changes (Ctrl+S / Cmd+S)
- Close the file when done (this unblocks Claude)

### Step 3: Read Back Edited Content

```python
# Read the user-edited content
Read(file_path=draft_file)
```

### Step 4: Show Preview & Ask for Approval

Display the final text to the user and ask for confirmation:

```
Here's what will be posted:

---
[Show the edited content]
---

Should I proceed with posting this? (yes/no)
```

### Step 5: Execute Operation

If approved, proceed with the operation:

```python
# Example: Post PR comment
gh api --method POST /repos/mlrun/mlrun/pulls/8947/comments/ID/replies \
  -f body="$(cat /path/to/temp_file.txt)"
```

### Step 6: Cleanup (MANDATORY)

**⚠️ CRITICAL**: Always delete temporary files after successful submission.

```bash
rm /path/to/temp_file.txt
```

**Why this matters:**
- Prevents confusion with stale drafts
- Avoids accidental reuse of old content
- Keeps workspace clean
- Prevents security issues (credentials, sensitive data)

**Verification:**
```bash
# Verify file is deleted
ls /tmp/jira_comment_*.txt  # Should return "No such file"
```

---

## Examples

### Example 1: Commit Message

```bash
# Step 1: Generate
cat > /tmp/commit_msg.txt << 'EOF'
[Model Monitoring] Add start_infer_time to _get_records() output

Include start_infer_time column in metrics and app_results tables output.

Reference: ML-11516
EOF

# Step 2: Edit
code --wait /tmp/commit_msg.txt

# Step 3: Read back (happens automatically when VSCode closes)

# Step 4: Preview & ask
# "Here's the commit message. Proceed? (yes/no)"

# Step 5: Execute
git commit -F /tmp/commit_msg.txt

# Step 6: Cleanup
rm /tmp/commit_msg.txt
```

### Example 2: PR Comment Reply

```bash
# Step 1: Generate
cat > ~/mlrun/pr_comment_reply.txt << 'EOF'
Good point! I've removed the redundant test.

The existing test already covers this.
EOF

# Step 2: Edit
code --wait ~/mlrun/pr_comment_reply.txt

# Step 3: Auto-read (VSCode closed)

# Step 4: Preview
cat ~/mlrun/pr_comment_reply.txt

# Step 5: Execute
gh api POST /repos/mlrun/mlrun/pulls/8947/comments/ID/replies \
  -f body="$(cat ~/mlrun/pr_comment_reply.txt)"

# Step 6: Cleanup
rm ~/mlrun/pr_comment_reply.txt
```

### Example 3: Jira Comment

```bash
# Step 1: Generate (use issue key in filename)
cat > /tmp/jira_comment_ML-11516.txt << 'EOF'
**Status Update**

The fix has been implemented and tested.

**Changes:**
- Added start_infer_time column
- Extended test coverage

**PR Link**: [PR #8947](https://github.com/mlrun/mlrun/pull/8947)
EOF

# Step 2: Edit
code --wait /tmp/jira_comment_ML-11516.txt

# Step 3: Auto-read (happens when VSCode closes)

# Step 4: Preview & confirm
cat /tmp/jira_comment_ML-11516.txt

# Step 5: Execute
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-11516",
    commentBody="$(cat /tmp/jira_comment_ML-11516.txt)"
)

# Step 6: Cleanup (MANDATORY - delete after successful submission)
rm /tmp/jira_comment_ML-11516.txt

# Verify cleanup
ls /tmp/jira_comment_ML-11516.txt  # Should fail with "No such file"
```

---

## Best Practices

### File Naming Conventions

Use descriptive temporary file names:
- `commit_msg.txt` - Commit messages
- `pr_description.txt` - PR descriptions
- `pr_comment_reply.txt` - PR comment responses
- `jira_comment.txt` - Jira comments
- `issue_description.txt` - Issue descriptions

### File Location

Store temporary files in:
1. `/tmp/` - System temp directory (auto-cleaned)
2. `~/mlrun/` - Project root (manual cleanup)

**Prefer `/tmp/`** for automatic cleanup on reboot.

### Content Quality

Generate high-quality drafts:
- Use proper formatting (markdown where supported)
- Include all relevant information
- Follow project conventions
- Reference tickets/PRs appropriately

### User Experience

Make it easy for users to edit:
- Clear, well-formatted content
- Placeholder text for user to fill in (if needed)
- Comments explaining what to edit
- Logical structure

---

## Integration with Other Workflows

### PRE_COMMIT_WORKFLOW.md

Commit message generation:
```bash
# After all checks pass, before git commit
code --wait /tmp/commit_msg.txt
git commit -F /tmp/commit_msg.txt
```

### PR_RESPONSE_GUIDE.md

Responding to PR feedback:
```bash
# Generate reply to reviewer
code --wait /tmp/pr_reply.txt
gh pr comment 8947 --body "$(cat /tmp/pr_reply.txt)"
```

### JIRA_UPDATE_PATTERN.md

Updating Jira tickets:
```bash
# Generate status update
code --wait /tmp/jira_update.txt
# Post to Jira
```

---

## Common Pitfalls

### ❌ Don't: Skip Preview Step

**Wrong:**
```bash
code --wait /tmp/file.txt
git commit -F /tmp/file.txt  # Execute immediately
```

**Right:**
```bash
code --wait /tmp/file.txt
cat /tmp/file.txt  # Show preview
# Ask user: "Proceed? (yes/no)"
git commit -F /tmp/file.txt
```

### ❌ Don't: Forget Cleanup

**Wrong:**
```bash
code --wait /tmp/file.txt
git commit -F /tmp/file.txt
# File left behind
```

**Right:**
```bash
code --wait /tmp/file.txt
git commit -F /tmp/file.txt
rm /tmp/file.txt  # Cleanup
```

### ❌ Don't: Use Ambiguous File Names

**Wrong:**
```bash
code --wait /tmp/temp.txt
```

**Right:**
```bash
code --wait /tmp/commit_msg.txt
```

---

## Why This Pattern Works

**Benefits:**
1. **User Control** - User can edit AI-generated content
2. **Review Step** - User sees exactly what will be posted
3. **Efficiency** - Good first draft saves typing
4. **Consistency** - Follows project conventions
5. **Flexibility** - User can make any changes needed

**User Feedback:**
- Feels like `git commit` editor workflow (familiar)
- Natural editing in preferred editor
- Full control over final content

---

**Last Updated**: 2025-11-20
**Created**: Response to user request for standardized edit workflow
**Related**: PRE_COMMIT_WORKFLOW.md, PR_RESPONSE_GUIDE.md, JIRA_UPDATE_PATTERN.md
