@echo off
echo Setting up permissions for AlgoMon persistent storage on Windows...

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator!
    pause
    exit /b 1
)

REM Create data directories if they don't exist
mkdir elasticsearch\data 2>nul
mkdir prometheus\data 2>nul
mkdir grafana\data 2>nul

REM Set full permissions for Users group
echo Setting directory permissions...
for %%G in (elasticsearch\data prometheus\data grafana\data) do (
    echo Setting permissions for %%G
    takeown /F %%G /R /D Y >nul 2>&1
    icacls %%G /grant:r Users:(OI)(CI)F /T /Q
    if errorlevel 1 (
        echo Failed to set permissions for %%G
    ) else (
        echo Successfully set permissions for %%G
    )
)

echo.
echo Done! All permissions have been set correctly.
echo You can now run 'docker compose up -d' to start AlgoMon.
pause