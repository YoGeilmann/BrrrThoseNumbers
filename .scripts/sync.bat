@echo off
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
set "MOD_DIR=%APPDATA%\Balatro\Mods"
set "GAME_EXE=C:\Program Files (x86)\Steam\steamapps\common\Balatro\Balatro.exe"
:: --- END CONFIGURATION ---

set "REPO_ROOT=%~dp0.."
set "LUA_VALIDATOR=%REPO_ROOT%\.tools\luac54.exe"

:: --- 1. PRE-FLIGHT CHECK ---
if not exist "%LUA_VALIDATOR%" (
    echo [SYNC] ERROR: Lua validator not found at %LUA_VALIDATOR%.
    echo Please ensure luac54.exe is in the .tools directory.
    pause
    goto :eof
)

:: --- 2. VALIDATION STEP (Safety First) ---
echo [SYNC] Validating all .lua files in repository...
set "VALIDATION_FAILED=0"

:: Recursively find all lua files, excluding .git folder via findstr
for /f "delims=" %%f in ('dir /s /b "%REPO_ROOT%\*.lua" ^| findstr /v /i "\\\.git\\"') do (
    "%LUA_VALIDATOR%" -p "%%f" >nul 2>&1
    if !errorlevel! neq 0 (
        echo     -> [ERROR] Syntax fail: %%f
        set "VALIDATION_FAILED=1"
    )
)

if %VALIDATION_FAILED% equ 1 (
    echo.
    echo [SYNC] CRITICAL: Lua validation failed. Commit and Deployment aborted.
    pause
    goto :eof
)
echo [SYNC] Lua validation successful.

:: --- 3. GIT ATOMIC SYNC (Integrated Snapshot) ---
if not "%~1"=="" (
    echo [SYNC] Updating structure snapshot...
    :: Generate snapshot before commit to include it in the current chunk
    tree "%REPO_ROOT%" /f /a > "%REPO_ROOT%\.docs\structure_snapshot.md"

    echo [SYNC] Starting Atomic Git Sync...
    git add .
    git commit -m "%~1"
    if !errorlevel! neq 0 (
        echo [SYNC] WARNING: Git commit failed or nothing to commit.
    )
)

:: --- 4. DEPLOYMENT STEP (Mirroring) ---
echo [SYNC] Mirroring mods to AppData...
:: Explicitly mirroring our two mod folders
robocopy "%REPO_ROOT%\BrrrThoseNumbers" "%MOD_DIR%\BrrrThoseNumbers" /MIR /NFL /NDL /NJH /NJS /nc /ns /np >nul
robocopy "%REPO_ROOT%\BrrrDebugBridge" "%MOD_DIR%\BrrrDebugBridge" /MIR /NFL /NDL /NJH /NJS /nc /ns /np >nul

:: --- 5. LAUNCH STEP ---
echo [SYNC] Launching Balatro (Standard Boot)...
if exist "%GAME_EXE%" (
    start "" "%GAME_EXE%"
) else (
    echo [SYNC] WARNING: Balatro.exe not found.
    echo [SYNC] Path checked: "%GAME_EXE%"
)

echo [SYNC] Sync complete.
endlocal