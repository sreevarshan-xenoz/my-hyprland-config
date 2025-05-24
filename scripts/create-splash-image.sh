#!/bin/bash

# create-splash-image.sh - Create a sample anime-themed splash image
# Part of the Hyprland Anime Ricing - Ultimate Edition
# https://github.com/sreevarshan-xenoz/my-hyprland-config

# Configuration
SPLASH_DIR="$HOME/.config/hypr/splash"
SPLASH_IMAGE="$SPLASH_DIR/splash.png"
THEME_DIR="$HOME/.config/hypr/themes"
THEME_NAME="default"

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

# Function to create a simple splash image
create_simple_splash() {
    local output_file=$1
    local text=$2
    local bg_color=$3
    local text_color=$4
    local font_size=$5
    
    print_message "$BLUE" "Creating simple splash image: $output_file"
    
    # Check if ImageMagick is installed
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
    
    # Create the splash image
    convert -size 1920x1080 xc:$bg_color \
        -fill $text_color -gravity center -pointsize $font_size \
        -annotate 0 "$text" \
        -gravity center -pointsize 36 \
        -annotate +0+100 "Anime Ricing - Ultimate Edition" \
        "$output_file"
    
    print_message "$GREEN" "Splash image created successfully!"
}

# Function to create a theme-specific splash image
create_theme_splash() {
    local theme=$1
    local output_dir="$THEME_DIR/$theme"
    local output_file="$output_dir/splash.png"
    
    # Create theme directory if it doesn't exist
    if [ ! -d "$output_dir" ]; then
        print_message "$BLUE" "Creating theme directory: $output_dir"
        mkdir -p "$output_dir"
    fi
    
    # Theme-specific colors and text
    case "$theme" in
        "demon-slayer")
            bg_color="#1a1a1a"
            text_color="#ff0000"
            text="Demon Slayer\nHyprland"
            ;;
        "attack-on-titan")
            bg_color="#2c3e50"
            text_color="#e74c3c"
            text="Attack on Titan\nHyprland"
            ;;
        "your-name")
            bg_color="#3498db"
            text_color="#f1c40f"
            text="Your Name\nHyprland"
            ;;
        "tokyo-ghoul")
            bg_color="#000000"
            text_color="#ffffff"
            text="Tokyo Ghoul\nHyprland"
            ;;
        "evangelion")
            bg_color="#8e44ad"
            text_color="#f39c12"
            text="Evangelion\nHyprland"
            ;;
        "one-piece")
            bg_color="#2980b9"
            text_color="#f1c40f"
            text="One Piece\nHyprland"
            ;;
        "naruto")
            bg_color="#f39c12"
            text_color="#2c3e50"
            text="Naruto\nHyprland"
            ;;
        "sailor-moon")
            bg_color="#9b59b6"
            text_color="#f1c40f"
            text="Sailor Moon\nHyprland"
            ;;
        "death-note")
            bg_color="#000000"
            text_color="#ffffff"
            text="Death Note\nHyprland"
            ;;
        "akira")
            bg_color="#c0392b"
            text_color="#f1c40f"
            text="Akira\nHyprland"
            ;;
        "princess-mononoke")
            bg_color="#27ae60"
            text_color="#f1c40f"
            text="Princess Mononoke\nHyprland"
            ;;
        "cowboy-bebop")
            bg_color="#2c3e50"
            text_color="#e74c3c"
            text="Cowboy Bebop\nHyprland"
            ;;
        *)
            bg_color="#1a1a1a"
            text_color="#ffffff"
            text="Hyprland\nAnime Ricing"
            ;;
    esac
    
    # Create the theme-specific splash image
    create_simple_splash "$output_file" "$text" "$bg_color" "$text_color" 72
    
    # Also create a copy in the main splash directory
    cp "$output_file" "$SPLASH_IMAGE"
    print_message "$GREEN" "Theme splash image copied to $SPLASH_IMAGE"
}

# Function to create splash images for all themes
create_all_theme_splashes() {
    # Create splash directory if it doesn't exist
    if [ ! -d "$SPLASH_DIR" ]; then
        print_message "$BLUE" "Creating splash directory: $SPLASH_DIR"
        mkdir -p "$SPLASH_DIR"
    fi
    
    # Create theme directory if it doesn't exist
    if [ ! -d "$THEME_DIR" ]; then
        print_message "$BLUE" "Creating themes directory: $THEME_DIR"
        mkdir -p "$THEME_DIR"
    fi
    
    # List of themes
    themes=(
        "demon-slayer"
        "attack-on-titan"
        "your-name"
        "tokyo-ghoul"
        "evangelion"
        "one-piece"
        "naruto"
        "sailor-moon"
        "death-note"
        "akira"
        "princess-mononoke"
        "cowboy-bebop"
        "default"
    )
    
    # Create splash images for each theme
    for theme in "${themes[@]}"; do
        print_message "$PURPLE" "Creating splash image for theme: $theme"
        create_theme_splash "$theme"
    done
    
    print_message "$GREEN" "All theme splash images created successfully!"
}

# Main function
main() {
    print_message "$PURPLE" "=== Hyprland Anime Ricing Splash Image Creator ==="
    
    # Check if a theme was specified
    if [ $# -gt 0 ]; then
        THEME_NAME="$1"
        print_message "$BLUE" "Creating splash image for theme: $THEME_NAME"
        create_theme_splash "$THEME_NAME"
    else
        print_message "$BLUE" "Creating splash images for all themes"
        create_all_theme_splashes
    fi
    
    print_message "$GREEN" "Splash image creation complete!"
}

# Run the main function
main "$@"

# Exit with success
exit 0 