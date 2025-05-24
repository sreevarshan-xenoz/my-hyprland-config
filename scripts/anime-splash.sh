#!/bin/bash

# anime-splash.sh - Anime-themed splash screen for Hyprland
# Part of the Hyprland Anime Ricing - Ultimate Edition
# https://github.com/sreevarshan-xenoz/my-hyprland-config

# Configuration
SPLASH_DIR="$HOME/.config/hypr/splash"
SPLASH_VIDEO="$SPLASH_DIR/splash.mp4"
SPLASH_IMAGE="$SPLASH_DIR/splash.png"
SPLASH_DURATION=5
SPLASH_AUDIO=true
SPLASH_VOLUME=0.3
SPLASH_FADE=1.0
SPLASH_THEME="random"  # Options: random, demon-slayer, attack-on-titan, your-name, etc.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create splash directory and download splash files if needed
setup_splash() {
    # Create splash directory if it doesn't exist
    if [ ! -d "$SPLASH_DIR" ]; then
        print_message "$BLUE" "Creating splash directory at $SPLASH_DIR..."
        mkdir -p "$SPLASH_DIR"
    fi

    # Check if splash files exist
    if [ ! -f "$SPLASH_VIDEO" ] && [ ! -f "$SPLASH_IMAGE" ]; then
        print_message "$YELLOW" "No splash files found. Downloading sample splash files..."
        
        # Create a simple splash image if no video is available
        if ! command_exists "convert"; then
            print_message "$YELLOW" "ImageMagick not found. Installing..."
            if command_exists "pacman"; then
                sudo pacman -S --noconfirm imagemagick
            elif command_exists "apt"; then
                sudo apt install -y imagemagick
            else
                print_message "$RED" "Could not install ImageMagick. Please install it manually."
                return 1
            fi
        fi
        
        # Create a simple splash image
        convert -size 1920x1080 xc:black -fill white -gravity center -pointsize 72 -annotate 0 "Hyprland\nAnime Ricing" "$SPLASH_IMAGE"
        
        # Try to download a sample splash video if mpv is available
        if command_exists "mpv"; then
            print_message "$YELLOW" "Downloading sample splash video..."
            # This is a placeholder URL - you would replace with actual anime splash video
            # wget -O "$SPLASH_VIDEO" "https://example.com/anime-splash.mp4" || print_message "$RED" "Failed to download splash video."
            
            # For now, we'll just create a simple video using ffmpeg if available
            if command_exists "ffmpeg"; then
                print_message "$YELLOW" "Creating a simple splash video..."
                ffmpeg -f lavfi -i color=c=black:s=1920x1080:d=$SPLASH_DURATION -vf "drawtext=fontfile=/usr/share/fonts/TTF/DejaVuSans-Bold.ttf:text='Hyprland Anime Ricing':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=(h-text_h)/2" -c:v libx264 -pix_fmt yuv420p "$SPLASH_VIDEO" -y
            else
                print_message "$RED" "ffmpeg not found. Please install it to create splash videos."
            fi
        fi
    fi
}

# Function to select a theme-based splash
select_theme_splash() {
    local theme=$1
    local themes_dir="$HOME/.config/hypr/themes"
    
    # If theme is "random", pick a random theme
    if [ "$theme" = "random" ]; then
        if [ -d "$themes_dir" ]; then
            # Get list of themes and pick one randomly
            themes=($(ls -d "$themes_dir"/*/ 2>/dev/null | xargs -n1 basename))
            if [ ${#themes[@]} -gt 0 ]; then
                theme=${themes[$RANDOM % ${#themes[@]}]}
                print_message "$GREEN" "Selected random theme: $theme"
            else
                print_message "$YELLOW" "No themes found. Using default splash."
                return
            fi
        else
            print_message "$YELLOW" "Themes directory not found. Using default splash."
            return
        fi
    fi
    
    # Check if theme-specific splash exists
    if [ -f "$themes_dir/$theme/splash.mp4" ]; then
        SPLASH_VIDEO="$themes_dir/$theme/splash.mp4"
        print_message "$GREEN" "Using theme-specific splash: $SPLASH_VIDEO"
    elif [ -f "$themes_dir/$theme/splash.png" ]; then
        SPLASH_IMAGE="$themes_dir/$theme/splash.png"
        print_message "$GREEN" "Using theme-specific splash: $SPLASH_IMAGE"
    else
        print_message "$YELLOW" "No theme-specific splash found for $theme. Using default splash."
    fi
}

# Function to show the splash screen
show_splash() {
    # Select theme-based splash if configured
    if [ "$SPLASH_THEME" != "default" ]; then
        select_theme_splash "$SPLASH_THEME"
    fi
    
    # Check if we have a video or image splash
    if [ -f "$SPLASH_VIDEO" ] && command_exists "mpv"; then
        print_message "$GREEN" "Showing video splash screen..."
        
        # Set audio options
        local audio_opts=""
        if [ "$SPLASH_AUDIO" = true ]; then
            audio_opts="--volume=$SPLASH_VOLUME"
        else
            audio_opts="--no-audio"
        fi
        
        # Play the splash video
        mpv --no-terminal --no-border --no-window-controls --no-input-default-bindings \
            --no-input-vo-keyboard --no-osc --no-osd-bar --no-sub --no-sub-auto \
            --no-config --no-ytdl --no-cache --no-demuxer-thread --no-hr-seek \
            --no-keep-open --no-resume-playback --no-terminal --no-video-sync \
            --no-audio-display --no-msg-color --no-msg-module --no-msg-time \
            --no-border --no-window-controls --no-input-default-bindings \
            --no-input-vo-keyboard --no-osc --no-osd-bar --no-sub --no-sub-auto \
            --no-config --no-ytdl --no-cache --no-demuxer-thread --no-hr-seek \
            --no-keep-open --no-resume-playback --no-terminal --no-video-sync \
            --no-audio-display --no-msg-color --no-msg-module --no-msg-time \
            --loop=inf --length=$SPLASH_DURATION $audio_opts "$SPLASH_VIDEO" &
        
        # Wait for the splash duration
        sleep $SPLASH_DURATION
        
        # Kill mpv
        pkill mpv
    elif [ -f "$SPLASH_IMAGE" ] && command_exists "swww"; then
        print_message "$GREEN" "Showing image splash screen..."
        
        # Initialize swww if not already running
        if ! pgrep -x "swww" > /dev/null; then
            swww init
        fi
        
        # Display the splash image with a fade effect
        swww img "$SPLASH_IMAGE" --transition-fps 60 --transition-type fade --transition-duration $SPLASH_FADE
        
        # Wait for the splash duration
        sleep $SPLASH_DURATION
        
        # Clear the splash image
        swww clear
    elif [ -f "$SPLASH_IMAGE" ] && command_exists "feh"; then
        print_message "$GREEN" "Showing image splash screen with feh..."
        
        # Display the splash image
        feh --fullscreen --hide-pointer "$SPLASH_IMAGE" &
        FEH_PID=$!
        
        # Wait for the splash duration
        sleep $SPLASH_DURATION
        
        # Kill feh
        kill $FEH_PID
    else
        print_message "$YELLOW" "No suitable splash display method found. Skipping splash screen."
    fi
}

# Main function
main() {
    print_message "$PURPLE" "=== Hyprland Anime Ricing Splash Screen ==="
    
    # Setup splash files if needed
    setup_splash
    
    # Show the splash screen
    show_splash
    
    print_message "$GREEN" "Splash screen complete. Starting Hyprland..."
}

# Run the main function
main

# Exit with success
exit 0 