# Projects Directory

This directory contains individual projects for the JC3248W535EN ESP32-S3 display board.

## Current Projects

### demo_lvgl

Original LVGL demonstration project showing widgets, benchmarks, and other demos.

**Quick Start (Windows):**

```cmd
cd projects\demo_lvgl
build.bat       REM Build the project
upload.bat      REM Build and upload to device
monitor.bat     REM Open serial monitor
clean.bat       REM Clean build (needed after config changes)
```

## Creating a New Project

1. **Create project directory:**
   ```bash
   mkdir -p projects/my_project/src
   ```

2. **Copy template files:**
   ```bash
   cp projects/demo_lvgl/src/lv_conf.h projects/my_project/src/
   cp projects/demo_lvgl/sdkconfig.defaults projects/my_project/
   ```

3. **Create main.c:**
   ```bash
   cat > projects/my_project/src/main.c << 'EOF'
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

       lv_obj_t *label = lv_label_create(lv_scr_act());
       lv_label_set_text(label, "My New Project");
       lv_obj_center(label);

       bsp_display_unlock();

       ESP_LOGI(TAG, "Initialization complete");
   }
   EOF
   ```

4. **Update platformio.ini:**
   - Change `src_dir = projects/my_project/src` in the `[platformio]` section
   - Or add a new environment (see template in platformio.ini)

5. **Build and test:**
   ```bash
   pio run -e demo_lvgl  # if using environments
   # or just:
   pio run               # if you changed src_dir
   ```

## Shared Resources

All projects share:
- **Board Support Package (BSP):** `libraries/esp_bsp/` - Display, touch, and hardware drivers
- **LVGL Library:** `libraries/lvgl/` - Graphics library
- **Board Definition:** `boards/320x480.json` - Hardware configuration

## Project Structure

Each project should follow this structure:

```
projects/my_project/
├── src/
│   ├── main.c              # Application entry point
│   ├── lv_conf.h           # LVGL configuration
│   └── [other .c/.h files] # Your application code
├── sdkconfig.defaults      # ESP-IDF configuration
├── build.bat               # Windows: Build script
├── upload.bat              # Windows: Upload script
├── monitor.bat             # Windows: Serial monitor script
├── clean.bat               # Windows: Clean build script
└── README.md               # Project documentation (optional)
```

### Batch File Templates (Windows)

Each project should have these batch files for easy development:

#### build.bat

```bat
@echo off
set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"
powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/my_project/src' | Set-Content platformio.ini"
pio run
```

#### upload.bat

```bat
@echo off
set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"
powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/my_project/src' | Set-Content platformio.ini"
pio run -t upload
```

#### monitor.bat

```bat
@echo off
set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"
powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/my_project/src' | Set-Content platformio.ini"
pio device monitor
```

#### clean.bat

```bat
@echo off
set PROJECT_ROOT=%~dp0..\..
cd /d "%PROJECT_ROOT%"
powershell -Command "(Get-Content platformio.ini) -replace 'src_dir = projects/.*/src', 'src_dir = projects/my_project/src' | Set-Content platformio.ini"
pio run -t fullclean
```

**Note:** Replace `my_project` with your actual project name in all batch files.

## Tips

- **Different LVGL configs:** Each project can enable/disable different LVGL features in its `lv_conf.h`
- **Different SDK configs:** Each project can have different ESP-IDF settings in `sdkconfig.defaults`
- **Share code:** Create libraries in `libraries/` for code shared across projects
- **Clean builds:** Use `pio run -t fullclean` after changing configurations
