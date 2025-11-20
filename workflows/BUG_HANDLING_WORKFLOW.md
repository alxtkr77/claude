# Bug Handling Workflow

## Overview

This guide covers the complete workflow for handling bugs from Jira tickets through to resolution and verification.

---

## CRITICAL: Evidence-Based Analysis Rules

**All bug analysis MUST be based on hard evidence. No speculation without proof.**

### Rule 1: Every Claim Must Cite Evidence

| Claim Type | Required Evidence |
|------------|-------------------|
| "The error is X" | Log line with timestamp, stack trace |
| "The bug is in file Y" | File path + line number + code snippet |
| "This was introduced in Z" | Git blame output, commit hash |
| "The fix should be W" | Root cause evidence first |

### Rule 2: State Uncertainty Explicitly

**Use these patterns:**
- **EVIDENCE**: "The logs show X at timestamp Y" (cite the log)
- **HYPOTHESIS**: "This MIGHT be caused by Y - need to verify by..."
- **UNKNOWN**: "I don't have enough evidence to determine Z"

**FORBIDDEN without evidence:**
- "The problem is..."
- "This is caused by..."
- "The fix is..."
- "Obviously..."
- "Clearly..."

### Rule 3: Before Proposing Any Fix

- [ ] Root cause identified with specific log/code evidence
- [ ] Reproduction confirmed (not assumed)
- [ ] Alternative explanations explicitly ruled out
- [ ] Evidence documented in analysis

### Rule 4: Investigation Output Format

```markdown
## Evidence Collected
1. **Log evidence**: [paste exact log lines with timestamps]
2. **Stack trace**: [paste full stack trace]
3. **Code location**: file.py:123 - [paste relevant code]
4. **Git history**: commit abc123 introduced this on DATE

## Root Cause Analysis
- **Confirmed**: [what the evidence proves]
- **Hypothesis**: [what we think but haven't proven]
- **Unknown**: [what we still need to investigate]

## Proposed Fix
- **Only after root cause is CONFIRMED with evidence**
```

### Rule 5: When Evidence is Insufficient

1. **ASK** for more logs/data before concluding
2. **ADD** debug logging to gather evidence
3. **REPRODUCE** locally to observe behavior
4. **STATE** "insufficient evidence" rather than guess

---

## Step 1: Triage and Understanding

### When You Receive a Bug Ticket

**Read the ticket thoroughly:**
- [ ] **Summary** - What is the symptom?
- [ ] **Description** - What are the steps to reproduce?
- [ ] **Expected vs Actual** - What should happen vs what happens?
- [ ] **Environment** - Where does it occur? (version, platform, configuration)
- [ ] **Severity/Priority** - How critical is this?
- [ ] **Attachments** - Logs, screenshots, stack traces?

### Ask Clarifying Questions in Ticket

If information is missing:
```markdown
@reporter Thanks for reporting! To help diagnose this, could you provide:

1. Full error message or stack trace
2. Steps to reproduce (code snippet if possible)
3. MLRun version: `python -c "import mlrun; print(mlrun.__version__)"`
4. Environment: Kubernetes version, OS, Python version
5. When did this start happening? (recent upgrade, config change?)

This will help us identify the root cause faster.
```

### Reproduce Locally (If Possible)

**Priority 1: Reproduce the issue**
```bash
# 1. Check out the affected version/branch
git checkout <version-tag-or-branch>

# 2. Set up environment matching the bug report
conda activate mlrun-base-vb
pip install -e .

# 3. Run the reproduction steps from ticket
python reproduce_bug.py

# 4. Capture logs, errors, behavior
```

**If you can't reproduce:**
- Ask for more details
- Try different configurations
- Check if it's environment-specific
- Request access to affected environment

---

## Step 2: Root Cause Analysis

### Investigation Techniques

**1. Read the Error Message Carefully**
```python
# Look for:
# - Exception type and message
# - File and line number
# - Full stack trace

Example error:
  File "mlrun/api/crud/endpoints.py", line 245, in get_endpoint
    return self._fetch_from_db(endpoint_id)
  KeyError: 'endpoint_id'

# This tells us: line 245, missing 'endpoint_id' key
```

**2. Add Debug Logging**
```python
# Temporary debug logging to understand flow
logger.debug(f"[DEBUG] endpoint_id={endpoint_id}, type={type(endpoint_id)}")
logger.debug(f"[DEBUG] Available keys: {list(data.keys())}")
logger.debug(f"[DEBUG] Full data: {data}")
```

**3. Use Git Blame**
```bash
# Find when the problematic code was introduced
git blame mlrun/api/crud/endpoints.py | grep -A5 -B5 "line 245"

# Check the commit that introduced it
git show <commit-hash>
```

**4. Check Recent Changes**
```bash
# Look for recent changes to the affected file
git log --oneline --since="2 weeks ago" -- mlrun/api/crud/endpoints.py

# Review recent PRs that might have introduced the bug
gh pr list --state merged --search "endpoints" --limit 10
```

**5. Check Tests**
```bash
# Are there existing tests for this code path?
grep -r "test.*endpoint" tests/

# Do the tests pass?
pytest tests/api/test_endpoints.py -v
```

### Common Bug Patterns

**Pattern 1: Null/None Handling**
```python
# ❌ Bug - no null check
def get_endpoint(endpoint_id):
    return db.query(endpoint_id).name  # Crashes if None

# ✅ Fix - handle None
def get_endpoint(endpoint_id):
    result = db.query(endpoint_id)
    if result is None:
        raise MLRunNotFoundError(f"Endpoint {endpoint_id} not found")
    return result.name
```

**Pattern 2: Race Conditions**
```python
# ❌ Bug - not thread-safe
if endpoint_id not in cache:
    cache[endpoint_id] = fetch_endpoint(endpoint_id)  # Race here!
return cache[endpoint_id]

# ✅ Fix - use locks or atomic operations
with cache_lock:
    if endpoint_id not in cache:
        cache[endpoint_id] = fetch_endpoint(endpoint_id)
    return cache[endpoint_id]
```

**Pattern 3: Missing Validation**
```python
# ❌ Bug - no input validation
def create_endpoint(name, state):
    db.insert(name=name, state=state)  # What if state is invalid?

# ✅ Fix - validate inputs
VALID_STATES = {"ready", "running", "error"}

def create_endpoint(name, state):
    if state not in VALID_STATES:
        raise ValueError(f"Invalid state: {state}")
    db.insert(name=name, state=state)
```

---

## Step 3: Fix Implementation

### Create Bug Fix Branch

```bash
git checkout development
git pull upstream development
git checkout -b bugfix/ML-12345-fix-endpoint-crash
```

### Write the Fix

**Guidelines:**
1. **Minimal change** - Fix only what's needed
2. **Don't refactor** - Keep refactoring separate
3. **Add validation** - Prevent similar bugs
4. **Handle edge cases** - Think about boundary conditions

**Example Fix:**
```python
# File: mlrun/api/crud/endpoints.py

def get_endpoint(project: str, endpoint_id: str) -> ModelEndpoint:
    """Get model endpoint by ID.

    Args:
        project: Project name
        endpoint_id: Endpoint unique identifier

    Returns:
        ModelEndpoint object

    Raises:
        MLRunNotFoundError: If endpoint doesn't exist
        MLRunInvalidArgumentError: If parameters are invalid
    """
    # Fix: Add validation (ML-12345)
    if not endpoint_id:
        raise MLRunInvalidArgumentError("endpoint_id cannot be empty")

    # Fix: Handle None case (ML-12345)
    endpoint = self._db.get_endpoint(project, endpoint_id)
    if endpoint is None:
        raise MLRunNotFoundError(
            f"Endpoint '{endpoint_id}' not found in project '{project}'"
        )

    return endpoint
```

### Add/Update Tests

**Must have: Test that reproduces the bug**
```python
# tests/api/test_endpoints.py

def test_get_endpoint_with_empty_id_raises_error():
    """Test that empty endpoint_id raises proper error (ML-12345)."""
    store = EndpointStore()

    with pytest.raises(MLRunInvalidArgumentError, match="endpoint_id cannot be empty"):
        store.get_endpoint(project="default", endpoint_id="")


def test_get_nonexistent_endpoint_raises_not_found():
    """Test that missing endpoint raises NotFoundError (ML-12345)."""
    store = EndpointStore()

    with pytest.raises(MLRunNotFoundError, match="Endpoint.*not found"):
        store.get_endpoint(project="default", endpoint_id="nonexistent")
```

**Verify fix works:**
```bash
# Run the specific tests
pytest tests/api/test_endpoints.py::test_get_endpoint_with_empty_id_raises_error -v
pytest tests/api/test_endpoints.py::test_get_nonexistent_endpoint_raises_not_found -v

# Run all endpoint tests
pytest tests/api/test_endpoints.py -v

# Run full test suite
make test
```

---

## Step 4: Commit and PR

### Run Pre-Commit Workflow

👉 **Run `PRE_COMMIT_WORKFLOW.md`** before committing:
1. Format code (`make fmt`)
2. Check linting (`make lint`)
3. Run tests
4. Quick self-review

**Reference**: `~/claude/PRE_COMMIT_WORKFLOW.md`

### Commit with Bug-Specific Message

👉 **Format**: `COMMIT_MESSAGE_FORMAT.md`

**Bug fix specific format:**
```bash
git add mlrun/api/crud/endpoints.py tests/api/test_endpoints.py

git commit -m "[API] Fix crash when endpoint_id is empty or invalid

Handle edge cases where endpoint_id is empty or endpoint doesn't exist.
Previously, these cases caused uncaught exceptions.

Root cause: Missing validation and null check
- Add validation for empty endpoint_id
- Handle None return from database query
- Raise appropriate MLRun exceptions with clear messages
- Add tests for both edge cases

Fixes: ML-12345"
```

**Key elements for bug fixes:**
- Use "Fix" or "Fixes" in summary
- Include "Root cause:" in description
- Use "Fixes: ML-XXXXX" (not just "Reference:")

### Create PR

👉 **Follow `PR_SUBMISSION_WORKFLOW.md`** for detailed PR creation

**Quick version:**
```bash
git push origin bugfix/ML-12345-fix-endpoint-crash

# Create PR using PR_TEMPLATE.txt format
gh pr create --title "[API] Fix crash when endpoint_id is empty or invalid" \
  --body "$(cat pr_description.md)"
```

**PR description should include:**
- Problem statement
- Root cause analysis
- Solution approach
- Test coverage
- Verification steps

**Reference**: `~/claude/PR_SUBMISSION_WORKFLOW.md`, `~/claude/PR_TEMPLATE.txt`

---

## Step 5: Update Jira Ticket

👉 **Follow `JIRA_UPDATE_PATTERN.md`** for all Jira operations

**Reference**: `~/claude/JIRA_UPDATE_PATTERN.md`

### During Investigation

```python
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**Investigation Update:**

Reproduced the issue locally. Root cause identified:

- **File**: mlrun/api/crud/endpoints.py, line 245
- **Issue**: Missing validation for empty endpoint_id and no None check
- **Introduced in**: Commit abc123 (PR #1234)

**Next Steps:**
- Add validation for empty endpoint_id
- Add None check after database query
- Add tests for both cases
- Target fix in next 2 days
"""
)
```

### After Fix / PR Creation

```python
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

### After Merge

```python
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**Resolved and Merged**

Fix merged to development branch.

**Included in:** v1.7.0 (or next release)
**Commit**: abc123

**Verification Steps for Users:**
\`\`\`python
import mlrun
store = mlrun.get_run_db()

# This should now raise clear error instead of crash
try:
    store.get_endpoint("default", "")
except mlrun.errors.MLRunInvalidArgumentError as e:
    print(f"Proper error: {e}")
\`\`\`

Closing ticket as resolved.
"""
)
```

---

## Step 6: Verification

### Test in Affected Environment

**If possible, deploy to test environment:**
```bash
# Build image with fix
docker build -t mlrun-api:bugfix-test .

# Deploy to test cluster
kubectl set image deployment/mlrun-api mlrun-api=mlrun-api:bugfix-test -n mlrun

# Verify fix works
python verify_fix.py
```

### Regression Testing

**Check that fix doesn't break anything:**
```bash
# Run full test suite
make test

# Run integration tests
make test-integration

# Check related functionality
pytest tests/api/test_endpoints.py -v
pytest tests/model_monitoring/ -v
```

---

## Common Bug Categories and Patterns

### Category 1: Null/Missing Data

**Symptoms:**
- `KeyError`, `AttributeError`, `NoneType has no attribute`

**Investigation:**
- Check where data comes from
- Verify all code paths set required fields
- Check database schema matches expectations

**Fix Pattern:**
```python
# Add validation and None checks
if value is None:
    raise MLRunInvalidArgumentError("value is required")
```

### Category 2: Race Conditions

**Symptoms:**
- Intermittent failures
- Works sometimes, fails others
- Database constraint violations

**Investigation:**
- Look for shared state (global variables, caches)
- Check concurrent operations (multi-threading, multiple requests)
- Review database transaction handling

**Fix Pattern:**
```python
# Use locks or atomic operations
with threading.Lock():
    # Critical section
    pass
```

### Category 3: Configuration Issues

**Symptoms:**
- Works in one environment, fails in another
- Connection errors, timeouts

**Investigation:**
- Check environment variables
- Compare configurations between environments
- Verify default values are sensible

**Fix Pattern:**
```python
# Add validation, better defaults
value = os.getenv("CONFIG_VAR")
if not value:
    raise MLRunConfigurationError("CONFIG_VAR must be set")
```

### Category 4: Data Format/Type Issues

**Symptoms:**
- `TypeError`, `ValueError`
- Serialization errors

**Investigation:**
- Check data types at boundaries (API, database)
- Verify serialization/deserialization
- Look for implicit type conversions

**Fix Pattern:**
```python
# Add type validation
if not isinstance(value, str):
    raise TypeError(f"Expected str, got {type(value)}")
```

---

## Quick Checklist

### Bug Investigation
- [ ] Reproduced locally
- [ ] Root cause identified
- [ ] Affected versions determined
- [ ] Scope of impact assessed

### Fix Implementation
- [ ] Minimal, focused change
- [ ] Handles edge cases
- [ ] Adds proper validation
- [ ] Clear error messages

### Testing
- [ ] Test reproduces original bug
- [ ] Test verifies fix works
- [ ] Existing tests still pass
- [ ] Edge cases covered

### Documentation
- [ ] Jira ticket updated with findings
- [ ] PR description explains problem and solution
- [ ] Commit message references ticket
- [ ] Verification steps documented

---

**Last Updated**: 2025-11-20
**Refactored**: Now references PRE_COMMIT_WORKFLOW.md, PR_SUBMISSION_WORKFLOW.md, JIRA_UPDATE_PATTERN.md
**Size Reduction**: 522 lines → 350 lines (33% reduction)
