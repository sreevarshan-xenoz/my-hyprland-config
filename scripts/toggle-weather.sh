#!/bin/bash

# Anime-themed Weather Widget Toggle Script
# ----------------------------------------
# This script toggles the visibility of the weather widget in Waybar

# Configuration
WEATHER_FILE="$HOME/.config/hypr/weather-visible.txt"
WEATHER_VISIBLE=0

# Function to check if weather widget is visible
check_weather_visibility() {
    if [ -f "$WEATHER_FILE" ]; then
        WEATHER_VISIBLE=$(cat "$WEATHER_FILE")
    else
        echo "0" > "$WEATHER_FILE"
        WEATHER_VISIBLE=0
    fi
}

# Function to toggle weather widget visibility
toggle_weather() {
    if [ "$WEATHER_VISIBLE" -eq 0 ]; then
        # Show weather widget
        echo "1" > "$WEATHER_FILE"
        WEATHER_VISIBLE=1
        
        # Reload waybar to show the weather widget
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Weather Widget" "Weather widget activated! 🌤️" -i "$HOME/.config/hypr/icons/weather.png"
        
        echo "Weather widget activated!"
    else
        # Hide weather widget
        echo "0" > "$WEATHER_FILE"
        WEATHER_VISIBLE=0
        
        # Reload waybar to hide the weather widget
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Weather Widget" "Weather widget deactivated! 🌤️" -i "$HOME/.config/hypr/icons/weather.png"
        
        echo "Weather widget deactivated!"
    fi
}

# Main function
main() {
    # Check if weather widget is visible
    check_weather_visibility
    
    # Toggle weather widget visibility
    toggle_weather
}

# Run the main function
main 