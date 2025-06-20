#!/bin/bash

# One-Click System Setup
# Handles both new system installation and new user setup

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$SCRIPT_DIR/setup.log"

# Setup mode detection
SETUP_MODE=""
export SETUP_MODE

# Logging function
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

# Detect distribution
detect_distro() {
    if [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/fedora-release ]]; then
        echo "fedora"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user."
    fi
}

# Detect setup mode (new system vs new user)
detect_setup_mode() {
    local has_hyprland=false
    local has_user_configs=false
    
    # Check if Hyprland is installed system-wide
    if command -v hyprland >/dev/null 2>&1; then
        has_hyprland=true
    fi
    
    # Check if user already has dotfiles
    if [[ -d "$HOME/.config" ]] && [[ $(ls -la "$HOME/.config" 2>/dev/null | wc -l) -gt 3 ]]; then
        has_user_configs=true
    fi
    
    if [[ "$has_hyprland" == true ]] && [[ "$has_user_configs" == true ]]; then
        SETUP_MODE="update"
        info "Detected: Existing system with user configurations (update mode)"
    elif [[ "$has_hyprland" == true ]]; then
        SETUP_MODE="new_user"
        info "Detected: Existing system, new user setup"
    else
        SETUP_MODE="new_system"
        info "Detected: New system installation required"
    fi
    export SETUP_MODE
}

# Create backup directory
create_backup() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory: $BACKUP_DIR"
    fi
}

# Backup existing configuration
backup_config() {
    local config_path="$1"
    local config_name="$(basename "$config_path")"
    
    if [[ -e "$config_path" ]]; then
        cp -r "$config_path" "$BACKUP_DIR/$config_name" 2>/dev/null || true
        info "Backed up $config_path to $BACKUP_DIR/$config_name"
    fi
}

# Install system packages
install_system_packages() {
    local distro="$(detect_distro)"
    log "Installing system packages for $distro..."
    
    case "$distro" in
        "arch")
            "$SCRIPT_DIR/modules/system/arch.sh"
            ;;
        "debian")
            "$SCRIPT_DIR/modules/system/debian.sh"
            ;;
        *)
            warning "Unsupported distribution: $distro. Skipping system package installation."
            ;;
    esac
}

# Setup user configurations
setup_user_configs() {
    log "Setting up user configurations..."
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Setup modules in order
    local modules=(
        "shell/zsh.sh"
        "git/git.sh"
        "tmux/tmux.sh"
        "neovim/lazyvim.sh"
        "hyprland/hyprland.sh"
        "terminal/terminal.sh"
        "scripts/user-scripts.sh"
        "misc/misc.sh"
    )
    
    for module in "${modules[@]}"; do
        if [[ -f "$SCRIPT_DIR/modules/$module" ]]; then
            log "Running module: $module"
            bash "$SCRIPT_DIR/modules/$module"
        else
            warning "Module not found: $module"
        fi
    done
}

# Setup display manager (requires sudo)
setup_display_manager() {
    if [[ "$SETUP_MODE" == "new_system" ]]; then
        log "Setting up display manager..."
        if [[ -f "$SCRIPT_DIR/modules/system/display-manager.sh" ]]; then
            bash "$SCRIPT_DIR/modules/system/display-manager.sh"
        fi
    fi
}

# Main setup function
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║       One-Click System Setup         ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_root
    detect_setup_mode
    create_backup
    
    case "$SETUP_MODE" in
        "new_system")
            log "Starting new system setup..."
            install_system_packages
            setup_user_configs
            setup_display_manager
            ;;
        "new_user")
            log "Starting new user setup..."
            setup_user_configs
            ;;
        "update")
            log "Starting configuration update..."
            setup_user_configs
            ;;
    esac
    
    # Reload Hyprland configuration if running
    if command -v hyprctl >/dev/null 2>&1 && pgrep -x Hyprland >/dev/null 2>&1; then
        log "Reloading Hyprland configuration..."
        hyprctl reload 2>/dev/null || warning "Failed to reload Hyprland configuration"
    fi
    
    log "Setup completed successfully!"
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════╗"
    echo "║           Setup Complete!            ║"
    echo "║                                      ║"
    echo "║  Your dotfiles have been installed.  ║"
    echo "║  Backup created at:                  ║"
    echo "║  $BACKUP_DIR"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    
    info "Log file: $LOG_FILE"
    info "To apply changes, you may need to:"
    echo "  - Restart your terminal"
    echo "  - Log out and log back in"
    echo "  - Reboot (for new system installations)"
}

# Run main function
main "$@" 