#!/bin/bash

# Anime-themed Service Manager Script
# ----------------------------------
# This script manages system services with anime-themed notifications

# Configuration
SERVICE_ICON="$HOME/.config/hypr/icons/service.png"
SERVICE_START_SOUND="$HOME/.config/hypr/sounds/service-start.wav"
SERVICE_STOP_SOUND="$HOME/.config/hypr/sounds/service-stop.wav"
SERVICE_RESTART_SOUND="$HOME/.config/hypr/sounds/service-restart.wav"

# Function to check if systemctl is installed
check_systemctl() {
    if ! command -v systemctl &> /dev/null; then
        notify-send "Service Manager" "systemctl is not installed. Please install it to use this script." -i "$SERVICE_ICON"
        exit 1
    fi
}

# Function to get service status
get_service_status() {
    # Check if systemctl is installed
    check_systemctl
    
    # Get the service name
    local service="$1"
    
    # Get service status
    local status=$(systemctl is-active "$service")
    
    echo "$status"
}

# Function to start a service
start_service() {
    # Check if systemctl is installed
    check_systemctl
    
    # Get the service name
    local service="$1"
    
    # Start the service
    systemctl start "$service"
    
    # Check if the service was started successfully
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$SERVICE_START_SOUND" &
        
        # Show success notification
        notify-send "Service Manager" "Started $service" -i "$SERVICE_ICON"
        
        echo "Started $service"
    else
        # Show error notification
        notify-send "Service Manager" "Failed to start $service" -i "$SERVICE_ICON"
        
        echo "Failed to start $service"
    fi
}

# Function to stop a service
stop_service() {
    # Check if systemctl is installed
    check_systemctl
    
    # Get the service name
    local service="$1"
    
    # Stop the service
    systemctl stop "$service"
    
    # Check if the service was stopped successfully
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$SERVICE_STOP_SOUND" &
        
        # Show success notification
        notify-send "Service Manager" "Stopped $service" -i "$SERVICE_ICON"
        
        echo "Stopped $service"
    else
        # Show error notification
        notify-send "Service Manager" "Failed to stop $service" -i "$SERVICE_ICON"
        
        echo "Failed to stop $service"
    fi
}

# Function to restart a service
restart_service() {
    # Check if systemctl is installed
    check_systemctl
    
    # Get the service name
    local service="$1"
    
    # Restart the service
    systemctl restart "$service"
    
    # Check if the service was restarted successfully
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$SERVICE_RESTART_SOUND" &
        
        # Show success notification
        notify-send "Service Manager" "Restarted $service" -i "$SERVICE_ICON"
        
        echo "Restarted $service"
    else
        # Show error notification
        notify-send "Service Manager" "Failed to restart $service" -i "$SERVICE_ICON"
        
        echo "Failed to restart $service"
    fi
}

# Function to enable a service
enable_service() {
    # Check if systemctl is installed
    check_systemctl
    
    # Get the service name
    local service="$1"
    
    # Enable the service
    systemctl enable "$service"
    
    # Check if the service was enabled successfully
    if [ $? -eq 0 ]; then
        # Show success notification
        notify-send "Service Manager" "Enabled $service" -i "$SERVICE_ICON"
        
        echo "Enabled $service"
    else
        # Show error notification
        notify-send "Service Manager" "Failed to enable $service" -i "$SERVICE_ICON"
        
        echo "Failed to enable $service"
    fi
}

# Function to disable a service
disable_service() {
    # Check if systemctl is installed
    check_systemctl
    
    # Get the service name
    local service="$1"
    
    # Disable the service
    systemctl disable "$service"
    
    # Check if the service was disabled successfully
    if [ $? -eq 0 ]; then
        # Show success notification
        notify-send "Service Manager" "Disabled $service" -i "$SERVICE_ICON"
        
        echo "Disabled $service"
    else
        # Show error notification
        notify-send "Service Manager" "Failed to disable $service" -i "$SERVICE_ICON"
        
        echo "Failed to disable $service"
    fi
}

# Function to list services
list_services() {
    # Check if systemctl is installed
    check_systemctl
    
    # List services
    local services=$(systemctl list-units --type=service --state=running | grep ".service" | awk '{print $1}')
    
    echo "$services"
}

# Function to show service information
show_service_info() {
    # Check if systemctl is installed
    check_systemctl
    
    # Get the service name
    local service="$1"
    
    # Get service status
    local status=$(get_service_status "$service")
    
    # Get service description
    local description=$(systemctl show "$service" -p Description | cut -d= -f2)
    
    # Get service load state
    local load_state=$(systemctl show "$service" -p LoadState | cut -d= -f2)
    
    # Get service active state
    local active_state=$(systemctl show "$service" -p ActiveState | cut -d= -f2)
    
    # Show service information
    notify-send "Service Manager" "Service: $service\nStatus: $status\nDescription: $description\nLoad State: $load_state\nActive State: $active_state" -i "$SERVICE_ICON"
    
    # Return the values for display
    echo "Service: $service | Status: $status | Description: $description | Load State: $load_state | Active State: $active_state"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "status")
            get_service_status "$2"
            ;;
        "start")
            start_service "$2"
            ;;
        "stop")
            stop_service "$2"
            ;;
        "restart")
            restart_service "$2"
            ;;
        "enable")
            enable_service "$2"
            ;;
        "disable")
            disable_service "$2"
            ;;
        "list")
            list_services
            ;;
        "info")
            show_service_info "$2"
            ;;
        *)
            # Show a menu
            choice=$(echo -e "List Services\nStart Service\nStop Service\nRestart Service\nEnable Service\nDisable Service\nShow Service Information" | wofi --dmenu --prompt "Service Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "List Services")
                    list_services
                    ;;
                "Start Service")
                    service=$(list_services | wofi --dmenu --prompt "Select Service" --style "$HOME/.config/wofi/power-menu.css")
                    start_service "$service"
                    ;;
                "Stop Service")
                    service=$(list_services | wofi --dmenu --prompt "Select Service" --style "$HOME/.config/wofi/power-menu.css")
                    stop_service "$service"
                    ;;
                "Restart Service")
                    service=$(list_services | wofi --dmenu --prompt "Select Service" --style "$HOME/.config/wofi/power-menu.css")
                    restart_service "$service"
                    ;;
                "Enable Service")
                    service=$(list_services | wofi --dmenu --prompt "Select Service" --style "$HOME/.config/wofi/power-menu.css")
                    enable_service "$service"
                    ;;
                "Disable Service")
                    service=$(list_services | wofi --dmenu --prompt "Select Service" --style "$HOME/.config/wofi/power-menu.css")
                    disable_service "$service"
                    ;;
                "Show Service Information")
                    service=$(list_services | wofi --dmenu --prompt "Select Service" --style "$HOME/.config/wofi/power-menu.css")
                    show_service_info "$service"
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 