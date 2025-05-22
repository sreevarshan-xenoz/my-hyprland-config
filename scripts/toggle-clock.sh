#!/bin/bash

# Anime-themed Clock Widget Toggle Script
# --------------------------------------
# This script toggles the visibility of the clock widget in Waybar

# Configuration
CLOCK_FILE="$HOME/.config/hypr/clock-visible.txt"
CLOCK_VISIBLE=0

# Function to check if clock widget is visible
check_clock_visibility() {
    if [ -f "$CLOCK_FILE" ]; then
        CLOCK_VISIBLE=$(cat "$CLOCK_FILE")
    else
        echo "0" > "$CLOCK_FILE"
        CLOCK_VISIBLE=0
    fi
}

# Function to toggle clock widget visibility
toggle_clock() {
    if [ "$CLOCK_VISIBLE" -eq 0 ]; then
        # Show clock widget
        echo "1" > "$CLOCK_FILE"
        CLOCK_VISIBLE=1
        
        # Reload waybar to show the clock widget
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Clock Widget" "Clock widget activated! 🕒" -i "$HOME/.config/hypr/icons/clock.png"
        
        echo "Clock widget activated!"
    else
        # Hide clock widget
        echo "0" > "$CLOCK_FILE"
        CLOCK_VISIBLE=0
        
        # Reload waybar to hide the clock widget
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Clock Widget" "Clock widget deactivated! 🕒" -i "$HOME/.config/hypr/icons/clock.png"
        
        echo "Clock widget deactivated!"
    fi
}

# Main function
main() {
    # Check if clock widget is visible
    check_clock_visibility
    
    # Toggle clock widget visibility
    toggle_clock
}

# Run the main function
main 