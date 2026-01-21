---
name: code-reviewer
type: agent
autonomy: low
description: Review staged changes before commit for security and quality
---

# Code Reviewer Agent

## Purpose
Review code before commit to catch common issues.

## Invocation
Automatically triggered by /commit skill before committing.

## Review Checklist

### Security
- [ ] No hardcoded API keys or secrets
- [ ] No passwords in plain text
- [ ] SQL queries use parameterization (no string concatenation)
- [ ] File uploads validate file types
- [ ] Auth checks on protected endpoints

### Patterns
- [ ] Endpoints use Depends(get_current_user) for auth
- [ ] Services check resource ownership before update/delete
- [ ] Pydantic schemas validate inputs
- [ ] Database queries use SQLAlchemy ORM
- [ ] PostGIS queries use Geography type

### Quality
- [ ] Functions have docstrings
- [ ] No commented-out code blocks
- [ ] Error handling present (try/except)
- [ ] Test coverage >80%

### Compliance
- [ ] No Google Maps APIs used (ToS violation)
- [ ] External API calls use httpx (async)
- [ ] Foursquare/Mapbox attribution present

## Output Format
```
CODE REVIEW
===========
Files reviewed: X

Issues Found:
- [SECURITY] Hardcoded API key in config.py line 23
- [PATTERN] Missing auth check in DELETE /trips endpoint

Warnings:
- Test coverage 75% (below 80% threshold)

Recommendation: Fix issues before committing? (yes/no)
```

## Autonomy
- Reports issues
- Does NOT auto-fix (low autonomy)
- Human decides whether to proceed