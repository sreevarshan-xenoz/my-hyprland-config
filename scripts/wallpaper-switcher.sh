#!/bin/bash

# Anime Wallpaper Switcher Script
# ------------------------------
# This script randomly selects a wallpaper from the wallpapers directory
# and applies it using swww, then updates the color scheme with pywal

# Configuration
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CURRENT_WALLPAPER="$HOME/.config/hypr/wallpapers/current.txt"
TRANSITION_TYPE="wipe"  # Options: simple, left, right, top, bottom, wipe, grow, center, outer, random

# Create wallpapers directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Check if there are any wallpapers in the directory
if [ -z "$(ls -A $WALLPAPER_DIR/*.jpg $WALLPAPER_DIR/*.png 2>/dev/null)" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    echo "Please add some anime wallpapers to $WALLPAPER_DIR"
    exit 1
fi

# Function to get a random wallpaper
get_random_wallpaper() {
    # Get all jpg and png files in the wallpaper directory
    local wallpapers=($WALLPAPER_DIR/*.jpg $WALLPAPER_DIR/*.png)
    
    # Get the current wallpaper if it exists
    local current_wallpaper=""
    if [ -f "$CURRENT_WALLPAPER" ]; then
        current_wallpaper=$(cat "$CURRENT_WALLPAPER")
    fi
    
    # Select a random wallpaper that's different from the current one
    local random_wallpaper
    while true; do
        random_wallpaper=${wallpapers[$RANDOM % ${#wallpapers[@]}]}
        if [ "$random_wallpaper" != "$current_wallpaper" ] || [ ${#wallpapers[@]} -eq 1 ]; then
            break
        fi
    done
    
    echo "$random_wallpaper"
}

# Get a random wallpaper
new_wallpaper=$(get_random_wallpaper)

# Save the current wallpaper
echo "$new_wallpaper" > "$CURRENT_WALLPAPER"

# Apply the wallpaper with swww
swww img "$new_wallpaper" --transition-type "$TRANSITION_TYPE" --transition-duration 1

# Update the color scheme with pywal
wal -i "$new_wallpaper" -n

# Reload waybar to apply the new colors
pkill -SIGUSR2 waybar

# Display a notification
notify-send "Wallpaper Changed" "New anime wallpaper applied: $(basename "$new_wallpaper")" -i "$new_wallpaper"

# Play a sound effect (optional)
# paplay "$HOME/.config/hypr/sounds/wallpaper-change.wav"

echo "Wallpaper changed to: $new_wallpaper" 