@echo off
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
:: Set the path to your Balatro mods directory.
:: It's often in %APPDATA%\Balatro\Mods
set "MOD_DIR=%APPDATA%\Balatro\Mods"

:: Set the path to your Balatro executable.
:: It's often in "C:\Program Files (x86)\Steam\steamapps\common\Balatro\Balatro.exe"
set "GAME_EXE=C:\Program Files (x86)\Steam\steamapps\common\Balatro\Balatro.exe"
:: --- END CONFIGURATION ---

:: Get the script's directory (.scripts) and go up to the repo root.
set "REPO_ROOT=%~dp0.."
set "LUA_VALIDATOR=%REPO_ROOT%\.tools\luac54.exe"

:: Check if validator exists
if not exist "%LUA_VALIDATOR%" (
    echo [SYNC] ERROR: Lua validator not found at %LUA_VALIDATOR%.
    echo Please ensure luac54.exe is in the .tools directory.
    goto :eof
)

:: --- VALIDATION STEP ---
echo [SYNC] Validating all .lua files...
set "VALIDATION_FAILED=0"
for /r "%REPO_ROOT%\BrrrThoseNumbers" %%f in (*.lua) do (
    "%LUA_VALIDATOR%" -p "%%f" >nul 2>&1
    if !errorlevel! neq 0 (
        echo   -> FAILED: %%~nxf
        set "VALIDATION_FAILED=1"
    )
)
for /r "%REPO_ROOT%\BrrrDebugBridge" %%f in (*.lua) do (
    "%LUA_VALIDATOR%" -p "%%f" >nul 2>&1
    if !errorlevel! neq 0 (
        echo   -> FAILED: %%~nxf
        set "VALIDATION_FAILED=1"
    )
)

if %VALIDATION_FAILED% equ 1 (
    echo.
    echo [SYNC] ERROR: Lua syntax validation failed. Aborting sync.
    pause
    goto :eof
)
echo [SYNC] Lua validation successful.

:: --- DEPLOYMENT STEP ---
echo [SYNC] Mirroring mods to %MOD_DIR%...
robocopy "%REPO_ROOT%\BrrrThoseNumbers" "%MOD_DIR%\BrrrThoseNumbers" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "%REPO_ROOT%\BrrrDebugBridge" "%MOD_DIR%\BrrrDebugBridge" /MIR /NFL /NDL /NJH /NJS /nc /ns /np

:: --- LAUNCH STEP ---
echo [SYNC] Launching Balatro...
if exist "%GAME_EXE%" (start "" "%GAME_EXE%") else (echo [SYNC] WARNING: Balatro.exe not found. Skipping launch.)

echo [SYNC] Sync complete.
endlocal