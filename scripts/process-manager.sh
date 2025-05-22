#!/bin/bash

# Anime-themed Process Manager Script
# ----------------------------------
# This script manages system processes with anime-themed notifications

# Configuration
PROCESS_ICON="$HOME/.config/hypr/icons/process.png"
PROCESS_KILL_SOUND="$HOME/.config/hypr/sounds/process-kill.wav"
PROCESS_START_SOUND="$HOME/.config/hypr/sounds/process-start.wav"
PROCESS_RESTART_SOUND="$HOME/.config/hypr/sounds/process-restart.wav"

# Function to list processes
list_processes() {
    # List processes
    local processes=$(ps aux | grep -v grep | grep -v "ps aux" | awk '{print $2, $11, $3, $4}')
    
    echo "$processes"
}

# Function to kill a process
kill_process() {
    # Get the process ID
    local pid="$1"
    
    # Check if the process ID is empty
    if [ -z "$pid" ]; then
        notify-send "Process Manager" "Process ID cannot be empty." -i "$PROCESS_ICON"
        return
    fi
    
    # Show kill notification
    notify-send "Process Manager" "Killing process $pid..." -i "$PROCESS_ICON"
    
    # Kill the process
    kill "$pid"
    
    # Check if the kill was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$PROCESS_KILL_SOUND" &
        
        # Show success notification
        notify-send "Process Manager" "Process $pid killed successfully!" -i "$PROCESS_ICON"
        
        echo "Process $pid killed successfully"
    else
        # Show error notification
        notify-send "Process Manager" "Failed to kill process $pid." -i "$PROCESS_ICON"
        
        echo "Failed to kill process $pid"
    fi
}

# Function to force kill a process
force_kill_process() {
    # Get the process ID
    local pid="$1"
    
    # Check if the process ID is empty
    if [ -z "$pid" ]; then
        notify-send "Process Manager" "Process ID cannot be empty." -i "$PROCESS_ICON"
        return
    fi
    
    # Show force kill notification
    notify-send "Process Manager" "Force killing process $pid..." -i "$PROCESS_ICON"
    
    # Force kill the process
    kill -9 "$pid"
    
    # Check if the force kill was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$PROCESS_KILL_SOUND" &
        
        # Show success notification
        notify-send "Process Manager" "Process $pid force killed successfully!" -i "$PROCESS_ICON"
        
        echo "Process $pid force killed successfully"
    else
        # Show error notification
        notify-send "Process Manager" "Failed to force kill process $pid." -i "$PROCESS_ICON"
        
        echo "Failed to force kill process $pid"
    fi
}

# Function to start a process
start_process() {
    # Get the process command
    local command="$1"
    
    # Check if the command is empty
    if [ -z "$command" ]; then
        notify-send "Process Manager" "Command cannot be empty." -i "$PROCESS_ICON"
        return
    fi
    
    # Show start notification
    notify-send "Process Manager" "Starting process $command..." -i "$PROCESS_ICON"
    
    # Start the process
    $command &
    
    # Check if the start was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$PROCESS_START_SOUND" &
        
        # Show success notification
        notify-send "Process Manager" "Process $command started successfully!" -i "$PROCESS_ICON"
        
        echo "Process $command started successfully"
    else
        # Show error notification
        notify-send "Process Manager" "Failed to start process $command." -i "$PROCESS_ICON"
        
        echo "Failed to start process $command"
    fi
}

# Function to restart a process
restart_process() {
    # Get the process ID
    local pid="$1"
    
    # Check if the process ID is empty
    if [ -z "$pid" ]; then
        notify-send "Process Manager" "Process ID cannot be empty." -i "$PROCESS_ICON"
        return
    fi
    
    # Get the process command
    local command=$(ps -p "$pid" -o command=)
    
    # Show restart notification
    notify-send "Process Manager" "Restarting process $pid..." -i "$PROCESS_ICON"
    
    # Kill the process
    kill "$pid"
    
    # Check if the kill was successful
    if [ $? -eq 0 ]; then
        # Wait for the process to die
        sleep 1
        
        # Start the process
        $command &
        
        # Check if the start was successful
        if [ $? -eq 0 ]; then
            # Play a sound effect
            paplay "$PROCESS_RESTART_SOUND" &
            
            # Show success notification
            notify-send "Process Manager" "Process $pid restarted successfully!" -i "$PROCESS_ICON"
            
            echo "Process $pid restarted successfully"
        else
            # Show error notification
            notify-send "Process Manager" "Failed to restart process $pid." -i "$PROCESS_ICON"
            
            echo "Failed to restart process $pid"
        fi
    else
        # Show error notification
        notify-send "Process Manager" "Failed to kill process $pid." -i "$PROCESS_ICON"
        
        echo "Failed to kill process $pid"
    fi
}

# Function to show process information
show_process_info() {
    # Get the process ID
    local pid="$1"
    
    # Check if the process ID is empty
    if [ -z "$pid" ]; then
        notify-send "Process Manager" "Process ID cannot be empty." -i "$PROCESS_ICON"
        return
    fi
    
    # Get process information
    local info=$(ps -p "$pid" -o pid,ppid,user,%cpu,%mem,vsz,rss,stat,start,time,command)
    
    # Show process information
    notify-send "Process Manager" "Process Information:\n$info" -i "$PROCESS_ICON"
    
    # Return the values for display
    echo "$info"
}

# Function to search processes
search_processes() {
    # Get the search term
    local search_term="$1"
    
    # Check if the search term is empty
    if [ -z "$search_term" ]; then
        notify-send "Process Manager" "Search term cannot be empty." -i "$PROCESS_ICON"
        return
    fi
    
    # Show search notification
    notify-send "Process Manager" "Searching for \"$search_term\" in processes..." -i "$PROCESS_ICON"
    
    # Search the processes
    local results=$(ps aux | grep "$search_term" | grep -v grep | grep -v "ps aux" | awk '{print $2, $11, $3, $4}')
    
    # Check if any results were found
    if [ -z "$results" ]; then
        notify-send "Process Manager" "No results found for \"$search_term\"." -i "$PROCESS_ICON"
        return
    fi
    
    # Show the results
    echo "$results" | wofi --dmenu --prompt "Process Search Results" --style "$HOME/.config/wofi/power-menu.css"
}

# Function to show top processes
show_top_processes() {
    # Show top processes
    local top_processes=$(ps aux --sort=-%cpu | head -n 6)
    
    # Show top processes
    notify-send "Process Manager" "Top Processes:\n$top_processes" -i "$PROCESS_ICON"
    
    # Return the values for display
    echo "$top_processes"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "list")
            list_processes
            ;;
        "kill")
            kill_process "$2"
            ;;
        "force-kill")
            force_kill_process "$2"
            ;;
        "start")
            start_process "$2"
            ;;
        "restart")
            restart_process "$2"
            ;;
        "info")
            show_process_info "$2"
            ;;
        "search")
            search_processes "$2"
            ;;
        "top")
            show_top_processes
            ;;
        *)
            # Show a menu
            choice=$(echo -e "List Processes\nKill Process\nForce Kill Process\nStart Process\nRestart Process\nShow Process Information\nSearch Processes\nShow Top Processes" | wofi --dmenu --prompt "Process Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "List Processes")
                    list_processes
                    ;;
                "Kill Process")
                    pid=$(list_processes | wofi --dmenu --prompt "Select Process" --style "$HOME/.config/wofi/power-menu.css" | awk '{print $1}')
                    kill_process "$pid"
                    ;;
                "Force Kill Process")
                    pid=$(list_processes | wofi --dmenu --prompt "Select Process" --style "$HOME/.config/wofi/power-menu.css" | awk '{print $1}')
                    force_kill_process "$pid"
                    ;;
                "Start Process")
                    command=$(wofi --dmenu --prompt "Enter Command" --style "$HOME/.config/wofi/power-menu.css")
                    start_process "$command"
                    ;;
                "Restart Process")
                    pid=$(list_processes | wofi --dmenu --prompt "Select Process" --style "$HOME/.config/wofi/power-menu.css" | awk '{print $1}')
                    restart_process "$pid"
                    ;;
                "Show Process Information")
                    pid=$(list_processes | wofi --dmenu --prompt "Select Process" --style "$HOME/.config/wofi/power-menu.css" | awk '{print $1}')
                    show_process_info "$pid"
                    ;;
                "Search Processes")
                    search_term=$(wofi --dmenu --prompt "Enter Search Term" --style "$HOME/.config/wofi/power-menu.css")
                    search_processes "$search_term"
                    ;;
                "Show Top Processes")
                    show_top_processes
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 