# Requirements Validation Checklist

## Overview

Use this checklist to validate that your implementation meets all requirements before submitting for review. This ensures completeness and reduces back-and-forth during code review.

---

## Step 1: Understand the Requirements

### From Jira Ticket

**Read the ticket thoroughly:**
- [ ] **Summary** - What is the high-level goal?
- [ ] **Description** - What specific functionality is needed?
- [ ] **Acceptance Criteria** - What must be true for this to be complete?
- [ ] **Edge Cases** - Are there specific scenarios to handle?
- [ ] **Non-Functional Requirements** - Performance, security, compatibility?

### Clarify Ambiguities

**If anything is unclear, ask in the ticket:**
```markdown
@ticket-author I have a few questions before starting:

1. For the "validation" requirement, should this be blocking or just warnings?
2. What should happen if validation fails - return error or skip the record?
3. Are there performance requirements? (e.g., must handle 10k records/sec)

This will help ensure I implement exactly what's needed.
```

---

## Step 2: Functional Requirements Validation

### Core Functionality

**For each acceptance criterion:**
- [ ] Implemented as described
- [ ] Tested with provided examples
- [ ] Edge cases handled
- [ ] Error cases handled

**Example:**
```
Requirement: "System should validate endpoint_id is not empty"

Validation:
✅ Validation logic implemented
✅ Test case: test_validate_empty_endpoint_id_raises_error
✅ Edge case: None, "", whitespace all caught
✅ Error: Raises MLRunInvalidArgumentError with clear message
```

### Input/Output Contract

**Verify:**
- [ ] All required parameters accepted
- [ ] Optional parameters with documented defaults
- [ ] Return type matches specification
- [ ] Error conditions documented

**Example:**
```python
def get_endpoint(
    project: str,           # ✅ Required parameter
    endpoint_id: str,       # ✅ Required parameter
    include_metrics: bool = False  # ✅ Optional with default
) -> ModelEndpoint:         # ✅ Return type specified
    """
    Returns:
        ModelEndpoint object

    Raises:                 # ✅ Error conditions documented
        MLRunNotFoundError: If endpoint not found
        MLRunInvalidArgumentError: If parameters invalid
    """
```

### Data Validation

**Check that all inputs are validated:**
- [ ] Required fields present
- [ ] Types correct
- [ ] Ranges valid
- [ ] Format valid (e.g., URLs, dates)
- [ ] Business rules enforced

**Example validation checklist:**
```python
# Requirement: "Validate endpoint configuration"

def validate_endpoint(endpoint):
    # ✅ Required fields
    if not endpoint.name:
        raise ValueError("name is required")

    # ✅ Type validation
    if not isinstance(endpoint.replicas, int):
        raise TypeError("replicas must be int")

    # ✅ Range validation
    if endpoint.replicas < 1 or endpoint.replicas > 10:
        raise ValueError("replicas must be 1-10")

    # ✅ Format validation
    if not endpoint.model_uri.startswith(("s3://", "store://")):
        raise ValueError("model_uri must be s3:// or store:// URL")

    # ✅ Business rules
    if endpoint.state == "production" and not endpoint.monitoring_enabled:
        raise ValueError("production endpoints must have monitoring enabled")
```

---

## Step 3: Non-Functional Requirements

### Performance Requirements

**If ticket specifies performance:**
- [ ] Measured actual performance
- [ ] Meets or exceeds requirement
- [ ] Optimized critical paths
- [ ] Added performance tests (if applicable)

**Example:**
```
Requirement: "List endpoints should handle 10,000 endpoints in <1 second"

Validation:
✅ Measured: 850ms for 10,000 endpoints
✅ Optimized: Added database index on commonly filtered fields
✅ Test: test_list_endpoints_performance_large_dataset
✅ Documented: Performance notes in PR description
```

### Scalability Requirements

**Check:**
- [ ] No N+1 query problems
- [ ] Batch operations used where appropriate
- [ ] Pagination implemented for lists
- [ ] Resources cleaned up (connections, files)
- [ ] No memory leaks

### Security Requirements

**Security checklist:**
- [ ] No SQL injection vulnerabilities
- [ ] No command injection vulnerabilities
- [ ] Input sanitization for external data
- [ ] Authentication checks (if applicable)
- [ ] Authorization checks (if applicable)
- [ ] Secrets not logged or exposed
- [ ] Error messages don't leak sensitive info

**Example:**
```python
# Requirement: "Allow filtering endpoints by project"

# ❌ SQL injection vulnerable
query = f"SELECT * FROM endpoints WHERE project = '{project}'"

# ✅ Safe - parameterized query
query = "SELECT * FROM endpoints WHERE project = %(project)s"
params = {"project": project}
```

### Backward Compatibility

**If modifying existing API:**
- [ ] Existing code still works
- [ ] New parameters are optional
- [ ] Default behavior unchanged
- [ ] Deprecation warnings added (if applicable)
- [ ] Migration guide provided (if breaking)

**Example:**
```python
# Requirement: "Add metrics to endpoint API"

# ✅ Backward compatible - new parameter optional
def get_endpoint(
    endpoint_id: str,
    include_metrics: bool = False  # Default False = old behavior
) -> ModelEndpoint:
    endpoint = _fetch_endpoint(endpoint_id)

    if include_metrics:
        endpoint.metrics = _fetch_metrics(endpoint_id)  # New functionality

    return endpoint
```

---

## Step 4: Test Coverage Validation

### Test Types Required

**For each requirement:**
- [ ] Unit test - Tests the core logic
- [ ] Integration test (if multi-component) - Tests components together
- [ ] System test (if end-to-end) - Tests full workflow

### Test Quality Checks

**From TESTING_STANDARDS.md:**
- [ ] Tests use concrete assertions (exact values, not just existence)
- [ ] Tests are meaningful (can fail if code is wrong)
- [ ] Edge cases covered
- [ ] Error cases covered
- [ ] Tests are independent
- [ ] Tests use public API

**Example requirement validation:**
```
Requirement: "Validate endpoint state transitions"

Unit Tests:
✅ test_transition_pending_to_ready - Valid transition
✅ test_transition_ready_to_running - Valid transition
✅ test_transition_running_to_error - Valid transition
✅ test_invalid_transition_raises_error - Invalid transition blocked
✅ test_unknown_state_raises_error - Unknown state rejected

Edge Cases:
✅ test_transition_from_none_state - Handles missing state
✅ test_transition_to_same_state - Idempotent

Error Cases:
✅ test_transition_with_empty_state - Clear error message
✅ test_transition_error_message_clarity - Error explains valid states
```

---

## Step 5: Documentation Validation

### Code Documentation

- [ ] Docstrings for public functions
- [ ] Type hints on complex parameters
- [ ] Comments explain WHY for complex logic
- [ ] Examples in docstrings (for complex APIs)

**Example:**
```python
def calculate_drift_score(
    baseline: pd.DataFrame,
    current: pd.DataFrame,
    method: str = "ks_test"
) -> float:
    """Calculate data drift score between baseline and current data.

    Compares feature distributions to detect drift. Higher scores
    indicate more drift.

    Args:
        baseline: Historical data to compare against
        current: Recent data to check for drift
        method: Statistical method - "ks_test", "psi", or "chi_square"

    Returns:
        Drift score from 0.0 (no drift) to 1.0 (complete drift)

    Raises:
        ValueError: If DataFrames have different columns
        ValueError: If method is not supported

    Example:
        >>> baseline = pd.DataFrame({"feature": [1, 2, 3, 4, 5]})
        >>> current = pd.DataFrame({"feature": [5, 6, 7, 8, 9]})
        >>> score = calculate_drift_score(baseline, current)
        >>> print(f"Drift: {score:.2f}")
        Drift: 0.85
    """
```

### User Documentation

**If adding user-facing features:**
- [ ] README updated
- [ ] API docs updated
- [ ] Examples provided
- [ ] Migration guide (if breaking changes)

---

## Step 6: Error Handling Validation

### Error Scenarios

**For each possible failure:**
- [ ] Error is caught
- [ ] Appropriate error type raised
- [ ] Error message is clear and actionable
- [ ] Error is logged with context
- [ ] Test case exists

**Example error handling validation:**
```python
# Requirement: "Get endpoint by ID"

# Possible errors to handle:
# 1. ✅ Endpoint not found
def test_get_nonexistent_endpoint_raises_not_found():
    with pytest.raises(MLRunNotFoundError, match="Endpoint.*not found"):
        store.get_endpoint("nonexistent-id")

# 2. ✅ Empty ID
def test_get_endpoint_empty_id_raises_invalid_argument():
    with pytest.raises(MLRunInvalidArgumentError, match="endpoint_id cannot be empty"):
        store.get_endpoint("")

# 3. ✅ Database connection error
def test_get_endpoint_db_error_propagates():
    with patch.object(store, "_db") as mock_db:
        mock_db.get.side_effect = ConnectionError("DB unavailable")
        with pytest.raises(MLRunRuntimeError, match="Failed to connect"):
            store.get_endpoint("test-id")

# 4. ✅ Invalid project permission
def test_get_endpoint_no_permission_raises_forbidden():
    with pytest.raises(MLRunForbiddenError, match="No permission"):
        store.get_endpoint("test-id", user=unauthorized_user)
```

---

## Step 7: Integration Points Validation

### External Dependencies

**For each external system:**
- [ ] Connection tested
- [ ] Timeouts configured
- [ ] Retries implemented (if appropriate)
- [ ] Errors handled gracefully
- [ ] Fallback behavior defined

**Example:**
```python
# Requirement: "Fetch model from external registry"

def fetch_model(model_uri: str) -> bytes:
    """Fetch model from registry with retry and timeout."""
    # ✅ Timeout configured
    # ✅ Retry logic
    # ✅ Error handling
    for attempt in range(3):
        try:
            response = requests.get(
                model_uri,
                timeout=30  # ✅ Timeout
            )
            response.raise_for_status()
            return response.content
        except requests.Timeout:
            if attempt == 2:
                raise MLRunRuntimeError(f"Timeout fetching model from {model_uri}")
            time.sleep(2 ** attempt)  # ✅ Exponential backoff
        except requests.HTTPError as e:
            if e.response.status_code == 404:
                raise MLRunNotFoundError(f"Model not found: {model_uri}")
            raise MLRunRuntimeError(f"Failed to fetch model: {e}")
```

### Database Operations

**For database changes:**
- [ ] Migrations created (if schema changes)
- [ ] Indexes added for query patterns
- [ ] Transactions used appropriately
- [ ] Connection pooling configured
- [ ] Tested with realistic data volumes

---

## Step 8: Configuration Validation

### Configuration Options

**If adding configurable behavior:**
- [ ] Configuration option added to `mlconf`
- [ ] Default value is sensible
- [ ] Documented in code and user docs
- [ ] Validated at startup
- [ ] Tested with different configurations

**Example:**
```python
# Requirement: "Make batch size configurable"

# ✅ Added to mlconf
mlrun.mlconf.model_endpoint_monitoring.batch_size = 100  # Default

# ✅ Validation
def validate_config():
    batch_size = mlrun.mlconf.model_endpoint_monitoring.batch_size
    if batch_size < 1 or batch_size > 10000:
        raise ValueError("batch_size must be between 1 and 10000")

# ✅ Used in code
def process_batch():
    batch_size = mlrun.mlconf.model_endpoint_monitoring.batch_size
    # Use batch_size...

# ✅ Test with different values
def test_process_with_custom_batch_size():
    with patch.object(mlrun.mlconf.model_endpoint_monitoring, "batch_size", 50):
        result = process_batch()
        assert len(result) == 50
```

---

## Step 9: Complete Requirements Checklist

### Create a Checklist in Your PR

**Example:**
```markdown
## Requirements Validation

**Functional Requirements:**
- [x] Endpoint validation logic implemented
- [x] Handles all edge cases (empty, None, invalid format)
- [x] Returns appropriate error types
- [x] All acceptance criteria met

**Non-Functional Requirements:**
- [x] Performance: <100ms for typical requests (measured 45ms avg)
- [x] Security: Input sanitization, no SQL injection
- [x] Backward compatibility: Existing API unchanged

**Testing:**
- [x] Unit tests: 15 tests covering all scenarios
- [x] Integration tests: 3 tests for database operations
- [x] Edge cases: 6 tests for boundary conditions
- [x] Error cases: 8 tests for failure scenarios
- [x] Coverage: 98% on new code

**Documentation:**
- [x] Docstrings on all public functions
- [x] Type hints on complex parameters
- [x] Comments on complex logic
- [x] README updated with new feature
- [x] API docs updated

**Error Handling:**
- [x] All failure scenarios tested
- [x] Clear error messages
- [x] Appropriate error types
- [x] Logging with context

**Integration:**
- [x] Database operations tested
- [x] External dependencies mocked in tests
- [x] Timeouts configured
- [x] Retry logic implemented

**Configuration:**
- [x] Configurable via mlconf
- [x] Sensible defaults
- [x] Documented
- [x] Validated at startup
```

---

## Quick Validation Commands

### Run Before Submitting

```bash
# 1. All tests pass
make test

# 2. Linting passes
make fmt
make lint

# 3. Check coverage
pytest --cov=mlrun --cov-report=html tests/
# Open htmlcov/index.html - ensure new code is covered

# 4. Security check
# Manually review for SQL injection, command injection, secrets

# 5. Performance check (if applicable)
# Run performance tests or benchmarks

# 6. Integration check (if applicable)
make test-integration
```

---

## Red Flags

### Stop and Fix These

🚩 **Missing Test Coverage**
- Core functionality not tested
- Edge cases not covered
- Error cases not tested

🚩 **Security Issues**
- SQL injection vulnerability
- Command injection vulnerability
- Secrets exposed

🚩 **Incomplete Implementation**
- Acceptance criteria not met
- Edge cases not handled
- Error messages unclear

🚩 **Breaking Changes Without Migration**
- Existing API changed
- No backward compatibility
- No migration guide

🚩 **Poor Error Handling**
- Errors swallowed
- Generic error messages
- No logging

---

## Final Validation

**Before marking PR as ready:**

1. **Re-read the ticket** - Does your implementation match?
2. **Check acceptance criteria** - All met?
3. **Run full test suite** - Everything passes?
4. **Review PR diff** - Would you approve this?
5. **Test manually** - Works as expected?

**Ask yourself:**
- ❓ Would this work in production?
- ❓ Can I confidently demo this to the product owner?
- ❓ Have I tested all the scenarios from the ticket?
- ❓ Are error messages helpful to users?
- ❓ Is the code maintainable?

If you answered "yes" to all - you're ready to submit!

---

**Last Updated**: 2025-11-10
**Reference**: MLRun development standards, Jira workflow
