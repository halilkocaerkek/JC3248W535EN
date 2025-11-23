@echo off
REM Clean build script for weather_station project

echo ========================================
echo Cleaning weather_station project
echo ========================================
echo.

set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"

findstr /C:"src_dir = projects/weather_station/src" platformio.ini >nul
if errorlevel 1 (
    echo Updating platformio.ini to use weather_station...
    powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/weather_station/src' | Set-Content platformio.ini"
)

echo Performing full clean...

where pio >nul 2>&1
if errorlevel 1 (
    if exist "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\pio.exe" run -t fullclean
    ) else if exist "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" (
        "%USERPROFILE%\.platformio\penv\Scripts\platformio.exe" run -t fullclean
    ) else (
        echo ERROR: PlatformIO not found! See PLATFORMIO_PATH_FIX.md
        exit /b 1
    )
) else (
    pio run -t fullclean
)

echo.
echo ========================================
echo CLEAN COMPLETE!
echo ========================================
echo.
echo Run build.bat to rebuild the project

exit /b 0
