#!/bin/bash

# User scripts installation module

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up user scripts..."

# Create scripts directory if it doesn't exist
ensure_dir "$HOME/scripts"

# Link utility scripts to ~/scripts
log "Linking user scripts..."

# Monitor layout switcher (for Hyprland)
if [[ -f "$REPO_ROOT/dotfiles/scripts/switch_layout.sh" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/scripts/switch_layout.sh" "$HOME/scripts/switch_layout.sh"
    chmod +x "$HOME/scripts/switch_layout.sh"
fi

# Zoxide + Neovim file finder
if [[ -f "$REPO_ROOT/dotfiles/scripts/zoxide_openfiles_nvim.sh" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/scripts/zoxide_openfiles_nvim.sh" "$HOME/scripts/zoxide_openfiles_nvim.sh"
    chmod +x "$HOME/scripts/zoxide_openfiles_nvim.sh"
fi

# Hyprland tmux window killer
if [[ -f "$REPO_ROOT/dotfiles/scripts/hypr-kill-tmux-window.sh" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/scripts/hypr-kill-tmux-window.sh" "$HOME/scripts/hypr-kill-tmux-window.sh"
    chmod +x "$HOME/scripts/hypr-kill-tmux-window.sh"
fi

# Zoom meeting launcher
if [[ -f "$REPO_ROOT/dotfiles/scripts/zoom.sh" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/scripts/zoom.sh" "$HOME/scripts/zoom.sh"
    chmod +x "$HOME/scripts/zoom.sh"
fi

# Also create symlinks in ~/.local/bin for system-wide access
ensure_dir "$HOME/.local/bin"

log "Creating system-wide script symlinks..."

# Link to ~/.local/bin for PATH access
if [[ -f "$HOME/scripts/switch_layout.sh" ]]; then
    ln -sf "$HOME/scripts/switch_layout.sh" "$HOME/.local/bin/switch-layout"
    info "Created symlink: switch-layout -> ~/.local/bin/"
fi

if [[ -f "$HOME/scripts/zoxide_openfiles_nvim.sh" ]]; then
    ln -sf "$HOME/scripts/zoxide_openfiles_nvim.sh" "$HOME/.local/bin/nzo"
    info "Created symlink: nzo -> ~/.local/bin/"
fi

if [[ -f "$HOME/scripts/hypr-kill-tmux-window.sh" ]]; then
    ln -sf "$HOME/scripts/hypr-kill-tmux-window.sh" "$HOME/.local/bin/hypr-kill-tmux-window.sh"
    info "Created symlink: hypr-kill-tmux-window.sh -> ~/.local/bin/"
fi

if [[ -f "$HOME/scripts/zoom.sh" ]]; then
    ln -sf "$HOME/scripts/zoom.sh" "$HOME/.local/bin/zoom"
    info "Created symlink: zoom -> ~/.local/bin/"
    
    # Also create system-wide symlink if we have sudo access
    if command -v sudo >/dev/null 2>&1; then
        if sudo -n true 2>/dev/null; then
            sudo ln -sf "$HOME/scripts/zoom.sh" "/usr/local/bin/zoom" 2>/dev/null || true
            info "Created system-wide symlink: zoom -> /usr/local/bin/"
        else
            info "Note: Run 'sudo ln -sf \$HOME/scripts/zoom.sh /usr/local/bin/zoom' for system-wide access"
        fi
    fi
fi

log "User scripts setup completed!"
log "Available commands:"
log "  switch-layout - Switch monitor layouts (Extended/Primary Only/Secondary Only)"
log "  nzo [search] - Find and open files with Neovim using zoxide and fzf"
log "  hypr-kill-tmux-window.sh - Intelligently kill Hyprland windows with tmux sessions"
log "  zoom <shortcut> - Launch Zoom meetings in special workspace (570, 386, 296)" 