# Deprecation Removal Workflow

## Overview

Complete workflow for removing deprecated APIs in MLRun. MLRun follows a **2-release deprecation cycle**: APIs deprecated in version X.Y.0 are removed after 2 subsequent releases.

Example: APIs deprecated in 1.8.0 → removed in 1.11.0 (1.9.0 was skipped)

---

## Step 1: Understand the Deprecation Policy

**MLRun Deprecation Cycle: 2 Releases**
- **Release N**: Mark API as deprecated with warning
- **Release N+1**: Deprecation warning continues (1st release with warning)
- **Release N+2**: Deprecation warning continues (2nd release with warning)
- **Release N+3**: API removed

**Important Note**: Release 1.9.0 was skipped in MLRun's versioning, so the cycle appears as 3 versions but is still 2 releases.

**Example:**
```
1.8.0: @deprecated("Will be removed in 1.11.0")
1.9.0: [SKIPPED - never released]
1.10.0: Still present with warning (1st release after deprecation)
1.11.0: Removed ✂️ (2nd release after deprecation)
```

**General Formula:**
- Deprecated in **X.Y.0**
- Removed in **X.(Y+N).0** where N gives users 2 releases to migrate
- Typically N=2, but N=3 when a version is skipped (like 1.9.0)

---

## Step 2: Identify What to Remove

### A. Check Jira for Deprecation History

**Search Pattern:**
```
project = ML AND (
  summary ~ "deprecation" OR
  summary ~ "1.X.0" OR
  labels = deprecation
) ORDER BY created DESC
```

**Look for:**
- Parent deprecation epic (e.g., ML-11321: "[1.11.0] Deprecations")
- Previous deprecation stories (e.g., ML-10042 for 1.7.0 → 1.10.0)
- Related component stories

### B. Scan Codebase for Deprecation Markers

**Search for TODO comments:**
```bash
grep -r "TODO.*[Rr]emove.*1\.11" --include="*.py"
grep -r "remove.*in.*1\.11" --include="*.py"
```

**Search for deprecation warnings:**
```bash
grep -r "deprecated.*1\.8\.0.*removed.*1\.11" --include="*.py"
grep -r "@deprecated.*1\.11" --include="*.py"
grep -r "deprecated=True" --include="*.py"
```

**Search for specific patterns:**
```bash
# Function parameters
grep -r "deprecated=True" server/py/services/api/api/endpoints/

# Class methods
grep -r "@deprecated.deprecated" mlrun/

# Warnings
grep -r "warnings.warn.*deprecated" mlrun/
```

### C. Cross-Reference with Documentation

**Check changelog:**
```bash
# Look in docs/change-log/index.md for "Deprecated APIs" table
grep -A 50 "Will be removed.*v1.11.0" docs/change-log/index.md
```

**Example table structure:**
| Will be removed | Deprecated | API | Use instead |
|----------------|------------|-----|-------------|
| v1.11.0 | v1.8.0 | `get_cached_artifact` | `get_artifact` |

---

## Step 3: Categorize by Component

**Determine ownership:**
```bash
# Check CODEOWNERS file
cat .github/CODEOWNERS | grep -E "(data-flows|platform)"
```

**Common component categories:**
- **Data-Flows**: Model monitoring, serving, feature store, datastore
- **Platform**: Artifacts API, projects, runtimes, general SDK

**Create categorized list:**
```markdown
## Data-Flows Owned:
1. Model Monitoring: rebuild_images parameter
2. Serving: batch parameter in set_tracking()
3. Execution: get_cached_artifact() method

## Platform Owned:
1. Artifacts: limit parameter
2. Projects: remove_function() method
```

---

## Step 4: Verify No Internal Usage

**Check for internal usage:**
```bash
# Search for each deprecated API
grep -r "rebuild_images" --include="*.py" mlrun/
grep -r "get_cached_artifact" --include="*.py" mlrun/
grep -r "set_tracking.*batch" --include="*.py" mlrun/
```

**Check templates and configs:**
```bash
# Search in JSON/YAML/markdown files
grep -r "deprecated_api" --include="*.{json,yaml,yml,md}" docs/
grep -r "deprecated_api" --include="*.ipynb" examples/
```

**Common places to check:**
- Example notebooks (`examples/`)
- Documentation (`docs/`)
- Test fixtures (usually safe to keep for backward compat testing)
- Configuration templates

---

## Step 5: Create Deprecations Table for Jira

**Format as markdown table:**

```markdown
| Location | Old Way (Deprecated) | New Way (Replacement) |
|----------|---------------------|----------------------|
| `model_monitoring.enable_model_monitoring` | `rebuild_images=True` | DELETE then PUT pattern |
| `ServingRuntime.set_tracking()` | `batch=100` | Remove parameter |
| `MLClientCtx.get_cached_artifact()` | `context.get_cached_artifact(key)` | `context.get_artifact(key)` |
```

**Update Jira issue** with complete analysis.

---

## Step 6: Remove Deprecated Code

### A. API Endpoints (FastAPI)

**Pattern: Query parameter with deprecated alias**

```python
# BEFORE (deprecated)
endpoint_id_old: Optional[str] = Query(
    None,
    alias="endpoint_id",
    deprecated=True,
    description="'endpoint_id' deprecated in 1.8.0, removed in 1.11.0"
)
endpoint_id: Optional[str] = Query(None, alias="endpoint-id")

# Fallback logic
endpoint_id = endpoint_id or endpoint_id_old

# AFTER (removed)
endpoint_id: Optional[str] = Query(None, alias="endpoint-id")
# No fallback needed
```

### B. Function Parameters

**Pattern: Deprecated parameter with warning**

```python
# BEFORE (deprecated)
def set_tracking(
    self,
    stream_path: Optional[str] = None,
    batch: Optional[int] = None,  # ← Remove this
    sampling_percentage: float = 100,
):
    if batch:
        warnings.warn("batch deprecated in 1.8.0, removed in 1.11", FutureWarning)
    # ... rest of function

# AFTER (removed)
def set_tracking(
    self,
    stream_path: Optional[str] = None,
    sampling_percentage: float = 100,
):
    # ... rest of function (no warning needed)
```

**Update docstrings:**
```python
# Remove deprecated parameter from docstring
:param batch: Deprecated. Micro batch size.  # ← Remove this line
```

### C. Deprecated Methods

**Pattern: Method that wraps new method**

```python
# BEFORE (deprecated)
def get_cached_artifact(self, key):
    warnings.warn("deprecated in 1.8.0, removed in 1.11.0", FutureWarning)
    return self.get_artifact(key)

def get_artifact(self, key):
    # ... implementation

# AFTER (removed)
# Just delete get_cached_artifact() entirely
def get_artifact(self, key):
    # ... implementation
```

### D. Legacy Backward Compatibility Code

**Pattern: Version checking for old clients**

```python
# BEFORE (deprecated)
if client_version >= "1.8.0" or "unstable" in client_version:
    # New compressed format
    encoded_spec = base64.b64encode(gzip.compress(spec.encode()))
else:
    # Legacy uncompressed format for old clients
    encoded_spec = spec

# AFTER (removed)
# Always use new format (all clients must be >= 1.8.0)
encoded_spec = base64.b64encode(gzip.compress(spec.encode()))
```

### E. Update Documentation

**Update function signatures in docs:**
```markdown
<!-- BEFORE -->
fn.set_tracking(stream_path, batch, sample)

<!-- AFTER -->
fn.set_tracking(stream_path, sampling_percentage)
```

**Update parameter descriptions:**
```markdown
<!-- Remove deprecated parameter docs -->
* **batch** — optional, send micro-batches every N requests

<!-- Keep only current parameters -->
* **sampling_percentage** — down sampling percentage (e.g., 50 for 50%)
```

---

## Step 7: Verify Removals

### A. Check Unused Imports

**After removing deprecated code:**
```bash
# Run ruff to clean up unused imports
python -m ruff check --fix mlrun/ server/
```

**Common cleanup:**
```python
# May need to remove
import warnings  # If no longer used
import semver    # If version checking removed
```

### B. Run Tests

**Test categories to run:**
```bash
# Unit tests for modified files
pytest tests/api/api/test_model_endpoints.py -v
pytest tests/serving/test_tracking.py -v

# Integration tests (if applicable)
pytest tests/integration/ -k "model_monitoring"
```

**Verify no internal code broke:**
- All tests pass
- No import errors
- No AttributeErrors for removed methods

### C. Run Linting and Formatting

**Required before commit:**
```bash
# Format code
make fmt

# Check linting
make lint

# IMPORTANT: Commit ALL formatting changes
# Ruff may make subtle line-wrapping changes
git diff  # Review all changes
git add -A  # Stage everything
```

---

## Step 8: Create PR

**⚠️ MANDATORY: Before creating PR, run the PR Readiness Checklist:**
👉 **See: `~/claude/PR_READINESS_CHECKLIST.md`**

This ensures you don't forget: fmt, lint, tests, self-review, proper commit message.

### A. Prepare Commit

**Commit message format:**
```bash
git commit -m "[Deprecations] Remove 1.8.0 deprecations for 1.11.0 release

Remove deprecated APIs marked in 1.8.0 for removal in 1.11.0:
- rebuild_images parameter from model monitoring endpoint
- endpoint_id/feature_analysis snake_case parameters
- batch parameter from ServingRuntime.set_tracking()
- MLClientCtx.get_cached_artifact() method
- Legacy uncompressed serving spec handling

Reference: ML-11435"
```

### B. Create PR Using PR Template

**Use project's PR template** (reference: `~/claude/PR_TEMPLATE.txt`):
```bash
cat ~/claude/PR_TEMPLATE.txt
```

**Fill in template without empty sections:**
- ✅ Include all relevant sections
- ❌ Remove sections that don't apply (don't leave empty)
- ❌ Don't include Claude attribution
- ✅ Focus on technical changes and impact

**Key sections for deprecation removal:**
```markdown
### 📝 Description
Complete removal of APIs deprecated in 1.8.0 per MLRun's 2-release deprecation policy.

### 🛠️ Changes Made
- Removed rebuild_images parameter
- Removed snake_case query parameters
[... list all removals]

### 🚨 Breaking Changes?
- [x] Yes

| Old API (Removed) | New API (Use Instead) |
|-------------------|----------------------|
| ... | ... |

### 🧪 Testing
- ✅ All unit tests passing (X/X)
- ✅ Verified no internal usage
- ✅ Documentation updated
```

### C. Push and Create PR

```bash
# Push to fork
git push -u origin ML-XXXXX-deprecations

# Create PR to main repo
gh pr create \
  --repo mlrun/mlrun \
  --base development \
  --head yourusername:ML-XXXXX-deprecations \
  --title "[Deprecations] Remove 1.8.0 deprecations for 1.11.0 release" \
  --body "$(cat pr_description.md)"
```

---

## Step 9: Update Jira

**After PR creation:**

```python
# Add comment with PR link (use markdown format)
mcp__atlassian__addCommentToJiraIssue(
    cloudId="1374a6f1-f268-4a06-909e-b3a9675a9bd1",
    issueIdOrKey="ML-XXXXX",
    commentBody="""**PR Link**: [PR #XXXX](https://github.com/mlrun/mlrun/pull/XXXX)

All deprecation removals implemented and submitted for review.

**Summary:**
- ✅ Removed X deprecated APIs
- ✅ Updated documentation
- ✅ All tests passing (X/X)"""
)
```

---

## Common Gotchas

### 1. Formatting Changes Not Committed

**Problem:** CI fails with "Would reformat: file.py"

**Cause:** Ruff formatter makes subtle line-wrapping changes

**Fix:**
```bash
make fmt
git diff  # Review ALL changes
git add -A  # Stage everything including formatting
git commit --amend --no-edit
git push -f
```

### 2. Unused Imports

**Problem:** Linter complains about unused imports

**Fix:**
```bash
python -m ruff check --fix  # Auto-remove unused imports
git add -A
```

### 3. Documentation Out of Sync

**Check these locations:**
- Function docstrings
- `docs/` markdown files
- Example notebooks
- Changelog (intentionally documents the deprecation)

### 4. Test Fixtures Still Using Old API

**Usually OK:** Test fixtures can keep old formats for backward compatibility testing

**Action:** Review with team if unsure

---

## Checklist for Deprecation Removal

### Investigation Phase
- [ ] Searched Jira for deprecation history
- [ ] Scanned codebase for TODO comments
- [ ] Scanned codebase for deprecation warnings
- [ ] Checked changelog documentation
- [ ] Categorized by component ownership
- [ ] Created deprecations table for Jira

### Verification Phase
- [ ] Verified no internal code uses deprecated APIs
- [ ] Checked templates and configs
- [ ] Checked example notebooks
- [ ] Checked documentation files

### Implementation Phase
- [ ] Removed deprecated parameters
- [ ] Removed deprecated methods
- [ ] Removed backward compatibility code
- [ ] Updated docstrings
- [ ] Updated documentation files
- [ ] Removed unused imports

### Testing Phase
- [ ] All unit tests passing
- [ ] Integration tests passing (if applicable)
- [ ] Manual verification done
- [ ] Linting passes
- [ ] Formatting passes

### PR Phase
- [ ] Commit with clear message
- [ ] PR follows pr_template.txt format
- [ ] No empty sections in PR description
- [ ] Breaking changes clearly documented
- [ ] Migration guidance provided
- [ ] Jira issue updated with PR link

---

## Example: Complete Deprecation Removal

**Scenario:** Remove `batch` parameter from `set_tracking()` (deprecated in 1.8.0)

**1. Find deprecation:**
```bash
grep -r "batch.*deprecated" mlrun/runtimes/nuclio/serving.py
# Found: Line 374-380
```

**2. Verify no usage:**
```bash
grep -r "set_tracking.*batch" mlrun/ tests/ examples/
# Only found: documentation examples
```

**3. Remove code:**
```python
# Remove parameter
def set_tracking(
    stream_path: Optional[str] = None,
    # batch: Optional[int] = None,  ← Remove
    sampling_percentage: float = 100,
):
    # Remove warning
    # if batch:
    #     warnings.warn(...)  ← Remove
```

**4. Update docs:**
```markdown
<!-- Remove from docs/serving/custom-model-serving-class.md -->
- * **batch** — optional, send micro-batches  ← Remove
```

**5. Test:**
```bash
pytest tests/serving/test_tracking.py -v
# ✅ 57/57 passed
```

**6. Commit and PR:**
```bash
git add mlrun/runtimes/nuclio/serving.py docs/serving/custom-model-serving-class.md
git commit -m "[Serving] Remove batch parameter from set_tracking()"
```

---

**Last Updated**: 2025-11-13
**Reference**: ML-11435 implementation, MLRun deprecation policy
