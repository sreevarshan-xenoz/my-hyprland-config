#!/bin/bash

# Anime-themed Log Manager Script
# ------------------------------
# This script manages system logs with anime-themed notifications

# Configuration
LOG_ICON="$HOME/.config/hypr/icons/log.png"
LOG_DIR="$HOME/.config/hypr/logs"
LOG_VIEWER="wofi --dmenu --prompt \"Log Viewer\" --style \"$HOME/.config/wofi/power-menu.css\""

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to list log files
list_log_files() {
    # Check if the log directory exists
    if [ ! -d "$LOG_DIR" ]; then
        notify-send "Log Manager" "No log files found." -i "$LOG_ICON"
        return
    fi
    
    # List log files
    local log_files=$(ls -1 "$LOG_DIR")
    
    echo "$log_files"
}

# Function to view a log file
view_log_file() {
    # Get the log file name
    local log_file="$1"
    
    # Get the log file path
    local log_path="$LOG_DIR/$log_file"
    
    # Check if the log file exists
    if [ ! -f "$log_path" ]; then
        notify-send "Log Manager" "Log file $log_file does not exist." -i "$LOG_ICON"
        return
    fi
    
    # Show log notification
    notify-send "Log Manager" "Viewing log file $log_file..." -i "$LOG_ICON"
    
    # View the log file
    cat "$log_path" | eval "$LOG_VIEWER"
}

# Function to clear a log file
clear_log_file() {
    # Get the log file name
    local log_file="$1"
    
    # Get the log file path
    local log_path="$LOG_DIR/$log_file"
    
    # Check if the log file exists
    if [ ! -f "$log_path" ]; then
        notify-send "Log Manager" "Log file $log_file does not exist." -i "$LOG_ICON"
        return
    fi
    
    # Show clear notification
    notify-send "Log Manager" "Clearing log file $log_file..." -i "$LOG_ICON"
    
    # Clear the log file
    echo "" > "$log_path"
    
    # Check if the clear was successful
    if [ $? -eq 0 ]; then
        # Show success notification
        notify-send "Log Manager" "Log file $log_file cleared successfully!" -i "$LOG_ICON"
        
        echo "Log file $log_file cleared successfully"
    else
        # Show error notification
        notify-send "Log Manager" "Failed to clear log file $log_file." -i "$LOG_ICON"
        
        echo "Failed to clear log file $log_file"
    fi
}

# Function to delete a log file
delete_log_file() {
    # Get the log file name
    local log_file="$1"
    
    # Get the log file path
    local log_path="$LOG_DIR/$log_file"
    
    # Check if the log file exists
    if [ ! -f "$log_path" ]; then
        notify-send "Log Manager" "Log file $log_file does not exist." -i "$LOG_ICON"
        return
    fi
    
    # Show delete notification
    notify-send "Log Manager" "Deleting log file $log_file..." -i "$LOG_ICON"
    
    # Delete the log file
    rm "$log_path"
    
    # Check if the delete was successful
    if [ $? -eq 0 ]; then
        # Show success notification
        notify-send "Log Manager" "Log file $log_file deleted successfully!" -i "$LOG_ICON"
        
        echo "Log file $log_file deleted successfully"
    else
        # Show error notification
        notify-send "Log Manager" "Failed to delete log file $log_file." -i "$LOG_ICON"
        
        echo "Failed to delete log file $log_file"
    fi
}

# Function to show log file information
show_log_file_info() {
    # Get the log file name
    local log_file="$1"
    
    # Get the log file path
    local log_path="$LOG_DIR/$log_file"
    
    # Check if the log file exists
    if [ ! -f "$log_path" ]; then
        notify-send "Log Manager" "Log file $log_file does not exist." -i "$LOG_ICON"
        return
    fi
    
    # Get log file size
    local size=$(du -h "$log_path" | awk '{print $1}')
    
    # Get log file creation time
    local creation_time=$(stat -c "%y" "$log_path")
    
    # Get log file modification time
    local modification_time=$(stat -c "%y" "$log_path")
    
    # Get log file line count
    local line_count=$(wc -l < "$log_path")
    
    # Show log file information
    notify-send "Log Manager" "Log File: $log_file\nSize: $size\nCreated: $creation_time\nModified: $modification_time\nLines: $line_count" -i "$LOG_ICON"
    
    # Return the values for display
    echo "Log File: $log_file | Size: $size | Created: $creation_time | Modified: $modification_time | Lines: $line_count"
}

# Function to search log files
search_log_files() {
    # Get the search term
    local search_term="$1"
    
    # Check if the search term is empty
    if [ -z "$search_term" ]; then
        notify-send "Log Manager" "Search term cannot be empty." -i "$LOG_ICON"
        return
    fi
    
    # Show search notification
    notify-send "Log Manager" "Searching for \"$search_term\" in log files..." -i "$LOG_ICON"
    
    # Search the log files
    local results=$(grep -r "$search_term" "$LOG_DIR")
    
    # Check if any results were found
    if [ -z "$results" ]; then
        notify-send "Log Manager" "No results found for \"$search_term\"." -i "$LOG_ICON"
        return
    fi
    
    # Show the results
    echo "$results" | eval "$LOG_VIEWER"
}

# Function to monitor a log file
monitor_log_file() {
    # Get the log file name
    local log_file="$1"
    
    # Get the log file path
    local log_path="$LOG_DIR/$log_file"
    
    # Check if the log file exists
    if [ ! -f "$log_path" ]; then
        notify-send "Log Manager" "Log file $log_file does not exist." -i "$LOG_ICON"
        return
    fi
    
    # Show monitor notification
    notify-send "Log Manager" "Monitoring log file $log_file..." -i "$LOG_ICON"
    
    # Monitor the log file
    tail -f "$log_path" | eval "$LOG_VIEWER"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "list")
            list_log_files
            ;;
        "view")
            view_log_file "$2"
            ;;
        "clear")
            clear_log_file "$2"
            ;;
        "delete")
            delete_log_file "$2"
            ;;
        "info")
            show_log_file_info "$2"
            ;;
        "search")
            search_log_files "$2"
            ;;
        "monitor")
            monitor_log_file "$2"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "List Log Files\nView Log File\nClear Log File\nDelete Log File\nShow Log File Information\nSearch Log Files\nMonitor Log File" | wofi --dmenu --prompt "Log Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "List Log Files")
                    list_log_files
                    ;;
                "View Log File")
                    log_file=$(list_log_files | wofi --dmenu --prompt "Select Log File" --style "$HOME/.config/wofi/power-menu.css")
                    view_log_file "$log_file"
                    ;;
                "Clear Log File")
                    log_file=$(list_log_files | wofi --dmenu --prompt "Select Log File" --style "$HOME/.config/wofi/power-menu.css")
                    clear_log_file "$log_file"
                    ;;
                "Delete Log File")
                    log_file=$(list_log_files | wofi --dmenu --prompt "Select Log File" --style "$HOME/.config/wofi/power-menu.css")
                    delete_log_file "$log_file"
                    ;;
                "Show Log File Information")
                    log_file=$(list_log_files | wofi --dmenu --prompt "Select Log File" --style "$HOME/.config/wofi/power-menu.css")
                    show_log_file_info "$log_file"
                    ;;
                "Search Log Files")
                    search_term=$(wofi --dmenu --prompt "Enter Search Term" --style "$HOME/.config/wofi/power-menu.css")
                    search_log_files "$search_term"
                    ;;
                "Monitor Log File")
                    log_file=$(list_log_files | wofi --dmenu --prompt "Select Log File" --style "$HOME/.config/wofi/power-menu.css")
                    monitor_log_file "$log_file"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 