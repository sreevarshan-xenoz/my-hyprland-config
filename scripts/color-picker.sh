#!/bin/bash

# Anime-themed Color Picker Script
# --------------------------------
# This script allows users to pick colors from the screen
# with anime-themed notifications

# Configuration
COLOR_ICON="$HOME/.config/hypr/icons/color.png"
PICK_SOUND="$HOME/.config/hypr/sounds/pick.wav"
COPY_SOUND="$HOME/.config/hypr/sounds/copy.wav"

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to use simpler color picker (reduces resource usage)
USE_SIMPLE_PICKER=true

# Function to play sound (with performance check)
play_sound() {
    if [ "$DISABLE_SOUNDS" = false ] && [ -f "$1" ]; then
        paplay "$1" &
    fi
}

# Function to send notification (with performance check)
send_notification() {
    if [ "$DISABLE_NOTIFICATIONS" = false ]; then
        notify-send "$1" "$2" -i "$3"
    fi
}

# Function to check if required tools are installed
check_dependencies() {
    local missing_deps=()
    
    # Check for hyprpicker
    if ! command -v hyprpicker &> /dev/null; then
        missing_deps+=("hyprpicker")
    fi
    
    # Check for wl-copy
    if ! command -v wl-copy &> /dev/null; then
        missing_deps+=("wl-copy")
    fi
    
    # Check for convert (ImageMagick)
    if ! command -v convert &> /dev/null; then
        missing_deps+=("imagemagick")
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Color Picker" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$COLOR_ICON"
        exit 1
    fi
}

# Function to pick a color
pick_color() {
    # Check dependencies
    check_dependencies
    
    # Play pick sound
    play_sound "$PICK_SOUND"
    
    # Pick color
    if [ "$USE_SIMPLE_PICKER" = true ]; then
        # Simpler picker for low-end devices
        color=$(hyprpicker -n)
    else
        # Full picker with preview
        color=$(hyprpicker)
    fi
    
    # Check if color was picked successfully
    if [ -n "$color" ]; then
        # Copy color to clipboard
        echo -n "$color" | wl-copy
        
        # Play copy sound
        play_sound "$COPY_SOUND"
        
        # Show success notification
        send_notification "Color Picker" "Color $color copied to clipboard!" -i "$COLOR_ICON"
        
        # Create a small color preview
        convert -size 100x100 xc:"$color" /tmp/color_preview.png
        
        # Show color preview
        if [ "$DISABLE_NOTIFICATIONS" = false ]; then
            notify-send "Color Preview" "" -i /tmp/color_preview.png
        fi
        
        echo "$color"
    else
        # Show error notification
        send_notification "Color Picker" "No color was picked." -i "$COLOR_ICON"
        
        echo "No color was picked."
    fi
}

# Function to detect system capabilities and adjust settings
detect_system_capabilities() {
    # Check CPU cores
    local cpu_cores=$(nproc 2>/dev/null || echo 2)
    
    # Check available memory
    local available_memory=$(free -m | awk '/^Mem:/ {print $7}' 2>/dev/null || echo 1024)
    
    # Adjust settings based on system capabilities
    if [ "$cpu_cores" -le 2 ] || [ "$available_memory" -lt 2048 ]; then
        # Low-end device detected
        DISABLE_SOUNDS=true
        DISABLE_NOTIFICATIONS=false
        USE_SIMPLE_PICKER=true
    fi
}

# Main function
main() {
    # Detect system capabilities
    detect_system_capabilities
    
    # Check the argument
    case "$1" in
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_PICKER=true
            send_notification "Color Picker" "Low-end mode enabled" -i "$COLOR_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_PICKER=false
            send_notification "Color Picker" "High-end mode enabled" -i "$COLOR_ICON"
            ;;
        *)
            # Pick color
            pick_color
            ;;
    esac
}

# Run the main function
main "$@" 