#!/bin/bash

# install.sh - Installation script for Hyprland Anime Ricing - Ultimate Edition
# https://github.com/sreevarshan-xenoz/my-hyprland-config

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

# Function to install required packages
install_packages() {
    print_message "$BLUE" "Installing required packages..."
    
    # Check if pacman is available (Arch Linux)
    if command_exists "pacman"; then
        # Core packages
        sudo pacman -S --noconfirm hyprland hyprpaper hyprlock hypridle hyprpicker
        sudo pacman -S --noconfirm waybar eww-wayland wofi rofi-wayland
        sudo pacman -S --noconfirm dunst mako pipewire pipewire-pulse pavucontrol
        sudo pacman -S --noconfirm foot kitty alacritty wezterm
        sudo pacman -S --noconfirm thunar nemo dolphin ranger lf
        sudo pacman -S --noconfirm grim slurp wl-clipboard swappy
        sudo pacman -S --noconfirm brightnessctl playerctl bluetuith
        
        # Theming packages
        sudo pacman -S --noconfirm papirus-icon-theme candy-icons
        sudo pacman -S --noconfirm bibata-cursor-theme catppuccin-cursors
        sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd ttf-fira-code-nerd
        sudo pacman -S --noconfirm noto-fonts-cjk noto-fonts-emoji
        sudo pacman -S --noconfirm ttf-ms-fonts adobe-source-han-sans-jp-fonts
        sudo pacman -S --noconfirm pywal-git colorz python-colorthief
        sudo pacman -S --noconfirm lxappearance qt5ct kvantum
        sudo pacman -S --noconfirm catppuccin-gtk-theme-mocha
        
        # Animation and effects
        sudo pacman -S --noconfirm glfw-wayland cairo pango
        sudo pacman -S --noconfirm librsvg gdk-pixbuf2 webp-pixbuf-loader
        sudo pacman -S --noconfirm cava cli-visualizer glava
        sudo pacman -S --noconfirm mpvpaper swww hyprpaper
        sudo pacman -S --noconfirm ffmpeg imagemagick gifski
        
        # Optional enhancement packages
        sudo pacman -S --noconfirm git nodejs npm python python-pip
        
        # Splash screen dependencies
        sudo pacman -S --noconfirm mpv swww feh imagemagick ffmpeg bc
        
        # Iris AI dependencies
        sudo pacman -S --noconfirm python-pip jq
        
        # Check if yay is available for AUR packages
        if command_exists "yay"; then
            print_message "$BLUE" "Installing AUR packages with yay..."
            yay -S --noconfirm swww-git hyprpicker-git eww-wayland
            yay -S --noconfirm cava-git cli-visualizer-git
            yay -S --noconfirm anime-wallpaper-cli waifu2x-ncnn-vulkan
            yay -S --noconfirm plymouth-theme-anime spicetify-cli
            yay -S --noconfirm zscroll-git picom-animations-git
        # Check if paru is available for AUR packages
        elif command_exists "paru"; then
            print_message "$BLUE" "Installing AUR packages with paru..."
            paru -S --noconfirm swww-git hyprpicker-git eww-wayland
            paru -S --noconfirm cava-git cli-visualizer-git
            paru -S --noconfirm anime-wallpaper-cli waifu2x-ncnn-vulkan
            paru -S --noconfirm plymouth-theme-anime spicetify-cli
            paru -S --noconfirm zscroll-git picom-animations-git
        else
            print_message "$YELLOW" "Neither yay nor paru found. Skipping AUR packages."
            print_message "$YELLOW" "You may want to install yay or paru to get AUR packages."
        fi
    # For Arch Linux, we already handled the package installation with pacman/yay/paru above
    # This section is removed as Arch Linux doesn't use apt
    # If you're using a different distribution that's not Arch-based, please modify this script
    # to use your distribution's package manager (e.g., dnf for Fedora, zypper for openSUSE, etc.)
    else
        print_message "$RED" "This script is configured for Arch Linux and requires pacman."
        print_message "$YELLOW" "Please install the required packages manually using your distribution's package manager."
        return 1
    fi
    
    print_message "$GREEN" "Package installation complete!"
}

# Function to install Iris AI dependencies
install_iris_dependencies() {
    print_message "$BLUE" "Installing Iris AI dependencies..."
    
    # Install Python packages
    pip3 install --user transformers torch accelerate sentencepiece protobuf
    pip3 install --user SpeechRecognition gTTS pygame numpy sounddevice
    
    print_message "$GREEN" "Iris AI dependencies installed!"
}

# Function to copy configuration files
copy_config_files() {
    print_message "$BLUE" "Copying configuration files..."
    
    # Create config directories
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/eww"
    mkdir -p "$HOME/.config/wofi"
    mkdir -p "$HOME/.config/dunst"
    mkdir -p "$HOME/.config/kitty"
    mkdir -p "$HOME/.config/foot"
    mkdir -p "$HOME/.config/alacritty"
    mkdir -p "$HOME/.config/wezterm"
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/qt5ct"
    mkdir -p "$HOME/.config/kvantum"
    mkdir -p "$HOME/.config/iris"
    mkdir -p "$HOME/.config/hypr/splash"
    mkdir -p "$HOME/.config/hypr/themes"
    
    # Copy Hyprland config
    cp -r config/hypr/* "$HOME/.config/hypr/"
    
    # Copy Waybar config
    cp -r config/waybar/* "$HOME/.config/waybar/"
    
    # Copy EWW config
    cp -r config/eww/* "$HOME/.config/eww/"
    
    # Copy Wofi config
    cp -r config/wofi/* "$HOME/.config/wofi/"
    
    # Copy Dunst config
    cp -r config/dunst/* "$HOME/.config/dunst/"
    
    # Copy terminal configs
    cp -r config/kitty/* "$HOME/.config/kitty/"
    cp -r config/foot/* "$HOME/.config/foot/"
    cp -r config/alacritty/* "$HOME/.config/alacritty/"
    cp -r config/wezterm/* "$HOME/.config/wezterm/"
    
    # Copy GTK/Qt configs
    cp -r config/gtk-3.0/* "$HOME/.config/gtk-3.0/"
    cp -r config/qt5ct/* "$HOME/.config/qt5ct/"
    cp -r config/kvantum/* "$HOME/.config/kvantum/"
    
    # Copy themes
    cp -r themes/* "$HOME/.config/hypr/themes/"
    
    # Copy wallpapers
    mkdir -p "$HOME/.config/hypr/wallpapers"
    cp -r wallpapers/* "$HOME/.config/hypr/wallpapers/"
    
    # Copy sounds
    mkdir -p "$HOME/.config/hypr/sounds"
    cp -r sounds/* "$HOME/.config/hypr/sounds/"
    
    # Copy icons
    mkdir -p "$HOME/.config/hypr/icons"
    cp -r icons/* "$HOME/.config/hypr/icons/"
    
    # Copy fonts
    mkdir -p "$HOME/.local/share/fonts"
    cp -r fonts/* "$HOME/.local/share/fonts/"
    fc-cache -f -v
    
    print_message "$GREEN" "Configuration files copied!"
}

# Function to copy scripts
copy_scripts() {
    print_message "$BLUE" "Copying scripts..."
    
    # Create scripts directory
    mkdir -p "$HOME/.config/hypr/scripts"
    
    # Copy scripts
    cp -r scripts/* "$HOME/.config/hypr/scripts/"
    
    # Make scripts executable
    chmod +x "$HOME/.config/hypr/scripts/"*.sh
    chmod +x "$HOME/.config/hypr/scripts/"*.py
    
    # Create symlinks for new scripts
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.config/hypr/scripts/performance-optimizer.sh" "$HOME/.local/bin/hypr-performance"
    ln -sf "$HOME/.config/hypr/scripts/iris-ai-upgrade.sh" "$HOME/.local/bin/iris-upgrade"
    ln -sf "$HOME/.config/hypr/scripts/workspace-manager.sh" "$HOME/.local/bin/hypr-workspace"
    
    print_message "$GREEN" "Scripts copied and made executable!"
}

# Function to copy Iris AI files
copy_iris_files() {
    print_message "$BLUE" "Copying Iris AI files..."
    
    # Create Iris config directory
    mkdir -p "$HOME/.config/iris"
    
    # Copy Iris AI scripts
    cp scripts/iris-ai.sh "$HOME/.config/hypr/scripts/"
    cp scripts/iris_os_control.py "$HOME/.config/hypr/scripts/"
    cp scripts/iris_voice.py "$HOME/.config/hypr/scripts/"
    
    # Make Iris AI script executable
    chmod +x "$HOME/.config/hypr/scripts/iris-ai.sh"
    
    print_message "$GREEN" "Iris AI files copied!"
}

# Function to setup splash screen
setup_splash_screen() {
    print_message "$BLUE" "Setting up splash screen..."
    
    # Create splash directory
    mkdir -p "$HOME/.config/hypr/splash"
    
    # Copy splash scripts
    cp scripts/anime-splash.sh "$HOME/.config/hypr/scripts/"
    cp scripts/splash-selector.sh "$HOME/.config/hypr/scripts/"
    cp scripts/create-splash-image.sh "$HOME/.config/hypr/scripts/"
    
    # Make splash scripts executable
    chmod +x "$HOME/.config/hypr/scripts/anime-splash.sh"
    chmod +x "$HOME/.config/hypr/scripts/splash-selector.sh"
    chmod +x "$HOME/.config/hypr/scripts/create-splash-image.sh"
    
    # Create splash images
    "$HOME/.config/hypr/scripts/create-splash-image.sh"
    
    # Create a symlink to the splash script in the user's bin directory
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.config/hypr/scripts/anime-splash.sh" "$HOME/.local/bin/hypr-splash"
    
    # Create a symlink for the splash selection script
    ln -sf "$HOME/.config/hypr/scripts/splash-selector.sh" "$HOME/.local/bin/hypr-splash-select"
    
    print_message "$GREEN" "Splash screen setup complete!"
}

# Function to create a desktop entry for the splash screen
create_splash_desktop_entry() {
    print_message "$BLUE" "Creating desktop entry for splash screen..."
    
    # Create desktop entry directory
    mkdir -p "$HOME/.local/share/applications"
    
    # Create desktop entry for splash screen
    cat > "$HOME/.local/share/applications/hypr-splash.desktop" << EOF
[Desktop Entry]
Name=Hyprland Anime Splash
Comment=Anime-themed splash screen for Hyprland
Exec=$HOME/.local/bin/hypr-splash
Terminal=false
Type=Application
Categories=Utility;
Icon=hyprland
EOF
    
    # Create desktop entry for splash screen selection
    cat > "$HOME/.local/share/applications/hypr-splash-select.desktop" << EOF
[Desktop Entry]
Name=Hyprland Splash Screen Selector
Comment=Configure your Hyprland splash screen
Exec=$HOME/.local/bin/hypr-splash-select
Terminal=false
Type=Application
Categories=Settings;Utility;
Icon=hyprland
EOF
    
    print_message "$GREEN" "Desktop entries created!"
}

# Function to create a desktop entry for Hyprland with splash screen
create_hyprland_desktop_entry() {
    print_message "$BLUE" "Creating desktop entry for Hyprland with splash screen..."
    
    # Create desktop entry directory
    mkdir -p "$HOME/.local/share/applications"
    
    # Create desktop entry
    cat > "$HOME/.local/share/applications/hyprland-anime.desktop" << EOF
[Desktop Entry]
Name=Hyprland Anime
Comment=Hyprland Anime Ricing - Ultimate Edition
Exec=$HOME/.local/bin/hypr-splash && Hyprland
Terminal=false
Type=Application
Categories=System;
Icon=hyprland
EOF
    
    print_message "$GREEN" "Hyprland desktop entry created!"
}

# Function to create a .xinitrc file
create_xinitrc() {
    print_message "$BLUE" "Creating .xinitrc file..."
    
    # Create .xinitrc file
    cat > "$HOME/.xinitrc" << EOF
#!/bin/bash

# Start Hyprland with splash screen
$HOME/.local/bin/hypr-splash && exec Hyprland
EOF
    
    # Make .xinitrc executable
    chmod +x "$HOME/.xinitrc"
    
    print_message "$GREEN" ".xinitrc file created!"
}

# Function to create a .xsession file
create_xsession() {
    print_message "$BLUE" "Creating .xsession file..."
    
    # Create .xsession file
    cat > "$HOME/.xsession" << EOF
#!/bin/bash

# Start Hyprland with splash screen
$HOME/.local/bin/hypr-splash && exec Hyprland
EOF
    
    # Make .xsession executable
    chmod +x "$HOME/.xsession"
    
    print_message "$GREEN" ".xsession file created!"
}

# Function to create a display manager configuration
create_display_manager_config() {
    print_message "$BLUE" "Creating display manager configuration..."
    
    # Check if SDDM is installed
    if command_exists "sddm"; then
        print_message "$BLUE" "SDDM detected. Creating SDDM configuration..."
        
        # Create SDDM config directory
        sudo mkdir -p /etc/sddm.conf.d/
        
        # Create SDDM config
        sudo cat > /etc/sddm.conf.d/hyprland.conf << EOF
[Autologin]
User=$USER
Session=hyprland-anime.desktop

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Theme]
Current=anime
EOF
        
        print_message "$GREEN" "SDDM configuration created!"
    # Check if LightDM is installed
    elif command_exists "lightdm"; then
        print_message "$BLUE" "LightDM detected. Creating LightDM configuration..."
        
        # Create LightDM config
        sudo cat > /etc/lightdm/lightdm.conf.d/hyprland.conf << EOF
[Seat:*]
autologin-user=$USER
autologin-user-timeout=0
session-wrapper=/etc/lightdm/Xsession
EOF
        
        print_message "$GREEN" "LightDM configuration created!"
    # Check if GDM is installed
    elif command_exists "gdm"; then
        print_message "$BLUE" "GDM detected. Creating GDM configuration..."
        
        # Create GDM config
        sudo cat > /etc/gdm/custom.conf << EOF
[daemon]
AutomaticLogin=$USER
AutomaticLoginEnable=true
DefaultSession=hyprland-anime.desktop
EOF
        
        print_message "$GREEN" "GDM configuration created!"
    else
        print_message "$YELLOW" "No supported display manager detected. Skipping display manager configuration."
    fi
}

# Function to create a systemd service for the splash screen
create_splash_service() {
    print_message "$BLUE" "Creating systemd service for splash screen..."
    
    # Create systemd user directory
    mkdir -p "$HOME/.config/systemd/user/"
    
    # Create service file
    cat > "$HOME/.config/systemd/user/hypr-splash.service" << EOF
[Unit]
Description=Hyprland Anime Splash Screen
Before=hyprland.service
After=graphical.target

[Service]
Type=oneshot
ExecStart=$HOME/.local/bin/hypr-splash
RemainAfterExit=yes

[Install]
WantedBy=hyprland.service
EOF
    
    # Enable the service
    systemctl --user enable hypr-splash.service
    
    print_message "$GREEN" "Splash screen service created and enabled!"
}

# Function to create a systemd service for Hyprland
create_hyprland_service() {
    print_message "$BLUE" "Creating systemd service for Hyprland..."
    
    # Create systemd user directory
    mkdir -p "$HOME/.config/systemd/user/"
    
    # Create service file
    cat > "$HOME/.config/systemd/user/hyprland.service" << EOF
[Unit]
Description=Hyprland Wayland Compositor
After=hypr-splash.service
Requires=hypr-splash.service

[Service]
Type=simple
ExecStart=Hyprland
Restart=on-failure
RestartSec=1
TimeoutStopSec=10

[Install]
WantedBy=graphical.target
EOF
    
    # Enable the service
    systemctl --user enable hyprland.service
    
    print_message "$GREEN" "Hyprland service created and enabled!"
}

# Function to setup new features
setup_new_features() {
    print_message "$BLUE" "Setting up new features..."
    
    # Setup Performance Optimizer
    print_message "$BLUE" "Setting up Performance Optimizer..."
    "$HOME/.config/hypr/scripts/performance-optimizer.sh" --auto
    
    # Setup Workspace Manager
    print_message "$BLUE" "Setting up Workspace Manager..."
    mkdir -p "$HOME/.config/hypr"
    
    # Create workspace configuration
    if [ ! -f "$HOME/.config/hypr/workspaces.conf" ]; then
        cat > "$HOME/.config/hypr/workspaces.conf" << EOF
{
    "workspaces": {
        "1": {
            "name": "Main",
            "icon": "desktop",
            "color": "#ff6699"
        },
        "2": {
            "name": "Web",
            "icon": "web-browser",
            "color": "#66aaff"
        },
        "3": {
            "name": "Code",
            "icon": "code",
            "color": "#99cc33"
        },
        "4": {
            "name": "Media",
            "icon": "multimedia",
            "color": "#cc66ff"
        },
        "5": {
            "name": "Chat",
            "icon": "chat",
            "color": "#ffcc00"
        },
        "6": {
            "name": "Files",
            "icon": "folder",
            "color": "#ff9933"
        },
        "7": {
            "name": "Design",
            "icon": "design",
            "color": "#33cccc"
        },
        "8": {
            "name": "Games",
            "icon": "games",
            "color": "#ff3366"
        },
        "9": {
            "name": "Settings",
            "icon": "settings",
            "color": "#999999"
        },
        "10": {
            "name": "Misc",
            "icon": "misc",
            "color": "#66cc99"
        }
    }
}
EOF
    fi
    
    # Create desktop entries for new features
    mkdir -p "$HOME/.local/share/applications"
    
    # Performance Optimizer desktop entry
    cat > "$HOME/.local/share/applications/hypr-performance.desktop" << EOF
[Desktop Entry]
Name=Hyprland Performance Optimizer
Comment=Optimize Hyprland performance based on hardware
Exec=$HOME/.local/bin/hypr-performance
Terminal=false
Type=Application
Categories=Settings;Utility;
Icon=preferences-system-performance
EOF
    
    # Workspace Manager desktop entry
    cat > "$HOME/.local/share/applications/hypr-workspace.desktop" << EOF
[Desktop Entry]
Name=Hyprland Workspace Manager
Comment=Manage Hyprland workspaces
Exec=$HOME/.local/bin/hypr-workspace --select
Terminal=false
Type=Application
Categories=Settings;Utility;
Icon=preferences-desktop-workspace
EOF
    
    print_message "$GREEN" "New features setup complete!"
}

# Function to update keybindings
update_keybindings() {
    print_message "$BLUE" "Updating keybindings..."
    
    # Create keybindings file
    cat > "$HOME/.config/hypr/keybinds.conf" << EOF
# Keybindings for new features

# Performance Optimizer
bind = SUPER ALT, P, exec, $HOME/.config/hypr/scripts/performance-optimizer.sh

# Workspace Manager
bind = SUPER, Tab, exec, $HOME/.config/hypr/scripts/workspace-manager.sh --simple
bind = SUPER SHIFT, Tab, exec, $HOME/.config/hypr/scripts/workspace-manager.sh --select
bind = SUPER CTRL, Tab, exec, $HOME/.config/hypr/scripts/workspace-manager.sh --move

# Iris AI Assistant
bind = SUPER, I, exec, $HOME/.config/hypr/scripts/iris-ai.sh start
bind = SUPER SHIFT, I, exec, $HOME/.config/hypr/scripts/iris-ai.sh stop
bind = SUPER CTRL, I, exec, $HOME/.config/hypr/scripts/iris-ai-upgrade.sh --upgrade
EOF
    
    # Include keybindings in hyprland.conf if not already present
    if ! grep -q "source = ~/.config/hypr/keybinds.conf" "$HOME/.config/hypr/hyprland.conf"; then
        echo "source = ~/.config/hypr/keybinds.conf" >> "$HOME/.config/hypr/hyprland.conf"
    fi
    
    print_message "$GREEN" "Keybindings updated!"
}

# Main function
main() {
    print_message "$PURPLE" "=== Hyprland Anime Ricing - Ultimate Edition Installation ==="
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_message "$RED" "Please do not run this script as root."
        exit 1
    fi
    
    # Check if running on a supported system
    if ! command_exists "hyprland"; then
        print_message "$YELLOW" "Hyprland not found. This script is designed for systems with Hyprland."
        read -p "Do you want to continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Install packages
    install_packages
    
    # Install Iris AI dependencies
    install_iris_dependencies
    
    # Copy configuration files
    copy_config_files
    
    # Copy scripts
    copy_scripts
    
    # Copy Iris AI files
    copy_iris_files
    
    # Setup splash screen
    setup_splash_screen
    
    # Create desktop entries
    create_splash_desktop_entry
    create_hyprland_desktop_entry
    
    # Create xinitrc and xsession files
    create_xinitrc
    create_xsession
    
    # Create display manager configuration
    create_display_manager_config
    
    # Create systemd services
    create_splash_service
    create_hyprland_service
    
    # Setup new features
    setup_new_features
    
    # Update keybindings
    update_keybindings
    
    print_message "$GREEN" "=== Installation Complete! ==="
    print_message "$GREEN" "You can now start Hyprland with the splash screen using one of the following methods:"
    print_message "$GREEN" "1. Select 'Hyprland Anime' from your display manager"
    print_message "$GREEN" "2. Run 'startx' from a terminal"
    print_message "$GREEN" "3. Run 'systemctl --user start hyprland.service'"
    print_message "$GREEN" "4. Run 'hypr-splash && Hyprland' from a terminal"
    print_message "$GREEN" ""
    print_message "$GREEN" "To configure your splash screen, run:"
    print_message "$GREEN" "hypr-splash-select"
    print_message "$GREEN" "Or select 'Hyprland Splash Screen Selector' from your applications menu"
    print_message "$GREEN" ""
    print_message "$GREEN" "To set up Iris AI Assistant, run:"
    print_message "$GREEN" "~/.config/hypr/scripts/iris-ai.sh setup"
    print_message "$GREEN" ""
    print_message "$GREEN" "To start Iris AI Assistant, run:"
    print_message "$GREEN" "~/.config/hypr/scripts/iris-ai.sh start"
    print_message "$GREEN" "Or press Super+I"
}

# Run the main function
main

# Exit with success
exit 0