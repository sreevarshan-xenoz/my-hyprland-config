#!/bin/bash

# anime-splash.sh - Anime-themed splash screen for Hyprland
# This script displays an anime-themed splash screen before starting Hyprland

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration file
CONFIG_FILE="$HOME/.config/hypr/splash/config.conf"

# Default values
SPLASH_TYPE="auto"
SPLASH_THEME="default"
SPLASH_DURATION=5
SPLASH_AUDIO=true
SPLASH_FADE=true
SPLASH_FADE_DURATION=1
CUSTOM_SPLASH_PATH=""

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to detect system capabilities
detect_system_capabilities() {
    # Check if mpv is available for video playback
    if command_exists "mpv"; then
        HAS_MPV=true
    else
        HAS_MPV=false
    fi
    
    # Check if swww is available for image display
    if command_exists "swww"; then
        HAS_SWWW=true
    else
        HAS_SWWW=false
    fi
    
    # Check if feh is available for image display
    if command_exists "feh"; then
        HAS_FEH=true
    else
        HAS_FEH=false
    fi
    
    # Check if bc is available for calculations
    if command_exists "bc"; then
        HAS_BC=true
    else
        HAS_BC=false
    fi
    
    # Check if audio is available
    if command_exists "pactl" || command_exists "amixer"; then
        HAS_AUDIO=true
    else
        HAS_AUDIO=false
    fi
    
    # Check if we're running in a terminal
    if [ -t 1 ]; then
        IS_TERMINAL=true
    else
        IS_TERMINAL=false
    fi
    
    # Check if we're running in a Wayland session
    if [ -n "$WAYLAND_DISPLAY" ]; then
        IS_WAYLAND=true
    else
        IS_WAYLAND=false
    fi
    
    # Check if we're running in an X session
    if [ -n "$DISPLAY" ]; then
        IS_X=true
    else
        IS_X=false
    fi
}

# Function to determine the best splash screen type
determine_best_splash_type() {
    if [ "$SPLASH_TYPE" = "auto" ]; then
        if [ "$HAS_MPV" = true ] && [ "$IS_WAYLAND" = true ]; then
            SPLASH_TYPE="video"
        elif [ "$HAS_SWWW" = true ] && [ "$IS_WAYLAND" = true ]; then
            SPLASH_TYPE="image"
        elif [ "$HAS_FEH" = true ] && [ "$IS_X" = true ]; then
            SPLASH_TYPE="image"
        else
            SPLASH_TYPE="minimal"
        fi
    fi
}

# Function to show the selection menu
show_selection_menu() {
    # If the script is called with the "select" argument, launch the splash selector
    if [ "$1" = "select" ]; then
        "$HOME/.config/hypr/scripts/splash-selector.sh"
        exit 0
    fi
}

# Function to show the splash screen
show_splash() {
    # Load configuration
    load_config
    
    # Detect system capabilities
    detect_system_capabilities
    
    # Determine the best splash screen type
    determine_best_splash_type
    
    # Show the appropriate splash screen based on the type
    case "$SPLASH_TYPE" in
        "video")
            show_video_splash
            ;;
        "image")
            show_image_splash
            ;;
        "minimal")
            show_minimal_splash
            ;;
        "none")
            print_message "$YELLOW" "Splash screen disabled."
            ;;
        *)
            print_message "$RED" "Unknown splash screen type: $SPLASH_TYPE"
            show_minimal_splash
            ;;
    esac
}

# Function to show a video splash screen
show_video_splash() {
    # Check if mpv is available
    if [ "$HAS_MPV" = false ]; then
        print_message "$RED" "mpv is not available. Falling back to minimal splash screen."
        show_minimal_splash
        return
    fi
    
    # Get the video path based on the theme
    local video_path
    case "$SPLASH_THEME" in
        "default")
            video_path="$HOME/.config/hypr/splash/videos/default.mp4"
            ;;
        "cyberpunk")
            video_path="$HOME/.config/hypr/splash/videos/cyberpunk.mp4"
            ;;
        "kawaii")
            video_path="$HOME/.config/hypr/splash/videos/kawaii.mp4"
            ;;
        "minimal")
            video_path="$HOME/.config/hypr/splash/videos/minimal.mp4"
            ;;
        "custom")
            if [ -n "$CUSTOM_SPLASH_PATH" ] && file_exists "$CUSTOM_SPLASH_PATH"; then
                video_path="$CUSTOM_SPLASH_PATH"
            else
                print_message "$RED" "Custom video not found. Using default video."
                video_path="$HOME/.config/hypr/splash/videos/default.mp4"
            fi
            ;;
        *)
            print_message "$RED" "Unknown theme: $SPLASH_THEME. Using default theme."
            video_path="$HOME/.config/hypr/splash/videos/default.mp4"
            ;;
    esac
    
    # Check if the video exists
    if ! file_exists "$video_path"; then
        print_message "$RED" "Video not found: $video_path"
        print_message "$YELLOW" "Falling back to minimal splash screen."
        show_minimal_splash
        return
    fi
    
    # Play the video
    print_message "$GREEN" "Playing video splash screen: $video_path"
    
    # Set audio options
    local audio_options=""
    if [ "$SPLASH_AUDIO" = true ] && [ "$HAS_AUDIO" = true ]; then
        audio_options="--no-mute"
    else
        audio_options="--mute"
    fi
    
    # Play the video with mpv
    if [ "$1" = "preview" ]; then
        # In preview mode, show the video in a window
        mpv --no-border --no-window-controls --no-input-default-bindings --no-terminal --no-osc --no-osd-bar --loop=1 --no-audio-display $audio_options "$video_path" &
        sleep "$SPLASH_DURATION"
        pkill -f "mpv.*$video_path"
    else
        # In normal mode, show the video fullscreen
        if [ "$IS_WAYLAND" = true ]; then
            # For Wayland, use mpv with wayland output
            mpv --no-border --no-window-controls --no-input-default-bindings --no-terminal --no-osc --no-osd-bar --loop=1 --no-audio-display --vo=gpu --gpu-context=wayland $audio_options "$video_path" &
            sleep "$SPLASH_DURATION"
            pkill -f "mpv.*$video_path"
        elif [ "$IS_X" = true ]; then
            # For X, use mpv with x11 output
            mpv --no-border --no-window-controls --no-input-default-bindings --no-terminal --no-osc --no-osd-bar --loop=1 --no-audio-display --vo=gpu --gpu-context=x11 $audio_options "$video_path" &
            sleep "$SPLASH_DURATION"
            pkill -f "mpv.*$video_path"
        else
            # Fallback to minimal splash screen
            print_message "$RED" "Neither Wayland nor X detected. Falling back to minimal splash screen."
            show_minimal_splash
        fi
    fi
}

# Function to show an image splash screen
show_image_splash() {
    # Get the image path based on the theme
    local image_path
    case "$SPLASH_THEME" in
        "default")
            image_path="$HOME/.config/hypr/splash/images/default.png"
            ;;
        "cyberpunk")
            image_path="$HOME/.config/hypr/splash/images/cyberpunk.png"
            ;;
        "kawaii")
            image_path="$HOME/.config/hypr/splash/images/kawaii.png"
            ;;
        "minimal")
            image_path="$HOME/.config/hypr/splash/images/minimal.png"
            ;;
        "custom")
            if [ -n "$CUSTOM_SPLASH_PATH" ] && file_exists "$CUSTOM_SPLASH_PATH"; then
                image_path="$CUSTOM_SPLASH_PATH"
            else
                print_message "$RED" "Custom image not found. Using default image."
                image_path="$HOME/.config/hypr/splash/images/default.png"
            fi
            ;;
        *)
            print_message "$RED" "Unknown theme: $SPLASH_THEME. Using default theme."
            image_path="$HOME/.config/hypr/splash/images/default.png"
            ;;
    esac
    
    # Check if the image exists
    if ! file_exists "$image_path"; then
        print_message "$RED" "Image not found: $image_path"
        print_message "$YELLOW" "Falling back to minimal splash screen."
        show_minimal_splash
        return
    fi
    
    # Display the image
    print_message "$GREEN" "Displaying image splash screen: $image_path"
    
    # Play audio if enabled
    if [ "$SPLASH_AUDIO" = true ] && [ "$HAS_AUDIO" = true ]; then
        # Get the audio path based on the theme
        local audio_path
        case "$SPLASH_THEME" in
            "default")
                audio_path="$HOME/.config/hypr/splash/sounds/default.mp3"
                ;;
            "cyberpunk")
                audio_path="$HOME/.config/hypr/splash/sounds/cyberpunk.mp3"
                ;;
            "kawaii")
                audio_path="$HOME/.config/hypr/splash/sounds/kawaii.mp3"
                ;;
            "minimal")
                audio_path="$HOME/.config/hypr/splash/sounds/minimal.mp3"
                ;;
            "custom")
                # For custom theme, try to find a matching audio file
                audio_path="$HOME/.config/hypr/splash/sounds/default.mp3"
                ;;
            *)
                audio_path="$HOME/.config/hypr/splash/sounds/default.mp3"
                ;;
        esac
        
        # Check if the audio exists
        if file_exists "$audio_path"; then
            # Play the audio in the background
            if command_exists "mpv"; then
                mpv --no-video --no-terminal --no-osc --no-osd-bar "$audio_path" &
            elif command_exists "paplay"; then
                paplay "$audio_path" &
            elif command_exists "aplay"; then
                aplay "$audio_path" &
            fi
        fi
    fi
    
    # Display the image with fade effects if enabled
    if [ "$SPLASH_FADE" = true ] && [ "$HAS_BC" = true ]; then
        # Calculate fade steps
        local fade_steps=$(echo "scale=0; $SPLASH_FADE_DURATION * 10" | bc)
        local step_duration=$(echo "scale=2; $SPLASH_FADE_DURATION / $fade_steps" | bc)
        
        # Fade in
        for i in $(seq 0 $fade_steps); do
            local opacity=$(echo "scale=2; $i / $fade_steps" | bc)
            if [ "$IS_WAYLAND" = true ] && [ "$HAS_SWWW" = true ]; then
                # For Wayland, use swww
                swww img "$image_path" --transition-step 1 --transition-fps 60 --transition-type fade --transition-pos 0,0 --transition-bezier 0.0,0.0,1.0,1.0 --transition-duration $step_duration
            elif [ "$IS_X" = true ] && [ "$HAS_FEH" = true ]; then
                # For X, use feh with fade effect
                feh --bg-fill "$image_path" --no-fehbg
                # Apply fade effect using xrandr
                if command_exists "xrandr"; then
                    for output in $(xrandr --query | grep " connected" | cut -d" " -f1); do
                        xrandr --output "$output" --brightness "$opacity"
                    done
                fi
            else
                # Fallback to minimal splash screen
                print_message "$RED" "Neither swww nor feh available. Falling back to minimal splash screen."
                show_minimal_splash
                return
            fi
            sleep "$step_duration"
        done
        
        # Display for the specified duration
        sleep "$SPLASH_DURATION"
        
        # Fade out
        for i in $(seq $fade_steps -1 0); do
            local opacity=$(echo "scale=2; $i / $fade_steps" | bc)
            if [ "$IS_WAYLAND" = true ] && [ "$HAS_SWWW" = true ]; then
                # For Wayland, use swww
                swww img "$image_path" --transition-step 1 --transition-fps 60 --transition-type fade --transition-pos 0,0 --transition-bezier 0.0,0.0,1.0,1.0 --transition-duration $step_duration
            elif [ "$IS_X" = true ] && [ "$HAS_FEH" = true ]; then
                # For X, use feh with fade effect
                feh --bg-fill "$image_path" --no-fehbg
                # Apply fade effect using xrandr
                if command_exists "xrandr"; then
                    for output in $(xrandr --query | grep " connected" | cut -d" " -f1); do
                        xrandr --output "$output" --brightness "$opacity"
                    done
                fi
            else
                # Fallback to minimal splash screen
                print_message "$RED" "Neither swww nor feh available. Falling back to minimal splash screen."
                show_minimal_splash
                return
            fi
            sleep "$step_duration"
        done
    else
        # Display without fade effects
        if [ "$IS_WAYLAND" = true ] && [ "$HAS_SWWW" = true ]; then
            # For Wayland, use swww
            swww img "$image_path" --transition-type none
        elif [ "$IS_X" = true ] && [ "$HAS_FEH" = true ]; then
            # For X, use feh
            feh --bg-fill "$image_path" --no-fehbg
        else
            # Fallback to minimal splash screen
            print_message "$RED" "Neither swww nor feh available. Falling back to minimal splash screen."
            show_minimal_splash
            return
        fi
        
        # Display for the specified duration
        sleep "$SPLASH_DURATION"
    fi
}

# Function to show a minimal splash screen
show_minimal_splash() {
    # Get the text based on the theme
    local splash_text
    case "$SPLASH_THEME" in
        "default")
            splash_text="Welcome to Hyprland Anime Ricing"
            ;;
        "cyberpunk")
            splash_text="Welcome to Cyberpunk Hyprland"
            ;;
        "kawaii")
            splash_text="Welcome to Kawaii Hyprland"
            ;;
        "minimal")
            splash_text="Welcome to Hyprland"
            ;;
        "custom")
            splash_text="Welcome to Hyprland"
            ;;
        *)
            splash_text="Welcome to Hyprland"
            ;;
    esac
    
    # Display the minimal splash screen
    print_message "$PURPLE" "=== $splash_text ==="
    print_message "$CYAN" "Loading your desktop environment..."
    
    # Play audio if enabled
    if [ "$SPLASH_AUDIO" = true ] && [ "$HAS_AUDIO" = true ]; then
        # Get the audio path based on the theme
        local audio_path
        case "$SPLASH_THEME" in
            "default")
                audio_path="$HOME/.config/hypr/splash/sounds/default.mp3"
                ;;
            "cyberpunk")
                audio_path="$HOME/.config/hypr/splash/sounds/cyberpunk.mp3"
                ;;
            "kawaii")
                audio_path="$HOME/.config/hypr/splash/sounds/kawaii.mp3"
                ;;
            "minimal")
                audio_path="$HOME/.config/hypr/splash/sounds/minimal.mp3"
                ;;
            "custom")
                # For custom theme, try to find a matching audio file
                audio_path="$HOME/.config/hypr/splash/sounds/default.mp3"
                ;;
            *)
                audio_path="$HOME/.config/hypr/splash/sounds/default.mp3"
                ;;
        esac
        
        # Check if the audio exists
        if file_exists "$audio_path"; then
            # Play the audio in the background
            if command_exists "mpv"; then
                mpv --no-video --no-terminal --no-osc --no-osd-bar "$audio_path" &
            elif command_exists "paplay"; then
                paplay "$audio_path" &
            elif command_exists "aplay"; then
                aplay "$audio_path" &
            fi
        fi
    fi
    
    # Display for the specified duration
    sleep "$SPLASH_DURATION"
    
    print_message "$GREEN" "=== Splash screen complete! ==="
}

# Main function
main() {
    # Check if the script is called with the "select" argument
    if [ "$1" = "select" ]; then
        show_selection_menu "$1"
        exit 0
    fi
    
    # Check if the script is called with the "preview" argument
    if [ "$1" = "preview" ]; then
        show_splash
        exit 0
    fi
    
    # Show the splash screen
    show_splash
}

# Run the main function
main "$@"

# Exit with success
exit 0 