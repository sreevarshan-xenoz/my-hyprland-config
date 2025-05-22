#!/bin/bash

# Anime-themed Wallbash Script
# ----------------------------
# This script generates color schemes from wallpapers
# with anime-themed notifications

# Configuration
WALLBASH_ICON="$HOME/.config/hypr/icons/wallbash.png"
GENERATE_SOUND="$HOME/.config/hypr/sounds/generate.wav"
APPLY_SOUND="$HOME/.config/hypr/sounds/apply.wav"

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to use simpler color generation (reduces resource usage)
USE_SIMPLE_GENERATION=true
# Set to true to cache color schemes (reduces resource usage)
USE_CACHING=true
# Cache directory
CACHE_DIR="$HOME/.cache/wallbash"
# Cache expiration time in seconds (1 day)
CACHE_EXPIRATION=86400

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
    
    # Check for pywal
    if ! command -v wal &> /dev/null; then
        missing_deps+=("pywal")
    fi
    
    # Check for swww
    if ! command -v swww &> /dev/null; then
        missing_deps+=("swww")
    fi
    
    # Check for convert (ImageMagick)
    if ! command -v convert &> /dev/null; then
        missing_deps+=("imagemagick")
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Wallbash" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$WALLBASH_ICON"
        exit 1
    fi
}

# Function to create cache directory
create_cache_dir() {
    if [ "$USE_CACHING" = true ] && [ ! -d "$CACHE_DIR" ]; then
        mkdir -p "$CACHE_DIR"
    fi
}

# Function to get wallpaper path
get_wallpaper_path() {
    # Get current wallpaper from swww
    local wallpaper=$(swww query | grep -o "image: .*" | cut -d ' ' -f 2)
    
    # If no wallpaper is set, use default
    if [ -z "$wallpaper" ]; then
        wallpaper="$HOME/.config/hypr/wallpapers/default.jpg"
    fi
    
    echo "$wallpaper"
}

# Function to generate color scheme
generate_color_scheme() {
    # Check dependencies
    check_dependencies
    
    # Create cache directory
    create_cache_dir
    
    # Get wallpaper path
    local wallpaper=$(get_wallpaper_path)
    
    # Generate cache key
    local cache_key=$(echo "$wallpaper" | md5sum | cut -d ' ' -f 1)
    local cache_file="$CACHE_DIR/$cache_key.json"
    
    # Check if cache is valid
    if [ "$USE_CACHING" = true ] && [ -f "$cache_file" ]; then
        # Get cache timestamp
        local cache_timestamp=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        local current_time=$(date +%s)
        
        # Check if cache is still valid
        if [ $((current_time - cache_timestamp)) -lt $CACHE_EXPIRATION ]; then
            # Use cached color scheme
            if [ "$USE_SIMPLE_GENERATION" = true ]; then
                # Simpler generation for low-end devices
                wal -q -n -i "$wallpaper" -o "$HOME/.config/hypr/scripts/apply-colors.sh" --backend colorz
            else
                # Full generation
                wal -q -i "$wallpaper" -o "$HOME/.config/hypr/scripts/apply-colors.sh" --backend colorz
            fi
            
            # Play apply sound
            play_sound "$APPLY_SOUND"
            
            # Show success notification
            send_notification "Wallbash" "Applied cached color scheme from $(basename "$wallpaper")" -i "$WALLBASH_ICON"
            
            return
        fi
    fi
    
    # Play generate sound
    play_sound "$GENERATE_SOUND"
    
    # Generate color scheme
    if [ "$USE_SIMPLE_GENERATION" = true ]; then
        # Simpler generation for low-end devices
        wal -q -n -i "$wallpaper" -o "$HOME/.config/hypr/scripts/apply-colors.sh" --backend colorz
    else
        # Full generation
        wal -q -i "$wallpaper" -o "$HOME/.config/hypr/scripts/apply-colors.sh" --backend colorz
    fi
    
    # Cache color scheme
    if [ "$USE_CACHING" = true ]; then
        cp "$HOME/.cache/wal/colors.json" "$cache_file"
    fi
    
    # Play apply sound
    play_sound "$APPLY_SOUND"
    
    # Show success notification
    send_notification "Wallbash" "Generated and applied color scheme from $(basename "$wallpaper")" -i "$WALLBASH_ICON"
}

# Function to clear cache
clear_cache() {
    if [ "$USE_CACHING" = true ] && [ -d "$CACHE_DIR" ]; then
        rm -rf "$CACHE_DIR"/*
        send_notification "Wallbash" "Cache cleared" -i "$WALLBASH_ICON"
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
        USE_SIMPLE_GENERATION=true
        USE_CACHING=true
    fi
}

# Main function
main() {
    # Detect system capabilities
    detect_system_capabilities
    
    # Check the argument
    case "$1" in
        "generate")
            # Generate color scheme
            generate_color_scheme
            ;;
        "clear-cache")
            # Clear cache
            clear_cache
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_GENERATION=true
            USE_CACHING=true
            send_notification "Wallbash" "Low-end mode enabled" -i "$WALLBASH_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_GENERATION=false
            USE_CACHING=true
            send_notification "Wallbash" "High-end mode enabled" -i "$WALLBASH_ICON"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Generate Color Scheme\nClear Cache\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "Wallbash" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Generate Color Scheme")
                    generate_color_scheme
                    ;;
                "Clear Cache")
                    clear_cache
                    ;;
                "Enable Low-End Mode")
                    DISABLE_SOUNDS=true
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_GENERATION=true
                    USE_CACHING=true
                    send_notification "Wallbash" "Low-end mode enabled" -i "$WALLBASH_ICON"
                    ;;
                "Enable High-End Mode")
                    DISABLE_SOUNDS=false
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_GENERATION=false
                    USE_CACHING=true
                    send_notification "Wallbash" "High-end mode enabled" -i "$WALLBASH_ICON"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 