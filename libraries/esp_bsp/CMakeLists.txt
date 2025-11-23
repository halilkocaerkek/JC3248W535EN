# ESP32-S3 Display Board Support Package
# CMakeLists.txt for ESP-IDF component

idf_component_register(
    SRCS
        "esp_bsp.c"
        "esp_lcd_axs15231b.c"
        "esp_lcd_touch.c"
        "lv_port.c"
    INCLUDE_DIRS
        "."
    REQUIRES
        driver
        esp_lcd
        esp_timer
        lvgl
)
