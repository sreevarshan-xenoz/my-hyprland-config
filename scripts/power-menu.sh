#!/bin/bash

# Anime-themed Power Menu Script
# -----------------------------
# This script creates a beautiful anime-themed power menu using wofi

# Configuration
MENU_WIDTH=300
MENU_HEIGHT=400
MENU_POSITION="center"
MENU_FONT="JetBrainsMono Nerd Font 12"
MENU_BG_COLOR="#2d1b2e"
MENU_FG_COLOR="#f8f0e3"
MENU_ACCENT_COLOR="#ff69b4"

# Create a temporary file for the menu
TEMP_FILE=$(mktemp)

# Define the menu options with anime-themed icons
cat > "$TEMP_FILE" << EOF
🔄 Reboot
⏻ Shutdown
🚪 Logout
🔒 Lock
💤 Suspend
🖥️ Hibernate
EOF

# Display the menu using wofi
CHOICE=$(cat "$TEMP_FILE" | wofi --dmenu \
    --width "$MENU_WIDTH" \
    --height "$MENU_HEIGHT" \
    --location "$MENU_POSITION" \
    --font "$MENU_FONT" \
    --prompt "Power Menu" \
    --style "$HOME/.config/wofi/power-menu.css" \
    --hide-scroll \
    --insensitive)

# Process the user's choice
case "$CHOICE" in
    "🔄 Reboot")
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/reboot.wav" &
        # Show confirmation dialog
        if wofi --dmenu --prompt "Are you sure you want to reboot?" --style "$HOME/.config/wofi/power-menu.css" < <(echo -e "Yes\nNo") | grep -q "Yes"; then
            systemctl reboot
        fi
        ;;
    "⏻ Shutdown")
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/shutdown.wav" &
        # Show confirmation dialog
        if wofi --dmenu --prompt "Are you sure you want to shutdown?" --style "$HOME/.config/wofi/power-menu.css" < <(echo -e "Yes\nNo") | grep -q "Yes"; then
            systemctl poweroff
        fi
        ;;
    "🚪 Logout")
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/logout.wav" &
        # Show confirmation dialog
        if wofi --dmenu --prompt "Are you sure you want to logout?" --style "$HOME/.config/wofi/power-menu.css" < <(echo -e "Yes\nNo") | grep -q "Yes"; then
            hyprctl dispatch exit
        fi
        ;;
    "🔒 Lock")
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/lock.wav" &
        # Lock the screen
        swaylock -i "$HOME/.config/hypr/wallpapers/lock.jpg" -f
        ;;
    "💤 Suspend")
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/suspend.wav" &
        # Show confirmation dialog
        if wofi --dmenu --prompt "Are you sure you want to suspend?" --style "$HOME/.config/wofi/power-menu.css" < <(echo -e "Yes\nNo") | grep -q "Yes"; then
            systemctl suspend
        fi
        ;;
    "🖥️ Hibernate")
        # Play a sound effect
        paplay "$HOME/.config/hypr/sounds/hibernate.wav" &
        # Show confirmation dialog
        if wofi --dmenu --prompt "Are you sure you want to hibernate?" --style "$HOME/.config/wofi/power-menu.css" < <(echo -e "Yes\nNo") | grep -q "Yes"; then
            systemctl hibernate
        fi
        ;;
esac

# Clean up
rm "$TEMP_FILE" 