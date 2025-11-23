/**
 * @file main.c
 * @brief Weather Station Project for JC3248W535EN Display
 *
 * This project demonstrates a weather station UI using LVGL.
 * Features:
 * - Temperature display
 * - Humidity display
 * - Weather icon
 * - Time/date display
 * - Chart for historical data
 */

#include <lvgl.h>
#include "esp_bsp.h"
#include "lv_port.h"
#include <esp_log.h>
#include <time.h>
#include <sys/time.h>

static const char *TAG = "WEATHER_STATION";

// UI Elements
static lv_obj_t *label_temp;
static lv_obj_t *label_humidity;
static lv_obj_t *label_time;
static lv_obj_t *label_date;
static lv_obj_t *chart;
static lv_chart_series_t *temp_series;

// Simulated sensor data (replace with real sensor readings)
static float current_temperature = 22.5;
static float current_humidity = 55.0;

/**
 * @brief Update time display
 */
static void update_time_display(void)
{
    time_t now;
    struct tm timeinfo;
    char time_str[16];
    char date_str[32];

    time(&now);
    localtime_r(&now, &timeinfo);

    // Format time (HH:MM)
    strftime(time_str, sizeof(time_str), "%H:%M", &timeinfo);

    // Format date (Day, Mon DD)
    strftime(date_str, sizeof(date_str), "%A, %b %d", &timeinfo);

    bsp_display_lock(0);
    lv_label_set_text(label_time, time_str);
    lv_label_set_text(label_date, date_str);
    bsp_display_unlock();
}

/**
 * @brief Update weather data display
 */
static void update_weather_display(void)
{
    char temp_str[32];
    char humidity_str[32];

    // Simulate temperature variation (replace with real sensor reading)
    current_temperature += ((float)(rand() % 20) - 10) / 10.0;
    if (current_temperature < 15.0) current_temperature = 15.0;
    if (current_temperature > 35.0) current_temperature = 35.0;

    // Simulate humidity variation (replace with real sensor reading)
    current_humidity += ((float)(rand() % 20) - 10) / 5.0;
    if (current_humidity < 30.0) current_humidity = 30.0;
    if (current_humidity > 80.0) current_humidity = 80.0;

    snprintf(temp_str, sizeof(temp_str), "%.1f°C", current_temperature);
    snprintf(humidity_str, sizeof(humidity_str), "%.0f%%", current_humidity);

    bsp_display_lock(0);
    lv_label_set_text(label_temp, temp_str);
    lv_label_set_text(label_humidity, humidity_str);

    // Add data point to chart
    lv_chart_set_next_value(chart, temp_series, (int32_t)current_temperature);
    bsp_display_unlock();

    ESP_LOGI(TAG, "Temperature: %.1f°C, Humidity: %.0f%%", current_temperature, current_humidity);
}

/**
 * @brief Timer callback for periodic updates
 */
static void update_timer_cb(lv_timer_t *timer)
{
    update_time_display();
    update_weather_display();
}

/**
 * @brief Create the weather station UI
 */
static void create_weather_ui(void)
{
    lv_obj_t *scr = lv_scr_act();

    // Set background color
    lv_obj_set_style_bg_color(scr, lv_color_hex(0x1E1E1E), 0);

    // Title
    lv_obj_t *label_title = lv_label_create(scr);
    lv_label_set_text(label_title, "Weather Station");
    lv_obj_set_style_text_font(label_title, &lv_font_montserrat_28, 0);
    lv_obj_set_style_text_color(label_title, lv_color_hex(0xFFFFFF), 0);
    lv_obj_align(label_title, LV_ALIGN_TOP_MID, 0, 10);

    // Date/Time section
    label_date = lv_label_create(scr);
    lv_label_set_text(label_date, "---");
    lv_obj_set_style_text_font(label_date, &lv_font_montserrat_16, 0);
    lv_obj_set_style_text_color(label_date, lv_color_hex(0xAAAAAA), 0);
    lv_obj_align(label_date, LV_ALIGN_TOP_MID, 0, 50);

    label_time = lv_label_create(scr);
    lv_label_set_text(label_time, "--:--");
    lv_obj_set_style_text_font(label_time, &lv_font_montserrat_48, 0);
    lv_obj_set_style_text_color(label_time, lv_color_hex(0xFFFFFF), 0);
    lv_obj_align(label_time, LV_ALIGN_TOP_MID, 0, 75);

    // Temperature section
    lv_obj_t *temp_container = lv_obj_create(scr);
    lv_obj_set_size(temp_container, 200, 100);
    lv_obj_set_style_bg_color(temp_container, lv_color_hex(0x2E2E2E), 0);
    lv_obj_set_style_border_width(temp_container, 0, 0);
    lv_obj_set_style_radius(temp_container, 10, 0);
    lv_obj_align(temp_container, LV_ALIGN_CENTER, -110, 0);

    lv_obj_t *label_temp_title = lv_label_create(temp_container);
    lv_label_set_text(label_temp_title, "Temperature");
    lv_obj_set_style_text_color(label_temp_title, lv_color_hex(0xAAAAAA), 0);
    lv_obj_align(label_temp_title, LV_ALIGN_TOP_MID, 0, 10);

    label_temp = lv_label_create(temp_container);
    lv_label_set_text(label_temp, "--°C");
    lv_obj_set_style_text_font(label_temp, &lv_font_montserrat_32, 0);
    lv_obj_set_style_text_color(label_temp, lv_color_hex(0xFF6B35), 0);
    lv_obj_align(label_temp, LV_ALIGN_CENTER, 0, 10);

    // Humidity section
    lv_obj_t *humidity_container = lv_obj_create(scr);
    lv_obj_set_size(humidity_container, 200, 100);
    lv_obj_set_style_bg_color(humidity_container, lv_color_hex(0x2E2E2E), 0);
    lv_obj_set_style_border_width(humidity_container, 0, 0);
    lv_obj_set_style_radius(humidity_container, 10, 0);
    lv_obj_align(humidity_container, LV_ALIGN_CENTER, 110, 0);

    lv_obj_t *label_humidity_title = lv_label_create(humidity_container);
    lv_label_set_text(label_humidity_title, "Humidity");
    lv_obj_set_style_text_color(label_humidity_title, lv_color_hex(0xAAAAAA), 0);
    lv_obj_align(label_humidity_title, LV_ALIGN_TOP_MID, 0, 10);

    label_humidity = lv_label_create(humidity_container);
    lv_label_set_text(label_humidity, "--%");
    lv_obj_set_style_text_font(label_humidity, &lv_font_montserrat_32, 0);
    lv_obj_set_style_text_color(label_humidity, lv_color_hex(0x4ECDC4), 0);
    lv_obj_align(label_humidity, LV_ALIGN_CENTER, 0, 10);

    // Temperature chart
    chart = lv_chart_create(scr);
    lv_obj_set_size(chart, 420, 120);
    lv_obj_align(chart, LV_ALIGN_BOTTOM_MID, 0, -10);
    lv_chart_set_type(chart, LV_CHART_TYPE_LINE);
    lv_chart_set_range(chart, LV_CHART_AXIS_PRIMARY_Y, 0, 40);
    lv_chart_set_point_count(chart, 20);
    lv_chart_set_update_mode(chart, LV_CHART_UPDATE_MODE_SHIFT);
    lv_obj_set_style_bg_color(chart, lv_color_hex(0x2E2E2E), 0);
    lv_obj_set_style_border_width(chart, 0, 0);

    // Add temperature series
    temp_series = lv_chart_add_series(chart, lv_color_hex(0xFF6B35), LV_CHART_AXIS_PRIMARY_Y);

    // Initialize chart with current temperature
    for (int i = 0; i < 20; i++) {
        lv_chart_set_next_value(chart, temp_series, (int32_t)current_temperature);
    }
}

void app_main()
{
    ESP_LOGI(TAG, "Starting Weather Station Application");

    // Initialize display with 90° rotation (landscape mode)
    bsp_display_cfg_t cfg = {
        .lvgl_port_cfg = ESP_LVGL_PORT_INIT_CONFIG(),
        .buffer_size = EXAMPLE_LCD_QSPI_H_RES * EXAMPLE_LCD_QSPI_V_RES,
        .rotate = LV_DISP_ROT_90,
    };

    bsp_display_start_with_config(&cfg);
    bsp_display_backlight_on();

    ESP_LOGI(TAG, "Display initialized");

    // Set timezone (adjust to your timezone)
    // Example: PST is UTC-8
    setenv("TZ", "PST8PDT,M3.2.0,M11.1.0", 1);
    tzset();

    // Set initial time (replace with NTP sync in real application)
    struct timeval tv = {
        .tv_sec = 1700000000,  // Placeholder timestamp
        .tv_usec = 0
    };
    settimeofday(&tv, NULL);

    // Create UI
    bsp_display_lock(0);
    create_weather_ui();
    bsp_display_unlock();

    ESP_LOGI(TAG, "UI created");

    // Create timer for periodic updates (every 2 seconds)
    lv_timer_create(update_timer_cb, 2000, NULL);

    // Initial update
    update_time_display();
    update_weather_display();

    ESP_LOGI(TAG, "Weather Station initialization complete");

    // Note: In a real application, you would:
    // 1. Connect to WiFi
    // 2. Sync time with NTP server
    // 3. Read data from actual sensors (DHT22, BME280, etc.)
    // 4. Optionally fetch weather data from API
}
