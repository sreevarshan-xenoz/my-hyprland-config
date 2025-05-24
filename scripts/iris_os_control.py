#!/usr/bin/env python3

import os
import json
import subprocess
import psutil
import shutil
from pathlib import Path

class IrisOSControl:
    def __init__(self, config_file):
        self.config_file = config_file
        self.load_config()
        
    def load_config(self):
        """Load Iris configuration"""
        with open(self.config_file, 'r') as f:
            self.config = json.load(f)
            
    def execute_command(self, command):
        """Execute a shell command and return output"""
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            return result.stdout.strip()
        except Exception as e:
            return f"Error executing command: {str(e)}"
            
    def get_system_info(self):
        """Get basic system information"""
        info = {
            "cpu_percent": psutil.cpu_percent(),
            "memory_percent": psutil.virtual_memory().percent,
            "disk_usage": psutil.disk_usage('/').percent,
            "battery": psutil.sensors_battery().percent if psutil.sensors_battery() else None
        }
        return info
        
    def control_audio(self, action, value=None):
        """Control audio settings"""
        if action == "volume":
            return self.execute_command(f"pactl set-sink-volume @DEFAULT_SINK@ {value}%")
        elif action == "mute":
            return self.execute_command("pactl set-sink-mute @DEFAULT_SINK@ toggle")
        elif action == "get_volume":
            return self.execute_command("pactl get-sink-volume @DEFAULT_SINK@")
            
    def control_brightness(self, value):
        """Control screen brightness"""
        return self.execute_command(f"brightnessctl set {value}%")
        
    def manage_processes(self, action, process_name=None):
        """Manage system processes"""
        if action == "list":
            return self.execute_command("ps aux")
        elif action == "kill" and process_name:
            return self.execute_command(f"pkill {process_name}")
            
    def manage_files(self, action, source=None, destination=None):
        """Manage files and directories"""
        if action == "list":
            return self.execute_command(f"ls -la {source}")
        elif action == "copy" and source and destination:
            shutil.copy2(source, destination)
            return f"Copied {source} to {destination}"
        elif action == "move" and source and destination:
            shutil.move(source, destination)
            return f"Moved {source} to {destination}"
        elif action == "delete" and source:
            os.remove(source)
            return f"Deleted {source}"
            
    def control_network(self, action, interface=None):
        """Control network settings"""
        if action == "status":
            return self.execute_command("nmcli device status")
        elif action == "connect" and interface:
            return self.execute_command(f"nmcli device connect {interface}")
        elif action == "disconnect" and interface:
            return self.execute_command(f"nmcli device disconnect {interface}")
            
    def control_power(self, action):
        """Control power settings"""
        if action == "shutdown":
            return self.execute_command("shutdown -h now")
        elif action == "reboot":
            return self.execute_command("reboot")
        elif action == "suspend":
            return self.execute_command("systemctl suspend")
            
    def get_weather(self, location=None):
        """Get weather information"""
        if location:
            return self.execute_command(f"curl wttr.in/{location}")
        return self.execute_command("curl wttr.in")
        
    def manage_wallpaper(self, action, path=None):
        """Manage wallpaper settings"""
        if action == "set" and path:
            return self.execute_command(f"swww img {path}")
        elif action == "random":
            return self.execute_command("swww img $(find ~/.config/hypr/wallpapers -type f | shuf -n 1)")
            
    def toggle_waybar(self):
        """Toggle Waybar visibility"""
        return self.execute_command("killall -SIGUSR1 waybar")
        
    def toggle_game_mode(self):
        """Toggle game mode"""
        return self.execute_command("~/.config/hypr/scripts/game-mode.sh")
        
    def get_help(self):
        """Get list of available commands"""
        return """
Available commands:
- system_info: Get system information
- audio_control: Control audio (volume, mute)
- brightness_control: Control screen brightness
- process_management: Manage processes
- file_management: Manage files and directories
- network_control: Control network settings
- power_control: Control power settings
- weather: Get weather information
- wallpaper: Manage wallpaper
- waybar: Toggle Waybar
- game_mode: Toggle game mode
""" 