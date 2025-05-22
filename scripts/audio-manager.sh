#!/bin/bash

# Anime-themed Audio Manager Script
# --------------------------------
# This script manages audio with anime-themed notifications

# Configuration
AUDIO_ICON="$HOME/.config/hypr/icons/audio.png"
MUTE_ICON="$HOME/.config/hypr/icons/mute.png"
VOLUME_UP_SOUND="$HOME/.config/hypr/sounds/volume-up.wav"
VOLUME_DOWN_SOUND="$HOME/.config/hypr/sounds/volume-down.wav"
MUTE_SOUND="$HOME/.config/hypr/sounds/mute.wav"
UNMUTE_SOUND="$HOME/.config/hypr/sounds/unmute.wav"

# Function to check if pactl is installed
check_pactl() {
    if ! command -v pactl &> /dev/null; then
        notify-send "Audio Manager" "pactl is not installed. Please install it to use this script." -i "$MUTE_ICON"
        exit 1
    fi
}

# Function to get volume
get_volume() {
    # Check if pactl is installed
    check_pactl
    
    # Get volume
    local volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
    
    echo "$volume"
}

# Function to get mute status
get_mute_status() {
    # Check if pactl is installed
    check_pactl
    
    # Get mute status
    local mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    
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
            paplay "$VOLUME_UP_SOUND" &
        else
            paplay "$VOLUME_DOWN_SOUND" &
        fi
        
        # Show success notification
        notify-send "Audio Manager" "Volume set to $volume%" -i "$AUDIO_ICON"
        
        echo "Volume set to $volume%"
    else
        # Show error notification
        notify-send "Audio Manager" "Failed to set volume" -i "$MUTE_ICON"
        
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
        paplay "$UNMUTE_SOUND" &
        
        # Show success notification
        notify-send "Audio Manager" "Unmuted" -i "$AUDIO_ICON"
        
        echo "Unmuted"
    else
        # Mute
        pactl set-sink-mute @DEFAULT_SINK@ 1
        
        # Play a sound effect
        paplay "$MUTE_SOUND" &
        
        # Show success notification
        notify-send "Audio Manager" "Muted" -i "$MUTE_ICON"
        
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
    local sink=$(pactl info | grep "Default Sink" | awk '{print $3}')
    
    # Show audio information
    notify-send "Audio Manager" "Volume: $volume%\nMute: $mute\nSink: $sink" -i "$AUDIO_ICON"
    
    # Return the values for display
    echo "Volume: $volume% | Mute: $mute | Sink: $sink"
}

# Main function
main() {
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
        *)
            # Show a menu
            choice=$(echo -e "Show Volume\nShow Mute Status\nSet Volume\nIncrease Volume\nDecrease Volume\nToggle Mute\nShow Audio Information" | wofi --dmenu --prompt "Audio Manager" --style "$HOME/.config/wofi/power-menu.css")
            
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
            esac
            ;;
    esac
}

# Run the main function
main "$@" 