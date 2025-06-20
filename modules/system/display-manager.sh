#!/bin/bash

# Display manager setup (greetd + tuigreet)

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up greetd display manager with tuigreet..."

# Create greetd config directory
sudo mkdir -p /etc/greetd

# Configure greetd
log "Configuring greetd..."
sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-user-session --asterisks --cmd Hyprland"
user = "greeter"

[initial_session]
command = "Hyprland"
user = "USERNAME_PLACEHOLDER"
EOF

# Replace placeholder with current user
sudo sed -i "s/USERNAME_PLACEHOLDER/$USER/g" /etc/greetd/config.toml

# Create greetd user if it doesn't exist
if ! id -u greeter >/dev/null 2>&1; then
    log "Creating greeter user..."
    sudo useradd -M -G video greeter
    sudo usermod -s /bin/nologin greeter
fi

# Set up proper permissions
sudo chmod 755 /etc/greetd
sudo chmod 644 /etc/greetd/config.toml

# Enable greetd service
log "Enabling greetd service..."
sudo systemctl enable greetd.service

# Disable other display managers if they exist
for dm in gdm lightdm sddm xdm; do
    if systemctl is-enabled $dm >/dev/null 2>&1; then
        log "Disabling $dm..."
        sudo systemctl disable $dm
    fi
done

# Create a session script for Hyprland
sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland Compositor
Exec=Hyprland
Type=Application
EOF

log "Display manager setup completed!"
log "greetd will start on next boot. You can start it now with: sudo systemctl start greetd" 