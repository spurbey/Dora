---
name: post-task
type: hook
trigger: After completing a task from PROJECT_STATUS.md
description: Update status file automatically
---

# Post-Task Hook

## Purpose
Automatically update PROJECT_STATUS.md when task completes.

## Trigger
After any task marked complete in checklist.

## Actions

1. Update PROJECT_STATUS.md:
   - Change [ ] to [x] for completed task
   - Update "Last Updated" timestamp
   - Increment "Completed Sessions" counter
   - Calculate new progress percentage

2. Check if phase complete:
   - If all tasks in phase done, update CURRENT_PHASE.md status

3. Show summary:
```
TASK COMPLETE
=============
Task: [task name]
Phase Progress: X/Y tasks (Z%)
Overall Progress: A/B sessions (C%)

Next Task: [next unchecked item]
```

## Implementation

Call this hook in /commit skill after successful commit:
```python
def update_project_status(task_id):
    # Read PROJECT_STATUS.md
    # Find task by ID
    # Mark as complete
    # Recalculate percentages
    # Write back to file
```

## Notes
- Runs automatically, no human intervention needed
- Keeps PROJECT_STATUS.md always current
- Provides clear progress tracking