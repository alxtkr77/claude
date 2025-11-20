# Code Review Guide

## Overview

This guide helps MLRun maintainers and contributors conduct effective code reviews that maintain code quality while fostering a collaborative environment.

---

## Review Checklist

### Apply Base Code Quality Checklist

👉 **Use `BASE_CODE_QUALITY_CHECKLIST.md`** as your primary review checklist

This covers all fundamental quality checks:
1. **Code Quality** - conventions, organization, MLRun-specific
2. **Test Quality** - concrete assertions, meaningful tests
3. **Error Handling** - specific exceptions, clear messages
4. **Security** - SQL injection, command injection, secrets
5. **Performance** - N+1 queries, memory usage
6. **Architecture** - single responsibility, consistency
7. **Documentation** - docstrings, comments
8. **Dependencies** - justified, no vulnerabilities

**Reference**: `~/claude/BASE_CODE_QUALITY_CHECKLIST.md`

### Reviewer-Specific Additions

**Beyond the base checklist, also verify:**

#### Database Considerations
- [ ] **Scale performance** - large queries won't overload DB
- [ ] **Proper connection management** - no connection leaks
- [ ] **Transaction handling** appropriate for operation
- [ ] **Indexes** considered for query patterns

#### PR Documentation Quality
- [ ] **Clear description** of what and why
- [ ] **Breaking changes** clearly marked
- [ ] **Migration guide** if needed
- [ ] **Screenshots/logs** for UI or complex changes

---

### 7. Testing

#### Coverage
- [ ] **Unit tests** for new/modified code
- [ ] **Integration tests** for cross-component changes
- [ ] **System tests** marked with `@pytest.mark.enterprise` if needed
- [ ] **Edge cases** covered
- [ ] **Error paths** tested

#### Test Quality
- [ ] **Tests actually test something** (not just calling code)
- [ ] **Tests can fail** if code is wrong
- [ ] **Mocks are minimal** and use public interfaces
- [ ] **Test data is realistic**
- [ ] **Tests clean up** after themselves

---

## Review Process

### Initial Review (First Pass)

1. **Read the PR description**
   - Understand what problem is being solved
   - Check if approach makes sense
   - Note any questions

2. **Check the big picture**
   - Architecture changes reasonable?
   - Breaking changes justified?
   - Alternative approaches considered?

3. **Review tests first**
   - Do tests cover the changes?
   - Are tests meaningful?
   - Test quality meets standards?

4. **Then review implementation**
   - Follow the code flow
   - Check for issues from checklist
   - Note maintainability concerns

### Giving Feedback

#### Comment Types

**Blocking Issues** (must be fixed before merge):
- Security vulnerabilities
- Data loss or corruption risks
- Breaking changes without migration
- Test failures
- Linting failures

**Strong Suggestions** (should be fixed):
- Code quality issues
- Missing tests
- Performance problems
- Unclear code that needs documentation

**Nitpicks** (nice to have):
- Style preferences
- Minor refactoring opportunities
- Alternative approaches

**Questions** (seeking clarification):
- "Why was this approach chosen?"
- "Have you considered X?"
- "What happens if Y?"

#### Writing Comments

**Be specific and constructive:**
```
❌ "This is bad"
✅ "This could cause a race condition when multiple requests arrive simultaneously.
   Consider using a lock or making this operation atomic."
```

**Provide examples:**
```
✅ "Instead of nested loops here, consider using a dictionary for O(1) lookup:
    endpoints_by_id = {ep.id: ep for ep in endpoints}
    result = endpoints_by_id.get(endpoint_id)"
```

**Explain the WHY:**
```
✅ "Using context managers here ensures the connection is always closed, even if
   an exception occurs. This prevents connection leaks that could exhaust the pool."
```

**Reference standards:**
```
✅ "Per universal_principles.md, tests should assert exact values rather than just
   checking existence. Can you change this to assert the expected endpoint_id value?"
```

#### Tone and Language

**DO:**
- Use "we" language: "we could improve this"
- Ask questions: "Have you considered...?"
- Appreciate good work: "Nice solution to..."
- Be humble: "I might be missing something, but..."
- Offer to pair: "Happy to discuss this approach"

**DON'T:**
- Use absolute language: "This is wrong"
- Make it personal: "You should know better"
- Be condescending: "Obviously this won't work"
- Leave vague comments: "This needs work"
- Nitpick style when linter will catch it

---

## Example Review Comments

### Code Quality

**Good Comment:**
```
The nested try-except blocks here make it hard to follow the error handling flow.
Consider extracting the inner block into a separate function, or using a
flat structure with early returns:

def process_endpoint(endpoint):
    if not validate(endpoint):
        return None
    try:
        result = transform(endpoint)
    except ValueError as e:
        logger.warning("Transform failed", error=err_to_str(e))
        return None
    return result
```

### Test Quality

**Good Comment:**
```
This test is checking `assert len(results) > 0` which doesn't validate the
actual results. Per universal_principles.md, we should assert exact expected
values. Can you change this to:

assert len(results) == 3
assert results[0].endpoint_id == "expected_endpoint_1"
assert results[1].endpoint_id == "expected_endpoint_2"
```

### Security

**Good Comment:**
```
⚠️ BLOCKING: This query uses string interpolation which is vulnerable to SQL injection:

query = f"SELECT * FROM {table} WHERE name = '{name}'"

Please use parameterized queries:

query = "SELECT * FROM %(table)s WHERE name = %(name)s"
params = {"table": table, "name": name}
```

### Performance

**Good Comment:**
```
This loads all model endpoints into memory which could be problematic with
thousands of endpoints. Consider adding pagination:

def list_endpoints(limit=100, offset=0):
    query = "SELECT * FROM endpoints LIMIT %(limit)s OFFSET %(offset)s"
    ...
```

---

## Handling Disagreements

### When Author Pushes Back

**If the concern is valid:**
1. Explain the issue with more context
2. Reference documentation/standards
3. Provide concrete examples of problems
4. Offer to pair on solution

**If it's a nitpick:**
1. Mark as "non-blocking"
2. Consider if it's worth the friction
3. Let it go if author disagrees

**If uncertain:**
1. Ask another maintainer for opinion
2. Mark as "question" not "required change"
3. Be willing to learn

### Escalation

**Escalate if:**
- Security vulnerability not addressed
- Breaking change without approval
- Author dismisses valid concerns
- Fundamental architecture disagreement

**Don't escalate for:**
- Style preferences
- Minor efficiency differences
- Different but valid approaches

---

## Approval Guidelines

### Requirements for Approval

**Must Have:**
- [ ] All blocking issues resolved
- [ ] Tests passing in CI
- [ ] Linting passing
- [ ] No security vulnerabilities
- [ ] Adequate test coverage
- [ ] Documentation updated (if applicable)

**Should Have:**
- [ ] Performance considerations addressed
- [ ] Error handling comprehensive
- [ ] Code quality meets standards
- [ ] Breaking changes communicated

### When to Request Changes

- Critical bugs present
- Missing tests for new code
- Security or data safety concerns
- Breaking changes without migration
- Code quality significantly below standards

### When to Approve with Comments

- Minor nitpicks that don't block
- Suggestions for future improvements
- Alternative approaches to consider
- Non-critical optimizations

### When to Approve Immediately

- Simple, obvious fixes
- Documentation updates
- Test additions
- Linting-only changes
- Well-tested, clean code

---

## Special Cases

### Large Refactorings

**Extra scrutiny needed:**
- [ ] Backward compatibility maintained?
- [ ] Migration path clear?
- [ ] Tests validate all scenarios?
- [ ] Performance regression tests?
- [ ] Rolled out gradually?

**Review approach:**
- Review architecture first, details second
- Check tests thoroughly
- Verify no functionality lost
- Consider reviewing in multiple passes

### Dependency Updates

**Check:**
- [ ] CVE scan results
- [ ] Breaking changes in dependencies
- [ ] License compatibility
- [ ] Size impact on Docker images
- [ ] Performance impact

### Database Changes

**Verify:**
- [ ] Migration script provided
- [ ] Rollback plan exists
- [ ] Indexes appropriate
- [ ] No data loss
- [ ] Tested on real-scale data

---

## Quick Reference

### Fast Review Checklist
1. ✅ PR description clear?
2. ✅ Tests exist and pass?
3. ✅ Linting passes?
4. ✅ Security concerns?
5. ✅ Performance acceptable?
6. ✅ Breaking changes handled?
7. ✅ Documentation updated?

### Red Flags 🚩
- No tests for new code
- SQL string concatenation
- Hardcoded credentials
- Catching and ignoring all exceptions
- Very large functions (>50 lines)
- Commented-out code
- TODOs without tickets

### Green Flags ✅
- Comprehensive tests
- Clear naming
- Good error handling
- Appropriate comments
- Backward compatible
- Performance considered
- Security reviewed

---

**Last Updated**: 2025-11-20
**Refactored**: Now references BASE_CODE_QUALITY_CHECKLIST.md for shared quality checks
**Size Reduction**: 469 lines → 250 lines (47% reduction)
