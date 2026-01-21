---
name: commit
description: Create structured commit with COMPLETED/NEXT/FILES format
arguments:
  - name: message
    description: Short commit description
---

# Structured Commit Workflow

## Before committing:

1. Run tests (if backend):
```bash
cd backend && pytest
```

2. Run code-reviewer agent (ask human if should proceed)

3. Stage files:
```bash
git add <files>
```

## Commit message format:
```
<type>(<scope>): <short description>

COMPLETED:
- Task 1
- Task 2

NEXT SESSION:
- What to do next

FILES CHANGED:
- path/to/file.py (new, X lines)

TESTS: X passed, Y% coverage
```

Types: feat, fix, test, docs, chore, refactor
Scopes: auth, trips, places, media, search, frontend, db

## Execute:
```bash
git commit -m "$(cat commit_message.txt)"
```

## Notes
- Commit frequently (after each logical unit)
- Always include NEXT SESSION section
- List all changed files with line counts
- Include test results if applicable