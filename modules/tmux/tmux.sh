#!/bin/bash

# Tmux configuration

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up tmux configuration..."

# Install TPM (Tmux Plugin Manager) if not present
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    log "Installing TPM (Tmux Plugin Manager)..."
    clone_or_update_repo \
        "https://github.com/tmux-plugins/tpm" \
        "$HOME/.tmux/plugins/tpm"
fi

# Link configuration files
log "Linking tmux configuration files..."
link_dotfile "$REPO_ROOT/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Link tmux reset configuration if it exists
if [[ -f "$REPO_ROOT/dotfiles/tmux/tmux.reset.conf" ]]; then
    ensure_dir "$HOME/.config/tmux"
    link_dotfile "$REPO_ROOT/dotfiles/tmux/tmux.reset.conf" "$HOME/.config/tmux/tmux.reset.conf"
fi

# Install tmux plugins
if command_exists tmux; then
    log "Installing tmux plugins..."
    # Start a detached tmux session to install plugins
    tmux new-session -d -s install_plugins 2>/dev/null || true
    tmux send-keys -t install_plugins "$HOME/.tmux/plugins/tpm/bin/install_plugins" Enter 2>/dev/null || true
    sleep 3
    tmux kill-session -t install_plugins 2>/dev/null || true
else
    log "tmux not found, plugins will be installed on first tmux startup"
fi

log "tmux setup completed!"
log "Press prefix + I in tmux to install plugins if they haven't been installed automatically" 