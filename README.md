# 🎌 Hyprland Anime Ricing

A comprehensive anime-themed Hyprland configuration for Arch Linux, featuring a beautiful and functional desktop environment with anime aesthetics.

![Hyprland Anime Ricing Preview](preview.png)

## 🌟 Features

### 🎨 Aesthetics & Theming
- **Wallpaper Engine**: Dynamic wallpaper management with sww or hyprpaper
- **Color Schemes**: Catppuccin, TokyoNight, Rose Pine, and more
- **GTK/QT Theming**: Consistent theme across all applications
- **Custom Icon Pack**: Anime-styled icons and Papirus variants
- **Anime-styled Fonts**: JetBrainsMono Nerd Font and Japanese fonts
- **Custom Cursor Theme**: Bibata or anime-styled cursors

### 🖥️ Hyprland Configuration
- **Tiling Behavior**: Customizable window management
- **Visual Effects**: Rounded corners, shadows, transparency
- **Animations**: Smooth window transitions and effects
- **Blur & Vibrancy**: Beautiful background effects

### 🛠️ Tools and Utilities
- **waybar**: Custom status bar with anime-colored modules
- **wofi/rofi-wayland**: Application launcher
- **dunst/mako**: Notification system
- **eww**: Custom widgets and HUD elements
- **Terminal**: Themed foot, kitty, or alacritty
- **pywal**: Dynamic colorscheme generation from wallpapers
- **mpvpaper**: Support for animated/video wallpapers
- **neofetch/uwufetch**: Terminal system information display

### 🔊 Audio & Effects
- **Startup Sound**: Anime-themed boot sound
- **Notification Sounds**: Character voice clips
- **Boot Animation**: Custom Plymouth theme with anime logo
- **Voice Greeting**: Optional TTS greeting on login

### 🔧 Automation & Scripts
- **Wallpaper Rotation**: Automatic wallpaper switching
- **Weather Widget**: Anime-themed weather display
- **Random Greetings**: Quotes and voice lines
- **Power Menu**: Custom anime-styled system menu
- **Workspace Switcher**: Anime faces for workspace tags

### 🎮 Extra Features
- **Game Mode**: Special layout for gaming
- **Conky Widgets**: Rainmeter-style system monitors
- **Face Recognition**: Personalized voice responses
- **Waifu Clock/Calendar**: Anime-themed time displays
- **Floating Dock**: Custom application launcher

## 📋 Requirements

- Arch Linux
- Hyprland
- Required packages (see Installation section)

## 🚀 Installation

```bash
# Clone this repository
git clone https://github.com/yourusername/hyprland-anime-ricing.git
cd hyprland-anime-ricing

# Run the installation script
./install.sh
```

## 📦 Package Dependencies

- hyprland
- waybar
- wofi/rofi-wayland
- dunst/mako
- eww
- foot/kitty/alacritty
- pywal
- mpvpaper
- neofetch/uwufetch
- sww/hyprpaper
- lxappearance/kvantum
- papirus-icon-theme
- ttf-jetbrains-mono-nerd
- noto-fonts-cjk
- bibata-cursor-theme
- plymouth
- pyttsx3

## 🛠️ Configuration

All configuration files are located in the `config` directory:

- `hypr/`: Hyprland configuration
- `waybar/`: Waybar configuration
- `wofi/`: Wofi configuration
- `dunst/`: Dunst configuration
- `eww/`: Eww widgets
- `scripts/`: Custom scripts and utilities

## 🎨 Customization

### Wallpapers
Place your anime wallpapers in `~/.config/hypr/wallpapers/`

### Color Schemes
Edit `~/.config/hypr/colors.conf` to change the color scheme

### Widgets
Customize eww widgets in `~/.config/eww/`

## 📝 License

MIT License

## 🙏 Acknowledgments

- Hyprland developers
- All the anime artists and creators
- The Linux ricing community

---

*Made with ❤️ for anime and Linux enthusiasts* 

![Hyprland Anime Ricing](https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/screenshots/main.png)

A beautiful and functional anime-themed Hyprland configuration for Arch Linux.

## Features

- 🎨 Anime-themed aesthetics with customizable wallpapers
- 🎮 Game mode toggle for distraction-free gaming
- 🌤️ Weather widget with anime-themed icons
- 🕒 Clock widget with anime quotes
- 🔊 Audio controls with anime-themed notifications
- 💻 Power menu with anime-themed styling
- 🖼️ Wallpaper switcher with anime wallpapers
- 🎵 Media controls for your favorite music
- 🔋 Battery and system monitoring
- 🌙 Light/dark mode toggle

## Screenshots

![Screenshot 1](https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/screenshots/screenshot1.png)
![Screenshot 2](https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/screenshots/screenshot2.png)
![Screenshot 3](https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/screenshots/screenshot3.png)

## Requirements

- Arch Linux (or an Arch-based distribution)
- A Wayland-compatible graphics driver
- Basic knowledge of Linux and Hyprland

## Installation

### Automatic Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/hyprland-anime-ricing.git
   cd hyprland-anime-ricing
   ```

2. Run the installation script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. Log out and select Hyprland from your display manager, or run `Hyprland` from your terminal.

### Manual Installation

1. Install the required packages:
   ```bash
   sudo pacman -S hyprland waybar wofi dunst swww pywal grim slurp wl-clipboard pavucontrol brightnessctl playerctl jq curl noto-fonts-cjk ttf-jetbrains-mono-nerd papirus-icon-theme bibata-cursor-theme
   yay -S eww-wayland mpvpaper uwufetch
   ```

2. Copy the configuration files to their respective locations:
   ```bash
   mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/wofi ~/.config/dunst ~/.config/eww ~/.config/hypr/wallpapers ~/.config/hypr/sounds ~/.config/hypr/icons ~/.config/hypr/scripts
   cp config/hypr/hyprland.conf ~/.config/hypr/
   cp config/hypr/colors.conf ~/.config/hypr/
   cp config/waybar/config ~/.config/waybar/
   cp config/waybar/style.css ~/.config/waybar/
   cp config/wofi/power-menu.css ~/.config/wofi/
   cp scripts/* ~/.config/hypr/scripts/
   chmod +x ~/.config/hypr/scripts/*.sh
   ```

3. Download sample wallpapers, sounds, and icons:
   ```bash
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-1.jpg" -o ~/.config/hypr/wallpapers/default.jpg
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-2.jpg" -o ~/.config/hypr/wallpapers/anime-2.jpg
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-3.jpg" -o ~/.config/hypr/wallpapers/anime-3.jpg
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-4.jpg" -o ~/.config/hypr/wallpapers/anime-4.jpg
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/wallpapers/anime-5.jpg" -o ~/.config/hypr/wallpapers/anime-5.jpg
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/startup.wav" -o ~/.config/hypr/sounds/startup.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/shutdown.wav" -o ~/.config/hypr/sounds/shutdown.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/reboot.wav" -o ~/.config/hypr/sounds/reboot.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/logout.wav" -o ~/.config/hypr/sounds/logout.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/lock.wav" -o ~/.config/hypr/sounds/lock.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/suspend.wav" -o ~/.config/hypr/sounds/suspend.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/hibernate.wav" -o ~/.config/hypr/sounds/hibernate.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/game-mode-on.wav" -o ~/.config/hypr/sounds/game-mode-on.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/sounds/game-mode-off.wav" -o ~/.config/hypr/sounds/game-mode-off.wav
   curl -L "https://raw.githubusercontent.com/linuxdotexe/archlinux-hyprland/main/icons/game-mode.png" -o ~/.config/hypr/icons/game-mode.png
   ```

4. Log out and select Hyprland from your display manager, or run `Hyprland` from your terminal.

## Configuration

### Hyprland Configuration

The main Hyprland configuration file is located at `~/.config/hypr/hyprland.conf`. This file contains all the keybindings, window rules, and other Hyprland-specific settings.

### Waybar Configuration

The Waybar configuration files are located at:
- `~/.config/waybar/config` - Main configuration file
- `~/.config/waybar/style.css` - CSS styling for Waybar

### Scripts

All the scripts are located in the `~/.config/hypr/scripts/` directory:

- `wallpaper-switcher.sh` - Switches between anime wallpapers
- `power-menu.sh` - Displays the power menu
- `weather.sh` - Displays the weather with anime-themed icons
- `clock.sh` - Displays the time with anime quotes
- `game-mode.sh` - Toggles game mode

## Keybindings

| Key | Action |
|-----|--------|
| `Super + Return` | Open terminal |
| `Super + D` | Open application launcher |
| `Super + Shift + Q` | Open power menu |
| `Super + W` | Toggle wallpaper |
| `Super + G` | Toggle game mode |
| `Super + M` | Toggle media controls |
| `Super + C` | Toggle clock widget |
| `Super + Y` | Toggle weather widget |
| `Super + L` | Lock screen |
| `Super + Shift + C` | Close window |
| `Super + F` | Toggle fullscreen |
| `Super + H` | Toggle floating mode |
| `Super + J` | Focus next window |
| `Super + K` | Focus previous window |
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Mouse1` | Move window |
| `Super + Mouse2` | Resize window |
| `Super + Mouse3` | Toggle floating mode |
| `Super + Mouse4` | Scroll through workspaces |
| `Super + Mouse5` | Scroll through workspaces |
| `Super + Shift + Mouse4` | Move window to previous workspace |
| `Super + Shift + Mouse5` | Move window to next workspace |
| `Super + Shift + S` | Take a screenshot |
| `Super + Shift + R` | Record a video |
| `Super + Shift + P` | Toggle picture-in-picture |
| `Super + Shift + T` | Toggle transparency |
| `Super + Shift + B` | Toggle blur |
| `Super + Shift + N` | Toggle night mode |
| `Super + Shift + A` | Toggle animations |
| `Super + Shift + V` | Toggle vfr |
| `Super + Shift + X` | Toggle xwayland |
| `Super + Shift + Z` | Toggle zero |
| `Super + Shift + 0` | Reset all settings |

## Customization

### Wallpapers

You can add your own anime wallpapers to the `~/.config/hypr/wallpapers/` directory. The wallpaper switcher script will automatically detect and use them.

### Colors

The color scheme is defined in the `~/.config/hypr/colors.conf` file. You can modify this file to change the color scheme.

### Icons

You can add your own anime icons to the `~/.config/hypr/icons/` directory. The scripts will automatically detect and use them.

### Sounds

You can add your own anime sounds to the `~/.config/hypr/sounds/` directory. The scripts will automatically detect and use them.

## Troubleshooting

### Waybar Not Showing

If Waybar is not showing, try running the following command:

```bash
waybar
```

If you see any errors, check the Waybar configuration files.

### Scripts Not Working

If the scripts are not working, make sure they are executable:

```bash
chmod +x ~/.config/hypr/scripts/*.sh
```

Also, check if the required dependencies are installed:

```bash
sudo pacman -S jq curl
```

### Hyprland Not Starting

If Hyprland is not starting, check the logs:

```bash
journalctl -b -u hyprland
```

Also, make sure you have a Wayland-compatible graphics driver installed.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Hyprland](https://github.com/hyprwm/Hyprland) - The Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - The status bar
- [Wofi](https://hg.sr.ht/~scoopta/wofi) - The application launcher
- [Dunst](https://github.com/dunst-project/dunst) - The notification daemon
- [Swww](https://github.com/Horus645/swww) - The wallpaper daemon
- [Pywal](https://github.com/dylanaraps/pywal) - The color scheme generator
- [Grim](https://github.com/emersion/grim) - The screenshot tool
- [Slurp](https://github.com/emersion/slurp) - The region selection tool
- [Wl-clipboard](https://github.com/bugaevc/wl-clipboard) - The clipboard tool
- [Pavucontrol](https://github.com/pulseaudio/pavucontrol) - The audio control tool
- [Brightnessctl](https://github.com/Hummer12007/brightnessctl) - The brightness control tool
- [Playerctl](https://github.com/altdesktop/playerctl) - The media control tool
- [Eww](https://github.com/elkowar/eww) - The widget system
- [Mpvpaper](https://github.com/GhostNaN/mpvpaper) - The video wallpaper tool
- [Uwufetch](https://github.com/TheDarkBug/uwufetch) - The system information tool 