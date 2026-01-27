@echo off
setlocal enabledelayedexpansion

:: GP-2026-STRICT: Atomic Config Generator
:: Purpose: Prepare the config.lua in the source directory.

:: --- 1. PATH RESOLUTION ---
set "SCRIPT_DIR=%~dp0"
:: Resolve REPO_ROOT safely
for %%i in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fi"
set "TARGET_DIR=%REPO_ROOT%\BrrrDebugBridge"
set "CONFIG_FILE=%TARGET_DIR%\config.lua"

:: --- 2. SAFETY CHECK ---
if not exist "%TARGET_DIR%" (
    echo [CRITICAL] Target directory missing: "%TARGET_DIR%"
    exit /b 1
)

:: --- 3. FLAG PROCESSING ---
:: Standard: Intro is skipped (show_intro = false)
set "SHOW_INTRO=false"

:: If argument 1 is "intro", we show the intro (show_intro = true)
if /i "%~1"=="intro" (
    set "SHOW_INTRO=true"
)

:: --- 4. ATOMIC WRITE ---
:: We write to a temp file first and then move to avoid partial writes
set "TEMP_CONFIG=%CONFIG_FILE%.tmp"

(
echo -- GP-2026-STRICT: Automated Bridge Config
echo -- Generated: %date% %time%
echo return {
echo     show_intro = %SHOW_INTRO%,
echo     test_scenario = "default"
echo }
) > "%TEMP_CONFIG%"

move /y "%TEMP_CONFIG%" "%CONFIG_FILE%" >nul

echo [CONFIG] Bridge source updated: show_intro=%SHOW_INTRO%
exit /b 0