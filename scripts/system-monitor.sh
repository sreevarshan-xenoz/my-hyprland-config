#!/bin/bash

# Anime-themed System Monitor Script
# ---------------------------------
# This script monitors system resources with anime-themed notifications

# Configuration
MONITOR_ICON="$HOME/.config/hypr/icons/monitor.png"
ALERT_ICON="$HOME/.config/hypr/icons/alert.png"
ALERT_SOUND="$HOME/.config/hypr/sounds/alert.wav"
LOG_FILE="$HOME/.config/hypr/logs/monitor.log"

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90
TEMP_THRESHOLD=80

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to get CPU usage
get_cpu_usage() {
    # Get CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    
    # Round to integer
    cpu_usage=$(printf "%.0f" "$cpu_usage")
    
    echo "$cpu_usage"
}

# Function to get memory usage
get_memory_usage() {
    # Get memory usage
    local memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    
    # Round to integer
    memory_usage=$(printf "%.0f" "$memory_usage")
    
    echo "$memory_usage"
}

# Function to get disk usage
get_disk_usage() {
    # Get disk usage
    local disk_usage=$(df -h / | tail -n 1 | awk '{print $5}' | sed 's/%//')
    
    echo "$disk_usage"
}

# Function to get CPU temperature
get_cpu_temperature() {
    # Check if sensors is installed
    if ! command -v sensors &> /dev/null; then
        echo "N/A"
        return
    fi
    
    # Get CPU temperature
    local temp=$(sensors | grep "Package id 0" | awk '{print $4}' | sed 's/+//' | sed 's/°C//')
    
    # Round to integer
    temp=$(printf "%.0f" "$temp")
    
    echo "$temp"
}

# Function to check system resources
check_system_resources() {
    # Get system resources
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local cpu_temp=$(get_cpu_temperature)
    
    # Check CPU usage
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        notify-send "System Monitor" "High CPU usage: $cpu_usage%" -i "$ALERT_ICON"
        paplay "$ALERT_SOUND" &
        echo "High CPU usage: $cpu_usage% at $(date)" >> "$LOG_FILE"
    fi
    
    # Check memory usage
    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        notify-send "System Monitor" "High memory usage: $memory_usage%" -i "$ALERT_ICON"
        paplay "$ALERT_SOUND" &
        echo "High memory usage: $memory_usage% at $(date)" >> "$LOG_FILE"
    fi
    
    # Check disk usage
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        notify-send "System Monitor" "High disk usage: $disk_usage%" -i "$ALERT_ICON"
        paplay "$ALERT_SOUND" &
        echo "High disk usage: $disk_usage% at $(date)" >> "$LOG_FILE"
    fi
    
    # Check CPU temperature
    if [ "$cpu_temp" != "N/A" ] && [ "$cpu_temp" -gt "$TEMP_THRESHOLD" ]; then
        notify-send "System Monitor" "High CPU temperature: $cpu_temp°C" -i "$ALERT_ICON"
        paplay "$ALERT_SOUND" &
        echo "High CPU temperature: $cpu_temp°C at $(date)" >> "$LOG_FILE"
    fi
    
    # Return the values for display
    echo "CPU: $cpu_usage% | Memory: $memory_usage% | Disk: $disk_usage% | Temp: $cpu_temp°C"
}

# Function to show system resources
show_system_resources() {
    # Get system resources
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local cpu_temp=$(get_cpu_temperature)
    
    # Show system resources
    notify-send "System Monitor" "CPU: $cpu_usage%\nMemory: $memory_usage%\nDisk: $disk_usage%\nTemp: $cpu_temp°C" -i "$MONITOR_ICON"
    
    # Return the values for display
    echo "CPU: $cpu_usage% | Memory: $memory_usage% | Disk: $disk_usage% | Temp: $cpu_temp°C"
}

# Function to show top processes
show_top_processes() {
    # Get top processes
    local top_processes=$(ps aux --sort=-%cpu | head -n 6)
    
    # Show top processes
    notify-send "System Monitor" "Top processes:\n$top_processes" -i "$MONITOR_ICON"
    
    # Return the values for display
    echo "$top_processes"
}

# Function to show system logs
show_system_logs() {
    # Check if the log file exists
    if [ ! -f "$LOG_FILE" ]; then
        notify-send "System Monitor" "No system logs found." -i "$MONITOR_ICON"
        echo "No system logs found"
        return 0
    fi
    
    # Show the system logs
    notify-send "System Monitor" "Showing system logs..." -i "$MONITOR_ICON"
    
    # Display the log file
    cat "$LOG_FILE" | wofi --dmenu --prompt "System Logs" --style "$HOME/.config/wofi/power-menu.css"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "check")
            check_system_resources
            ;;
        "show")
            show_system_resources
            ;;
        "top")
            show_top_processes
            ;;
        "logs")
            show_system_logs
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Check System Resources\nShow System Resources\nShow Top Processes\nShow System Logs" | wofi --dmenu --prompt "System Monitor" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Check System Resources")
                    check_system_resources
                    ;;
                "Show System Resources")
                    show_system_resources
                    ;;
                "Show Top Processes")
                    show_top_processes
                    ;;
                "Show System Logs")
                    show_system_logs
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 