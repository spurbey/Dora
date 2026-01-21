---
name: backend-builder
type: agent
autonomy: high
description: Build complete API resource (model → schema → service → route → test)
---

# Backend Builder Agent

## Purpose
Autonomous agent to implement a complete backend resource from specification.

## Input Required
- Resource name (e.g., "trips", "places")
- Fields specification
- Business logic requirements

## Workflow

1. Read relevant phase PRD from docs/phases/
2. Create SQLAlchemy model in app/models/
3. Create Pydantic schemas in app/schemas/
4. Create service layer in app/services/
5. Create API routes in app/api/v1/
6. Create pytest tests in tests/
7. Run tests
8. If tests fail, debug and fix (max 3 attempts)
9. Commit with structured message

## Autonomy Rules
- Can create files without asking
- Can install dependencies if needed
- Must ask before modifying existing files
- Must ask if tests fail after 3 attempts

## Success Criteria
- All CRUD endpoints work
- Tests pass with >80% coverage
- Follows project patterns (uses Depends, proper error handling)
- Structured commit created

## Example Invocation
```
Run backend-builder agent for "trips" resource with fields:
- title (string, required)
- description (text, optional)
- start_date, end_date (dates)
- visibility (enum: private/unlisted/public)
```

Agent will implement complete trips CRUD system autonomously.