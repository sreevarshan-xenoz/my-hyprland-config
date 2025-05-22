#!/bin/bash

# Anime-themed Theme Manager Script
# --------------------------------
# This script manages system themes with anime-themed notifications

# Configuration
THEME_ICON="$HOME/.config/hypr/icons/theme.png"
THEME_CHANGE_SOUND="$HOME/.config/hypr/sounds/theme-change.wav"
THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/current-theme.txt"

# Create themes directory if it doesn't exist
mkdir -p "$THEMES_DIR"

# Function to get current theme
get_current_theme() {
    # Check if the current theme file exists
    if [ ! -f "$CURRENT_THEME_FILE" ]; then
        echo "default"
        return
    fi
    
    # Get the current theme
    local theme=$(cat "$CURRENT_THEME_FILE")
    
    echo "$theme"
}

# Function to set current theme
set_current_theme() {
    # Get the theme name
    local theme="$1"
    
    # Set the current theme
    echo "$theme" > "$CURRENT_THEME_FILE"
    
    echo "Current theme set to $theme"
}

# Function to list themes
list_themes() {
    # Check if the themes directory exists
    if [ ! -d "$THEMES_DIR" ]; then
        notify-send "Theme Manager" "No themes found." -i "$THEME_ICON"
        return
    fi
    
    # List themes
    local themes=$(ls -1 "$THEMES_DIR")
    
    echo "$themes"
}

# Function to apply a theme
apply_theme() {
    # Get the theme name
    local theme="$1"
    
    # Get the theme path
    local theme_path="$THEMES_DIR/$theme"
    
    # Check if the theme exists
    if [ ! -d "$theme_path" ]; then
        notify-send "Theme Manager" "Theme $theme does not exist." -i "$THEME_ICON"
        return
    fi
    
    # Show theme notification
    notify-send "Theme Manager" "Applying theme $theme..." -i "$THEME_ICON"
    
    # Play a sound effect
    paplay "$THEME_CHANGE_SOUND" &
    
    # Apply the theme
    # Copy the theme files to the appropriate locations
    cp -r "$theme_path/hypr" "$HOME/.config/"
    cp -r "$theme_path/waybar" "$HOME/.config/"
    cp -r "$theme_path/wofi" "$HOME/.config/"
    cp -r "$theme_path/dunst" "$HOME/.config/"
    cp -r "$theme_path/eww" "$HOME/.config/"
    
    # Set the current theme
    set_current_theme "$theme"
    
    # Restart the components
    killall -q waybar
    waybar &
    
    killall -q dunst
    dunst &
    
    # Show success notification
    notify-send "Theme Manager" "Theme $theme applied successfully!" -i "$THEME_ICON"
    
    echo "Theme $theme applied successfully"
}

# Function to create a theme
create_theme() {
    # Get the theme name
    local theme="$1"
    
    # Get the theme path
    local theme_path="$THEMES_DIR/$theme"
    
    # Check if the theme already exists
    if [ -d "$theme_path" ]; then
        notify-send "Theme Manager" "Theme $theme already exists." -i "$THEME_ICON"
        return
    fi
    
    # Create the theme directory
    mkdir -p "$theme_path"
    mkdir -p "$theme_path/hypr"
    mkdir -p "$theme_path/waybar"
    mkdir -p "$theme_path/wofi"
    mkdir -p "$theme_path/dunst"
    mkdir -p "$theme_path/eww"
    
    # Copy the current configuration files to the theme directory
    cp -r "$HOME/.config/hypr" "$theme_path/"
    cp -r "$HOME/.config/waybar" "$theme_path/"
    cp -r "$HOME/.config/wofi" "$theme_path/"
    cp -r "$HOME/.config/dunst" "$theme_path/"
    cp -r "$HOME/.config/eww" "$theme_path/"
    
    # Show success notification
    notify-send "Theme Manager" "Theme $theme created successfully!" -i "$THEME_ICON"
    
    echo "Theme $theme created successfully"
}

# Function to delete a theme
delete_theme() {
    # Get the theme name
    local theme="$1"
    
    # Get the theme path
    local theme_path="$THEMES_DIR/$theme"
    
    # Check if the theme exists
    if [ ! -d "$theme_path" ]; then
        notify-send "Theme Manager" "Theme $theme does not exist." -i "$THEME_ICON"
        return
    fi
    
    # Check if the theme is the current theme
    local current_theme=$(get_current_theme)
    if [ "$theme" = "$current_theme" ]; then
        notify-send "Theme Manager" "Cannot delete the current theme." -i "$THEME_ICON"
        return
    fi
    
    # Show delete notification
    notify-send "Theme Manager" "Deleting theme $theme..." -i "$THEME_ICON"
    
    # Delete the theme
    rm -rf "$theme_path"
    
    # Check if the delete was successful
    if [ $? -eq 0 ]; then
        # Show success notification
        notify-send "Theme Manager" "Theme $theme deleted successfully!" -i "$THEME_ICON"
        
        echo "Theme $theme deleted successfully"
    else
        # Show error notification
        notify-send "Theme Manager" "Failed to delete theme $theme." -i "$THEME_ICON"
        
        echo "Failed to delete theme $theme"
    fi
}

# Function to show theme information
show_theme_info() {
    # Get the theme name
    local theme="$1"
    
    # Get the theme path
    local theme_path="$THEMES_DIR/$theme"
    
    # Check if the theme exists
    if [ ! -d "$theme_path" ]; then
        notify-send "Theme Manager" "Theme $theme does not exist." -i "$THEME_ICON"
        return
    fi
    
    # Get theme size
    local size=$(du -sh "$theme_path" | awk '{print $1}')
    
    # Get theme creation time
    local creation_time=$(stat -c "%y" "$theme_path")
    
    # Check if the theme is the current theme
    local current_theme=$(get_current_theme)
    local is_current="No"
    if [ "$theme" = "$current_theme" ]; then
        is_current="Yes"
    fi
    
    # Show theme information
    notify-send "Theme Manager" "Theme: $theme\nSize: $size\nCreated: $creation_time\nCurrent: $is_current" -i "$THEME_ICON"
    
    # Return the values for display
    echo "Theme: $theme | Size: $size | Created: $creation_time | Current: $is_current"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "current")
            get_current_theme
            ;;
        "list")
            list_themes
            ;;
        "apply")
            apply_theme "$2"
            ;;
        "create")
            create_theme "$2"
            ;;
        "delete")
            delete_theme "$2"
            ;;
        "info")
            show_theme_info "$2"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Show Current Theme\nList Themes\nApply Theme\nCreate Theme\nDelete Theme\nShow Theme Information" | wofi --dmenu --prompt "Theme Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Show Current Theme")
                    get_current_theme
                    ;;
                "List Themes")
                    list_themes
                    ;;
                "Apply Theme")
                    theme=$(list_themes | wofi --dmenu --prompt "Select Theme" --style "$HOME/.config/wofi/power-menu.css")
                    apply_theme "$theme"
                    ;;
                "Create Theme")
                    theme=$(wofi --dmenu --prompt "Enter Theme Name" --style "$HOME/.config/wofi/power-menu.css")
                    create_theme "$theme"
                    ;;
                "Delete Theme")
                    theme=$(list_themes | wofi --dmenu --prompt "Select Theme" --style "$HOME/.config/wofi/power-menu.css")
                    delete_theme "$theme"
                    ;;
                "Show Theme Information")
                    theme=$(list_themes | wofi --dmenu --prompt "Select Theme" --style "$HOME/.config/wofi/power-menu.css")
                    show_theme_info "$theme"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 