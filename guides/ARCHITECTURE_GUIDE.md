# MLRun Architecture Guide

## Core Architecture Principles

### From Universal Principles

1. **Explicit Solutions Over Clever Tricks**
   - Direct, obvious approaches preferred
   - Code should tell its story
   - Avoid "sneaky" encoding or workarounds

2. **Focused Classes Over Monolithic**
   - Single clear responsibility per class
   - Target classes that tell their purpose from name
   - Break large classes into focused components

3. **Composition + Utilities Over Inheritance**
   - Extract common logic to utilities
   - Compose focused classes
   - Minimize deep inheritance hierarchies

4. **Public API Testing Over Private Implementation**
   - Test through public interfaces
   - Internal refactoring shouldn't break tests
   - Focus on behavior, not implementation

---

## MLRun Component Architecture

### High-Level Structure

```
mlrun/
├── api/                    # REST API layer
│   ├── endpoints/         # API route definitions
│   ├── crud/              # Database operations
│   └── schemas/           # Request/response models
├── db/                     # Database abstractions
│   ├── base.py            # Abstract base interfaces
│   └── sqldb/             # SQL implementation
├── runtimes/              # Function execution runtimes
│   ├── base.py            # Base runtime
│   ├── kubejob.py         # Kubernetes jobs
│   └── serving.py         # Serving runtime
├── model_monitoring/      # Model monitoring system
│   ├── api/               # Monitoring API
│   ├── db/                # Monitoring database layer
│   └── applications/      # Monitoring apps
├── feature_store/         # Feature store
│   ├── api.py             # Feature store API
│   ├── feature_set.py     # Feature set management
│   └── retrieval/         # Feature retrieval
└── datastore/             # Data access layer
    ├── base.py            # Abstract datastore
    ├── s3.py              # S3 implementation
    └── v3io.py            # V3IO implementation
```

---

## Design Patterns

### 1. Repository Pattern

**Used in**: Database layer, feature store

**Pattern**:
```python
class BaseRepository(ABC):
    @abstractmethod
    def create(self, entity): pass

    @abstractmethod
    def get(self, id): pass

    @abstractmethod
    def list(self, filters): pass

    @abstractmethod
    def update(self, id, updates): pass

    @abstractmethod
    def delete(self, id): pass
```

**Implementation**:
```python
class SQLModelEndpointStore(BaseRepository):
    def create(self, endpoint):
        session = self._get_session()
        db_endpoint = self._entity_to_db(endpoint)
        session.add(db_endpoint)
        session.commit()
        return self._db_to_entity(db_endpoint)
```

---

### 2. Strategy Pattern

**Used in**: Runtimes, datastores, monitoring databases

**Pattern**:
```python
class Runtime(ABC):
    @abstractmethod
    def run(self, task): pass

    @abstractmethod
    def deploy(self, **kwargs): pass

# Concrete strategies
class KubejobRuntime(Runtime): ...
class DaskRuntime(Runtime): ...
class SparkRuntime(Runtime): ...
```

---

### 3. Builder Pattern

**Used in**: Query construction, configuration

**Pattern**:
```python
class QueryBuilder:
    def __init__(self):
        self._query = {}

    def with_filter(self, field, value):
        self._query.setdefault('filters', {})[field] = value
        return self

    def with_limit(self, limit):
        self._query['limit'] = limit
        return self

    def build(self):
        return self._query

# Usage
query = (QueryBuilder()
    .with_filter('state', 'running')
    .with_limit(100)
    .build())
```

---

### 4. Factory Pattern

**Used in**: Runtime creation, datastore initialization

**Pattern**:
```python
class RuntimeFactory:
    _runtimes = {
        'job': KubejobRuntime,
        'dask': DaskRuntime,
        'spark': SparkRuntime,
    }

    @classmethod
    def create(cls, kind, **kwargs):
        runtime_class = cls._runtimes.get(kind)
        if not runtime_class:
            raise ValueError(f"Unknown runtime: {kind}")
        return runtime_class(**kwargs)
```

---

## Database Architecture

### TimescaleDB for Model Monitoring

**Why TimescaleDB:**
- Time-series optimization for metrics
- Continuous aggregates for pre-computed queries
- PostgreSQL compatibility

**Architecture**:
```
TimescaleDBConnector
├── TimescaleDBConnection        # Connection pooling
├── TimescaleDBOperationsManager # Table/schema management
├── TimescaleDBStreamProcessor   # Streaming writes
├── TimescaleDBQueryHandler      # Query execution
│   ├── TimescaleDBMetricsQueries
│   ├── TimescaleDBPredictionsQueries
│   └── TimescaleDBResultsQueries
└── Utils
    ├── TimescaleDBQueryBuilder
    ├── TimescaleDBDataFrameProcessor
    └── TimescaleDBPreAggregateManager
```

**Key Patterns**:
- **Mixin composition** for query handlers
- **Pre-aggregate with fallback** for performance
- **Connection pooling** for scalability

---

### V3IO for Enterprise Features

**Why V3IO:**
- High-performance data layer
- Real-time ingestion
- Multi-model database

**Architecture**:
- Frames for DataFrames
- KV for key-value ops
- Streaming for real-time data

---

## Streaming Architecture

### Model Monitoring Streaming Pipeline

**Components**:
```
Inference Request
    ↓
[Nuclio Function]
    ↓
[Model Monitoring Stream]
    ├→ [Metrics Processor]
    ├→ [Predictions Logger]
    └→ [Monitoring Apps]
        ↓
    [TSDB Target] → TimescaleDB
```

**Implementation Pattern**:
```python
graph = function.set_topology("flow")

graph.to("Metrics", handler=process_metrics)\
     .to("Logger", handler=log_predictions)\
     .to("DB", class_name="TSDBTarget", **tsdb_config)
```

---

## API Layer Architecture

### REST API Design

**Structure**:
```
/api/v1/projects/{project}/
    /functions/
        GET     - List functions
        POST    - Create function
        /{name}/
            GET    - Get function
            PATCH  - Update function
            DELETE - Delete function
    /model-endpoints/
        GET     - List endpoints
        POST    - Create endpoint
        /{id}/
            GET    - Get endpoint
            PATCH  - Update endpoint
            DELETE - Delete endpoint
```

**Layers**:
```
API Route (endpoints/)
    ↓
Business Logic (crud/)
    ↓
Database Layer (db/)
    ↓
Database
```

---

## Module Organization Rules

### Package Structure

**Good**:
```
feature_module/
├── __init__.py          # Public API exports
├── api.py               # High-level API
├── models.py            # Data models
├── operations.py        # Business logic
└── utils.py             # Utilities
```

**Bad**:
```
feature_module/
└── everything.py        # 5000 lines
```

### Import Guidelines

**Local imports** - Use `import` not `from ... import`:
```python
# ✅ Good
import mlrun.model_monitoring.api
result = mlrun.model_monitoring.api.create_endpoint(...)

# ❌ Bad (circular import risk)
from mlrun.model_monitoring.api import create_endpoint
```

**External imports** - `from ... import` is OK:
```python
# ✅ Good
from sqlalchemy import Column, Integer
import pandas as pd
```

---

## Common Anti-Patterns to Avoid

### 1. God Classes

**❌ Bad**:
```python
class ModelMonitoringHandler:  # 2000 lines
    def create_endpoint(self): ...
    def log_metrics(self): ...
    def calculate_drift(self): ...
    def send_alerts(self): ...
    def generate_reports(self): ...
    # 50 more methods...
```

**✅ Good**:
```python
class EndpointManager: ...      # CRUD operations
class MetricsCollector: ...     # Metrics collection
class DriftCalculator: ...      # Drift detection
class AlertManager: ...         # Alerting
class ReportGenerator: ...      # Reporting
```

---

### 2. Deep Inheritance

**❌ Bad**:
```python
class A: pass
class B(A): pass
class C(B): pass
class D(C): pass  # Hard to understand
```

**✅ Good**:
```python
class Base: pass
class Feature1Mixin: pass
class Feature2Mixin: pass
class Implementation(Base, Feature1Mixin, Feature2Mixin): pass
```

---

### 3. Tight Coupling

**❌ Bad**:
```python
class EndpointManager:
    def __init__(self):
        self.db = SQLDatabase()  # Hard dependency
        self.cache = RedisCache()  # Hard dependency
```

**✅ Good**:
```python
class EndpointManager:
    def __init__(self, db: BaseDatabase, cache: BaseCache):
        self.db = db  # Dependency injection
        self.cache = cache
```

---

## Database Connector Pattern

### When to Use Each Database

| Database | Use Case | Characteristics |
|----------|----------|-----------------|
| **TimescaleDB** | Time-series data (metrics, events) | PostgreSQL-compatible, continuous aggregates, performant for time-range queries |
| **TDEngine** | High-throughput time-series | Optimized for IoT/metrics at massive scale |
| **V3IO** | Enterprise real-time + historical | Multi-model, high performance, Iguazio-specific |
| **SQLite** | Unit tests only | In-memory, fast, SQL compatible |

### Database Connector Interface

```python
class TSDBConnector(ABC):
    @abstractmethod
    def create_tables(self, tables): pass

    @abstractmethod
    def write(self, table, data): pass

    @abstractmethod
    def read(self, table, start_time, end_time, filters): pass

# Implementations
class TimescaleDBConnector(TSDBConnector): ...
class TDEngineConnector(TSDBConnector): ...
class V3IOTSDBConnector(TSDBConnector): ...
```

---

## Performance Patterns

### 1. Connection Pooling

```python
from sqlalchemy.pool import QueuePool

engine = create_engine(
    connection_string,
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20
)
```

### 2. Batch Operations

```python
# ❌ Bad - N database calls
for item in items:
    db.create(item)

# ✅ Good - Single batch operation
db.bulk_create(items)
```

### 3. Caching Strategy

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def get_project_config(project_name):
    return db.get_project(project_name).config
```

### 4. Lazy Loading

```python
class Project:
    @property
    def functions(self):
        if not hasattr(self, '_functions'):
            self._functions = self._load_functions()
        return self._functions
```

---

## Security Architecture

### Authentication Layers

```
API Request
    ↓
[Authentication Middleware] → Verify token
    ↓
[Authorization Middleware] → Check permissions
    ↓
[API Handler] → Business logic
```

### Secret Management

```python
# ✅ Good - Use secrets manager
secrets = mlrun.get_secret_or_env("API_KEY")

# ❌ Bad - Hardcoded
API_KEY = "sk_1234..."  # NEVER DO THIS
```

---

## Testing Architecture

### Test Pyramid

```
        /\
       /  \   E2E Tests (few)
      /____\
     /      \  Integration Tests (some)
    /________\
   /          \ Unit Tests (many)
  /__________\
```

**Guidelines**:
- 70% Unit tests
- 20% Integration tests
- 10% System/E2E tests

---

## Migration Patterns

### Database Migrations

**Alembic for schema changes**:
```python
# migrations/versions/001_add_endpoint_state.py
def upgrade():
    op.add_column('model_endpoints',
        sa.Column('state', sa.String(50), nullable=False, server_default='unknown'))

def downgrade():
    op.drop_column('model_endpoints', 'state')
```

### API Versioning

```python
# /api/v1/endpoints  - Current
# /api/v2/endpoints  - New version with breaking changes

# Maintain v1 for N releases before deprecation
```

---

## Quick Reference

### When Adding New Features

1. **Choose the right layer**: API, business logic, or database?
2. **Check existing patterns**: Follow established conventions
3. **Keep classes focused**: Single responsibility
4. **Use composition**: Utilities + focused classes
5. **Test public API**: Don't test implementation details
6. **Document decisions**: Why, not just what

### Red Flags

- 🚩 File > 500 lines
- 🚩 Class > 10 methods
- 🚩 Function > 50 lines
- 🚩 Cyclic dependencies
- 🚩 Hardcoded values
- 🚩 No error handling

---

**Last Updated**: 2025-11-10
**Reference**: universal_principles.md, MLRun codebase patterns
