# Pre-Commit Workflow

## Critical Rule: ALWAYS Run Before EVERY Commit

**This workflow applies to ALL commits, not just PRs:**
- Initial PR commits
- Responding to review feedback
- Quick fixes
- Documentation changes
- Test-only changes

---

## Mandatory Steps (No Exceptions)

### Steps 1-4: Quality Checks

👉 **Run `QUALITY_CHECKS.md`** (single source of truth)

This includes:
1. **Format code**: `make fmt`
2. **Lint code**: `make lint`
3. **Run tests**: `pytest <path> -v`
4. **Review changes**: `git diff`

**All checks MUST pass** before proceeding to commit.

---

### Step 5: Security Scan - Check for Secrets

**CRITICAL**: Before committing, scan for leaked secrets.

👉 **Full guide**: `SECURITY_SECRETS_SCAN.md`

**Quick scan checklist**:
```bash
git diff path/to/changed/files
```

**Look for**:
- ❌ API keys, tokens, passwords
- ❌ Cloud credentials (AWS, Azure, GCP)
- ❌ Database connection strings with passwords
- ❌ Private keys (SSH, SSL, PGP)
- ❌ OAuth tokens, client secrets

**If secrets found**:
1. **STOP** - Do not commit
2. Remove the secret from code
3. Use environment variables: `API_KEY = os.getenv("API_KEY")`
4. Add sensitive files to `.gitignore`
5. If already pushed: **Immediately rotate credentials**

**Safe pattern**:
```python
# Good
API_KEY = os.environ.get("API_KEY")

# Bad
API_KEY = "ak_live_1234567890abcdef"
```

See `SECURITY_SECRETS_SCAN.md` for complete patterns and remediation steps.

---

### Step 6: Quick Self-Review

**Check**:
- No debug statements or print() calls
- No commented-out code
- Variable names are clear
- No hardcoded values that should be configurable
- Logic is correct
- Error handling is appropriate
- Follows "Reference Test Data" principle for tests (see TESTING_STANDARDS.md)

---

### Step 7: Generate Commit Message (MANDATORY User Review)

**CRITICAL**: ALWAYS use the USER_EDIT_WORKFLOW pattern for ALL commits.

**Steps:**

1. **Generate draft commit message** to temporary file:
   ```bash
   cat > /tmp/commit_msg.txt << 'EOF'
   [Scope] Brief description

   Detailed explanation...

   Reference: TICKET-XXX
   EOF
   ```

2. **Open in VSCode for user editing** (MANDATORY):
   ```bash
   code --wait /tmp/commit_msg.txt
   ```
   - User edits and saves the message
   - Close file when done (unblocks Claude)

3. **Show preview and ask for approval**:
   ```bash
   cat /tmp/commit_msg.txt
   ```
   Ask: "Should I proceed with this commit message? (yes/no)"

4. **Commit with reviewed message**:
   ```bash
   git add <files>
   git commit -F /tmp/commit_msg.txt
   ```

5. **Cleanup** (MANDATORY):
   ```bash
   rm /tmp/commit_msg.txt
   ```

👉 **Full details**: `USER_EDIT_WORKFLOW.md`
👉 **Commit message format**: `COMMIT_MESSAGE_FORMAT.md`

**Why this is mandatory:**
- User has final control over commit message
- Catches AI mistakes or unclear descriptions
- Ensures accurate representation of changes
- Allows user to add context AI doesn't have

---

## When to Skip (Never)

**Common excuses that are WRONG:**
- ❌ "It's just a small change" → **Still run workflow**
- ❌ "I'm just responding to review comments" → **Still run workflow**
- ❌ "It's only documentation" → **Still run fmt/lint (markdown)**
- ❌ "Tests are slow" → **At minimum run affected tests**
- ❌ "I'll fix it later" → **Fix it now**

**Correct approach:** ALWAYS run the workflow, no exceptions

---

## Checklist

Before running `git commit`:
- [ ] Ran QUALITY_CHECKS.md (fmt → lint → tests)
- [ ] All checks passed
- [ ] **Security scan: No secrets in `git diff`** (API keys, passwords, credentials)
- [ ] Reviewed `git diff` for quality
- [ ] Generated commit message draft to /tmp/commit_msg.txt
- [ ] Opened in VSCode with `code --wait` for user editing
- [ ] User reviewed and edited the message
- [ ] Showed preview and got user approval
- [ ] Committed with `git commit -F /tmp/commit_msg.txt`
- [ ] Cleaned up temp file with `rm /tmp/commit_msg.txt`

---

## Why This Matters

**Time saved:**
- Avoids "lint failed" CI failures
- Avoids "please run formatter" review comments
- Catches bugs before pushing
- Reduces review cycles

**Quality maintained:**
- Consistent code style
- No silly mistakes slip through
- Tests actually verify changes work

**Professional:**
- Shows attention to detail
- Respects reviewers' time
- Builds trust with team

---

## Integration with Other Workflows

**PR Creation** (`PR_READINESS_CHECKLIST.md`):
- This workflow is step 1-4 of PR creation
- PR readiness adds: documentation verification, PR description, Jira update

**Bug Fixing** (`BUG_HANDLING_WORKFLOW.md`):
- This workflow comes before "commit fix" step

**Review Response** (`PR_RESPONSE_GUIDE.md`):
- This workflow runs before committing changes from review feedback

---

## Quick Command Reference

```bash
# Run all steps in one command:
make fmt && make lint && pytest <path> -v && git diff
```

---

**Last Updated**: 2025-11-20
**Refactored**: Now references QUALITY_CHECKS.md and COMMIT_MESSAGE_FORMAT.md
**Created Due To**: Skipping fmt/lint/self-review when responding to PR #8903 feedback
