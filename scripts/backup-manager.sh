#!/bin/bash

# Anime-themed Backup Manager Script
# ---------------------------------
# This script manages system backups with anime-themed notifications

# Configuration
BACKUP_ICON="$HOME/.config/hypr/icons/backup.png"
BACKUP_START_SOUND="$HOME/.config/hypr/sounds/backup-start.wav"
BACKUP_END_SOUND="$HOME/.config/hypr/sounds/backup-end.wav"
BACKUP_ERROR_SOUND="$HOME/.config/hypr/sounds/backup-error.wav"
BACKUP_DIR="$HOME/.config/hypr/backups"
LOG_FILE="$HOME/.config/hypr/logs/backup.log"

# Create backup and log directories if they don't exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Function to check if rsync is installed
check_rsync() {
    if ! command -v rsync &> /dev/null; then
        notify-send "Backup Manager" "rsync is not installed. Please install it to use this script." -i "$BACKUP_ICON"
        exit 1
    fi
}

# Function to create a backup
create_backup() {
    # Check if rsync is installed
    check_rsync
    
    # Get the source directory
    local source="$1"
    
    # Get the backup name
    local backup_name="$2"
    
    # Create the backup directory
    local backup_path="$BACKUP_DIR/$backup_name"
    mkdir -p "$backup_path"
    
    # Show backup notification
    notify-send "Backup Manager" "Creating backup of $source..." -i "$BACKUP_ICON"
    
    # Play a sound effect
    paplay "$BACKUP_START_SOUND" &
    
    # Log the start of the backup
    echo "Starting backup of $source to $backup_path at $(date)" >> "$LOG_FILE"
    
    # Create the backup
    rsync -av --delete "$source" "$backup_path"
    
    # Check if the backup was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$BACKUP_END_SOUND" &
        
        # Show success notification
        notify-send "Backup Manager" "Backup of $source completed successfully!" -i "$BACKUP_ICON"
        
        # Log the success
        echo "Backup of $source completed successfully at $(date)" >> "$LOG_FILE"
        
        echo "Backup of $source completed successfully"
    else
        # Play a sound effect
        paplay "$BACKUP_ERROR_SOUND" &
        
        # Show error notification
        notify-send "Backup Manager" "Backup of $source failed. Check the logs for details." -i "$BACKUP_ICON"
        
        # Log the error
        echo "Backup of $source failed at $(date)" >> "$LOG_FILE"
        
        echo "Backup of $source failed"
    fi
}

# Function to restore a backup
restore_backup() {
    # Check if rsync is installed
    check_rsync
    
    # Get the backup name
    local backup_name="$1"
    
    # Get the destination directory
    local destination="$2"
    
    # Get the backup path
    local backup_path="$BACKUP_DIR/$backup_name"
    
    # Check if the backup exists
    if [ ! -d "$backup_path" ]; then
        notify-send "Backup Manager" "Backup $backup_name does not exist." -i "$BACKUP_ICON"
        return
    fi
    
    # Show restore notification
    notify-send "Backup Manager" "Restoring backup $backup_name to $destination..." -i "$BACKUP_ICON"
    
    # Play a sound effect
    paplay "$BACKUP_START_SOUND" &
    
    # Log the start of the restore
    echo "Starting restore of $backup_name to $destination at $(date)" >> "$LOG_FILE"
    
    # Restore the backup
    rsync -av --delete "$backup_path" "$destination"
    
    # Check if the restore was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$BACKUP_END_SOUND" &
        
        # Show success notification
        notify-send "Backup Manager" "Restore of $backup_name completed successfully!" -i "$BACKUP_ICON"
        
        # Log the success
        echo "Restore of $backup_name completed successfully at $(date)" >> "$LOG_FILE"
        
        echo "Restore of $backup_name completed successfully"
    else
        # Play a sound effect
        paplay "$BACKUP_ERROR_SOUND" &
        
        # Show error notification
        notify-send "Backup Manager" "Restore of $backup_name failed. Check the logs for details." -i "$BACKUP_ICON"
        
        # Log the error
        echo "Restore of $backup_name failed at $(date)" >> "$LOG_FILE"
        
        echo "Restore of $backup_name failed"
    fi
}

# Function to list backups
list_backups() {
    # Check if the backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        notify-send "Backup Manager" "No backups found." -i "$BACKUP_ICON"
        return
    fi
    
    # List backups
    local backups=$(ls -1 "$BACKUP_DIR")
    
    echo "$backups"
}

# Function to delete a backup
delete_backup() {
    # Get the backup name
    local backup_name="$1"
    
    # Get the backup path
    local backup_path="$BACKUP_DIR/$backup_name"
    
    # Check if the backup exists
    if [ ! -d "$backup_path" ]; then
        notify-send "Backup Manager" "Backup $backup_name does not exist." -i "$BACKUP_ICON"
        return
    fi
    
    # Show delete notification
    notify-send "Backup Manager" "Deleting backup $backup_name..." -i "$BACKUP_ICON"
    
    # Delete the backup
    rm -rf "$backup_path"
    
    # Check if the delete was successful
    if [ $? -eq 0 ]; then
        # Show success notification
        notify-send "Backup Manager" "Backup $backup_name deleted successfully!" -i "$BACKUP_ICON"
        
        # Log the success
        echo "Backup $backup_name deleted successfully at $(date)" >> "$LOG_FILE"
        
        echo "Backup $backup_name deleted successfully"
    else
        # Show error notification
        notify-send "Backup Manager" "Failed to delete backup $backup_name." -i "$BACKUP_ICON"
        
        # Log the error
        echo "Failed to delete backup $backup_name at $(date)" >> "$LOG_FILE"
        
        echo "Failed to delete backup $backup_name"
    fi
}

# Function to show backup information
show_backup_info() {
    # Get the backup name
    local backup_name="$1"
    
    # Get the backup path
    local backup_path="$BACKUP_DIR/$backup_name"
    
    # Check if the backup exists
    if [ ! -d "$backup_path" ]; then
        notify-send "Backup Manager" "Backup $backup_name does not exist." -i "$BACKUP_ICON"
        return
    fi
    
    # Get backup size
    local size=$(du -sh "$backup_path" | awk '{print $1}')
    
    # Get backup creation time
    local creation_time=$(stat -c "%y" "$backup_path")
    
    # Show backup information
    notify-send "Backup Manager" "Backup: $backup_name\nSize: $size\nCreated: $creation_time" -i "$BACKUP_ICON"
    
    # Return the values for display
    echo "Backup: $backup_name | Size: $size | Created: $creation_time"
}

# Function to show backup logs
show_backup_logs() {
    # Check if the log file exists
    if [ ! -f "$LOG_FILE" ]; then
        notify-send "Backup Manager" "No backup logs found." -i "$BACKUP_ICON"
        return
    fi
    
    # Show the backup logs
    notify-send "Backup Manager" "Showing backup logs..." -i "$BACKUP_ICON"
    
    # Display the log file
    cat "$LOG_FILE" | wofi --dmenu --prompt "Backup Logs" --style "$HOME/.config/wofi/power-menu.css"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "create")
            create_backup "$2" "$3"
            ;;
        "restore")
            restore_backup "$2" "$3"
            ;;
        "list")
            list_backups
            ;;
        "delete")
            delete_backup "$2"
            ;;
        "info")
            show_backup_info "$2"
            ;;
        "logs")
            show_backup_logs
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Create Backup\nRestore Backup\nList Backups\nDelete Backup\nShow Backup Information\nShow Backup Logs" | wofi --dmenu --prompt "Backup Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Create Backup")
                    source=$(wofi --dmenu --prompt "Enter Source Directory" --style "$HOME/.config/wofi/power-menu.css")
                    backup_name=$(wofi --dmenu --prompt "Enter Backup Name" --style "$HOME/.config/wofi/power-menu.css")
                    create_backup "$source" "$backup_name"
                    ;;
                "Restore Backup")
                    backup_name=$(list_backups | wofi --dmenu --prompt "Select Backup" --style "$HOME/.config/wofi/power-menu.css")
                    destination=$(wofi --dmenu --prompt "Enter Destination Directory" --style "$HOME/.config/wofi/power-menu.css")
                    restore_backup "$backup_name" "$destination"
                    ;;
                "List Backups")
                    list_backups
                    ;;
                "Delete Backup")
                    backup_name=$(list_backups | wofi --dmenu --prompt "Select Backup" --style "$HOME/.config/wofi/power-menu.css")
                    delete_backup "$backup_name"
                    ;;
                "Show Backup Information")
                    backup_name=$(list_backups | wofi --dmenu --prompt "Select Backup" --style "$HOME/.config/wofi/power-menu.css")
                    show_backup_info "$backup_name"
                    ;;
                "Show Backup Logs")
                    show_backup_logs
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 