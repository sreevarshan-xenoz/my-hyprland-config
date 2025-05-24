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
SPLASH_TYPE="auto"     # Options: auto, video, image, minimal, none

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

# Function to show the selection menu
show_selection_menu() {
    print_message "$PURPLE" "=== Hyprland Anime Ricing Splash Screen Selection ==="
    print_message "$BLUE" "Please select your preferred splash screen type:"
    echo "1) Auto (Video if available, otherwise image)"
    echo "2) Video (Animated splash screen)"
    echo "3) Image (Static splash screen)"
    echo "4) Minimal (Simple text splash)"
    echo "5) None (Skip splash screen)"
    echo "6) Configure splash settings"
    echo "7) Exit without changes"
    
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1) SPLASH_TYPE="auto" ;;
        2) SPLASH_TYPE="video" ;;
        3) SPLASH_TYPE="image" ;;
        4) SPLASH_TYPE="minimal" ;;
        5) SPLASH_TYPE="none" ;;
        6) configure_splash_settings ;;
        7) exit 0 ;;
        *) print_message "$RED" "Invalid choice. Using default (auto)." ;;
    esac
    
    # Save the selection to a config file
    save_splash_config
}

# Function to configure splash settings
configure_splash_settings() {
    print_message "$PURPLE" "=== Splash Screen Configuration ==="
    
    # Configure theme
    print_message "$BLUE" "Available themes:"
    echo "1) Random (changes each time)"
    echo "2) Demon Slayer"
    echo "3) Attack on Titan"
    echo "4) Your Name"
    echo "5) Tokyo Ghoul"
    echo "6) Evangelion"
    echo "7) One Piece"
    echo "8) Naruto"
    echo "9) Sailor Moon"
    echo "10) Death Note"
    echo "11) Akira"
    echo "12) Princess Mononoke"
    echo "13) Cowboy Bebop"
    echo "14) Default"
    
    read -p "Select a theme (1-14): " theme_choice
    
    case $theme_choice in
        1) SPLASH_THEME="random" ;;
        2) SPLASH_THEME="demon-slayer" ;;
        3) SPLASH_THEME="attack-on-titan" ;;
        4) SPLASH_THEME="your-name" ;;
        5) SPLASH_THEME="tokyo-ghoul" ;;
        6) SPLASH_THEME="evangelion" ;;
        7) SPLASH_THEME="one-piece" ;;
        8) SPLASH_THEME="naruto" ;;
        9) SPLASH_THEME="sailor-moon" ;;
        10) SPLASH_THEME="death-note" ;;
        11) SPLASH_THEME="akira" ;;
        12) SPLASH_THEME="princess-mononoke" ;;
        13) SPLASH_THEME="cowboy-bebop" ;;
        14) SPLASH_THEME="default" ;;
        *) print_message "$RED" "Invalid choice. Using default theme." ;;
    esac
    
    # Configure duration
    read -p "Enter splash duration in seconds (1-10, default: 5): " duration
    if [[ $duration =~ ^[0-9]+$ ]] && [ $duration -ge 1 ] && [ $duration -le 10 ]; then
        SPLASH_DURATION=$duration
    else
        print_message "$YELLOW" "Invalid duration. Using default (5 seconds)."
    fi
    
    # Configure audio
    read -p "Enable audio for splash screen? (y/n, default: y): " audio_choice
    if [[ $audio_choice =~ ^[Yy]$ ]] || [ -z "$audio_choice" ]; then
        SPLASH_AUDIO=true
        
        # Configure volume
        read -p "Enter audio volume (0.0-1.0, default: 0.3): " volume
        if [[ $volume =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$volume >= 0.0 && $volume <= 1.0" | bc -l) )); then
            SPLASH_VOLUME=$volume
        else
            print_message "$YELLOW" "Invalid volume. Using default (0.3)."
        fi
    else
        SPLASH_AUDIO=false
    fi
    
    # Configure fade effect
    read -p "Enter fade effect duration in seconds (0.0-2.0, default: 1.0): " fade
    if [[ $fade =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$fade >= 0.0 && $fade <= 2.0" | bc -l) )); then
        SPLASH_FADE=$fade
    else
        print_message "$YELLOW" "Invalid fade duration. Using default (1.0 seconds)."
    fi
    
    print_message "$GREEN" "Splash screen configuration saved!"
    
    # Save the configuration
    save_splash_config
    
    # Return to the main menu
    show_selection_menu
}

# Function to save splash configuration
save_splash_config() {
    # Create config directory if it doesn't exist
    mkdir -p "$HOME/.config/hypr/splash"
    
    # Save configuration to a file
    cat > "$HOME/.config/hypr/splash/config.conf" << EOF
# Hyprland Anime Ricing Splash Screen Configuration
SPLASH_TYPE="$SPLASH_TYPE"
SPLASH_THEME="$SPLASH_THEME"
SPLASH_DURATION=$SPLASH_DURATION
SPLASH_AUDIO=$SPLASH_AUDIO
SPLASH_VOLUME=$SPLASH_VOLUME
SPLASH_FADE=$SPLASH_FADE
EOF
    
    print_message "$GREEN" "Splash screen configuration saved to $HOME/.config/hypr/splash/config.conf"
}

# Function to load splash configuration
load_splash_config() {
    local config_file="$HOME/.config/hypr/splash/config.conf"
    
    if [ -f "$config_file" ]; then
        print_message "$BLUE" "Loading splash screen configuration..."
        source "$config_file"
        print_message "$GREEN" "Configuration loaded!"
    else
        print_message "$YELLOW" "No configuration file found. Using defaults."
    fi
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

# Function to show a minimal splash screen
show_minimal_splash() {
    print_message "$GREEN" "Showing minimal splash screen..."
    
    # Create a temporary minimal splash image
    local temp_image="/tmp/minimal-splash.png"
    
    # Check if ImageMagick is installed
    if ! command_exists "convert"; then
        print_message "$RED" "ImageMagick not found. Cannot create minimal splash."
        return 1
    fi
    
    # Create a simple splash image
    convert -size 1920x1080 xc:black -fill white -gravity center -pointsize 72 -annotate 0 "Hyprland\nAnime Ricing" "$temp_image"
    
    # Display the minimal splash
    if command_exists "swww"; then
        # Initialize swww if not already running
        if ! pgrep -x "swww" > /dev/null; then
            swww init
        fi
        
        # Display the splash image with a fade effect
        swww img "$temp_image" --transition-fps 60 --transition-type fade --transition-duration $SPLASH_FADE
        
        # Wait for the splash duration
        sleep $SPLASH_DURATION
        
        # Clear the splash image
        swww clear
    elif command_exists "feh"; then
        # Display the splash image
        feh --fullscreen --hide-pointer "$temp_image" &
        FEH_PID=$!
        
        # Wait for the splash duration
        sleep $SPLASH_DURATION
        
        # Kill feh
        kill $FEH_PID
    else
        print_message "$RED" "Neither swww nor feh found. Cannot display minimal splash."
        return 1
    fi
    
    # Remove the temporary image
    rm -f "$temp_image"
}

# Function to show the splash screen
show_splash() {
    # Skip splash if configured to none
    if [ "$SPLASH_TYPE" = "none" ]; then
        print_message "$YELLOW" "Splash screen disabled. Skipping..."
        return 0
    fi
    
    # Select theme-based splash if configured
    if [ "$SPLASH_THEME" != "default" ]; then
        select_theme_splash "$SPLASH_THEME"
    fi
    
    # Determine splash type if set to auto
    if [ "$SPLASH_TYPE" = "auto" ]; then
        if [ -f "$SPLASH_VIDEO" ] && command_exists "mpv"; then
            SPLASH_TYPE="video"
        elif [ -f "$SPLASH_IMAGE" ] && (command_exists "swww" || command_exists "feh"); then
            SPLASH_TYPE="image"
        else
            SPLASH_TYPE="minimal"
        fi
    fi
    
    # Show the appropriate splash screen
    case "$SPLASH_TYPE" in
        "video")
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
            else
                print_message "$YELLOW" "Video splash not available. Falling back to image splash."
                SPLASH_TYPE="image"
                show_splash
            fi
            ;;
        "image")
            if [ -f "$SPLASH_IMAGE" ] && command_exists "swww"; then
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
                print_message "$YELLOW" "Image splash not available. Falling back to minimal splash."
                SPLASH_TYPE="minimal"
                show_splash
            fi
            ;;
        "minimal")
            show_minimal_splash
            ;;
        *)
            print_message "$RED" "Unknown splash type: $SPLASH_TYPE. Using minimal splash."
            SPLASH_TYPE="minimal"
            show_splash
            ;;
    esac
}

# Function to show the setup menu
show_setup_menu() {
    print_message "$PURPLE" "=== Hyprland Anime Ricing Splash Screen Setup ==="
    print_message "$BLUE" "What would you like to do?"
    echo "1) Configure splash screen settings"
    echo "2) Create new splash images"
    echo "3) Download sample splash videos"
    echo "4) Return to main menu"
    echo "5) Exit"
    
    read -p "Enter your choice (1-5): " setup_choice
    
    case $setup_choice in
        1) 
            configure_splash_settings
            show_setup_menu
            ;;
        2)
            print_message "$BLUE" "Creating new splash images..."
            "$HOME/.config/hypr/scripts/create-splash-image.sh"
            show_setup_menu
            ;;
        3)
            print_message "$BLUE" "Downloading sample splash videos..."
            # This would be implemented to download actual anime splash videos
            print_message "$YELLOW" "This feature is not yet implemented."
            show_setup_menu
            ;;
        4)
            show_selection_menu
            ;;
        5)
            exit 0
            ;;
        *)
            print_message "$RED" "Invalid choice."
            show_setup_menu
            ;;
    esac
}

# Main function
main() {
    # Check if this is the first run
    if [ ! -f "$HOME/.config/hypr/splash/config.conf" ]; then
        print_message "$PURPLE" "=== First-time Splash Screen Setup ==="
        print_message "$BLUE" "This appears to be your first time running the splash screen."
        print_message "$BLUE" "Would you like to configure it now? (y/n)"
        read -p "Enter your choice (y/n): " first_run_choice
        
        if [[ $first_run_choice =~ ^[Yy]$ ]]; then
            show_setup_menu
        else
            # Use defaults
            save_splash_config
        fi
    else
        # Load existing configuration
        load_splash_config
        
        # Check if we're being called with a setup parameter
        if [ "$1" = "setup" ]; then
            show_setup_menu
            exit 0
        elif [ "$1" = "select" ]; then
            show_selection_menu
            exit 0
        fi
    fi
    
    # Setup splash files if needed
    setup_splash
    
    # Show the splash screen
    show_splash
    
    print_message "$GREEN" "Splash screen complete. Starting Hyprland..."
}

# Run the main function
main "$@"

# Exit with success
exit 0 