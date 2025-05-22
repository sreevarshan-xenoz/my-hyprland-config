#!/bin/bash

# Anime-themed Clock Widget Script
# ------------------------------
# This script displays the current time with anime-themed styling

# Configuration
TIME_FORMAT="%H:%M"
DATE_FORMAT="%Y-%m-%d"
DAY_FORMAT="%A"
ANIME_QUOTES_FILE="$HOME/.config/hypr/scripts/anime-quotes.txt"

# Function to get a random anime quote
get_anime_quote() {
    if [ -f "$ANIME_QUOTES_FILE" ]; then
        # Get a random line from the quotes file
        local quote=$(shuf -n 1 "$ANIME_QUOTES_FILE")
        echo "$quote"
    else
        # Create the quotes file if it doesn't exist
        mkdir -p "$(dirname "$ANIME_QUOTES_FILE")"
        cat > "$ANIME_QUOTES_FILE" << EOF
"Believe in yourself. Not in the you who believes in me. Not in the me who believes in you. Believe in the you who believes in yourself." - Kamina, Gurren Lagann
"People die when they are killed." - Shirou Emiya, Fate/stay night
"It's not about how hard you hit. It's about how hard you can get hit and keep moving forward." - Rocky Balboa, Rocky
"The world isn't perfect. But it's there for us, doing the best it can. That's what makes it so damn beautiful." - Roy Mustang, Fullmetal Alchemist
"Sometimes I do feel like I'm a failure. Like there's no hope for me. But even so, I'm not gonna give up. Ever!" - Izuku Midoriya, My Hero Academia
"Life is not a game of luck. If you wanna win, work hard." - Sora, No Game No Life
"I'm not a hero. I'm a high school student who likes to help people." - Izuku Midoriya, My Hero Academia
"The only ones who should kill are those prepared to be killed." - Lelouch Lamperouge, Code Geass
"Hard work betrays none, but dreams betray many." - Hachiman Hikigaya, My Teen Romantic Comedy SNAFU
"People's lives don't end when they die. It ends when they lose faith." - Itachi Uchiha, Naruto
EOF
        # Get a random line from the newly created quotes file
        local quote=$(shuf -n 1 "$ANIME_QUOTES_FILE")
        echo "$quote"
    fi
}

# Function to get the current time with anime-themed styling
get_time() {
    local current_time=$(date +"$TIME_FORMAT")
    local current_date=$(date +"$DATE_FORMAT")
    local current_day=$(date +"$DAY_FORMAT")
    
    # Get a random anime quote
    local quote=$(get_anime_quote)
    
    # Format the output for waybar
    local waybar_output="{\"text\": \"🕒 $current_time\", \"tooltip\": \"$current_day, $current_date\\n\\n$quote\"}"
    
    echo "$waybar_output"
}

# Main function
main() {
    # Get the current time
    get_time
}

# Run the main function
main 