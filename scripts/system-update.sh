#!/bin/bash

# Anime-themed System Update Script
# --------------------------------
# This script manages system updates with anime-themed notifications

# Configuration
UPDATE_ICON="$HOME/.config/hypr/icons/update.png"
UPDATE_SOUND="$HOME/.config/hypr/sounds/update.wav"
LOG_FILE="$HOME/.config/hypr/logs/update.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to check for updates
check_updates() {
    # Check for updates
    echo "Checking for updates..."
    notify-send "System Update" "Checking for updates..." -i "$UPDATE_ICON"
    
    # Get the number of updates
    local updates=$(yay -Qu | wc -l)
    
    if [ "$updates" -gt 0 ]; then
        notify-send "System Update" "$updates updates available" -i "$UPDATE_ICON"
        echo "$updates updates available"
    else
        notify-send "System Update" "System is up to date" -i "$UPDATE_ICON"
        echo "System is up to date"
    fi
    
    return "$updates"
}

# Function to update the system
update_system() {
    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        notify-send "System Update" "yay is not installed. Please install it to use this script."
        exit 1
    fi
    
    # Check for updates
    local updates=$(yay -Qu | wc -l)
    
    if [ "$updates" -eq 0 ]; then
        notify-send "System Update" "System is already up to date" -i "$UPDATE_ICON"
        echo "System is already up to date"
        return 0
    fi
    
    # Show update notification
    notify-send "System Update" "Updating system... This may take a while." -i "$UPDATE_ICON"
    
    # Log the start of the update
    echo "Starting system update at $(date)" >> "$LOG_FILE"
    
    # Update the system
    yay -Syu --noconfirm
    
    # Check if the update was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$UPDATE_SOUND" &
        
        # Show success notification
        notify-send "System Update" "System update completed successfully!" -i "$UPDATE_ICON"
        
        # Log the success
        echo "System update completed successfully at $(date)" >> "$LOG_FILE"
        
        echo "System update completed successfully"
    else
        # Show error notification
        notify-send "System Update" "System update failed. Check the logs for details." -i "$UPDATE_ICON"
        
        # Log the error
        echo "System update failed at $(date)" >> "$LOG_FILE"
        
        echo "System update failed"
    fi
}

# Function to clean the system
clean_system() {
    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        notify-send "System Update" "yay is not installed. Please install it to use this script."
        exit 1
    fi
    
    # Show cleaning notification
    notify-send "System Update" "Cleaning system... This may take a while." -i "$UPDATE_ICON"
    
    # Log the start of the cleaning
    echo "Starting system cleaning at $(date)" >> "$LOG_FILE"
    
    # Clean the system
    yay -Yc --noconfirm
    
    # Check if the cleaning was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$UPDATE_SOUND" &
        
        # Show success notification
        notify-send "System Update" "System cleaning completed successfully!" -i "$UPDATE_ICON"
        
        # Log the success
        echo "System cleaning completed successfully at $(date)" >> "$LOG_FILE"
        
        echo "System cleaning completed successfully"
    else
        # Show error notification
        notify-send "System Update" "System cleaning failed. Check the logs for details." -i "$UPDATE_ICON"
        
        # Log the error
        echo "System cleaning failed at $(date)" >> "$LOG_FILE"
        
        echo "System cleaning failed"
    fi
}

# Function to show update history
show_update_history() {
    # Check if the log file exists
    if [ ! -f "$LOG_FILE" ]; then
        notify-send "System Update" "No update history found." -i "$UPDATE_ICON"
        echo "No update history found"
        return 0
    fi
    
    # Show the update history
    notify-send "System Update" "Showing update history..." -i "$UPDATE_ICON"
    
    # Display the log file
    cat "$LOG_FILE" | wofi --dmenu --prompt "Update History" --style "$HOME/.config/wofi/power-menu.css"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "check")
            check_updates
            ;;
        "update")
            update_system
            ;;
        "clean")
            clean_system
            ;;
        "history")
            show_update_history
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Check for Updates\nUpdate System\nClean System\nShow Update History" | wofi --dmenu --prompt "System Update" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Check for Updates")
                    check_updates
                    ;;
                "Update System")
                    update_system
                    ;;
                "Clean System")
                    clean_system
                    ;;
                "Show Update History")
                    show_update_history
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 