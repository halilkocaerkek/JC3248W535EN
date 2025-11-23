# Windows Batch Scripts Guide

## Overview

Each project includes Windows batch files (.bat) for easy development workflow. These scripts automatically update `platformio.ini` to point to the correct project and execute PlatformIO commands.

## Available Scripts

Every project has four batch files:

| Script | Purpose | Command |
|--------|---------|---------|
| **build.bat** | Build the project | `pio run` |
| **upload.bat** | Build and upload to device | `pio run -t upload` |
| **monitor.bat** | Open serial monitor | `pio device monitor` |
| **clean.bat** | Clean build (full rebuild) | `pio run -t fullclean` |

## Usage

### Quick Start

Navigate to your project directory and run the desired script:

```cmd
cd projects\demo_lvgl
build.bat        REM Compile the project
upload.bat       REM Flash to device
monitor.bat      REM View serial output
```

### Typical Workflow

**1. Development Cycle:**

```cmd
cd projects\my_project

REM Edit your code...

build.bat        REM Test compilation
upload.bat       REM Flash to device
monitor.bat      REM Check output
```

**2. After Configuration Changes:**

```cmd
cd projects\my_project

REM After editing sdkconfig.defaults or lv_conf.h...

clean.bat        REM Clean build
build.bat        REM Rebuild with new config
upload.bat       REM Flash to device
```

## How It Works

### Automatic Project Switching

Each batch file automatically updates `platformio.ini` to point to its project:

```bat
powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/my_project/src' | Set-Content platformio.ini"
```

This means you can:
- ✅ Switch between projects by running different batch files
- ✅ No manual editing of platformio.ini required
- ✅ Always builds the correct project

### Example: Switching Projects

```cmd
REM Work on demo_lvgl
cd projects\demo_lvgl
build.bat                    REM Builds demo_lvgl

REM Switch to weather_station
cd ..\weather_station
build.bat                    REM Automatically switches and builds weather_station

REM Back to demo_lvgl
cd ..\demo_lvgl
upload.bat                   REM Switches back and uploads demo_lvgl
```

## Script Details

### build.bat

**Purpose:** Compile the project without uploading

**When to use:**
- Testing if code compiles
- Checking for errors before upload
- Quick syntax validation

**Output:**
- ✅ Success: "BUILD SUCCESSFUL!"
- ❌ Failure: Shows compilation errors

**Example:**

```cmd
C:\...\projects\demo_lvgl> build.bat

========================================
Building demo_lvgl project
========================================

Building project...
[... compilation output ...]

========================================
BUILD SUCCESSFUL!
========================================

To upload: run upload.bat
To monitor: run monitor.bat
```

### upload.bat

**Purpose:** Build and flash firmware to device

**When to use:**
- After making code changes
- Deploying to hardware
- Testing on real device

**Requirements:**
- ESP32-S3 connected via USB
- COM port detected by Windows
- May need to hold BOOT button during upload

**Troubleshooting:**
If upload fails:
1. Check USB cable connection
2. Verify COM port in Device Manager
3. Try holding BOOT button
4. Check if another program is using the COM port

**Example:**

```cmd
C:\...\projects\demo_lvgl> upload.bat

========================================
Building and Uploading demo_lvgl
========================================

Building and uploading...
[... build and upload output ...]

========================================
UPLOAD SUCCESSFUL!
========================================

To monitor serial output: run monitor.bat
Or press any key to start monitoring now...
```

### monitor.bat

**Purpose:** Open serial monitor to view device output

**When to use:**
- Viewing ESP_LOG output
- Debugging application
- Checking crash backtraces (with exception decoder)

**Features:**
- ESP32 exception decoder automatically enabled
- Displays log messages in real-time
- Press Ctrl+C to exit

**Example:**

```cmd
C:\...\projects\demo_lvgl> monitor.bat

========================================
Serial Monitor - demo_lvgl
========================================

Press Ctrl+C to exit monitor

Starting serial monitor...

--- Terminal on COM3 | 115200 8-N-1
--- Available filters and text transformations: ...
--- Quit: Ctrl+C | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H ---

I (123) MY_PROJECT: Starting My Project
I (234) MY_PROJECT: Display initialized
I (345) MY_PROJECT: UI created
```

### clean.bat

**Purpose:** Perform full clean build (remove all build artifacts)

**When to use:**
- After changing `sdkconfig.defaults`
- After modifying Kconfig options (e.g., enabling LVGL demos)
- When switching between significantly different configurations
- Troubleshooting mysterious build errors

**What it does:**
- Deletes `.pio/build/` directory
- Forces CMake reconfiguration
- Regenerates `sdkconfig` files

**Note:** Next build will take longer as everything recompiles

**Example:**

```cmd
C:\...\projects\demo_lvgl> clean.bat

========================================
Cleaning demo_lvgl project
========================================

Performing full clean...
[... clean output ...]

========================================
CLEAN COMPLETE!
========================================

Run build.bat to rebuild the project

Note: Full clean is needed after:
- Changing sdkconfig.defaults
- Modifying Kconfig options
- Enabling/disabling LVGL demos
- Switching projects
```

## Creating Scripts for New Projects

### Method 1: Use the Generator Script (Recommended)

Run the project script generator from repository root:

```cmd
create_project_scripts.bat my_new_project
```

This automatically creates all four batch files for your project.

### Method 2: Copy from Existing Project

```cmd
mkdir projects\my_new_project
xcopy projects\demo_lvgl\*.bat projects\my_new_project\

REM Edit each .bat file to replace "demo_lvgl" with "my_new_project"
```

### Method 3: Create Manually

See templates in `projects/README.md` or `MULTI_PROJECT_SETUP.md`

## Advanced Usage

### Running from Repository Root

You can run batch files from anywhere:

```cmd
REM From repository root
projects\demo_lvgl\build.bat
projects\weather_station\upload.bat
```

### Combining Commands

```cmd
REM Build, upload, and monitor in one go
build.bat && upload.bat && monitor.bat

REM Clean and rebuild
clean.bat && build.bat
```

### Using with Task Scheduler

You can automate builds:

```cmd
REM Create scheduled task
schtasks /create /tn "Nightly Build" /tr "C:\path\to\projects\my_project\build.bat" /sc daily /st 02:00
```

## Troubleshooting

### "pio: command not found"

**Problem:** PlatformIO not in PATH

**Solution:**
1. Add PlatformIO to PATH, or
2. Use full path in scripts:
   ```bat
   C:\Users\YourName\.platformio\penv\Scripts\pio.exe run
   ```

### Script Doesn't Switch Projects

**Problem:** PowerShell execution policy

**Solution:**
```cmd
powershell -ExecutionPolicy Bypass -Command "..."
```

Or enable PowerShell scripts:
```cmd
powershell Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Access Denied" on platformio.ini

**Problem:** File is read-only or locked

**Solution:**
```cmd
attrib -r platformio.ini
```

## Best Practices

### 1. Always Use Project's Own Scripts

```cmd
REM Good
cd projects\my_project
build.bat

REM Bad - might build wrong project
cd projects\my_project
pio run  # Which project does this build?
```

### 2. Clean After Config Changes

```cmd
REM Edit sdkconfig.defaults or lv_conf.h
clean.bat    # Always clean first
build.bat    # Then rebuild
```

### 3. Monitor After Upload

```cmd
upload.bat
REM Press any key when prompted to start monitoring
REM Or run separately:
monitor.bat
```

### 4. Check Build Before Upload

```cmd
build.bat    # Test compilation
REM If successful:
upload.bat   # Then upload
```

## File Structure Reference

```
projects/
├── demo_lvgl/
│   ├── src/
│   │   ├── main.c
│   │   └── lv_conf.h
│   ├── sdkconfig.defaults
│   ├── build.bat       ← Builds demo_lvgl
│   ├── upload.bat      ← Uploads demo_lvgl
│   ├── monitor.bat     ← Monitors demo_lvgl
│   └── clean.bat       ← Cleans demo_lvgl
│
└── weather_station/
    ├── src/
    ├── sdkconfig.defaults
    ├── build.bat       ← Builds weather_station
    ├── upload.bat      ← Uploads weather_station
    ├── monitor.bat     ← Monitors weather_station
    └── clean.bat       ← Cleans weather_station
```

## Quick Reference Card

```
┌─────────────────────────────────────────────────┐
│          Windows Batch Scripts                  │
│         Quick Reference Card                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  build.bat     → Compile project               │
│  upload.bat    → Flash to device               │
│  monitor.bat   → View serial output            │
│  clean.bat     → Full rebuild                  │
│                                                 │
│  TYPICAL WORKFLOW:                              │
│  1. Edit code                                   │
│  2. build.bat (test compilation)               │
│  3. upload.bat (flash to device)               │
│  4. monitor.bat (view output)                  │
│                                                 │
│  AFTER CONFIG CHANGES:                          │
│  1. clean.bat                                   │
│  2. build.bat                                   │
│  3. upload.bat                                  │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Summary

- ✅ Each project has 4 batch files for common tasks
- ✅ Scripts automatically switch to correct project
- ✅ No manual editing of platformio.ini needed
- ✅ Use `create_project_scripts.bat` for new projects
- ✅ Always clean after configuration changes
- ✅ Monitor after upload to see output
