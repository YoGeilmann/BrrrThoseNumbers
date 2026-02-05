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

:: --- 3. ACTION: BACKUP (Safety First) ---
echo [VAULT] Creating safety backup...

:: Generate ISO timestamp via PowerShell (Replacement for WMIC)
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set "TIMESTAMP=%%i"
set "BACKUP_DIR=%VAULT_ROOT%\backup_%TIMESTAMP%"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul

if exist "%SAVE_ROOT%" (
    :: Fixed robocopy syntax without confusing brackets
    robocopy "%SAVE_ROOT%" "%BACKUP_DIR%" meta.jkr profile.jkr save.jkr /NFL /NDL /NJH /NJS /nc /ns /np
    if errorlevel 8 (
        echo [ERROR] Backup failed.
        exit /b 1
    )
    echo     -> Backup: backup_%TIMESTAMP%
) else (
    echo     -> [WARN] Profile 2 not found. Create it in-game first.
)

:: --- 4. ACTION: INJECT ---
if "%DO_INJECT%"=="true" (
    echo [VAULT] Injecting test saves...
    
    :: Prüft, ob überhaupt irgendwelche .jkr Dateien im Quellordner sind
    set "FOUND_SAVES=false"
    if exist "%TEST_SOURCE%\*.jkr" set "FOUND_SAVES=true"
    
    if "!FOUND_SAVES!"=="false" (
        echo     -> [ERROR] No .jkr files found in: %TEST_SOURCE%
        exit /b 1
    )

    if exist "%SAVE_ROOT%" del /q "%SAVE_ROOT%\*.jkr"
    
    robocopy "%TEST_SOURCE%" "%SAVE_ROOT%" *.jkr /NFL /NDL /NJH /NJS /nc /ns /np
    if errorlevel 8 (
        echo [ERROR] Injection failed.
        exit /b 1
    )
    echo     -> Injection complete.
)

:: --- 5. ACTION: RESTORE ---
if "%DO_RESTORE%"=="true" (
    echo [VAULT] Restoring latest backup...
    set "LATEST="
    for /f "delims=" %%d in ('dir "%VAULT_ROOT%\backup_*" /b /ad /o-n') do (
        set "LATEST=%VAULT_ROOT%\%%d"
        goto found_latest
    )
    :found_latest
    if "!LATEST!"=="" (
        echo     -> [ERROR] No backups found.
        exit /b 1
    )
    if exist "%SAVE_ROOT%" del /q "%SAVE_ROOT%\*.jkr"
    robocopy "!LATEST!" "%SAVE_ROOT%" *.jkr /NFL /NDL /NJH /NJS /nc /ns /np
    if errorlevel 8 (
        echo [ERROR] Restore failed.
        exit /b 1
    )
    echo     -> Restored from: !LATEST!
)

echo [VAULT] Operations finished.
exit /b 0