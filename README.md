# 🎌 Hyprland Anime Ricing - Ultimate Edition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hyprland](https://img.shields.io/badge/Hyprland-v0.34+-blue.svg)](https://hyprland.org/)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=fff)](https://archlinux.org/)

A comprehensive, feature-rich anime-themed Hyprland configuration for Arch Linux that transforms your desktop into a beautiful, functional anime paradise. This setup combines cutting-edge Wayland technology with stunning anime aesthetics and advanced automation.

![Hyprland Anime Ricing Preview](preview.png)

## 🌟 Features

- **🎭 Multiple Anime Themes**: Switch between different anime series themes
- **🎵 Audio Visualizer**: Real-time audio visualization with anime effects
- **🎮 Enhanced Gaming Mode**: Performance optimization for gaming
- **🌐 Live Wallpapers**: Support for interactive and reactive wallpapers
- **🗣️ Iris AI Assistant**: Local AI assistant with voice capabilities
- **🎬 Anime Splash Screen**: Custom boot splash with anime themes
- **🎨 Dynamic Theming**: Automatic color extraction from wallpapers
- **🔔 Custom Notifications**: Anime-styled notification system

## 📋 System Requirements

### Minimum Requirements
- **OS**: Arch Linux or Arch-based distribution
- **GPU**: OpenGL 3.3+ support
- **RAM**: 4GB (8GB recommended)
- **Storage**: 2GB free space for full installation

### Recommended Hardware
- **GPU**: Dedicated graphics card for best performance
- **RAM**: 16GB+ for smooth animations and effects
- **CPU**: Multi-core processor (4+ cores recommended)
- **Storage**: SSD for faster boot times and smoother animations

### Iris AI Requirements
- **RAM**: 2GB+ for lightweight models
- **Storage**: 2-4GB for model storage
- **Microphone**: For voice command functionality
- **Speakers**: For voice response output

## 🚀 Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/sreevarshan-xenoz/my-hyprland-config.git
cd my-hyprland-config

# Make the install script executable
chmod +x install.sh

# Run the installer
./install.sh
```

### Post-Installation

After installation completes, you can start Hyprland with the splash screen using one of the following methods:

1. Select 'Hyprland Anime' from your display manager
2. Run 'startx' from a terminal
3. Run 'systemctl --user start hyprland.service'
4. Run 'hypr-splash && Hyprland' from a terminal

To configure your splash screen, run:
```bash
hypr-splash-select
```

To set up Iris AI Assistant, run:
```bash
~/.config/hypr/scripts/iris-ai.sh setup
```

To start Iris AI Assistant, run:
```bash
~/.config/hypr/scripts/iris-ai.sh start
```
Or press Super+I

## 📦 Package Dependencies

### Core Packages (Required)
```bash
# Hyprland ecosystem
hyprland hyprpaper hyprlock hypridle hyprpicker

# Status bar and widgets
waybar eww-wayland

# Application launcher and menus
wofi rofi-wayland

# Notifications and audio
dunst mako pipewire pipewire-pulse pavucontrol

# Terminal emulators
foot kitty alacritty wezterm

# File management and utilities
thunar nemo dolphin ranger lf
grim slurp wl-clipboard swappy
brightnessctl playerctl bluetuith
```

### Theming Packages
```bash
# Icon themes and cursors
papirus-icon-theme candy-icons
bibata-cursor-theme catppuccin-cursors

# Fonts
ttf-jetbrains-mono-nerd ttf-fira-code-nerd
noto-fonts-cjk noto-fonts-emoji
ttf-ms-fonts adobe-source-han-sans-jp-fonts

# Color scheme generators
pywal-git colorz python-colorthief

# GTK/Qt theming
lxappearance qt5ct kvantum
catppuccin-gtk-theme-mocha
```

### Animation and Effects
```bash
# Animation libraries
glfw-wayland cairo pango
librsvg gdk-pixbuf2 webp-pixbuf-loader

# Audio visualization
cava cli-visualizer glava

# Video wallpapers and effects
mpvpaper swww hyprpaper
ffmpeg imagemagick gifski
```

### Iris AI Python Dependencies
```bash
# Core AI packages
pip install transformers torch accelerate sentencepiece protobuf

# Voice capabilities
pip install SpeechRecognition gTTS pygame numpy sounddevice
```

### AUR Packages (via yay/paru)
```bash
# Essential AUR packages
yay -S swww-git hyprpicker-git eww-wayland
yay -S cava-git cli-visualizer-git
yay -S anime-wallpaper-cli waifu2x-ncnn-vulkan
yay -S plymouth-theme-anime spicetify-cli
yay -S zscroll-git picom-animations-git
```

## 🎛️ Configuration Structure

```
~/.config/hypr/
├── hyprland.conf       # Main config file
├── themes/             # Theme configurations
├── scripts/            # Utility scripts
├── wallpapers/         # Wallpaper collections
├── sounds/             # Audio files
├── icons/              # Custom icons
└── splash/             # Splash screen configurations
```

## ⌨️ Key Features

### Anime Splash Screen
The configuration includes a customizable anime-themed splash screen that plays before Hyprland starts. You can select different animations, themes, and audio effects.

```bash
# Configure splash screen
hypr-splash-select
```

### Iris AI Assistant
Iris is a local AI assistant that can control your system through voice commands. It uses lightweight AI models that run on your local machine.

```bash
# Setup Iris AI
~/.config/hypr/scripts/iris-ai.sh setup

# Start Iris AI
~/.config/hypr/scripts/iris-ai.sh start
```

### Dynamic Theming
The configuration includes a dynamic theming system that can extract colors from your wallpaper and apply them to your entire desktop environment.

### Custom Keybindings
The configuration includes a comprehensive set of keybindings for window management, system control, and application launching.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- [Hyprland](https://hyprland.org/) - The dynamic tiling Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Highly customizable Wayland bar
- [EWW](https://github.com/elkowar/eww) - ElKowar's Wacky Widgets
- [Wofi](https://hg.sr.ht/~scoopta/wofi) - Application launcher for Wayland
- [Dunst](https://github.com/dunst-project/dunst) - Lightweight notification daemon
- [Swww](https://github.com/Horus645/swww) - Efficient animated wallpaper daemon for Wayland
- [Cava](https://github.com/karlstav/cava) - Console-based audio visualizer

## 📞 Support

If you encounter any issues or have questions, please open an issue on GitHub.