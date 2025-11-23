@echo off
REM Upload script for weather_station project

echo ========================================
echo Building and Uploading weather_station
echo ========================================
echo.

set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"

findstr /C:"src_dir = projects/weather_station/src" platformio.ini >nul
if errorlevel 1 (
    echo Updating platformio.ini to use weather_station...
    powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/weather_station/src' | Set-Content platformio.ini"
)

echo Building and uploading...

where pio >nul 2>&1
if errorlevel 1 (
    if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" run -t upload
    ) else if exist "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" run -t upload
    ) else (
        echo ERROR: PlatformIO not found! See PLATFORMIO_PATH_FIX.md
        exit /b 1
    )
) else (
    pio run -t upload
)

if errorlevel 1 (
    echo.
    echo ========================================
    echo UPLOAD FAILED!
    echo ========================================
    exit /b 1
) else (
    echo.
    echo ========================================
    echo UPLOAD SUCCESSFUL!
    echo ========================================
    echo.
    echo To monitor: run monitor.bat
)

exit /b 0
