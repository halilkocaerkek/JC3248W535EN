@echo off
REM Upload script for demo_lvgl project
REM Builds and uploads firmware to the device

echo ========================================
echo Building and Uploading demo_lvgl
echo ========================================
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

echo Building and uploading...
pio run -t upload

if errorlevel 1 (
    echo.
    echo ========================================
    echo UPLOAD FAILED!
    echo ========================================
    echo.
    echo Troubleshooting:
    echo - Check USB cable is connected
    echo - Check COM port in Device Manager
    echo - Try holding BOOT button during upload
    exit /b 1
) else (
    echo.
    echo ========================================
    echo UPLOAD SUCCESSFUL!
    echo ========================================
    echo.
    echo To monitor serial output: run monitor.bat
    echo Or press any key to start monitoring now...
    pause >nul
    call monitor.bat
)

exit /b 0
