#!/bin/bash

# Get Slack window info
slack_window=$(hyprctl clients -j | jq -r '.[] | select(.class == "Slack")')

# Check if Slack is running
if [ -z "$slack_window" ]; then
    echo '{"text": "", "tooltip": "Slack is not running", "class": "inactive", "color": "#f5c2e7"}'
    exit 0
fi

# Extract window title
title=$(echo "$slack_window" | jq -r '.title')

# Check for different notification types
if echo "$title" | grep -q "new item"; then
    # DMs and Other notifications
    echo '{"text": "", "tooltip": "New stuff in Slack", "class": "normal", "color": "#a6e3a1"}'
else
    # No unread messages
    echo '{"text": "", "tooltip": "No unread Slack messages", "class": "normal", "color": "#a6e3a1"}'
fi

