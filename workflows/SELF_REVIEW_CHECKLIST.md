# Self-Review Checklist

## Overview

Before submitting your PR for review, conduct a thorough self-review. This catches issues early, speeds up the review process, and demonstrates professionalism.

---

## Why Self-Review?

**Benefits:**
- ✅ Catch obvious issues before reviewers see them
- ✅ Reduce review cycles
- ✅ Show attention to detail
- ✅ Learn from your own mistakes
- ✅ Save reviewers' time

**When to Self-Review:**
- After all code is written
- Before creating PR
- After rebasing or major changes
- After addressing review feedback

---

## Step 1: Review Your Own Code

### Read Through GitHub Diff

**View as a reviewer would:**
```bash
# Push your branch
git push origin feature/ML-12345-add-feature

# Open PR in draft mode or use GitHub's "Files changed" view
# Read every line as if reviewing someone else's code
```

### Ask Yourself:

**For each file:**
- [ ] **Is this file needed?** - No accidentally committed files?
- [ ] **Is the change clear?** - What problem does this solve?
- [ ] **Any debug code left?** - Remove temporary logging, comments

**For each function:**
- [ ] **Is the name clear?** - Would a new developer understand it?
- [ ] **Is it too long?** - Should it be split up?
- [ ] **Is it doing one thing?** - Single responsibility?
- [ ] **Are edge cases handled?** - What about None, empty, zero?

**For each line:**
- [ ] **Is this line necessary?** - Can it be simplified?
- [ ] **Is it clear what it does?** - Need a comment?
- [ ] **Could it cause problems?** - Security, performance, bugs?

---

## Step 2: Run Code Quality Checks

👉 **Run `QUALITY_CHECKS.md`** (format, lint, tests)

```bash
make fmt
make lint
pytest <path> -v

# If any issues, fix them now
```

**Reference**: `~/claude/QUALITY_CHECKS.md`

---

## Step 3: Apply Base Code Quality Checklist

👉 **Run `BASE_CODE_QUALITY_CHECKLIST.md`** on all your changes

This covers:
1. **Code Quality** - naming, organization, MLRun conventions
2. **Test Quality** - concrete assertions, meaningful tests
3. **Error Handling** - specific exceptions, clear messages
4. **Security** - SQL injection, command injection, secrets
5. **Performance** - N+1 queries, memory usage
6. **Architecture** - single responsibility, consistency
7. **Documentation** - docstrings, comments
8. **Dependencies** - justified, no vulnerabilities

**Reference**: `~/claude/BASE_CODE_QUALITY_CHECKLIST.md`

**Self-review specific additions:**
- Read through as if reviewing someone else's code
- Be your own toughest critic
- Don't rationalize away concerns - fix them
- If something feels wrong, it probably is

---

## Step 4: PR Description Review

👉 **Use `PR_TEMPLATE.txt`** for PR description

**Checklist:**
- [ ] Explains WHAT and WHY
- [ ] Links to Jira ticket (ML-XXXXX)
- [ ] Lists changes clearly
- [ ] Describes testing done
- [ ] Notes breaking changes (if any)
- [ ] Includes screenshots/logs (if helpful)
- [ ] Removed empty sections

**Reference**: `~/claude/PR_TEMPLATE.txt`

---

## Step 5: Commit History Review

👉 **Follow `GIT_WORKFLOW.md`** for commit cleanup

```bash
# View your commits
git log --oneline origin/development..HEAD

# Interactive rebase for cleanup
git rebase -i origin/development
```

**Checklist:**
- [ ] No "WIP" or "fixup" commits
- [ ] Commit messages follow COMMIT_MESSAGE_FORMAT.md
- [ ] Each commit is logical unit of work
- [ ] Commits reference Jira ticket

**Reference**: `~/claude/GIT_WORKFLOW.md`, `~/claude/COMMIT_MESSAGE_FORMAT.md`

---

## Step 6: Dependencies and Breaking Changes

### Added Dependencies

**Checklist:**
- [ ] New dependencies justified?
- [ ] Using minimal version specifiers?
- [ ] No security vulnerabilities?
- [ ] License compatible with MLRun (Apache 2.0)?
- [ ] Added to requirements.txt properly?

### Breaking Changes

**Checklist:**
- [ ] Is this a breaking change?
- [ ] Can it be made backward compatible?
- [ ] Is migration guide needed?
- [ ] Are deprecation warnings added?
- [ ] Is it documented in PR?

---

## Self-Review Red Flags

### Stop and Fix These Immediately:

🚩 **Security Issues**
- SQL injection vulnerabilities
- Command injection vulnerabilities
- Secrets in logs
- Missing authentication checks

🚩 **Test Issues**
- No tests for new code
- Tests that don't actually test anything
- Commented-out tests
- Tests that fail

🚩 **Code Quality Issues**
- Functions > 100 lines
- Classes > 500 lines
- Deeply nested code (> 4 levels)
- Duplicate code

🚩 **Documentation Issues**
- No docstrings on public functions
- Breaking changes not documented
- No PR description

---

## Final Checklist

Before requesting review:

### Code Quality
- [ ] Ran `make fmt && make lint` (passes)
- [ ] No debug code or commented code
- [ ] Clear naming throughout
- [ ] Proper error handling
- [ ] No security issues

### Testing
- [ ] All tests pass locally
- [ ] New tests added
- [ ] Edge cases covered
- [ ] Tests are meaningful

### Documentation
- [ ] Docstrings added
- [ ] PR description complete
- [ ] Breaking changes noted
- [ ] Migration guide (if needed)

### Review
- [ ] Read through GitHub diff
- [ ] Would I approve this PR?
- [ ] Is it the minimal change needed?
- [ ] Is it ready for production?

### Commit
- [ ] Clean commit history
- [ ] Clear commit messages
- [ ] Ticket referenced

---

## Example Self-Review Comment

When creating your PR, add a self-review comment:

```markdown
## Self-Review Notes

**What I checked:**
- ✅ All tests pass (95% coverage on new code)
- ✅ Lint passes
- ✅ Security review: no SQL injection, proper input validation
- ✅ Performance: uses batch queries, no N+1 issues
- ✅ Documentation: added docstrings and updated README

**Questions for reviewers:**
- Is the error handling approach in `endpoints.py:245` appropriate?
- Should we add integration test for the database migration?

**Trade-offs made:**
- Chose simplicity over performance in `_process_batch()` since typical batch size is < 100 items
- Used existing `QueryBuilder` pattern rather than new abstraction

**Known limitations:**
- Currently only supports TimescaleDB, TDEngine support in follow-up (ML-12346)
```

This shows you've done your homework and helps reviewers focus on what matters.

---

**Last Updated**: 2025-11-20
**Refactored**: Now references BASE_CODE_QUALITY_CHECKLIST.md, QUALITY_CHECKS.md, COMMIT_MESSAGE_FORMAT.md, PR_TEMPLATE.txt, GIT_WORKFLOW.md
**Size Reduction**: 479 lines → 150 lines (69% reduction)
