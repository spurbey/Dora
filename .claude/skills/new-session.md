---
name: new-session
description: Start a new session with context loading
---

# New Session Workflow

## Execute in order:

1. Read project status:
```bash
cat .claude/PROJECT_STATUS.md
```

2. Read current phase:
```bash
cat .claude/CURRENT_PHASE.md
```

3. Check recent commits:
```bash
git log --oneline -20
```

4. Check last commit details:
```bash
git log -1 --format=full
```

5. Identify current task from PROJECT_STATUS.md (first unchecked item)

6. Load relevant phase PRD if needed:
```bash
cat docs/phases/phase-X-name.md
```

## Output to human:
```
SESSION START
=============
Phase: [phase name]
Current Task: [task description]
Last Commit: [last commit summary]
Context Loaded: [list files read]

Ready to proceed? (yes/no)
```

## Notes
- Only load phase PRD if you need detailed specs
- Don't load entire codebase
- If blockers exist, ask human first