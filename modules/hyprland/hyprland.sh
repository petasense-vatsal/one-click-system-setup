#!/bin/bash

# Hyprland configuration

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up Hyprland configuration..."

# Create necessary directories
ensure_dir "$HOME/.config/hypr"
ensure_dir "$HOME/.config/waybar"
ensure_dir "$HOME/.config/wofi"
ensure_dir "$HOME/.config/mako"
ensure_dir "$HOME/.config/swaylock"

# Link configuration files
log "Linking Hyprland configuration files..."
link_dotfile "$REPO_ROOT/dotfiles/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
link_dotfile "$REPO_ROOT/dotfiles/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
link_dotfile "$REPO_ROOT/dotfiles/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
link_dotfile "$REPO_ROOT/dotfiles/hypr/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
link_dotfile "$REPO_ROOT/dotfiles/hypr/mocha.conf" "$HOME/.config/hypr/mocha.conf"

# Link other config files if they exist
if [[ -d "$REPO_ROOT/dotfiles/waybar" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/waybar" "$HOME/.config/waybar"
fi
if [[ -d "$REPO_ROOT/dotfiles/wofi" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/wofi" "$HOME/.config/wofi"
fi
if [[ -d "$REPO_ROOT/dotfiles/mako" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/mako" "$HOME/.config/mako"
fi
if [[ -d "$REPO_ROOT/dotfiles/swaylock" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/swaylock" "$HOME/.config/swaylock"
fi
if [[ -d "$REPO_ROOT/dotfiles/backgrounds" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/backgrounds" "$HOME/.config/backgrounds"
fi

# Create scripts directory
ensure_dir "$HOME/.local/bin"
ensure_dir "$HOME/.config/hypr/scripts"

# Link Hyprland scripts
if [[ -d "$REPO_ROOT/dotfiles/hypr/scripts" ]]; then
    for script in "$REPO_ROOT/dotfiles/hypr/scripts"/*; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            link_dotfile "$script" "$HOME/.local/bin/$script_name"
            chmod +x "$HOME/.local/bin/$script_name"
        fi
    done
fi

# Set up wallpapers directory
ensure_dir "$HOME/Pictures/wallpapers"
if [[ -d "$REPO_ROOT/dotfiles/wallpapers" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/wallpapers" "$HOME/Pictures/wallpapers"
fi

# Install additional Wayland tools if not present
log "Installing additional Wayland tools..."

# Install wlroots-based tools
if command_exists pacman; then
    # Install packages individually to handle failures gracefully
    packages=(
        "xdg-desktop-portal-wlr"
        "xdg-desktop-portal-gtk"
        "qt5ct"
        "lxappearance"
        "nwg-look"
    )
    
    for package in "${packages[@]}"; do
        if ! pacman -Qi "$package" &>/dev/null; then
            sudo pacman -S --needed --noconfirm "$package" || warning "Failed to install $package, continuing..."
        fi
    done
elif command_exists apt; then
    install_package xdg-desktop-portal-wlr || true
    install_package xdg-desktop-portal-gtk || true
    install_package qt5ct || true
    install_package lxappearance || true
fi

log "Hyprland setup completed!"
log "You can start Hyprland by running 'Hyprland' from a TTY or using a display manager" 