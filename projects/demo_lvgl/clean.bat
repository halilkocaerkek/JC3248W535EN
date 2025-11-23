@echo off
REM Clean build script for demo_lvgl project
REM Performs a full clean build (forces CMake reconfiguration)

echo ========================================
echo Cleaning demo_lvgl project
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

echo Performing full clean...
pio run -t fullclean

echo.
echo ========================================
echo CLEAN COMPLETE!
echo ========================================
echo.
echo Next steps:
echo - Run build.bat to rebuild the project
echo.
echo Note: Full clean is needed after:
echo - Changing sdkconfig.defaults
echo - Modifying Kconfig options
echo - Enabling/disabling LVGL demos
echo - Switching projects

exit /b 0
