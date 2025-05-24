#!/bin/bash

# Anime-themed Power Menu Script
# -----------------------------
# This script provides system power options with anime-themed visuals and sound effects

# Configuration
ICON_DIR="$HOME/.config/hypr/icons"
SOUND_DIR="$HOME/.config/hypr/sounds"
POWER_ICON="$ICON_DIR/power.png"
SLEEP_ICON="$ICON_DIR/sleep.png"
RESTART_ICON="$ICON_DIR/restart.png"
LOGOUT_ICON="$ICON_DIR/logout.png"
LOCK_ICON="$ICON_DIR/lock.png"
MENU_SOUND="$SOUND_DIR/menu.wav"
SELECT_SOUND="$SOUND_DIR/select.wav"
CONFIRM_SOUND="$SOUND_DIR/confirm.wav"
CANCEL_SOUND="$SOUND_DIR/cancel.wav"

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to disable visual effects (reduces resource usage)
DISABLE_VISUAL_EFFECTS=false
# Set to true to use simpler menu (reduces resource usage)
USE_SIMPLE_MENU=true

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
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Anime Power Menu" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$POWER_ICON"
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
        DISABLE_VISUAL_EFFECTS=true
        USE_SIMPLE_MENU=true
    fi
}

# Function to show power menu
show_power_menu() {
    # Play menu sound
    play_sound "$MENU_SOUND"
    
    # Show power menu
    choice=$(echo -e "Power Off\nRestart\nSleep\nLogout\nLock\nCancel" | wofi --dmenu --prompt "Power Menu" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a choice was made
    if [ -n "$choice" ]; then
        # Play select sound
        play_sound "$SELECT_SOUND"
        
        # Handle choice
        case "$choice" in
            "Power Off")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to power off?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show notification
                    send_notification "Power Off" "Shutting down..." -i "$POWER_ICON"
                    
                    # Power off
                    systemctl poweroff
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "Power Off" "Cancelled" -i "$POWER_ICON"
                fi
                ;;
            "Restart")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to restart?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show notification
                    send_notification "Restart" "Restarting..." -i "$RESTART_ICON"
                    
                    # Restart
                    systemctl reboot
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "Restart" "Cancelled" -i "$RESTART_ICON"
                fi
                ;;
            "Sleep")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to sleep?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show notification
                    send_notification "Sleep" "Going to sleep..." -i "$SLEEP_ICON"
                    
                    # Sleep
                    systemctl suspend
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "Sleep" "Cancelled" -i "$SLEEP_ICON"
                fi
                ;;
            "Logout")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to logout?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show notification
                    send_notification "Logout" "Logging out..." -i "$LOGOUT_ICON"
                    
                    # Logout
                    hyprctl dispatch exit
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "Logout" "Cancelled" -i "$LOGOUT_ICON"
                fi
                ;;
            "Lock")
                # Play confirm sound
                play_sound "$CONFIRM_SOUND"
                
                # Show notification
                send_notification "Lock" "Locking screen..." -i "$LOCK_ICON"
                
                # Lock
                swaylock
                ;;
            "Cancel")
                # Play cancel sound
                play_sound "$CANCEL_SOUND"
                
                # Show notification
                send_notification "Power Menu" "Cancelled" -i "$POWER_ICON"
                ;;
        esac
    else
        # Play cancel sound
        play_sound "$CANCEL_SOUND"
        
        # Show notification
        send_notification "Power Menu" "Cancelled" -i "$POWER_ICON"
    fi
}

# Function to show anime-themed power menu
show_anime_power_menu() {
    # Play menu sound
    play_sound "$MENU_SOUND"
    
    # Show anime-themed power menu
    choice=$(echo -e "Power Off (Shutdown)\nRestart (Reboot)\nSleep (Suspend)\nLogout (Exit)\nLock (Screen Lock)\nCancel (Go Back)" | wofi --dmenu --prompt "Anime Power Menu" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a choice was made
    if [ -n "$choice" ]; then
        # Play select sound
        play_sound "$SELECT_SOUND"
        
        # Handle choice
        case "$choice" in
            "Power Off (Shutdown)")
                # Show anime-themed confirmation dialog
                confirm=$(echo -e "Yes (Confirm)\nNo (Cancel)" | wofi --dmenu --prompt "Are you sure you want to power off?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes (Confirm)" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Power Off" "Shutting down... See you next time!" -i "$POWER_ICON"
                    
                    # Power off
                    systemctl poweroff
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Power Off" "Cancelled. Staying with you a bit longer!" -i "$POWER_ICON"
                fi
                ;;
            "Restart (Reboot)")
                # Show anime-themed confirmation dialog
                confirm=$(echo -e "Yes (Confirm)\nNo (Cancel)" | wofi --dmenu --prompt "Are you sure you want to restart?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes (Confirm)" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Restart" "Restarting... I'll be back in a moment!" -i "$RESTART_ICON"
                    
                    # Restart
                    systemctl reboot
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Restart" "Cancelled. No restart for now!" -i "$RESTART_ICON"
                fi
                ;;
            "Sleep (Suspend)")
                # Show anime-themed confirmation dialog
                confirm=$(echo -e "Yes (Confirm)\nNo (Cancel)" | wofi --dmenu --prompt "Are you sure you want to sleep?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes (Confirm)" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Sleep" "Going to sleep... Sweet dreams!" -i "$SLEEP_ICON"
                    
                    # Sleep
                    systemctl suspend
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Sleep" "Cancelled. Staying awake for now!" -i "$SLEEP_ICON"
                fi
                ;;
            "Logout (Exit)")
                # Show anime-themed confirmation dialog
                confirm=$(echo -e "Yes (Confirm)\nNo (Cancel)" | wofi --dmenu --prompt "Are you sure you want to logout?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes (Confirm)" ]; then
                    # Play confirm sound
                    play_sound "$CONFIRM_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Logout" "Logging out... See you later!" -i "$LOGOUT_ICON"
                    
                    # Logout
                    hyprctl dispatch exit
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show anime-themed notification
                    send_notification "Logout" "Cancelled. Staying logged in!" -i "$LOGOUT_ICON"
                fi
                ;;
            "Lock (Screen Lock)")
                # Play confirm sound
                play_sound "$CONFIRM_SOUND"
                
                # Show anime-themed notification
                send_notification "Lock" "Locking screen... I'll keep an eye on your system!" -i "$LOCK_ICON"
                
                # Lock
                swaylock
                ;;
            "Cancel (Go Back)")
                # Play cancel sound
                play_sound "$CANCEL_SOUND"
                
                # Show anime-themed notification
                send_notification "Power Menu" "Cancelled. Staying with you!" -i "$POWER_ICON"
                ;;
        esac
    else
        # Play cancel sound
        play_sound "$CANCEL_SOUND"
        
        # Show anime-themed notification
        send_notification "Power Menu" "Cancelled. Staying with you!" -i "$POWER_ICON"
    fi
}

# Function to show simple power menu
show_simple_power_menu() {
    # Show simple power menu
    choice=$(echo -e "Power Off\nRestart\nSleep\nLogout\nLock\nCancel" | wofi --dmenu --prompt "Power Menu" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a choice was made
    if [ -n "$choice" ]; then
        # Handle choice
        case "$choice" in
            "Power Off")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to power off?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Show notification
                    send_notification "Power Off" "Shutting down..." -i "$POWER_ICON"
                    
                    # Power off
                    systemctl poweroff
                else
                    # Show notification
                    send_notification "Power Off" "Cancelled" -i "$POWER_ICON"
                fi
                ;;
            "Restart")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to restart?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Show notification
                    send_notification "Restart" "Restarting..." -i "$RESTART_ICON"
                    
                    # Restart
                    systemctl reboot
                else
                    # Show notification
                    send_notification "Restart" "Cancelled" -i "$RESTART_ICON"
                fi
                ;;
            "Sleep")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to sleep?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Show notification
                    send_notification "Sleep" "Going to sleep..." -i "$SLEEP_ICON"
                    
                    # Sleep
                    systemctl suspend
                else
                    # Show notification
                    send_notification "Sleep" "Cancelled" -i "$SLEEP_ICON"
                fi
                ;;
            "Logout")
                # Show confirmation dialog
                confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to logout?" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if confirmed
                if [ "$confirm" = "Yes" ]; then
                    # Show notification
                    send_notification "Logout" "Logging out..." -i "$LOGOUT_ICON"
                    
                    # Logout
                    hyprctl dispatch exit
                else
                    # Show notification
                    send_notification "Logout" "Cancelled" -i "$LOGOUT_ICON"
                fi
                ;;
            "Lock")
                # Show notification
                send_notification "Lock" "Locking screen..." -i "$LOCK_ICON"
                
                # Lock
                swaylock
                ;;
            "Cancel")
                # Show notification
                send_notification "Power Menu" "Cancelled" -i "$POWER_ICON"
                ;;
        esac
    else
        # Show notification
        send_notification "Power Menu" "Cancelled" -i "$POWER_ICON"
    fi
}

# Function to show menu
show_menu() {
    # Show menu
    choice=$(echo -e "Standard Power Menu\nAnime-themed Power Menu\nSimple Power Menu\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "Power Menu" --style "$HOME/.config/wofi/power-menu.css")
    
    case "$choice" in
        "Standard Power Menu")
            show_power_menu
            ;;
        "Anime-themed Power Menu")
            show_anime_power_menu
            ;;
        "Simple Power Menu")
            show_simple_power_menu
            ;;
        "Enable Low-End Mode")
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=true
            USE_SIMPLE_MENU=true
            send_notification "Power Menu" "Low-end mode enabled" -i "$POWER_ICON"
            ;;
        "Enable High-End Mode")
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=false
            USE_SIMPLE_MENU=false
            send_notification "Power Menu" "High-end mode enabled" -i "$POWER_ICON"
            ;;
    esac
}

# Main function
main() {
    # Check dependencies
    check_dependencies
    
    # Detect system capabilities
    detect_system_capabilities
    
    # Check the argument
    case "$1" in
        "standard")
            # Show standard power menu
            show_power_menu
            ;;
        "anime")
            # Show anime-themed power menu
            show_anime_power_menu
            ;;
        "simple")
            # Show simple power menu
            show_simple_power_menu
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=true
            USE_SIMPLE_MENU=true
            send_notification "Power Menu" "Low-end mode enabled" -i "$POWER_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=false
            USE_SIMPLE_MENU=false
            send_notification "Power Menu" "High-end mode enabled" -i "$POWER_ICON"
            ;;
        *)
            # Show menu
            show_menu
            ;;
    esac
}

# Run the main function
main "$@" 