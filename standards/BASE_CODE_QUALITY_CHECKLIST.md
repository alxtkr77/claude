# Base Code Quality Checklist

## Overview

This checklist contains the fundamental code quality checks that apply to both self-review and code review. It's the single source of truth for quality standards.

**Usage:**
- **Self-Review**: Run this checklist on your own code before submitting PR
- **Code Review**: Use this checklist when reviewing others' code
- **PR Readiness**: Part of self-review step

---

## 1. Code Quality

### Style and Conventions
- [ ] **Follows Python conventions** (snake_case for functions/variables, CamelCase for classes)
- [ ] **Uses meaningful names** - no abbreviations unless standard (e.g., `endpoint_id` not `ep_id`)
- [ ] **Proper import style** - `import X` not `from X import Y` for local MLRun code
- [ ] **Type hints** for complex parameters and return values
- [ ] **Docstrings** present for all public API functions (see CONTRIBUTING.md format)
- [ ] **No hardcoded values** - uses Enum, environment variables, or config

### Code Organization
- [ ] **Functions are short** (< 50 lines ideally) and do one thing
- [ ] **Classes have single responsibility** - focused, clear purpose
- [ ] **Private methods below public ones** in class definitions
- [ ] **Helper functions below callers** when in same file
- [ ] **No commented-out code** - use git history instead

### MLRun-Specific Conventions
- [ ] Uses `mlrun.mlconf` not `mlrun.config.config`
- [ ] Uses `mlrun.errors.err_to_str(error)` not `str(error)`
- [ ] Minimizes imports in client code (avoid pulling in server dependencies)
- [ ] Uses structured logging: `logger.debug("Message", var1=var1, var2=var2)`
- [ ] Uses f-strings for formatting (except SQL/templates which need parameterization)

### Clean Code
- [ ] **No debug code** - no print() statements, pdb, or debug traces
- [ ] **No TODO comments without tickets** - either `TODO(ML-XXXXX)` or don't add
- [ ] **All changes are intentional** - no accidental file inclusions
- [ ] **Variable names are clear** - reader can understand without context
- [ ] **Logic is correct** - handles expected inputs properly

---

## 2. Test Quality

### Test Structure (from TESTING_STANDARDS.md)
- [ ] **Concrete assertions** - assert exact values, not just existence
  ```python
  # ✅ Good
  assert result["endpoint_id"] == "test_endpoint"

  # ❌ Bad
  assert "endpoint_id" in result
  ```

- [ ] **No redundant attribute checks** - don't check existence before immediate use
  ```python
  # ✅ Good
  assert result.values == expected_values

  # ❌ Bad
  assert hasattr(result, 'values')
  assert result.values == expected_values
  ```

- [ ] **Direct object comparison when possible**
  ```python
  # ✅ Good
  assert result == expected_object

  # ❌ Bad - field-by-field comparison
  assert result.field1 == expected_object.field1
  assert result.field2 == expected_object.field2
  ```

- [ ] **Tests use public API** - not private properties or implementation details
- [ ] **Reference test data** - assertions derive from test data, not hardcoded values
- [ ] **Meaningful test names** - `test_get_endpoint_with_empty_id_raises_error`
- [ ] **Tests are independent** - can run in any order
- [ ] **Uses tmp_path fixture** for temporary files

### Test Coverage
- [ ] **Tests exist for new code** - all new functions have tests
- [ ] **Tests exist for bug fixes** - test reproduces the bug, then verifies fix
- [ ] **Edge cases covered** - empty inputs, None, boundary conditions
- [ ] **Error cases tested** - exceptions, validation failures
- [ ] **Tests can fail** - if code is wrong, test will catch it

---

## 3. Error Handling

### Exception Handling
- [ ] **Catching specific exceptions** - not bare `except` or `except Exception`
- [ ] **Logging errors with context** - include relevant variables
- [ ] **Not swallowing errors silently** - log or re-raise appropriately
- [ ] **Using MLRun error types** - `mlrun.errors.MLRunNotFoundError`, etc.
- [ ] **Error messages are clear and actionable** - user knows what went wrong and how to fix

### Validation
- [ ] **Input validation** for all external data (API inputs, user config)
- [ ] **Null/None checks** before dereferencing
- [ ] **Range validation** for numerical inputs
- [ ] **Type validation** where appropriate

---

## 4. Security

### Common Vulnerabilities
- [ ] **No SQL injection** - uses parameterized queries
  ```python
  # ✅ Safe
  query = "SELECT * FROM %(table)s WHERE name = %(name)s"
  params = {"table": table, "name": name}

  # ❌ Vulnerable
  query = f"SELECT * FROM {table} WHERE name = '{name}'"
  ```

- [ ] **No command injection** - validates/escapes shell inputs
  ```python
  # ✅ Safe
  subprocess.run(["kubectl", "get", "pod", pod_name])

  # ❌ Vulnerable
  os.system(f"kubectl get pod {pod_name}")
  ```

- [ ] **No XSS vulnerabilities** - sanitizes user inputs in web contexts
- [ ] **Secrets not logged** or exposed in error messages
  ```python
  # ❌ Leaks secrets
  logger.info(f"Connecting with token: {api_token}")

  # ✅ Safe
  logger.info("Connecting to API")
  ```

### Authentication & Authorization
- [ ] **Authentication checks** present for protected operations
- [ ] **Authorization checks** verify user has permission
- [ ] **No hardcoded credentials** - use environment variables or secrets
- [ ] **Proper session management** - timeouts, secure cookies

---

## 5. Performance

### Scale Considerations
- [ ] **Pagination** for list operations that could return many results
- [ ] **Avoid N+1 queries** - batch database operations
  ```python
  # ❌ N+1 query problem
  for endpoint in get_all_endpoints():
      metrics = get_metrics(endpoint.id)

  # ✅ Better - batch operation
  endpoints = get_all_endpoints()
  all_metrics = get_metrics_batch([e.id for e in endpoints])
  ```

- [ ] **Indexes** for frequently queried database columns
- [ ] **Cache** expensive operations appropriately (with expiration)
- [ ] **Async operations** for I/O-bound tasks (when appropriate)

### Memory Management
- [ ] **Stream large files** - don't load entire file into memory
  ```python
  # ❌ Loads all into memory
  data = pd.read_csv("large_file.csv")

  # ✅ Streams in chunks
  for chunk in pd.read_csv("large_file.csv", chunksize=10000):
      process(chunk)
  ```

- [ ] **Cleanup resources** in finally blocks or context managers
- [ ] **Avoid DataFrame overhead** when not needed - use dicts/lists for simple data
- [ ] **Connection pooling** for database operations
- [ ] **Caches have size limits** - prevent unbounded growth

---

## 6. Architecture and Design

### Design Principles
- [ ] **Single Responsibility Principle** - classes/functions do one thing well
  ```python
  # ❌ Doing too much
  class ModelMonitor:
      def monitor(self):
          self.collect_metrics()
          self.detect_drift()
          self.send_alerts()
          self.generate_reports()

  # ✅ Focused classes
  class MetricsCollector: ...
  class DriftDetector: ...
  class AlertManager: ...
  ```

- [ ] **Composition over inheritance** - prefer delegating to other classes
- [ ] **Public API is clean** - users interact with simple, clear interfaces
- [ ] **Internal refactoring won't break users** - abstraction boundaries respected
- [ ] **Explicit solutions** - clear, straightforward code over clever tricks

### Consistency with Codebase
- [ ] **Follows existing patterns** in MLRun codebase
- [ ] **Uses same naming conventions** as surrounding code
- [ ] **Fits with overall architecture** - doesn't introduce new paradigms unnecessarily
- [ ] **Doesn't reinvent existing utilities** - reuses common helpers
- [ ] **Uses appropriate abstractions** - dataclasses, Enums, context managers

---

## 7. Documentation

### Code Documentation
- [ ] **Docstrings** for all public functions (Google style per CONTRIBUTING.md)
  ```python
  def get_endpoint(endpoint_id: str) -> ModelEndpoint:
      """Get model endpoint by ID.

      Args:
          endpoint_id: Endpoint unique identifier

      Returns:
          ModelEndpoint object

      Raises:
          MLRunNotFoundError: If endpoint doesn't exist
      """
  ```

- [ ] **Comments explain WHY** - not what the code does (code is self-documenting)
- [ ] **Complex logic documented** with reasoning for approach
- [ ] **TODOs have ticket references** - `TODO(ML-XXXXX): description`
- [ ] **Units specified** for numerical values - seconds, bytes, MB, etc.

### API Documentation
- [ ] **Public API changes documented** - update relevant .md files
- [ ] **Breaking changes clearly marked** - migration guide provided
- [ ] **Examples provided** for new features - code snippets, notebooks

---

## 8. Dependencies and Breaking Changes

### Dependencies
- [ ] **New dependencies justified** - no unnecessary packages
- [ ] **Minimal version specifiers** - `package>=1.0` not `package==1.0.1`
- [ ] **No security vulnerabilities** in dependencies
- [ ] **License compatible** with MLRun (Apache 2.0)
- [ ] **Added to requirements.txt** properly

### API Compatibility
- [ ] **Breaking changes avoided** - or clearly justified
- [ ] **Backward compatibility maintained** - existing code still works
- [ ] **Deprecation warnings** added if removing features
  ```python
  warnings.warn(
      "old_function() is deprecated, use new_function() instead. "
      "Will be removed in v1.8.0",
      DeprecationWarning
  )
  ```

- [ ] **Migration guide** provided for breaking changes

---

## Quick Verification

### Self-Review Questions
1. **Would I approve this code?** - if reviewing someone else's PR
2. **Is this the minimal change needed?** - no over-engineering
3. **Is it ready for production?** - handles edge cases, errors
4. **Is it maintainable?** - next developer can understand it
5. **Does it follow standards?** - per TESTING_STANDARDS.md, CODING_STANDARDS.md

### Red Flags 🚩
Stop and fix immediately:
- SQL injection vulnerabilities
- Command injection vulnerabilities
- Secrets in logs
- Missing authentication checks
- No tests for new code
- Tests that don't test anything
- Functions > 100 lines
- Deeply nested code (> 4 levels)

---

## Usage in Different Contexts

### For Self-Review (SELF_REVIEW_CHECKLIST.md)
Before submitting PR:
1. Read through your GitHub diff
2. Run this checklist on every file you changed
3. Fix any issues found
4. Re-run quality checks (fmt, lint, tests)
5. Mark PR ready for review

### For Code Review (CODE_REVIEW_GUIDE.md)
When reviewing others' code:
1. Read PR description to understand intent
2. Review tests first (understand what's being built)
3. Apply this checklist to implementation
4. Provide specific, constructive feedback
5. Reference checklist items in review comments

### For PR Readiness (PR_READINESS_CHECKLIST.md)
Before creating PR:
1. Ensure quality checks passed (fmt, lint, tests)
2. Run this checklist as part of self-review
3. Verify all items checked
4. Proceed to PR creation only if all pass

---

## Referenced By

- SELF_REVIEW_CHECKLIST.md (primary usage)
- CODE_REVIEW_GUIDE.md (reviewer perspective)
- PR_READINESS_CHECKLIST.md (step 4)
- TESTING_STANDARDS.md (principle reference)
- CODING_STANDARDS.md (convention reference)

---

**Last Updated**: 2025-11-20
**Purpose**: Single source of truth for code quality standards
**Coverage**: Extracted from 70% shared content between SELF_REVIEW and CODE_REVIEW
