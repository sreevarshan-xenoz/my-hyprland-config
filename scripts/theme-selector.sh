#!/bin/bash

# Anime-themed Theme Selector Script
# ---------------------------------
# This script allows users to switch between different anime themes
# with anime-themed notifications and performance optimizations

# Configuration
THEME_ICON="$HOME/.config/hypr/icons/theme.png"
CHANGE_SOUND="$HOME/.config/hypr/sounds/theme-change.wav"
THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/current-theme.txt"
THEME_PREVIEW_DIR="$HOME/.config/hypr/theme-previews"

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to use simpler theme switching (reduces resource usage)
USE_SIMPLE_SWITCHING=true
# Set to true to disable theme previews (reduces resource usage)
DISABLE_PREVIEWS=false
# Set to true to cache theme information (reduces resource usage)
USE_CACHING=true
# Cache file
CACHE_FILE="/tmp/theme-cache.txt"
# Cache expiration time in seconds
CACHE_EXPIRATION=300

# Function to play sound (with performance check)
play_sound() {
    if [ "$DISABLE_SOUNDS" = false ] && [ -f "$1" ]; then
        paplay "$1" &
    fi
}

# Function to send notification (with performance check)
send_notification() {
    if [ "$DISABLE_NOTIFICATIONS" = false ]; then
        notify-send "$1" "$2" -i "$3"
    fi
}

# Function to check if required tools are installed
check_dependencies() {
    local missing_deps=()
    
    # Check for wofi
    if ! command -v wofi &> /dev/null; then
        missing_deps+=("wofi")
    fi
    
    # Check for hyprctl
    if ! command -v hyprctl &> /dev/null; then
        missing_deps+=("hyprctl")
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Theme Selector" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$THEME_ICON"
        exit 1
    fi
}

# Function to detect system capabilities and adjust settings
detect_system_capabilities() {
    # Check CPU cores
    local cpu_cores=$(nproc 2>/dev/null || echo 2)
    
    # Check available memory
    local available_memory=$(free -m | awk '/^Mem:/ {print $7}' 2>/dev/null || echo 1024)
    
    # Adjust settings based on system capabilities
    if [ "$cpu_cores" -le 2 ] || [ "$available_memory" -lt 2048 ]; then
        # Low-end device detected
        DISABLE_SOUNDS=true
        DISABLE_NOTIFICATIONS=false
        USE_SIMPLE_SWITCHING=true
        DISABLE_PREVIEWS=true
        USE_CACHING=true
    fi
}

# Function to list available themes
list_themes() {
    # Check if themes directory exists
    if [ ! -d "$THEMES_DIR" ]; then
        send_notification "Theme Selector" "Themes directory not found: $THEMES_DIR" -i "$THEME_ICON"
        exit 1
    fi
    
    # List themes
    find "$THEMES_DIR" -maxdepth 1 -type d -not -path "$THEMES_DIR" | sort | xargs -n 1 basename
}

# Function to get current theme
get_current_theme() {
    # Check if current theme file exists
    if [ -f "$CURRENT_THEME_FILE" ]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "default"
    fi
}

# Function to apply theme
apply_theme() {
    local theme="$1"
    
    # Check if theme exists
    if [ ! -d "$THEMES_DIR/$theme" ]; then
        send_notification "Theme Selector" "Theme not found: $theme" -i "$THEME_ICON"
        return
    fi
    
    # Check if theme has a colors.conf file
    if [ ! -f "$THEMES_DIR/$theme/colors.conf" ]; then
        send_notification "Theme Selector" "Theme is missing colors.conf: $theme" -i "$THEME_ICON"
        return
    fi
    
    # Apply theme colors
    if [ "$USE_SIMPLE_SWITCHING" = true ]; then
        # Simpler command for low-end devices
        cat "$THEMES_DIR/$theme/colors.conf" > "$HOME/.config/hypr/colors.conf"
    else
        # Use more advanced theme application
        cat "$THEMES_DIR/$theme/colors.conf" > "$HOME/.config/hypr/colors.conf"
        
        # Apply theme-specific configurations if they exist
        if [ -f "$THEMES_DIR/$theme/hyprland.conf" ]; then
            # Apply theme-specific Hyprland configuration
            cat "$THEMES_DIR/$theme/hyprland.conf" > "$HOME/.config/hypr/hyprland-theme.conf"
        fi
        
        # Apply theme-specific Waybar configuration if it exists
        if [ -f "$THEMES_DIR/$theme/waybar.css" ]; then
            # Apply theme-specific Waybar styling
            cat "$THEMES_DIR/$theme/waybar.css" > "$HOME/.config/waybar/theme.css"
        fi
        
        # Apply theme-specific EWW configuration if it exists
        if [ -f "$THEMES_DIR/$theme/eww.scss" ]; then
            # Apply theme-specific EWW styling
            cat "$THEMES_DIR/$theme/eww.scss" > "$HOME/.config/eww/theme.scss"
        fi
    fi
    
    # Save current theme
    echo "$theme" > "$CURRENT_THEME_FILE"
    
    # Reload Hyprland configuration
    hyprctl reload
    
    # Restart Waybar
    pkill waybar
    waybar &
    
    # Restart EWW if it's running
    if pgrep -x "eww" > /dev/null; then
        pkill eww
        eww daemon
        eww open bar
    fi
    
    # Play change sound
    play_sound "$CHANGE_SOUND"
    
    # Show success notification
    send_notification "Theme Selector" "Applied theme: $theme" -i "$THEME_ICON"
    
    echo "Applied theme: $theme"
}

# Function to show theme preview
show_theme_preview() {
    local theme="$1"
    
    # Check if previews are disabled
    if [ "$DISABLE_PREVIEWS" = true ]; then
        return
    fi
    
    # Check if theme has a preview image
    if [ -f "$THEME_PREVIEW_DIR/$theme.png" ]; then
        # Show preview image
        feh --bg-fill "$THEME_PREVIEW_DIR/$theme.png"
    elif [ -f "$THEMES_DIR/$theme/preview.png" ]; then
        # Show preview image from theme directory
        feh --bg-fill "$THEMES_DIR/$theme/preview.png"
    fi
}

# Function to select theme
select_theme() {
    # List themes
    local themes=($(list_themes))
    
    # Check if any themes were found
    if [ ${#themes[@]} -eq 0 ]; then
        send_notification "Theme Selector" "No themes found in $THEMES_DIR" -i "$THEME_ICON"
        return
    fi
    
    # Get current theme
    local current_theme=$(get_current_theme)
    
    # Create theme options
    local theme_options=""
    for theme in "${themes[@]}"; do
        if [ "$theme" = "$current_theme" ]; then
            theme_options="$theme_options$theme (Current)\n"
        else
            theme_options="$theme_options$theme\n"
        fi
    done
    
    # Show theme selection menu
    local selected_theme=$(echo -e "$theme_options" | wofi --dmenu --prompt "Select Theme" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a theme was selected
    if [ -n "$selected_theme" ]; then
        # Remove "(Current)" suffix if present
        selected_theme=$(echo "$selected_theme" | sed 's/ (Current)//')
        
        # Show theme preview
        show_theme_preview "$selected_theme"
        
        # Apply theme
        apply_theme "$selected_theme"
    else
        # Show error notification
        send_notification "Theme Selector" "No theme was selected" -i "$THEME_ICON"
    fi
}

# Function to create a new theme
create_theme() {
    # Prompt for theme name
    local theme_name=$(echo "" | wofi --dmenu --prompt "Enter Theme Name" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a theme name was entered
    if [ -z "$theme_name" ]; then
        send_notification "Theme Selector" "No theme name was entered" -i "$THEME_ICON"
        return
    fi
    
    # Create theme directory
    mkdir -p "$THEMES_DIR/$theme_name"
    
    # Create colors.conf file
    cat > "$THEMES_DIR/$theme_name/colors.conf" << EOF
# Theme: $theme_name
# Created: $(date)

# Colors
\$bg = 0xff1a1b26
\$fg = 0xffc0caf5
\$accent = 0xff7aa2f7
\$accent2 = 0xffbb9af7
\$accent3 = 0xff7dcfff
\$accent4 = 0xfff7768e
\$accent5 = 0xff9ece6a
\$accent6 = 0xffff9e64
\$accent7 = 0xffdb4b4b
\$accent8 = 0xffc0caf5
\$accent9 = 0xff7aa2f7
\$accent10 = 0xffbb9af7
\$accent11 = 0xff7dcfff
\$accent12 = 0xfff7768e
\$accent13 = 0xff9ece6a
\$accent14 = 0xffff9e64
\$accent15 = 0xffdb4b4b
EOF
    
    # Create metadata.json file
    cat > "$THEMES_DIR/$theme_name/metadata.json" << EOF
{
    "name": "$theme_name",
    "description": "A custom anime theme",
    "author": "$USER",
    "created": "$(date)",
    "version": "1.0.0",
    "tags": ["custom", "anime"],
    "preview": "preview.png"
}
EOF
    
    # Show success notification
    send_notification "Theme Selector" "Created theme: $theme_name" -i "$THEME_ICON"
    
    echo "Created theme: $theme_name"
}

# Function to edit theme
edit_theme() {
    # List themes
    local themes=($(list_themes))
    
    # Check if any themes were found
    if [ ${#themes[@]} -eq 0 ]; then
        send_notification "Theme Selector" "No themes found in $THEMES_DIR" -i "$THEME_ICON"
        return
    fi
    
    # Create theme options
    local theme_options=""
    for theme in "${themes[@]}"; do
        theme_options="$theme_options$theme\n"
    done
    
    # Show theme selection menu
    local selected_theme=$(echo -e "$theme_options" | wofi --dmenu --prompt "Select Theme to Edit" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a theme was selected
    if [ -n "$selected_theme" ]; then
        # Check if theme exists
        if [ ! -d "$THEMES_DIR/$selected_theme" ]; then
            send_notification "Theme Selector" "Theme not found: $selected_theme" -i "$THEME_ICON"
            return
        fi
        
        # Open theme directory in file manager
        if command -v thunar &> /dev/null; then
            thunar "$THEMES_DIR/$selected_theme" &
        elif command -v nautilus &> /dev/null; then
            nautilus "$THEMES_DIR/$selected_theme" &
        elif command -v dolphin &> /dev/null; then
            dolphin "$THEMES_DIR/$selected_theme" &
        else
            send_notification "Theme Selector" "No file manager found to edit theme" -i "$THEME_ICON"
        fi
    else
        # Show error notification
        send_notification "Theme Selector" "No theme was selected" -i "$THEME_ICON"
    fi
}

# Function to delete theme
delete_theme() {
    # List themes
    local themes=($(list_themes))
    
    # Check if any themes were found
    if [ ${#themes[@]} -eq 0 ]; then
        send_notification "Theme Selector" "No themes found in $THEMES_DIR" -i "$THEME_ICON"
        return
    fi
    
    # Create theme options
    local theme_options=""
    for theme in "${themes[@]}"; do
        theme_options="$theme_options$theme\n"
    done
    
    # Show theme selection menu
    local selected_theme=$(echo -e "$theme_options" | wofi --dmenu --prompt "Select Theme to Delete" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a theme was selected
    if [ -n "$selected_theme" ]; then
        # Check if theme exists
        if [ ! -d "$THEMES_DIR/$selected_theme" ]; then
            send_notification "Theme Selector" "Theme not found: $selected_theme" -i "$THEME_ICON"
            return
        fi
        
        # Show confirmation dialog
        local confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure you want to delete $selected_theme?" --style "$HOME/.config/wofi/power-menu.css")
        
        # Check if confirmed
        if [ "$confirm" = "Yes" ]; then
            # Delete theme
            rm -rf "$THEMES_DIR/$selected_theme"
            
            # Show success notification
            send_notification "Theme Selector" "Deleted theme: $selected_theme" -i "$THEME_ICON"
            
            echo "Deleted theme: $selected_theme"
        else
            # Show cancelled notification
            send_notification "Theme Selector" "Deletion cancelled" -i "$THEME_ICON"
        fi
    else
        # Show error notification
        send_notification "Theme Selector" "No theme was selected" -i "$THEME_ICON"
    fi
}

# Function to import theme
import_theme() {
    # Prompt for theme URL or path
    local theme_source=$(echo "" | wofi --dmenu --prompt "Enter Theme URL or Path" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a theme source was entered
    if [ -z "$theme_source" ]; then
        send_notification "Theme Selector" "No theme source was entered" -i "$THEME_ICON"
        return
    fi
    
    # Check if theme source is a URL
    if [[ "$theme_source" == http* ]]; then
        # Download theme
        local temp_dir=$(mktemp -d)
        curl -L "$theme_source" -o "$temp_dir/theme.zip"
        
        # Extract theme
        unzip "$temp_dir/theme.zip" -d "$temp_dir"
        
        # Find theme directory
        local theme_dir=$(find "$temp_dir" -type d -name "*.theme" | head -n 1)
        
        # Check if theme directory was found
        if [ -z "$theme_dir" ]; then
            send_notification "Theme Selector" "No theme found in downloaded file" -i "$THEME_ICON"
            rm -rf "$temp_dir"
            return
        fi
        
        # Get theme name
        local theme_name=$(basename "$theme_dir" .theme)
        
        # Copy theme to themes directory
        cp -r "$theme_dir"/* "$THEMES_DIR/$theme_name"
        
        # Clean up
        rm -rf "$temp_dir"
        
        # Show success notification
        send_notification "Theme Selector" "Imported theme: $theme_name" -i "$THEME_ICON"
        
        echo "Imported theme: $theme_name"
    else
        # Check if theme source is a local path
        if [ -d "$theme_source" ]; then
            # Get theme name
            local theme_name=$(basename "$theme_source")
            
            # Copy theme to themes directory
            cp -r "$theme_source" "$THEMES_DIR/$theme_name"
            
            # Show success notification
            send_notification "Theme Selector" "Imported theme: $theme_name" -i "$THEME_ICON"
            
            echo "Imported theme: $theme_name"
        else
            # Show error notification
            send_notification "Theme Selector" "Invalid theme source: $theme_source" -i "$THEME_ICON"
        fi
    fi
}

# Function to export theme
export_theme() {
    # List themes
    local themes=($(list_themes))
    
    # Check if any themes were found
    if [ ${#themes[@]} -eq 0 ]; then
        send_notification "Theme Selector" "No themes found in $THEMES_DIR" -i "$THEME_ICON"
        return
    fi
    
    # Create theme options
    local theme_options=""
    for theme in "${themes[@]}"; do
        theme_options="$theme_options$theme\n"
    done
    
    # Show theme selection menu
    local selected_theme=$(echo -e "$theme_options" | wofi --dmenu --prompt "Select Theme to Export" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a theme was selected
    if [ -n "$selected_theme" ]; then
        # Check if theme exists
        if [ ! -d "$THEMES_DIR/$selected_theme" ]; then
            send_notification "Theme Selector" "Theme not found: $selected_theme" -i "$THEME_ICON"
            return
        fi
        
        # Prompt for export path
        local export_path=$(echo "$HOME/Downloads/$selected_theme.theme.zip" | wofi --dmenu --prompt "Enter Export Path" --style "$HOME/.config/wofi/power-menu.css")
        
        # Check if an export path was entered
        if [ -z "$export_path" ]; then
            send_notification "Theme Selector" "No export path was entered" -i "$THEME_ICON"
            return
        fi
        
        # Create temporary directory
        local temp_dir=$(mktemp -d)
        
        # Copy theme to temporary directory
        cp -r "$THEMES_DIR/$selected_theme" "$temp_dir/$selected_theme.theme"
        
        # Create zip file
        cd "$temp_dir" && zip -r "$export_path" "$selected_theme.theme"
        
        # Clean up
        rm -rf "$temp_dir"
        
        # Show success notification
        send_notification "Theme Selector" "Exported theme: $selected_theme" -i "$THEME_ICON"
        
        echo "Exported theme: $selected_theme"
    else
        # Show error notification
        send_notification "Theme Selector" "No theme was selected" -i "$THEME_ICON"
    fi
}

# Main function
main() {
    # Detect system capabilities
    detect_system_capabilities
    
    # Check dependencies
    check_dependencies
    
    # Check the argument
    case "$1" in
        "select")
            # Select theme
            select_theme
            ;;
        "create")
            # Create theme
            create_theme
            ;;
        "edit")
            # Edit theme
            edit_theme
            ;;
        "delete")
            # Delete theme
            delete_theme
            ;;
        "import")
            # Import theme
            import_theme
            ;;
        "export")
            # Export theme
            export_theme
            ;;
        "current")
            # Get current theme
            get_current_theme
            ;;
        "list")
            # List themes
            list_themes
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_SWITCHING=true
            DISABLE_PREVIEWS=true
            USE_CACHING=true
            send_notification "Theme Selector" "Low-end mode enabled" -i "$THEME_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            USE_SIMPLE_SWITCHING=false
            DISABLE_PREVIEWS=false
            USE_CACHING=true
            send_notification "Theme Selector" "High-end mode enabled" -i "$THEME_ICON"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Select Theme\nCreate Theme\nEdit Theme\nDelete Theme\nImport Theme\nExport Theme\nShow Current Theme\nList Themes\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "Theme Selector" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Select Theme")
                    select_theme
                    ;;
                "Create Theme")
                    create_theme
                    ;;
                "Edit Theme")
                    edit_theme
                    ;;
                "Delete Theme")
                    delete_theme
                    ;;
                "Import Theme")
                    import_theme
                    ;;
                "Export Theme")
                    export_theme
                    ;;
                "Show Current Theme")
                    current_theme=$(get_current_theme)
                    send_notification "Theme Selector" "Current theme: $current_theme" -i "$THEME_ICON"
                    ;;
                "List Themes")
                    themes=$(list_themes)
                    send_notification "Theme Selector" "Available themes: $themes" -i "$THEME_ICON"
                    ;;
                "Enable Low-End Mode")
                    DISABLE_SOUNDS=true
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_SWITCHING=true
                    DISABLE_PREVIEWS=true
                    USE_CACHING=true
                    send_notification "Theme Selector" "Low-end mode enabled" -i "$THEME_ICON"
                    ;;
                "Enable High-End Mode")
                    DISABLE_SOUNDS=false
                    DISABLE_NOTIFICATIONS=false
                    USE_SIMPLE_SWITCHING=false
                    DISABLE_PREVIEWS=false
                    USE_CACHING=true
                    send_notification "Theme Selector" "High-end mode enabled" -i "$THEME_ICON"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 