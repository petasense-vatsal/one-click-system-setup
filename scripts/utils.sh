#!/bin/bash

# Utility functions for the setup system

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$REPO_ROOT/setup.log"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# Backup function
backup_config() {
    local config_path="$1"
    local backup_dir="${2:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
    local config_name="$(basename "$config_path")"
    
    if [[ -e "$config_path" ]]; then
        mkdir -p "$backup_dir"
        cp -r "$config_path" "$backup_dir/$config_name" 2>/dev/null || true
        info "Backed up $config_path to $backup_dir/$config_name"
    fi
}

# Link dotfile function
link_dotfile() {
    local source_file="$1"
    local target_file="$2"
    local backup_dir="${3:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target_file")"
    
    # Backup existing file if it exists and is not a symlink
    if [[ -e "$target_file" ]] && [[ ! -L "$target_file" ]]; then
        backup_config "$target_file" "$backup_dir"
    fi
    
    # Remove existing symlink or file/directory
    if [[ -L "$target_file" ]]; then
        # It's a symlink, remove it
        rm -f "$target_file"
    elif [[ -d "$target_file" ]]; then
        # It's a directory, remove it recursively
        rm -rf "$target_file"
    elif [[ -f "$target_file" ]]; then
        # It's a file, remove it
        rm -f "$target_file"
    fi
    
    # Create symlink
    ln -sf "$source_file" "$target_file"
    info "Linked $source_file -> $target_file"
}

# Install package function (distribution-agnostic)
install_package() {
    local package="$1"
    
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm "$package"
    elif command -v apt >/dev/null 2>&1; then
        sudo apt install -y "$package"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$package"
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y "$package"
    else
        warning "Package manager not found. Please install $package manually."
        return 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Download and install from GitHub releases
install_github_release() {
    local repo="$1"
    local binary_name="$2"
    local install_path="${3:-/usr/local/bin}"
    
    log "Installing $binary_name from $repo..."
    
    local latest_release
    latest_release=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    local download_url
    download_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"browser_download_url":' | grep -i "linux" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [[ -n "$download_url" ]]; then
        cd /tmp
        curl -LO "$download_url"
        local downloaded_file=$(basename "$download_url")
        
        if [[ "$downloaded_file" == *.tar.gz ]] || [[ "$downloaded_file" == *.tgz ]]; then
            tar -xzf "$downloaded_file"
        elif [[ "$downloaded_file" == *.zip ]]; then
            unzip "$downloaded_file"
        fi
        
        # Find the binary and install it
        local binary_path=$(find . -name "$binary_name" -type f -executable | head -n 1)
        if [[ -n "$binary_path" ]]; then
            sudo install "$binary_path" "$install_path/$binary_name"
            info "Installed $binary_name to $install_path"
        else
            warning "Could not find binary $binary_name in downloaded archive"
        fi
        
        cd ~
        rm -rf /tmp/"$downloaded_file" /tmp/"${downloaded_file%.*}"
    else
        warning "Could not find download URL for $repo"
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir_path="$1"
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path"
        info "Created directory: $dir_path"
    fi
}

# Clone or update git repository
clone_or_update_repo() {
    local repo_url="$1"
    local target_dir="$2"
    local branch="${3:-}"
    
    if [[ -d "$target_dir" ]]; then
        info "Updating repository at $target_dir..."
        cd "$target_dir"
        git pull || true
        cd ~
    else
        info "Cloning repository to $target_dir..."
        if [[ -n "$branch" ]]; then
            git clone --depth 1 -b "$branch" "$repo_url" "$target_dir"
        else
            # Try to clone without specifying branch (uses default)
            git clone --depth 1 "$repo_url" "$target_dir"
        fi
    fi
}

# Enhanced package installation functions
install_package_manager() {
    local package="$1"
    local name="$2"
    
    log "Installing $name via package manager..."
    
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm "$package" || warn "Failed to install $package"
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y "$package" || warn "Failed to install $package"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$package" || warn "Failed to install $package"
    else
        warn "Package manager not supported for $package"
        return 1
    fi
}

# Install AUR package (Arch Linux)
install_aur_package() {
    local package="$1"
    local name="$2"
    
    if ! command -v pacman >/dev/null 2>&1; then
        warn "AUR packages only supported on Arch Linux"
        return 1
    fi
    
    log "Installing $name from AUR..."
    
    # Check if yay is installed, if not try to install it
    if ! command -v yay >/dev/null 2>&1; then
        log "Installing yay AUR helper..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
        rm -rf /tmp/yay
    fi
    
    yay -S --needed --noconfirm "$package" || warn "Failed to install $package from AUR"
}

# Install Chrome on Debian/Ubuntu
install_chrome_deb() {
    local name="$1"
    
    log "Installing $name..."
    cd /tmp
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable || warn "Failed to install Chrome"
}

# Install Brave on Debian/Ubuntu
install_brave_deb() {
    local name="$1"
    
    log "Installing $name..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser || warn "Failed to install Brave"
}

# Download and install .deb file
download_and_install_deb() {
    local url="$1"
    local filename="$2"
    local name="$3"
    
    log "Downloading and installing $name..."
    cd /tmp
    
    if [[ "$url" == *"latest"* ]]; then
        # Handle GitHub latest releases
        local actual_url=$(curl -s "$url" | grep -o 'https://[^"]*\.deb' | head -1)
        if [[ -n "$actual_url" ]]; then
            wget -O "$filename" "$actual_url" || warn "Failed to download $name"
        else
            warn "Could not find download URL for $name"
            return 1
        fi
    else
        wget -O "$filename" "$url" || warn "Failed to download $name"
    fi
    
    if [[ -f "$filename" ]]; then
        sudo dpkg -i "$filename" || warn "Failed to install $name"
        sudo apt install -f -y # Fix dependencies if needed
        rm -f "$filename"
    fi
}

# Helper function to warn
warn() {
    warning "$1"
} 