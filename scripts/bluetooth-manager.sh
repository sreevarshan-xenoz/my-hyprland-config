#!/bin/bash

# Anime-themed Bluetooth Manager Script
# ------------------------------------
# This script manages Bluetooth with anime-themed notifications

# Configuration
BLUETOOTH_ICON="$HOME/.config/hypr/icons/bluetooth.png"
BLUETOOTH_OFF_ICON="$HOME/.config/hypr/icons/bluetooth-off.png"
CONNECT_SOUND="$HOME/.config/hypr/sounds/connect.wav"
DISCONNECT_SOUND="$HOME/.config/hypr/sounds/disconnect.wav"

# Function to check if bluetoothctl is installed
check_bluetoothctl() {
    if ! command -v bluetoothctl &> /dev/null; then
        notify-send "Bluetooth Manager" "bluetoothctl is not installed. Please install it to use this script." -i "$BLUETOOTH_OFF_ICON"
        exit 1
    fi
}

# Function to get Bluetooth status
get_bluetooth_status() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get Bluetooth status
    local status=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
    
    echo "$status"
}

# Function to toggle Bluetooth
toggle_bluetooth() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get Bluetooth status
    local status=$(get_bluetooth_status)
    
    if [ "$status" = "yes" ]; then
        # Turn off Bluetooth
        bluetoothctl power off
        
        # Play a sound effect
        paplay "$DISCONNECT_SOUND" &
        
        # Show success notification
        notify-send "Bluetooth Manager" "Bluetooth turned off" -i "$BLUETOOTH_OFF_ICON"
        
        echo "Bluetooth turned off"
    else
        # Turn on Bluetooth
        bluetoothctl power on
        
        # Play a sound effect
        paplay "$CONNECT_SOUND" &
        
        # Show success notification
        notify-send "Bluetooth Manager" "Bluetooth turned on" -i "$BLUETOOTH_ICON"
        
        echo "Bluetooth turned on"
    fi
}

# Function to get paired devices
get_paired_devices() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get paired devices
    local devices=$(bluetoothctl paired-devices | awk '{print $2, $3}')
    
    echo "$devices"
}

# Function to get connected devices
get_connected_devices() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get connected devices
    local devices=$(bluetoothctl devices Connected | awk '{print $2, $3}')
    
    echo "$devices"
}

# Function to connect to a device
connect_to_device() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get paired devices
    local devices=$(get_paired_devices)
    
    if [ -z "$devices" ]; then
        notify-send "Bluetooth Manager" "No paired devices" -i "$BLUETOOTH_OFF_ICON"
        return
    fi
    
    # Get the device to connect to
    local device=$(echo "$devices" | wofi --dmenu --prompt "Select Device" --style "$HOME/.config/wofi/power-menu.css")
    
    if [ -z "$device" ]; then
        return
    fi
    
    # Extract the MAC address
    local mac=$(echo "$device" | awk '{print $1}')
    
    # Connect to the device
    bluetoothctl connect "$mac"
    
    # Check if the connection was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$CONNECT_SOUND" &
        
        # Show success notification
        notify-send "Bluetooth Manager" "Connected to $device" -i "$BLUETOOTH_ICON"
        
        echo "Connected to $device"
    else
        # Show error notification
        notify-send "Bluetooth Manager" "Failed to connect to $device" -i "$BLUETOOTH_OFF_ICON"
        
        echo "Failed to connect to $device"
    fi
}

# Function to disconnect from a device
disconnect_from_device() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get connected devices
    local devices=$(get_connected_devices)
    
    if [ -z "$devices" ]; then
        notify-send "Bluetooth Manager" "No connected devices" -i "$BLUETOOTH_OFF_ICON"
        return
    fi
    
    # Get the device to disconnect from
    local device=$(echo "$devices" | wofi --dmenu --prompt "Select Device" --style "$HOME/.config/wofi/power-menu.css")
    
    if [ -z "$device" ]; then
        return
    fi
    
    # Extract the MAC address
    local mac=$(echo "$device" | awk '{print $1}')
    
    # Disconnect from the device
    bluetoothctl disconnect "$mac"
    
    # Check if the disconnection was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$DISCONNECT_SOUND" &
        
        # Show success notification
        notify-send "Bluetooth Manager" "Disconnected from $device" -i "$BLUETOOTH_OFF_ICON"
        
        echo "Disconnected from $device"
    else
        # Show error notification
        notify-send "Bluetooth Manager" "Failed to disconnect from $device" -i "$BLUETOOTH_OFF_ICON"
        
        echo "Failed to disconnect from $device"
    fi
}

# Function to scan for devices
scan_for_devices() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Show scanning notification
    notify-send "Bluetooth Manager" "Scanning for devices..." -i "$BLUETOOTH_ICON"
    
    # Start scanning
    bluetoothctl scan on
    
    # Wait for 10 seconds
    sleep 10
    
    # Stop scanning
    bluetoothctl scan off
    
    # Get discovered devices
    local devices=$(bluetoothctl devices | awk '{print $2, $3}')
    
    # Show discovered devices
    notify-send "Bluetooth Manager" "Discovered devices:\n$devices" -i "$BLUETOOTH_ICON"
    
    # Return the values for display
    echo "$devices"
}

# Function to pair with a device
pair_with_device() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get discovered devices
    local devices=$(bluetoothctl devices | awk '{print $2, $3}')
    
    if [ -z "$devices" ]; then
        notify-send "Bluetooth Manager" "No discovered devices" -i "$BLUETOOTH_OFF_ICON"
        return
    fi
    
    # Get the device to pair with
    local device=$(echo "$devices" | wofi --dmenu --prompt "Select Device" --style "$HOME/.config/wofi/power-menu.css")
    
    if [ -z "$device" ]; then
        return
    fi
    
    # Extract the MAC address
    local mac=$(echo "$device" | awk '{print $1}')
    
    # Pair with the device
    bluetoothctl pair "$mac"
    
    # Check if the pairing was successful
    if [ $? -eq 0 ]; then
        # Play a sound effect
        paplay "$CONNECT_SOUND" &
        
        # Show success notification
        notify-send "Bluetooth Manager" "Paired with $device" -i "$BLUETOOTH_ICON"
        
        echo "Paired with $device"
    else
        # Show error notification
        notify-send "Bluetooth Manager" "Failed to pair with $device" -i "$BLUETOOTH_OFF_ICON"
        
        echo "Failed to pair with $device"
    fi
}

# Function to show Bluetooth information
show_bluetooth_info() {
    # Check if bluetoothctl is installed
    check_bluetoothctl
    
    # Get Bluetooth status
    local status=$(get_bluetooth_status)
    
    # Get paired devices
    local paired_devices=$(get_paired_devices)
    
    # Get connected devices
    local connected_devices=$(get_connected_devices)
    
    # Show Bluetooth information
    notify-send "Bluetooth Manager" "Status: $status\nPaired Devices: $paired_devices\nConnected Devices: $connected_devices" -i "$BLUETOOTH_ICON"
    
    # Return the values for display
    echo "Status: $status | Paired Devices: $paired_devices | Connected Devices: $connected_devices"
}

# Main function
main() {
    # Check the argument
    case "$1" in
        "status")
            get_bluetooth_status
            ;;
        "toggle")
            toggle_bluetooth
            ;;
        "paired")
            get_paired_devices
            ;;
        "connected")
            get_connected_devices
            ;;
        "connect")
            connect_to_device
            ;;
        "disconnect")
            disconnect_from_device
            ;;
        "scan")
            scan_for_devices
            ;;
        "pair")
            pair_with_device
            ;;
        "info")
            show_bluetooth_info
            ;;
        *)
            # Show a menu
            choice=$(echo -e "Show Bluetooth Status\nToggle Bluetooth\nShow Paired Devices\nShow Connected Devices\nConnect to Device\nDisconnect from Device\nScan for Devices\nPair with Device\nShow Bluetooth Information" | wofi --dmenu --prompt "Bluetooth Manager" --style "$HOME/.config/wofi/power-menu.css")
            
            case "$choice" in
                "Show Bluetooth Status")
                    get_bluetooth_status
                    ;;
                "Toggle Bluetooth")
                    toggle_bluetooth
                    ;;
                "Show Paired Devices")
                    get_paired_devices
                    ;;
                "Show Connected Devices")
                    get_connected_devices
                    ;;
                "Connect to Device")
                    connect_to_device
                    ;;
                "Disconnect from Device")
                    disconnect_from_device
                    ;;
                "Scan for Devices")
                    scan_for_devices
                    ;;
                "Pair with Device")
                    pair_with_device
                    ;;
                "Show Bluetooth Information")
                    show_bluetooth_info
                    ;;
            esac
            ;;
    esac
}

# Run the main function
main "$@" 