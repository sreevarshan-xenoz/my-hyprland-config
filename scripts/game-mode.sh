#!/bin/bash

# Anime-themed Game Mode Script
# ----------------------------
# This script toggles a special gaming layout for Hyprland

# Configuration
GAME_MODE_FILE="$HOME/.config/hypr/game-mode.txt"
GAME_MODE_ACTIVE=0

# Function to check if game mode is active
check_game_mode() {
    if [ -f "$GAME_MODE_FILE" ]; then
        GAME_MODE_ACTIVE=$(cat "$GAME_MODE_FILE")
    else
        echo "0" > "$GAME_MODE_FILE"
        GAME_MODE_ACTIVE=0
    fi
}

# Function to toggle game mode
toggle_game_mode() {
    if [ "$GAME_MODE_ACTIVE" -eq 0 ]; then
        # Enable game mode
        echo "1" > "$GAME_MODE_FILE"
        GAME_MODE_ACTIVE=1
        
        # Apply game mode settings
        hyprctl keyword general:gaps_in 0
        hyprctl keyword general:gaps_out 0
        hyprctl keyword decoration:rounding 0
        hyprctl keyword decoration:blur:enabled false
        hyprctl keyword decoration:drop_shadow false
        hyprctl keyword general:border_size 0
        
        # Hide waybar
        pkill -SIGUSR2 waybar
        
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/game-mode-on.wav" &
        
        # Show notification
        notify-send "Game Mode" "Game mode activated! 🎮" -i "$HOME/.config/hypr/icons/game-mode.png"
        
        echo "Game mode activated!"
    else
        # Disable game mode
        echo "0" > "$GAME_MODE_FILE"
        GAME_MODE_ACTIVE=0
        
        # Restore normal settings
        hyprctl keyword general:gaps_in 5
        hyprctl keyword general:gaps_out 10
        hyprctl keyword decoration:rounding 10
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword decoration:drop_shadow true
        hyprctl keyword general:border_size 2
        
        # Show waybar
        waybar &
        
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/game-mode-off.wav" &
        
        # Show notification
        notify-send "Game Mode" "Game mode deactivated! 🎮" -i "$HOME/.config/hypr/icons/game-mode.png"
        
        echo "Game mode deactivated!"
    fi
}

# Main function
main() {
    # Check if game mode is active
    check_game_mode
    
    # Toggle game mode
    toggle_game_mode
}

# Run the main function
main 