# PlatformIO PATH Fix

## Problem

When running batch files, you see:

```
'pio' is not recognized as an internal or external command
```

This means PlatformIO is not in your system PATH.

## Quick Fix (Recommended)

### Option 1: Add PlatformIO to PATH (Permanent)

**PowerShell (Run as Administrator):**

```powershell
# Add to current session
$env:Path += ";$env:USERPROFILE\.platformio\penv\Scripts"

# Add permanently (user level)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\.platformio\penv\Scripts", "User")
```

**Command Prompt (Run as Administrator):**

```cmd
# Add permanently
setx PATH "%PATH%;%USERPROFILE%\.platformio\penv\Scripts"
```

After adding to PATH, **restart your terminal** and try again.

### Option 2: Use VSCode/PlatformIO IDE Terminal

If you have VSCode with PlatformIO IDE extension installed:

1. Open VSCode in this repository
2. Open Terminal (Ctrl+`)
3. Run the batch files from VSCode terminal

VSCode automatically adds PlatformIO to PATH in its integrated terminal.

### Option 3: Run from VSCode PlatformIO

Instead of batch files, use VSCode PlatformIO buttons:

- Click "Build" button in status bar
- Click "Upload" button
- Click "Monitor" button

## Verify PlatformIO Installation

Check if PlatformIO is installed:

```cmd
dir %USERPROFILE%\.platformio\penv\Scripts\pio.exe
```

If file not found, install PlatformIO:

```cmd
# Using Python pip
pip install -U platformio

# Or download installer from:
# https://platformio.org/install/cli
```

## Test the Fix

After adding to PATH, test:

```cmd
pio --version
```

Should output something like:

```
PlatformIO Core, version 6.x.x
```

Then try building again:

```cmd
cd projects\demo_lvgl
build.bat
```

## Batch Files Auto-Detection

The updated batch files (build.bat, upload.bat, etc.) now automatically try to find PlatformIO in common locations:

1. First tries `pio` from PATH
2. Then tries `%USERPROFILE%\.platformio\penv\Scripts\pio.exe`
3. Then tries `%USERPROFILE%\.platformio\penv\Scripts\platformio.exe`
4. Shows helpful error if not found

So even without adding to PATH, the scripts should work if PlatformIO is installed in the default location.

## Still Not Working?

### Check PlatformIO Installation Location

```cmd
where /R C:\Users pio.exe
```

This searches for pio.exe. If found in a different location, you can either:

1. Add that location to PATH, or
2. Edit `pio_find.bat` to include your custom location

### Use Full Path Directly

If you know where PlatformIO is installed, you can edit the batch files to use the full path:

Example in `build.bat`:

```bat
REM Replace this line:
call pio_find.bat run

REM With full path:
"C:\your\custom\path\to\pio.exe" run
```

## Summary

**Recommended Solution:** Add PlatformIO to PATH permanently using Option 1 above, then restart your terminal.

**Quick Workaround:** Use VSCode integrated terminal which has PlatformIO in PATH automatically.

**Already Fixed:** The batch files now auto-detect PlatformIO in standard locations, so they should work even without PATH configuration.
