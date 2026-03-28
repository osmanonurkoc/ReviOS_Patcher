@echo off
setlocal EnableDelayedExpansion
title ReviOS Patcher @osmanonurkoc
color 0b

:: ========================================================
:: PLAYBOOK CONFIGURATION (1 = Enable, 0 = Disable)
:: ========================================================
:: Core Features
set "CFG_DISABLE_DEFENDER=1"
set "CFG_DISABLE_HIBERNATE=1"

:: Debloat Options
set "CFG_REMOVE_EDGE=1"
set "CFG_REMOVE_ONEDRIVE=1"
set "CFG_REMOVE_AI=1"
set "CFG_REMOVE_TEAMS=1"

:: UWP Apps Removal
set "CFG_REMOVE_PHOTOS=1"
set "CFG_REMOVE_DEVHOME=1"
set "CFG_REMOVE_XBOX=1"
set "CFG_REMOVE_YOURPHONE=1"

:: System Customization
set "CFG_DARK_MODE=1"
set "CFG_LEGACY_CONTEXT_MENU=1"
set "CFG_REMOVE_PINNED_START=1"
set "CFG_DISABLE_MAINTENANCE=1"

:: Optional Tweaks (Disabled by default)
set "CFG_APPLY_WALLPAPER=0"
set "CFG_DISABLE_TRANSPARENCY=0"
set "CFG_INSTALL_BRAVE=0"
set "CFG_INSTALL_FIREFOX=0"

:: ========================================================
:: ASCII ART WELCOME PAGE
:: ========================================================
echo =================================================================
echo  ____            _  ___  ____    ____       _       _
echo ^|  _ \ _____   _(_)/ _ \/ ___^|  ^|  _ \ __ _^| ^|_ ___^| ^|__   ___ _ __
echo ^| ^|_) / _ \ \ / / ^| ^| ^| \___ \  ^| ^|_) / _` ^| __/ __^| '_ \ / _ \ '__^|
echo ^|  _ ^<  __/^\ V /^| ^| ^|_^| ^|___) ^| ^|  __/ (_^| ^| ^|^| (__^| ^| ^| ^|  __/ ^|
echo ^|_^| \_\___^| \_/ ^|_^|\___/^|____/  ^|_^|   \__,_^|\__\___^|_^| ^|_^|\___^|_^|
echo.
echo                          @osmanonurkoc
echo =================================================================
echo.

:: ---------------------------------------------------------
:: 1. ADMINISTRATOR PRIVILEGE CHECK
:: ---------------------------------------------------------
fltmc >nul 2>&1 || (
    echo [!] Administrator privileges are required.
    echo Requesting permissions...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ---------------------------------------------------------
:: 2. WORKSPACE SETUP (C:\Revision)
:: ---------------------------------------------------------
set "WORK_DIR=C:\Revision"

echo [*] Preparing Workspace in %WORK_DIR%...
:: Clear any existing remnants
if exist "%WORK_DIR%" rd /s /q "%WORK_DIR%"
mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

:: ---------------------------------------------------------
:: 3. DOWNLOAD 7ZA VIA BITS
:: ---------------------------------------------------------
echo [1/6] Downloading 7za.exe...
bitsadmin /transfer "7zaDownload" /download /priority foreground "https://github.com/osmanonurkoc/WSL2Scripts/releases/download/0.1/7za.exe" "%WORK_DIR%\7za.exe" >nul

if not exist "7za.exe" (
    echo [ERROR] Failed to download 7za.exe via BITS!
    pause
    goto :CLEANUP
)

:: ---------------------------------------------------------
:: 4. DOWNLOAD AME CLI & REVIOS PLAYBOOK
:: ---------------------------------------------------------
echo [2/6] Downloading latest AME CLI and ReviOS Playbook...
powershell -NoProfile -Command ^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
    "$ErrorActionPreference = 'Stop';" ^
    "try {" ^
    "   $headers = @{ 'User-Agent' = 'UpdaterScript' };" ^
    "   $cliRepo = 'https://api.github.com/repos/Ameliorated-LLC/trusted-uninstaller-cli/releases?per_page=1';" ^
    "   $pbRepo = 'https://api.github.com/repos/meetrevision/playbook/releases?per_page=1';" ^
    "   Write-Host '   - Fetching CLI info...';" ^
    "   $cliJson = Invoke-RestMethod -Uri $cliRepo -Headers $headers;" ^
    "   $cliLatest = $cliJson[0];" ^
    "   $cliAsset = $cliLatest.assets | Where-Object { $_.name -like '*CLI-Standalone*' } | Select-Object -First 1;" ^
    "   if (-not $cliAsset) { throw 'CLI Asset NOT FOUND' };" ^
    "   Invoke-WebRequest -Uri $cliAsset.browser_download_url -OutFile 'CLI-Standalone.zip';" ^
    "   Write-Host '   - Fetching Playbook info...';" ^
    "   $pbJson = Invoke-RestMethod -Uri $pbRepo -Headers $headers;" ^
    "   $pbLatest = $pbJson[0];" ^
    "   $pbAsset = $pbLatest.assets | Where-Object { $_.name -like '*.apbx' } | Select-Object -First 1;" ^
    "   if (-not $pbAsset) { throw 'Playbook Asset NOT FOUND' };" ^
    "   Invoke-WebRequest -Uri $pbAsset.browser_download_url -OutFile $pbAsset.name;" ^
    "} catch { Write-Error $_; exit 1 }"

if %errorlevel% neq 0 (
    echo [ERROR] File download failed.
    pause
    goto :CLEANUP
)

:: ---------------------------------------------------------
:: 5. EXTRACTION
:: ---------------------------------------------------------
echo [3/6] Extracting files...
7za.exe x "CLI-Standalone.zip" -y >nul

set "PB_FILE="
for %%F in (*.apbx) do set "PB_FILE=%%F"

if defined PB_FILE (
    mkdir "ReviPlaybook"
    7za.exe x "%PB_FILE%" -o"ReviPlaybook" -p"malte" -y >nul
) else (
    echo [ERROR] .apbx Playbook file not found!
    pause
    goto :CLEANUP
)

:: ---------------------------------------------------------
:: 6. REGISTRY FIXES (.ps1 association)
:: ---------------------------------------------------------
echo [4/6] Applying Registry Fixes (Will apply on reboot)...

(
echo Windows Registry Editor Version 5.00
echo.
echo ; 1. Fix .ps1 File Association
echo [HKEY_CLASSES_ROOT\.ps1]
echo @="Microsoft.PowerShellScript.1"
echo.
echo ; 2. Set Command to Run with Bypass Mode
echo [HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Open\Command]
echo @="\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" -NoLogo -ExecutionPolicy Bypass -File \"%%1\" %%*"
echo.
echo ; 3. Set System Execution Policy to RemoteSigned
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell]
echo "ExecutionPolicy"="RemoteSigned"
echo.
echo ; 4. Enable Winget Hash Override
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppInstaller]
echo "EnableHashOverride"=dword:00000001
echo.
echo ; 5. FORCE DELETE User Choice / Manual Associations
echo [-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ps1\UserChoice]
echo [-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ps1\OpenWithProgids]
echo [-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ps1\OpenWithList]
echo.
echo ; 6. Remove Gallery from File Explorer
echo [HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
echo "System.IsPinnedToNameSpaceTree"=dword:00000000
) > "temp_fix.reg"

regedit /s "temp_fix.reg"
del /f /q "temp_fix.reg" >nul 2>&1

:: ---------------------------------------------------------
:: 7. EXECUTE REVIOS PLAYBOOK (Dynamic Flags)
:: ---------------------------------------------------------
echo [5/6] Starting Playbook Tasks...

set "CLI_FLAGS=--accept-eula"
if "%CFG_DISABLE_DEFENDER%"=="1" set "CLI_FLAGS=!CLI_FLAGS! disable-defender"
if "%CFG_DISABLE_HIBERNATE%"=="1" set "CLI_FLAGS=!CLI_FLAGS! disable-hibernate"
if "%CFG_REMOVE_EDGE%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-edge"
if "%CFG_REMOVE_ONEDRIVE%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-onedrive"
if "%CFG_REMOVE_AI%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-winsxs-ai"
if "%CFG_REMOVE_TEAMS%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-teams"
if "%CFG_REMOVE_PHOTOS%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-appx-photos"
if "%CFG_REMOVE_DEVHOME%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-appx-devhome"
if "%CFG_REMOVE_XBOX%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-appx-xbox"
if "%CFG_REMOVE_YOURPHONE%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-appx-yourphone"
if "%CFG_DARK_MODE%"=="1" set "CLI_FLAGS=!CLI_FLAGS! configure-darkmode"
if "%CFG_LEGACY_CONTEXT_MENU%"=="1" set "CLI_FLAGS=!CLI_FLAGS! configure-lcm"
if "%CFG_REMOVE_PINNED_START%"=="1" set "CLI_FLAGS=!CLI_FLAGS! remove-pinned-items-startmenu"
if "%CFG_DISABLE_MAINTENANCE%"=="1" set "CLI_FLAGS=!CLI_FLAGS! disable-automatic-maintenance"

if "%CFG_APPLY_WALLPAPER%"=="1" set "CLI_FLAGS=!CLI_FLAGS! configure-wallpaper"
if "%CFG_DISABLE_TRANSPARENCY%"=="1" set "CLI_FLAGS=!CLI_FLAGS! configure-te"
if "%CFG_INSTALL_BRAVE%"=="1" set "CLI_FLAGS=!CLI_FLAGS! browser-brave"
if "%CFG_INSTALL_FIREFOX%"=="1" set "CLI_FLAGS=!CLI_FLAGS! browser-firefox"

if exist "TrustedUninstaller.CLI.exe" (
    TrustedUninstaller.CLI.exe "ReviPlaybook" !CLI_FLAGS!
) else (
    echo [ERROR] TrustedUninstaller.CLI.exe not found!
    pause
)

:: ---------------------------------------------------------
:: 8. FINAL CLEANUP (RunOnce) & RESTART
:: ---------------------------------------------------------
:CLEANUP
echo [6/6] Scheduling workspace cleanup for the next reboot...

:: Add a RunOnce registry key to delete the C:\Revision folder silently on next startup
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "ReviOSCleanup" /t REG_SZ /d "cmd.exe /c rd /s /q \"%WORK_DIR%\"" /f >nul 2>&1

:: Move to system drive root to ensure we don't lock anything right now
cd /d "%SystemDrive%\"

echo.
echo ========================================================
echo   PATCH COMPLETED SUCCESSFULLY!
echo   The system will restart in 15 seconds.
echo   C:\Revision will be automatically deleted on boot.
echo ========================================================
shutdown /r /t 15 /c "Installation finished. Restarting to apply changes and clean up."
timeout /t 15 >nul
exit /b
