#!/bin/bash

# Anime-themed System Monitor Script
# ---------------------------------
# This script displays system information with anime-themed visuals and notifications

# Configuration
ICON_DIR="$HOME/.config/hypr/icons"
SOUND_DIR="$HOME/.config/hypr/sounds"
NOTIFICATION_ICON="$ICON_DIR/notification.png"
ALERT_ICON="$ICON_DIR/alert.png"
ALERT_SOUND="$SOUND_DIR/alert.wav"
UPDATE_INTERVAL=5
MAX_HISTORY=60
HISTORY_FILE="/tmp/anime-monitor-history.txt"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
TEMP_THRESHOLD=80
BATTERY_LOW=20
BATTERY_CRITICAL=10

# Performance settings
# Set to true to disable sound effects (reduces resource usage)
DISABLE_SOUNDS=false
# Set to true to disable notifications (reduces resource usage)
DISABLE_NOTIFICATIONS=false
# Set to true to disable history tracking (reduces resource usage)
DISABLE_HISTORY=false
# Set to true to use simpler monitoring (reduces resource usage)
USE_SIMPLE_MONITORING=true
# Set to true to disable visual effects (reduces resource usage)
DISABLE_VISUAL_EFFECTS=false

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
    
    # Check for basic tools
    for cmd in grep awk free df top sensors; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for optional tools
    if [ "$DISABLE_VISUAL_EFFECTS" = false ]; then
        if ! command -v eww &> /dev/null; then
            missing_deps+=("eww")
        fi
    fi
    
    # If any dependencies are missing, show notification and exit
    if [ ${#missing_deps[@]} -gt 0 ]; then
        send_notification "Anime Monitor" "Missing dependencies: ${missing_deps[*]}. Please install them to use this script." -i "$NOTIFICATION_ICON"
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
        DISABLE_HISTORY=true
        USE_SIMPLE_MONITORING=true
        DISABLE_VISUAL_EFFECTS=true
    fi
}

# Function to get CPU usage
get_cpu_usage() {
    if [ "$USE_SIMPLE_MONITORING" = true ]; then
        # Simpler command for low-end devices
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1
    else
        # More accurate command
        top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1
    fi
}

# Function to get memory usage
get_memory_usage() {
    if [ "$USE_SIMPLE_MONITORING" = true ]; then
        # Simpler command for low-end devices
        free | grep Mem | awk '{print int($3/$2 * 100)}'
    else
        # More accurate command
        free | grep Mem | awk '{print int(($2-$7)/$2 * 100)}'
    fi
}

# Function to get disk usage
get_disk_usage() {
    if [ "$USE_SIMPLE_MONITORING" = true ]; then
        # Simpler command for low-end devices
        df -h / | tail -1 | awk '{print $5}' | sed 's/%//'
    else
        # More accurate command
        df -h / | tail -1 | awk '{print $5}' | sed 's/%//'
    fi
}

# Function to get CPU temperature
get_cpu_temperature() {
    if [ "$USE_SIMPLE_MONITORING" = true ]; then
        # Simpler command for low-end devices
        sensors | grep "Core 0" | awk '{print $3}' | sed 's/+//' | sed 's/°C//'
    else
        # More accurate command
        sensors | grep "Core 0" | awk '{print $3}' | sed 's/+//' | sed 's/°C//'
    fi
}

# Function to get battery level
get_battery_level() {
    if [ -f /sys/class/power_supply/BAT0/capacity ]; then
        cat /sys/class/power_supply/BAT0/capacity
    else
        echo "N/A"
    fi
}

# Function to get battery status
get_battery_status() {
    if [ -f /sys/class/power_supply/BAT0/status ]; then
        cat /sys/class/power_supply/BAT0/status
    else
        echo "N/A"
    fi
}

# Function to get uptime
get_uptime() {
    uptime -p | sed 's/up //'
}

# Function to get load average
get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | awk '{print $1}'
}

# Function to get network usage
get_network_usage() {
    if [ "$USE_SIMPLE_MONITORING" = true ]; then
        # Simpler command for low-end devices
        echo "N/A"
    else
        # More accurate command
        if command -v ifconfig &> /dev/null; then
            ifconfig | grep "RX bytes" | awk '{print $2}' | sed 's/bytes://'
        else
            echo "N/A"
        fi
    fi
}

# Function to get GPU usage (if available)
get_gpu_usage() {
    if [ "$USE_SIMPLE_MONITORING" = true ]; then
        # Simpler command for low-end devices
        echo "N/A"
    else
        # More accurate command
        if command -v nvidia-smi &> /dev/null; then
            nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits
        else
            echo "N/A"
        fi
    fi
}

# Function to update history
update_history() {
    if [ "$DISABLE_HISTORY" = true ]; then
        return
    fi
    
    # Get current values
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local cpu_temp=$(get_cpu_temperature)
    
    # Add to history
    echo "$(date +%s),$cpu_usage,$memory_usage,$disk_usage,$cpu_temp" >> "$HISTORY_FILE"
    
    # Trim history if needed
    if [ -f "$HISTORY_FILE" ]; then
        local line_count=$(wc -l < "$HISTORY_FILE")
        if [ "$line_count" -gt "$MAX_HISTORY" ]; then
            tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "$HISTORY_FILE.tmp"
            mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
        fi
    fi
}

# Function to check for alerts
check_alerts() {
    # Check CPU usage
    local cpu_usage=$(get_cpu_usage)
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        send_notification "CPU Alert" "CPU usage is high: $cpu_usage%" -i "$ALERT_ICON"
        play_sound "$ALERT_SOUND"
    fi
    
    # Check memory usage
    local memory_usage=$(get_memory_usage)
    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        send_notification "Memory Alert" "Memory usage is high: $memory_usage%" -i "$ALERT_ICON"
        play_sound "$ALERT_SOUND"
    fi
    
    # Check disk usage
    local disk_usage=$(get_disk_usage)
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        send_notification "Disk Alert" "Disk usage is high: $disk_usage%" -i "$ALERT_ICON"
        play_sound "$ALERT_SOUND"
    fi
    
    # Check CPU temperature
    local cpu_temp=$(get_cpu_temperature)
    if [ "$cpu_temp" -gt "$TEMP_THRESHOLD" ]; then
        send_notification "Temperature Alert" "CPU temperature is high: $cpu_temp°C" -i "$ALERT_ICON"
        play_sound "$ALERT_SOUND"
    fi
    
    # Check battery level
    local battery_level=$(get_battery_level)
    if [ "$battery_level" != "N/A" ]; then
        if [ "$battery_level" -le "$BATTERY_CRITICAL" ]; then
            send_notification "Battery Critical" "Battery level is critical: $battery_level%" -i "$ALERT_ICON"
            play_sound "$ALERT_SOUND"
        elif [ "$battery_level" -le "$BATTERY_LOW" ]; then
            send_notification "Battery Low" "Battery level is low: $battery_level%" -i "$ALERT_ICON"
            play_sound "$ALERT_SOUND"
        fi
    fi
}

# Function to display system information
display_system_info() {
    # Get system information
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local cpu_temp=$(get_cpu_temperature)
    local battery_level=$(get_battery_level)
    local battery_status=$(get_battery_status)
    local uptime=$(get_uptime)
    local load_average=$(get_load_average)
    local network_usage=$(get_network_usage)
    local gpu_usage=$(get_gpu_usage)
    
    # Create system information message
    local message="System Information:\n\n"
    message+="CPU Usage: $cpu_usage%\n"
    message+="Memory Usage: $memory_usage%\n"
    message+="Disk Usage: $disk_usage%\n"
    message+="CPU Temperature: $cpu_temp°C\n"
    
    if [ "$battery_level" != "N/A" ]; then
        message+="Battery Level: $battery_level% ($battery_status)\n"
    fi
    
    message+="Uptime: $uptime\n"
    message+="Load Average: $load_average\n"
    
    if [ "$network_usage" != "N/A" ]; then
        message+="Network Usage: $network_usage bytes\n"
    fi
    
    if [ "$gpu_usage" != "N/A" ]; then
        message+="GPU Usage: $gpu_usage%\n"
    fi
    
    # Display system information
    if [ "$DISABLE_VISUAL_EFFECTS" = false ]; then
        # Use EWW to display system information
        if command -v eww &> /dev/null; then
            eww update system_info="$message"
        else
            # Fallback to notification
            send_notification "System Information" "$message" -i "$NOTIFICATION_ICON"
        fi
    else
        # Use notification
        send_notification "System Information" "$message" -i "$NOTIFICATION_ICON"
    fi
}

# Function to display anime-themed system information
display_anime_system_info() {
    # Get system information
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local cpu_temp=$(get_cpu_temperature)
    local battery_level=$(get_battery_level)
    local battery_status=$(get_battery_status)
    local uptime=$(get_uptime)
    local load_average=$(get_load_average)
    
    # Determine anime character based on system state
    local anime_character=""
    local anime_quote=""
    
    # CPU usage determines the character's mood
    if [ "$cpu_usage" -gt 90 ]; then
        anime_character="Stressed Anime Character"
        anime_quote="My CPU is overheating! I need to cool down!"
    elif [ "$cpu_usage" -gt 70 ]; then
        anime_character="Worried Anime Character"
        anime_quote="My CPU is working hard. I hope it doesn't overheat!"
    elif [ "$cpu_usage" -gt 50 ]; then
        anime_character="Focused Anime Character"
        anime_quote="My CPU is working at a moderate pace. I can handle this!"
    else
        anime_character="Relaxed Anime Character"
        anime_quote="My CPU is relaxed. Everything is running smoothly!"
    fi
    
    # Memory usage affects the character's appearance
    if [ "$memory_usage" -gt 90 ]; then
        anime_character="$anime_character (Memory Stressed)"
        anime_quote="$anime_quote\nMy memory is almost full! I need to free up some space!"
    elif [ "$memory_usage" -gt 70 ]; then
        anime_character="$anime_character (Memory Worried)"
        anime_quote="$anime_quote\nMy memory is getting full. I should clean up soon."
    fi
    
    # Temperature affects the character's appearance
    if [ "$cpu_temp" -gt 80 ]; then
        anime_character="$anime_character (Overheating)"
        anime_quote="$anime_quote\nI'm overheating! I need to cool down!"
    elif [ "$cpu_temp" -gt 70 ]; then
        anime_character="$anime_character (Warm)"
        anime_quote="$anime_quote\nI'm getting warm. I should take a break soon."
    fi
    
    # Battery level affects the character's appearance
    if [ "$battery_level" != "N/A" ]; then
        if [ "$battery_level" -le 10 ]; then
            anime_character="$anime_character (Low Battery)"
            anime_quote="$anime_quote\nMy battery is critically low! I need to charge soon!"
        elif [ "$battery_level" -le 20 ]; then
            anime_character="$anime_character (Low Battery)"
            anime_quote="$anime_quote\nMy battery is getting low. I should charge soon."
        fi
    fi
    
    # Create anime-themed system information message
    local message="Anime-themed System Information:\n\n"
    message+="Character: $anime_character\n"
    message+="Quote: $anime_quote\n\n"
    message+="CPU Usage: $cpu_usage%\n"
    message+="Memory Usage: $memory_usage%\n"
    message+="Disk Usage: $disk_usage%\n"
    message+="CPU Temperature: $cpu_temp°C\n"
    
    if [ "$battery_level" != "N/A" ]; then
        message+="Battery Level: $battery_level% ($battery_status)\n"
    fi
    
    message+="Uptime: $uptime\n"
    message+="Load Average: $load_average\n"
    
    # Display anime-themed system information
    if [ "$DISABLE_VISUAL_EFFECTS" = false ]; then
        # Use EWW to display anime-themed system information
        if command -v eww &> /dev/null; then
            eww update anime_system_info="$message"
        else
            # Fallback to notification
            send_notification "Anime System Information" "$message" -i "$NOTIFICATION_ICON"
        fi
    else
        # Use notification
        send_notification "Anime System Information" "$message" -i "$NOTIFICATION_ICON"
    fi
}

# Function to start monitoring
start_monitoring() {
    # Check dependencies
    check_dependencies
    
    # Detect system capabilities
    detect_system_capabilities
    
    # Initialize history file
    if [ "$DISABLE_HISTORY" = false ]; then
        echo "timestamp,cpu,memory,disk,temperature" > "$HISTORY_FILE"
    fi
    
    # Start monitoring loop
    while true; do
        # Update history
        update_history
        
        # Check for alerts
        check_alerts
        
        # Display system information
        if [ "$1" = "anime" ]; then
            display_anime_system_info
        else
            display_system_info
        fi
        
        # Sleep for update interval
        sleep "$UPDATE_INTERVAL"
    done
}

# Function to show monitoring menu
show_monitoring_menu() {
    # Show monitoring menu
    choice=$(echo -e "Start Standard Monitoring\nStart Anime-themed Monitoring\nShow Current System Information\nShow Anime-themed System Information\nEnable Low-End Mode\nEnable High-End Mode" | wofi --dmenu --prompt "Anime Monitor" --style "$HOME/.config/wofi/power-menu.css")
    
    case "$choice" in
        "Start Standard Monitoring")
            start_monitoring "standard"
            ;;
        "Start Anime-themed Monitoring")
            start_monitoring "anime"
            ;;
        "Show Current System Information")
            display_system_info
            ;;
        "Show Anime-themed System Information")
            display_anime_system_info
            ;;
        "Enable Low-End Mode")
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            DISABLE_HISTORY=true
            USE_SIMPLE_MONITORING=true
            DISABLE_VISUAL_EFFECTS=true
            send_notification "Anime Monitor" "Low-end mode enabled" -i "$NOTIFICATION_ICON"
            ;;
        "Enable High-End Mode")
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            DISABLE_HISTORY=false
            USE_SIMPLE_MONITORING=false
            DISABLE_VISUAL_EFFECTS=false
            send_notification "Anime Monitor" "High-end mode enabled" -i "$NOTIFICATION_ICON"
            ;;
    esac
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "start")
            # Start monitoring
            start_monitoring "standard"
            ;;
        "anime")
            # Start anime-themed monitoring
            start_monitoring "anime"
            ;;
        "info")
            # Show current system information
            display_system_info
            ;;
        "anime-info")
            # Show anime-themed system information
            display_anime_system_info
            ;;
        "low-end")
            # Enable low-end mode
            DISABLE_SOUNDS=true
            DISABLE_NOTIFICATIONS=false
            DISABLE_HISTORY=true
            USE_SIMPLE_MONITORING=true
            DISABLE_VISUAL_EFFECTS=true
            send_notification "Anime Monitor" "Low-end mode enabled" -i "$NOTIFICATION_ICON"
            ;;
        "high-end")
            # Enable high-end mode
            DISABLE_SOUNDS=false
            DISABLE_NOTIFICATIONS=false
            DISABLE_HISTORY=false
            USE_SIMPLE_MONITORING=false
            DISABLE_VISUAL_EFFECTS=false
            send_notification "Anime Monitor" "High-end mode enabled" -i "$NOTIFICATION_ICON"
            ;;
        *)
            # Show monitoring menu
            show_monitoring_menu
            ;;
    esac
}

# Run the main function
main "$@" 