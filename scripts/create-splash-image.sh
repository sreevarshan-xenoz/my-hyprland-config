#!/bin/bash

# create-splash-image.sh - Script to create splash screen images and videos for Hyprland Anime Ricing
# This script generates splash screen images and videos for different themes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directories
SPLASH_DIR="$HOME/.config/hypr/splash"
IMAGES_DIR="$SPLASH_DIR/images"
VIDEOS_DIR="$SPLASH_DIR/videos"
SOUNDS_DIR="$SPLASH_DIR/sounds"
TEMP_DIR="$SPLASH_DIR/temp"

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

# Function to create directories
create_directories() {
    print_message "$BLUE" "Creating splash screen directories..."
    
    # Create splash directory
    mkdir -p "$SPLASH_DIR"
    
    # Create images directory
    mkdir -p "$IMAGES_DIR"
    
    # Create videos directory
    mkdir -p "$VIDEOS_DIR"
    
    # Create sounds directory
    mkdir -p "$SOUNDS_DIR"
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    print_message "$GREEN" "Directories created!"
}

# Function to check dependencies
check_dependencies() {
    print_message "$BLUE" "Checking dependencies..."
    
    # Check for required commands
    local missing_deps=()
    
    if ! command_exists "convert"; then
        missing_deps+=("imagemagick")
    fi
    
    if ! command_exists "ffmpeg"; then
        missing_deps+=("ffmpeg")
    fi
    
    if ! command_exists "bc"; then
        missing_deps+=("bc")
    fi
    
    # If any dependencies are missing, print a message
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_message "$RED" "The following dependencies are missing:"
        for dep in "${missing_deps[@]}"; do
            print_message "$RED" "  - $dep"
        done
        
        print_message "$YELLOW" "Please install the missing dependencies and try again."
        print_message "$YELLOW" "For Arch Linux: sudo pacman -S ${missing_deps[*]}"
        print_message "$YELLOW" "For Debian/Ubuntu: sudo apt install ${missing_deps[*]}"
        
        exit 1
    fi
    
    print_message "$GREEN" "All dependencies are installed!"
}

# Function to create default splash image
create_default_splash_image() {
    print_message "$BLUE" "Creating default splash image..."
    
    # Create a 1920x1080 image with a gradient background
    convert -size 1920x1080 gradient:purple-blue "$TEMP_DIR/background.png"
    
    # Add text to the image
    convert "$TEMP_DIR/background.png" \
        -font "JetBrains-Mono-Nerd-Font" \
        -pointsize 72 \
        -fill white \
        -gravity center \
        -annotate +0-100 "Welcome to" \
        -pointsize 120 \
        -fill white \
        -gravity center \
        -annotate +0+50 "Hyprland Anime Ricing" \
        -pointsize 36 \
        -fill white \
        -gravity center \
        -annotate +0+200 "Ultimate Edition" \
        "$IMAGES_DIR/default.png"
    
    print_message "$GREEN" "Default splash image created!"
}

# Function to create cyberpunk splash image
create_cyberpunk_splash_image() {
    print_message "$BLUE" "Creating cyberpunk splash image..."
    
    # Create a 1920x1080 image with a cyberpunk gradient background
    convert -size 1920x1080 gradient:magenta-cyan "$TEMP_DIR/background.png"
    
    # Add a grid pattern
    convert "$TEMP_DIR/background.png" \
        -fill "rgba(0,255,255,0.2)" \
        -draw "line 0,0 1920,1080" \
        -draw "line 1920,0 0,1080" \
        -draw "line 0,540 1920,540" \
        -draw "line 960,0 960,1080" \
        "$TEMP_DIR/grid.png"
    
    # Add text to the image
    convert "$TEMP_DIR/grid.png" \
        -font "JetBrains-Mono-Nerd-Font" \
        -pointsize 72 \
        -fill "rgba(255,0,255,0.8)" \
        -gravity center \
        -annotate +0-100 "WELCOME TO" \
        -pointsize 120 \
        -fill "rgba(0,255,255,0.8)" \
        -gravity center \
        -annotate +0+50 "CYBERPUNK HYPRLAND" \
        -pointsize 36 \
        -fill "rgba(255,255,255,0.8)" \
        -gravity center \
        -annotate +0+200 "NEON EDITION" \
        "$IMAGES_DIR/cyberpunk.png"
    
    print_message "$GREEN" "Cyberpunk splash image created!"
}

# Function to create kawaii splash image
create_kawaii_splash_image() {
    print_message "$BLUE" "Creating kawaii splash image..."
    
    # Create a 1920x1080 image with a kawaii gradient background
    convert -size 1920x1080 gradient:pink-lavender "$TEMP_DIR/background.png"
    
    # Add some cute patterns
    convert "$TEMP_DIR/background.png" \
        -fill "rgba(255,192,203,0.3)" \
        -draw "circle 200,200 300,200" \
        -draw "circle 1720,200 1620,200" \
        -draw "circle 200,880 300,880" \
        -draw "circle 1720,880 1620,880" \
        "$TEMP_DIR/patterns.png"
    
    # Add text to the image
    convert "$TEMP_DIR/patterns.png" \
        -font "JetBrains-Mono-Nerd-Font" \
        -pointsize 72 \
        -fill "rgba(255,105,180,0.8)" \
        -gravity center \
        -annotate +0-100 "Welcome to" \
        -pointsize 120 \
        -fill "rgba(255,105,180,0.8)" \
        -gravity center \
        -annotate +0+50 "Kawaii Hyprland" \
        -pointsize 36 \
        -fill "rgba(255,105,180,0.8)" \
        -gravity center \
        -annotate +0+200 "Cute Edition" \
        "$IMAGES_DIR/kawaii.png"
    
    print_message "$GREEN" "Kawaii splash image created!"
}

# Function to create minimal splash image
create_minimal_splash_image() {
    print_message "$BLUE" "Creating minimal splash image..."
    
    # Create a 1920x1080 image with a minimal gradient background
    convert -size 1920x1080 gradient:black-gray "$TEMP_DIR/background.png"
    
    # Add text to the image
    convert "$TEMP_DIR/background.png" \
        -font "JetBrains-Mono-Nerd-Font" \
        -pointsize 72 \
        -fill white \
        -gravity center \
        -annotate +0+0 "HYPRLAND" \
        "$IMAGES_DIR/minimal.png"
    
    print_message "$GREEN" "Minimal splash image created!"
}

# Function to create default splash video
create_default_splash_video() {
    print_message "$BLUE" "Creating default splash video..."
    
    # Check if we have a default image
    if [ ! -f "$IMAGES_DIR/default.png" ]; then
        create_default_splash_image
    fi
    
    # Create a video from the image with a fade effect
    ffmpeg -y -loop 1 -i "$IMAGES_DIR/default.png" \
        -c:v libx264 -t 5 -pix_fmt yuv420p \
        -vf "fade=t=in:st=0:d=1,fade=t=out:st=4:d=1" \
        "$VIDEOS_DIR/default.mp4"
    
    print_message "$GREEN" "Default splash video created!"
}

# Function to create cyberpunk splash video
create_cyberpunk_splash_video() {
    print_message "$BLUE" "Creating cyberpunk splash video..."
    
    # Check if we have a cyberpunk image
    if [ ! -f "$IMAGES_DIR/cyberpunk.png" ]; then
        create_cyberpunk_splash_image
    fi
    
    # Create a video from the image with a fade effect and a glitch effect
    ffmpeg -y -loop 1 -i "$IMAGES_DIR/cyberpunk.png" \
        -c:v libx264 -t 5 -pix_fmt yuv420p \
        -vf "fade=t=in:st=0:d=1,fade=t=out:st=4:d=1,glitch=amount=0.1:seed=1" \
        "$VIDEOS_DIR/cyberpunk.mp4"
    
    print_message "$GREEN" "Cyberpunk splash video created!"
}

# Function to create kawaii splash video
create_kawaii_splash_video() {
    print_message "$BLUE" "Creating kawaii splash video..."
    
    # Check if we have a kawaii image
    if [ ! -f "$IMAGES_DIR/kawaii.png" ]; then
        create_kawaii_splash_image
    fi
    
    # Create a video from the image with a fade effect and a zoom effect
    ffmpeg -y -loop 1 -i "$IMAGES_DIR/kawaii.png" \
        -c:v libx264 -t 5 -pix_fmt yuv420p \
        -vf "fade=t=in:st=0:d=1,fade=t=out:st=4:d=1,zoompan=z='min(zoom+0.0015,1.5)':d=125" \
        "$VIDEOS_DIR/kawaii.mp4"
    
    print_message "$GREEN" "Kawaii splash video created!"
}

# Function to create minimal splash video
create_minimal_splash_video() {
    print_message "$BLUE" "Creating minimal splash video..."
    
    # Check if we have a minimal image
    if [ ! -f "$IMAGES_DIR/minimal.png" ]; then
        create_minimal_splash_image
    fi
    
    # Create a video from the image with a fade effect
    ffmpeg -y -loop 1 -i "$IMAGES_DIR/minimal.png" \
        -c:v libx264 -t 5 -pix_fmt yuv420p \
        -vf "fade=t=in:st=0:d=1,fade=t=out:st=4:d=1" \
        "$VIDEOS_DIR/minimal.mp4"
    
    print_message "$GREEN" "Minimal splash video created!"
}

# Function to create default splash sound
create_default_splash_sound() {
    print_message "$BLUE" "Creating default splash sound..."
    
    # Check if we have a default sound
    if [ ! -f "$SOUNDS_DIR/default.mp3" ]; then
        print_message "$YELLOW" "No default sound found. Skipping sound creation."
        print_message "$YELLOW" "You can add your own sound file at $SOUNDS_DIR/default.mp3"
    fi
    
    print_message "$GREEN" "Default splash sound checked!"
}

# Function to create cyberpunk splash sound
create_cyberpunk_splash_sound() {
    print_message "$BLUE" "Creating cyberpunk splash sound..."
    
    # Check if we have a cyberpunk sound
    if [ ! -f "$SOUNDS_DIR/cyberpunk.mp3" ]; then
        print_message "$YELLOW" "No cyberpunk sound found. Skipping sound creation."
        print_message "$YELLOW" "You can add your own sound file at $SOUNDS_DIR/cyberpunk.mp3"
    fi
    
    print_message "$GREEN" "Cyberpunk splash sound checked!"
}

# Function to create kawaii splash sound
create_kawaii_splash_sound() {
    print_message "$BLUE" "Creating kawaii splash sound..."
    
    # Check if we have a kawaii sound
    if [ ! -f "$SOUNDS_DIR/kawaii.mp3" ]; then
        print_message "$YELLOW" "No kawaii sound found. Skipping sound creation."
        print_message "$YELLOW" "You can add your own sound file at $SOUNDS_DIR/kawaii.mp3"
    fi
    
    print_message "$GREEN" "Kawaii splash sound checked!"
}

# Function to create minimal splash sound
create_minimal_splash_sound() {
    print_message "$BLUE" "Creating minimal splash sound..."
    
    # Check if we have a minimal sound
    if [ ! -f "$SOUNDS_DIR/minimal.mp3" ]; then
        print_message "$YELLOW" "No minimal sound found. Skipping sound creation."
        print_message "$YELLOW" "You can add your own sound file at $SOUNDS_DIR/minimal.mp3"
    fi
    
    print_message "$GREEN" "Minimal splash sound checked!"
}

# Function to create all splash screen assets
create_all_splash_assets() {
    print_message "$PURPLE" "=== Creating Splash Screen Assets ==="
    
    # Create directories
    create_directories
    
    # Check dependencies
    check_dependencies
    
    # Create splash images
    create_default_splash_image
    create_cyberpunk_splash_image
    create_kawaii_splash_image
    create_minimal_splash_image
    
    # Create splash videos
    create_default_splash_video
    create_cyberpunk_splash_video
    create_kawaii_splash_video
    create_minimal_splash_video
    
    # Create splash sounds
    create_default_splash_sound
    create_cyberpunk_splash_sound
    create_kawaii_splash_sound
    create_minimal_splash_sound
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    
    print_message "$GREEN" "=== All Splash Screen Assets Created! ==="
    print_message "$YELLOW" "You can customize the splash screen by editing the files in:"
    print_message "$YELLOW" "  - $IMAGES_DIR (for images)"
    print_message "$YELLOW" "  - $VIDEOS_DIR (for videos)"
    print_message "$YELLOW" "  - $SOUNDS_DIR (for sounds)"
    print_message "$YELLOW" "Or use the splash screen selector:"
    print_message "$YELLOW" "  - Run 'hypr-splash-select' to configure your splash screen"
}

# Main function
main() {
    # Check if the script is called with the "all" argument
    if [ "$1" = "all" ]; then
        create_all_splash_assets
        exit 0
    fi
    
    # Check if the script is called with the "images" argument
    if [ "$1" = "images" ]; then
        create_directories
        check_dependencies
        create_default_splash_image
        create_cyberpunk_splash_image
        create_kawaii_splash_image
        create_minimal_splash_image
        rm -rf "$TEMP_DIR"
        exit 0
    fi
    
    # Check if the script is called with the "videos" argument
    if [ "$1" = "videos" ]; then
        create_directories
        check_dependencies
        create_default_splash_video
        create_cyberpunk_splash_video
        create_kawaii_splash_video
        create_minimal_splash_video
        rm -rf "$TEMP_DIR"
        exit 0
    fi
    
    # Check if the script is called with the "sounds" argument
    if [ "$1" = "sounds" ]; then
        create_directories
        create_default_splash_sound
        create_cyberpunk_splash_sound
        create_kawaii_splash_sound
        create_minimal_splash_sound
        exit 0
    fi
    
    # If no argument is provided, create all assets
    create_all_splash_assets
}

# Run the main function
main "$@"

# Exit with success
exit 0 