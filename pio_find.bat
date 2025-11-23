@echo off
REM Helper script to find and execute PlatformIO command
REM Usage: call pio_find.bat [pio arguments]
REM Example: call pio_find.bat run
REM Example: call pio_find.bat run -t upload

REM Check if pio is in PATH
where pio >nul 2>&1
if not errorlevel 1 (
    pio %*
    exit /b %ERRORLEVEL%
)

REM Try common PlatformIO locations
if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
    "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" %*
    exit /b %ERRORLEVEL%
)

if exist "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" (
    "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" %*
    exit /b %ERRORLEVEL%
)

if exist "C:\Users\%USERNAME%\.platformio\penv\Scripts\pio.exe" (
    "C:\Users\%USERNAME%\.platformio\penv\Scripts\pio.exe" %*
    exit /b %ERRORLEVEL%
)

REM PlatformIO not found
echo.
echo ========================================
echo ERROR: PlatformIO not found!
echo ========================================
echo.
echo Please either:
echo 1. Add PlatformIO to your PATH
echo 2. Install PlatformIO Core
echo.
echo To add to PATH:
echo   PowerShell:      $env:Path += ";$env:USERPROFILE\.platformio\penv\Scripts"
echo   Command Prompt:  set PATH=%%PATH%%;%%USERPROFILE%%\.platformio\penv\Scripts
echo.
echo To install PlatformIO:
echo   https://platformio.org/install/cli
echo.
exit /b 1
