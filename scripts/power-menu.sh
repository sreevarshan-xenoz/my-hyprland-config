#!/bin/bash

# Anime-themed Power Menu Script
# -----------------------------
# This script provides a stylish anime-themed power menu with options
# for shutdown, reboot, suspend, and logout

# Configuration
POWER_ICON="$HOME/.config/hypr/icons/power.png"
SHUTDOWN_ICON="$HOME/.config/hypr/icons/shutdown.png"
REBOOT_ICON="$HOME/.config/hypr/icons/reboot.png"
SUSPEND_ICON="$HOME/.config/hypr/icons/suspend.png"
LOGOUT_ICON="$HOME/.config/hypr/icons/logout.png"
LOCK_ICON="$HOME/.config/hypr/icons/lock.png"
MENU_SOUND="$HOME/.config/hypr/sounds/menu.wav"
SELECT_SOUND="$HOME/.config/hypr/sounds/select.wav"

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to use simpler menu (reduces resource usage)
USE_SIMPLE_MENU=true
# Set to true to use simpler icons (reduces resource usage)
USE_SIMPLE_ICONS=false

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
    
    # Check for wofi
    if ! command -v wofi &> /dev/null; then
        missing_deps+=("wofi")
    fi
    
    # Check for systemctl
    if ! command -v systemctl &> /dev/null; then
        missing_deps+=("systemd")
    fi
    
    # Check for loginctl
    if ! command -v loginctl &> /dev/null; then
        missing_deps+=("systemd")
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Power Menu" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$POWER_ICON"
        exit 1
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
        USE_SIMPLE_MENU=true
        USE_SIMPLE_ICONS=true
    fi
}

# Function to show power menu
show_power_menu() {
    # Play menu sound
    play_sound "$MENU_SOUND"
    
    # Create menu options
    local menu_options=""
    
    if [ "$USE_SIMPLE_MENU" = true ]; then
        # Simple menu for low-end devices
        menu_options="Shutdown\nReboot\nSuspend\nLogout"
    else
        # Full menu with icons
        if [ "$USE_SIMPLE_ICONS" = true ]; then
            # Use simple icons
            menu_options="Shutdown\nReboot\nSuspend\nLogout\nLock"
        else
            # Use full icons
            menu_options="󰐥 Shutdown\n󰜉 Reboot\n󰤄 Suspend\n󰍃 Logout\n󰌾 Lock"
        fi
    fi
    
    # Show menu
    local choice=$(echo -e "$menu_options" | wofi --dmenu --prompt "Power Menu" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a choice was made
    if [ -n "$choice" ]; then
        # Play select sound
        play_sound "$SELECT_SOUND"
        
        # Process choice
        case "$choice" in
            *"Shutdown"*)
                # Show confirmation dialog
                confirm_action "Shutdown" "Are you sure you want to shutdown?" "$SHUTDOWN_ICON" "systemctl poweroff"
                ;;
            *"Reboot"*)
                # Show confirmation dialog
                confirm_action "Reboot" "Are you sure you want to reboot?" "$REBOOT_ICON" "systemctl reboot"
                ;;
            *"Suspend"*)
                # Show confirmation dialog
                confirm_action "Suspend" "Are you sure you want to suspend?" "$SUSPEND_ICON" "systemctl suspend"
                ;;
            *"Logout"*)
                # Show confirmation dialog
                confirm_action "Logout" "Are you sure you want to logout?" "$LOGOUT_ICON" "hyprctl dispatch exit"
                ;;
            *"Lock"*)
                # Lock screen
                lock_screen
                ;;
        esac
    fi
}

# Function to confirm action
confirm_action() {
    local action="$1"
    local message="$2"
    local icon="$3"
    local command="$4"
    
    # Show confirmation dialog
    local confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "$message" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if confirmed
    if [ "$confirm" = "Yes" ]; then
        # Show notification
        send_notification "$action" "System will $action in 3 seconds..." -i "$icon"
        
        # Wait 3 seconds
        sleep 3
        
        # Execute command
        eval "$command"
    else
        # Show cancelled notification
        send_notification "$action" "Action cancelled" -i "$icon"
    fi
}

# Function to lock screen
lock_screen() {
    # Check if swaylock is installed
    if command -v swaylock &> /dev/null; then
        # Show notification
        send_notification "Lock Screen" "Locking screen..." -i "$LOCK_ICON"
        
        # Lock screen
        swaylock --image "$(get_current_wallpaper)" --scaling fill --effect-blur 7x5 --indicator-radius 100 --indicator-thickness 7 --ring-color 4c566a --key-hl-color 88c0d0 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2
    else
        # Show error notification
        send_notification "Lock Screen" "swaylock is not installed. Please install it to use this feature." -i "$LOCK_ICON"
    fi
}

# Function to get current wallpaper
get_current_wallpaper() {
    # Check if swww is running
    if ! pgrep -x "swww" > /dev/null; then
        echo ""
        return
    fi
    
    # Get current wallpaper
    local current_wallpaper=$(swww query | grep "image:" | awk '{print $2}')
    
    echo "$current_wallpaper"
}

# Main function
main() {
    # Detect system capabilities
    detect_system_capabilities
    
    # Check dependencies
    check_dependencies
    
    # Show power menu
    show_power_menu
}

# Run the main function
main "$@" 