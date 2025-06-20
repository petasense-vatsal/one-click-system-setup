#!/bin/bash

# Arch Linux system package installation

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up Arch Linux system packages..."

# Update system
log "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install essential packages
log "Installing essential packages..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    curl \
    wget \
    unzip \
    zip \
    tar \
    gzip \
    htop \
    neofetch \
    tree \
    ripgrep \
    fd \
    bat \
    eza \
    fzf \
    zoxide \
    yazi \
    tmux \
    zsh \
    neovim \
    starship \
    nodejs \
    npm \
    python \
    python-pip \
    go \
    rust \
    gcc \
    make \
    cmake \
    pkg-config

# Install Hyprland and related packages
log "Installing Hyprland and Wayland ecosystem..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    waybar \
    wofi \
    mako \
    grim \
    slurp \
    swappy \
    wl-clipboard \
    brightnessctl \
    pamixer \
    pavucontrol \
    polkit-kde-agent \
    qt5-wayland \
    qt6-wayland \
    xorg-xwayland

# Install terminal and fonts
log "Installing terminal and fonts..."
sudo pacman -S --needed --noconfirm \
    kitty \
    wezterm \
    ttf-fira-code \
    ttf-jetbrains-mono \
    ttf-nerd-fonts-symbols \
    noto-fonts \
    noto-fonts-emoji \
    ttf-liberation \
    ttf-dejavu

# Install greetd and tuigreet
log "Installing display manager (greetd + tuigreet)..."
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet

# Install AUR helper (yay) if not present
if ! command -v yay >/dev/null 2>&1; then
    log "Installing yay AUR helper..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
fi

# Install AUR packages
log "Installing AUR packages..."
yay -S --noconfirm \
    hyprshot \
    wlogout \
    swaylock-effects \
    hypridle \
    hyprlock \
    hyprpaper \
    swaync \
    nwg-look \
    python-pywal \
    oh-my-zsh-git

# Install development tools
log "Installing development tools..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    lazygit \
    github-cli \
    jq \
    yq \
    kubectl \
    helm

# Enable services
log "Enabling system services..."
sudo systemctl enable greetd.service
sudo systemctl enable docker.service

log "Arch Linux system setup completed!" 