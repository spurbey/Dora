---
name: flutter-command-unblocker
type: agent
autonomy: medium
description: Diagnose and unblock hanging Flutter CLI/test commands on Windows before test execution
---

# Flutter Command Unblocker

## Purpose
Recover from Flutter CLI hangs where `flutter --version` or `flutter test` appears stuck and never reaches test execution.

## Scope
- Windows + PowerShell workflows
- Flutter SDK installed outside project (example: `C:\flutter\flutter`)
- Agent troubleshooting and recovery only (no app code changes)

## Typical Symptoms
- `flutter test` seems to hang for minutes with no output.
- `flutter --version` also hangs or times out.
- `dart --version` works immediately.
- Stale `dart.exe` processes are visible from older sessions.

## Root Cause Pattern
In this workspace, the main blocker was SDK cache lockfile access:
- non-elevated process could not open `C:\flutter\flutter\bin\cache\lockfile`
- Flutter CLI then stalled before normal startup

Secondary noise:
- stale `dart.exe` processes from interrupted runs
- stale lock artifacts (`flutter.bat.lock`, `lockfile`)

## Diagnostic Checklist
Run in this order and capture outputs:

1. Confirm Flutter path:
```powershell
where.exe flutter
Get-Command flutter | Select-Object Source,Version
```

2. Compare Dart vs Flutter responsiveness:
```powershell
C:\flutter\flutter\bin\cache\dart-sdk\bin\dart.exe --version
flutter --version
```

3. Check stale processes:
```powershell
Get-Process flutter,dart -ErrorAction SilentlyContinue |
  Select-Object ProcessName,Id,CPU,StartTime
```

4. Validate lock artifacts:
```powershell
Get-ChildItem C:\flutter\flutter\bin\cache -Force |
  Where-Object { $_.Name -in @('lockfile','flutter.bat.lock') }
```

5. If Flutter still hangs, verify lockfile error directly:
```powershell
C:\flutter\flutter\bin\cache\dart-sdk\bin\dart.exe `
  C:\flutter\flutter\bin\cache\flutter_tools.snapshot --version
```

If output contains:
`Flutter failed to open a file at "...\bin\cache\lockfile"...`
then this is a permissions/escalation issue, not test-code failure.

## Recovery Procedure
1. Stop stale processes:
```powershell
Get-Process dart,flutter -ErrorAction SilentlyContinue | Stop-Process -Force
```

2. Remove stale SDK lock files (only these files):
```powershell
Remove-Item -Force C:\flutter\flutter\bin\cache\lockfile, C:\flutter\flutter\bin\cache\flutter.bat.lock
```

3. Re-run Flutter commands with elevated permissions when required by environment policy:
- `flutter --version`
- `flutter test ...`

4. Re-check baseline:
```powershell
flutter --version
flutter test --reporter compact
```

## Escalation Rule
If non-elevated Flutter command times out and step 5 reports lockfile access error, escalate Flutter commands rather than repeatedly rerunning non-elevated.

Recommended approval prefixes:
- `["flutter"]`
- `["flutter","test"]`

## Guardrails
- Do not edit project code during CLI recovery.
- Do not delete Flutter SDK directories or cache directories broadly.
- Only remove the known lock artifacts when needed.
- After recovery, run the smallest failing test first, then full suite.

## Output Contract (for handoff)
Always report:
1. Commands executed
2. Confirmed root cause (with exact error string)
3. Recovery actions taken
4. Post-recovery verification (`flutter --version`, test results)
5. Which failures are current-regression vs pre-existing
