@echo off
setlocal enabledelayedexpansion

:: --- 1. PATH RESOLUTION ---
set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fi"

set "MOD_DIR=%APPDATA%\Balatro\Mods"
set "GAME_EXE=C:\Program Files (x86)\Steam\steamapps\common\Balatro\Balatro.exe"
set "LUA_VALIDATOR=%REPO_ROOT%\.tools\luac54.exe"

:: --- 2. PRE-FLIGHT ---
if not exist "%LUA_VALIDATOR%" (
    echo [ERROR] Validator missing at: %LUA_VALIDATOR%
    pause & exit /b
)

:: --- 3. VALIDATION ---
echo [SYNC] Validating Lua syntax...
set "VALIDATION_FAILED=0"
for /f "delims=" %%f in ('dir /s /b "%REPO_ROOT%\*.lua" ^| findstr /v /i "\\\.git\\"') do (
    "%LUA_VALIDATOR%" -p "%%f" >nul 2>&1
    if !errorlevel! neq 0 (
        echo     -> [FAIL] %%f
        set "VALIDATION_FAILED=1"
    )
)
if %VALIDATION_FAILED% equ 1 (
    echo [CRITICAL] Syntax errors detected. Sync aborted.
    pause & exit /b
)

:: --- 3.5 CONFIGURATION (REPAIRED) ---
echo [SYNC] Preparing bridge configuration...
:: GP-2026-STRICT: Safer argument extraction using shift logic
set "MSG_ARG=%~1"
shift
set "BRIDGE_FLAGS=%*"

:: Execute config generator with remaining arguments
call "%SCRIPT_DIR%set_config.bat" %BRIDGE_FLAGS%
if !errorlevel! neq 0 (
    echo [CRITICAL] Config generation failed.
    pause & exit /b
)

:: --- 4. DEPLOYMENT ---
echo [SYNC] Mirroring to AppData...
robocopy "%REPO_ROOT%\BrrrThoseNumbers" "%MOD_DIR%\BrrrThoseNumbers" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "%REPO_ROOT%\BrrrDebugBridge" "%MOD_DIR%\BrrrDebugBridge" /MIR /NFL /NDL /NJH /NJS /nc /ns /np

:: --- 5. VERIFICATION GATE ---
if exist "%GAME_EXE%" (start "" "%GAME_EXE%")

echo.
echo ===========================================================
echo   VERIFICATION: [Y] AUTO-COMMIT ^| [N] ABORT
echo ===========================================================
echo.

choice /c YN /n /m "Selection (Y/N): "
if errorlevel 2 (
    echo [ABORTED] History clean.
    pause & exit /b
)

:: --- 6. ATOMIC FINALIZATION ---
echo [SYNC] Updating snapshot and committing...
tree "%REPO_ROOT%" /f /a > "%REPO_ROOT%\.docs\structure_snapshot.md"

:: SET COMMIT MESSAGE (Arg 1 or default)
set "msg=%~1"
if "!msg!"=="" set "msg=sync: automated update %date% %time%"

git -C "%REPO_ROOT%" add .
git -C "%REPO_ROOT%" commit -m "!msg!"
echo [SUCCESS] Atomic Sync Complete: !msg!
pause