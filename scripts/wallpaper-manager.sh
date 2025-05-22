#!/bin/bash

# Anime-themed Wallpaper Manager Script
# ------------------------------------
# This script allows users to manage wallpapers with anime-themed notifications
# and performance optimizations for low-end devices

# Configuration
WALLPAPER_ICON="$HOME/.config/hypr/icons/wallpaper.png"
CHANGE_SOUND="$HOME/.config/hypr/sounds/change.wav"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WALLPAPER_CACHE_DIR="$HOME/.cache/wallpapers"
WALLPAPER_HISTORY_FILE="$HOME/.cache/wallpaper-history.txt"
MAX_HISTORY=20

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to use simpler wallpaper setting (reduces resource usage)
USE_SIMPLE_WALLPAPER=true
# Set to true to cache wallpapers (reduces resource usage)
USE_CACHING=true
# Set to true to use lower resolution wallpapers (reduces resource usage)
USE_LOW_RES=false
# Set to true to disable wallpaper effects (reduces resource usage)
DISABLE_EFFECTS=false
# Set to true to enable auto-cycling wallpapers
ENABLE_AUTO_CYCLE=false
# Auto-cycle interval in minutes
AUTO_CYCLE_INTERVAL=30

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
    
    # Check for swww
    if ! command -v swww &> /dev/null; then
        missing_deps+=("swww")
    fi
    
    # Check for convert (for image processing)
    if ! command -v convert &> /dev/null; then
        missing_deps+=("imagemagick")
    fi
    
    # Check for wofi (for menu)
    if ! command -v wofi &> /dev/null; then
        missing_deps+=("wofi")
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Wallpaper Manager" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$WALLPAPER_ICON"
        exit 1
    fi
}

# Function to create cache directory
create_cache_dir() {
    if [ ! -d "$WALLPAPER_CACHE_DIR" ]; then
        mkdir -p "$WALLPAPER_CACHE_DIR"
    fi
}

# Function to get current wallpaper
get_current_wallpaper() {
    # Check if swww is running
    if ! pgrep -x "swww" > /dev/null; then
        echo "swww is not running"
        return
    fi
    
    # Get current wallpaper
    local current_wallpaper=$(swww query | grep "image:" | awk '{print $2}')
    
    echo "$current_wallpaper"
}

# Function to list wallpapers
list_wallpapers() {
    # Check if wallpaper directory exists
    if [ ! -d "$WALLPAPER_DIR" ]; then
        send_notification "Wallpaper Manager" "Wallpaper directory not found: $WALLPAPER_DIR" -i "$WALLPAPER_ICON"
        exit 1
    fi
    
    # List wallpapers
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | sort
}

# Function to set wallpaper
set_wallpaper() {
    local wallpaper="$1"
    
    # Check if wallpaper exists
    if [ ! -f "$wallpaper" ]; then
        send_notification "Wallpaper Manager" "Wallpaper not found: $wallpaper" -i "$WALLPAPER_ICON"
        return
    fi
    
    # Check if swww is running
    if ! pgrep -x "swww" > /dev/null; then
        # Start swww
        swww init
    fi
    
    # Set wallpaper
    if [ "$USE_SIMPLE_WALLPAPER" = true ]; then
        # Simpler command for low-end devices
        swww img "$wallpaper" --transition-type none
    else
        # Use transition effects if not disabled
        if [ "$DISABLE_EFFECTS" = false ]; then
            swww img "$wallpaper" --transition-type wipe --transition-angle 30 --transition-step 90
        else
            swww img "$wallpaper" --transition-type none
        fi
    fi
    
    # Add to history
    add_to_history "$wallpaper"
    
    # Play change sound
    play_sound "$CHANGE_SOUND"
    
    # Show success notification
    local wallpaper_name=$(basename "$wallpaper")
    send_notification "Wallpaper Manager" "Set wallpaper: $wallpaper_name" -i "$WALLPAPER_ICON"
    
    echo "Set wallpaper: $wallpaper"
}

# Function to add wallpaper to history
add_to_history() {
    local wallpaper="$1"
    
    # Create history file if it doesn't exist
    if [ ! -f "$WALLPAPER_HISTORY_FILE" ]; then
        touch "$WALLPAPER_HISTORY_FILE"
    fi
    
    # Add wallpaper to history
    echo "$wallpaper" >> "$WALLPAPER_HISTORY_FILE"
    
    # Limit history size
    if [ -f "$WALLPAPER_HISTORY_FILE" ]; then
        local history_size=$(wc -l < "$WALLPAPER_HISTORY_FILE")
        if [ "$history_size" -gt "$MAX_HISTORY" ]; then
            # Remove oldest entries
            sed -i "1,$((history_size - MAX_HISTORY))d" "$WALLPAPER_HISTORY_FILE"
        fi
    fi
}

# Function to get wallpaper history
get_wallpaper_history() {
    # Check if history file exists
    if [ ! -f "$WALLPAPER_HISTORY_FILE" ]; then
        echo ""
        return
    fi
    
    # Get wallpaper history
    cat "$WALLPAPER_HISTORY_FILE" | tac
}

# Function to select wallpaper from directory
select_wallpaper() {
    # List wallpapers
    local wallpapers=($(list_wallpapers))
    
    # Check if any wallpapers were found
    if [ ${#wallpapers[@]} -eq 0 ]; then
        send_notification "Wallpaper Manager" "No wallpapers found in $WALLPAPER_DIR" -i "$WALLPAPER_ICON"
        return
    fi
    
    # Create wallpaper options
    local wallpaper_options=""
    for wallpaper in "${wallpapers[@]}"; do
        local wallpaper_name=$(basename "$wallpaper")
        wallpaper_options="$wallpaper_options$wallpaper_name|$wallpaper\n"
    done
    
    # Show wallpaper selection menu
    local selected_option=$(echo -e "$wallpaper_options" | wofi --dmenu --prompt "Select Wallpaper" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a wallpaper was selected
    if [ -n "$selected_option" ]; then
        # Extract wallpaper path
        local selected_wallpaper=$(echo "$selected_option" | cut -d '|' -f 2)
        
        # Set wallpaper
        set_wallpaper "$selected_wallpaper"
    else
        # Show error notification
        send_notification "Wallpaper Manager" "No wallpaper was selected" -i "$WALLPAPER_ICON"
    fi
}

# Function to select wallpaper from history
select_from_history() {
    # Get wallpaper history
    local history=($(get_wallpaper_history))
    
    # Check if any wallpapers were found
    if [ ${#history[@]} -eq 0 ]; then
        send_notification "Wallpaper Manager" "No wallpaper history found" -i "$WALLPAPER_ICON"
        return
    fi
    
    # Create wallpaper options
    local wallpaper_options=""
    for wallpaper in "${history[@]}"; do
        local wallpaper_name=$(basename "$wallpaper")
        wallpaper_options="$wallpaper_options$wallpaper_name|$wallpaper\n"
    done
    
    # Show wallpaper selection menu
    local selected_option=$(echo -e "$wallpaper_options" | wofi --dmenu --prompt "Select from History" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a wallpaper was selected
    if [ -n "$selected_option" ]; then
        # Extract wallpaper path
        local selected_wallpaper=$(echo "$selected_option" | cut -d '|' -f 2)
        
        # Set wallpaper
        set_wallpaper "$selected_wallpaper"
    else
        # Show error notification
        send_notification "Wallpaper Manager" "No wallpaper was selected" -i "$WALLPAPER_ICON"
    fi
}

# Function to set random wallpaper
set_random_wallpaper() {
    # List wallpapers
    local wallpapers=($(list_wallpapers))
    
    # Check if any wallpapers were found
    if [ ${#wallpapers[@]} -eq 0 ]; then
        send_notification "Wallpaper Manager" "No wallpapers found in $WALLPAPER_DIR" -i "$WALLPAPER_ICON"
        return
    fi
    
    # Get random wallpaper
    local random_index=$((RANDOM % ${#wallpapers[@]}))
    local random_wallpaper="${wallpapers[$random_index]}"
    
    # Set wallpaper
    set_wallpaper "$random_wallpaper"
}

# Function to toggle auto-cycle
toggle_auto_cycle() {
    # Toggle auto-cycle
    if [ "$ENABLE_AUTO_CYCLE" = true ]; then
        ENABLE_AUTO_CYCLE=false
        send_notification "Wallpaper Manager" "Auto-cycle disabled" -i "$WALLPAPER_ICON"
    else
        ENABLE_AUTO_CYCLE=true
        send_notification "Wallpaper Manager" "Auto-cycle enabled (every $AUTO_CYCLE_INTERVAL minutes)" -i "$WALLPAPER_ICON"
        
        # Start auto-cycle in background
        auto_cycle &
    fi
}

# Function to auto-cycle wallpapers
auto_cycle() {
    while [ "$ENABLE_AUTO_CYCLE" = true ]; do
        # Sleep for auto-cycle interval
        sleep $((AUTO_CYCLE_INTERVAL * 60))
        
        # Set random wallpaper
        set_random_wallpaper
    done
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
        USE_SIMPLE_WALLPAPER=true
        USE_CACHING=true
        USE_LOW_RES=true
        DISABLE_EFFECTS=true
        ENABLE_AUTO_CYCLE=false
    fi
}

# Function to optimize wallpaper for low-end devices
optimize_wallpaper() {
    local wallpaper="$1"
    local optimized_wallpaper="$WALLPAPER_CACHE_DIR/$(basename "$wallpaper")"
    
    # Check if optimized wallpaper already exists
    if [ -f "$optimized_wallpaper" ]; then
        echo "$optimized_wallpaper"
        return
    fi
    
    # Create cache directory
    create_cache_dir
    
    # Optimize wallpaper
    if [ "$USE_LOW_RES" = true ]; then
        # Resize to lower resolution
        convert "$wallpaper" -resize 1280x720 "$optimized_wallpaper"
    else
        # Just copy the wallpaper
        cp "$wallpaper" "$optimized_wallpaper"
    fi
    
    echo "$optimized_wallpaper"
}

# Main function
main() {
    # Detect system capabilities
    detect_system_capabilities
    
    # Check dependencies
    check_dependencies
    
    # Create cache directory
    create_cache_dir
    
    # Check the argument
    case "$1" in
        "select")
            # Select wallpaper from directory
            select_wallpaper
            ;;
        "history")
            # Select wallpaper from history
            select_from_history
            ;;
        "random")
            # Set random wallpaper
            set_random_wallpaper
            ;;
        "current")
            # Get current wallpaper
            get_current_wallpaper
            ;;
        "auto-cycle")
            # Toggle auto-cycle
            toggle_auto_cycle
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_WALLPAPER=true
            USE_CACHING=true
            USE_LOW_RES=true
            DISABLE_EFFECTS=true
            ENABLE_AUTO_CYCLE=false
            send_notification "Wallpaper Manager" "Low-end mode enabled" -i "$WALLPAPER_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_WALLPAPER=false
            USE_CACHING=true
            USE_LOW_RES=false
            DISABLE_EFFECTS=false
            ENABLE_AUTO_CYCLE=false
            send_notification "Wallpaper Manager" "High-end mode enabled" -i "$WALLPAPER_ICON"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Select Wallpaper\nSelect from History\nSet Random Wallpaper\nToggle Auto-Cycle\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "Wallpaper Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Select Wallpaper")
                    select_wallpaper
                    ;;
                "Select from History")
                    select_from_history
                    ;;
                "Set Random Wallpaper")
                    set_random_wallpaper
                    ;;
                "Toggle Auto-Cycle")
                    toggle_auto_cycle
                    ;;
                "Enable Low-End Mode")
                    DISABLE_SOUNDS=true
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_WALLPAPER=true
                    USE_CACHING=true
                    USE_LOW_RES=true
                    DISABLE_EFFECTS=true
                    ENABLE_AUTO_CYCLE=false
                    send_notification "Wallpaper Manager" "Low-end mode enabled" -i "$WALLPAPER_ICON"
                    ;;
                "Enable High-End Mode")
                    DISABLE_SOUNDS=false
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_WALLPAPER=false
                    USE_CACHING=true
                    USE_LOW_RES=false
                    DISABLE_EFFECTS=false
                    ENABLE_AUTO_CYCLE=false
                    send_notification "Wallpaper Manager" "High-end mode enabled" -i "$WALLPAPER_ICON"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 