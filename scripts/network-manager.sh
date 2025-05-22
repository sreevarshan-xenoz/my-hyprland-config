#!/bin/bash

# Anime-themed Network Manager Script
# ---------------------------------
# This script manages network connections with anime-themed notifications

# Configuration
WIFI_ICON="$HOME/.config/hypr/icons/wifi.png"
ETHERNET_ICON="$HOME/.config/hypr/icons/ethernet.png"
DISCONNECTED_ICON="$HOME/.config/hypr/icons/disconnected.png"
CONNECT_SOUND="$HOME/.config/hypr/sounds/connect.wav"
DISCONNECT_SOUND="$HOME/.config/hypr/sounds/disconnect.wav"

# Function to check if nmcli is installed
check_nmcli() {
    if ! command -v nmcli &> /dev/null; then
        notify-send "Network Manager" "nmcli is not installed. Please install it to use this script." -i "$DISCONNECTED_ICON"
        exit 1
    fi
}

# Function to get network status
get_network_status() {
    # Check if nmcli is installed
    check_nmcli
    
    # Get network status
    local status=$(nmcli -t -f STATE g)
    
    echo "$status"
}

# Function to get connection type
get_connection_type() {
    # Check if nmcli is installed
    check_nmcli
    
    # Get connection type
    local type=$(nmcli -t -f TYPE c show --active | head -n 1)
    
    echo "$type"
}

# Function to get connection name
get_connection_name() {
    # Check if nmcli is installed
    check_nmcli
    
    # Get connection name
    local name=$(nmcli -t -f NAME c show --active | head -n 1)
    
    echo "$name"
}

# Function to get IP address
get_ip_address() {
    # Check if nmcli is installed
    check_nmcli
    
    # Get IP address
    local ip=$(nmcli -t -f IP4.ADDRESS c show --active | head -n 1 | cut -d '/' -f 1)
    
    echo "$ip"
}

# Function to get signal strength (for WiFi)
get_signal_strength() {
    # Check if nmcli is installed
    check_nmcli
    
    # Get signal strength
    local strength=$(nmcli -t -f SIGNAL d wifi list --rescan no | grep "$(get_connection_name)" | cut -d ':' -f 2)
    
    echo "$strength"
}

# Function to list available WiFi networks
list_wifi_networks() {
    # Check if nmcli is installed
    check_nmcli
    
    # List available WiFi networks
    nmcli -t -f SSID,SIGNAL,SECURITY d wifi list --rescan yes
}

# Function to connect to a WiFi network
connect_wifi() {
    # Check if nmcli is installed
    check_nmcli
    
    # Get the SSID to connect to
    local ssid="$1"
    
    # Get the password (if needed)
    local password=""
    if [ -n "$2" ]; then
        password="$2"
    else
        # Check if the network is secured
        local security=$(nmcli -t -f SECURITY d wifi list --rescan no | grep "$ssid" | cut -d ':' -f 2)
        
        if [ "$security" != "--" ]; then
            # Ask for password
            password=$(wofi --dmenu --password --prompt "Enter password for $ssid" --style "$HOME/.config/wofi/power-menu.css")
        fi
    fi
    
    # Connect to the network
    if [ -n "$password" ]; then
        nmcli d wifi connect "$ssid" password "$password"
    else
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

# Function to disconnect from the current network
disconnect_network() {
    # Check if nmcli is installed
    check_nmcli
    
    # Get the connection name
    local name=$(get_connection_name)
    
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
    # Check if nmcli is installed
    check_nmcli
    
    # Check if WiFi is enabled
    local wifi_enabled=$(nmcli radio wifi)
    
    if [ "$wifi_enabled" = "enabled" ]; then
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
    # Check if nmcli is installed
    check_nmcli
    
    # Get network status
    local status=$(get_network_status)
    
    # Get connection type
    local type=$(get_connection_type)
    
    # Get connection name
    local name=$(get_connection_name)
    
    # Get IP address
    local ip=$(get_ip_address)
    
    # Get signal strength (for WiFi)
    local signal=""
    if [ "$type" = "wifi" ]; then
        signal="Signal: $(get_signal_strength)%"
    fi
    
    # Show network information
    notify-send "Network Manager" "Status: $status\nType: $type\nName: $name\nIP: $ip\n$signal" -i "$WIFI_ICON"
    
    # Return the values for display
    echo "Status: $status | Type: $type | Name: $name | IP: $ip | $signal"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "status")
            get_network_status
            ;;
        "type")
            get_connection_type
            ;;
        "name")
            get_connection_name
            ;;
        "ip")
            get_ip_address
            ;;
        "signal")
            get_signal_strength
            ;;
        "list")
            list_wifi_networks
            ;;
        "connect")
            connect_wifi "$2" "$3"
            ;;
        "disconnect")
            disconnect_network
            ;;
        "toggle")
            toggle_wifi
            ;;
        "info")
            show_network_info
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Show Network Status\nShow Connection Type\nShow Connection Name\nShow IP Address\nShow Signal Strength\nList WiFi Networks\nConnect to WiFi\nDisconnect from Network\nToggle WiFi\nShow Network Information" | wofi --dmenu --prompt "Network Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Show Network Status")
                    get_network_status
                    ;;
                "Show Connection Type")
                    get_connection_type
                    ;;
                "Show Connection Name")
                    get_connection_name
                    ;;
                "Show IP Address")
                    get_ip_address
                    ;;
                "Show Signal Strength")
                    get_signal_strength
                    ;;
                "List WiFi Networks")
                    list_wifi_networks
                    ;;
                "Connect to WiFi")
                    # Get the SSID to connect to
                    ssid=$(list_wifi_networks | wofi --dmenu --prompt "Select WiFi Network" --style "$HOME/.config/wofi/power-menu.css" | cut -d ':' -f 1)
                    
                    if [ -n "$ssid" ]; then
                        connect_wifi "$ssid"
                    fi
                    ;;
                "Disconnect from Network")
                    disconnect_network
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