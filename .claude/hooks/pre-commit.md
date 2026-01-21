---
name: pre-commit
type: hook
trigger: Before git commit
description: Lint, type check, prevent secrets in commits
---

# Pre-Commit Hook

## Purpose
Automated checks before allowing commit.

## Checks Performed

### 1. Linting (Backend)
```bash
cd backend && ruff check app/
```

### 2. Type Checking (Backend)
```bash
cd backend && mypy app/
```

### 3. Secret Detection
```bash
git diff --cached | grep -E "(API_KEY|SECRET|PASSWORD|TOKEN)" | grep -v ".env.example"
```
If found, block commit and warn human.

### 4. Test Run (Optional)
```bash
pytest tests/ -x  # Stop on first failure
```

## Configuration

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Run linting
cd backend && ruff check app/ || exit 1

# Check for secrets
if git diff --cached | grep -E "API_KEY.*=.*['\"]" | grep -v ".env.example"; then
    echo "ERROR: Potential secret detected in commit"
    exit 1
fi

exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Notes
- Hook runs automatically on `git commit`
- Can bypass with `git commit --no-verify` (not recommended)