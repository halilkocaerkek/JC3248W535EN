@echo off
REM Build script for weather_station project

echo ========================================
echo Building weather_station project
echo ========================================
echo.

REM Navigate to repository root
set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"

REM Update platformio.ini to point to this project
findstr /C:"src_dir = projects/weather_station/src" platformio.ini >nul
if errorlevel 1 (
    echo Updating platformio.ini to use weather_station...
    powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/weather_station/src' -replace 'default_envs = .*', 'default_envs = weather_station' | Set-Content platformio.ini"
)

echo Building project (using environment: weather_station)...

REM Try to find and use pio command
where pio >nul 2>&1
if errorlevel 1 (
    REM pio not in PATH, try common locations
    if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" run
    ) else if exist "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" run
    ) else if exist "C:\Users\%USERNAME%\.platformio\penv\Scripts\pio.exe" (
        "C:\Users\%USERNAME%\.platformio\penv\Scripts\pio.exe" run
    ) else (
        echo.
        echo ERROR: PlatformIO not found!
        echo.
        echo Please either:
        echo 1. Add PlatformIO to your PATH, or
        echo 2. Install PlatformIO Core
        echo.
        echo See PLATFORMIO_PATH_FIX.md for instructions
        echo.
        exit /b 1
    )
) else (
    pio run
)

if errorlevel 1 (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    exit /b 1
) else (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo To upload: run upload.bat
    echo To monitor: run monitor.bat
)

exit /b 0
