#!/bin/bash

# Anime-themed Keyboard Layout Toggle Script
# -----------------------------------------
# This script allows users to switch between keyboard layouts
# with anime-themed notifications

# Configuration
KEYBOARD_ICON="$HOME/.config/hypr/icons/keyboard.png"
SWITCH_SOUND="$HOME/.config/hypr/sounds/switch.wav"

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to use simpler layout switching (reduces resource usage)
USE_SIMPLE_SWITCHING=true
# Set to true to cache current layout (reduces resource usage)
USE_CACHING=true
# Cache file
CACHE_FILE="/tmp/keyboard-layout-cache.txt"
# Cache expiration time in seconds
CACHE_EXPIRATION=5

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
    
    # Check for hyprctl
    if ! command -v hyprctl &> /dev/null; then
        missing_deps+=("hyprctl")
    fi
    
    # Check for setxkbmap
    if ! command -v setxkbmap &> /dev/null; then
        missing_deps+=("setxkbmap")
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Keyboard Layout" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$KEYBOARD_ICON"
        exit 1
    fi
}

# Function to get current keyboard layout
get_current_layout() {
    # Check if caching is enabled and cache is valid
    if [ "$USE_CACHING" = true ] && [ -f "$CACHE_FILE" ]; then
        # Get cache timestamp
        local cache_timestamp=$(grep "timestamp:" "$CACHE_FILE" | cut -d ':' -f 2)
        local current_time=$(date +%s)
        
        # Check if cache is still valid
        if [ -n "$cache_timestamp" ] && [ $((current_time - cache_timestamp)) -lt $CACHE_EXPIRATION ]; then
            # Get layout from cache
            local layout=$(grep "layout:" "$CACHE_FILE" | cut -d ':' -f 2)
            if [ -n "$layout" ]; then
                echo "$layout"
                return
            fi
        fi
    fi
    
    # Get layout directly
    if [ "$USE_SIMPLE_SWITCHING" = true ]; then
        # Simpler command for low-end devices
        local layout=$(setxkbmap -query | grep "layout" | awk '{print $2}' 2>/dev/null || echo "us")
    else
        local layout=$(setxkbmap -query | grep "layout" | awk '{print $2}')
    fi
    
    # Update cache if caching is enabled
    if [ "$USE_CACHING" = true ]; then
        echo "timestamp:$(date +%s)" > "$CACHE_FILE"
        echo "layout:$layout" >> "$CACHE_FILE"
    fi
    
    echo "$layout"
}

# Function to get available keyboard layouts
get_available_layouts() {
    # Define available layouts
    local layouts=("us" "gb" "fr" "de" "es" "it" "ru" "jp" "kr" "cn")
    
    echo "${layouts[@]}"
}

# Function to switch keyboard layout
switch_layout() {
    # Check dependencies
    check_dependencies
    
    # Get current layout
    local current_layout=$(get_current_layout)
    
    # Get available layouts
    local available_layouts=($(get_available_layouts))
    
    # Find current layout index
    local current_index=0
    for i in "${!available_layouts[@]}"; do
        if [ "${available_layouts[$i]}" = "$current_layout" ]; then
            current_index=$i
            break
        fi
    done
    
    # Calculate next layout index
    local next_index=$((current_index + 1))
    if [ $next_index -ge ${#available_layouts[@]} ]; then
        next_index=0
    fi
    
    # Get next layout
    local next_layout="${available_layouts[$next_index]}"
    
    # Switch to next layout
    if [ "$USE_SIMPLE_SWITCHING" = true ]; then
        # Simpler command for low-end devices
        setxkbmap -layout "$next_layout" 2>/dev/null
    else
        setxkbmap -layout "$next_layout"
    fi
    
    # Update Hyprland keyboard layout
    hyprctl keyword input:kb_layout "$next_layout"
    
    # Update cache if caching is enabled
    if [ "$USE_CACHING" = true ]; then
        echo "timestamp:$(date +%s)" > "$CACHE_FILE"
        echo "layout:$next_layout" >> "$CACHE_FILE"
    fi
    
    # Play switch sound
    play_sound "$SWITCH_SOUND"
    
    # Show success notification
    send_notification "Keyboard Layout" "Switched to $next_layout layout" -i "$KEYBOARD_ICON"
    
    echo "Switched to $next_layout layout"
}

# Function to select keyboard layout
select_layout() {
    # Check dependencies
    check_dependencies
    
    # Get available layouts
    local available_layouts=($(get_available_layouts))
    
    # Create layout options
    local layout_options=""
    for layout in "${available_layouts[@]}"; do
        layout_options="$layout_options$layout\n"
    done
    
    # Show layout selection menu
    local selected_layout=$(echo -e "$layout_options" | wofi --dmenu --prompt "Select Keyboard Layout" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a layout was selected
    if [ -n "$selected_layout" ]; then
        # Switch to selected layout
        if [ "$USE_SIMPLE_SWITCHING" = true ]; then
            # Simpler command for low-end devices
            setxkbmap -layout "$selected_layout" 2>/dev/null
        else
            setxkbmap -layout "$selected_layout"
        fi
        
        # Update Hyprland keyboard layout
        hyprctl keyword input:kb_layout "$selected_layout"
        
        # Update cache if caching is enabled
        if [ "$USE_CACHING" = true ]; then
            echo "timestamp:$(date +%s)" > "$CACHE_FILE"
            echo "layout:$selected_layout" >> "$CACHE_FILE"
        fi
        
        # Play switch sound
        play_sound "$SWITCH_SOUND"
        
        # Show success notification
        send_notification "Keyboard Layout" "Switched to $selected_layout layout" -i "$KEYBOARD_ICON"
        
        echo "Switched to $selected_layout layout"
    else
        # Show error notification
        send_notification "Keyboard Layout" "No layout was selected" -i "$KEYBOARD_ICON"
        
        echo "No layout was selected"
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
        USE_SIMPLE_SWITCHING=true
        USE_CACHING=true
    fi
}

# Main function
main() {
    # Detect system capabilities
    detect_system_capabilities
    
    # Check the argument
    case "$1" in
        "switch")
            # Switch keyboard layout
            switch_layout
            ;;
        "select")
            # Select keyboard layout
            select_layout
            ;;
        "current")
            # Get current keyboard layout
            get_current_layout
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_SWITCHING=true
            USE_CACHING=true
            send_notification "Keyboard Layout" "Low-end mode enabled" -i "$KEYBOARD_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_SWITCHING=false
            USE_CACHING=true
            send_notification "Keyboard Layout" "High-end mode enabled" -i "$KEYBOARD_ICON"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Switch Layout\nSelect Layout\nShow Current Layout\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "Keyboard Layout" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Switch Layout")
                    switch_layout
                    ;;
                "Select Layout")
                    select_layout
                    ;;
                "Show Current Layout")
                    current_layout=$(get_current_layout)
                    send_notification "Keyboard Layout" "Current layout: $current_layout" -i "$KEYBOARD_ICON"
                    ;;
                "Enable Low-End Mode")
                    DISABLE_SOUNDS=true
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_SWITCHING=true
                    USE_CACHING=true
                    send_notification "Keyboard Layout" "Low-end mode enabled" -i "$KEYBOARD_ICON"
                    ;;
                "Enable High-End Mode")
                    DISABLE_SOUNDS=false
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_SWITCHING=false
                    USE_CACHING=true
                    send_notification "Keyboard Layout" "High-end mode enabled" -i "$KEYBOARD_ICON"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 