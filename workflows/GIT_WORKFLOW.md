# Git Workflow Guide

## Remote Repository Naming

### ⚠️ IMPORTANT: Always Use `upstream` for mlrun/mlrun

**Critical Rule**: When working with a fork of the MLRun repository:
- **`upstream`** = Official mlrun/mlrun repository
- **`origin`** = Your personal fork (e.g., alxtkr77/mlrun)

**Always use `upstream` when pulling from development**:
```bash
# ✅ CORRECT - Pull from official repository
git pull upstream development

# ❌ WRONG - Do not use origin for main development branch
git pull origin development
```

**Why This Matters**:
- `origin` points to your fork, which may be out of date
- `upstream` points to the official repository with the latest changes
- Using `origin` can cause you to miss important updates and create merge conflicts

**Setup Remotes** (if not already configured):
```bash
# Add upstream remote (official mlrun/mlrun)
git remote add upstream https://github.com/mlrun/mlrun.git

# Verify remotes
git remote -v
# Should show:
# origin    https://github.com/YOUR_USERNAME/mlrun.git (fetch)
# origin    https://github.com/YOUR_USERNAME/mlrun.git (push)
# upstream  https://github.com/mlrun/mlrun.git (fetch)
# upstream  https://github.com/mlrun/mlrun.git (push)
```

---

## Branch Naming Conventions

### Format
```
<type>/<ticket-id>-<brief-description>
```

### Branch Types
- `feature/` - New features or enhancements
- `bugfix/` - Bug fixes
- `hotfix/` - Urgent production fixes
- `refactor/` - Code refactoring without functional changes
- `test/` - Test additions or modifications
- `docs/` - Documentation changes only

### Examples
```bash
feature/ML-12345-add-timescaledb-support
bugfix/ML-12346-fix-race-condition
refactor/ML-12347-simplify-query-handler
test/ML-12348-add-integration-tests
docs/ML-12349-update-contributing-guide
```

### Branch Lifecycle
1. **Create from latest development branch**
   ```bash
   git checkout development
   git pull upstream development
   git checkout -b feature/ML-12345-add-feature
   ```

2. **Keep branch up to date**
   ```bash
   git checkout development
   git pull upstream development
   git checkout feature/ML-12345-add-feature
   git rebase development
   ```

3. **Clean up after merge**
   ```bash
   git branch -d feature/ML-12345-add-feature
   git push origin --delete feature/ML-12345-add-feature
   ```

---

## Commit Message Format

### Structure
```
[<scope>] Verb object in imperative mood

Optional detailed description of what changed and why.

- Bullet points for key changes
- Reference ticket: ML-12345
```

### Scope Examples
- `[API]` - API/server changes
- `[SDK]` - Client SDK changes
- `[Model Monitoring]` - Model monitoring features
- `[Feature Store]` - Feature store functionality
- `[DB]` - Database schema or query changes
- `[Tests]` - Test-only changes
- `[Docs]` - Documentation changes
- `[CI/CD]` - Build/deployment pipeline changes

### Commit Message Examples

**Good:**
```
[API] Add endpoint for listing model endpoints with filters

Implements new GET /api/projects/{project}/model-endpoints endpoint
that supports filtering by label, state, and time range.

- Add ModelEndpointFilter dataclass
- Implement query builder with filter support
- Add comprehensive unit tests
- Reference: ML-12345
```

**Bad:**
```
Fixed stuff
```

### Commit Guidelines
1. **Use imperative mood**: "Add feature" not "Added feature" or "Adds feature"
2. **Be specific**: "Fix race condition in artifact creation" not "Fix bug"
3. **Keep first line under 72 characters**
4. **Add ticket reference** in commit body
5. **Explain WHY not just WHAT** in the description

---

## Rebase vs Merge Strategy

### When to Rebase (Preferred)
**Use rebase for:**
- Updating feature branch with latest development changes
- Keeping linear history
- Before creating PR (clean up commits)

```bash
git checkout feature/ML-12345
git fetch origin
git rebase origin/development
```

**Benefits:**
- Clean, linear history
- Easier to understand git log
- No merge commit noise

### When to Merge
**Use merge for:**
- Merging PR to development (handled by GitHub)
- When working with shared branches (avoid rewriting history)
- Integration branches

```bash
# Usually done via GitHub PR merge button
# Or if needed locally:
git checkout development
git merge --no-ff feature/ML-12345
```

### Interactive Rebase for Cleanup
```bash
# Clean up last 5 commits before PR
git rebase -i HEAD~5

# Squash fixup commits, reword messages, reorder commits
```

---

## Handling Merge Conflicts

### During Rebase
```bash
git rebase origin/development

# If conflicts occur:
# 1. Fix conflicts in files
# 2. Stage resolved files
git add <resolved-files>

# 3. Continue rebase
git rebase --continue

# Or abort if needed
git rebase --abort
```

### Conflict Resolution Tips
1. **Understand both sides**: Read both versions carefully
2. **Test after resolution**: Run tests after resolving
3. **Consult file history**: Use `git log <file>` to understand changes
4. **Ask for help**: If unsure, consult the author of conflicting changes

### Common Conflict Patterns
```python
# Conflict markers
<<<<<<< HEAD
your_code()
=======
their_code()
>>>>>>> branch-name

# Resolution: Choose one or combine
final_code()
```

---

## Squash vs Preserve History

### When to Squash
**Squash commits when:**
- Multiple "WIP" or "fix typo" commits exist
- Commit history is messy during development
- Logical changes are split across many commits
- Creating final PR (GitHub squash merge option)

```bash
# Squash last 3 commits
git rebase -i HEAD~3
# Change 'pick' to 'squash' or 'fixup' for commits to combine
```

### When to Preserve History
**Keep separate commits when:**
- Each commit represents a logical, atomic change
- Commits are already well-structured
- History helps understand feature evolution
- Multiple reviewers worked on different commits

### MLRun Preferred Approach
- **During development**: Commit frequently (messy is OK)
- **Before PR**: Clean up with interactive rebase
- **PR merge**: Use GitHub squash merge (default)

---

## Common Workflows

### Feature Development Workflow
```bash
# 1. Create feature branch
git checkout development
git pull upstream development
git checkout -b feature/ML-12345-add-feature

# 2. Develop with frequent commits
git add <files>
git commit -m "[Feature Store] Add initial implementation"

# 3. Keep branch updated (do this daily)
git fetch origin
git rebase origin/development

# 4. Clean up before PR
git rebase -i HEAD~10  # Squash WIP commits

# 5. Push and create PR
git push origin feature/ML-12345-add-feature

# 6. Address review feedback
git add <files>
git commit -m "[Feature Store] Address review comments"
git push origin feature/ML-12345-add-feature

# 7. After PR merge, cleanup
git checkout development
git pull upstream development
git branch -d feature/ML-12345-add-feature
```

### Hotfix Workflow
```bash
# 1. Create from production/main
git checkout main
git pull origin main
git checkout -b hotfix/ML-12345-critical-fix

# 2. Fix and test
git add <files>
git commit -m "[API] Fix critical security vulnerability"

# 3. Create PR to main (expedited review)
git push origin hotfix/ML-12345-critical-fix

# 4. After merge, backport to development if needed
git checkout development
git cherry-pick <commit-hash>
```

### Reviewing and Testing Others' PRs
```bash
# 1. Fetch PR branch
git fetch origin pull/1234/head:pr-1234
git checkout pr-1234

# 2. Test locally
make test
make lint

# 3. Return to your branch
git checkout feature/ML-12345
```

---

## Best Practices

### DO
- ✅ Pull latest before creating new branch
- ✅ Rebase frequently to avoid large conflicts
- ✅ Write meaningful commit messages
- ✅ Test before pushing
- ✅ Run `make fmt` and `make lint` before committing
- ✅ Keep commits focused and atomic
- ✅ Reference ticket numbers in commits

### DON'T
- ❌ Force push to shared branches
- ❌ Commit directly to development/main
- ❌ Leave "WIP" or "fixup" commits in PR
- ❌ Rebase after pushing to PR (force push required)
- ❌ Mix unrelated changes in one commit
- ❌ Commit without testing

---

## Git Configuration Tips

### Recommended Git Config
```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# Useful aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.lg "log --graph --oneline --decorate --all"

# Automatically prune deleted remote branches
git config --global fetch.prune true

# Use rebase when pulling
git config --global pull.rebase true
```

### Helpful Git Commands
```bash
# See what changed
git diff HEAD~1

# See commit history
git log --oneline --graph --decorate

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git restore .

# Update all branches
git fetch --all --prune

# List merged branches
git branch --merged

# Delete merged branches
git branch --merged | grep -v "\*\|development\|main" | xargs -n 1 git branch -d
```

---

## Troubleshooting

### "Cannot rebase: You have unstaged changes"
```bash
# Stash changes temporarily
git stash
git rebase origin/development
git stash pop
```

### "Detached HEAD state"
```bash
# Create branch from detached HEAD
git checkout -b recovery-branch

# Or discard and return
git checkout development
```

### "Merge conflict in binary file"
```bash
# Choose theirs
git checkout --theirs path/to/file

# Or choose ours
git checkout --ours path/to/file

git add path/to/file
```

### Accidentally committed to wrong branch
```bash
# On wrong branch
git log  # Find commit hash

# Switch to correct branch
git checkout correct-branch
git cherry-pick <commit-hash>

# Go back and remove from wrong branch
git checkout wrong-branch
git reset --hard HEAD~1
```

---

**Last Updated**: 2025-11-10
**Reference**: Based on MLRun CONTRIBUTING.md and universal_principles.md
