# PR Readiness Checklist

## 🚨 WHEN USER SAYS "READY FOR PR" - RUN THIS CHECKLIST FIRST

This is a **mandatory pre-flight checklist** to run before creating any PR. Never skip these steps.

---

## Steps 1-4: Pre-Commit Workflow

👉 **Run `PRE_COMMIT_WORKFLOW.md`** (mandatory before every commit)

This covers:
1. Format code (`make fmt`)
2. Check linting (`make lint`)
3. Run relevant tests
4. Quick self-review

**Verify all checks pass** before proceeding.

**Reference**: `~/claude/PRE_COMMIT_WORKFLOW.md`

---

## Step 5: Documentation Verification

### Check if Documentation Needs Updates

```bash
# Search for references to changed APIs
grep -r "old_api_name" docs/ --include="*.md"
grep -r "old_parameter" docs/ --include="*.md"

# Check example notebooks
grep -r "old_api_name" examples/ --include="*.ipynb"
```

**Checklist:**
- [ ] Docstrings updated for changed functions
- [ ] Documentation files updated (if public API changed)
- [ ] Examples updated (if applicable)
- [ ] README updated (if adding features)

---

## Step 6: Complete Self-Review

👉 **Run `SELF_REVIEW_CHECKLIST.md`** for thorough review

OR at minimum, run `BASE_CODE_QUALITY_CHECKLIST.md`:
- Code quality checks
- Test quality checks
- Security review
- Performance review
- Architecture review

**Reference**: `~/claude/SELF_REVIEW_CHECKLIST.md` or `~/claude/BASE_CODE_QUALITY_CHECKLIST.md`

---

## Step 7: Stage All Changes

```bash
git status
```

**Verify:**
- [ ] All intended changes are staged
- [ ] No unintended files are included
- [ ] Formatting changes from `make fmt` are staged

**Stage everything:**
```bash
git add <modified-files>
# Or if confident:
git add -A
```

---

## Step 8: Commit with Proper Message

👉 **Format**: `COMMIT_MESSAGE_FORMAT.md`

**Quick reminder:**
```bash
git commit -m "[Component] Brief description

Detailed explanation of what and why.
- Key change 1
- Key change 2

Reference: ML-XXXXX"
```

**Requirements:**
- [ ] Starts with [Component] scope
- [ ] Imperative mood ("Add feature" not "Added feature")
- [ ] References Jira ticket
- [ ] Clear and concise

**Reference**: `~/claude/COMMIT_MESSAGE_FORMAT.md`

---

## Step 9: Push to Fork/Branch

```bash
# First time:
git push -u origin ML-XXXXX-branch-name

# Subsequent pushes:
git push origin ML-XXXXX-branch-name
```

---

## Step 10: Create PR

👉 **MANDATORY**: Use USER_EDIT_WORKFLOW pattern for PR title and description
👉 **Follow `PR_SUBMISSION_WORKFLOW.md`** for detailed PR creation

**Steps:**

1. **Generate PR title and description draft** to temporary file:
   ```bash
   # Use mktemp (NOT hardcoded paths), use Bash heredoc (NOT Write tool)
   TMPFILE=$(mktemp --suffix=_pr_description.txt)
   cat > "$TMPFILE" << 'EOF'
   TITLE: [Component] Brief description

   ## Summary
   What was changed and why

   ## Changes Made
   - Change 1
   - Change 2

   ## Testing
   What tests were run

   ## Reference
   - Jira: TICKET-XXX
   EOF
   echo "$TMPFILE"
   ```

2. **Open in VSCode for user editing** (MANDATORY):
   ```bash
   # Handle stale socket: use backticks to find latest socket
   VSCODE_IPC_HOOK_CLI=`ls -t /run/user/1000/vscode-ipc-*.sock | head -1` code --wait "$TMPFILE"
   ```

3. **Show preview and ask for approval**:
   ```bash
   cat /tmp/pr_description.txt
   ```
   Ask: "Should I proceed with creating this PR? (yes/no)"

4. **Create PR with reviewed content**:
   ```bash
   # Extract title and body
   TITLE=$(head -n1 /tmp/pr_description.txt | sed 's/^TITLE: //')
   BODY=$(tail -n +3 /tmp/pr_description.txt)

   # For fork workflow:
   gh pr create \
     --repo mlrun/mlrun \
     --base development \
     --head username:BRANCH-NAME \
     --title "$TITLE" \
     --body "$BODY"

   # For direct repo access:
   gh pr create \
     --base development \
     --title "$TITLE" \
     --body "$BODY"
   ```

5. **Cleanup** (MANDATORY):
   ```bash
   rm /tmp/pr_description.txt
   ```

**Required PR sections:**
- ✅ 📝 Description (what and why)
- ✅ 🛠️ Changes Made (bullet list)
- ✅ ✅ Checklist (mark completed items)
- ✅ 🧪 Testing (what tests were run)
- ✅ 🔗 References (Jira ticket link)
- ✅ 🚨 Breaking Changes (Yes/No, explain if yes)

**Reference**: `~/claude/PR_SUBMISSION_WORKFLOW.md`, `~/claude/PR_TEMPLATE.txt`

---

## Step 11: Update Jira

👉 **MANDATORY**: Use USER_EDIT_WORKFLOW pattern for Jira comments
👉 **Follow `JIRA_UPDATE_PATTERN.md`** for Jira operations

**Steps:**

1. **Generate Jira comment draft** to temporary file:
   ```bash
   # Use mktemp (NOT hardcoded paths), use Bash heredoc (NOT Write tool)
   TMPFILE=$(mktemp --suffix=_jira_comment.txt)
   cat > "$TMPFILE" << 'EOF'
   **PR Link**: [PR #YYYY](https://github.com/mlrun/mlrun/pull/YYYY)

   Summary of changes:
   - Change 1
   - Change 2
   EOF
   echo "$TMPFILE"
   ```

2. **Open in VSCode for user editing** (MANDATORY):
   ```bash
   # Handle stale socket: use backticks to find latest socket
   VSCODE_IPC_HOOK_CLI=`ls -t /run/user/1000/vscode-ipc-*.sock | head -1` code --wait "$TMPFILE"
   ```

3. **Show preview and ask for approval**:
   ```bash
   cat /tmp/jira_comment.txt
   ```
   Ask: "Should I proceed with posting this to Jira? (yes/no)"

4. **Post comment with reviewed content**:
   ```python
   # Use site URL format (recommended - no permission issues)
   mcp__atlassian__addCommentToJiraIssue(
       cloudId="https://yoursite.atlassian.net",
       issueIdOrKey="TICKET-XXX",
       commentBody="<content from /tmp/jira_comment.txt>"
   )
   ```

5. **Cleanup** (MANDATORY):
   ```bash
   rm /tmp/jira_comment.txt
   ```

**Note on cloudId**: Use site URL format (e.g., `https://iguazio.atlassian.net`) instead of UUID cloud ID to avoid permission issues.

**Reference**: `~/claude/JIRA_UPDATE_PATTERN.md`

---

## Common Mistakes to Avoid

### ❌ Forgetting `make fmt`
- **Problem:** CI fails with "Would reformat: file.py"
- **Prevention:** Always run `make fmt` and commit ALL formatting changes

### ❌ Not staging formatting changes
- **Problem:** Formatter made changes but they weren't committed
- **Prevention:** Run `git status` after `make fmt` and stage everything

### ❌ Skipping lint check
- **Problem:** CI fails on unused imports or other issues
- **Prevention:** Always run `make lint` and fix all issues

### ❌ Not running tests
- **Problem:** PR breaks existing functionality
- **Prevention:** Run relevant test suite before creating PR

### ❌ Empty sections in PR description
- **Problem:** PR looks incomplete or sloppy
- **Prevention:** Remove sections that don't apply, don't leave empty

### ❌ No Jira reference
- **Problem:** Can't track work or link to requirements
- **Prevention:** Always include "Reference: ML-XXXXX" in PR description

### ❌ Forgetting to push after fixes
- **Problem:** CI still fails because fixes aren't pushed
- **Prevention:** After any fix: git add → git commit (or --amend) → git push

---

## Quick Command Summary

```bash
# Complete pre-PR workflow (reference guide):

# 1-4: PRE_COMMIT_WORKFLOW.md
make fmt && git add -A && make lint && pytest <tests> -v

# 5: Documentation check
grep -r "api_name" docs/ --include="*.md"

# 6: Self-review
# (Manual checklist - see SELF_REVIEW_CHECKLIST.md)

# 7-8: Stage and commit
git status && git add -A
git commit -m "[Component] Description

Reference: ML-XXXXX"

# 9: Push
git push -u origin ML-XXXXX-branch

# 10: Create PR (see PR_SUBMISSION_WORKFLOW.md)
gh pr create --repo mlrun/mlrun --base development --head user:branch --title "..." --body "..."

# 11: Update Jira (see JIRA_UPDATE_PATTERN.md)
```

---

## Final Verification Before Saying "PR is Ready"

- [ ] PRE_COMMIT_WORKFLOW.md completed
- [ ] Documentation verified/updated
- [ ] SELF_REVIEW_CHECKLIST.md completed
- [ ] All changes staged and committed
- [ ] Branch pushed to origin
- [ ] PR created with complete description
- [ ] Jira updated with PR link
- [ ] CI is green (after PR creation)

---

## When CI Fails After PR Creation

**Check the error and fix locally:**

```bash
# If formatting failed:
make fmt && git add -A && git commit --amend --no-edit && git push -f

# If linting failed:
make lint && python -m ruff check --fix && git add -A && git commit --amend --no-edit && git push -f

# If tests failed:
pytest <failing-test> -v
# Fix the issue
git add <fixed-files> && git commit -m "[Tests] Fix failing test" && git push
```

---

## Integration with Other Workflows

This checklist orchestrates multiple workflows:
- **PRE_COMMIT_WORKFLOW.md** (steps 1-4)
- **SELF_REVIEW_CHECKLIST.md** (step 6)
- **PR_SUBMISSION_WORKFLOW.md** (step 10 - detailed guide)
- **JIRA_UPDATE_PATTERN.md** (step 11)

Each workflow is independently documented for reusability.

---

**Remember:** This checklist exists because it's easy to forget steps. Run it EVERY TIME the user says "ready for PR" or "I want to create a PR".

**Last Updated**: 2025-11-20
**Refactored**: Now references base workflows instead of duplicating content
**Size Reduction**: 287 lines → 100 lines core content (65% reduction)
