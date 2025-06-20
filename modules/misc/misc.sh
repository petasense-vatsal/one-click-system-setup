#!/bin/bash

# Miscellaneous configurations

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up miscellaneous configurations..."

# Note: user-scripts.sh is already executed in the main setup flow

# Link additional dotfiles that might not be handled by other modules
if [[ -d "$REPO_ROOT/dotfiles/wofi" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/wofi" "$HOME/.config/wofi"
fi
if [[ -d "$REPO_ROOT/dotfiles/backgrounds" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/backgrounds" "$HOME/.config/backgrounds"
fi
if [[ -d "$REPO_ROOT/dotfiles/waybar" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/waybar" "$HOME/.config/waybar"
fi

# Create .local/bin directory for user scripts
ensure_dir "$HOME/.local/bin"

# Add user bin to PATH if not already there
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" 2>/dev/null || true
fi

# Setup environment files
ensure_dir "$REPO_ROOT/dotfiles/misc"

# Create .profile if it doesn't exist
if [[ ! -f "$REPO_ROOT/dotfiles/misc/.profile" ]]; then
    cat > "$REPO_ROOT/dotfiles/misc/.profile" << 'EOF'
# ~/.profile: executed by the command interpreter for login shells.

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Environment variables
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox
export TERMINAL=kitty

# Go environment
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust environment
export PATH="$HOME/.cargo/bin:$PATH"

# Node.js environment
export PATH="$HOME/.npm-global/bin:$PATH"

# Python environment
export PATH="$HOME/.local/bin:$PATH"
EOF
fi

link_dotfile "$REPO_ROOT/dotfiles/misc/.profile" "$HOME/.profile"

# Setup XDG directories
ensure_dir "$HOME/.config"
ensure_dir "$HOME/.local/share"
ensure_dir "$HOME/.local/state"
ensure_dir "$HOME/.cache"

# Create XDG user directories
if command_exists xdg-user-dirs-update; then
    xdg-user-dirs-update
fi

# Create common development directories
ensure_dir "$HOME/Projects"
ensure_dir "$HOME/Downloads"
ensure_dir "$HOME/Documents"
ensure_dir "$HOME/Pictures/screenshots"
ensure_dir "$HOME/Pictures/wallpapers"

# Setup screenshot script
cat > "$HOME/.local/bin/screenshot" << 'EOF'
#!/bin/bash
# Screenshot script for Hyprland

SCREENSHOT_DIR="$HOME/Pictures/screenshots"
mkdir -p "$SCREENSHOT_DIR"

case "$1" in
    "area")
        grim -g "$(slurp)" "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
    "window")
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
    "full"|*)
        grim "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
esac
EOF

chmod +x "$HOME/.local/bin/screenshot"

# Setup brightness control script
cat > "$HOME/.local/bin/brightness" << 'EOF'
#!/bin/bash
# Brightness control script

case "$1" in
    "up")
        brightnessctl set +10%
        ;;
    "down")
        brightnessctl set 10%-
        ;;
    *)
        echo "Usage: brightness [up|down]"
        echo "Current brightness: $(brightnessctl get)"
        ;;
esac
EOF

chmod +x "$HOME/.local/bin/brightness"

# Setup volume control script
cat > "$HOME/.local/bin/volume" << 'EOF'
#!/bin/bash
# Volume control script

case "$1" in
    "up")
        pamixer -i 5
        ;;
    "down")
        pamixer -d 5
        ;;
    "mute")
        pamixer --toggle-mute
        ;;
    *)
        echo "Usage: volume [up|down|mute]"
        echo "Current volume: $(pamixer --get-volume)%"
        echo "Muted: $(pamixer --get-mute)"
        ;;
esac
EOF

chmod +x "$HOME/.local/bin/volume"

# Setup power menu script
cat > "$HOME/.local/bin/powermenu" << 'EOF'
#!/bin/bash
# Power menu script

options="Lock\nLogout\nReboot\nShutdown"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --width 200 --height 150)

case $chosen in
    "Lock")
        swaylock -f -c 000000
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac
EOF

chmod +x "$HOME/.local/bin/powermenu"

# Setup application launcher enhancement
cat > "$HOME/.local/bin/launcher" << 'EOF'
#!/bin/bash
# Enhanced application launcher

wofi --show drun --width 600 --height 400 --prompt "Applications"
EOF

chmod +x "$HOME/.local/bin/launcher"

log "Miscellaneous setup completed!"
log "Created utility scripts in ~/.local/bin/" 