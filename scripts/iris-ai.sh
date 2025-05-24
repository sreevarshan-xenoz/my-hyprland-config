#!/bin/bash

# Iris AI Assistant for Hyprland
# -----------------------------
# A local AI assistant that can control various aspects of the OS
# Supports multiple lightweight models based on hardware capabilities

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
LOG_FILE="$IRIS_CONFIG_DIR/iris.log"

# Available models and their requirements
declare -A MODEL_REQUIREMENTS=(
    ["phi2"]="2GB RAM, 2GB Storage"
    ["gemma2b"]="4GB RAM, 4GB Storage"
    ["qwen2.5-0.5b"]="2GB RAM, 2GB Storage"
)

# Print a header
print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  Iris AI Assistant Setup  ${NC}"
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
    }
    
    return 0
}

# Create necessary directories
create_directories() {
    print_section "Creating directories"
    
    mkdir -p "$IRIS_CONFIG_DIR"
    mkdir -p "$MODELS_DIR"
    
    print_success "Created Iris configuration directories"
}

# Initialize configuration file
init_config() {
    print_section "Initializing configuration"
    
    cat > "$CONFIG_FILE" << EOF
{
    "model": "",
    "model_path": "",
    "temperature": 0.7,
    "max_tokens": 512,
    "system_prompt": "You are Iris, a helpful AI assistant for Hyprland. You can control various aspects of the operating system and help users with their tasks.",
    "capabilities": {
        "system_control": true,
        "file_management": true,
        "process_management": true,
        "network_control": true,
        "audio_control": true,
        "voice_control": true
    },
    "voice": {
        "model": "en-US",
        "speed": 1.0,
        "volume": 1.0,
        "pitch": 1.0,
        "gender": "female",
        "anime_voice": false,
        "anime_voice_style": "kawaii"
    }
}
EOF
    
    print_success "Created configuration file"
}

# Install required Python packages
install_dependencies() {
    print_section "Installing Python dependencies"
    
    pip3 install --user transformers torch accelerate sentencepiece protobuf
    
    print_success "Installed required Python packages"
}

# Install voice dependencies
install_voice_dependencies() {
    print_section "Installing voice dependencies"
    
    pip3 install --user SpeechRecognition gTTS pygame numpy sounddevice
    
    print_success "Installed voice dependencies"
}

# Download selected model
download_model() {
    local model=$1
    print_section "Downloading model: $model"
    
    case $model in
        "phi2")
            python3 -c "
from transformers import AutoModelForCausalLM, AutoTokenizer
model = AutoModelForCausalLM.from_pretrained('microsoft/phi-2')
tokenizer = AutoTokenizer.from_pretrained('microsoft/phi-2')
model.save_pretrained('$MODELS_DIR/phi2')
tokenizer.save_pretrained('$MODELS_DIR/phi2')
"
            ;;
        "gemma2b")
            python3 -c "
from transformers import AutoModelForCausalLM, AutoTokenizer
model = AutoModelForCausalLM.from_pretrained('google/gemma-2b')
tokenizer = AutoTokenizer.from_pretrained('google/gemma-2b')
model.save_pretrained('$MODELS_DIR/gemma2b')
tokenizer.save_pretrained('$MODELS_DIR/gemma2b')
"
            ;;
        "qwen2.5-0.5b")
            python3 -c "
from transformers import AutoModelForCausalLM, AutoTokenizer
model = AutoModelForCausalLM.from_pretrained('Qwen/Qwen1.5-0.5B')
tokenizer = AutoTokenizer.from_pretrained('Qwen/Qwen1.5-0.5B')
model.save_pretrained('$MODELS_DIR/qwen2.5-0.5b')
tokenizer.save_pretrained('$MODELS_DIR/qwen2.5-0.5b')
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

# Main setup function
setup_iris() {
    print_header
    
    # Check system requirements
    if ! check_system_requirements; then
        print_error "System requirements not met"
        exit 1
    fi
    
    # Create directories
    create_directories
    
    # Initialize configuration
    init_config
    
    # Install dependencies
    install_dependencies
    
    # Install voice dependencies
    install_voice_dependencies
    
    # Show available models
    print_section "Available Models"
    for model in "${!MODEL_REQUIREMENTS[@]}"; do
        echo -e "${YELLOW}$model${NC}: ${MODEL_REQUIREMENTS[$model]}"
    done
    
    # Get user's model choice
    read -p "Enter the model you want to use (phi2/gemma2b/qwen2.5-0.5b): " chosen_model
    
    # Download selected model
    if [[ -n "${MODEL_REQUIREMENTS[$chosen_model]}" ]]; then
        download_model "$chosen_model"
    else
        print_error "Invalid model choice"
        exit 1
    fi
    
    # Ask about voice capabilities
    print_section "Voice Capabilities"
    read -p "Do you want to enable voice capabilities? (y/n): " enable_voice
    
    if [[ "$enable_voice" == "y" || "$enable_voice" == "Y" ]]; then
        # Enable voice capabilities
        jq '.capabilities.voice_control = true' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
        mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        # Ask about anime voice
        read -p "Do you want to enable anime voice style? (y/n): " enable_anime_voice
        
        if [[ "$enable_anime_voice" == "y" || "$enable_anime_voice" == "Y" ]]; then
            # Enable anime voice
            jq '.voice.anime_voice = true' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            
            # Show available anime voice styles
            echo -e "${YELLOW}Available anime voice styles:${NC}"
            echo -e "1. kawaii - Cute and high-pitched"
            echo -e "2. tsundere - Slightly higher pitch, normal speed"
            echo -e "3. yandere - Lower pitch, slower speed"
            echo -e "4. kuudere - Lower pitch, normal speed"
            echo -e "5. senpai - Slightly higher pitch, slower speed"
            
            # Get user's anime voice style choice
            read -p "Enter the anime voice style you want to use (1-5): " anime_voice_style_choice
            
            case $anime_voice_style_choice in
                1) anime_voice_style="kawaii" ;;
                2) anime_voice_style="tsundere" ;;
                3) anime_voice_style="yandere" ;;
                4) anime_voice_style="kuudere" ;;
                5) anime_voice_style="senpai" ;;
                *) anime_voice_style="kawaii" ;;
            esac
            
            # Set anime voice style
            jq --arg style "$anime_voice_style" '.voice.anime_voice_style = $style' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        fi
    else
        # Disable voice capabilities
        jq '.capabilities.voice_control = false' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
        mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    print_success "Iris AI Assistant setup complete!"
}

# Start Iris AI
start_iris() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Iris is not configured. Please run setup first."
        exit 1
    fi
    
    # Load configuration
    model=$(jq -r '.model' "$CONFIG_FILE")
    model_path=$(jq -r '.model_path' "$CONFIG_FILE")
    voice_control=$(jq -r '.capabilities.voice_control' "$CONFIG_FILE")
    
    # Start the AI assistant
    python3 -c "
import json
import torch
import sys
import os
from transformers import AutoModelForCausalLM, AutoTokenizer

# Add the scripts directory to the path
sys.path.append(os.path.dirname(os.path.abspath('$0')))
from iris_os_control import IrisOSControl

# Load configuration
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

# Load model and tokenizer
model = AutoModelForCausalLM.from_pretrained('$model_path')
tokenizer = AutoTokenizer.from_pretrained('$model_path')

# Initialize OS control
os_control = IrisOSControl('$CONFIG_FILE')

# Initialize voice if enabled
voice_enabled = config['capabilities'].get('voice_control', False)
if voice_enabled:
    try:
        from iris_voice import IrisVoice
        voice = IrisVoice('$CONFIG_FILE')
        print('Voice capabilities enabled')
    except ImportError:
        print('Voice module not found. Voice capabilities disabled.')
        voice_enabled = False
else:
    voice_enabled = False

# Process user input
def process_input(user_input):
    # Generate response
    inputs = tokenizer(user_input, return_tensors='pt')
    outputs = model.generate(
        inputs['input_ids'],
        max_length=config['max_tokens'],
        temperature=config['temperature']
    )
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    # Speak the response if voice is enabled
    if voice_enabled:
        voice.speak(response)
    
    return response

# Voice command callback
def voice_command_callback(text):
    print(f'Voice command: {text}')
    response = process_input(text)
    print(f'Iris: {response}')

# Main interaction loop
print('Iris AI Assistant is ready! Type \"exit\" to quit.')
print('Type \"voice on\" to enable voice commands or \"voice off\" to disable them.')

# Start voice listening if enabled
if voice_enabled:
    voice.listen(voice_command_callback)
    print('Voice commands enabled. Say \"Iris\" followed by your command.')

while True:
    user_input = input('You: ')
    if user_input.lower() == 'exit':
        break
    elif user_input.lower() == 'voice on' and not voice_enabled:
        try:
            from iris_voice import IrisVoice
            voice = IrisVoice('$CONFIG_FILE')
            voice.listen(voice_command_callback)
            voice_enabled = True
            print('Voice commands enabled. Say \"Iris\" followed by your command.')
        except ImportError:
            print('Voice module not found. Voice capabilities disabled.')
    elif user_input.lower() == 'voice off' and voice_enabled:
        voice.stop_listening()
        voice_enabled = False
        print('Voice commands disabled.')
    else:
        response = process_input(user_input)
        print(f'Iris: {response}')

# Stop voice listening if enabled
if voice_enabled:
    voice.stop_listening()
"
}

# Main function
main() {
    case "$1" in
        "setup")
            setup_iris
            ;;
        "start")
            start_iris
            ;;
        *)
            echo "Usage: $0 {setup|start}"
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 