#!/bin/bash

# Anime-themed Theme Toggle Script
# -------------------------------
# This script toggles between light and dark anime themes

# Configuration
THEME_FILE="$HOME/.config/hypr/theme.txt"
CURRENT_THEME="dark"

# Function to check current theme
check_theme() {
    if [ -f "$THEME_FILE" ]; then
        CURRENT_THEME=$(cat "$THEME_FILE")
    else
        echo "dark" > "$THEME_FILE"
        CURRENT_THEME="dark"
    fi
}

# Function to toggle theme
toggle_theme() {
    if [ "$CURRENT_THEME" = "dark" ]; then
        # Switch to light theme
        echo "light" > "$THEME_FILE"
        CURRENT_THEME="light"
        
        # Apply light theme settings
        hyprctl keyword general:col.active_border "rgba(ff69b4ff) rgba(ff1493ff) 45deg"
        hyprctl keyword general:col.inactive_border "rgba(595959aa)"
        hyprctl keyword decoration:col.shadow "rgba(1a1a1aee)"
        
        # Reload waybar
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Theme" "Light anime theme activated! 🌞" -i "$HOME/.config/hypr/icons/light-theme.png"
        
        echo "Light anime theme activated!"
    else
        # Switch to dark theme
        echo "dark" > "$THEME_FILE"
        CURRENT_THEME="dark"
        
        # Apply dark theme settings
        hyprctl keyword general:col.active_border "rgba(ff69b4ff) rgba(ff1493ff) 45deg"
        hyprctl keyword general:col.inactive_border "rgba(595959aa)"
        hyprctl keyword decoration:col.shadow "rgba(1a1a1aee)"
        
        # Reload waybar
        pkill -SIGUSR2 waybar
        
        # Show notification
        notify-send "Theme" "Dark anime theme activated! 🌙" -i "$HOME/.config/hypr/icons/dark-theme.png"
        
        echo "Dark anime theme activated!"
    fi
}

# Main function
main() {
    # Check current theme
    check_theme
    
    # Toggle theme
    toggle_theme
}

# Run the main function
main 