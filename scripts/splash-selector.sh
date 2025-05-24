#!/bin/bash

# splash-selector.sh - Splash screen selection script for Hyprland Anime Ricing
# This script provides a user-friendly interface to select and configure the splash screen

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
    else
        # Default values
        SPLASH_TYPE="auto"
        SPLASH_THEME="default"
        SPLASH_DURATION=5
        SPLASH_AUDIO=true
        SPLASH_FADE=true
        SPLASH_FADE_DURATION=1
    fi
}

# Function to save configuration
save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << EOF
# Hyprland Anime Splash Screen Configuration
# Generated on $(date)

# Splash screen type (auto, video, image, minimal, none)
SPLASH_TYPE="$SPLASH_TYPE"

# Splash screen theme (default, cyberpunk, kawaii, minimal, custom)
SPLASH_THEME="$SPLASH_THEME"

# Splash screen duration in seconds
SPLASH_DURATION=$SPLASH_DURATION

# Enable/disable audio
SPLASH_AUDIO=$SPLASH_AUDIO

# Enable/disable fade effects
SPLASH_FADE=$SPLASH_FADE

# Fade duration in seconds
SPLASH_FADE_DURATION=$SPLASH_FADE_DURATION

# Custom splash screen path (if SPLASH_THEME is set to "custom")
CUSTOM_SPLASH_PATH="$CUSTOM_SPLASH_PATH"
EOF
    
    print_message "$GREEN" "Configuration saved to $CONFIG_FILE"
}

# Function to show the main selection menu
show_main_menu() {
    clear
    print_message "$PURPLE" "=== Hyprland Anime Splash Screen Selector ==="
    print_message "$BLUE" "Current settings:"
    print_message "$CYAN" "  Type: $SPLASH_TYPE"
    print_message "$CYAN" "  Theme: $SPLASH_THEME"
    print_message "$CYAN" "  Duration: ${SPLASH_DURATION}s"
    print_message "$CYAN" "  Audio: $([ "$SPLASH_AUDIO" = true ] && echo "Enabled" || echo "Disabled")"
    print_message "$CYAN" "  Fade effects: $([ "$SPLASH_FADE" = true ] && echo "Enabled" || echo "Disabled")"
    if [ "$SPLASH_FADE" = true ]; then
        print_message "$CYAN" "  Fade duration: ${SPLASH_FADE_DURATION}s"
    fi
    if [ "$SPLASH_THEME" = "custom" ]; then
        print_message "$CYAN" "  Custom path: $CUSTOM_SPLASH_PATH"
    fi
    print_message "$PURPLE" "============================================"
    print_message "$YELLOW" "Select an option:"
    print_message "$GREEN" "1) Change splash screen type"
    print_message "$GREEN" "2) Change splash screen theme"
    print_message "$GREEN" "3) Change splash screen duration"
    print_message "$GREEN" "4) Toggle audio"
    print_message "$GREEN" "5) Toggle fade effects"
    print_message "$GREEN" "6) Change fade duration"
    print_message "$GREEN" "7) Preview current splash screen"
    print_message "$GREEN" "8) Save and exit"
    print_message "$RED" "9) Exit without saving"
    
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) select_splash_type ;;
        2) select_splash_theme ;;
        3) set_splash_duration ;;
        4) toggle_audio ;;
        5) toggle_fade ;;
        6) set_fade_duration ;;
        7) preview_splash ;;
        8) save_config; exit 0 ;;
        9) exit 0 ;;
        *) print_message "$RED" "Invalid option. Please try again."; sleep 1; show_main_menu ;;
    esac
}

# Function to select splash screen type
select_splash_type() {
    clear
    print_message "$PURPLE" "=== Select Splash Screen Type ==="
    print_message "$YELLOW" "Choose a splash screen type:"
    print_message "$GREEN" "1) Auto (automatically choose based on system capabilities)"
    print_message "$GREEN" "2) Video (animated splash screen with video)"
    print_message "$GREEN" "3) Image (static image with fade effects)"
    print_message "$GREEN" "4) Minimal (simple text-based splash screen)"
    print_message "$GREEN" "5) None (disable splash screen)"
    print_message "$BLUE" "6) Back to main menu"
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1) SPLASH_TYPE="auto"; print_message "$GREEN" "Splash screen type set to: Auto" ;;
        2) SPLASH_TYPE="video"; print_message "$GREEN" "Splash screen type set to: Video" ;;
        3) SPLASH_TYPE="image"; print_message "$GREEN" "Splash screen type set to: Image" ;;
        4) SPLASH_TYPE="minimal"; print_message "$GREEN" "Splash screen type set to: Minimal" ;;
        5) SPLASH_TYPE="none"; print_message "$GREEN" "Splash screen type set to: None" ;;
        6) show_main_menu; return ;;
        *) print_message "$RED" "Invalid option. Please try again."; sleep 1; select_splash_type ;;
    esac
    
    sleep 1
    show_main_menu
}

# Function to select splash screen theme
select_splash_theme() {
    clear
    print_message "$PURPLE" "=== Select Splash Screen Theme ==="
    print_message "$YELLOW" "Choose a splash screen theme:"
    print_message "$GREEN" "1) Default (anime-themed splash screen)"
    print_message "$GREEN" "2) Cyberpunk (futuristic cyberpunk theme)"
    print_message "$GREEN" "3) Kawaii (cute anime theme)"
    print_message "$GREEN" "4) Minimal (simple and clean theme)"
    print_message "$GREEN" "5) Custom (use your own splash screen)"
    print_message "$BLUE" "6) Back to main menu"
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1) SPLASH_THEME="default"; print_message "$GREEN" "Splash screen theme set to: Default" ;;
        2) SPLASH_THEME="cyberpunk"; print_message "$GREEN" "Splash screen theme set to: Cyberpunk" ;;
        3) SPLASH_THEME="kawaii"; print_message "$GREEN" "Splash screen theme set to: Kawaii" ;;
        4) SPLASH_THEME="minimal"; print_message "$GREEN" "Splash screen theme set to: Minimal" ;;
        5) set_custom_splash ;;
        6) show_main_menu; return ;;
        *) print_message "$RED" "Invalid option. Please try again."; sleep 1; select_splash_theme ;;
    esac
    
    sleep 1
    show_main_menu
}

# Function to set custom splash screen
set_custom_splash() {
    SPLASH_THEME="custom"
    print_message "$YELLOW" "Enter the path to your custom splash screen (video or image):"
    read -p "Path: " custom_path
    
    if [ -z "$custom_path" ]; then
        print_message "$RED" "No path provided. Using default theme instead."
        SPLASH_THEME="default"
        return
    fi
    
    if [ ! -f "$custom_path" ]; then
        print_message "$RED" "File not found: $custom_path"
        print_message "$YELLOW" "Do you want to try again? (y/n)"
        read -p "Choice: " retry
        if [[ $retry =~ ^[Yy]$ ]]; then
            set_custom_splash
        else
            SPLASH_THEME="default"
            print_message "$GREEN" "Using default theme instead."
        fi
        return
    fi
    
    # Check if the file is a video or image
    file_type=$(file -b --mime-type "$custom_path" | cut -d/ -f1)
    if [ "$file_type" != "video" ] && [ "$file_type" != "image" ]; then
        print_message "$RED" "Unsupported file type: $file_type"
        print_message "$YELLOW" "Do you want to try again? (y/n)"
        read -p "Choice: " retry
        if [[ $retry =~ ^[Yy]$ ]]; then
            set_custom_splash
        else
            SPLASH_THEME="default"
            print_message "$GREEN" "Using default theme instead."
        fi
        return
    fi
    
    CUSTOM_SPLASH_PATH="$custom_path"
    print_message "$GREEN" "Custom splash screen set to: $CUSTOM_SPLASH_PATH"
}

# Function to set splash screen duration
set_splash_duration() {
    clear
    print_message "$PURPLE" "=== Set Splash Screen Duration ==="
    print_message "$YELLOW" "Current duration: ${SPLASH_DURATION}s"
    print_message "$YELLOW" "Enter a new duration in seconds (1-30):"
    read -p "Duration: " duration
    
    # Validate input
    if ! [[ "$duration" =~ ^[0-9]+$ ]] || [ "$duration" -lt 1 ] || [ "$duration" -gt 30 ]; then
        print_message "$RED" "Invalid duration. Please enter a number between 1 and 30."
        sleep 1
        set_splash_duration
        return
    fi
    
    SPLASH_DURATION=$duration
    print_message "$GREEN" "Splash screen duration set to: ${SPLASH_DURATION}s"
    sleep 1
    show_main_menu
}

# Function to toggle audio
toggle_audio() {
    if [ "$SPLASH_AUDIO" = true ]; then
        SPLASH_AUDIO=false
        print_message "$GREEN" "Audio disabled"
    else
        SPLASH_AUDIO=true
        print_message "$GREEN" "Audio enabled"
    fi
    sleep 1
    show_main_menu
}

# Function to toggle fade effects
toggle_fade() {
    if [ "$SPLASH_FADE" = true ]; then
        SPLASH_FADE=false
        print_message "$GREEN" "Fade effects disabled"
    else
        SPLASH_FADE=true
        print_message "$GREEN" "Fade effects enabled"
    fi
    sleep 1
    show_main_menu
}

# Function to set fade duration
set_fade_duration() {
    clear
    print_message "$PURPLE" "=== Set Fade Duration ==="
    print_message "$YELLOW" "Current fade duration: ${SPLASH_FADE_DURATION}s"
    print_message "$YELLOW" "Enter a new fade duration in seconds (0.1-5):"
    read -p "Duration: " duration
    
    # Validate input
    if ! [[ "$duration" =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$duration < 0.1" | bc -l) )) || (( $(echo "$duration > 5" | bc -l) )); then
        print_message "$RED" "Invalid duration. Please enter a number between 0.1 and 5."
        sleep 1
        set_fade_duration
        return
    fi
    
    SPLASH_FADE_DURATION=$duration
    print_message "$GREEN" "Fade duration set to: ${SPLASH_FADE_DURATION}s"
    sleep 1
    show_main_menu
}

# Function to preview the current splash screen
preview_splash() {
    clear
    print_message "$PURPLE" "=== Preview Splash Screen ==="
    print_message "$YELLOW" "Previewing splash screen with current settings..."
    
    # Call the anime-splash.sh script with preview mode
    "$HOME/.config/hypr/scripts/anime-splash.sh" preview
    
    print_message "$GREEN" "Preview complete!"
    print_message "$YELLOW" "Press Enter to return to the main menu..."
    read
    show_main_menu
}

# Main function
main() {
    # Load configuration
    load_config
    
    # Show main menu
    show_main_menu
}

# Run the main function
main

# Exit with success
exit 0 