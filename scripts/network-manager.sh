#!/bin/bash

# Anime-themed Network Manager Script
# ----------------------------------
# This script manages network connections with anime-themed notifications

# Configuration
NETWORK_ICON="$HOME/.config/hypr/icons/network.png"
WIFI_ICON="$HOME/.config/hypr/icons/wifi.png"
ETHERNET_ICON="$HOME/.config/hypr/icons/ethernet.png"
DISCONNECTED_ICON="$HOME/.config/hypr/icons/disconnected.png"
CONNECT_SOUND="$HOME/.config/hypr/sounds/connect.wav"
DISCONNECT_SOUND="$HOME/.config/hypr/sounds/disconnect.wav"

# Function to check if NetworkManager is installed
check_network_manager() {
    if ! command -v nmcli &> /dev/null; then
        notify-send "Network Manager" "NetworkManager is not installed. Please install it to use this script." -i "$DISCONNECTED_ICON"
        exit 1
    fi
}

# Function to get network status
get_network_status() {
    # Check if NetworkManager is installed
    check_network_manager
    
    # Get network status
    local status=$(nmcli -t -f STATE g)
    
    echo "$status"
}

# Function to get active connection
get_active_connection() {
    # Check if NetworkManager is installed
    check_network_manager
    
    # Get active connection
    local connection=$(nmcli -t -f NAME,DEVICE,STATE c s --active | head -n 1)
    
    echo "$connection"
}

# Function to get available networks
get_available_networks() {
    # Check if NetworkManager is installed
    check_network_manager
    
    # Get available networks
    local networks=$(nmcli -t -f SSID,SIGNAL,SECURITY d wifi list | sort -k2 -nr)
    
    echo "$networks"
}

# Function to connect to a network
connect_to_network() {
    # Check if NetworkManager is installed
    check_network_manager
    
    # Get the network to connect to
    local network=$(get_available_networks | wofi --dmenu --prompt "Select Network" --style "$HOME/.config/wofi/power-menu.css")
    
    if [ -z "$network" ]; then
        return
    fi
    
    # Extract the SSID
    local ssid=$(echo "$network" | cut -d: -f1)
    
    # Check if the network is secured
    local security=$(echo "$network" | cut -d: -f3)
    
    if [ "$security" != "" ]; then
        # Get the password
        local password=$(wofi --dmenu --prompt "Enter Password" --password --style "$HOME/.config/wofi/power-menu.css")
        
        if [ -z "$password" ]; then
            return
        fi
        
        # Connect to the network
        nmcli d wifi connect "$ssid" password "$password"
    else
        # Connect to the network
        nmcli d wifi connect "$ssid"
    fi
    
    # Check if the connection was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$CONNECT_SOUND" &
        
        # Show success notification
        notify-send "Network Manager" "Connected to $ssid" -i "$WIFI_ICON"
        
        echo "Connected to $ssid"
    else
        # Show error notification
        notify-send "Network Manager" "Failed to connect to $ssid" -i "$DISCONNECTED_ICON"
        
        echo "Failed to connect to $ssid"
    fi
}

# Function to disconnect from a network
disconnect_from_network() {
    # Check if NetworkManager is installed
    check_network_manager
    
    # Get active connection
    local connection=$(get_active_connection)
    
    if [ -z "$connection" ]; then
        notify-send "Network Manager" "No active connection" -i "$DISCONNECTED_ICON"
        return
    fi
    
    # Extract the connection name
    local name=$(echo "$connection" | cut -d: -f1)
    
    # Disconnect from the network
    nmcli c down "$name"
    
    # Check if the disconnection was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$DISCONNECT_SOUND" &
        
        # Show success notification
        notify-send "Network Manager" "Disconnected from $name" -i "$DISCONNECTED_ICON"
        
        echo "Disconnected from $name"
    else
        # Show error notification
        notify-send "Network Manager" "Failed to disconnect from $name" -i "$DISCONNECTED_ICON"
        
        echo "Failed to disconnect from $name"
    fi
}

# Function to toggle WiFi
toggle_wifi() {
    # Check if NetworkManager is installed
    check_network_manager
    
    # Get WiFi status
    local status=$(nmcli radio wifi)
    
    if [ "$status" = "enabled" ]; then
        # Disable WiFi
        nmcli radio wifi off
        
        # Play a sound effect
        paplay "$DISCONNECT_SOUND" &
        
        # Show success notification
        notify-send "Network Manager" "WiFi disabled" -i "$DISCONNECTED_ICON"
        
        echo "WiFi disabled"
    else
        # Enable WiFi
        nmcli radio wifi on
        
        # Play a sound effect
        paplay "$CONNECT_SOUND" &
        
        # Show success notification
        notify-send "Network Manager" "WiFi enabled" -i "$WIFI_ICON"
        
        echo "WiFi enabled"
    fi
}

# Function to show network information
show_network_info() {
    # Check if NetworkManager is installed
    check_network_manager
    
    # Get network status
    local status=$(get_network_status)
    
    # Get active connection
    local connection=$(get_active_connection)
    
    # Get IP address
    local ip=$(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1)
    
    # Show network information
    notify-send "Network Manager" "Status: $status\nConnection: $connection\nIP: $ip" -i "$NETWORK_ICON"
    
    # Return the values for display
    echo "Status: $status | Connection: $connection | IP: $ip"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "status")
            get_network_status
            ;;
        "connect")
            connect_to_network
            ;;
        "disconnect")
            disconnect_from_network
            ;;
        "toggle")
            toggle_wifi
            ;;
        "info")
            show_network_info
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Show Network Status\nConnect to Network\nDisconnect from Network\nToggle WiFi\nShow Network Information" | wofi --dmenu --prompt "Network Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Show Network Status")
                    get_network_status
                    ;;
                "Connect to Network")
                    connect_to_network
                    ;;
                "Disconnect from Network")
                    disconnect_from_network
                    ;;
                "Toggle WiFi")
                    toggle_wifi
                    ;;
                "Show Network Information")
                    show_network_info
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 