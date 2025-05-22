#!/bin/bash

# Anime-themed Weather Widget Script
# --------------------------------
# This script fetches weather data and displays it with anime-themed icons

# Configuration
API_KEY="YOUR_OPENWEATHERMAP_API_KEY"  # Replace with your OpenWeatherMap API key
CITY="Tokyo"  # Default city (anime-themed)
UNITS="metric"  # metric or imperial
LANG="en"  # Language
CACHE_FILE="$HOME/.cache/weather.json"
CACHE_EXPIRY=1800  # Cache expiry in seconds (30 minutes)

# Anime-themed weather icons
declare -A WEATHER_ICONS
WEATHER_ICONS["Clear"]="☀️"  # Sunny day
WEATHER_ICONS["Clouds"]="☁️"  # Cloudy
WEATHER_ICONS["Rain"]="🌧️"  # Rain
WEATHER_ICONS["Drizzle"]="🌦️"  # Light rain
WEATHER_ICONS["Thunderstorm"]="⛈️"  # Thunderstorm
WEATHER_ICONS["Snow"]="❄️"  # Snow
WEATHER_ICONS["Mist"]="🌫️"  # Mist
WEATHER_ICONS["Smoke"]="🌫️"  # Smoke
WEATHER_ICONS["Haze"]="🌫️"  # Haze
WEATHER_ICONS["Dust"]="🌫️"  # Dust
WEATHER_ICONS["Fog"]="🌫️"  # Fog
WEATHER_ICONS["Sand"]="🌫️"  # Sand
WEATHER_ICONS["Ash"]="🌫️"  # Ash
WEATHER_ICONS["Squall"]="💨"  # Squall
WEATHER_ICONS["Tornado"]="🌪️"  # Tornado

# Function to get weather data
get_weather() {
    # Check if cache exists and is not expired
    if [ -f "$CACHE_FILE" ]; then
        local cache_time=$(stat -c %Y "$CACHE_FILE")
        local current_time=$(date +%s)
        local time_diff=$((current_time - cache_time))
        
        if [ $time_diff -lt $CACHE_EXPIRY ]; then
            cat "$CACHE_FILE"
            return
        fi
    fi
    
    # Fetch weather data from OpenWeatherMap API
    local weather_data=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=$CITY&appid=$API_KEY&units=$UNITS&lang=$LANG")
    
    # Save to cache
    echo "$weather_data" > "$CACHE_FILE"
    
    echo "$weather_data"
}

# Function to format weather data
format_weather() {
    local weather_data="$1"
    
    # Extract weather information
    local temp=$(echo "$weather_data" | jq -r '.main.temp')
    local feels_like=$(echo "$weather_data" | jq -r '.main.feels_like')
    local humidity=$(echo "$weather_data" | jq -r '.main.humidity')
    local wind_speed=$(echo "$weather_data" | jq -r '.wind.speed')
    local weather_main=$(echo "$weather_data" | jq -r '.weather[0].main')
    local weather_desc=$(echo "$weather_data" | jq -r '.weather[0].description')
    local city_name=$(echo "$weather_data" | jq -r '.name')
    
    # Get the appropriate icon
    local icon=${WEATHER_ICONS[$weather_main]}
    if [ -z "$icon" ]; then
        icon="🌈"  # Default icon
    fi
    
    # Format the output for waybar
    local waybar_output="{\"text\": \"$icon $temp°C\", \"tooltip\": \"$city_name: $weather_desc\\nTemperature: $temp°C\\nFeels like: $feels_like°C\\nHumidity: $humidity%\\nWind: $wind_speed m/s\"}"
    
    echo "$waybar_output"
}

# Main function
main() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "{\"text\": \"❌ jq not installed\", \"tooltip\": \"Please install jq to use this widget\"}"
        exit 1
    fi
    
    # Check if API key is set
    if [ "$API_KEY" = "YOUR_OPENWEATHERMAP_API_KEY" ]; then
        echo "{\"text\": \"❌ API key not set\", \"tooltip\": \"Please set your OpenWeatherMap API key in the script\"}"
        exit 1
    fi
    
    # Get weather data
    local weather_data=$(get_weather)
    
    # Check if weather data is valid
    if [ -z "$weather_data" ] || [ "$(echo "$weather_data" | jq -r '.cod')" != "200" ]; then
        echo "{\"text\": \"❌ Weather error\", \"tooltip\": \"Failed to fetch weather data\"}"
        exit 1
    fi
    
    # Format and output weather data
    format_weather "$weather_data"
}

# Run the main function
main 