# Testing Standards

## Overview

This guide consolidates MLRun testing best practices from universal_principles.md, CONTRIBUTING.md, and proven patterns.

---

## Test Quality Principles

### 1. Concrete Assertions Over Existence Checks

**❌ Bad - Vague existence checks:**
```python
assert "endpoint_id" in result
assert len(results) > 0
assert hasattr(result, 'values')
```

**✅ Good - Exact expected values:**
```python
assert result["endpoint_id"] == "test_endpoint"
assert len(results) == 3
assert result.values == [0.1, 0.2, 0.3]
```

**Why**: Existence checks pass even when values are wrong. Concrete assertions catch actual bugs.

---

### 2. No Redundant Attribute Checks

**❌ Bad - Checking before immediate usage:**
```python
assert hasattr(result, 'values'), "Expected values attribute"
assert result.values == expected_values  # Uses .values immediately!
```

**✅ Good - Direct usage (AttributeError is clear enough):**
```python
assert result.values == expected_values
```

**Why**: If attribute is missing, AttributeError is self-explanatory. Extra check adds no value.

---

### 3. Direct Object Comparison When Possible

**❌ Bad - Field-by-field comparison:**
```python
assert actual_item.type == expected_item.type
assert actual_item.value == expected_item.value
assert actual_item.time == expected_item.time
```

**✅ Good - Compare objects directly:**
```python
expected_item = SomeClass(type='result', value=0.6, time=datetime(...))
assert result[0] == expected_item
```

**Why**: Cleaner, catches all fields automatically, easier to maintain.

---

### 4. Test Public API, Not Private Implementation

**❌ Bad - Mocking private properties:**
```python
with patch.object(store, "_storage_options", mock_options):
    result = store.method()
```

**✅ Good - Test through public interfaces:**
```python
store = AzureBlobStore(parent, schema="wasbs", endpoint="container@host", secrets=secrets)
result = store.get_spark_options()
assert result == expected_options
```

**Why**: Tests become brittle when tied to internal implementation. Public API tests survive refactoring.

---

### 5. Reference Test Data, Don't Hardcode Expected Values

**❌ Bad - Hardcoded magic values in assertions:**
```python
def test_get_metrics_with_data():
    test_metrics = [
        {
            "end_infer_time": datetime(2024, 1, 15, 12, 0, 0),
            "metric_name": "accuracy",
            "metric_value": 0.95,
        },
        {
            "end_infer_time": datetime(2024, 1, 15, 12, 5, 0),
            "metric_name": "precision",
            "metric_value": 0.87,
        }
    ]

    write_metrics(test_metrics)
    result = get_metrics()

    # Bad: Hardcoded values disconnected from test_metrics
    assert result[0].value == 0.95  # Magic number!
    assert "2024-01-15T12:00:00" in result[0].timestamp  # Hardcoded string!
    assert result[0].name == "accuracy"  # Duplicates test data
```

**✅ Good - Reference test data directly:**
```python
def test_get_metrics_with_data():
    test_metrics = [
        {
            "end_infer_time": datetime(2024, 1, 15, 12, 0, 0),
            "metric_name": "accuracy",
            "metric_value": 0.95,
        },
        {
            "end_infer_time": datetime(2024, 1, 15, 12, 5, 0),
            "metric_name": "precision",
            "metric_value": 0.87,
        }
    ]

    write_metrics(test_metrics)
    result = get_metrics()

    # Good: Assert result matches what we inserted
    assert result[0].value == test_metrics[0]["metric_value"]
    expected_time = test_metrics[0]["end_infer_time"]
    assert expected_time.strftime("%Y-%m-%dT%H:%M:%S") in result[0].timestamp
    assert result[0].name == test_metrics[0]["metric_name"]
```

**Why**:
- **Single Source of Truth**: Test data defined once, assertions derive from it
- **Maintainability**: Changing test data automatically updates all assertions
- **Self-Documenting**: `assert value == test_data[0]["expected"]` clearly shows "result matches what we inserted"
- **Prevents Copy-Paste Errors**: Can't accidentally hardcode wrong values in assertions
- **Easier Refactoring**: Update test data structure once, all assertions follow

**Pattern to follow:**
```python
# 1. Define test data
test_data = [...]

# 2. Execute operation
result = function_under_test(test_data)

# 3. Assert result matches test_data (not hardcoded values!)
assert result.field == test_data[0]["expected_field"]
```

---

## Test Structure

### Naming Conventions

**Test Files:**
```
tests/unit/module/test_<component>.py
tests/integration/test_<feature>_integration.py
tests/system/test_<end_to_end_flow>.py
```

**Test Functions:**
```python
def test_<what>_<condition>_<expected_result>():
    # Good examples:
    def test_create_endpoint_with_valid_data_returns_endpoint()
    def test_delete_endpoint_with_missing_id_raises_not_found()
    def test_list_endpoints_with_filters_returns_filtered_results()
```

**Test Classes:**
```python
class TestModelEndpointCRUD:
    def test_create_endpoint(self):
        pass

    def test_update_endpoint(self):
        pass
```

---

### Test Organization

**AAA Pattern - Arrange, Act, Assert:**
```python
def test_create_endpoint_stores_in_database():
    # Arrange - Set up test data and dependencies
    project_name = "test-project"
    endpoint_data = {"name": "test-endpoint", "model": "model-123"}
    db = MockDatabase()

    # Act - Execute the functionality being tested
    result = create_endpoint(project_name, endpoint_data, db)

    # Assert - Verify the expected outcome
    assert result.name == "test-endpoint"
    assert db.get_endpoint(result.id) is not None
```

**Use fixtures for shared setup:**
```python
@pytest.fixture
def sample_endpoint():
    return ModelEndpoint(
        id="test-123",
        name="test-endpoint",
        model="model-456"
    )

def test_update_endpoint(sample_endpoint):
    # Test uses pre-configured endpoint
    updated = update_endpoint(sample_endpoint, {"name": "new-name"})
    assert updated.name == "new-name"
```

---

## Unit Test Standards

### What to Unit Test

**✅ DO test:**
- Business logic and algorithms
- Data transformations
- Input validation
- Error handling
- Edge cases and boundary conditions
- Utility functions

**❌ DON'T unit test:**
- Framework code (e.g., SQLAlchemy internals)
- External libraries (assume they work)
- Trivial getters/setters
- Configuration files

### Mocking Guidelines

**Minimize mocks:**
```python
# ✅ Good - Real objects when possible
def test_endpoint_filter():
    endpoints = [
        ModelEndpoint(name="ep1", state="running"),
        ModelEndpoint(name="ep2", state="stopped")
    ]
    result = filter_endpoints(endpoints, state="running")
    assert len(result) == 1
```

**Mock external dependencies only:**
```python
# ✅ Good - Mock external HTTP call
@patch('requests.get')
def test_fetch_model_from_registry(mock_get):
    mock_get.return_value.json.return_value = {"model": "data"}
    result = fetch_model("model-123")
    assert result["model"] == "data"
```

**Don't mock what you're testing:**
```python
# ❌ Bad - Mocking the thing being tested
@patch.object(ModelEndpointStore, 'create')
def test_create_endpoint(mock_create):
    mock_create.return_value = ModelEndpoint(...)
    result = store.create(...)  # Not actually testing anything!
```

---

## Integration Test Standards

### Purpose
Test interaction between multiple components/modules that work together.

### Patterns

**Database Integration:**
```python
@pytest.mark.integration
def test_endpoint_crud_with_real_database(database_url):
    # Use real database connection
    store = ModelEndpointStore(database_url)

    # Create
    endpoint = store.create(ModelEndpoint(...))

    # Read
    retrieved = store.get(endpoint.id)
    assert retrieved.name == endpoint.name

    # Update
    updated = store.update(endpoint.id, {"name": "new"})
    assert updated.name == "new"

    # Delete
    store.delete(endpoint.id)
    assert store.get(endpoint.id) is None
```

**API Integration:**
```python
@pytest.mark.integration
def test_model_monitoring_pipeline(mlrun_client):
    # Test full pipeline: deploy → monitor → alert

    # Deploy model
    function = mlrun_client.deploy_model(...)

    # Send inference requests
    responses = function.invoke(test_data)

    # Verify monitoring data collected
    metrics = mlrun_client.get_metrics(function.endpoint_id)
    assert len(metrics) > 0
```

---

## System Test Standards

### Purpose
Test complete end-to-end workflows in production-like environment.

### Markers

```python
@TestMLRunSystem.skip_test_if_env_not_configured
@pytest.mark.enterprise  # Only if requires full Iguazio system
class TestModelMonitoringFlow(TestMLRunSystem):
    def test_complete_monitoring_workflow(self):
        # Full E2E test
        pass
```

### Best Practices

**Test realistic scenarios:**
```python
@TestMLRunSystem.skip_test_if_env_not_configured
class TestMLOpsWorkflow(TestMLRunSystem):
    def test_train_deploy_monitor_cycle(self):
        # 1. Train model
        train_run = self.project.run_function('trainer', inputs={...})
        model_uri = train_run.outputs['model']

        # 2. Deploy model
        serving_fn = self.project.deploy_function('serving', models=[model_uri])

        # 3. Send inference requests
        for data in test_dataset:
            serving_fn.invoke(data)

        # 4. Verify monitoring active
        endpoint = self.project.get_model_endpoint(serving_fn.status.endpoint_id)
        assert endpoint.state == "active"

        # 5. Check metrics collected
        metrics = endpoint.get_metrics()
        assert len(metrics) > 0
```

**Clean up resources:**
```python
class TestModelDeployment(TestMLRunSystem):
    def custom_setup(self):
        self.endpoints = []

    def custom_teardown(self):
        # Clean up all created endpoints
        for endpoint_id in self.endpoints:
            try:
                self.project.delete_model_endpoint(endpoint_id)
            except Exception:
                pass

    def test_deploy_model(self):
        endpoint = self.project.deploy_model(...)
        self.endpoints.append(endpoint.id)  # Track for cleanup
        assert endpoint.state == "ready"
```

---

## Test Coverage

### Coverage Goals

**Not about numbers:**
- ❌ "We need 80% coverage"
- ✅ "All critical paths and edge cases are tested"

**Quality over quantity:**
```python
# ❌ Bad - 100% coverage but meaningless
def test_endpoint_exists():
    endpoint = ModelEndpoint(...)
    assert endpoint is not None  # Useless test

# ✅ Good - Tests actual behavior
def test_endpoint_validate_rejects_invalid_state():
    endpoint = ModelEndpoint(state="invalid-state")
    with pytest.raises(ValueError, match="Invalid state"):
        endpoint.validate()
```

### What Must Be Tested

**Critical paths:**
- Data write operations (create, update, delete)
- Authentication and authorization
- Data validation and sanitization
- Error handling for external dependencies
- Business logic and calculations

**Edge cases:**
- Empty inputs
- Null/None values
- Boundary conditions (min/max values)
- Concurrent operations
- Large datasets

---

## Testing Patterns

### Testing Exceptions

```python
# ✅ Good - Specific exception and message
def test_create_endpoint_with_duplicate_name_raises_conflict():
    store.create(ModelEndpoint(name="duplicate"))

    with pytest.raises(ConflictError, match="Endpoint.*already exists"):
        store.create(ModelEndpoint(name="duplicate"))
```

### Testing Async Code

```python
@pytest.mark.asyncio
async def test_async_endpoint_creation():
    endpoint = await async_create_endpoint(...)
    assert endpoint.state == "ready"
```

### Parameterized Tests

```python
@pytest.mark.parametrize("state,expected", [
    ("running", True),
    ("stopped", False),
    ("error", False),
])
def test_endpoint_is_active(state, expected):
    endpoint = ModelEndpoint(state=state)
    assert endpoint.is_active() == expected
```

### Testing with Temporary Files

```python
def test_save_model_creates_file(tmp_path):
    model_path = tmp_path / "model.pkl"
    save_model(model, str(model_path))

    assert model_path.exists()
    assert model_path.stat().st_size > 0
```

---

## Test Data Management

### Test Fixtures

**Use realistic data:**
```python
@pytest.fixture
def sample_model_endpoint():
    """Representative model endpoint for testing."""
    return ModelEndpoint(
        id="test-endpoint-123",
        project="default",
        name="fraud-detection-v1",
        model_uri="store://models/fraud-detection:latest",
        function_uri="default/fraud-detector:latest",
        state="ready",
        labels={"team": "ml-ops", "env": "prod"}
    )
```

**Factory functions for variations:**
```python
def create_test_endpoint(**overrides):
    """Create test endpoint with optional overrides."""
    defaults = {
        "id": f"test-{uuid.uuid4()}",
        "name": "test-endpoint",
        "state": "ready"
    }
    return ModelEndpoint(**(defaults | overrides))

# Usage
running_endpoint = create_test_endpoint(state="running")
failed_endpoint = create_test_endpoint(state="error", error_message="OOM")
```

---

## Performance Testing

### When to Add Performance Tests

- Database queries handling large datasets
- Batch operations
- Data processing pipelines
- API endpoints under load

### Example

```python
import time

def test_list_endpoints_performance_with_large_dataset():
    # Create 10,000 endpoints
    endpoints = [create_test_endpoint() for _ in range(10000)]
    store.bulk_create(endpoints)

    # Measure query time
    start = time.time()
    results = store.list_endpoints(limit=100)
    duration = time.time() - start

    # Should complete in under 1 second
    assert duration < 1.0
    assert len(results) == 100
```

---

## Common Testing Mistakes

### ❌ Testing Implementation Details

```python
# Bad - Test is brittle, breaks with refactoring
def test_endpoint_uses_cache():
    store._cache = {}  # Accessing private attribute
    store.get_endpoint("123")
    assert "123" in store._cache  # Testing internal state
```

### ❌ Tests That Don't Test Anything

```python
# Bad - Will never fail
def test_create_endpoint():
    endpoint = ModelEndpoint()
    assert endpoint is not None  # Always true
```

### ❌ Flaky Tests

```python
# Bad - Depends on timing, fails randomly
def test_async_processing():
    submit_job()
    time.sleep(1)  # Race condition!
    assert job_completed()  # May or may not be done
```

### ❌ Tests with Side Effects

```python
# Bad - Modifies shared state
def test_update_global_config():
    mlrun.mlconf.some_setting = "test-value"
    # Affects other tests!
```

---

## Quick Reference

### Test Checklist

Before submitting PR with tests:
- [ ] Tests use concrete assertions (exact values)
- [ ] No redundant attribute checks
- [ ] Tests use public API, not private internals
- [ ] **Assertions reference test data, not hardcoded values**
- [ ] Test names clearly describe what's tested
- [ ] Edge cases covered
- [ ] Error cases tested
- [ ] Tests are independent (can run in any order)
- [ ] No hardcoded values that will break later
- [ ] Cleanup happens in teardown or fixtures
- [ ] `make test` passes locally

### Coverage Analysis

```bash
# Run with coverage
pytest --cov=mlrun --cov-report=html tests/

# View report
open htmlcov/index.html

# Focus on uncovered lines, not percentage
```

### Test Commands

```bash
# Unit tests
make test

# Integration tests
make test-integration

# Specific test file
pytest tests/unit/test_endpoint.py

# Specific test
pytest tests/unit/test_endpoint.py::test_create_endpoint

# With verbose output
pytest -v tests/

# Stop on first failure
pytest -x tests/

# Run in parallel (faster)
pytest -n auto tests/
```

---

**Last Updated**: 2025-11-17
**Reference**: universal_principles.md, CONTRIBUTING.md
**Latest Addition**: Principle 5 - Reference Test Data (from PR #8903 review feedback)
