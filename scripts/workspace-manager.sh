#!/bin/bash

# Dynamic Workspace Manager for Hyprland
# -------------------------------------
# This script provides a visual way to manage and navigate between workspaces
# Features:
# - Visual workspace switcher
# - Drag and drop window movement between workspaces
# - Workspace thumbnails
# - Custom workspace naming

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONFIG_DIR="$HOME/.config/hypr"
WORKSPACE_CONFIG="$CONFIG_DIR/workspaces.conf"
TEMP_DIR="/tmp/hypr-workspace-manager"
SCREENSHOT_DIR="$TEMP_DIR/screenshots"

# Create temporary directories
mkdir -p "$TEMP_DIR"
mkdir -p "$SCREENSHOT_DIR"

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    for cmd in hyprctl grim slurp jq wofi convert; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done
    
    # If any dependencies are missing, print a message
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_message "$RED" "The following dependencies are missing:"
        for dep in "${missing_deps[@]}"; do
            print_message "$RED" "  - $dep"
        done
        
        print_message "$YELLOW" "Please install the missing dependencies and try again."
        print_message "$YELLOW" "For Arch Linux: sudo pacman -S ${missing_deps[*]}"
        
        exit 1
    fi
}

# Function to load workspace configuration
load_workspace_config() {
    # Create default configuration if it doesn't exist
    if [ ! -f "$WORKSPACE_CONFIG" ]; then
        cat > "$WORKSPACE_CONFIG" << EOF
{
    "workspaces": {
        "1": {
            "name": "Main",
            "icon": "desktop",
            "color": "#ff6699"
        },
        "2": {
            "name": "Web",
            "icon": "web-browser",
            "color": "#66aaff"
        },
        "3": {
            "name": "Code",
            "icon": "code",
            "color": "#99cc33"
        },
        "4": {
            "name": "Media",
            "icon": "multimedia",
            "color": "#cc66ff"
        },
        "5": {
            "name": "Chat",
            "icon": "chat",
            "color": "#ffcc00"
        },
        "6": {
            "name": "Files",
            "icon": "folder",
            "color": "#ff9933"
        },
        "7": {
            "name": "Design",
            "icon": "design",
            "color": "#33cccc"
        },
        "8": {
            "name": "Games",
            "icon": "games",
            "color": "#ff3366"
        },
        "9": {
            "name": "Settings",
            "icon": "settings",
            "color": "#999999"
        },
        "10": {
            "name": "Misc",
            "icon": "misc",
            "color": "#66cc99"
        }
    }
}
EOF
    fi
    
    # Load configuration
    local config=$(cat "$WORKSPACE_CONFIG")
    echo "$config"
}

# Function to get active workspaces
get_active_workspaces() {
    hyprctl workspaces -j | jq -c '.'
}

# Function to get active windows
get_active_windows() {
    hyprctl clients -j | jq -c '.'
}

# Function to get current workspace
get_current_workspace() {
    hyprctl activeworkspace -j | jq -r '.id'
}

# Function to take a screenshot of a workspace
take_workspace_screenshot() {
    local workspace_id=$1
    local output_file="$SCREENSHOT_DIR/workspace_${workspace_id}.png"
    
    # Switch to the workspace
    hyprctl dispatch workspace "$workspace_id"
    
    # Wait for the workspace to become active
    sleep 0.2
    
    # Take a screenshot
    grim -o "$(hyprctl monitors -j | jq -r '.[0].name')" "$output_file"
    
    # Return the path to the screenshot
    echo "$output_file"
}

# Function to create workspace thumbnails
create_workspace_thumbnails() {
    local workspaces=$1
    local config=$2
    local current_workspace=$(get_current_workspace)
    
    # Create a temporary HTML file for the workspace selector
    local html_file="$TEMP_DIR/workspaces.html"
    
    # Start HTML file
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Workspace Selector</title>
    <style>
        body {
            background-color: #1a1a1a;
            color: #ffffff;
            font-family: 'JetBrains Mono', 'Noto Sans', sans-serif;
            margin: 0;
            padding: 20px;
        }
        .workspace-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            grid-gap: 15px;
            margin-bottom: 20px;
        }
        .workspace {
            background-color: #2a2a2a;
            border-radius: 10px;
            padding: 10px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .workspace:hover {
            background-color: #3a3a3a;
            transform: scale(1.05);
        }
        .workspace.active {
            border: 2px solid #ffffff;
            background-color: #3a3a3a;
        }
        .workspace-thumbnail {
            width: 100%;
            height: 120px;
            object-fit: cover;
            border-radius: 5px;
            margin-bottom: 10px;
        }
        .workspace-name {
            font-weight: bold;
            margin-bottom: 5px;
        }
        .workspace-info {
            font-size: 0.8em;
            color: #aaaaaa;
        }
        .workspace-color {
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
        }
        .window-count {
            position: absolute;
            top: 5px;
            right: 5px;
            background-color: rgba(0, 0, 0, 0.7);
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 0.7em;
        }
        .actions {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }
        .button {
            background-color: #444444;
            border: none;
            color: white;
            padding: 10px 15px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            margin: 4px 2px;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .button:hover {
            background-color: #555555;
        }
        .button.primary {
            background-color: #6272a4;
        }
        .button.primary:hover {
            background-color: #7384b6;
        }
    </style>
</head>
<body>
    <h1>Workspace Manager</h1>
    <div class="workspace-grid">
EOF
    
    # Process each workspace
    echo "$workspaces" | jq -c '.[]' | while read -r workspace; do
        local id=$(echo "$workspace" | jq -r '.id')
        local name=$(echo "$config" | jq -r ".workspaces[\"$id\"].name // \"Workspace $id\"")
        local icon=$(echo "$config" | jq -r ".workspaces[\"$id\"].icon // \"desktop\"")
        local color=$(echo "$config" | jq -r ".workspaces[\"$id\"].color // \"#6272a4\"")
        local window_count=$(echo "$workspace" | jq -r '.windows // 0')
        local is_active=$([ "$id" = "$current_workspace" ] && echo "active" || echo "")
        
        # Take a screenshot of the workspace
        local screenshot=$(take_workspace_screenshot "$id")
        
        # Add workspace to HTML
        cat >> "$html_file" << EOF
        <div class="workspace $is_active" onclick="selectWorkspace($id)">
            <div class="workspace-color" style="background-color: $color;"></div>
            <div class="window-count">$window_count windows</div>
            <img src="$screenshot" class="workspace-thumbnail" alt="Workspace $id">
            <div class="workspace-name">$name</div>
            <div class="workspace-info">Workspace $id</div>
        </div>
EOF
    done
    
    # Complete HTML file
    cat >> "$html_file" << EOF
    </div>
    <div class="actions">
        <button class="button" onclick="editWorkspaces()">Edit Workspaces</button>
        <button class="button" onclick="moveWindow()">Move Window</button>
        <button class="button" onclick="createWorkspace()">New Workspace</button>
        <button class="button primary" onclick="closeDialog()">Close</button>
    </div>
    
    <script>
        function selectWorkspace(id) {
            // Send workspace ID back to the script
            console.log("workspace:" + id);
            setTimeout(() => closeDialog(), 100);
        }
        
        function editWorkspaces() {
            console.log("edit");
            closeDialog();
        }
        
        function moveWindow() {
            console.log("move");
            closeDialog();
        }
        
        function createWorkspace() {
            console.log("create");
            closeDialog();
        }
        
        function closeDialog() {
            window.close();
        }
    </script>
</body>
</html>
EOF
    
    # Return the path to the HTML file
    echo "$html_file"
}

# Function to show workspace selector
show_workspace_selector() {
    # Load configuration
    local config=$(load_workspace_config)
    
    # Get active workspaces
    local workspaces=$(get_active_workspaces)
    
    # Create workspace thumbnails
    local html_file=$(create_workspace_thumbnails "$workspaces" "$config")
    
    # Show the workspace selector using a web browser
    if command_exists "firefox"; then
        firefox --new-window "file://$html_file" &
    elif command_exists "chromium"; then
        chromium --app="file://$html_file" &
    elif command_exists "brave"; then
        brave --app="file://$html_file" &
    else
        xdg-open "$html_file"
    fi
}

# Function to show a simplified workspace selector using wofi
show_simple_workspace_selector() {
    # Load configuration
    local config=$(load_workspace_config)
    
    # Get active workspaces
    local workspaces=$(get_active_workspaces)
    
    # Get current workspace
    local current_workspace=$(get_current_workspace)
    
    # Create a list of workspaces for wofi
    local workspace_list=""
    echo "$workspaces" | jq -c '.[]' | while read -r workspace; do
        local id=$(echo "$workspace" | jq -r '.id')
        local name=$(echo "$config" | jq -r ".workspaces[\"$id\"].name // \"Workspace $id\"")
        local window_count=$(echo "$workspace" | jq -r '.windows // 0')
        local is_active=$([ "$id" = "$current_workspace" ] && echo "* " || echo "")
        
        workspace_list+="${is_active}${id}: ${name} (${window_count} windows)\n"
    done
    
    # Show the workspace selector using wofi
    local selected=$(echo -e "$workspace_list" | wofi --dmenu --prompt "Select Workspace" --style "$HOME/.config/wofi/power-menu.css")
    
    # Extract the workspace ID from the selection
    if [ -n "$selected" ]; then
        local workspace_id=$(echo "$selected" | grep -o '^[*]\? *[0-9]\+' | tr -d '* ')
        
        # Switch to the selected workspace
        if [ -n "$workspace_id" ]; then
            hyprctl dispatch workspace "$workspace_id"
        fi
    fi
}

# Function to move the current window to another workspace
move_window_to_workspace() {
    # Load configuration
    local config=$(load_workspace_config)
    
    # Get active workspaces
    local workspaces=$(get_active_workspaces)
    
    # Get current window
    local current_window=$(hyprctl activewindow -j)
    local window_title=$(echo "$current_window" | jq -r '.title')
    local window_class=$(echo "$current_window" | jq -r '.class')
    
    # Create a list of workspaces for wofi
    local workspace_list=""
    echo "$workspaces" | jq -c '.[]' | while read -r workspace; do
        local id=$(echo "$workspace" | jq -r '.id')
        local name=$(echo "$config" | jq -r ".workspaces[\"$id\"].name // \"Workspace $id\"")
        local window_count=$(echo "$workspace" | jq -r '.windows // 0')
        
        workspace_list+="${id}: ${name} (${window_count} windows)\n"
    done
    
    # Show the workspace selector using wofi
    local selected=$(echo -e "$workspace_list" | wofi --dmenu --prompt "Move '$window_title' to Workspace" --style "$HOME/.config/wofi/power-menu.css")
    
    # Extract the workspace ID from the selection
    if [ -n "$selected" ]; then
        local workspace_id=$(echo "$selected" | grep -o '^[0-9]\+')
        
        # Move the window to the selected workspace
        if [ -n "$workspace_id" ]; then
            hyprctl dispatch movetoworkspace "$workspace_id"
            print_message "$GREEN" "Moved window to workspace $workspace_id"
        fi
    fi
}

# Function to edit workspace configuration
edit_workspace_configuration() {
    # Load configuration
    local config=$(load_workspace_config)
    
    # Get active workspaces
    local workspaces=$(get_active_workspaces)
    
    # Create a list of workspaces for wofi
    local workspace_list=""
    echo "$workspaces" | jq -c '.[]' | while read -r workspace; do
        local id=$(echo "$workspace" | jq -r '.id')
        local name=$(echo "$config" | jq -r ".workspaces[\"$id\"].name // \"Workspace $id\"")
        
        workspace_list+="${id}: ${name}\n"
    done
    
    # Show the workspace selector using wofi
    local selected=$(echo -e "$workspace_list" | wofi --dmenu --prompt "Edit Workspace" --style "$HOME/.config/wofi/power-menu.css")
    
    # Extract the workspace ID from the selection
    if [ -n "$selected" ]; then
        local workspace_id=$(echo "$selected" | grep -o '^[0-9]\+')
        
        if [ -n "$workspace_id" ]; then
            # Get current values
            local current_name=$(echo "$config" | jq -r ".workspaces[\"$workspace_id\"].name // \"Workspace $workspace_id\"")
            local current_icon=$(echo "$config" | jq -r ".workspaces[\"$workspace_id\"].icon // \"desktop\"")
            local current_color=$(echo "$config" | jq -r ".workspaces[\"$workspace_id\"].color // \"#6272a4\"")
            
            # Get new name
            local new_name=$(echo "$current_name" | wofi --dmenu --prompt "Workspace Name" --style "$HOME/.config/wofi/power-menu.css")
            
            if [ -n "$new_name" ]; then
                # Get new color
                local new_color=$(echo "$current_color" | wofi --dmenu --prompt "Workspace Color (hex)" --style "$HOME/.config/wofi/power-menu.css")
                
                # Update configuration
                local updated_config=$(echo "$config" | jq ".workspaces[\"$workspace_id\"].name = \"$new_name\" | .workspaces[\"$workspace_id\"].color = \"$new_color\"")
                
                # Save configuration
                echo "$updated_config" > "$WORKSPACE_CONFIG"
                
                print_message "$GREEN" "Updated workspace $workspace_id configuration"
            fi
        fi
    fi
}

# Function to create a new workspace
create_new_workspace() {
    # Get the next available workspace ID
    local next_id=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n | tail -n 1)
    next_id=$((next_id + 1))
    
    # Get workspace name
    local name=$(echo "New Workspace" | wofi --dmenu --prompt "Workspace Name" --style "$HOME/.config/wofi/power-menu.css")
    
    if [ -n "$name" ]; then
        # Get workspace color
        local color=$(echo "#6272a4" | wofi --dmenu --prompt "Workspace Color (hex)" --style "$HOME/.config/wofi/power-menu.css")
        
        # Load configuration
        local config=$(load_workspace_config)
        
        # Update configuration
        local updated_config=$(echo "$config" | jq ".workspaces[\"$next_id\"] = {\"name\": \"$name\", \"icon\": \"desktop\", \"color\": \"$color\"}")
        
        # Save configuration
        echo "$updated_config" > "$WORKSPACE_CONFIG"
        
        # Switch to the new workspace
        hyprctl dispatch workspace "$next_id"
        
        print_message "$GREEN" "Created new workspace $next_id: $name"
    fi
}

# Function to show help
show_help() {
    echo "Dynamic Workspace Manager for Hyprland"
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --select    Show workspace selector"
    echo "  --simple    Show simplified workspace selector"
    echo "  --move      Move current window to another workspace"
    echo "  --edit      Edit workspace configuration"
    echo "  --create    Create a new workspace"
    echo "  --help      Show this help message"
    echo ""
}

# Clean up temporary files
cleanup() {
    rm -rf "$TEMP_DIR"
}

# Set trap to clean up on exit
trap cleanup EXIT

# Main function
main() {
    # Check dependencies
    check_dependencies
    
    # Parse command-line arguments
    case "$1" in
        --select)
            show_workspace_selector
            ;;
        --simple)
            show_simple_workspace_selector
            ;;
        --move)
            move_window_to_workspace
            ;;
        --edit)
            edit_workspace_configuration
            ;;
        --create)
            create_new_workspace
            ;;
        --help)
            show_help
            ;;
        *)
            # Default to simple selector
            show_simple_workspace_selector
            ;;
    esac
}

# Run the main function
main "$@" 