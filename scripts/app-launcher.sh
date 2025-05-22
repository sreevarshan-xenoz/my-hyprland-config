#!/bin/bash

# Anime-themed App Launcher Script
# --------------------------------
# This script lists all installed applications using wofi,
# with anime-themed sound and notification hooks, and low-end optimizations

# Configuration
LAUNCHER_ICON="$HOME/.config/hypr/icons/launcher.png"
LAUNCH_SOUND="$HOME/.config/hypr/sounds/launch.wav"

# Performance settings
DISABLE_SOUNDS=false
DISABLE_NOTIFICATIONS=false
USE_SIMPLE_LAUNCHER=true

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
    if ! command -v wofi &> /dev/null; then
        missing_deps+=("wofi")
    fi
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "App Launcher" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$LAUNCHER_ICON"
        exit 1
    fi
}

# Function to detect system capabilities and adjust settings
detect_system_capabilities() {
    local cpu_cores=$(nproc 2>/dev/null || echo 2)
    local available_memory=$(free -m | awk '/^Mem:/ {print $7}' 2>/dev/null || echo 1024)
    if [ "$cpu_cores" -le 2 ] || [ "$available_memory" -lt 2048 ]; then
        DISABLE_SOUNDS=true
        DISABLE_NOTIFICATIONS=false
        USE_SIMPLE_LAUNCHER=true
    fi
}

# Function to list all .desktop applications
list_applications() {
    local app_dirs=(
        "$HOME/.local/share/applications"
        "/usr/share/applications"
        "/usr/local/share/applications"
    )
    local apps=()
    for dir in "${app_dirs[@]}"; do
        [ -d "$dir" ] && apps+=("$dir"/*.desktop)
    done
    for app in "${apps[@]}"; do
        # Only show valid .desktop files
        if [ -f "$app" ]; then
            local name=$(grep -m 1 '^Name=' "$app" | cut -d '=' -f 2-)
            local exec=$(grep -m 1 '^Exec=' "$app" | cut -d '=' -f 2- | sed 's/ .*$//')
            if [ -n "$name" ] && [ -n "$exec" ]; then
                echo "$name|$exec|$app"
            fi
        fi
    done | sort -u
}

# Function to launch selected application
launch_application() {
    local entry="$1"
    local name=$(echo "$entry" | cut -d '|' -f 1)
    local exec=$(echo "$entry" | cut -d '|' -f 2)
    local desktop_file=$(echo "$entry" | cut -d '|' -f 3)
    # Play launch sound
    play_sound "$LAUNCH_SOUND"
    # Send notification
    send_notification "App Launcher" "Launching $name" "$LAUNCHER_ICON"
    # Launch the application
    nohup $exec >/dev/null 2>&1 &
}

# Main function
main() {
    detect_system_capabilities
    check_dependencies
    local app_list=$(list_applications)
    if [ -z "$app_list" ]; then
        send_notification "App Launcher" "No applications found." "$LAUNCHER_ICON"
        exit 1
    fi
    local menu_entries=$(echo "$app_list" | awk -F '|' '{print $1}')
    local selected_name=$(echo "$menu_entries" | wofi --dmenu --prompt "Launch App" --style "$HOME/.config/wofi/power-menu.css")
    if [ -z "$selected_name" ]; then
        exit 0
    fi
    local selected_entry=$(echo "$app_list" | grep "^$selected_name|")
    if [ -n "$selected_entry" ]; then
        launch_application "$selected_entry"
    fi
}

main "$@" 