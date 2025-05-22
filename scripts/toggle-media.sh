#!/bin/bash

# Anime-themed Media Controls Toggle Script
# ----------------------------------------
# This script toggles the visibility of media controls in Waybar

# Configuration
MEDIA_FILE="$HOME/.config/hypr/media-visible.txt"
MEDIA_VISIBLE=0

# Function to check if media controls are visible
check_media_visibility() {
    if [ -f "$MEDIA_FILE" ]; then
        MEDIA_VISIBLE=$(cat "$MEDIA_FILE")
    else
        echo "0" > "$MEDIA_FILE"
        MEDIA_VISIBLE=0
    fi
}

# Function to toggle media controls visibility
toggle_media() {
    if [ "$MEDIA_VISIBLE" -eq 0 ]; then
        # Show media controls
        echo "1" > "$MEDIA_FILE"
        MEDIA_VISIBLE=1
        
        # Reload waybar to show media controls
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Media Controls" "Media controls activated! 🎵" -i "$HOME/.config/hypr/icons/media.png"
        
        echo "Media controls activated!"
    else
        # Hide media controls
        echo "0" > "$MEDIA_FILE"
        MEDIA_VISIBLE=0
        
        # Reload waybar to hide media controls
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Media Controls" "Media controls deactivated! 🎵" -i "$HOME/.config/hypr/icons/media.png"
        
        echo "Media controls deactivated!"
    fi
}

# Main function
main() {
    # Check if media controls are visible
    check_media_visibility
    
    # Toggle media controls visibility
    toggle_media
}

# Run the main function
main 