#!/bin/bash

# Hyprland Anime Ricing Installation Script
# ----------------------------------------
# This script installs and configures the Hyprland anime ricing setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print a header
print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  Hyprland Anime Ricing Installation  ${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo ""
}

# Print a section header
print_section() {
    echo -e "${CYAN}==>${NC} ${YELLOW}$1${NC}"
}

# Print a success message
print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

# Print an error message
print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Print an info message
print_info() {
    echo -e "${BLUE}==>${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a package is installed
package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Install a package if it's not already installed
install_package() {
    if ! package_installed "$1"; then
        print_info "Installing $1..."
        sudo pacman -S --noconfirm "$1"
        if [ $? -eq 0 ]; then
            print_success "Installed $1"
        else
            print_error "Failed to install $1"
            exit 1
        fi
    else
        print_info "$1 is already installed"
    fi
}

# Install packages from AUR
install_aur_package() {
    if ! package_installed "$1"; then
        print_info "Installing $1 from AUR..."
        yay -S --noconfirm "$1"
        if [ $? -eq 0 ]; then
            print_success "Installed $1 from AUR"
        else
            print_error "Failed to install $1 from AUR"
            exit 1
        fi
    else
        print_info "$1 is already installed"
    fi
}

# Create a directory if it doesn't exist
create_directory() {
    if [ ! -d "$1" ]; then
        print_info "Creating directory $1..."
        mkdir -p "$1"
        print_success "Created directory $1"
    else
        print_info "Directory $1 already exists"
    fi
}

# Copy a file
copy_file() {
    print_info "Copying $1 to $2..."
    cp "$1" "$2"
    if [ $? -eq 0 ]; then
        print_success "Copied $1 to $2"
    else
        print_error "Failed to copy $1 to $2"
        exit 1
    fi
}

# Make a file executable
make_executable() {
    print_info "Making $1 executable..."
    chmod +x "$1"
    if [ $? -eq 0 ]; then
        print_success "Made $1 executable"
    else
        print_error "Failed to make $1 executable"
        exit 1
    fi
}

# Install Iris AI dependencies
install_iris_dependencies() {
    print_section "Installing Iris AI dependencies"
    
    # Install Python packages
    install_package "python"
    install_package "python-pip"
    install_package "jq"
    
    # Install Python dependencies
    pip3 install --user transformers torch accelerate sentencepiece protobuf psutil
    
    print_success "Installed Iris AI dependencies"
}

# Copy Iris AI files
copy_iris_files() {
    print_section "Copying Iris AI files"
    
    # Create Iris configuration directory
    create_directory "$HOME/.config/iris"
    
    # Copy Iris scripts
    copy_file "scripts/iris-ai.sh" "$HOME/.config/hypr/scripts/"
    copy_file "scripts/iris_os_control.py" "$HOME/.config/hypr/scripts/"
    
    # Make Iris scripts executable
    make_executable "$HOME/.config/hypr/scripts/iris-ai.sh"
    
    print_success "Copied Iris AI files"
}

# Main installation function
main() {
    print_header
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
        exit 1
    fi
    
    # Check if running on Arch Linux
    if ! command_exists pacman; then
        print_error "This script is designed for Arch Linux"
        exit 1
    fi
    
    # Check if yay is installed
    if ! command_exists yay; then
        print_info "Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd - > /dev/null
        print_success "Installed yay"
    fi
    
    # Install required packages
    print_section "Installing required packages"
    
    # Core packages
    install_package "hyprland"
    install_package "waybar"
    install_package "wofi"
    install_package "dunst"
    install_package "swww"
    install_package "pywal"
    install_package "grim"
    install_package "slurp"
    install_package "wl-clipboard"
    install_package "pavucontrol"
    install_package "brightnessctl"
    install_package "playerctl"
    install_package "jq"
    install_package "curl"
    install_package "noto-fonts-cjk"
    install_package "ttf-jetbrains-mono-nerd"
    install_package "papirus-icon-theme"
    install_package "bibata-cursor-theme"
    
    # AUR packages
    install_aur_package "eww-wayland"
    install_aur_package "mpvpaper"
    install_aur_package "uwufetch"
    
    # Create configuration directories
    print_section "Creating configuration directories"
    
    create_directory "$HOME/.config/hypr"
    create_directory "$HOME/.config/waybar"
    create_directory "$HOME/.config/wofi"
    create_directory "$HOME/.config/dunst"
    create_directory "$HOME/.config/eww"
    create_directory "$HOME/.config/hypr/wallpapers"
    create_directory "$HOME/.config/hypr/sounds"
    create_directory "$HOME/.config/hypr/icons"
    create_directory "$HOME/.config/hypr/scripts"
    
    # Copy configuration files
    print_section "Copying configuration files"
    
    copy_file "config/hypr/hyprland.conf" "$HOME/.config/hypr/"
    copy_file "config/hypr/colors.conf" "$HOME/.config/hypr/"
    copy_file "config/waybar/config" "$HOME/.config/waybar/"
    copy_file "config/waybar/style.css" "$HOME/.config/waybar/"
    copy_file "config/wofi/power-menu.css" "$HOME/.config/wofi/"
    
    # Copy scripts
    print_section "Copying scripts"
    
    copy_file "scripts/wallpaper-switcher.sh" "$HOME/.config/hypr/scripts/"
    copy_file "scripts/power-menu.sh" "$HOME/.config/hypr/scripts/"
    copy_file "scripts/weather.sh" "$HOME/.config/hypr/scripts/"
    copy_file "scripts/clock.sh" "$HOME/.config/hypr/scripts/"
    copy_file "scripts/game-mode.sh" "$HOME/.config/hypr/scripts/"
    
    # Make scripts executable
    print_section "Making scripts executable"
    
    make_executable "$HOME/.config/hypr/scripts/wallpaper-switcher.sh"
    make_executable "$HOME/.config/hypr/scripts/power-menu.sh"
    make_executable "$HOME/.config/hypr/scripts/weather.sh"
    make_executable "$HOME/.config/hypr/scripts/clock.sh"
    make_executable "$HOME/.config/hypr/scripts/game-mode.sh"
    
    # Download sample wallpapers
    print_section "Downloading sample wallpapers"
    
    print_info "Downloading sample anime wallpapers..."
    mkdir -p /tmp/anime-wallpapers
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-1.jpg" -o "$HOME/.config/hypr/wallpapers/default.jpg"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-2.jpg" -o "$HOME/.config/hypr/wallpapers/anime-2.jpg"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-3.jpg" -o "$HOME/.config/hypr/wallpapers/anime-3.jpg"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-4.jpg" -o "$HOME/.config/hypr/wallpapers/anime-4.jpg"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-5.jpg" -o "$HOME/.config/hypr/wallpapers/anime-5.jpg"
    print_success "Downloaded sample anime wallpapers"
    
    # Download sample sounds
    print_section "Downloading sample sounds"
    
    print_info "Downloading sample anime sounds..."
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/startup.wav" -o "$HOME/.config/hypr/sounds/startup.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/shutdown.wav" -o "$HOME/.config/hypr/sounds/shutdown.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/reboot.wav" -o "$HOME/.config/hypr/sounds/reboot.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/logout.wav" -o "$HOME/.config/hypr/sounds/logout.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/lock.wav" -o "$HOME/.config/hypr/sounds/lock.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/suspend.wav" -o "$HOME/.config/hypr/sounds/suspend.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/hibernate.wav" -o "$HOME/.config/hypr/sounds/hibernate.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/game-mode-on.wav" -o "$HOME/.config/hypr/sounds/game-mode-on.wav"
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/game-mode-off.wav" -o "$HOME/.config/hypr/sounds/game-mode-off.wav"
    print_success "Downloaded sample anime sounds"
    
    # Download sample icons
    print_section "Downloading sample icons"
    
    print_info "Downloading sample anime icons..."
    curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/icons/game-mode.png" -o "$HOME/.config/hypr/icons/game-mode.png"
    print_success "Downloaded sample anime icons"
    
    # Install Iris AI
    print_section "Installing Iris AI Assistant"
    install_iris_dependencies
    copy_iris_files
    
    # Final message
    print_section "Installation complete"
    print_success "Hyprland anime ricing setup is now installed!"
    print_info "You can start Hyprland by logging out and selecting Hyprland from your display manager"
    print_info "Or by running 'Hyprland' from your terminal"
    print_info "Enjoy your anime-themed desktop!"
    echo -e "${YELLOW}To set up Iris AI Assistant, run:${NC}"
    echo -e "${GREEN}~/.config/hypr/scripts/iris-ai.sh setup${NC}"
    echo -e "${YELLOW}To start Iris AI Assistant, run:${NC}"
    echo -e "${GREEN}~/.config/hypr/scripts/iris-ai.sh start${NC}"
}

# Run the main function
main 