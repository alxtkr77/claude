# PR Submission Workflow

## ⚠️ WHEN USER SAYS "READY FOR PR"

**STOP and run this checklist FIRST:**
👉 **See: `~/claude/PR_READINESS_CHECKLIST.md`**

This mandatory checklist ensures you:
1. Run `make fmt` and `make lint`
2. Run relevant tests
3. Do self-review
4. Commit properly
5. Create PR with correct format
6. Update Jira

**Never skip these steps.** Use the checklist as a template for every PR.

---

## Overview

Complete workflow for preparing, submitting, and managing pull requests in MLRun.

---

## Pre-Submission Checklist

### Before Creating PR

**Code Complete:**
- [ ] All intended functionality implemented
- [ ] Edge cases handled
- [ ] Error handling in place
- [ ] No debug code or TODOs without tickets

**Testing:**
- [ ] Unit tests written and passing
- [ ] Integration tests (if needed)
- [ ] Manual testing done
- [ ] `make test` passes locally

**Code Quality:**
- [ ] `make fmt` run (auto-formatting applied)
- [ ] `make lint` passes (no errors)
- [ ] Self-review completed (see SELF_REVIEW_CHECKLIST.md)

**Documentation:**
- [ ] Docstrings added for public functions
- [ ] README updated (if adding features)
- [ ] Migration guide (if breaking changes)

**Git:**
- [ ] Commits are clean and logical
- [ ] Commit messages reference ticket
- [ ] Branch is up to date with development

---

## Step 1: Prepare Your Branch

### Update from Development

```bash
# Ensure your branch is current
git checkout development
git pull upstream development

# Rebase your feature branch
git checkout ML-12345-add-feature
git rebase development

# Resolve any conflicts
# ... fix conflicts ...
git add <resolved-files>
git rebase --continue
```

### Clean Up Commit History

👉 **Follow `GIT_WORKFLOW.md`** for rebase/squash guidance

```bash
# Review your commits
git log --oneline origin/development..HEAD

# Interactive rebase to clean up
git rebase -i origin/development

# In the editor:
# - Squash "WIP" commits together
# - Reword unclear commit messages
# - Reorder commits logically
```

**Reference**: `~/claude/GIT_WORKFLOW.md` (Squash vs Preserve History section)

### Final Local Checks

👉 **Run `QUALITY_CHECKS.md`** one final time

```bash
# Format and lint
make fmt
make lint

# Run full test suite
make test

# Verify no accidental changes
git status
git diff origin/development
```

**Reference**: `~/claude/QUALITY_CHECKS.md`

---

## Step 2: Push and Create PR

### Push Your Branch

```bash
# First time push
git push -u origin ML-12345-add-feature

# Or if you rebased (force push)
git push -f origin ML-12345-add-feature
```

### Create PR via GitHub CLI

👉 **MANDATORY**: Use USER_EDIT_WORKFLOW pattern for PR creation

**Steps:**

1. **Generate PR title and description draft** to temporary file:
   ```bash
   # Use mktemp for proper temp file creation (NOT hardcoded paths)
   # Use Bash heredoc (NOT Claude's Write tool which triggers diff view)
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
   # If code --wait fails with stale socket error, use this pattern:
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

   # For direct repo access:
   gh pr create \
     --base development \
     --title "$TITLE" \
     --body "$BODY"

   # For fork workflow:
   gh pr create \
     --repo mlrun/mlrun \
     --base development \
     --head yourname:BRANCH-NAME \
     --title "$TITLE" \
     --body "$BODY"
   ```

5. **Cleanup** (MANDATORY):
   ```bash
   rm /tmp/pr_description.txt
   ```

**Or create via GitHub Web UI:**
1. Go to https://github.com/mlrun/mlrun/pulls
2. Click "New pull request"
3. Select your branch
4. Fill in title and description
5. Click "Create pull request"

---

## Step 3: PR Description Best Practices

### Title Format

👉 **Follow `COMMIT_MESSAGE_FORMAT.md`** for scope and format

**Quick format:**
```
[Scope] Brief description in imperative mood

Examples:
✅ [Feature Store] Add feature validation during ingestion
✅ [API] Fix endpoint crash on empty input
✅ [Model Monitoring] Improve drift detection performance
✅ [Tests] Add integration tests for TimescaleDB queries

❌ Added some features
❌ Fix bug
❌ WIP: working on feature store
```

**Reference**: `~/claude/COMMIT_MESSAGE_FORMAT.md`

### Description Template

👉 **Use `PR_TEMPLATE.txt`** as your starting point

**IMPORTANT Guidelines:**
- Always include Jira case reference (ML-XXXXX format)
- Follow structured sections from PR_TEMPLATE.txt
- **Remove empty sections** - only include sections with content
- **No AI attribution** - don't include "Generated with Claude Code"
- Focus on technical changes and impact

**Reference**: `~/claude/PR_TEMPLATE.txt`

**Template structure** (from PR_TEMPLATE.txt):
```markdown
### 📝 Description
[What and why]

### 🛠️ Changes Made
- Key changes

### ✅ Checklist
- [ ] Tests added
- [ ] Documentation updated

### 🧪 Testing
[How tested]

### 🔗 References
- Ticket link: ML-XXXXX

### 🚨 Breaking Changes?
- [ ] Yes/No

### 🔍️ Additional Notes
[Optional]
```

---

## Step 4: Update Jira Issue

👉 **MANDATORY**: Use USER_EDIT_WORKFLOW pattern for Jira comments
👉 **Follow `JIRA_UPDATE_PATTERN.md`** for all Jira operations

**Steps:**

1. **Generate Jira comment draft** to temporary file:
   ```bash
   # Use mktemp for proper temp file creation (NOT hardcoded paths)
   # Use Bash heredoc (NOT Claude's Write tool which triggers diff view)
   TMPFILE=$(mktemp --suffix=_jira_comment.txt)
   cat > "$TMPFILE" << 'EOF'
   **PR Link**: [PR #XXXX](https://github.com/mlrun/mlrun/pull/XXXX)

   Summary of changes:
   - Change 1
   - Change 2
   EOF
   echo "$TMPFILE"
   ```

2. **Open in VSCode for user editing** (MANDATORY):
   ```bash
   # If code --wait fails with stale socket error, use this pattern:
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

   # Transition to In Progress (if needed)
   mcp__atlassian__transitionJiraIssue(
       cloudId="https://yoursite.atlassian.net",
       issueIdOrKey="TICKET-XXX",
       transition={"id": "741"}
   )
   ```

5. **Cleanup** (MANDATORY):
   ```bash
   rm /tmp/jira_comment.txt
   ```

**Note on cloudId**: Use site URL format (e.g., `https://yoursite.atlassian.net`) instead of UUID cloud ID to avoid permission issues.

**Reference**: `~/claude/JIRA_UPDATE_PATTERN.md`

---

## Step 5: Monitor CI and Address Failures

### After PR Creation

**CI Checks:**
- [ ] Lint check passes
- [ ] Unit tests pass
- [ ] Integration tests pass (if applicable)
- [ ] Security scan passes
- [ ] Build succeeds

### If CI Fails

**Common failures and fixes:**

**1. Lint Failures:**
```bash
# Run locally
make lint

# Fix issues
make fmt

# Commit and push
git add .
git commit -m "[Tests] Fix linting issues"
git push origin ML-12345-add-feature
```

**2. Test Failures:**
```bash
# Run failing test locally
pytest tests/feature_store/test_validator.py::test_failing -v

# Debug and fix
# ...

# Verify fix
pytest tests/feature_store/test_validator.py -v

# Commit and push
git add .
git commit -m "[Tests] Fix test_failing for edge case"
git push origin ML-12345-add-feature
```

**3. Build Failures:**
```bash
# Check Docker build locally
docker build -t test .

# Fix Dockerfile or dependencies
# Commit and push
```

---

## Step 6: Request Reviews

### Who to Request

**For different types of PRs:**
- **Feature work**: Component owner + domain expert
- **Bug fixes**: Original author (if possible) + maintainer
- **Refactoring**: Someone familiar with the code
- **Breaking changes**: Multiple reviewers including tech leads

### Request via GitHub

```bash
# Using gh CLI
gh pr edit --add-reviewer username1,username2

# Or use GitHub UI: "Reviewers" section on the right
```

### Add Context Comment

**After requesting review, add helpful comment:**
```markdown
@reviewer1 @reviewer2 Ready for review!

**Context for reviewers:**
- This builds on PR #1234 (already merged)
- Main complexity is in `validator.py:150-200` - validation logic
- Please pay special attention to error handling in `_validate_range()`

**Questions:**
- Is the validation approach reasonable?
- Should we make validation async for better performance?

Thanks for reviewing!
```

---

## Step 7: Respond to Feedback

### When Feedback Arrives

**Respond promptly:**
- Same day or next business day
- Address all comments
- Ask questions if unclear
- Group related fixes

**See PR_RESPONSE_GUIDE.md for detailed guidance**

### Make Requested Changes

```bash
# Make fixes
# ... edit files ...

# Commit changes
git add .
git commit -m "[Feature Store] Address review feedback

- Simplified validation logic per @reviewer1
- Added null check per @reviewer2
- Improved error messages"

# Push
git push origin ML-12345-add-feature

# Re-request review
gh pr ready
```

### Track What's Done

**Add comment summarizing changes:**
```markdown
## Updates from Review Round 1

**Addressed:**
- ✅ Simplified validation logic (commit abc123)
- ✅ Added null check (commit def456)
- ✅ Improved error messages (commit ghi789)
- ✅ Updated docstrings

**Still discussing:**
- Async validation approach - waiting for @reviewer1 response

**Follow-up tickets created:**
- ML-12346: Add validation for additional types

Ready for another look!
```

---

## Step 8: Handle Merge Conflicts

### When Conflicts Occur

**GitHub shows: "This branch has conflicts that must be resolved"**

```bash
# Update your branch
git checkout ML-12345-add-feature
git fetch origin
git rebase origin/development

# Conflicts appear - resolve in your editor
# ... edit files, remove conflict markers ...

# Stage resolved files
git add <resolved-files>

# Continue rebase
git rebase --continue

# Force push (rebase rewrites history)
git push -f origin ML-12345-add-feature
```

### After Resolving Conflicts

**Add comment on PR:**
```markdown
Resolved merge conflicts with latest development branch.

Changes:
- Rebased on latest development
- No functional changes
- All tests still passing

Ready for final review.
```

---

## Step 9: Final Approval and Merge

### When Approved

**Final checks before merge:**
- [ ] All reviewers approved
- [ ] CI is green
- [ ] No merge conflicts
- [ ] No new comments to address

### Merge Options

**MLRun typically uses "Squash and Merge":**
- All commits squashed into one
- Keeps development branch clean
- GitHub UI handles this automatically

```bash
# Via GitHub CLI
gh pr merge --squash --delete-branch

# Or use GitHub UI "Squash and merge" button
```

### After Merge

**Clean up:**
```bash
# Update local development
git checkout development
git pull upstream development

# Delete local branch
git branch -d ML-12345-add-feature

# Remote branch deleted automatically by GitHub (if configured)
```

**Update Jira ticket:**
```markdown
**Merged to development**

PR: https://github.com/mlrun/mlrun/pull/1234
Commit: abc123

Will be included in next release.
```

---

## Special Cases

### Draft PRs

**When to use:**
- Work in progress
- Want early feedback
- Need CI to run on WIP

```bash
# Create as draft
gh pr create --draft --title "[WIP] Feature Store validation"

# Convert to ready when done
gh pr ready
```

### Large PRs

**If PR is large (>500 lines):**
1. **Consider splitting** into smaller PRs
2. **Provide overview** in description
3. **Guide reviewers** with comments on complex sections
4. **Offer to pair** review if helpful

**Example comment on large PR:**
```markdown
## Review Guide

This PR is large but logically cohesive. Suggested review order:

1. **Start with tests** (`tests/feature_store/test_validator.py`) - understand what's being built
2. **Core logic** (`mlrun/feature_store/validator.py`) - validation implementation
3. **Integration** (`mlrun/feature_store/ingestion.py`) - how it's wired in
4. **Utils** (other files) - supporting functions

Feel free to review in multiple passes. Happy to pair review if helpful!
```

### Hotfixes

**For urgent production fixes:**
```bash
# Branch from main/production
git checkout main
git pull origin main
git checkout -b hotfix/ML-12345-critical-fix

# Fix, test, commit
# ...

# Create PR to main (expedited review)
gh pr create --base main --title "[HOTFIX] Fix critical bug"

# After merge to main, backport to development
git checkout development
git cherry-pick <hotfix-commit>
git push origin development
```

### Working with Forks

**When you're working from a personal fork:**

MLRun contributors typically work from personal forks rather than the main repository. Here's how to manage this workflow.

#### Fork Setup

```bash
# Check your remotes
git remote -v

# Should show:
# origin    git@github.com:yourname/mlrun.git (your fork)
# upstream  git@github.com:mlrun/mlrun.git (main repo)

# If upstream is missing, add it:
git remote add upstream git@github.com:mlrun/mlrun.git
```

#### Keeping Your Fork in Sync

```bash
# Update upstream tracking
git fetch upstream

# Update your local development branch
git checkout development
git pull upstream development

# Push to your fork (optional but recommended)
git push origin development
```

#### Create Branch from Updated Development

```bash
# Always branch from latest upstream development
git fetch upstream
git checkout development
git reset --hard upstream/development  # Ensure exact match with upstream

# Create your feature branch
git checkout -b ML-12345-feature-name
```

#### Push to Your Fork

```bash
# Push your branch to YOUR fork (origin)
git push -u origin ML-12345-feature-name
```

#### Create PR from Fork to Main Repo

**Important**: When working from a fork, you need to specify the main repo and your fork branch explicitly.

```bash
# Create PR from fork to main repo
gh pr create \
  --repo mlrun/mlrun \
  --base development \
  --head yourname:ML-12345-feature-name \
  --title "[Component] Brief description" \
  --body "..."

# Example:
gh pr create \
  --repo mlrun/mlrun \
  --base development \
  --head alxtkr77:ML-11455-controller-fix \
  --title "[Model Monitoring] Fix controller deadlock" \
  --body "$(cat <<'EOF'
## Problem
...
EOF
)"
```

**Key Differences from Direct Repo Access:**
- Must include `--repo mlrun/mlrun` (target repository)
- Must include `--head yourname:branch-name` (your fork and branch)
- `origin` points to YOUR fork, not mlrun/mlrun
- `upstream` points to mlrun/mlrun

#### Common Fork Issues

**Issue 1: PR creation fails with "No commits between development and branch"**

**Cause**: Your local development is out of sync with upstream

**Fix**:
```bash
# Sync with upstream
git checkout development
git fetch upstream
git reset --hard upstream/development
git push -f origin development

# Rebase your feature branch
git checkout ML-12345-feature-name
git rebase development
git push -f origin ML-12345-feature-name
```

**Issue 2: "Head sha can't be blank" error**

**Cause**: Branch not pushed to your fork, or wrong remote specified

**Fix**:
```bash
# Ensure branch is pushed to YOUR fork
git push -u origin ML-12345-feature-name

# Use correct --head format
gh pr create --repo mlrun/mlrun --head yourname:branch-name ...
```

#### Fork Workflow Summary

```bash
# 1. Setup (once)
git remote add upstream git@github.com:mlrun/mlrun.git

# 2. Start new feature
git fetch upstream
git checkout development
git reset --hard upstream/development
git checkout -b ML-12345-feature

# 3. Work and commit
git add .
git commit -m "..."

# 4. Push to YOUR fork
git push -u origin ML-12345-feature

# 5. Create PR to main repo
gh pr create \
  --repo mlrun/mlrun \
  --base development \
  --head yourname:ML-12345-feature \
  --title "..." \
  --body "..."

# 6. After merge, cleanup
git checkout development
git fetch upstream
git reset --hard upstream/development
git push -f origin development
git branch -d ML-12345-feature
```

---

## Checklist Summary

### Before Creating PR
- [ ] Code complete and working
- [ ] Tests written and passing
- [ ] `make fmt && make lint` passes
- [ ] Self-review done
- [ ] Branch rebased on development
- [ ] Commit history cleaned

### Creating PR
- [ ] Descriptive title with scope
- [ ] Complete PR description
- [ ] Breaking changes noted
- [ ] Reviewers requested
- [ ] Labels added (if applicable)

### During Review
- [ ] Respond to feedback promptly
- [ ] Address all comments
- [ ] Track what's been done
- [ ] Re-request review after changes

### Before Merge
- [ ] All reviewers approved
- [ ] CI green
- [ ] No merge conflicts
- [ ] Final self-review

### After Merge
- [ ] Local branch deleted
- [ ] Jira ticket updated
- [ ] Documentation updated (if external docs)

---

## Quick Commands Reference

### For Direct Repo Access (Maintainers)

```bash
# Create feature branch
git checkout -b ML-12345-description

# Update from development
git fetch origin && git rebase origin/development

# Clean commits
git rebase -i origin/development

# Format and lint
make fmt && make lint

# Test
make test

# Push
git push -u origin ML-12345-description

# Create PR
gh pr create --title "..." --body "..."

# Check PR status
gh pr view

# Merge
gh pr merge --squash --delete-branch

# Cleanup
git checkout development && git pull && git branch -d ML-12345-description
```

### For Fork Workflow (Contributors)

```bash
# Setup fork (once)
git remote add upstream git@github.com:mlrun/mlrun.git

# Create feature branch from upstream
git fetch upstream
git checkout development
git reset --hard upstream/development
git checkout -b ML-12345-description

# Format and lint
make fmt && make lint

# Test
make test

# Commit
git add .
git commit -m "[Component] Brief description"

# Push to YOUR fork
git push -u origin ML-12345-description

# Create PR from fork to main repo
gh pr create \
  --repo mlrun/mlrun \
  --base development \
  --head yourname:ML-12345-description \
  --title "[Component] Brief description" \
  --body "..."

# Check PR status
gh pr view --repo mlrun/mlrun

# After merge, sync fork
git checkout development
git fetch upstream
git reset --hard upstream/development
git push -f origin development
git branch -d ML-12345-description
```

---

## Troubleshooting

### VSCode `code --wait` Fails with Stale Socket

**Symptom:**
```
Unable to connect to VS Code server: Error in request.
Error: connect ENOENT /run/user/1000/vscode-ipc-XXXXXXXX.sock
```

**Cause:** The `VSCODE_IPC_HOOK_CLI` environment variable caches the socket path from when the terminal session started. If VS Code restarts, a new socket is created but the old path persists.

**Solution:** Use backticks to dynamically find the latest socket:
```bash
VSCODE_IPC_HOOK_CLI=`ls -t /run/user/1000/vscode-ipc-*.sock | head -1` code --wait "$TMPFILE"
```

**Alternative:** Restart the Claude Code terminal session to pick up the new socket.

### Claude's Write Tool Shows Diff View

**Symptom:** When creating temp files, VSCode opens a side-by-side diff comparison instead of a plain editor.

**Cause:** Claude's `Write` tool is integrated with IDE change tracking.

**Solution:** Use Bash with heredoc to create temp files:
```bash
# DO THIS:
TMPFILE=$(mktemp --suffix=_description.txt)
cat > "$TMPFILE" << 'EOF'
Content here
EOF

# NOT THIS (triggers diff view):
# Write tool to /tmp/file.txt
```

### Temp File Best Practices

1. **Use `mktemp`** - Creates unique temp files, avoids conflicts
2. **Use Bash heredoc** - Bypasses Claude's Write tool diff view
3. **Use meaningful suffixes** - `--suffix=_pr_description.txt` for clarity
4. **Clean up after use** - `rm "$TMPFILE"` when done
5. **Don't ask for confirmation** - Just create temp files and proceed

---

**Last Updated**: 2025-11-21
**Refactored**: Now references GIT_WORKFLOW.md, QUALITY_CHECKS.md, COMMIT_MESSAGE_FORMAT.md, PR_TEMPLATE.txt, JIRA_UPDATE_PATTERN.md
**Added**: Troubleshooting section for VSCode socket and temp file issues
