---
name: test-runner
type: agent
autonomy: medium
description: Run tests, analyze failures, fix issues, re-run
---

# Test Runner Agent

## Purpose
Autonomous agent to run tests, debug failures, and fix issues.

## Input Required
- Test scope (all, backend, frontend, specific file)

## Workflow

1. Run tests:
```bash
cd backend && pytest  # or frontend npm test
```

2. If tests pass:
   - Report success
   - Show coverage report
   - Done

3. If tests fail:
   - Analyze error messages
   - Read relevant source files
   - Identify issue
   - Propose fix
   - Ask human: "Apply this fix? (yes/no)"
   - If yes, apply fix and re-run (max 3 iterations)

## Autonomy Rules
- Can run tests without asking
- Can read any file to debug
- Must ask before applying fixes
- Stops after 3 failed fix attempts

## Success Criteria
- All tests pass
- Coverage >80%
- No flaky tests

## Example Invocation
```
Run test-runner agent for backend tests
```

Agent will run pytest, fix any failures autonomously.