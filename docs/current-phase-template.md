# Current Phase Template

Template for Codex to generate `CURRENT_PHASE.md`.

---

## Template
```
# Current Phase: {PHASE_NAME}

Phase: {PHASE_NUM} | Status: {STATUS}

## Progress
{COMPLETED_SESSIONS_LIST}
- [ ] Session {NEXT_NUM}: {NEXT_TITLE} (NEXT)

## Session {NEXT_NUM}: {NEXT_TITLE} (READY TO START)

Focus: {FOCUS_LINE}

### Context from Previous Session
{PREVIOUS_SUMMARY}

### Tasks
{TASKS_FROM_PRD - descriptions only, no code}

### Required Files
{FILES_TO_CREATE_OR_MODIFY}

### Success Criteria
{SUCCESS_CRITERIA_FROM_PRD}

### Related PRD
`{PRD_PATH}`

Next: {NEXT_PHASE}
```

---

## How to Fill

**PHASE_NAME:** From PRD title (e.g., "Phase 1B - Trips CRUD")

**PHASE_NUM:** From PRD (e.g., "1B")

**STATUS:** 
- "Ready to Start" if no sessions done
- "In Progress (X%)" if some done
- "Complete" if all done

**COMPLETED_SESSIONS_LIST:** From PROJECT_STATUS.md (look for [x] items)

**NEXT_NUM:** First unchecked session in phase

**NEXT_TITLE:** From PRD session heading

**FOCUS_LINE:** From PRD session "Focus:" line

**PREVIOUS_SUMMARY:** From PROJECT_STATUS.md → Recent Commits → last commit "COMPLETED:" section

**TASKS_FROM_PRD:** Copy from PRD session tasks (numbered list)

**FILES_TO_CREATE_OR_MODIFY:** Infer from tasks:
- Schemas → `app/schemas/*.py`
- Services → `app/services/*.py`
- Endpoints → `app/api/v1/*.py`
- Tests → `tests/test_*.py`

**SUCCESS_CRITERIA_FROM_PRD:** Copy from PRD

**PRD_PATH:** `docs/phases/phase-{num}-*.md`

**NEXT_PHASE:** Next phase in sequence

---

## Sources

1. Read `PROJECT_STATUS.md` for next session
2. Read `docs/phases/phase-*.md` for details
3. Read `PROJECT_STATUS.md` → Recent Commits for context