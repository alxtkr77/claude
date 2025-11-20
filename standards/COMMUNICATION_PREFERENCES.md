# Communication Preferences

## Git & GitHub - No Non-ASCII Characters

**CRITICAL**: Do NOT use non-ASCII characters in git commits or GitHub PR/review responses.

### Prohibited in Git/GitHub

- Emoji: ✅ ❌ ⚠️ 🚨 📝 🔗 etc.
- Special symbols: ✓ ✗ → ← ▼ ▲ etc.
- Unicode decorations: ┌ ─ └ │ etc.

### Where This Applies

1. **Git commit messages** - All commit messages must be ASCII-only
2. **GitHub PR review comments** - All review responses and comments
3. **GitHub PR descriptions** - PR title and body
4. **GitHub issue comments** - All issue discussions

### Use Instead

```markdown
# Instead of emoji in git/GitHub:
✅ → [DONE] or [OK] or PASS or Applied
❌ → [FAIL] or [ERROR] or NO
⚠️ → [WARNING] or NOTE
🚨 → [CRITICAL] or IMPORTANT
📝 → [DESCRIPTION] or SUMMARY
🔗 → [LINK] or REF

# Instead of Unicode arrows:
→ → "->" or "=>"
← → "<-" or "<="
```

### Examples

**Bad (Non-ASCII in git commit)**:
```bash
git commit -m "✅ Applied review feedback - Use rstrip() for cleaner code"
```

**Good (ASCII only)**:
```bash
git commit -m "[Automation] Use rstrip() for cleaner trailing slash removal

Address review feedback from liranbg to use rstrip('/') instead of
endswith() check for removing trailing slashes from registry URLs.

Reference: ML-11462"
```

**Bad (Non-ASCII in PR review comment)**:
```markdown
✅ Applied! Changed to use `rstrip("/")` for both registries.
```

**Good (ASCII only)**:
```markdown
Applied! Changed to use `rstrip("/")` for both registries. Much cleaner - thanks for the suggestion!
```

### Rationale

- Git logs viewed in terminal must display correctly
- GitHub web interface sometimes has font rendering issues
- Copy-paste from commits/PRs may corrupt non-ASCII characters
- Standard practice in many open source projects
- Better compatibility across different systems and locales

## Status Indicators

```markdown
# Use plain text status markers:
[OK]       - Success
[FAIL]     - Failure
[SKIP]     - Skipped
[WARN]     - Warning
[INFO]     - Information
[DONE]     - Completed
[PENDING]  - In progress
[BLOCKED]  - Blocked

# Or use words:
PASS / FAIL
YES / NO
SUCCESS / ERROR
COMPLETED / INCOMPLETE
```

## Lists and Structure

```markdown
# Use standard markdown lists:
- Item 1
- Item 2
  - Nested item

# Or numbered lists:
1. First step
2. Second step
   a. Sub-step

# Tables use standard markdown:
| Column 1 | Column 2 |
|----------|----------|
| Data     | More     |
```

## Examples

### Bad (Non-ASCII)
```
✅ PR Review Completed
❌ Tests failed
→ Next step: deploy
```

### Good (ASCII Only)
```
[DONE] PR Review Completed
[FAIL] Tests failed
NEXT: Deploy to production
```

---

**Last Updated**: 2025-11-13
**Applies To**: All communication, responses, summaries, and documentation
