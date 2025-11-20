# PR Response Guide

## Overview

This guide helps you respond effectively to code review feedback, whether you're addressing comments, pushing back on suggestions, or seeking clarification.

---

## General Principles

### Mindset
- 📖 **Reviews are learning opportunities**, not personal criticisms
- 🤝 **Reviewers want to help**, they invested time in your code
- 💡 **Questions are chances to improve** documentation or clarity
- 🎯 **Focus on code quality**, not ego
- ⏱️ **Respond promptly** - aim for same/next day

### Response Types
1. **Accept and implement** - Most common case
2. **Ask for clarification** - When comment is unclear
3. **Provide explanation** - When intent wasn't clear
4. **Discuss alternatives** - When there are trade-offs
5. **Push back respectfully** - When you have good reason

### Writing Responses

👉 **For PR comment replies**: Use `USER_EDIT_WORKFLOW.md` pattern
- Generate draft response → Edit in VSCode → Review → Post

---

## Responding to Different Comment Types

### 1. Blocking Issues (Security, Data Safety, Tests)

**DO:**
- ✅ Fix immediately
- ✅ Acknowledge the issue
- ✅ Explain fix in comment
- ✅ Thank reviewer for catching it

**Example Response:**
```markdown
Good catch! You're right - this could cause a SQL injection.

Fixed in commit abc123 by using parameterized queries:
query = "SELECT * FROM %(table)s WHERE name = %(name)s"
params = {"table": table, "name": name}

Thanks for reviewing this carefully!
```

### 2. Strong Suggestions (Code Quality, Performance)

**If you agree:**
```markdown
Great suggestion! I've refactored to use a dictionary lookup instead of nested loops.
This improves from O(n²) to O(n).

Updated in commit abc123.
```

**If you partially agree:**
```markdown
Good point about performance. I've added pagination (commit abc123), though I kept
the current approach for the in-memory filtering since our typical dataset is <100 items.

If you think we should optimize further, I can use a different data structure. Let me know!
```

**If unclear:**
```markdown
I'm not sure I follow - are you concerned about memory usage or query performance?
Could you elaborate on what specific issue you see?
```

### 3. Nitpicks and Style Preferences

**If it's easy to fix:**
```markdown
Done! ✅
```

**If it's a preference:**
```markdown
I see your point. I went with this approach because [reason], but I'm happy to change
it if you feel strongly. What do you think?
```

**If it's out of scope:**
```markdown
Agreed this could be improved. I've created ticket ML-12345 to track this as a
follow-up. For this PR, I'd like to keep the scope focused on [original goal].
```

### 4. Questions About Approach

**Provide context:**
```markdown
Great question! I chose this approach because:

1. The alternative (X) would require changes to Y, which is out of scope
2. This handles the edge case where Z
3. Performance testing showed this is 2x faster for our typical workload

Happy to discuss if you see issues with this approach!
```

**If approach is wrong, admit it:**
```markdown
You're right - I didn't consider that case. Let me rethink this approach.

I'll update with a better solution that handles [the case you mentioned].
```

---

## When to Push Back

### Valid Reasons to Push Back

✅ **Disagreement on standards**
```markdown
I understand your concern, but per CONTRIBUTING.md section 12, we use `import X`
not `from X import Y` for local imports. This is consistent with the rest of the codebase.
```

✅ **Out of scope for PR**
```markdown
I agree this would be valuable, but it's outside the scope of this PR which is
focused on [specific goal]. I've created ticket ML-12345 to track this improvement.

Would you be okay with addressing it in a follow-up?
```

✅ **Performance trade-off with justification**
```markdown
I considered that approach, but it would require loading all records into memory
which could be problematic with large datasets. The current approach streams results
and has acceptable performance for our use case (<100ms for typical queries).

If you're still concerned, I can add benchmarks to demonstrate.
```

✅ **Technical accuracy**
```markdown
Actually, TimescaleDB continuous aggregates require autocommit=True for the
refresh operation. This is documented in their official docs [link]. Without it,
the refresh fails with "cannot refresh in transaction" error.
```

### Invalid Reasons to Push Back

❌ **"I don't want to change it"**
❌ **"It works on my machine"**
❌ **"No one else complained"**
❌ **"I don't have time"**
❌ **"That's how we did it before"**

---

## Resolving Conversations

### When You've Addressed the Comment

**Clear resolution:**
```markdown
Fixed in commit abc123. Now using parameterized queries as suggested.

[Mark as resolved]
```

**With explanation:**
```markdown
Updated to use dictionary lookup (commit abc123). Performance improved from 5.2s to 0.3s
on test dataset of 10k records.

[Mark as resolved]
```

### When You Can't Fix It

**Out of scope:**
```markdown
Created follow-up ticket ML-12345 to track this. Keeping current implementation for
this PR to maintain scope.

[Request reviewer mark as resolved if acceptable]
```

**Won't fix:**
```markdown
After discussion, we're keeping the current approach because [valid reason].
See [link to discussion or design doc].

[Request reviewer mark as resolved]
```

### Who Resolves?

**Best Practice:**
- Author fixes → Author marks resolved ✅
- Author explains/pushes back → Reviewer marks resolved (if satisfied) ✅
- Discuss first if uncertain ✅

---

## Handling Multiple Review Rounds

### Round 1: Initial Feedback

1. **Read all comments first** - don't respond immediately
2. **Group related comments** - address themes together
3. **Ask clarifying questions** for unclear feedback
4. **Prioritize blockers** - fix critical issues first

**Example Response:**
```markdown
Thanks for the thorough review! I'll address these in order of priority:

## Blocking Issues
- Security: Fixed SQL injection (commit abc123)
- Tests: Added missing edge case tests (commit def456)

## Suggestions
- Performance: Added pagination (commit ghi789)
- Code quality: Refactored for clarity (commit jkl012)

## Questions
For the caching suggestion - could you elaborate on which operations you
think would benefit most? I want to make sure I optimize the right path.
```

### Round 2: Follow-up Feedback

**Track what's been addressed:**
```markdown
## Updates from Round 2 Feedback

✅ Addressed:
- Added connection pooling (commit abc123)
- Updated docstrings (commit def456)

❓ Still discussing:
- Caching strategy - waiting for your response on [question]

🎫 Follow-up tickets:
- ML-12345: Investigate alternative approach (discussed with @reviewer)
```

### Round 3+: Iteration

**Keep momentum:**
- Respond within 1 business day
- Batch small fixes into single commit
- Summarize changes clearly
- Show appreciation for reviewer's time

```markdown
Final round of updates based on feedback:

- Simplified error handling per your suggestion (commit abc123)
- Added performance benchmarks to PR description
- Updated migration guide in docs/

I think we're good to go now. Thanks for all the feedback - the code is much
better as a result!
```

---

## Communication Patterns

### Asking for Clarification

**Good:**
```markdown
Could you clarify what you mean by "this could cause issues"? Are you concerned about:
1. Thread safety?
2. Memory usage?
3. Performance?

I want to make sure I address the right problem.
```

**Bad:**
```markdown
What do you mean? 😕
```

### Explaining Your Reasoning

**Good:**
```markdown
I chose this implementation because:

1. **Performance**: Testing showed 3x faster than the alternative
2. **Maintainability**: Uses existing patterns from feature_store module
3. **Backward compatibility**: Doesn't break existing API

Here's the benchmark data: [link or code snippet]

Let me know if you see issues with this reasoning!
```

**Bad:**
```markdown
This way is better because I think so.
```

### Proposing Alternatives

**Good:**
```markdown
I see three options here:

**Option A (current)**: Fast but uses more memory
**Option B**: Memory efficient but 2x slower
**Option C**: Complex but optimal for both

Given our typical workload is <1000 records, I went with A. But I'm happy to
switch to C if you think the complexity is worth it.

What's your preference?
```

**Bad:**
```markdown
We could do it differently I guess.
```

### Pushing Back Respectfully

**Good:**
```markdown
I understand your concern about complexity, but I think it's necessary here because:

1. The simpler approach doesn't handle [edge case]
2. We hit this scenario in production (ticket ML-12340)
3. I've added comprehensive tests to prevent regressions

That said, if you have a simpler approach that handles these cases, I'm all ears!
```

**Bad:**
```markdown
This is the only way to do it. The simpler version doesn't work.
```

---

## Common Scenarios

### Scenario 1: Reviewer Misunderstood Intent

**Response:**
```markdown
I think I didn't explain this well in the PR description. Let me clarify:

The goal here is to [explain intent], not [what reviewer thought].

The reason for [specific implementation choice] is [explanation].

Does that make more sense? Happy to improve the PR description to make this clearer.
```

### Scenario 2: Conflicting Feedback from Multiple Reviewers

**Response:**
```markdown
@reviewer1 and @reviewer2 - I'm getting conflicting feedback on this approach:

- @reviewer1 suggests [approach A]
- @reviewer2 suggests [approach B]

Both seem valid. Could you discuss and let me know which direction to take?
Or if there's a third option that addresses both concerns, I'm happy to implement it.
```

### Scenario 3: Reviewer Asks for Out-of-Scope Changes

**Response:**
```markdown
That's a great idea for improving [area], but it's outside the scope of this PR
which is focused on [specific goal].

I've created ticket ML-12345 to track this improvement. Would you be okay if I
address it in a follow-up PR? That way we can:
1. Keep this PR focused and reviewable
2. Give the new work proper attention and testing
3. Not block the original feature
```

### Scenario 4: Reviewer Found Fundamental Issue

**Response:**
```markdown
Oh wow, you're absolutely right. I completely missed [issue].

Let me go back to the drawing board on this. I'll update the PR once I have a
solution that properly handles [the issue you found].

Thanks for catching this before it made it to production!

ETA: [timeframe] for updated implementation.
```

### Scenario 5: Nitpick You Disagree With

**Response:**
```markdown
I see your point about [suggestion]. I went with the current approach because
[brief reason], but it's not critical.

I'm happy to change it if you feel strongly - just let me know!

Otherwise, I'll leave it as-is to keep momentum on getting this merged.
```

---

## Re-requesting Review

### When to Re-request

✅ **All blocking comments addressed**
✅ **All requested changes made**
✅ **CI passing**
✅ **Linting passing**

### How to Re-request

**On GitHub:**
1. Click "Re-request review" button
2. Add comment summarizing changes

**Example Comment:**
```markdown
@reviewer Ready for another look!

## Changes Made
- ✅ Fixed SQL injection vulnerability (commit abc123)
- ✅ Added missing tests (commit def456)
- ✅ Refactored for clarity (commit ghi789)
- ✅ Updated documentation

## Still TODO
- None - all feedback addressed

Let me know if anything else needs attention!
```

### If No Response

**After 2 business days:**
```markdown
@reviewer Friendly ping - when you get a chance, could you take another look?
No rush, just want to make sure this doesn't fall through the cracks.

Thanks!
```

**After 5 business days:**
```markdown
@reviewer @other-maintainer This has been pending review for a while.
Could one of you take a look when you get a chance?

All feedback has been addressed and CI is green.
```

---

## Best Practices

### DO ✅

- ✅ **Respond promptly** (within 24 hours when possible)
- ✅ **Be grateful** for reviewer's time
- ✅ **Ask questions** when unclear
- ✅ **Admit mistakes** when you make them
- ✅ **Provide context** for decisions
- ✅ **Link to docs/tickets** for reference
- ✅ **Resolve conversations** when fixed
- ✅ **Test your fixes** before pushing

### DON'T ❌

- ❌ **Take feedback personally**
- ❌ **Argue for ego**
- ❌ **Ignore comments**
- ❌ **Make excuses**
- ❌ **Rush fixes** without testing
- ❌ **Leave conversations hanging**
- ❌ **Push back without good reason**
- ❌ **Be defensive**

---

## Example: Complete PR Conversation

### Initial Review Comment
> **Reviewer**: This query could be vulnerable to SQL injection. Can you use
> parameterized queries instead?

### Good Response
```markdown
Good catch! You're absolutely right.

Fixed in commit abc123:
```python
# Before (vulnerable)
query = f"SELECT * FROM {table} WHERE name = '{name}'"

# After (safe)
query = "SELECT * FROM %(table)s WHERE name = %(name)s"
params = {"table": table, "name": name}
```

I also audited the rest of the file and found 2 similar cases - fixed those too.

Thanks for catching this!

[Marked as resolved]
```

---

## Quick Reference Card

### Response Formula
1. **Acknowledge** - Show you read it
2. **Explain** or **Fix** - Provide context or solution
3. **Commit** - Reference the change
4. **Thank** - Appreciate the feedback

### When in Doubt
- ❓ Ask for clarification
- 🤝 Err on the side of accepting feedback
- 📞 Suggest pairing if complex
- 🎯 Focus on what's best for the code

### Red Flags 🚩
- Arguing over every comment
- Ignoring feedback for days
- Defensive responses
- "This is fine" without explanation
- Not testing fixes

### Green Flags ✅
- Prompt responses
- Clear explanations
- Testing fixes
- Graceful acceptance
- Following up on commitments

---

**Last Updated**: 2025-11-10
**Reference**: Based on MLRun CLAUDE.md PR review experience (#8562)
