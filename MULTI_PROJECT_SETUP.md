# Multi-Project Organization Guide

This document explains how to organize multiple projects for the JC3248W535EN display board within a single repository.

## Recommended Approach: Shared BSP with Multiple Source Directories

This approach keeps all hardware-specific code (BSP) in a shared library while allowing independent projects with their own source code and configurations.

---

## Strategy Comparison

### ✅ **Option 1: Multiple Environments (Recommended)**
**Best for:** 3-10 projects sharing the same hardware but with different applications

**Pros:**
- Clean separation of project code
- Shared BSP library (no code duplication)
- Easy to switch between projects
- All projects in one repository (easy version control)
- Each project can have custom LVGL config and sdkconfig

**Cons:**
- Slightly more complex initial setup
- Need to specify `-e project_name` when building

---

### Option 2: Git Branches per Project
**Best for:** Projects that diverge significantly or need independent version history

**Pros:**
- Complete isolation between projects
- Easy to merge common fixes across branches
- Standard Git workflow

**Cons:**
- Context switching requires `git checkout`
- Can't easily compare projects side-by-side
- More complex if you want to work on multiple projects simultaneously

---

### Option 3: Separate Repositories with Submodule
**Best for:** Very different projects or when projects need independent release cycles

**Pros:**
- Complete independence
- Can have different collaborators per project
- Each project has clean history

**Cons:**
- BSP code duplication (unless using git submodule)
- Harder to propagate BSP improvements
- More repositories to manage

---

## Implementation: Multi-Environment Setup (Option 1)

### Step 1: Reorganize Current Structure

```bash
# Create projects directory
mkdir projects

# Move current demo to projects/demo_lvgl
mkdir -p projects/demo_lvgl/src
mv src/* projects/demo_lvgl/src/
mv sdkconfig.LVGL-320-480 projects/demo_lvgl/sdkconfig.defaults

# Create shared BSP library
mkdir -p libraries/esp_bsp
mv projects/demo_lvgl/src/esp_bsp.* libraries/esp_bsp/
mv projects/demo_lvgl/src/esp_lcd_*.* libraries/esp_bsp/
mv projects/demo_lvgl/src/lv_port.* libraries/esp_bsp/
mv projects/demo_lvgl/src/display.h libraries/esp_bsp/
mv projects/demo_lvgl/src/bsp_err_check.h libraries/esp_bsp/

# Keep only application code in projects/demo_lvgl/src/
# - DEMO_LVGL.c (or rename to main.c)
# - lv_conf.h
```

### Step 2: Create BSP Library Header

Create `libraries/esp_bsp/library.json`:
```json
{
  "name": "ESP32-S3-Display-BSP",
  "version": "1.0.0",
  "description": "Board Support Package for JC3248W535EN ESP32-S3 Display",
  "keywords": ["esp32s3", "display", "lvgl", "touch"],
  "authors": [
    {
      "name": "Your Name"
    }
  ],
  "repository": {
    "type": "git",
    "url": "https://github.com/yourusername/JC3248W535EN"
  },
  "frameworks": "espidf",
  "platforms": "espressif32"
}
```

### Step 3: Update platformio.ini

Replace your current `platformio.ini` with the multi-project version (see `platformio.ini.example-multiproject`).

Key changes:
- `default_envs = demo_lvgl` (or your preferred default project)
- Each `[env:project_name]` has its own `src_dir`
- Each project points to its own `lv_conf.h` and `sdkconfig.defaults`

### Step 4: Create New Project Template

When starting a new project:

```bash
# Create project structure
mkdir -p projects/my_new_project/src

# Copy template files
cp projects/demo_lvgl/src/lv_conf.h projects/my_new_project/src/
cp projects/demo_lvgl/sdkconfig.defaults projects/my_new_project/

# Create main application file
cat > projects/my_new_project/src/main.c << 'EOF'
#include <lvgl.h>
#include "esp_bsp.h"
#include "lv_port.h"
#include <esp_log.h>

static const char *TAG = "MY_PROJECT";

void app_main()
{
    ESP_LOGI(TAG, "Starting My Project");

    // Initialize display with 90° rotation
    bsp_display_cfg_t cfg = {
        .lvgl_port_cfg = ESP_LVGL_PORT_INIT_CONFIG(),
        .buffer_size = EXAMPLE_LCD_QSPI_H_RES * EXAMPLE_LCD_QSPI_V_RES,
        .rotate = LV_DISP_ROT_90,
    };

    bsp_display_start_with_config(&cfg);
    bsp_display_backlight_on();

    // Create your UI
    bsp_display_lock(0);

    // Your LVGL code here
    lv_obj_t *label = lv_label_create(lv_scr_act());
    lv_label_set_text(label, "My New Project");
    lv_obj_center(label);

    bsp_display_unlock();

    ESP_LOGI(TAG, "Initialization complete");
}
EOF
```

### Step 5: Add to platformio.ini

```ini
[env:my_new_project]
platform = ${common.platform}
board = ${common.board}
monitor_filters = ${common.monitor_filters}
framework = ${common.framework}
build_type = ${common.build_type}
src_dir = projects/my_new_project/src
build_flags =
	${common.build_flags}
	-D LV_CONF_PATH="${PROJECT_DIR}/projects/my_new_project/src/lv_conf.h"
board_build.esp-idf.sdkconfig_path = projects/my_new_project/sdkconfig.defaults
```

### Step 6: Build and Run

```bash
# Build your new project
pio run -e my_new_project

# Upload and monitor
pio run -e my_new_project -t upload
pio device monitor -e my_new_project

# Build all projects
pio run
```

---

## Project-Specific Configurations

### Different LVGL Configurations

Each project can enable/disable different LVGL features:

**projects/weather_station/src/lv_conf.h:**
```c
#define LV_USE_DEMO_WIDGETS 0      // Disable demo
#define LV_USE_CHART 1              // Enable charts for graphs
#define LV_USE_CALENDAR 1           // Enable calendar widget
```

**projects/media_player/src/lv_conf.h:**
```c
#define LV_USE_DEMO_MUSIC 1         // Enable music demo as base
#define LV_USE_ANIMIMG 1            // Enable animated images
#define LV_USE_SLIDER 1             // Enable volume slider
```

### Different SDK Configurations

Each project can have custom ESP-IDF settings:

**projects/weather_station/sdkconfig.defaults:**
```
# Base configuration
CONFIG_FREERTOS_HZ=1000

# Enable WiFi
CONFIG_ESP32_WIFI_ENABLED=1
CONFIG_ESP32_WIFI_STATIC_RX_BUFFER_NUM=10

# LVGL demos
CONFIG_LV_USE_DEMO_WIDGETS=n
CONFIG_LV_USE_DEMO_BENCHMARK=n
```

**projects/media_player/sdkconfig.defaults:**
```
# Base configuration
CONFIG_FREERTOS_HZ=1000

# Audio configuration
CONFIG_ESP32_I2S_ENABLED=1

# LVGL demos
CONFIG_LV_USE_DEMO_MUSIC=y
```

---

## Directory Structure (Final)

```
JC3248W535EN/
├── platformio.ini                    # Multi-environment configuration
├── boards/
│   └── 320x480.json                  # Custom board definition
├── libraries/
│   ├── esp_bsp/                      # Shared Board Support Package
│   │   ├── library.json
│   │   ├── esp_bsp.c
│   │   ├── esp_bsp.h
│   │   ├── esp_lcd_axs15231b.c
│   │   ├── esp_lcd_axs15231b.h
│   │   ├── esp_lcd_touch.c
│   │   ├── esp_lcd_touch.h
│   │   ├── lv_port.c
│   │   ├── lv_port.h
│   │   ├── display.h
│   │   └── bsp_err_check.h
│   └── lvgl/                         # LVGL library
├── projects/
│   ├── demo_lvgl/                    # Original demo project
│   │   ├── src/
│   │   │   ├── main.c
│   │   │   └── lv_conf.h
│   │   └── sdkconfig.defaults
│   ├── weather_station/              # Weather display project
│   │   ├── src/
│   │   │   ├── main.c
│   │   │   ├── weather_ui.c
│   │   │   ├── weather_ui.h
│   │   │   └── lv_conf.h
│   │   └── sdkconfig.defaults
│   └── media_player/                 # Media player project
│       ├── src/
│       │   ├── main.c
│       │   ├── audio_player.c
│       │   ├── audio_player.h
│       │   └── lv_conf.h
│       └── sdkconfig.defaults
├── docs/                             # Documentation
├── CLAUDE.md                         # AI assistant guide
├── MULTI_PROJECT_SETUP.md           # This file
└── README.md                         # Repository overview
```

---

## Common Tasks

### Switching Between Projects

```bash
# Build specific project
pio run -e weather_station

# Set default project (edit platformio.ini)
[platformio]
default_envs = weather_station

# Then just use:
pio run
```

### Sharing Code Between Projects

**Option A: Create shared utility library**
```
libraries/
  └── project_utils/
      ├── library.json
      ├── wifi_manager.c
      ├── wifi_manager.h
      ├── settings.c
      └── settings.h
```

**Option B: Include from other project** (not recommended, creates coupling)
```c
// In weather_station/src/main.c
#include "../../media_player/src/audio_player.h"  // Avoid this
```

### Updating BSP for All Projects

When you fix a bug or add a feature to the BSP:

1. Edit files in `libraries/esp_bsp/`
2. Test with one project: `pio run -e demo_lvgl`
3. Test with other projects: `pio run -e weather_station`
4. Commit changes (all projects automatically get the update)

### Cleaning Builds

```bash
# Clean specific project
pio run -e weather_station -t fullclean

# Clean all projects
pio run -t fullclean
```

---

## Migration Script

Here's a bash script to automatically reorganize your current structure:

```bash
#!/bin/bash
# migrate_to_multiproject.sh

echo "Migrating to multi-project structure..."

# Create directories
mkdir -p projects/demo_lvgl/src
mkdir -p libraries/esp_bsp

# Move application code
mv src/DEMO_LVGL.c projects/demo_lvgl/src/main.c
mv src/lv_conf.h projects/demo_lvgl/src/

# Move BSP to library
mv src/esp_bsp.* libraries/esp_bsp/
mv src/esp_lcd_*.* libraries/esp_bsp/
mv src/lv_port.* libraries/esp_bsp/
mv src/display.h libraries/esp_bsp/
mv src/bsp_err_check.h libraries/esp_bsp/

# Move sdkconfig
cp sdkconfig.defaults projects/demo_lvgl/

# Create BSP library.json
cat > libraries/esp_bsp/library.json << 'EOF'
{
  "name": "ESP32-S3-Display-BSP",
  "version": "1.0.0",
  "description": "Board Support Package for JC3248W535EN",
  "frameworks": "espidf",
  "platforms": "espressif32"
}
EOF

# Backup old platformio.ini
cp platformio.ini platformio.ini.backup

# Copy example multi-project config
cp platformio.ini.example-multiproject platformio.ini

echo "Migration complete!"
echo "1. Review platformio.ini"
echo "2. Test build: pio run -e demo_lvgl"
echo "3. Create new projects in projects/ directory"
```

---

## Best Practices

1. **Keep BSP hardware-agnostic:** Don't put application logic in `libraries/esp_bsp/`
2. **Use consistent naming:** All projects use `main.c` as entry point
3. **Document project purpose:** Add README.md in each project directory
4. **Version control:** Use `.gitignore` to exclude build artifacts:
   ```
   .pio/
   projects/*/sdkconfig.LVGL-320-480
   ```
5. **Test across projects:** When changing BSP, test with at least 2 projects
6. **Separate concerns:** Keep UI code separate from business logic

---

## Troubleshooting

**Problem:** "undefined reference to BSP functions"
- **Solution:** BSP library not found. Check `lib_dir = libraries` in platformio.ini

**Problem:** "lv_conf.h not found"
- **Solution:** Check `LV_CONF_PATH` points to correct project's lv_conf.h

**Problem:** Changes to BSP not reflected in build
- **Solution:** Run `pio run -e project_name -t fullclean` to force rebuild

**Problem:** Different projects interfering with each other
- **Solution:** Each project should have independent `.pio/build/project_name/` directory

---

## Alternative: Branches Approach

If you prefer using Git branches:

```bash
# Main branch: shared BSP
git checkout main

# Create project branches
git checkout -b project/weather-station
# ... develop weather station ...

git checkout -b project/media-player
# ... develop media player ...

# Merge BSP fixes to all projects
git checkout main
# ... fix BSP bug ...
git commit -m "Fix display driver bug"

git checkout project/weather-station
git merge main  # Get BSP fixes

git checkout project/media-player
git merge main  # Get BSP fixes
```

**When to use branches:**
- Projects are experimental or prototypes
- Projects have very different dependencies
- You want clean project history
- Team members work on different projects

---

## Summary

**Recommended for most use cases:** Multi-environment setup with shared BSP library
- ✅ Easy to manage
- ✅ No code duplication
- ✅ All projects accessible simultaneously
- ✅ Clean build separation
- ✅ Flexible per-project configuration

Start with the migration script above, then create new projects using the template provided in Step 4.
