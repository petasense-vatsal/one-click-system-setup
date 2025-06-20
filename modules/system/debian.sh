#!/bin/bash

# Debian/Ubuntu system package installation

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up Debian/Ubuntu system packages..."

# Update system
log "Updating package lists..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
log "Installing essential packages..."
sudo apt install -y \
    build-essential \
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
    fd-find \
    bat \
    fzf \
    tmux \
    zsh \
    neovim \
    nodejs \
    npm \
    python3 \
    python3-pip \
    golang-go \
    rustc \
    cargo \
    gcc \
    make \
    cmake \
    pkg-config \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Hyprland dependencies (requires newer Ubuntu/Debian)
log "Installing Wayland and compositor dependencies..."
sudo apt install -y \
    wayland-protocols \
    libwayland-dev \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libxkbcommon-dev \
    libxkbcommon-x11-0 \
    libpixman-1-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libwebp-dev \
    xwayland \
    sway \
    waybar \
    wofi \
    mako-notifier \
    grim \
    slurp \
    wl-clipboard \
    brightnessctl \
    pamixer \
    pavucontrol \
    policykit-1-gnome

# Install terminal and fonts
log "Installing terminal and fonts..."
sudo apt install -y \
    kitty \
    fonts-firacode \
    fonts-jetbrains-mono \
    fonts-noto \
    fonts-noto-emoji \
    fonts-liberation \
    fonts-dejavu

# Install Snap packages if snapd is available
if command -v snap >/dev/null 2>&1; then
    log "Installing Snap packages..."
    sudo snap install code --classic
    sudo snap install discord
fi

# Install Flatpak if available
if command -v flatpak >/dev/null 2>&1; then
    log "Setting up Flatpak..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Docker
log "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install additional development tools
log "Installing development tools..."
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh jq

# Install LazyGit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

# Build and install Hyprland from source (if not available in repos)
if ! command -v hyprland >/dev/null 2>&1; then
    log "Building Hyprland from source..."
    sudo apt install -y meson ninja-build libdrm-dev libxkbcommon-dev libinput-dev libgbm-dev libxcb-dri3-dev
    cd /tmp
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all && sudo make install
    cd ~
    rm -rf /tmp/Hyprland
fi

# Enable services
log "Enabling system services..."
sudo systemctl enable docker.service

# Add user to docker group
sudo usermod -aG docker $USER

log "Debian/Ubuntu system setup completed!"
log "Note: You may need to log out and back in for group changes to take effect." 