# Weather Station Project

A weather station UI demonstration for the JC3248W535EN ESP32-S3 display board.

![Weather Station UI](../../docs/weather_station_preview.png)

## Features

- **Real-time Display:**
  - Temperature reading with trend chart
  - Humidity percentage
  - Current time (HH:MM format)
  - Date display

- **Modern UI:**
  - Dark theme design
  - Color-coded sensors (orange for temperature, teal for humidity)
  - Live temperature chart with 20 data points
  - Smooth LVGL animations

- **Landscape Mode:**
  - 480x320 display (90° rotation)
  - Optimized layout for horizontal viewing

## Quick Start

### Build and Upload

```cmd
cd projects\weather_station
build.bat       # Compile the project
upload.bat      # Flash to device
monitor.bat     # View serial output
```

### Clean Build

After modifying configuration files:

```cmd
clean.bat       # Full clean
build.bat       # Rebuild
```

## Current Implementation

### Simulated Data

Currently uses **simulated sensor readings** for demonstration:

- Temperature: Random walk between 15°C and 35°C
- Humidity: Random walk between 30% and 80%
- Updates every 2 seconds

### Time/Date

Uses a placeholder timestamp. In production, sync with NTP server.

## Adding Real Sensors

### Option 1: DHT22 Temperature/Humidity Sensor

1. **Hardware Connection:**
   - VCC → 3.3V
   - GND → GND
   - DATA → GPIO (e.g., GPIO5)

2. **Add to platformio.ini:**
   ```ini
   lib_deps =
       ${common.lib_deps}
       adafruit/DHT sensor library
   ```

3. **Update main.c:**
   ```c
   #include "DHT.h"
   #define DHT_PIN 5
   #define DHT_TYPE DHT22
   DHT dht(DHT_PIN, DHT_TYPE);

   void app_main() {
       dht.begin();
       // ...
   }

   static void update_weather_display(void) {
       current_temperature = dht.readTemperature();
       current_humidity = dht.readHumidity();
       // ... rest of function
   }
   ```

### Option 2: BME280 (I2C) - Temperature, Humidity, Pressure

1. **Hardware Connection:**
   - VCC → 3.3V
   - GND → GND
   - SCL → GPIO8 (shared with display - see BSP)
   - SDA → GPIO4 (shared with display - see BSP)

2. **Add library dependency**

3. **Read sensor via I2C**

### Option 3: WiFi + Weather API

Fetch real weather data from online services:

- OpenWeatherMap API
- WeatherAPI
- Weather Underground

**Example steps:**
1. Connect to WiFi
2. Make HTTP request to API
3. Parse JSON response
4. Update display with live data

## Configuration

### Display Rotation

Current: 90° (landscape)

To change, edit `main.c`:

```c
bsp_display_cfg_t cfg = {
    // ...
    .rotate = LV_DISP_ROT_90,  // Change to 0, 90, 180, or 270
};
```

### Update Frequency

Current: 2 seconds

To change, edit `main.c`:

```c
// Update interval in milliseconds
lv_timer_create(update_timer_cb, 2000, NULL);  // Change 2000 to desired value
```

### Temperature Units

Current: Celsius

To add Fahrenheit, modify `update_weather_display()`:

```c
float temp_f = (current_temperature * 9.0 / 5.0) + 32.0;
snprintf(temp_str, sizeof(temp_str), "%.1f°F", temp_f);
```

### Timezone

Current: PST (UTC-8)

To change, edit `app_main()`:

```c
// Examples:
setenv("TZ", "EST5EDT,M3.2.0,M11.1.0", 1);    // Eastern Time
setenv("TZ", "CST6CDT,M3.2.0,M11.1.0", 1);    // Central Time
setenv("TZ", "MST7MDT,M3.2.0,M11.1.0", 1);    // Mountain Time
setenv("TZ", "UTC0", 1);                       // UTC
tzset();
```

## UI Customization

### Colors

Edit in `create_weather_ui()`:

```c
// Background
lv_obj_set_style_bg_color(scr, lv_color_hex(0x1E1E1E), 0);  // Dark gray

// Temperature color
lv_obj_set_style_text_color(label_temp, lv_color_hex(0xFF6B35), 0);  // Orange

// Humidity color
lv_obj_set_style_text_color(label_humidity, lv_color_hex(0x4ECDC4), 0);  // Teal
```

### Fonts

Available LVGL fonts (configured in lv_conf.h):
- `lv_font_montserrat_12` through `lv_font_montserrat_48`

Change font:

```c
lv_obj_set_style_text_font(label_time, &lv_font_montserrat_48, 0);
```

### Chart Settings

Modify chart behavior:

```c
lv_chart_set_point_count(chart, 20);           // Number of data points
lv_chart_set_range(chart, LV_CHART_AXIS_PRIMARY_Y, 0, 40);  // Y-axis range
```

## Extending the Project

### Add Weather Icons

Use LVGL image decoder to display weather condition icons:

```c
LV_IMG_DECLARE(img_sun);
LV_IMG_DECLARE(img_cloud);

lv_obj_t *img = lv_img_create(scr);
lv_img_set_src(img, &img_sun);
```

### Add Pressure Display

For BME280 sensor:

```c
lv_obj_t *label_pressure = lv_label_create(scr);
float pressure = bme.readPressure() / 100.0F;  // hPa
snprintf(str, sizeof(str), "%.1f hPa", pressure);
lv_label_set_text(label_pressure, str);
```

### Add Forecast

Fetch and display 5-day forecast from API

### Add Historical Data

Store data in SPIFFS/LittleFS and display trends

## Troubleshooting

### Display Issues

- Check display is properly initialized
- Verify 90° rotation in config
- Check LVGL buffer size

### Sensor Not Reading

- Verify I2C/GPIO connections
- Check sensor power (3.3V, not 5V)
- Add pull-up resistors if needed (4.7kΩ)
- Check I2C address (use I2C scanner)

### Time Not Updating

- Verify timer is created
- Check `update_timer_cb` is being called
- Add `ESP_LOGI` debug messages

## File Structure

```
projects/weather_station/
├── src/
│   ├── main.c              # Main application code
│   └── lv_conf.h           # LVGL configuration
├── sdkconfig.defaults      # ESP-IDF settings
├── build.bat               # Build script
├── upload.bat              # Upload script
├── monitor.bat             # Serial monitor
├── clean.bat               # Clean build
└── README.md               # This file
```

## Next Steps

1. **Add real sensors** (DHT22 or BME280)
2. **WiFi connectivity** for NTP time sync
3. **Weather API integration** for forecasts
4. **Touch interaction** (tap to switch units, etc.)
5. **Historical data** storage and graphs
6. **Alerts** for extreme conditions

## Resources

- LVGL Documentation: https://docs.lvgl.io/8.3/
- ESP-IDF API Reference: https://docs.espressif.com/projects/esp-idf/en/v5.3/
- BME280 Library: https://github.com/adafruit/Adafruit_BME280_Library
- OpenWeatherMap API: https://openweathermap.org/api

## License

Same as parent repository - see root LICENSE file.
