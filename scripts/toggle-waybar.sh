#!/bin/bash

# Anime-themed Waybar Toggle Script
# --------------------------------
# This script toggles the visibility of the Waybar

# Configuration
WAYBAR_FILE="$HOME/.config/hypr/waybar-visible.txt"
WAYBAR_VISIBLE=1

# Function to check if Waybar is visible
check_waybar_visibility() {
    if [ -f "$WAYBAR_FILE" ]; then
        WAYBAR_VISIBLE=$(cat "$WAYBAR_FILE")
    else
        echo "1" > "$WAYBAR_FILE"
        WAYBAR_VISIBLE=1
    fi
}

# Function to toggle Waybar visibility
toggle_waybar() {
    if [ "$WAYBAR_VISIBLE" -eq 1 ]; then
        # Hide Waybar
        echo "0" > "$WAYBAR_FILE"
        WAYBAR_VISIBLE=0
        
        # Hide Waybar
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Waybar" "Waybar hidden! 🎌" -i "$HOME/.config/hypr/icons/waybar.png"
        
        echo "Waybar hidden!"
    else
        # Show Waybar
        echo "1" > "$WAYBAR_FILE"
        WAYBAR_VISIBLE=1
        
        # Show Waybar
        waybar &
        
        # Show notification
        notify-send "Waybar" "Waybar shown! 🎌" -i "$HOME/.config/hypr/icons/waybar.png"
        
        echo "Waybar shown!"
    fi
}

# Main function
main() {
    # Check if Waybar is visible
    check_waybar_visibility
    
    # Toggle Waybar visibility
    toggle_waybar
}

# Run the main function
main 