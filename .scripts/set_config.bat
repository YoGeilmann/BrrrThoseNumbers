@echo off
setlocal enabledelayedexpansion

:: GP-2026-STRICT: Bridge Configuration Generator
:: [FIX] Removed pipe character to prevent CMD execution errors

set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fi"
set "CONFIG_FILE=%REPO_ROOT%\BrrrDebugBridge\config.lua"

set "MODE=auto"
set "SHOW_INTRO=false"

:args_loop
if "%~1"=="" goto write_config
if /i "%~1"=="intro" (
    set "SHOW_INTRO=true"
    echo [CONFIG] Status: Intro enabled
)
if /i "%~1"=="manual" (
    set "MODE=manual"
    echo [CONFIG] Status: Manual mode activated
)
shift
goto args_loop

:write_config
(
echo return {
echo     show_intro = %SHOW_INTRO%,
echo     mode = "%MODE%",
echo     deck = "b_red"
echo }
) > "%CONFIG_FILE%.tmp"

move /y "%CONFIG_FILE%.tmp" "%CONFIG_FILE%" >nul

:: GP-2026-STRICT: Use safe delimiters only
echo [CONFIG] Sync complete - Mode: %MODE% - Intro: %SHOW_INTRO%
exit /b 0