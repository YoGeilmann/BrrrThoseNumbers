@echo off
setlocal enabledelayedexpansion

:: --- 1. PATH RESOLUTION ---
set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fi"

set "MOD_DIR=%APPDATA%\Balatro\Mods"
set "GAME_EXE=C:\Program Files (x86)\Steam\steamapps\common\Balatro\Balatro.exe"
set "LUA_VALIDATOR=%REPO_ROOT%\.tools\luac54.exe"

:: --- 1.5 SAVE MANAGEMENT ---
echo [SYNC] Checking save management flags...
call "%SCRIPT_DIR%manage_saves.bat" %*
if !errorlevel! neq 0 (
    echo [CRITICAL] Save management failed.
    pause & exit /b
)

:: --- 2. PRE-FLIGHT ---
if not exist "%LUA_VALIDATOR%" (
    echo [ERROR] Validator missing at: %LUA_VALIDATOR%
    pause & exit /b
)

:: --- 3. VALIDATION (STRICT MOD-ONLY) ---
echo [SYNC] Validating active mod files...
set "VALIDATION_FAILED=0"
set "MOD_FOLDERS=BrrrThoseNumbers BrrrDebugBridge"

for %%d in (%MOD_FOLDERS%) do (
    if exist "%REPO_ROOT%\%%d" (
        for /r "%REPO_ROOT%\%%d" %%f in (*.lua) do (
            "%LUA_VALIDATOR%" -p "%%f" >nul 2>&1
            if errorlevel 1 (
                echo     -^> [FAIL] %%~nxf
                set "VALIDATION_FAILED=1"
            ) else (
                echo     -^> [OK] %%~nxf
            )
        )
    )
)

if "%VALIDATION_FAILED%"=="1" (
    echo [CRITICAL] Syntax errors detected. Sync aborted.
    pause & exit /b
)

:: --- 4. CONFIGURATION ---
echo [SYNC] Preparing bridge configuration...
set "MSG_ARG=%~1"
shift
set "BRIDGE_FLAGS=%*"

call "%SCRIPT_DIR%set_config.bat" %BRIDGE_FLAGS%
if errorlevel 1 (
    echo [CRITICAL] Config generation failed.
    pause & exit /b
)

:: --- 5. DEPLOYMENT ---
echo [SYNC] Mirroring to AppData...
robocopy "%REPO_ROOT%\BrrrThoseNumbers" "%MOD_DIR%\BrrrThoseNumbers" /MIR /NFL /NDL /NJH /NJS /nc /ns /np >nul
robocopy "%REPO_ROOT%\BrrrDebugBridge" "%MOD_DIR%\BrrrDebugBridge" /MIR /NFL /NDL /NJH /NJS /nc /ns /np >nul

:: --- 6. VERIFICATION GATE ---
if exist "%GAME_EXE%" (
    echo [SYNC] Launching Balatro...
    start "" "%GAME_EXE%"
)

echo.
echo CONFIRM: [Y] AUTO-COMMIT ^| [N] ABORT
echo.

set /p "CHOICE=Action (Y/N): "
if /i "%CHOICE%" neq "Y" (
    echo [ABORTED] History clean.
    pause & exit /b
)

:: --- 7. ATOMIC FINALIZATION ---
echo [SYNC] Updating snapshot and committing...
tree "%REPO_ROOT%" /f /a /at > "%REPO_ROOT%\.docs\structure_snapshot.md"

set "COMMIT_MSG=%MSG_ARG%"
if "!COMMIT_MSG!"=="" set "COMMIT_MSG=sync: automated update"

git -C "%REPO_ROOT%" add .
git -C "%REPO_ROOT%" commit -m "!COMMIT_MSG!"
echo [SUCCESS] Atomic Sync Complete.
pause