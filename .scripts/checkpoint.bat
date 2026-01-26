@echo off
setlocal

:: Get the script's directory (.scripts) and go up to the repo root.
set "REPO_ROOT=%~dp0.."

echo [CHECKPOINT] Staging all changes...
git add -A

echo [CHECKPOINT] Creating timestamped commit...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "commit_msg=chore: Atomic checkpoint at %dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%:%dt:~12,2%"
git commit -m "%commit_msg%"

echo [CHECKPOINT] Generating new structure snapshot...
pushd %REPO_ROOT%
:: Generate a tree, excluding common noise, and save it to the docs folder
tree /f /a | findstr /v /i /c:".git" /c:".vscode" /c:".tools" > .docs\structure_snapshot.md
popd

echo [CHECKPOINT] Amending snapshot to the last commit...
git add %REPO_ROOT%\.docs\structure_snapshot.md
git commit --amend --no-edit > nul

echo.
echo [CHECKPOINT] Atomic Sync complete.
endlocal