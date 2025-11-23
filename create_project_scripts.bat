@echo off
REM Script to create batch files for a new project
REM Usage: create_project_scripts.bat project_name

if "%1"=="" (
    echo Usage: create_project_scripts.bat project_name
    echo Example: create_project_scripts.bat weather_station
    exit /b 1
)

set PROJECT_NAME=%1
set PROJECT_DIR=projects\%PROJECT_NAME%

if not exist "%PROJECT_DIR%" (
    echo Error: Project directory %PROJECT_DIR% does not exist!
    echo Please create it first with: mkdir %PROJECT_DIR%\src
    exit /b 1
)

echo Creating batch files for project: %PROJECT_NAME%
echo.

REM Create build.bat
echo Creating build.bat...
(
echo @echo off
echo REM Build script for %PROJECT_NAME% project
echo REM Updates platformio.ini to point to this project and builds it
echo.
echo echo ========================================
echo echo Building %PROJECT_NAME% project
echo echo ========================================
echo echo.
echo.
echo REM Save current directory
echo set PROJECT_ROOT=%%~dp0..\..
echo cd /d "%%PROJECT_ROOT%%"
echo.
echo REM Check if platformio.ini src_dir is already set to this project
echo findstr /C:"src_dir = projects/%PROJECT_NAME%/src" platformio.ini ^>nul
echo if errorlevel 1 ^(
echo     echo Updating platformio.ini to use %PROJECT_NAME%...
echo     powershell -Command "^(Get-Content platformio.ini^) -replace 'src_dir = projects/.*/src', 'src_dir = projects/%PROJECT_NAME%/src' | Set-Content platformio.ini"
echo ^)
echo.
echo echo Building project...
echo pio run
echo.
echo if errorlevel 1 ^(
echo     echo.
echo     echo ========================================
echo     echo BUILD FAILED!
echo     echo ========================================
echo     exit /b 1
echo ^) else ^(
echo     echo.
echo     echo ========================================
echo     echo BUILD SUCCESSFUL!
echo     echo ========================================
echo     echo.
echo     echo To upload: run upload.bat
echo     echo To monitor: run monitor.bat
echo ^)
echo.
echo exit /b 0
) > "%PROJECT_DIR%\build.bat"

REM Create upload.bat
echo Creating upload.bat...
(
echo @echo off
echo REM Upload script for %PROJECT_NAME% project
echo.
echo echo ========================================
echo echo Building and Uploading %PROJECT_NAME%
echo echo ========================================
echo echo.
echo.
echo set PROJECT_ROOT=%%~dp0..\..
echo cd /d "%%PROJECT_ROOT%%"
echo.
echo findstr /C:"src_dir = projects/%PROJECT_NAME%/src" platformio.ini ^>nul
echo if errorlevel 1 ^(
echo     echo Updating platformio.ini to use %PROJECT_NAME%...
echo     powershell -Command "^(Get-Content platformio.ini^) -replace 'src_dir = projects/.*/src', 'src_dir = projects/%PROJECT_NAME%/src' | Set-Content platformio.ini"
echo ^)
echo.
echo echo Building and uploading...
echo pio run -t upload
echo.
echo if errorlevel 1 ^(
echo     echo.
echo     echo ========================================
echo     echo UPLOAD FAILED!
echo     echo ========================================
echo     exit /b 1
echo ^) else ^(
echo     echo.
echo     echo ========================================
echo     echo UPLOAD SUCCESSFUL!
echo     echo ========================================
echo     echo.
echo     echo To monitor: run monitor.bat
echo ^)
echo.
echo exit /b 0
) > "%PROJECT_DIR%\upload.bat"

REM Create monitor.bat
echo Creating monitor.bat...
(
echo @echo off
echo REM Monitor script for %PROJECT_NAME% project
echo.
echo echo ========================================
echo echo Serial Monitor - %PROJECT_NAME%
echo echo ========================================
echo echo.
echo echo Press Ctrl+C to exit monitor
echo echo.
echo.
echo set PROJECT_ROOT=%%~dp0..\..
echo cd /d "%%PROJECT_ROOT%%"
echo.
echo findstr /C:"src_dir = projects/%PROJECT_NAME%/src" platformio.ini ^>nul
echo if errorlevel 1 ^(
echo     echo Updating platformio.ini to use %PROJECT_NAME%...
echo     powershell -Command "^(Get-Content platformio.ini^) -replace 'src_dir = projects/.*/src', 'src_dir = projects/%PROJECT_NAME%/src' | Set-Content platformio.ini"
echo ^)
echo.
echo echo Starting serial monitor...
echo echo.
echo pio device monitor
echo.
echo exit /b 0
) > "%PROJECT_DIR%\monitor.bat"

REM Create clean.bat
echo Creating clean.bat...
(
echo @echo off
echo REM Clean build script for %PROJECT_NAME% project
echo.
echo echo ========================================
echo echo Cleaning %PROJECT_NAME% project
echo echo ========================================
echo echo.
echo.
echo set PROJECT_ROOT=%%~dp0..\..
echo cd /d "%%PROJECT_ROOT%%"
echo.
echo findstr /C:"src_dir = projects/%PROJECT_NAME%/src" platformio.ini ^>nul
echo if errorlevel 1 ^(
echo     echo Updating platformio.ini to use %PROJECT_NAME%...
echo     powershell -Command "^(Get-Content platformio.ini^) -replace 'src_dir = projects/.*/src', 'src_dir = projects/%PROJECT_NAME%/src' | Set-Content platformio.ini"
echo ^)
echo.
echo echo Performing full clean...
echo pio run -t fullclean
echo.
echo echo.
echo echo ========================================
echo echo CLEAN COMPLETE!
echo echo ========================================
echo echo.
echo echo Run build.bat to rebuild the project
echo.
echo exit /b 0
) > "%PROJECT_DIR%\clean.bat"

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo.
echo Batch files created in %PROJECT_DIR%:
echo - build.bat
echo - upload.bat
echo - monitor.bat
echo - clean.bat
echo.
echo Usage:
echo   cd %PROJECT_DIR%
echo   build.bat
echo   upload.bat
echo   monitor.bat
echo.

exit /b 0
