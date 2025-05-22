#!/bin/bash

# Anime-themed Brightness Manager Script
# -------------------------------------
# This script manages brightness with anime-themed notifications

# Configuration
BRIGHTNESS_ICON="$HOME/.config/hypr/icons/brightness.png"
BRIGHTNESS_UP_SOUND="$HOME/.config/hypr/sounds/brightness-up.wav"
BRIGHTNESS_DOWN_SOUND="$HOME/.config/hypr/sounds/brightness-down.wav"

# Function to check if brightnessctl is installed
check_brightnessctl() {
    if ! command -v brightnessctl &> /dev/null; then
        notify-send "Brightness Manager" "brightnessctl is not installed. Please install it to use this script." -i "$BRIGHTNESS_ICON"
        exit 1
    fi
}

# Function to get brightness
get_brightness() {
    # Check if brightnessctl is installed
    check_brightnessctl
    
    # Get brightness
    local brightness=$(brightnessctl get)
    local max_brightness=$(brightnessctl max)
    local percentage=$((brightness * 100 / max_brightness))
    
    echo "$percentage"
}

# Function to set brightness
set_brightness() {
    # Check if brightnessctl is installed
    check_brightnessctl
    
    # Get the brightness to set
    local brightness="$1"
    
    # Set brightness
    brightnessctl set "$brightness%"
    
    # Check if the brightness was set successfully
    if [ $? -eq 0 ]; then
        # Play a sound effect
        if [ "$brightness" -gt "$(get_brightness)" ]; then
            paplay "$BRIGHTNESS_UP_SOUND" &
        else
            paplay "$BRIGHTNESS_DOWN_SOUND" &
        fi
        
        # Show success notification
        notify-send "Brightness Manager" "Brightness set to $brightness%" -i "$BRIGHTNESS_ICON"
        
        echo "Brightness set to $brightness%"
    else
        # Show error notification
        notify-send "Brightness Manager" "Failed to set brightness" -i "$BRIGHTNESS_ICON"
        
        echo "Failed to set brightness"
    fi
}

# Function to increase brightness
increase_brightness() {
    # Check if brightnessctl is installed
    check_brightnessctl
    
    # Get current brightness
    local brightness=$(get_brightness)
    
    # Increase brightness by 5%
    local new_brightness=$((brightness + 5))
    
    # Cap at 100%
    if [ "$new_brightness" -gt 100 ]; then
        new_brightness=100
    fi
    
    # Set brightness
    set_brightness "$new_brightness"
}

# Function to decrease brightness
decrease_brightness() {
    # Check if brightnessctl is installed
    check_brightnessctl
    
    # Get current brightness
    local brightness=$(get_brightness)
    
    # Decrease brightness by 5%
    local new_brightness=$((brightness - 5))
    
    # Cap at 0%
    if [ "$new_brightness" -lt 0 ]; then
        new_brightness=0
    fi
    
    # Set brightness
    set_brightness "$new_brightness"
}

# Function to show brightness information
show_brightness_info() {
    # Check if brightnessctl is installed
    check_brightnessctl
    
    # Get brightness
    local brightness=$(get_brightness)
    
    # Get device
    local device=$(brightnessctl -l | head -n 1 | awk '{print $2}')
    
    # Show brightness information
    notify-send "Brightness Manager" "Brightness: $brightness%\nDevice: $device" -i "$BRIGHTNESS_ICON"
    
    # Return the values for display
    echo "Brightness: $brightness% | Device: $device"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "brightness")
            get_brightness
            ;;
        "set")
            set_brightness "$2"
            ;;
        "up")
            increase_brightness
            ;;
        "down")
            decrease_brightness
            ;;
        "info")
            show_brightness_info
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Show Brightness\nSet Brightness\nIncrease Brightness\nDecrease Brightness\nShow Brightness Information" | wofi --dmenu --prompt "Brightness Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Show Brightness")
                    get_brightness
                    ;;
                "Set Brightness")
                    brightness=$(wofi --dmenu --prompt "Enter Brightness (0-100)" --style "$HOME/.config/wofi/power-menu.css")
                    set_brightness "$brightness"
                    ;;
                "Increase Brightness")
                    increase_brightness
                    ;;
                "Decrease Brightness")
                    decrease_brightness
                    ;;
                "Show Brightness Information")
                    show_brightness_info
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 