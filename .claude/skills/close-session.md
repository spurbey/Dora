---
name: close-session
description: End session, update status files, final commit
---

# Close Session Workflow

## 1. Update PROJECT_STATUS.md

Mark completed tasks:
- Change [ ] to [x] for completed items
- Update "Last Updated" date
- Update "Active Session" to None
- Add commit summary to "Recent Commits" section

## 2. Update CURRENT_PHASE.md (if phase complete)

If all sessions in phase done:
- Change Status to "Complete"
- Create new CURRENT_PHASE.md for next phase

## 3. Create session summary commit

Format:
```
session: complete [phase name]

COMPLETED THIS SESSION:
- Major item 1
- Major item 2

NEXT SESSION:
- Start [next phase/task]

BLOCKERS: [None/describe]

FILES CHANGED:
- List all files modified this session
```

## 4. Show summary to human
```
SESSION COMPLETE
================
Phase: [name]
Tasks Completed: X
Next Focus: [next task]
Blockers: [None/describe]

Status files updated. Session commit created.
```