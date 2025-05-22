#!/bin/bash

# Anime-themed Audio Manager Script (Optimized for Low-End Devices)
# --------------------------------------------------------------
# This script manages audio with anime-themed notifications
# Optimized for low-end devices with reduced resource usage

# Configuration
AUDIO_ICON="$HOME/.config/hypr/icons/audio.png"
MUTE_ICON="$HOME/.config/hypr/icons/mute.png"
VOLUME_UP_SOUND="$HOME/.config/hypr/sounds/volume-up.wav"
VOLUME_DOWN_SOUND="$HOME/.config/hypr/sounds/volume-down.wav"
MUTE_SOUND="$HOME/.config/hypr/sounds/mute.wav"
UNMUTE_SOUND="$HOME/.config/hypr/sounds/unmute.wav"

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to use simpler audio commands (reduces resource usage)
USE_SIMPLE_COMMANDS=true
# Set to true to cache volume and mute status (reduces resource usage)
USE_CACHING=true
# Cache file
CACHE_FILE="/tmp/audio-manager-cache.txt"
# Cache expiration time in seconds
CACHE_EXPIRATION=5

# Function to check if pactl is installed
check_pactl() {
    if ! command -v pactl &> /dev/null; then
        if [ "$DISABLE_NOTIFICATIONS" = false ]; then
            notify-send "Audio Manager" "pactl is not installed. Please install it to use this script." -i "$MUTE_ICON"
        fi
        exit 1
    fi
}

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

# Function to get volume from cache or directly
get_volume() {
    # Check if pactl is installed
    check_pactl
    
    # Check if caching is enabled and cache is valid
    if [ "$USE_CACHING" = true ] && [ -f "$CACHE_FILE" ]; then
        # Get cache timestamp
        local cache_timestamp=$(grep "timestamp:" "$CACHE_FILE" | cut -d ':' -f 2)
        local current_time=$(date +%s)
        
        # Check if cache is still valid
        if [ -n "$cache_timestamp" ] && [ $((current_time - cache_timestamp)) -lt $CACHE_EXPIRATION ]; then
            # Get volume from cache
            local volume=$(grep "volume:" "$CACHE_FILE" | cut -d ':' -f 2)
            if [ -n "$volume" ]; then
                echo "$volume"
                return
            fi
        fi
    fi
    
    # Get volume directly
    if [ "$USE_SIMPLE_COMMANDS" = true ]; then
        # Simpler command for low-end devices
        local volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
    else
        local volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
    fi
    
    # Update cache if caching is enabled
    if [ "$USE_CACHING" = true ]; then
        echo "timestamp:$(date +%s)" > "$CACHE_FILE"
        echo "volume:$volume" >> "$CACHE_FILE"
    fi
    
    echo "$volume"
}

# Function to get mute status from cache or directly
get_mute_status() {
    # Check if pactl is installed
    check_pactl
    
    # Check if caching is enabled and cache is valid
    if [ "$USE_CACHING" = true ] && [ -f "$CACHE_FILE" ]; then
        # Get cache timestamp
        local cache_timestamp=$(grep "timestamp:" "$CACHE_FILE" | cut -d ':' -f 2)
        local current_time=$(date +%s)
        
        # Check if cache is still valid
        if [ -n "$cache_timestamp" ] && [ $((current_time - cache_timestamp)) -lt $CACHE_EXPIRATION ]; then
            # Get mute status from cache
            local mute=$(grep "mute:" "$CACHE_FILE" | cut -d ':' -f 2)
            if [ -n "$mute" ]; then
                echo "$mute"
                return
            fi
        fi
    fi
    
    # Get mute status directly
    if [ "$USE_SIMPLE_COMMANDS" = true ]; then
        # Simpler command for low-end devices
        local mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}' 2>/dev/null || echo "no")
    else
        local mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    fi
    
    # Update cache if caching is enabled
    if [ "$USE_CACHING" = true ]; then
        echo "timestamp:$(date +%s)" > "$CACHE_FILE"
        echo "mute:$mute" >> "$CACHE_FILE"
    fi
    
    echo "$mute"
}

# Function to set volume
set_volume() {
    # Check if pactl is installed
    check_pactl
    
    # Get the volume to set
    local volume="$1"
    
    # Set volume
    pactl set-sink-volume @DEFAULT_SINK@ "$volume%"
    
    # Check if the volume was set successfully
    if [ $? -eq 0 ]; then
        # Play a sound effect
        if [ "$volume" -gt "$(get_volume)" ]; then
            play_sound "$VOLUME_UP_SOUND"
        else
            play_sound "$VOLUME_DOWN_SOUND"
        fi
        
        # Show success notification
        send_notification "Audio Manager" "Volume set to $volume%" "$AUDIO_ICON"
        
        # Update cache if caching is enabled
        if [ "$USE_CACHING" = true ]; then
            echo "timestamp:$(date +%s)" > "$CACHE_FILE"
            echo "volume:$volume" >> "$CACHE_FILE"
        fi
        
        echo "Volume set to $volume%"
    else
        # Show error notification
        send_notification "Audio Manager" "Failed to set volume" "$MUTE_ICON"
        
        echo "Failed to set volume"
    fi
}

# Function to increase volume
increase_volume() {
    # Check if pactl is installed
    check_pactl
    
    # Get current volume
    local volume=$(get_volume)
    
    # Increase volume by 5%
    local new_volume=$((volume + 5))
    
    # Cap at 100%
    if [ "$new_volume" -gt 100 ]; then
        new_volume=100
    fi
    
    # Set volume
    set_volume "$new_volume"
}

# Function to decrease volume
decrease_volume() {
    # Check if pactl is installed
    check_pactl
    
    # Get current volume
    local volume=$(get_volume)
    
    # Decrease volume by 5%
    local new_volume=$((volume - 5))
    
    # Cap at 0%
    if [ "$new_volume" -lt 0 ]; then
        new_volume=0
    fi
    
    # Set volume
    set_volume "$new_volume"
}

# Function to toggle mute
toggle_mute() {
    # Check if pactl is installed
    check_pactl
    
    # Get mute status
    local mute=$(get_mute_status)
    
    if [ "$mute" = "yes" ]; then
        # Unmute
        pactl set-sink-mute @DEFAULT_SINK@ 0
        
        # Play a sound effect
        play_sound "$UNMUTE_SOUND"
        
        # Show success notification
        send_notification "Audio Manager" "Unmuted" "$AUDIO_ICON"
        
        # Update cache if caching is enabled
        if [ "$USE_CACHING" = true ]; then
            echo "timestamp:$(date +%s)" > "$CACHE_FILE"
            echo "mute:no" >> "$CACHE_FILE"
        fi
        
        echo "Unmuted"
    else
        # Mute
        pactl set-sink-mute @DEFAULT_SINK@ 1
        
        # Play a sound effect
        play_sound "$MUTE_SOUND"
        
        # Show success notification
        send_notification "Audio Manager" "Muted" "$MUTE_ICON"
        
        # Update cache if caching is enabled
        if [ "$USE_CACHING" = true ]; then
            echo "timestamp:$(date +%s)" > "$CACHE_FILE"
            echo "mute:yes" >> "$CACHE_FILE"
        fi
        
        echo "Muted"
    fi
}

# Function to show audio information
show_audio_info() {
    # Check if pactl is installed
    check_pactl
    
    # Get volume
    local volume=$(get_volume)
    
    # Get mute status
    local mute=$(get_mute_status)
    
    # Get default sink
    if [ "$USE_SIMPLE_COMMANDS" = true ]; then
        # Simpler command for low-end devices
        local sink=$(pactl info | grep "Default Sink" | awk '{print $3}' 2>/dev/null || echo "unknown")
    else
        local sink=$(pactl info | grep "Default Sink" | awk '{print $3}')
    fi
    
    # Show audio information
    send_notification "Audio Manager" "Volume: $volume%\nMute: $mute\nSink: $sink" "$AUDIO_ICON"
    
    # Return the values for display
    echo "Volume: $volume% | Mute: $mute | Sink: $sink"
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
        USE_SIMPLE_COMMANDS=true
        USE_CACHING=true
    fi
}

# Main function
main() {
    # Detect system capabilities
    detect_system_capabilities
    
    # Check the argument
    case "$1" in
        "volume")
            get_volume
            ;;
        "mute")
            get_mute_status
            ;;
        "set")
            set_volume "$2"
            ;;
        "up")
            increase_volume
            ;;
        "down")
            decrease_volume
            ;;
        "toggle")
            toggle_mute
            ;;
        "info")
            show_audio_info
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_COMMANDS=true
            USE_CACHING=true
            send_notification "Audio Manager" "Low-end mode enabled" "$AUDIO_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_COMMANDS=false
            USE_CACHING=false
            send_notification "Audio Manager" "High-end mode enabled" "$AUDIO_ICON"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Show Volume\nShow Mute Status\nSet Volume\nIncrease Volume\nDecrease Volume\nToggle Mute\nShow Audio Information\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "Audio Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Show Volume")
                    get_volume
                    ;;
                "Show Mute Status")
                    get_mute_status
                    ;;
                "Set Volume")
                    volume=$(wofi --dmenu --prompt "Enter Volume (0-100)" --style "$HOME/.config/wofi/power-menu.css")
                    set_volume "$volume"
                    ;;
                "Increase Volume")
                    increase_volume
                    ;;
                "Decrease Volume")
                    decrease_volume
                    ;;
                "Toggle Mute")
                    toggle_mute
                    ;;
                "Show Audio Information")
                    show_audio_info
                    ;;
                "Enable Low-End Mode")
                    DISABLE_SOUNDS=true
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_COMMANDS=true
                    USE_CACHING=true
                    send_notification "Audio Manager" "Low-end mode enabled" "$AUDIO_ICON"
                    ;;
                "Enable High-End Mode")
                    DISABLE_SOUNDS=false
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_COMMANDS=false
                    USE_CACHING=false
                    send_notification "Audio Manager" "High-end mode enabled" "$AUDIO_ICON"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 