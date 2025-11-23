@echo off
REM Monitor script for weather_station project

echo ========================================
echo Serial Monitor - weather_station
echo ========================================
echo.
echo Press Ctrl+C to exit monitor
echo.

set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"

findstr /C:"src_dir = projects/weather_station/src" platformio.ini >nul
if errorlevel 1 (
    echo Updating platformio.ini to use weather_station...
    powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/weather_station/src' | Set-Content platformio.ini"
)

echo Starting serial monitor...
echo.

where pio >nul 2>&1
if errorlevel 1 (
    if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" device monitor
    ) else if exist "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" device monitor
    ) else (
        echo ERROR: PlatformIO not found! See PLATFORMIO_PATH_FIX.md
        exit /b 1
    )
) else (
    pio device monitor
)

exit /b 0
