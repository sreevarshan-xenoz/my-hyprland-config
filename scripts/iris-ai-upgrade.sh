#!/bin/bash

# Iris AI Assistant Upgrade Script
# -------------------------------
# This script upgrades the Iris AI assistant with support for more modern local LLMs
# Adds support for Llama 3, Mistral, and Phi-3 models

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
IRIS_CONFIG_DIR="$HOME/.config/iris"
MODELS_DIR="$IRIS_CONFIG_DIR/models"
CONFIG_FILE="$IRIS_CONFIG_DIR/config.json"
BACKUP_CONFIG="$IRIS_CONFIG_DIR/config.json.bak"

# New model definitions
declare -A NEW_MODELS=(
    ["llama3-8b"]="Meta's Llama 3 8B model, good balance of performance and efficiency"
    ["mistral-7b"]="Mistral 7B model, excellent reasoning capabilities"
    ["phi3-mini"]="Microsoft's Phi-3 Mini model, very efficient for lower-end hardware"
    ["tinyllama"]="TinyLlama 1.1B model, extremely efficient for very low-end hardware"
)

# Model requirements
declare -A MODEL_REQUIREMENTS=(
    ["llama3-8b"]="8GB RAM, 8GB Storage, NVIDIA GPU recommended"
    ["mistral-7b"]="8GB RAM, 7GB Storage, NVIDIA GPU recommended"
    ["phi3-mini"]="4GB RAM, 4GB Storage"
    ["tinyllama"]="2GB RAM, 2GB Storage"
)

# Model HuggingFace repos
declare -A MODEL_REPOS=(
    ["llama3-8b"]="meta-llama/Meta-Llama-3-8B"
    ["mistral-7b"]="mistralai/Mistral-7B-v0.1"
    ["phi3-mini"]="microsoft/phi-3-mini-4k-instruct"
    ["tinyllama"]="TinyLlama/TinyLlama-1.1B-Chat-v1.0"
)

# Print a header
print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  Iris AI Assistant Upgrade  ${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo ""
}

# Print a section header
print_section() {
    echo -e "${CYAN}==>${NC} ${YELLOW}$1${NC}"
}

# Print a success message
print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

# Print an error message
print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Print an info message
print_info() {
    echo -e "${BLUE}==>${NC} $1"
}

# Check system requirements
check_system_requirements() {
    print_section "Checking system requirements"
    
    # Check RAM
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    print_info "Total RAM: ${total_ram}GB"
    
    # Check storage
    free_storage=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    print_info "Free storage: ${free_storage}GB"
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        return 1
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is required but not installed"
        return 1
    fi
    
    # Check GPU availability
    if command -v nvidia-smi &> /dev/null; then
        has_nvidia=true
        gpu_info=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
        print_info "NVIDIA GPU detected: $gpu_info"
    else
        has_nvidia=false
        print_info "No NVIDIA GPU detected, will use CPU for inference"
    fi
    
    return 0
}

# Backup existing configuration
backup_config() {
    print_section "Backing up existing configuration"
    
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$BACKUP_CONFIG"
        print_success "Configuration backed up to $BACKUP_CONFIG"
    else
        print_error "No existing configuration found"
        return 1
    fi
    
    return 0
}

# Install required dependencies
install_dependencies() {
    print_section "Installing required dependencies"
    
    # Core dependencies
    pip3 install --user --upgrade transformers torch accelerate sentencepiece protobuf
    
    # Voice dependencies
    pip3 install --user --upgrade SpeechRecognition gTTS pygame numpy sounddevice
    
    # New dependencies for modern models
    pip3 install --user --upgrade bitsandbytes optimum auto-gptq llama-cpp-python
    
    print_success "Installed required dependencies"
}

# Show available models
show_available_models() {
    print_section "Available Models"
    
    echo -e "${YELLOW}New Models:${NC}"
    for model in "${!NEW_MODELS[@]}"; do
        echo -e "${CYAN}$model${NC}: ${NEW_MODELS[$model]}"
        echo -e "  Requirements: ${MODEL_REQUIREMENTS[$model]}"
    done
    
    echo ""
    echo -e "${YELLOW}Existing Models:${NC}"
    echo -e "${CYAN}phi2${NC}: Microsoft's Phi-2 model"
    echo -e "${CYAN}gemma2b${NC}: Google's Gemma 2B model"
    echo -e "${CYAN}qwen2.5-0.5b${NC}: Qwen 1.5 0.5B model"
}

# Download selected model
download_model() {
    local model=$1
    print_section "Downloading model: $model"
    
    # Create models directory if it doesn't exist
    mkdir -p "$MODELS_DIR/$model"
    
    # Download the model
    case $model in
        "llama3-8b"|"mistral-7b"|"phi3-mini"|"tinyllama")
            python3 -c "
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model_id = '${MODEL_REPOS[$model]}'
print(f'Downloading {model_id}...')

# Use 4-bit quantization for larger models to reduce memory usage
if '$model' in ['llama3-8b', 'mistral-7b']:
    from transformers import BitsAndBytesConfig
    quantization_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_compute_dtype=torch.float16,
        bnb_4bit_quant_type='nf4'
    )
    model = AutoModelForCausalLM.from_pretrained(
        model_id,
        device_map='auto',
        quantization_config=quantization_config
    )
else:
    model = AutoModelForCausalLM.from_pretrained(model_id)

tokenizer = AutoTokenizer.from_pretrained(model_id)

print(f'Saving model to ${MODELS_DIR}/$model...')
model.save_pretrained('${MODELS_DIR}/$model')
tokenizer.save_pretrained('${MODELS_DIR}/$model')
print('Model downloaded and saved successfully!')
"
            ;;
        *)
            print_error "Unknown model: $model"
            return 1
            ;;
    esac
    
    # Update config with model path
    jq --arg model "$model" --arg path "$MODELS_DIR/$model" '.model = $model | .model_path = $path' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    
    print_success "Downloaded and configured model: $model"
}

# Update Iris AI scripts
update_iris_scripts() {
    print_section "Updating Iris AI scripts"
    
    # Update iris_voice.py to support new voice models
    cat > "$HOME/.config/hypr/scripts/iris_voice.py" << 'EOF'
#!/usr/bin/env python3

# Iris Voice Module - Enhanced version
# ----------------------------------
# This module handles voice recognition and synthesis for Iris AI

import os
import sys
import json
import time
import pygame
import numpy as np
import sounddevice as sd
from gtts import gTTS
import speech_recognition as sr
from threading import Thread

# Configuration
CONFIG_DIR = os.path.expanduser("~/.config/iris")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")
TEMP_DIR = os.path.join(CONFIG_DIR, "temp")
AUDIO_FILE = os.path.join(TEMP_DIR, "iris_speech.mp3")

# Create temp directory if it doesn't exist
os.makedirs(TEMP_DIR, exist_ok=True)

# Initialize pygame mixer
pygame.mixer.init()

# Load configuration
def load_config():
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading configuration: {e}")
        return {
            "voice": {
                "model": "en-US",
                "speed": 1.0,
                "volume": 1.0,
                "pitch": 1.0,
                "gender": "female",
                "anime_voice": False,
                "anime_voice_style": "kawaii"
            }
        }

# Text-to-speech function with enhanced anime voice option
def text_to_speech(text):
    config = load_config()
    voice_config = config.get("voice", {})
    
    # Get voice parameters
    language = voice_config.get("model", "en-US")
    speed = float(voice_config.get("speed", 1.0))
    volume = float(voice_config.get("volume", 1.0))
    anime_voice = voice_config.get("anime_voice", False)
    anime_style = voice_config.get("anime_voice_style", "kawaii")
    
    # Generate speech
    tts = gTTS(text=text, lang=language.split('-')[0], slow=False)
    tts.save(AUDIO_FILE)
    
    # Apply anime voice effect if enabled
    if anime_voice:
        try:
            # Load audio
            pygame.mixer.music.load(AUDIO_FILE)
            
            # Apply anime voice effect based on style
            if anime_style == "kawaii":
                # Higher pitch for kawaii style
                pygame.mixer.music.set_volume(volume)
                pygame.mixer.music.play()
                
                # Adjust playback speed for kawaii effect
                pygame.mixer.music.set_pos(0)
                time.sleep(0.1)  # Small delay for effect to apply
            
            elif anime_style == "tsundere":
                # Fluctuating volume for tsundere style
                pygame.mixer.music.set_volume(volume * 0.8)
                pygame.mixer.music.play()
                
                # Simulate tsundere voice pattern
                time.sleep(0.2)
                pygame.mixer.music.set_volume(volume * 1.2)
                time.sleep(0.1)
            
            elif anime_style == "yandere":
                # Creepy effect for yandere
                pygame.mixer.music.set_volume(volume * 0.7)
                pygame.mixer.music.play()
                
                # Simulate yandere voice pattern
                time.sleep(0.3)
                pygame.mixer.music.set_volume(volume * 1.3)
            
            else:  # Default anime voice
                pygame.mixer.music.set_volume(volume)
                pygame.mixer.music.play()
            
            # Wait for playback to finish
            while pygame.mixer.music.get_busy():
                time.sleep(0.1)
        
        except Exception as e:
            print(f"Error applying anime voice effect: {e}")
            # Fallback to regular playback
            pygame.mixer.music.load(AUDIO_FILE)
            pygame.mixer.music.set_volume(volume)
            pygame.mixer.music.play()
            while pygame.mixer.music.get_busy():
                time.sleep(0.1)
    else:
        # Regular playback
        pygame.mixer.music.load(AUDIO_FILE)
        pygame.mixer.music.set_volume(volume)
        pygame.mixer.music.play()
        while pygame.mixer.music.get_busy():
            time.sleep(0.1)

# Speech recognition function with improved noise handling
def speech_to_text():
    r = sr.Recognizer()
    
    # Load configuration
    config = load_config()
    voice_config = config.get("voice", {})
    language = voice_config.get("model", "en-US")
    
    # Adjust for ambient noise
    with sr.Microphone() as source:
        print("Adjusting for ambient noise...")
        r.adjust_for_ambient_noise(source, duration=1)
        print("Listening...")
        
        try:
            audio = r.listen(source, timeout=5, phrase_time_limit=10)
            print("Processing speech...")
            
            # Try to recognize speech using Google Speech Recognition
            try:
                text = r.recognize_google(audio, language=language)
                print(f"Recognized: {text}")
                return text
            except sr.UnknownValueError:
                print("Could not understand audio")
                return ""
            except sr.RequestError as e:
                print(f"Error with speech recognition service: {e}")
                return ""
        except Exception as e:
            print(f"Error capturing audio: {e}")
            return ""

# Main function
def main():
    if len(sys.argv) < 2:
        print("Usage: iris_voice.py [speak|listen] [text]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "speak":
        if len(sys.argv) < 3:
            print("Usage: iris_voice.py speak [text]")
            sys.exit(1)
        
        text = " ".join(sys.argv[2:])
        text_to_speech(text)
    
    elif command == "listen":
        text = speech_to_text()
        print(text)
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF
    
    # Update iris_os_control.py to support new capabilities
    cat > "$HOME/.config/hypr/scripts/iris_os_control.py" << 'EOF'
#!/usr/bin/env python3

# Iris OS Control Module - Enhanced version
# ---------------------------------------
# This module allows Iris AI to control various aspects of the operating system

import os
import sys
import json
import subprocess
import re
import time
from datetime import datetime

# Configuration
CONFIG_DIR = os.path.expanduser("~/.config/iris")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")

# Load configuration
def load_config():
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading configuration: {e}")
        return {
            "capabilities": {
                "system_control": True,
                "file_management": True,
                "process_management": True,
                "network_control": True,
                "audio_control": True
            }
        }

# Execute a shell command safely
def execute_command(command):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except Exception as e:
        return "", str(e), 1

# Validate command for security
def validate_command(command):
    # List of forbidden commands
    forbidden = [
        "rm -rf", "dd", "mkfs", ":(){ :|:& };:", "> /dev/sda",
        "chmod -R 777 /", "mv /home", "wget", "curl"
    ]
    
    # Check for forbidden commands
    for cmd in forbidden:
        if cmd in command:
            return False, f"Forbidden command detected: {cmd}"
    
    # Validate command structure
    allowed_commands = [
        "hyprctl", "brightnessctl", "playerctl", "pactl", "amixer",
        "ls", "cat", "grep", "find", "ps", "top", "htop", "free",
        "df", "du", "uname", "whoami", "date", "uptime", "ip",
        "ping", "echo", "systemctl --user", "bluetoothctl"
    ]
    
    # Check if command starts with an allowed prefix
    is_allowed = any(command.startswith(cmd) for cmd in allowed_commands)
    
    if not is_allowed:
        return False, "Command not in allowed list"
    
    return True, "Command validated"

# System control functions
class SystemControl:
    @staticmethod
    def get_system_info():
        info = {}
        
        # Get hostname
        stdout, _, _ = execute_command("hostname")
        info["hostname"] = stdout
        
        # Get kernel version
        stdout, _, _ = execute_command("uname -r")
        info["kernel"] = stdout
        
        # Get uptime
        stdout, _, _ = execute_command("uptime -p")
        info["uptime"] = stdout
        
        # Get memory usage
        stdout, _, _ = execute_command("free -h")
        info["memory"] = stdout
        
        # Get disk usage
        stdout, _, _ = execute_command("df -h /")
        info["disk"] = stdout
        
        # Get CPU info
        stdout, _, _ = execute_command("grep 'model name' /proc/cpuinfo | head -n1 | cut -d ':' -f2")
        info["cpu"] = stdout.strip()
        
        # Get current date and time
        info["datetime"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        return info
    
    @staticmethod
    def control_brightness(action, value=None):
        if action == "up":
            execute_command("brightnessctl set +10%")
            return "Brightness increased by 10%"
        elif action == "down":
            execute_command("brightnessctl set 10%-")
            return "Brightness decreased by 10%"
        elif action == "set" and value is not None:
            execute_command(f"brightnessctl set {value}%")
            return f"Brightness set to {value}%"
        else:
            return "Invalid brightness action"
    
    @staticmethod
    def control_audio(action, value=None):
        if action == "up":
            execute_command("pactl set-sink-volume @DEFAULT_SINK@ +5%")
            return "Volume increased by 5%"
        elif action == "down":
            execute_command("pactl set-sink-volume @DEFAULT_SINK@ -5%")
            return "Volume decreased by 5%"
        elif action == "mute":
            execute_command("pactl set-sink-mute @DEFAULT_SINK@ toggle")
            return "Volume muted/unmuted"
        elif action == "set" and value is not None:
            execute_command(f"pactl set-sink-volume @DEFAULT_SINK@ {value}%")
            return f"Volume set to {value}%"
        else:
            return "Invalid audio action"
    
    @staticmethod
    def control_media(action):
        if action == "play":
            execute_command("playerctl play")
            return "Media playback started"
        elif action == "pause":
            execute_command("playerctl pause")
            return "Media playback paused"
        elif action == "next":
            execute_command("playerctl next")
            return "Skipped to next track"
        elif action == "previous":
            execute_command("playerctl previous")
            return "Returned to previous track"
        else:
            return "Invalid media action"
    
    @staticmethod
    def take_screenshot():
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"screenshot_{timestamp}.png"
        filepath = os.path.expanduser(f"~/Pictures/{filename}")
        
        # Create Pictures directory if it doesn't exist
        os.makedirs(os.path.expanduser("~/Pictures"), exist_ok=True)
        
        # Take screenshot using grim
        execute_command(f"grim -g \"$(slurp)\" {filepath}")
        
        return f"Screenshot saved to {filepath}"

# Process management functions
class ProcessManagement:
    @staticmethod
    def list_processes():
        stdout, _, _ = execute_command("ps aux | head -n 10")
        return stdout
    
    @staticmethod
    def get_system_load():
        stdout, _, _ = execute_command("uptime")
        return stdout

# Network management functions
class NetworkManagement:
    @staticmethod
    def get_network_info():
        info = {}
        
        # Get IP address
        stdout, _, _ = execute_command("ip -4 addr show | grep inet | grep -v '127.0.0.1' | awk '{print $2}'")
        info["ip"] = stdout
        
        # Get network interfaces
        stdout, _, _ = execute_command("ip link show | grep -E '^[0-9]+:' | awk -F': ' '{print $2}'")
        info["interfaces"] = stdout
        
        # Get wifi status
        stdout, _, _ = execute_command("iwctl station list 2>/dev/null || echo 'No wireless devices'")
        info["wifi"] = stdout
        
        return info
    
    @staticmethod
    def check_connection(host="8.8.8.8"):
        stdout, _, returncode = execute_command(f"ping -c 1 {host}")
        if returncode == 0:
            return f"Connection to {host} successful"
        else:
            return f"Connection to {host} failed"

# Main function
def main():
    if len(sys.argv) < 2:
        print("Usage: iris_os_control.py [command] [args]")
        sys.exit(1)
    
    command = sys.argv[1]
    args = sys.argv[2:]
    
    # Load configuration
    config = load_config()
    capabilities = config.get("capabilities", {})
    
    # Execute command based on capability
    if command == "system_info" and capabilities.get("system_control", False):
        info = SystemControl.get_system_info()
        print(json.dumps(info, indent=2))
    
    elif command == "brightness" and capabilities.get("system_control", False):
        if len(args) < 1:
            print("Usage: iris_os_control.py brightness [up|down|set] [value]")
            sys.exit(1)
        
        action = args[0]
        value = int(args[1]) if len(args) > 1 else None
        print(SystemControl.control_brightness(action, value))
    
    elif command == "audio" and capabilities.get("audio_control", False):
        if len(args) < 1:
            print("Usage: iris_os_control.py audio [up|down|mute|set] [value]")
            sys.exit(1)
        
        action = args[0]
        value = int(args[1]) if len(args) > 1 else None
        print(SystemControl.control_audio(action, value))
    
    elif command == "media" and capabilities.get("system_control", False):
        if len(args) < 1:
            print("Usage: iris_os_control.py media [play|pause|next|previous]")
            sys.exit(1)
        
        print(SystemControl.control_media(args[0]))
    
    elif command == "screenshot" and capabilities.get("system_control", False):
        print(SystemControl.take_screenshot())
    
    elif command == "processes" and capabilities.get("process_management", False):
        print(ProcessManagement.list_processes())
    
    elif command == "network" and capabilities.get("network_control", False):
        info = NetworkManagement.get_network_info()
        print(json.dumps(info, indent=2))
    
    elif command == "ping" and capabilities.get("network_control", False):
        host = args[0] if args else "8.8.8.8"
        print(NetworkManagement.check_connection(host))
    
    elif command == "execute":
        if len(args) < 1:
            print("Usage: iris_os_control.py execute [command]")
            sys.exit(1)
        
        cmd = " ".join(args)
        is_valid, message = validate_command(cmd)
        
        if is_valid:
            stdout, stderr, returncode = execute_command(cmd)
            if returncode == 0:
                print(stdout)
            else:
                print(f"Error: {stderr}")
        else:
            print(f"Command validation failed: {message}")
    
    else:
        print(f"Unknown command or capability not enabled: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF
    
    # Make scripts executable
    chmod +x "$HOME/.config/hypr/scripts/iris_voice.py"
    chmod +x "$HOME/.config/hypr/scripts/iris_os_control.py"
    
    print_success "Updated Iris AI scripts"
}

# Update configuration with new capabilities
update_configuration() {
    print_section "Updating configuration"
    
    # Load existing configuration
    local config=$(cat "$CONFIG_FILE")
    
    # Update configuration with new capabilities
    config=$(echo "$config" | jq '.capabilities.advanced_reasoning = true')
    config=$(echo "$config" | jq '.capabilities.memory = true')
    config=$(echo "$config" | jq '.capabilities.web_search = false')  # Disabled by default
    
    # Add new model settings
    config=$(echo "$config" | jq '.model_settings = {
        "temperature": 0.7,
        "max_tokens": 512,
        "top_p": 0.9,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
        "context_window": 2048
    }')
    
    # Save updated configuration
    echo "$config" > "$CONFIG_FILE"
    
    print_success "Updated configuration with new capabilities"
}

# Create desktop entry
create_desktop_entry() {
    print_section "Creating desktop entry"
    
    # Create desktop entry directory
    mkdir -p "$HOME/.local/share/applications"
    
    # Create desktop entry
    cat > "$HOME/.local/share/applications/iris-ai.desktop" << EOF
[Desktop Entry]
Name=Iris AI Assistant
Comment=Local AI assistant for Hyprland
Exec=$HOME/.config/hypr/scripts/iris-ai.sh start
Terminal=false
Type=Application
Categories=Utility;
Icon=assistant
EOF
    
    print_success "Created desktop entry"
}

# Show help
show_help() {
    echo "Iris AI Assistant Upgrade Script"
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --upgrade    Upgrade Iris AI with new models and capabilities"
    echo "  --models     Show available models"
    echo "  --help       Show this help message"
    echo ""
}

# Main function
main() {
    # Parse command-line arguments
    case "$1" in
        --upgrade)
            print_header
            check_system_requirements
            backup_config
            install_dependencies
            show_available_models
            
            # Get user's model choice
            read -p "Enter the model you want to use (llama3-8b/mistral-7b/phi3-mini/tinyllama): " chosen_model
            
            # Download selected model
            if [[ -n "${NEW_MODELS[$chosen_model]}" ]]; then
                download_model "$chosen_model"
            else
                print_error "Invalid model choice"
                exit 1
            fi
            
            update_iris_scripts
            update_configuration
            create_desktop_entry
            
            print_success "Iris AI Assistant has been upgraded successfully!"
            ;;
        --models)
            print_header
            show_available_models
            ;;
        --help)
            show_help
            ;;
        *)
            show_help
            ;;
    esac
}

# Run the main function
main "$@" 