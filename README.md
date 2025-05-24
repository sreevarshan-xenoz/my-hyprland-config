# 🎌 Hyprland Anime Ricing - Ultimate Edition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hyprland](https://img.shields.io/badge/Hyprland-v0.34+-blue.svg)](https://hyprland.org/)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=fff)](https://archlinux.org/)

A comprehensive, feature-rich anime-themed Hyprland configuration for Arch Linux that transforms your desktop into a beautiful, functional anime paradise. This setup combines cutting-edge Wayland technology with stunning anime aesthetics and advanced automation.

![Hyprland Anime Ricing Preview](preview.png)

## 🌟 What's New in Ultimate Edition

- **🎭 Multiple Anime Themes**: Switch between different anime series themes
- **🤖 AI-Powered Features**: Smart wallpaper matching and dynamic theming
- **🎵 Audio Visualizer**: Real-time audio visualization with anime effects
- **🎮 Enhanced Gaming Mode**: RGB lighting sync and performance optimization
- **📱 Mobile Integration**: Control your desktop from your phone
- **🌐 Live Wallpapers**: Support for interactive and reactive wallpapers
- **🎯 Context-Aware UI**: Interface adapts based on your activity

## ✨ Features Overview

### 🎨 Advanced Aesthetics & Theming

#### Dynamic Theme Engine
- **Multi-Theme Support**: 15+ anime series themes (Demon Slayer, Attack on Titan, Your Name, etc.)
- **Seasonal Themes**: Automatic theme switching based on time/season
- **Character Modes**: Dedicated themes for specific anime characters
- **Live Color Extraction**: Dynamic colors from current wallpaper/media
- **Mood-Based Theming**: Themes that adapt to time of day and weather

#### Visual Effects
- **Shader Pipeline**: Custom GLSL shaders for unique visual effects
- **Particle Systems**: Animated sakura petals, snow, and other effects
- **Dynamic Blur**: Context-sensitive blur effects
- **Neon Glow Effects**: Cyberpunk-style glowing elements
- **Holographic UI**: Semi-transparent, futuristic interface elements

### 🖥️ Enhanced Hyprland Configuration

#### Window Management
- **Smart Layouts**: Automatic layout suggestions based on application types
- **Floating Rules**: Intelligent floating window management
- **Workspace Theming**: Each workspace can have its own anime theme
- **Window Decorations**: Custom titlebar designs with anime elements
- **Gesture Controls**: Advanced touchpad/mouse gestures

#### Animation System
- **60+ Animation Presets**: From subtle to dramatic transitions
- **Physics-Based Animations**: Realistic spring and bounce effects
- **Context Animations**: Different animations for different app types
- **Performance Scaling**: Automatic animation quality adjustment

### 🛠️ Comprehensive Tool Suite

#### Core Components
- **Waybar Pro**: Enhanced status bar with 20+ custom modules
- **Wofi/Rofi Anime**: Fully themed application launchers
- **Dunst Plus**: Rich notifications with anime sounds and images
- **EWW Widgets**: 15+ custom widgets (weather, system stats, quotes, etc.)
- **Hyprlock**: Custom anime-themed lock screen
- **Hypridle**: Smart idle management with anime screensavers

#### Terminal Enhancement
- **Multi-Terminal Support**: Foot, Kitty, Alacritty, WezTerm configs
- **Anime Prompts**: Starship configs with anime characters
- **Terminal Wallpapers**: Background images in terminal
- **Sound Effects**: Terminal bell sounds with anime clips
- **Custom Commands**: Anime-themed aliases and functions

### 🎵 Audio & Media Integration

#### Advanced Audio
- **Audio Visualizer**: Real-time spectrum analyzer with anime themes
- **Character Voice Pack**: 100+ voice clips for system events
- **Dynamic Sound Effects**: Context-aware audio feedback
- **Media Integration**: Album art and anime poster displays
- **Spatial Audio**: 3D positioned sound effects

#### Media Features
- **Anime Streaming Integration**: Direct links to legal streaming platforms
- **MAL Integration**: MyAnimeList status in your desktop
- **Episode Tracker**: Keep track of what you're watching
- **Soundtrack Player**: Dedicated anime OST player
- **Live Concert Mode**: Special layout for anime concert streams

### 🔧 Automation & Intelligence

#### Smart Features
- **Routine Detection**: Learn your daily patterns
- **Auto Theming**: Switch themes based on what you're doing
- **Weather Integration**: 50+ weather conditions with anime representations
- **Calendar Events**: Anime character birthday notifications
- **Focus Mode**: Distraction-free environments for work/study

#### System Integration
- **Hardware Monitoring**: GPU, CPU temps with anime-style meters
- **RGB Lighting**: Sync with OpenRGB for immersive lighting
- **Webcam Effects**: Anime filters and backgrounds for video calls
- **Clipboard Manager**: Visual clipboard with anime-styled previews
- **File Manager**: Themed file browsers with anime folder icons

### 🎮 Gaming Excellence

#### Game Mode Features
- **Performance Profiles**: Automatic optimization per game
- **RGB Game Sync**: Lighting changes based on game events
- **Overlay System**: In-game anime-themed overlays
- **Achievement Notifications**: Custom anime-styled game achievements
- **Streaming Integration**: OBS scenes with anime overlays

#### Gaming Enhancements
- **Controller Support**: DS4, Xbox, Switch Pro controller themes
- **Game Library**: Visual game launcher with anime box art
- **Performance Metrics**: Real-time FPS, temps with anime styling
- **Screenshot Gallery**: Organized game screenshots with metadata
- **Time Tracking**: Detailed gaming statistics

### 📱 Mobile & Remote Features

- **Mobile Control App**: Control desktop from Android/iOS
- **Remote Wallpaper**: Change wallpapers from your phone
- **Notification Sync**: Phone notifications on desktop
- **File Sharing**: Seamless file transfer between devices
- **Remote Power**: Shutdown, restart, suspend from mobile

## 📋 System Requirements

### Minimum Requirements
- **OS**: Arch Linux, EndeavourOS, or Arch-based distribution
- **GPU**: OpenGL 3.3+ support (Intel HD 4000+, AMD GCN 1.0+, NVIDIA GTX 400+)
- **RAM**: 4GB (8GB recommended)
- **Storage**: 2GB free space for full installation
- **Network**: Internet connection for initial setup and updates

### Recommended Hardware
- **GPU**: Dedicated graphics card for best performance
- **RAM**: 16GB+ for smooth animations and effects
- **CPU**: Multi-core processor (4+ cores recommended)
- **Storage**: SSD for faster boot times and smoother animations

### Supported Resolutions
- **4K (3840x2160)**: Full support with scaling options
- **1440p (2560x1440)**: Native support, optimal experience
- **1080p (1920x1080)**: Full support, best performance
- **Ultrawide**: 21:9 and 32:9 aspect ratios supported

## 🚀 Installation

### Quick Install (Recommended)

```bash
# Download and run the interactive installer
curl -fsSL https://raw.githubusercontent.com/yourusername/hyprland-anime-ricing/main/install.sh | bash

# Or clone and run manually
git clone https://github.com/yourusername/hyprland-anime-ricing.git
cd hyprland-anime-ricing
chmod +x install.sh
./install.sh
```

### Installation Options

The installer provides several options:

1. **Full Installation**: Complete setup with all features
2. **Minimal Installation**: Basic theming without heavy features
3. **Gaming Focus**: Optimized for gaming with performance tweaks
4. **Streaming Setup**: Configured for content creation and streaming
5. **Custom Installation**: Choose specific components

### Post-Installation Setup

```bash
# Initialize the configuration
hypr-anime-setup --init

# Choose your starting theme
hypr-anime-setup --theme-selector

# Configure hardware-specific settings
hypr-anime-setup --hardware-config

# Set up mobile integration (optional)
hypr-anime-setup --mobile-setup
```

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

### Optional Enhancement Packages
```bash
# Development and customization
git nodejs npm python python-pip
code-oss neovim emacs

# Gaming enhancements
steam lutris gamemode mangohud
openrgb liquidctl

# Media and creativity
obs-studio kdenlive gimp blender
spotify-launcher firefox chromium

# System monitoring
htop btop neofetch fastfetch uwufetch
sensors lm_sensors nvtop
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
~/.config/hypr-anime/
├── hypr/                    # Hyprland configuration
│   ├── hyprland.conf       # Main config file
│   ├── themes/             # Theme configurations
│   ├── keybinds/           # Keybinding configs
│   ├── rules/              # Window rules
│   └── animations/         # Animation presets
├── waybar/                 # Status bar configuration
│   ├── config             # Waybar config
│   ├── style.css          # Main styles
│   └── modules/           # Custom modules
├── eww/                   # Widget configurations
│   ├── eww.yuck          # Widget definitions
│   ├── eww.scss          # Widget styles
│   └── scripts/          # Widget scripts
├── wofi/                  # Application launcher
├── dunst/                 # Notification system
├── themes/                # Theme definitions
│   ├── demon-slayer/     # Individual theme folders
│   ├── attack-on-titan/
│   ├── your-name/
│   └── custom/
├── wallpapers/            # Wallpaper collections
├── sounds/                # Audio files
├── icons/                 # Custom icons
├── scripts/               # Automation scripts
├── fonts/                 # Custom fonts
└── mobile/                # Mobile integration
```

## 🎨 Theme Gallery

### Available Themes

| Theme | Style | Colors | Best For |
|-------|-------|---------|----------|
| **Demon Slayer** | Traditional | Red, Black, Gold | General use |
| **Attack on Titan** | Military | Green, Brown, Steel | Productivity |
| **Your Name** | Romantic | Blue, Purple, Pink | Creative work |
| **Studio Ghibli** | Whimsical | Green, Brown, Cream | Relaxation |
| **Cyberpunk Anime** | Futuristic | Neon, Black, Blue | Gaming |
| **Tokyo Ghoul** | Dark | Black, Red, White | Night sessions |
| **Spirited Away** | Magical | Multi-color | Daily use |
| **Evangelion** | Sci-fi | Purple, Green, Orange | Development |
| **One Piece** | Adventure | Blue, Red, Yellow | Entertainment |
| **Naruto** | Ninja | Orange, Blue, Black | Focus work |
| **Sailor Moon** | Magical Girl | Pink, Blue, Gold | Creative design |
| **Death Note** | Gothic | Black, White, Red | Writing/Study |
| **Akira** | Retro-future | Red, Black, Neon | Cyberpunk vibes |
| **Princess Mononoke** | Nature | Green, Brown, White | Eco-friendly |
| **Cowboy Bebop** | Space | Blue, Yellow, Black | Jazz sessions |

### Custom Theme Creation

```bash
# Create a new theme
hypr-anime-setup --create-theme "My Custom Theme"

# Theme structure
themes/my-custom-theme/
├── colors.conf           # Color definitions
├── wallpapers/          # Theme wallpapers
├── sounds/              # Theme sounds
├── waybar.css           # Waybar styling
├── eww.scss             # Widget styling
└── metadata.json        # Theme information
```

## ⌨️ Keybindings Reference

### Window Management
| Keybinding | Action | Category |
|------------|--------|----------|
| `Super + Return` | Open terminal | Launch |
| `Super + D` | Application launcher | Launch |
| `Super + Shift + Q` | Quit application | Window |
| `Super + F` | Toggle fullscreen | Window |
| `Super + T` | Toggle floating | Window |
| `Super + H/J/K/L` | Move focus | Navigation |
| `Super + Shift + H/J/K/L` | Move window | Window |
| `Super + Ctrl + H/J/K/L` | Resize window | Window |
| `Super + 1-9` | Switch workspace | Workspace |
| `Super + Shift + 1-9` | Move to workspace | Workspace |
| `Super + Mouse1` | Move window | Mouse |
| `Super + Mouse2` | Resize window | Mouse |

### System Controls
| Keybinding | Action | Category |
|------------|--------|----------|
| `Super + L` | Lock screen | Security |
| `Super + Shift + E` | Power menu | System |
| `Super + Shift + R` | Restart Hyprland | System |
| `Super + Alt + R` | Reload config | System |
| `Print` | Screenshot | Media |
| `Shift + Print` | Region screenshot | Media |
| `Super + Print` | Window screenshot | Media |
| `XF86AudioRaiseVolume` | Volume up | Audio |
| `XF86AudioLowerVolume` | Volume down | Audio |
| `XF86AudioMute` | Toggle mute | Audio |
| `XF86MonBrightnessUp` | Brightness up | Display |
| `XF86MonBrightnessDown` | Brightness down | Display |

### Anime-Specific Features
| Keybinding | Action | Category |
|------------|--------|----------|
| `Super + W` | Wallpaper switcher | Theme |
| `Super + Shift + T` | Theme selector | Theme |
| `Super + G` | Game mode toggle | Gaming |
| `Super + M` | Music mode | Media |
| `Super + N` | Night mode | Display |
| `Super + R` | Random quote | Fun |
| `Super + Shift + W` | Weather widget | Widget |
| `Super + C` | Calendar widget | Widget |
| `Super + V` | Audio visualizer | Media |
| `Super + Shift + G` | RGB control | Hardware |
| `Super + Alt + M` | Mobile sync | Mobile |
| `Super + Shift + A` | Animation settings | Effects |

### Advanced Features
| Keybinding | Action | Category |
|------------|--------|----------|
| `Super + Tab` | Window switcher | Navigation |
| `Super + Grave` | Workspace overview | Navigation |
| `Super + Shift + S` | Screen recorder | Media |
| `Super + Alt + S` | Stream mode | Streaming |
| `Super + Ctrl + G` | Gaming overlay | Gaming |
| `Super + Shift + F` | Focus mode | Productivity |
| `Super + Alt + W` | Waifu mode | Fun |
| `Super + Ctrl + A` | Achievement popup | Gaming |
| `Super + Shift + N` | Notification history | System |
| `Super + Alt + T` | Terminal dropdown | Launch |

## 🔧 Advanced Configuration

### Performance Optimization

```bash
# Gaming performance preset
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# GPU performance
echo "performance" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level

# Memory optimization
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

### Custom Animations

```toml
# ~/.config/hypr/animations/custom.conf
animation = windows,1,7,default,slide
animation = border,1,10,default
animation = fade,1,10,default
animation = workspaces,1,6,default,slidevert
animation = specialWorkspace,1,8,default,fade
```

### Hardware-Specific Settings

```bash
# NVIDIA users
export WLR_NO_HARDWARE_CURSORS=1
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# AMD users
export RADV_PERFTEST=aco,llvm
export MESA_LOADER_DRIVER_OVERRIDE=radeonsi

# Intel users
export MESA_LOADER_DRIVER_OVERRIDE=iris
```

### Multi-Monitor Setup

```bash
# Configure monitors
monitor=DP-1,2560x1440@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1

# Workspace binding
workspace=1,monitor:DP-1
workspace=2,monitor:DP-1
workspace=9,monitor:HDMI-A-1
workspace=10,monitor:HDMI-A-1
```

## 📱 Mobile Integration

### Android App Setup

1. Download the companion app from [GitHub Releases](https://github.com/yourusername/hyprland-anime-mobile/releases)
2. Install the APK: `adb install hyprland-anime-controller.apk`
3. Connect to the same WiFi network as your desktop
4. Pair using the QR code generated by `hypr-anime-setup --mobile-pair`

### iOS Shortcuts

1. Download the Shortcuts app from the App Store
2. Import the provided shortcuts from the `mobile/ios/` directory
3. Configure the shortcuts with your desktop's IP address
4. Add shortcuts to your home screen for quick access

### Available Mobile Controls

- **Remote Control**: Volume, brightness, media playback
- **Wallpaper Changer**: Browse and set wallpapers remotely
- **Theme Switcher**: Change desktop themes from your phone
- **Screenshot Viewer**: View and share desktop screenshots
- **System Monitor**: Check CPU, RAM, GPU usage
- **Gaming Mode**: Toggle gaming optimizations
- **Notification Mirror**: View desktop notifications on phone
- **File Transfer**: Send files between devices
- **Power Control**: Shutdown, restart, suspend remotely

## 🎮 Gaming Features

### Game Mode Enhancements

When game mode is activated:
- **CPU Governor**: Switches to performance mode
- **GPU Clocking**: Maximum performance settings
- **Compositor**: Reduced for lower latency
- **Notifications**: Temporarily disabled
- **RGB Lighting**: Gaming-specific lighting profiles
- **Audio**: Dedicated audio profile for games
- **Network**: Gaming network optimizations

### Supported Games Integration

The configuration includes special rules and optimizations for:
- **Steam Games**: Automatic fullscreen and performance tweaks
- **Lutris**: Wine/Proton optimizations
- **Minecraft**: Java-specific optimizations
- **Emulators**: RetroArch, PCSX2, Dolphin, etc.
- **Native Linux Games**: Various indie and AAA titles

### RGB Integration

Compatible with OpenRGB for synchronized lighting:
- **Corsair**: iCUE compatible devices
- **Razer**: Chroma devices
- **Logitech**: G HUB devices
- **SteelSeries**: Engine devices
- **ASUS**: Aura Sync devices
- **MSI**: Mystic Light devices

## 🔊 Audio Configuration

### PipeWire Setup

```bash
# Install PipeWire
sudo pacman -S pipewire pipewire-pulse pipewire-alsa
sudo pacman -S wireplumber pipewire-jack

# Enable services
systemctl --user enable --now pipewire
systemctl --user enable --now pipewire-pulse
systemctl --user enable --now wireplumber
```

### Audio Profiles

- **Default**: Balanced audio for general use
- **Gaming**: Low-latency, surround sound optimization
- **Music**: High-quality audio for music listening
- **Streaming**: Optimized for content creation
- **Movie**: Cinema-like surround experience
- **Anime**: Enhanced for anime dialogue and music

### Character Voice Packs

The configuration includes voice packs for:
- System startup/shutdown sounds
- Notification sounds
- Error/warning alerts
- Achievement notifications
- Time announcements
- Weather updates
- Custom greetings

## 🌐 Streaming and Content Creation

### OBS Integration

Pre-configured OBS scenes include:
- **Desktop Capture**: Full desktop with anime overlays
- **Gaming**: Game capture with custom HUD
- **Webcam**: Anime-themed webcam frames
- **Chat**: Integrated chat display
- **Music**: Audio visualizer scenes
- **BRB**: Anime-themed "be right back" scenes

### Streaming Optimizations

- **Hardware Encoding**: NVENC/AMF/QuickSync support
- **Low Latency Mode**: Reduced stream delay
- **Quality Presets**: Multiple bitrate/quality options
- **Scene Transitions**: Smooth animated transitions
- **Audio Mixing**: Multiple audio sources management
- **Chat Integration**: Twitch/YouTube chat overlay

## 🛠️ Troubleshooting

### Common Issues

#### Hyprland Won't Start
```bash
# Check logs
journalctl -u hyprland --no-pager

# Common fixes
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
```

#### Waybar Not Showing
```bash
# Restart waybar
pkill waybar && waybar &

# Check config syntax
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css
```

#### Audio Issues
```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse
```

#### Performance Issues
```bash
# Disable animations temporarily
hyprctl keyword animations:enabled false

# Check GPU usage
nvidia-smi  # NVIDIA
radeontop   # AMD
intel_gpu_top  # Intel
```

### Debug Mode

Enable debug logging:
```bash
# Start Hyprland with debug
export HYPRLAND_LOG_WLR=1
Hyprland -c ~/.config/hypr/hyprland.conf --verbose
```

### Recovery Mode

If something breaks:
```bash
# Backup current config
cp -r ~/.config/hypr ~/.config/hypr.backup

# Reset to default
hypr-anime-setup --reset

# Restore specific parts
hypr-anime-setup --restore-keybinds
hypr-anime-setup --restore-themes
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Theme Contributions
1. Create a new theme using the theme template
2. Test it thoroughly across different screen sizes
3. Submit a pull request with screenshots
4. Include theme metadata and description

### Bug Reports
1. Use the GitHub issue template
2. Include system information (`hypr-anime-info`)
3. Provide logs and screenshots
4. List reproduction steps

### Feature Requests
1. Check existing issues first
2. Describe the feature clearly
3. Explain the use case
4. Provide mockups if applicable

### Code Contributions
1. Fork the repository
2. Create a feature branch
3. Follow the coding standards
4. Test thoroughly
5. Submit a pull request

### Translation
Help translate the interface:
- English (default)
- Japanese (日本語)
- Spanish (Español)
- French (Français)
- German (Deutsch)
- Korean (한국어)
- Chinese (中文)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎉 Acknowledgments

### Hyprland Ecosystem
- [Hyprland](https://github.com/hyprwm/Hyprland) - The amazing Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Highly customizable status bar
- [EWW](https://github.com/elkowar/eww) - Widget system extraordinaire

### Anime Community
- **Artists**: All the talented anime artists whose work inspires these themes
- **Studios**: Studio Ghibli, Mappa, Ufotable, and many others
- **Community**: The amazing anime community for inspiration and feedback

### Open Source Projects
- **Arch Linux**: The foundation of this setup
- **Wayland**: The future of Linux desktop
- **Font Authors**: JetBrains, Google, Adobe for amazing fonts
- **Icon Designers**: Papirus, Candy Icons creators

### Special Thanks
- The Hyprland Discord community
- r/unixporn for inspiration
- Beta testers and early adopters
- All contributors and supporters

---

<div align="center">

**Made with ❤️ for anime and Linux enthusiasts**

*Transform your desktop into an anime paradise*

[🌟 Star this project](https://github.com/yourusername/hyprland-anime-ricing) • [🐛 Report Bug](https://github.com/yourusername/hyprland-anime-ricing/issues) • [💡 Request Feature](https://github.com/yourusername/hyprland-anime-ricing/issues)

![Anime Linux](https://img.shields.io/badge/Anime-Linux-FF69B4?style=for-the-badge&logo=linux&logoColor=white)
![Made with Love](https://img.shields.io/badge/Made%20with-❤️-red?style=for-the-badge)

</div>