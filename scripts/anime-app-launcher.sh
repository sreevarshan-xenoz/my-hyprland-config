#!/bin/bash

# Anime-themed App Launcher Script
# -------------------------------
# This script provides a beautiful and customizable app launcher with anime-themed visuals and sound effects

# Configuration
ICON_DIR="$HOME/.config/hypr/icons"
SOUND_DIR="$HOME/.config/hypr/sounds"
MENU_SOUND="$SOUND_DIR/menu.wav"
SELECT_SOUND="$SOUND_DIR/select.wav"
LAUNCH_SOUND="$SOUND_DIR/launch.wav"
CANCEL_SOUND="$SOUND_DIR/cancel.wav"
APP_CATEGORIES=("All" "Games" "Internet" "Multimedia" "Office" "System" "Utilities" "Development" "Graphics" "Education" "Anime")
FAVORITE_APPS_FILE="$HOME/.config/hypr/favorite-apps.txt"
RECENT_APPS_FILE="$HOME/.config/hypr/recent-apps.txt"
MAX_RECENT_APPS=10
APP_CACHE_FILE="/tmp/app-cache.txt"
APP_CACHE_EXPIRATION=3600

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to disable visual effects (reduces resource usage)
DISABLE_VISUAL_EFFECTS=false
# Set to true to use simpler launcher (reduces resource usage)
USE_SIMPLE_LAUNCHER=true
# Set to true to disable app caching (reduces resource usage)
DISABLE_CACHING=false

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
    
    # Check for gtk-launch
    if ! command -v gtk-launch &> /dev/null; then
        missing_deps+=("gtk-launch")
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Anime App Launcher" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$ICON_DIR/app.png"
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
        DISABLE_VISUAL_EFFECTS=true
        USE_SIMPLE_LAUNCHER=true
        DISABLE_CACHING=false
    fi
}

# Function to get all applications
get_all_applications() {
    # Check if caching is enabled and cache is valid
    if [ "$DISABLE_CACHING" = false ] && [ -f "$APP_CACHE_FILE" ]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$APP_CACHE_FILE" 2>/dev/null || echo 0)))
        if [ "$cache_age" -lt "$APP_CACHE_EXPIRATION" ]; then
            # Use cached applications
            cat "$APP_CACHE_FILE"
            return
        fi
    fi
    
    # Get all applications
    local applications=""
    
    # Get applications from /usr/share/applications
    if [ -d "/usr/share/applications" ]; then
        applications+=$(find /usr/share/applications -name "*.desktop" -type f -exec grep -l "Exec=" {} \; | xargs grep -l "Name=" | xargs grep -l "Categories=" | xargs grep -l "NoDisplay=false" 2>/dev/null || echo "")
    fi
    
    # Get applications from ~/.local/share/applications
    if [ -d "$HOME/.local/share/applications" ]; then
        applications+=$(find "$HOME/.local/share/applications" -name "*.desktop" -type f -exec grep -l "Exec=" {} \; | xargs grep -l "Name=" | xargs grep -l "Categories=" | xargs grep -l "NoDisplay=false" 2>/dev/null || echo "")
    fi
    
    # Get application names
    local app_names=""
    for app in $applications; do
        local name=$(grep -m 1 "Name=" "$app" | cut -d= -f2)
        local exec=$(grep -m 1 "Exec=" "$app" | cut -d= -f2 | cut -d' ' -f1)
        local icon=$(grep -m 1 "Icon=" "$app" | cut -d= -f2)
        local categories=$(grep -m 1 "Categories=" "$app" | cut -d= -f2)
        
        # Skip if name or exec is empty
        if [ -z "$name" ] || [ -z "$exec" ]; then
            continue
        fi
        
        # Add to app names
        app_names+="$name|$exec|$icon|$categories\n"
    done
    
    # Sort app names
    app_names=$(echo -e "$app_names" | sort)
    
    # Cache applications if caching is enabled
    if [ "$DISABLE_CACHING" = false ]; then
        echo -e "$app_names" > "$APP_CACHE_FILE"
    fi
    
    # Return app names
    echo -e "$app_names"
}

# Function to get applications by category
get_applications_by_category() {
    local category="$1"
    
    # Get all applications
    local all_apps=$(get_all_applications)
    
    # Filter applications by category
    if [ "$category" = "All" ]; then
        echo -e "$all_apps"
    else
        echo -e "$all_apps" | grep -i "|.*|.*|.*$category"
    fi
}

# Function to get favorite applications
get_favorite_applications() {
    # Check if favorite apps file exists
    if [ ! -f "$FAVORITE_APPS_FILE" ]; then
        # Create favorite apps file
        touch "$FAVORITE_APPS_FILE"
    fi
    
    # Get favorite apps
    local favorite_apps=""
    while IFS= read -r app; do
        # Skip empty lines
        if [ -z "$app" ]; then
            continue
        fi
        
        # Get app details
        local app_details=$(get_all_applications | grep -i "^$app|")
        
        # Add to favorite apps
        if [ -n "$app_details" ]; then
            favorite_apps+="$app_details\n"
        fi
    done < "$FAVORITE_APPS_FILE"
    
    # Return favorite apps
    echo -e "$favorite_apps"
}

# Function to get recent applications
get_recent_applications() {
    # Check if recent apps file exists
    if [ ! -f "$RECENT_APPS_FILE" ]; then
        # Create recent apps file
        touch "$RECENT_APPS_FILE"
    fi
    
    # Get recent apps
    local recent_apps=""
    while IFS= read -r app; do
        # Skip empty lines
        if [ -z "$app" ]; then
            continue
        fi
        
        # Get app details
        local app_details=$(get_all_applications | grep -i "^$app|")
        
        # Add to recent apps
        if [ -n "$app_details" ]; then
            recent_apps+="$app_details\n"
        fi
    done < "$RECENT_APPS_FILE"
    
    # Return recent apps
    echo -e "$recent_apps"
}

# Function to add application to favorites
add_to_favorites() {
    local app_name="$1"
    
    # Check if app name is empty
    if [ -z "$app_name" ]; then
        return
    fi
    
    # Check if app is already in favorites
    if grep -q "^$app_name$" "$FAVORITE_APPS_FILE"; then
        return
    fi
    
    # Add app to favorites
    echo "$app_name" >> "$FAVORITE_APPS_FILE"
}

# Function to remove application from favorites
remove_from_favorites() {
    local app_name="$1"
    
    # Check if app name is empty
    if [ -z "$app_name" ]; then
        return
    fi
    
    # Check if app is in favorites
    if ! grep -q "^$app_name$" "$FAVORITE_APPS_FILE"; then
        return
    fi
    
    # Remove app from favorites
    sed -i "/^$app_name$/d" "$FAVORITE_APPS_FILE"
}

# Function to add application to recent
add_to_recent() {
    local app_name="$1"
    
    # Check if app name is empty
    if [ -z "$app_name" ]; then
        return
    fi
    
    # Remove app from recent if it exists
    sed -i "/^$app_name$/d" "$RECENT_APPS_FILE"
    
    # Add app to recent
    echo "$app_name" >> "$RECENT_APPS_FILE"
    
    # Trim recent apps if needed
    local line_count=$(wc -l < "$RECENT_APPS_FILE")
    if [ "$line_count" -gt "$MAX_RECENT_APPS" ]; then
        tail -n "$MAX_RECENT_APPS" "$RECENT_APPS_FILE" > "$RECENT_APPS_FILE.tmp"
        mv "$RECENT_APPS_FILE.tmp" "$RECENT_APPS_FILE"
    fi
}

# Function to launch application
launch_application() {
    local app_name="$1"
    local app_exec="$2"
    
    # Check if app name or exec is empty
    if [ -z "$app_name" ] || [ -z "$app_exec" ]; then
        return
    fi
    
    # Add app to recent
    add_to_recent "$app_name"
    
    # Play launch sound
    play_sound "$LAUNCH_SOUND"
    
    # Show notification
    send_notification "Launching" "$app_name" -i "$ICON_DIR/app.png"
    
    # Launch application
    gtk-launch "$app_name" &
}

# Function to show app launcher
show_app_launcher() {
    # Play menu sound
    play_sound "$MENU_SOUND"
    
    # Show app launcher
    if [ "$USE_SIMPLE_LAUNCHER" = true ]; then
        # Simple app launcher
        local app_name=$(get_all_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application" --style "$HOME/.config/wofi/power-menu.css")
        
        # Check if an app was selected
        if [ -n "$app_name" ]; then
            # Get app exec
            local app_exec=$(get_all_applications | grep -i "^$app_name|" | cut -d'|' -f2)
            
            # Launch application
            launch_application "$app_name" "$app_exec"
        else
            # Play cancel sound
            play_sound "$CANCEL_SOUND"
            
            # Show notification
            send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
        fi
    else
        # Advanced app launcher
        local choice=$(echo -e "All Applications\nFavorite Applications\nRecent Applications\nBy Category\nSearch Applications\nCancel" | wofi --dmenu --prompt "App Launcher" --style "$HOME/.config/wofi/power-menu.css")
        
        # Check if a choice was made
        if [ -n "$choice" ]; then
            # Play select sound
            play_sound "$SELECT_SOUND"
            
            # Handle choice
            case "$choice" in
                "All Applications")
                    # Get all applications
                    local app_name=$(get_all_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application" --style "$HOME/.config/wofi/power-menu.css")
                    
                    # Check if an app was selected
                    if [ -n "$app_name" ]; then
                        # Get app exec
                        local app_exec=$(get_all_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                        
                        # Launch application
                        launch_application "$app_name" "$app_exec"
                    else
                        # Play cancel sound
                        play_sound "$CANCEL_SOUND"
                        
                        # Show notification
                        send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                    fi
                    ;;
                "Favorite Applications")
                    # Get favorite applications
                    local app_name=$(get_favorite_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application" --style "$HOME/.config/wofi/power-menu.css")
                    
                    # Check if an app was selected
                    if [ -n "$app_name" ]; then
                        # Get app exec
                        local app_exec=$(get_favorite_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                        
                        # Launch application
                        launch_application "$app_name" "$app_exec"
                    else
                        # Play cancel sound
                        play_sound "$CANCEL_SOUND"
                        
                        # Show notification
                        send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                    fi
                    ;;
                "Recent Applications")
                    # Get recent applications
                    local app_name=$(get_recent_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application" --style "$HOME/.config/wofi/power-menu.css")
                    
                    # Check if an app was selected
                    if [ -n "$app_name" ]; then
                        # Get app exec
                        local app_exec=$(get_recent_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                        
                        # Launch application
                        launch_application "$app_name" "$app_exec"
                    else
                        # Play cancel sound
                        play_sound "$CANCEL_SOUND"
                        
                        # Show notification
                        send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                    fi
                    ;;
                "By Category")
                    # Show category selection
                    local category=$(printf "%s\n" "${APP_CATEGORIES[@]}" | wofi --dmenu --prompt "Select Category" --style "$HOME/.config/wofi/power-menu.css")
                    
                    # Check if a category was selected
                    if [ -n "$category" ]; then
                        # Get applications by category
                        local app_name=$(get_applications_by_category "$category" | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application" --style "$HOME/.config/wofi/power-menu.css")
                        
                        # Check if an app was selected
                        if [ -n "$app_name" ]; then
                            # Get app exec
                            local app_exec=$(get_applications_by_category "$category" | grep -i "^$app_name|" | cut -d'|' -f2)
                            
                            # Launch application
                            launch_application "$app_name" "$app_exec"
                        else
                            # Play cancel sound
                            play_sound "$CANCEL_SOUND"
                            
                            # Show notification
                            send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                        fi
                    else
                        # Play cancel sound
                        play_sound "$CANCEL_SOUND"
                        
                        # Show notification
                        send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                    fi
                    ;;
                "Search Applications")
                    # Show search dialog
                    local search_term=$(echo "" | wofi --dmenu --prompt "Search Applications" --style "$HOME/.config/wofi/power-menu.css")
                    
                    # Check if a search term was entered
                    if [ -n "$search_term" ]; then
                        # Search applications
                        local app_name=$(get_all_applications | grep -i "$search_term" | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application" --style "$HOME/.config/wofi/power-menu.css")
                        
                        # Check if an app was selected
                        if [ -n "$app_name" ]; then
                            # Get app exec
                            local app_exec=$(get_all_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                            
                            # Launch application
                            launch_application "$app_name" "$app_exec"
                        else
                            # Play cancel sound
                            play_sound "$CANCEL_SOUND"
                            
                            # Show notification
                            send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                        fi
                    else
                        # Play cancel sound
                        play_sound "$CANCEL_SOUND"
                        
                        # Show notification
                        send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                    fi
                    ;;
                "Cancel")
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
                    ;;
            esac
        else
            # Play cancel sound
            play_sound "$CANCEL_SOUND"
            
            # Show notification
            send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
        fi
    fi
}

# Function to show anime-themed app launcher
show_anime_app_launcher() {
    # Play menu sound
    play_sound "$MENU_SOUND"
    
    # Show anime-themed app launcher
    local choice=$(echo -e "All Applications (すべてのアプリケーション)\nFavorite Applications (お気に入りのアプリケーション)\nRecent Applications (最近のアプリケーション)\nBy Category (カテゴリ別)\nSearch Applications (アプリケーションを検索)\nCancel (キャンセル)" | wofi --dmenu --prompt "Anime App Launcher" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if a choice was made
    if [ -n "$choice" ]; then
        # Play select sound
        play_sound "$SELECT_SOUND"
        
        # Handle choice
        case "$choice" in
            "All Applications (すべてのアプリケーション)")
                # Get all applications
                local app_name=$(get_all_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application (アプリケーションを起動)" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if an app was selected
                if [ -n "$app_name" ]; then
                    # Get app exec
                    local app_exec=$(get_all_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                    
                    # Launch application
                    launch_application "$app_name" "$app_exec"
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                fi
                ;;
            "Favorite Applications (お気に入りのアプリケーション)")
                # Get favorite applications
                local app_name=$(get_favorite_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application (アプリケーションを起動)" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if an app was selected
                if [ -n "$app_name" ]; then
                    # Get app exec
                    local app_exec=$(get_favorite_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                    
                    # Launch application
                    launch_application "$app_name" "$app_exec"
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                fi
                ;;
            "Recent Applications (最近のアプリケーション)")
                # Get recent applications
                local app_name=$(get_recent_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application (アプリケーションを起動)" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if an app was selected
                if [ -n "$app_name" ]; then
                    # Get app exec
                    local app_exec=$(get_recent_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                    
                    # Launch application
                    launch_application "$app_name" "$app_exec"
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                fi
                ;;
            "By Category (カテゴリ別)")
                # Show category selection
                local category=$(printf "%s\n" "${APP_CATEGORIES[@]}" | wofi --dmenu --prompt "Select Category (カテゴリを選択)" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if a category was selected
                if [ -n "$category" ]; then
                    # Get applications by category
                    local app_name=$(get_applications_by_category "$category" | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application (アプリケーションを起動)" --style "$HOME/.config/wofi/power-menu.css")
                    
                    # Check if an app was selected
                    if [ -n "$app_name" ]; then
                        # Get app exec
                        local app_exec=$(get_applications_by_category "$category" | grep -i "^$app_name|" | cut -d'|' -f2)
                        
                        # Launch application
                        launch_application "$app_name" "$app_exec"
                    else
                        # Play cancel sound
                        play_sound "$CANCEL_SOUND"
                        
                        # Show notification
                        send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                    fi
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                fi
                ;;
            "Search Applications (アプリケーションを検索)")
                # Show search dialog
                local search_term=$(echo "" | wofi --dmenu --prompt "Search Applications (アプリケーションを検索)" --style "$HOME/.config/wofi/power-menu.css")
                
                # Check if a search term was entered
                if [ -n "$search_term" ]; then
                    # Search applications
                    local app_name=$(get_all_applications | grep -i "$search_term" | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application (アプリケーションを起動)" --style "$HOME/.config/wofi/power-menu.css")
                    
                    # Check if an app was selected
                    if [ -n "$app_name" ]; then
                        # Get app exec
                        local app_exec=$(get_all_applications | grep -i "^$app_name|" | cut -d'|' -f2)
                        
                        # Launch application
                        launch_application "$app_name" "$app_exec"
                    else
                        # Play cancel sound
                        play_sound "$CANCEL_SOUND"
                        
                        # Show notification
                        send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                    fi
                else
                    # Play cancel sound
                    play_sound "$CANCEL_SOUND"
                    
                    # Show notification
                    send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                fi
                ;;
            "Cancel (キャンセル)")
                # Play cancel sound
                play_sound "$CANCEL_SOUND"
                
                # Show notification
                send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
                ;;
        esac
    else
        # Play cancel sound
        play_sound "$CANCEL_SOUND"
        
        # Show notification
        send_notification "App Launcher" "Cancelled (キャンセル)" -i "$ICON_DIR/app.png"
    fi
}

# Function to show simple app launcher
show_simple_app_launcher() {
    # Show simple app launcher
    local app_name=$(get_all_applications | cut -d'|' -f1 | wofi --dmenu --prompt "Launch Application" --style "$HOME/.config/wofi/power-menu.css")
    
    # Check if an app was selected
    if [ -n "$app_name" ]; then
        # Get app exec
        local app_exec=$(get_all_applications | grep -i "^$app_name|" | cut -d'|' -f2)
        
        # Launch application
        launch_application "$app_name" "$app_exec"
    else
        # Show notification
        send_notification "App Launcher" "Cancelled" -i "$ICON_DIR/app.png"
    fi
}

# Function to show menu
show_menu() {
    # Show menu
    choice=$(echo -e "Standard App Launcher\nAnime-themed App Launcher\nSimple App Launcher\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "App Launcher" --style "$HOME/.config/wofi/power-menu.css")
    
    case "$choice" in
        "Standard App Launcher")
            show_app_launcher
            ;;
        "Anime-themed App Launcher")
            show_anime_app_launcher
            ;;
        "Simple App Launcher")
            show_simple_app_launcher
            ;;
        "Enable Low-End Mode")
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=true
            USE_SIMPLE_LAUNCHER=true
            DISABLE_CACHING=false
            send_notification "App Launcher" "Low-end mode enabled" -i "$ICON_DIR/app.png"
            ;;
        "Enable High-End Mode")
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=false
            USE_SIMPLE_LAUNCHER=false
            DISABLE_CACHING=false
            send_notification "App Launcher" "High-end mode enabled" -i "$ICON_DIR/app.png"
            ;;
    esac
}

# Main function
main() {
    # Check dependencies
    check_dependencies
    
    # Detect system capabilities
    detect_system_capabilities
    
    # Check the argument
    case "$1" in
        "standard")
            # Show standard app launcher
            show_app_launcher
            ;;
        "anime")
            # Show anime-themed app launcher
            show_anime_app_launcher
            ;;
        "simple")
            # Show simple app launcher
            show_simple_app_launcher
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=true
            USE_SIMPLE_LAUNCHER=true
            DISABLE_CACHING=false
            send_notification "App Launcher" "Low-end mode enabled" -i "$ICON_DIR/app.png"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            DISABLE_VISUAL_EFFECTS=false
            USE_SIMPLE_LAUNCHER=false
            DISABLE_CACHING=false
            send_notification "App Launcher" "High-end mode enabled" -i "$ICON_DIR/app.png"
            ;;
        *)
            # Show menu
            show_menu
            ;;
    esac
}

# Run the main function
main "$@" 