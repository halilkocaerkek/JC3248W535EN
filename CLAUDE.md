# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **multi-project repository** for the JC3248W535EN ESP32-S3 display board with a 3.5-inch capacitive touch LCD (320×480 resolution). It uses PlatformIO with ESP-IDF 5.3 framework and includes a shared Board Support Package (BSP) that multiple projects can use.

**Hardware:** ESP32-S3 dual-core @ 240MHz, 8MB PSRAM, 16MB Flash, AXS15231B display controller (QSPI interface + I2C touch)

**Repository Structure:**

- `projects/` - Individual application projects
- `libraries/esp_bsp/` - Shared BSP (display, touch, LVGL port)
- `libraries/lvgl/` - LVGL graphics library
- `boards/` - Custom board definitions

## Build Commands

```bash
# Build the default project (demo_lvgl)
pio run

# Build specific project (if using environments)
pio run -e demo_lvgl

# Upload to device
pio run -t upload

# Monitor serial output with ESP32 exception decoder
pio device monitor

# Build and upload
pio run -t upload && pio device monitor

# Clean build (forces CMake reconfiguration)
pio run -t fullclean
```

**Note:** After modifying `sdkconfig.defaults` or Kconfig options, you must run `fullclean` to regenerate configuration files.

## Configuration System

This project uses ESP-IDF's Kconfig system alongside LVGL's configuration:

### ESP-IDF Configuration (sdkconfig)
- **`sdkconfig.defaults`** - Default configuration applied on clean builds
- **`sdkconfig.LVGL-320-480`** - Generated active configuration (don't manually edit unless necessary)
- **Location:** Root directory

**Key configuration pattern:** LVGL demos require BOTH Kconfig and lv_conf.h settings:
```
sdkconfig.defaults:
CONFIG_LV_USE_DEMO_BENCHMARK=y

src/lv_conf.h:
#define LV_USE_DEMO_BENCHMARK 1
```

The Kconfig setting (`CONFIG_LV_USE_DEMO_*`) controls whether source files are compiled/linked. The lv_conf.h setting controls header declarations. Both must be enabled.

### LVGL Configuration (lv_conf.h)
- **Primary config:** `src/lv_conf.h` (specified in platformio.ini via `LV_CONF_PATH`)
- **Duplicates exist** in `libraries/` and `JC3248W535EN/` directories for compatibility

**Important:** When modifying LVGL configuration, update ALL lv_conf.h files to maintain consistency across demos.

## Architecture

### Component Layers
```
Application (DEMO_LVGL.c)
    ↓
Board Support Package (esp_bsp.c/h)
    ↓
├─ Display Driver (esp_lcd_axs15231b.c/h)
├─ Touch Controller (esp_lcd_touch.c/h)
└─ LVGL Port (lv_port.c/h)
    ↓
ESP-IDF (SPI, I2C, GPIO, LEDC, FreeRTOS)
```

### Key Components

**BSP (Board Support Package) - esp_bsp.c/h:**
- One-call initialization: `bsp_display_start_with_config()`
- Hardware abstraction for display, touch, backlight, I2C
- Thread-safe LVGL access via `bsp_display_lock()` / `bsp_display_unlock()`
- Backlight control: `bsp_display_brightness_set(0-100)`

**Display Driver - esp_lcd_axs15231b.c/h:**
- QSPI interface (4-bit parallel data on SPI2_HOST)
- Tear Effect (TE) synchronization for flicker-free updates
- 67-command initialization sequence with vendor-specific parameters
- RGB565 color format with byte swapping

**LVGL Port - lv_port.c/h:**
- FreeRTOS task (Priority 4, 4KB stack) running LVGL event loop
- ESP Timer for `lv_tick_inc()` callbacks (5ms period)
- Double buffering with PSRAM allocation (full 320×480 buffers)
- Touch input integration via `lv_indev_read()` callback

### Hardware Pinout

**QSPI Display (SPI2_HOST):**
- CS: GPIO 45, PCLK: GPIO 47
- DATA0-3: GPIO 21, 48, 40, 39
- DC: GPIO 8, TE: GPIO 38, BL: GPIO 1

**I2C Touch (I2C_NUM_0):**
- SDA: GPIO 4, SCL: GPIO 8 (shared with LCD DC)
- Speed: 400kHz

### Threading and Synchronization

**Tasks:**
- LVGL Task (Priority 4) - UI rendering and event handling
- Tear Sync Task (Priority 4) - Synchronizes SPI transfers with VBLANK

**Synchronization:**
- LVGL Mutex (recursive) - Protects all LVGL API calls
- Touch Spinlock (`portMUX_TYPE`) - Protects touch data structure
- Semaphores: `te_v_sync_sem`, `trans_done_sem`, `tp_intr_event`

**Critical:** Always acquire LVGL mutex before calling LVGL APIs:
```c
bsp_display_lock(0);
lv_demo_widgets();  // or any LVGL function
bsp_display_unlock();
```

### Memory Allocation

**PSRAM (8MB SPIRAM):**
- LVGL framebuffers: 307KB (320×480×2 bytes)
- Layer buffers: 24KB + 3KB fallback
- Custom LVGL allocations via `malloc()`

**Internal RAM:**
- FreeRTOS task stacks
- Driver contexts
- Interrupt handlers

## Display Configuration

**Current setup (90° rotation):**
- Physical: 320×480 portrait panel
- Logical: 480×320 landscape (after rotation)
- Configured in `DEMO_LVGL.c`: `cfg.rotate = LV_DISP_ROT_90`

**To change rotation:**
1. Modify `LVGL_PORT_ROTATION_DEGREE` in `DEMO_LVGL.c`
2. Update `cfg.rotate` in the setup function
3. Rebuild (rotation is compile-time, not runtime)

## Common Development Tasks

### Enabling LVGL Demos

To enable a different demo (e.g., benchmark, music, stress):

1. **Edit sdkconfig.defaults:**
```
CONFIG_LV_USE_DEMO_BENCHMARK=y
```

2. **Edit src/lv_conf.h:**
```c
#define LV_USE_DEMO_BENCHMARK 1
```

3. **Sync all lv_conf.h files** (if maintaining compatibility with Arduino demos):
```bash
cp src/lv_conf.h libraries/lv_conf.h
cp src/lv_conf.h JC3248W535EN/1-Demo/Demo_Arduino/DEMO_LVGL/lv_conf.h
# ... etc
```

4. **Clean and rebuild:**
```bash
pio run -e LVGL-320-480 -t fullclean
pio run -e LVGL-320-480
```

5. **Update DEMO_LVGL.c to call the demo:**
```c
bsp_display_lock(0);
lv_demo_benchmark();  // Change this line
bsp_display_unlock();
```

### Debugging Display Issues

**Tear Effect (TE) synchronization:**
- TE signal on GPIO 38 provides V-Sync timing
- Timing windows: 13ms display update, 3ms safe transfer window
- If you see tearing, check TE ISR is triggering: add logging in `te_gpio_isr_handler()`

**Common issues:**
- **Linker errors for demo functions:** Missing Kconfig setting (`CONFIG_LV_USE_DEMO_*`)
- **Display not initializing:** Check QSPI GPIO connections, verify 3.3V power
- **Touch not working:** Verify I2C bus (400kHz), check GPIO 4/8 connections
- **Flicker/tearing:** TE signal may not be connected or ISR not configured

### Modifying BSP

The Board Support Package (`esp_bsp.c/h`) encapsulates all hardware-specific code. To port to a different display:

1. Replace `esp_lcd_axs15231b.c/h` with your display driver
2. Update GPIO definitions in `esp_bsp.h`
3. Modify `bsp_display_new()` initialization sequence
4. Adjust `bsp_display_cfg_t` defaults if needed
5. Update `display.h` with new resolution/format

## Known Constraints

1. **ESP-IDF 5.3.0 required:** Display driver uses APIs not in earlier versions
2. **QSPI interface only:** Driver doesn't support standard SPI mode
3. **Single-touch only:** Multi-touch disabled in configuration (`CONFIG_ESP_LCD_TOUCH_MAX_POINTS=1`)
4. **No rotation at runtime:** Display rotation is compile-time configuration
5. **Full-screen buffers:** 307KB PSRAM usage per buffer (double buffering = 614KB)

## Project Structure Notes

- **`src/`** - Active project source code (~4000 LOC)
- **`libraries/lvgl/`** - LVGL 8.4.0 (use 8.3.x compatible code)
- **`boards/320x480.json`** - Custom PlatformIO board definition
- **`docs/`** - Hardware schematics, specifications, getting started guide
- **`JC3248W535EN/`** - Original manufacturer files (reference only, not used in build)

## Documentation References

- Hardware specs: `docs/JC3248W535 Specifications-EN.pdf`
- Getting started: `docs/Getting started JC3248W535.pdf`
- GPIO pinout: `docs/GPIO_pinout.jpg`
- Schematics: `docs/ESP32_schematic.jpg`, `docs/Power_schematic.jpg`
- LVGL docs: https://docs.lvgl.io/8.3/
- ESP-IDF docs: https://docs.espressif.com/projects/esp-idf/en/v5.3/

## Multi-Project Management

### Creating a New Project

1. Create project directory:

   ```bash
   mkdir -p projects/my_project/src
   ```

2. Copy template files:

   ```bash
   cp projects/demo_lvgl/src/lv_conf.h projects/my_project/src/
   cp projects/demo_lvgl/sdkconfig.defaults projects/my_project/
   ```

3. Create your `main.c` in `projects/my_project/src/main.c`

4. Update `platformio.ini` - change the `src_dir` in the `[platformio]` section:

   ```ini
   [platformio]
   src_dir = projects/my_project/src
   ```

5. Build:

   ```bash
   pio run -t fullclean  # Clean old build
   pio run               # Build new project
   ```

### Switching Between Projects

To switch to a different project, edit `platformio.ini`:

```ini
[platformio]
src_dir = projects/weather_station/src  # Change this line
```

Then clean and rebuild:

```bash
pio run -t fullclean
pio run
```

### Shared BSP Library

All projects share the same BSP in `libraries/esp_bsp/`:

- `esp_bsp.c/h` - Board support package (display init, backlight, I2C)
- `esp_lcd_axs15231b.c/h` - Display driver
- `esp_lcd_touch.c/h` - Touch controller
- `lv_port.c/h` - LVGL porting layer
- `display.h` - Hardware configuration
- `bsp_err_check.h` - Error checking macros

When you fix a bug or add a feature in the BSP, **all projects automatically get the update** on next build.

## Build System Details

**PlatformIO → ESP-IDF CMake Integration:**

- PlatformIO uses `espressif32` platform (v6.6.0)
- CMake handles ESP-IDF component discovery and linking
- Each project has auto-generated CMakeLists.txt
- `libraries/esp_bsp/CMakeLists.txt` registers BSP as ESP-IDF component
- `libraries/lvgl/env_support/cmake/esp.cmake` handles LVGL component registration

**Key build flags:**

- `LOG_LOCAL_LEVEL=ESP_LOG_VERBOSE` - Full debug logging (reduce if performance critical)
- `LV_CONF_PATH` - Points to project-specific LVGL config

**Partition table:**

- 16MB flash, default partition scheme
- OTA updates not configured in current setup
- Filesystem: LittleFS (configured but not used in demo)
