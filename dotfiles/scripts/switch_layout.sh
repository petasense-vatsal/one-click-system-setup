#!/bin/bash

# Get all available monitors (both active and inactive)
# First try to get all monitors including disabled ones
ALL_MONITORS=($(hyprctl monitors all -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || hyprctl monitors -j | jq -r '.[].name'))

# If that fails, fall back to active monitors only
if [ ${#ALL_MONITORS[@]} -eq 0 ]; then
    ALL_MONITORS=($(hyprctl monitors -j | jq -r '.[].name'))
fi

# Check if we have at least one monitor
if [ ${#ALL_MONITORS[@]} -eq 0 ]; then
    echo "No monitors detected!"
    exit 1
fi

# Sort monitors to ensure consistent primary/secondary assignment
SORTED_MONITORS=($(sort <<<"${ALL_MONITORS[*]}"))

PRIMARY=${SORTED_MONITORS[0]}
SECONDARY=${SORTED_MONITORS[1]:-}  # Use empty string as default if no secondary monitor

echo "All available monitors: ${ALL_MONITORS[*]}"
echo "Primary: $PRIMARY"
echo "Secondary: $SECONDARY"
echo "Total monitors available: ${#ALL_MONITORS[@]}"

# Check if a command line argument was provided
if [ $# -eq 1 ]; then
    CHOICE="$1"
    echo "Using command line argument: $CHOICE"
else
    # Prompt user for layout choice - only show available options
    if [ -n "$SECONDARY" ]; then
        CHOICE=$(printf "Extended\nPrimary Only\nSecondary Only" | wofi --dmenu --prompt="Select Monitor Layout")
    else
        CHOICE=$(printf "Primary Only" | wofi --dmenu --prompt="Select Monitor Layout (Only one monitor detected)")
    fi
fi

# Exit if no choice was made
if [ -z "$CHOICE" ]; then
    echo "No selection made, exiting..."
    exit 0
fi

# Function to move all workspaces from disabled monitors to the active monitor
move_workspaces_to() {
    local target_monitor=$1
    
    # Wait a moment for monitor changes to take effect
    sleep 0.5
    
    # Get all workspaces and their assigned monitors
    # Parse the output more carefully to handle workspace names with spaces
    hyprctl workspaces -j | jq -r '.[] | "\(.id) \(.monitor)"' | while IFS=' ' read -r ws_id monitor_name; do
        # Skip if workspace is already on target monitor
        if [ "$monitor_name" != "$target_monitor" ]; then
            echo "Moving workspace $ws_id from $monitor_name to $target_monitor"
            hyprctl dispatch moveworkspacetomonitor "$ws_id" "$target_monitor" 2>/dev/null || true
        fi
    done
}

# Function to safely disable a monitor and move workspaces
disable_monitor_safely() {
    local monitor_to_disable=$1
    local target_monitor=$2
    
    # First move workspaces, then disable monitor
    move_workspaces_to "$target_monitor"
    
    # Wait a moment for workspace moves to complete
    sleep 0.2
    
    # Disable the monitor
    hyprctl keyword monitor "$monitor_to_disable,disable"
}

case "$CHOICE" in
    Extended)
        echo "Setting up extended display..."
        
        # Check if we actually have a secondary monitor
        if [ -z "$SECONDARY" ]; then
            echo "Error: Extended mode requires two monitors, but only one detected!"
            echo "Available monitors: ${ALL_MONITORS[*]}"
            exit 1
        fi
        
        # Enable primary monitor
        hyprctl keyword monitor "$PRIMARY,preferred,0x0,auto"
        
        # Enable secondary monitor to the right of primary
        hyprctl keyword monitor "$SECONDARY,preferred,auto,auto"
        ;;
        
    "Primary Only")
        echo "Setting up primary only..."
        # Enable primary monitor
        hyprctl keyword monitor "$PRIMARY,preferred,0x0,auto"
        
        # Disable secondary if it exists
        if [ -n "$SECONDARY" ]; then
            echo "Disabling secondary monitor: $SECONDARY"
            disable_monitor_safely "$SECONDARY" "$PRIMARY"
        else
            echo "Only primary monitor detected, nothing to disable"
        fi
        ;;
        
    "Secondary Only")
        echo "Setting up secondary only..."
        
        # Check if secondary monitor exists
        if [ -z "$SECONDARY" ]; then
            echo "Error: No secondary monitor detected!"
            echo "Available monitors: ${ALL_MONITORS[*]}"
            exit 1
        fi
        
        # Enable secondary monitor first
        echo "Enabling secondary monitor: $SECONDARY"
        hyprctl keyword monitor "$SECONDARY,preferred,0x0,auto"
        
        # Wait longer for secondary to be fully ready
        echo "Waiting for secondary monitor to be ready..."
        sleep 1.5
        
        # Check if secondary monitor is now active
        if ! hyprctl monitors -j | jq -r '.[].name' | grep -q "^$SECONDARY$"; then
            echo "Warning: Secondary monitor may not be fully active yet"
        fi
        
        # Explicitly move all workspaces from primary to secondary
        echo "Moving all workspaces from primary ($PRIMARY) to secondary ($SECONDARY)..."
        hyprctl workspaces -j | jq -r '.[] | select(.monitor=="'$PRIMARY'") | .id' | while read -r ws_id; do
            if [ -n "$ws_id" ]; then
                echo "Moving workspace $ws_id to $SECONDARY"
                hyprctl dispatch moveworkspacetomonitor "$ws_id" "$SECONDARY" 2>/dev/null || echo "Failed to move workspace $ws_id"
            fi
        done
        
        # Wait for workspace moves to complete
        sleep 1
        
        # Now disable the primary monitor
        echo "Disabling primary monitor: $PRIMARY"
        hyprctl keyword monitor "$PRIMARY,disable"
        ;;
        
    *)
        echo "Invalid choice: $CHOICE"
        exit 1
        ;;
esac

echo "Monitor setup complete!" 