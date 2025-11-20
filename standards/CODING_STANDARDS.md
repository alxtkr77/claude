# MLRun Coding Standards

## Python Style Guide

### Naming Conventions

**Variables and Functions**
```python
# ✅ Good - snake_case
endpoint_id = "test-123"
model_endpoint = get_endpoint(endpoint_id)

def calculate_drift_score(baseline, current):
    pass

# ❌ Bad - camelCase (not Python convention)
endpointId = "test-123"
modelEndpoint = getEndpoint(endpointId)
```

**Classes**
```python
# ✅ Good - CamelCase
class ModelEndpoint:
    pass

class TimescaleDBConnector:
    pass

# ❌ Bad - snake_case for classes
class model_endpoint:
    pass
```

**Constants**
```python
# ✅ Good - SCREAMING_SNAKE_CASE
MAX_RETRY_ATTEMPTS = 3
DEFAULT_BATCH_SIZE = 100
MODEL_ENDPOINT_STATE_READY = "ready"

# ❌ Bad - lowercase constants
max_retry_attempts = 3
```

**Private Methods**
```python
class EndpointManager:
    def get_endpoint(self, id):
        """Public method."""
        return self._fetch_from_db(id)

    def _fetch_from_db(self, id):
        """Private helper - single underscore prefix."""
        pass
```

---

## Import Organization

### Order of Imports

```python
# 1. Standard library imports
import os
import sys
from datetime import datetime
from typing import Dict, List, Optional

# 2. Third-party imports
import pandas as pd
import numpy as np
from sqlalchemy import Column, Integer, String

# 3. Local application imports (use 'import' not 'from...import')
import mlrun.config
import mlrun.errors
import mlrun.model_monitoring.api
```

### Import Style

**External Packages - Use `from...import`**
```python
# ✅ Good for third-party
from pandas import DataFrame
from sqlalchemy import create_engine
```

**MLRun Modules - Use `import`**
```python
# ✅ Good - prevents circular imports
import mlrun.errors
import mlrun.model_monitoring.api

# Use with full path
raise mlrun.errors.MLRunNotFoundError("Endpoint not found")
result = mlrun.model_monitoring.api.get_endpoint(...)

# ❌ Bad - can cause circular imports
from mlrun.errors import MLRunNotFoundError
from mlrun.model_monitoring.api import get_endpoint
```

---

## Type Hints

### When to Use Type Hints

**Always:**
- Public API functions
- Functions with complex parameters
- Return types that aren't obvious

**Optional:**
- Simple utility functions where types are obvious
- Internal implementation details

### Examples

```python
from typing import Dict, List, Optional, Union

# ✅ Good - clear parameter and return types
def get_endpoint(
    project: str,
    endpoint_id: str,
    include_metrics: bool = False
) -> Optional[Dict[str, Any]]:
    """Get model endpoint by ID."""
    pass

# ✅ Good - complex types documented
def batch_process(
    endpoints: List[Dict[str, Any]],
    filters: Optional[Dict[str, Union[str, int]]] = None
) -> pd.DataFrame:
    pass

# ❌ Bad - no hints on complex function
def process_data(data, config, options):
    pass
```

---

## Error Handling

### MLRun Error Types

```python
import mlrun.errors

# Use appropriate MLRun error types
raise mlrun.errors.MLRunNotFoundError(f"Endpoint {endpoint_id} not found")
raise mlrun.errors.MLRunInvalidArgumentError("Invalid state value")
raise mlrun.errors.MLRunRuntimeError("Failed to connect to database")
raise mlrun.errors.MLRunConflictError("Endpoint already exists")
```

### Error Message Guidelines

```python
# ✅ Good - specific, actionable
raise ValueError(
    f"Invalid interval '{interval}'. "
    f"Must be one of: {', '.join(VALID_INTERVALS)}"
)

# ❌ Bad - vague
raise ValueError("Bad interval")
```

### Error Conversion

```python
import mlrun.errors

# ✅ Good - convert errors safely
try:
    result = risky_operation()
except Exception as e:
    logger.error("Operation failed", error=mlrun.errors.err_to_str(e))
    raise

# ❌ Bad - str() can fail or leak sensitive info
except Exception as e:
    logger.error(f"Operation failed: {str(e)}")
```

---

## Logging

### MLRun Logging Standards

```python
import mlrun.utils

logger = mlrun.utils.logger.create_logger(level="INFO", name="my-module")

# ✅ Good - structured logging with context
logger.info("Endpoint created", endpoint_id=endpoint_id, project=project)
logger.debug("Query executed", query=query[:100], duration_ms=duration)
logger.error("Database error", error=mlrun.errors.err_to_str(e), endpoint_id=endpoint_id)

# ❌ Bad - string formatting loses structure
logger.info(f"Endpoint {endpoint_id} created in {project}")
logger.debug(f"Query: {query}, Duration: {duration}ms")
```

### What to Log

**DO Log:**
- ✅ Operation start/complete with context
- ✅ Important state changes
- ✅ Error conditions with context
- ✅ Performance metrics (DEBUG level)

**DON'T Log:**
- ❌ Sensitive data (passwords, tokens, PII)
- ❌ Large objects (full DataFrames, big JSON)
- ❌ Every loop iteration
- ❌ Debug statements in production code paths

---

## Configuration Access

### Use mlrun.mlconf

```python
import mlrun

# ✅ Good - use mlrun.mlconf
connection_string = mlrun.mlconf.model_endpoint_monitoring.tsdb_connection
batch_size = mlrun.mlconf.model_endpoint_monitoring.batch_size

# ❌ Bad - direct config access
from mlrun.config import config
connection_string = config.model_endpoint_monitoring.tsdb_connection
```

---

## String Formatting

### Use f-strings (Python 3.6+)

```python
# ✅ Good - f-strings (readable, fast)
message = f"Endpoint {endpoint_id} in project {project} is {state}"
query = f"SELECT * FROM {table} WHERE id = {id}"

# ❌ Bad - .format() is verbose
message = "Endpoint {} in project {} is {}".format(endpoint_id, project, state)

# ❌ Bad - % formatting is outdated
message = "Endpoint %s in project %s is %s" % (endpoint_id, project, state)
```

### Exception: Templates and SQL

```python
# ✅ Good - use placeholders for SQL (security)
query = "SELECT * FROM %(table)s WHERE name = %(name)s"
params = {"table": table_name, "name": endpoint_name}

# ✅ Good - multi-line strings with .format() for readability
template = """
Project: {project}
Endpoint: {endpoint}
State: {state}
""".format(project=project, endpoint=endpoint, state=state)
```

---

## Docstrings

### Format (Google Style)

```python
def get_endpoint_metrics(
    endpoint_id: str,
    start_time: datetime,
    end_time: datetime,
    metric_names: Optional[List[str]] = None
) -> pd.DataFrame:
    """Get metrics for a model endpoint in a time range.

    Args:
        endpoint_id: Unique identifier of the model endpoint
        start_time: Start of time range (inclusive)
        end_time: End of time range (inclusive)
        metric_names: Optional list of specific metrics to fetch.
                     If None, fetches all metrics.

    Returns:
        DataFrame with columns: timestamp, metric_name, value

    Raises:
        MLRunNotFoundError: If endpoint does not exist
        MLRunInvalidArgumentError: If time range is invalid

    Example:
        >>> metrics = get_endpoint_metrics(
        ...     "endpoint-123",
        ...     datetime(2024, 1, 1),
        ...     datetime(2024, 1, 31)
        ... )
    """
    pass
```

### When Docstrings Are Required

**Required:**
- Public API functions
- Classes (class-level docstring)
- Complex algorithms

**Optional:**
- Private helper functions (if logic is complex)
- Simple getters/setters

---

## Function Length Guidelines

### Keep Functions Short

```python
# ✅ Good - focused, single purpose
def validate_endpoint_state(state: str) -> None:
    """Validate endpoint state is valid."""
    if state not in VALID_STATES:
        raise ValueError(f"Invalid state: {state}")

def get_endpoint(endpoint_id: str) -> ModelEndpoint:
    """Get endpoint by ID."""
    endpoint = db.get(endpoint_id)
    if not endpoint:
        raise MLRunNotFoundError(f"Endpoint {endpoint_id} not found")
    return endpoint

# ❌ Bad - doing too much
def validate_and_get_endpoint_with_metrics(endpoint_id, state, start, end):
    # 100 lines of mixed validation, fetching, processing...
    pass
```

**Guidelines:**
- Target: 10-20 lines per function
- Maximum: 50 lines (consider refactoring if longer)
- If > 50 lines, extract helpers

---

## Class Design

### Single Responsibility

```python
# ✅ Good - focused classes
class EndpointStore:
    """Handles endpoint persistence."""
    def create(self, endpoint): pass
    def get(self, id): pass
    def list(self, filters): pass
    def update(self, id, updates): pass
    def delete(self, id): pass

class EndpointValidator:
    """Validates endpoint data."""
    def validate_state(self, state): pass
    def validate_uri(self, uri): pass

class MetricsCollector:
    """Collects endpoint metrics."""
    def collect(self, endpoint_id): pass
    def aggregate(self, metrics): pass

# ❌ Bad - god class doing everything
class EndpointManager:
    def create(self): pass
    def get(self): pass
    def validate(self): pass
    def collect_metrics(self): pass
    def send_alerts(self): pass
    def generate_reports(self): pass
    # 50 more methods...
```

---

## Common Patterns

### Context Managers for Resources

```python
# ✅ Good - ensures cleanup
with TimescaleDBConnection(dsn) as conn:
    result = conn.query("SELECT * FROM endpoints")
    # Connection closed automatically

# ✅ Good - custom context manager
class DatabaseTransaction:
    def __enter__(self):
        self.conn = connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            self.conn.rollback()
        else:
            self.conn.commit()
        self.conn.close()
```

### Early Returns

```python
# ✅ Good - early returns reduce nesting
def process_endpoint(endpoint):
    if not endpoint:
        return None

    if endpoint.state != "ready":
        logger.warning("Endpoint not ready", endpoint_id=endpoint.id)
        return None

    return _execute_processing(endpoint)

# ❌ Bad - deep nesting
def process_endpoint(endpoint):
    if endpoint:
        if endpoint.state == "ready":
            return _execute_processing(endpoint)
        else:
            logger.warning(f"Endpoint not ready: {endpoint.id}")
            return None
    else:
        return None
```

### Factory Pattern for Object Creation

```python
# ✅ Good - factory for different implementations
class ConnectorFactory:
    _connectors = {
        "timescaledb": TimescaleDBConnector,
        "tdengine": TDEngineConnector,
        "v3io": V3IOConnector,
    }

    @classmethod
    def create(cls, connector_type: str, **kwargs):
        connector_class = cls._connectors.get(connector_type)
        if not connector_class:
            raise ValueError(f"Unknown connector: {connector_type}")
        return connector_class(**kwargs)
```

---

## Anti-Patterns to Avoid

### Don't Use Mutable Default Arguments

```python
# ❌ Bad - mutable default
def add_metric(metrics=[]):
    metrics.append("new")
    return metrics

# ✅ Good - use None and create inside
def add_metric(metrics=None):
    if metrics is None:
        metrics = []
    metrics.append("new")
    return metrics
```

### Don't Catch and Ignore All Exceptions

```python
# ❌ Bad - swallows all errors
try:
    result = operation()
except:
    pass

# ✅ Good - specific exceptions, log errors
try:
    result = operation()
except (ConnectionError, TimeoutError) as e:
    logger.error("Connection failed", error=mlrun.errors.err_to_str(e))
    raise
```

### Don't Use Global Variables

```python
# ❌ Bad - global state
endpoint_cache = {}

def get_endpoint(id):
    if id in endpoint_cache:
        return endpoint_cache[id]
    # ...

# ✅ Good - pass state explicitly or use class
class EndpointManager:
    def __init__(self):
        self._cache = {}

    def get_endpoint(self, id):
        if id in self._cache:
            return self._cache[id]
        # ...
```

---

## Quick Reference Checklist

Before committing code:
- [ ] Follows naming conventions (snake_case, CamelCase)
- [ ] Imports organized correctly (stdlib, third-party, local)
- [ ] Type hints for public APIs
- [ ] Uses mlrun.errors for exceptions
- [ ] Structured logging (no f-strings in logger)
- [ ] Uses mlrun.mlconf for configuration
- [ ] Docstrings for public functions
- [ ] Functions < 50 lines
- [ ] No mutable default arguments
- [ ] Resources cleaned up (context managers)
- [ ] No hardcoded values (use constants or config)

---

**Last Updated**: 2025-11-10
**Reference**: MLRun CONTRIBUTING.md, Python PEP 8, MLRun codebase conventions
