# Quality Checks - Standard Pattern

## Overview

This is the atomic quality check pattern that MUST be run before any commit to MLRun. This pattern is referenced by all commit workflows.

---

## Standard Quality Check Workflow

### Step 1: Format Code

```bash
make fmt
```

**What it does:**
- Runs `ruff format` on all Python files
- Auto-fixes formatting issues (line length, indentation, spacing)
- May wrap long lines automatically

**After running:**
```bash
git status  # Review what changed
```

**IMPORTANT**: Stage ALL formatting changes, including subtle line wraps.

---

### Step 2: Check Linting

```bash
make lint
```

**What it checks:**
- Code quality issues
- Unused imports
- Line length violations (after formatting)
- Style compliance

**If lint fails:**
```bash
# Auto-fix what's possible
python -m ruff check --fix

# Check again
make lint

# Fix remaining issues manually
```

**MUST**: Zero errors before proceeding.

---

### Step 3: Run Tests

```bash
# Run affected tests (recommended)
pytest path/to/affected/tests.py -v

# OR run specific test pattern
pytest -k "test_pattern" -v

# OR run full suite (slower)
make test
```

**What to run:**
- **Minimum**: Tests for files you changed
- **Recommended**: Related test suite (e.g., `tests/model_monitoring/` if you changed model monitoring)
- **Best**: Full test suite (especially before PR)

**MUST**: All tests pass before committing.

---

### Step 4: Review Changes

```bash
git diff
```

**Check for:**
- No debug code (print statements, commented code)
- No TODO comments without ticket numbers
- All changes are intentional
- Formatting changes look correct

---

## Quick Command Reference

```bash
# Run all quality checks in sequence:
make fmt && git status && make lint && pytest <path> -v
```

---

## When to Run This Pattern

**ALWAYS run before:**
- ✅ Every commit (PRE_COMMIT)
- ✅ Creating PR (PR_READINESS)
- ✅ Responding to review feedback
- ✅ Fixing bugs
- ✅ After resolving merge conflicts

**NO EXCEPTIONS** - Even for:
- "Small changes"
- "Just documentation"
- "Quick fix"

---

## Referenced By

- PRE_COMMIT_WORKFLOW.md (steps 1-4)
- PR_READINESS_CHECKLIST.md (steps 1-2)
- SELF_REVIEW_CHECKLIST.md (step 2)
- BUG_HANDLING_WORKFLOW.md (step 4)
- PR_SUBMISSION_WORKFLOW.md (step 1)

---

**Last Updated**: 2025-11-20
**Purpose**: Single source of truth for quality check pattern
