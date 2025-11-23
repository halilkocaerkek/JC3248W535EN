@echo off
REM Build script for demo_lvgl project
REM Updates platformio.ini to point to this project and builds it

echo ========================================
echo Building demo_lvgl project
echo ========================================
echo.

REM Save current directory
set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"

REM Check if platformio.ini src_dir is already set to this project
findstr /C:"src_dir = projects/demo_lvgl/src" platformio.ini >nul
if errorlevel 1 (
    echo Updating platformio.ini to use demo_lvgl...
    powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/demo_lvgl/src' | Set-Content platformio.ini"
)

echo Building project...

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
        echo To add to PATH in PowerShell:
        echo   $env:Path += ";$env:USERPROFILE\.platformio\penv\Scripts"
        echo.
        echo Or in Command Prompt:
        echo   set PATH=%%PATH%%;%%USERPROFILE%%\.platformio\penv\Scripts
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
