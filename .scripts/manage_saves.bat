@echo off
setlocal enabledelayedexpansion

:: --- 1. CONFIGURATION ---
set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fi"

set "SAVE_ROOT=%AppData%\Balatro\2"
set "VAULT_ROOT=%REPO_ROOT%\backups\vault_p2"
set "TEST_SOURCE=%REPO_ROOT%\test_saves\active"

:: --- 2. ARGUMENT PARSING ---
set "DO_INJECT=false"
set "DO_RESTORE=false"

:parse_args
if "%~1"=="" goto execute
if /i "%~1"=="--inject" set "DO_INJECT=true"
if /i "%~1"=="--restore" set "DO_RESTORE=true"
shift
goto parse_args

:execute

:: --- 3. ACTION: BACKUP ---
echo [VAULT] Processing safety backup...
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set "TIMESTAMP=%%i"
set "BACKUP_DIR=%VAULT_ROOT%\backup_%TIMESTAMP%"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul

if exist "%SAVE_ROOT%" (
    :: Strict robocopy call without redirections that could create files
    robocopy "%SAVE_ROOT%" "%BACKUP_DIR%" *.jkr /NFL /NDL /NJH /NJS /nc /ns /np
    echo     -^> Backup created: %TIMESTAMP%
) else (
    echo     -^> [WARN] Profile 2 not found.
)

:: --- 4. ACTION: INJECT ---
if /i "!DO_INJECT!"=="true" (
    echo [VAULT] Executing injection...
    if not exist "%TEST_SOURCE%\*.jkr" (
        echo     -^> [ERROR] No source files in %TEST_SOURCE%
        exit /b 1
    )
    if exist "%SAVE_ROOT%" del /q "%SAVE_ROOT%\*.jkr"
    robocopy "%TEST_SOURCE%" "%SAVE_ROOT%" *.jkr /NFL /NDL /NJH /NJS /nc /ns /np
    echo     -^> Injection finished.
)

:: --- 5. ACTION: RESTORE ---
if /i "!DO_RESTORE!"=="true" (
    echo [VAULT] Executing restore...
    set "LATEST="
    for /f "delims=" %%d in ('dir "%VAULT_ROOT%\backup_*" /b /ad /o-n') do (
        set "LATEST=%VAULT_ROOT%\%%d"
        goto found_latest
    )
    :found_latest
    if "!LATEST!"=="" (
        echo     -^> [ERROR] No backups found.
        exit /b 1
    )
    if exist "%SAVE_ROOT%" del /q "%SAVE_ROOT%\*.jkr"
    robocopy "!LATEST!" "%SAVE_ROOT%" *.jkr /NFL /NDL /NJH /NJS /nc /ns /np
    echo     -^> Restored from latest vault.
)

echo [VAULT] Done.
exit /b 0