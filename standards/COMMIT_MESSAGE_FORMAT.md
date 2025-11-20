# Commit Message Format

## Single Source of Truth

This document defines the standard commit message format for MLRun. All workflows reference this format.

---

## Format Structure

```
[<scope>] Verb object in imperative mood

Optional detailed description of what changed and why.
Can span multiple paragraphs if needed.

- Bullet point for key change 1
- Bullet point for key change 2
- Bullet point for key change 3

Reference: ML-XXXXX
```

---

## Components

### 1. Scope (Required)

**Format**: `[Scope]` - Brackets required, Title Case

**Common scopes:**
- `[API]` - API/server changes
- `[SDK]` - Client SDK changes
- `[Model Monitoring]` - Model monitoring features
- `[Feature Store]` - Feature store functionality
- `[DB]` - Database schema or query changes
- `[Tests]` - Test-only changes
- `[Docs]` - Documentation changes
- `[CI/CD]` - Build/deployment pipeline changes
- `[UI]` - Web UI changes
- `[Runtimes]` - Runtime execution (Dask, Spark, etc.)
- `[Serving]` - Model serving functionality

### 2. Summary Line (Required)

**Rules:**
- ✅ Use imperative mood: "Add feature" NOT "Added feature" or "Adds feature"
- ✅ Keep under 72 characters total (including scope)
- ✅ Be specific: "Fix race condition in artifact creation" NOT "Fix bug"
- ✅ No period at the end
- ✅ Capitalize first word after scope

**Examples:**
- ✅ `[API] Add endpoint for listing model endpoints with filters`
- ✅ `[Model Monitoring] Fix crash when endpoint_id is empty`
- ✅ `[Tests] Add integration tests for TimescaleDB queries`
- ❌ `[API] added new endpoint` (not imperative)
- ❌ `[API] Fix stuff` (too vague)
- ❌ `Fixed bug` (no scope)

### 3. Detailed Description (Optional but Recommended)

**When to include:**
- Change is non-obvious
- Multiple files affected
- Important context needed
- Complex bug fix

**What to include:**
- **What** changed (high-level)
- **Why** it changed (motivation)
- **How** it was done (approach, if not obvious)
- **Impact** (breaking changes, performance, etc.)

**Example:**
```
Implements new GET /api/projects/{project}/model-endpoints endpoint
that supports filtering by label, state, and time range.

This enables the UI to efficiently filter large lists of endpoints
without loading all data. Uses query builder pattern for composable filters.

Performance impact: ~10ms for filtered query vs 500ms for full list.
```

### 4. Bullet Points (Optional)

**Use for:**
- Listing key changes
- Breaking down complex commits
- Highlighting important details

**Format:**
- Use `-` for bullet points
- One change per line
- Keep concise

**Example:**
```
- Add ModelEndpointFilter dataclass
- Implement query builder with filter support
- Add comprehensive unit tests
- Update API documentation
```

### 5. Reference (Required)

**Format**: `Reference: ML-XXXXX` or `Fixes: ML-XXXXX`

**Use:**
- `Reference: ML-XXXXX` - General reference to ticket
- `Fixes: ML-XXXXX` - Explicitly fixes/resolves the ticket

---

## Complete Examples

### Example 1: Feature Addition

```
[Feature Store] Add feature validation during ingestion

Implements FeatureValidator class that validates features during ingestion
to prevent invalid data from entering the feature store. Validation includes
type checking, range validation, and schema compliance.

- Add mlrun/feature_store/validator.py with validation logic
- Integrate with ingestion pipeline (opt-in via validate_features=True)
- Add comprehensive unit and integration tests
- Update documentation with validation examples

Reference: ML-12345
```

### Example 2: Bug Fix

```
[API] Fix crash when endpoint_id is empty or invalid

Handle edge cases where endpoint_id is empty or endpoint doesn't exist.
Previously, these cases caused uncaught exceptions.

- Add validation for empty endpoint_id
- Handle None return from database query
- Raise appropriate MLRun exceptions with clear messages
- Add tests for both edge cases

Fixes: ML-12346
```

### Example 3: Refactoring

```
[Model Monitoring] Refactor TimescaleDB query handler for maintainability

Split monolithic query handler (1,389 lines) into focused modules using
composition pattern. No functional changes - pure refactoring.

- Extract TimescaleDBMetricsQueries mixin
- Extract TimescaleDBPredictionsQueries mixin
- Extract TimescaleDBResultsQueries mixin
- Add TimescaleDBQueryBuilder utility
- All 118 tests passing, API preserved

Reference: ML-12347
```

### Example 4: Test Addition

```
[Tests] Add integration tests for TimescaleDB continuous aggregates

Tests were missing for pre-aggregate functionality, causing regression
in production. These tests cover all aggregate query patterns.

- Add test_pre_aggregate_queries.py with 15 test cases
- Test hourly, daily, and monthly aggregates
- Test fallback to raw queries when aggregates unavailable
- Coverage: 95% on pre-aggregate code paths

Reference: ML-12348
```

### Example 5: Documentation

```
[Docs] Update CONTRIBUTING.md with TimescaleDB setup instructions

Community contributors struggled to set up TimescaleDB for local testing.
Added step-by-step setup guide with Docker commands.

- Add TimescaleDB Docker setup section
- Document required environment variables
- Add troubleshooting for common connection issues
- Include example test commands

Reference: ML-12349
```

---

## Bad Examples (What NOT to Do)

### ❌ Too Vague
```
Fixed stuff
Update code
WIP
```

### ❌ No Scope
```
Fix bug in endpoint retrieval
Add new feature
```

### ❌ Wrong Mood
```
[API] Added new endpoint
[API] Fixes the bug
[API] Adding feature
```

### ❌ No Ticket Reference
```
[API] Add endpoint for listing model endpoints

Implements new GET endpoint...
```

### ❌ Too Much Implementation Detail
```
[API] Add endpoint for listing model endpoints

Changed line 45 to use filter() instead of list comprehension.
Modified variable name from x to endpoint_id.
Added import for FilterBuilder class.
...
```

---

## Quick Checklist

Before committing, verify:
- [ ] Scope in [brackets]
- [ ] Summary in imperative mood ("Add" not "Added")
- [ ] Summary under 72 characters
- [ ] Detailed description explains WHY (if non-obvious)
- [ ] Ticket reference included (Reference: or Fixes:)
- [ ] No typos or grammar errors

---

## Special Cases

### Merge Commits
```
Merge branch 'development' into feature/ML-12345
```
(GitHub handles these automatically)

### Revert Commits
```
Revert "[API] Add endpoint for listing endpoints"

This reverts commit abc123. The feature introduced a regression
in production that requires deeper investigation.

Reference: ML-12350
```

### Amend Commits
Use `git commit --amend` to fix the most recent commit message.
**Only amend if not yet pushed**, or if explicitly required by pre-commit hooks.

---

## Git Commit Command

```bash
git commit -m "[Scope] Brief description

Detailed explanation of what and why.
- Key change 1
- Key change 2

Reference: ML-XXXXX"
```

**For multi-line messages, use heredoc:**
```bash
git commit -m "$(cat <<'EOF'
[Scope] Brief description

Detailed explanation.

Reference: ML-XXXXX
EOF
)"
```

---

## Referenced By

- PRE_COMMIT_WORKFLOW.md
- PR_READINESS_CHECKLIST.md
- GIT_WORKFLOW.md
- BUG_HANDLING_WORKFLOW.md
- PR_SUBMISSION_WORKFLOW.md
- CODE_REVIEW_GUIDE.md

---

**Last Updated**: 2025-11-20
**Purpose**: Single source of truth for commit message format
