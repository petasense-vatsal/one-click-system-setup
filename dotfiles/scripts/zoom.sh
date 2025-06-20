#!/bin/bash

# Define your meeting mappings here
declare -A meetings
meetings["570"]="https://zoom.us/wc/join/5701573159?pwd=JrsqkDvQrXIaXlieb8kQ4QZDRnoZWu.1"
meetings["386"]="https://zoom.us/wc/join/3866392056?pwd=WHdoamFjeWV0UWxFTzVieFZhdGZFZz09#success"
meetings["296"]="https://zoom.us/wc/join/2967900418?pwd=MoteTx123%21"

key="$1"

if [[ -z "$key" ]]; then
    echo "Usage: zoom <shortcut>"
    echo "Available shortcuts:"
    for k in "${!meetings[@]}"; do
        echo "  $k"
    done
    exit 1
fi

url="${meetings[$key]}"

if [[ -z "$url" ]]; then
    echo "No meeting found for shortcut: $key"
    exit 1
fi

# Determine the default browser
browser=$(xdg-settings get default-web-browser 2>/dev/null || echo "firefox.desktop")

# Extract the browser name from the .desktop file
browser_name="${browser%.desktop}"

# Set environment variables for hyprctl to work properly
# Get the correct instance signature dynamically
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    # Find the active Hyprland instance
    ACTIVE_INSTANCE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
    export HYPRLAND_INSTANCE_SIGNATURE="$ACTIVE_INSTANCE"
else
    export HYPRLAND_INSTANCE_SIGNATURE="${HYPRLAND_INSTANCE_SIGNATURE}"
fi

# Switch to the zoom special workspace first
if command -v hyprctl >/dev/null 2>&1 && [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "Switching to zoom workspace..."
    hyprctl dispatch workspace special:zoom 2>/dev/null || true
fi

# Then open the URL in a new browser window
case "$browser_name" in
    firefox)
        nohup firefox --new-window "$url" > /dev/null 2>&1 &
        ;;
    google-chrome|chrome)
        nohup google-chrome-stable --new-window "$url" > /dev/null 2>&1 &
        ;;
    chromium)
        nohup chromium --new-window "$url" > /dev/null 2>&1 &
        ;;
    brave)
        nohup brave --new-window "$url" > /dev/null 2>&1 &
        ;;
    *)
        # Fallback to xdg-open if the browser is unrecognized
        nohup xdg-open "$url" > /dev/null 2>&1 &
        ;;
esac 