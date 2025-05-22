#!/bin/bash

# Anime-themed Screenshot Script
# -----------------------------
# This script takes screenshots with anime-themed notifications

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
SCREENSHOT_SOUND="$HOME/.config/hypr/sounds/screenshot.wav"

# Create screenshot directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Function to take a full screenshot
take_full_screenshot() {
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local filename="$SCREENSHOT_DIR/screenshot_$timestamp.png"
    
    # Take the screenshot
    grim "$filename"
    
    # Play a sound effect
    paplay "$SCREENSHOT_SOUND" &
    
    # Show notification
    notify-send "Screenshot" "Full screenshot saved to $filename" -i "$filename"
    
    echo "Screenshot saved to $filename"
}

# Function to take a region screenshot
take_region_screenshot() {
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local filename="$SCREENSHOT_DIR/screenshot_$timestamp.png"
    
    # Take the screenshot
    grim -g "$(slurp)" "$filename"
    
    # Play a sound effect
    paplay "$SCREENSHOT_SOUND" &
    
    # Show notification
    notify-send "Screenshot" "Region screenshot saved to $filename" -i "$filename"
    
    echo "Screenshot saved to $filename"
}

# Function to take a window screenshot
take_window_screenshot() {
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local filename="$SCREENSHOT_DIR/screenshot_$timestamp.png"
    
    # Get the active window
    local active_window=$(hyprctl activewindow -j | jq -r '.at')
    local window_geometry=$(hyprctl activewindow -j | jq -r '.at[0], .at[1], .size[0], .size[1]')
    
    # Take the screenshot
    grim -g "$window_geometry" "$filename"
    
    # Play a sound effect
    paplay "$SCREENSHOT_SOUND" &
    
    # Show notification
    notify-send "Screenshot" "Window screenshot saved to $filename" -i "$filename"
    
    echo "Screenshot saved to $filename"
}

# Function to copy screenshot to clipboard
copy_screenshot() {
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local filename="$SCREENSHOT_DIR/screenshot_$timestamp.png"
    
    # Take the screenshot
    grim -g "$(slurp)" "$filename"
    
    # Copy to clipboard
    wl-copy < "$filename"
    
    # Play a sound effect
    paplay "$SCREENSHOT_SOUND" &
    
    # Show notification
    notify-send "Screenshot" "Screenshot copied to clipboard" -i "$filename"
    
    echo "Screenshot copied to clipboard"
}

# Main function
main() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        notify-send "Screenshot" "jq is not installed. Please install it to use this script."
        exit 1
    fi
    
    # Check if grim is installed
    if ! command -v grim &> /dev/null; then
        notify-send "Screenshot" "grim is not installed. Please install it to use this script."
        exit 1
    fi
    
    # Check if slurp is installed
    if ! command -v slurp &> /dev/null; then
        notify-send "Screenshot" "slurp is not installed. Please install it to use this script."
        exit 1
    fi
    
    # Check if wl-copy is installed
    if ! command -v wl-copy &> /dev/null; then
        notify-send "Screenshot" "wl-copy is not installed. Please install it to use this script."
        exit 1
    fi
    
    # Check the argument
    case "$1" in
        "full")
            take_full_screenshot
            ;;
        "region")
            take_region_screenshot
            ;;
        "window")
            take_window_screenshot
            ;;
        "copy")
            copy_screenshot
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Full Screenshot\nRegion Screenshot\nWindow Screenshot\nCopy to Clipboard" | wofi --dmenu --prompt "Screenshot" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Full Screenshot")
                    take_full_screenshot
                    ;;
                "Region Screenshot")
                    take_region_screenshot
                    ;;
                "Window Screenshot")
                    take_window_screenshot
                    ;;
                "Copy to Clipboard")
                    copy_screenshot
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 