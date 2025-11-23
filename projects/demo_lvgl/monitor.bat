@echo off
REM Monitor script for demo_lvgl project
REM Opens serial monitor with ESP32 exception decoder

echo ========================================
echo Serial Monitor - demo_lvgl
echo ========================================
echo.
echo Press Ctrl+C to exit monitor
echo.

REM Save current directory
set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"

REM Update platformio.ini to point to this project
findstr /C:"src_dir = projects/demo_lvgl/src" platformio.ini >nul
if errorlevel 1 (
    echo Updating platformio.ini to use demo_lvgl...
    powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/demo_lvgl/src' | Set-Content platformio.ini"
)

echo Starting serial monitor...
echo.
pio device monitor

exit /b 0
