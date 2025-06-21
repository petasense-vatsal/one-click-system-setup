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

# Function to install tmux plugins automatically
install_tmux_plugins() {
    log "Installing tmux plugins automatically..."
    
    # Make sure TPM install script is executable
    chmod +x "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
    
    # Direct TPM script execution (most reliable method)
    if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
        log "Running TPM install script..."
        if "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null; then
            log "✓ Plugins installed successfully"
            return 0
        else
            log "⚠️ TPM install script failed"
            return 1
        fi
    else
        log "⚠️ TPM install script not found or not executable"
        return 1
    fi
}

# Verify plugin installation
verify_plugin_installation() {
    local plugin_dirs=(
        "tmux-sensible" "tmux-yank" "tmux-resurrect" "tmux-continuum"
        "tmux-thumbs" "tmux-fzf" "tmux-fzf-url" "catppuccin-tmux"
        "tmux-sessionx" "tmux-floax"
    )
    
    local installed_count=0
    local total_plugins=${#plugin_dirs[@]}
    
    log "Verifying plugin installation..."
    
    for plugin in "${plugin_dirs[@]}"; do
        if [[ -d "$HOME/.tmux/plugins/$plugin" ]]; then
            ((installed_count++))
            log "  ✓ $plugin"
        else
            log "  ✗ $plugin (missing)"
        fi
    done
    
    log "Plugin installation status: $installed_count/$total_plugins plugins installed"
    
    if [[ $installed_count -eq $total_plugins ]]; then
        success "All tmux plugins installed successfully! 🎉"
        return 0
    elif [[ $installed_count -gt 0 ]]; then
        warning "Some plugins are missing. You may need to run 'prefix + I' in tmux to install remaining plugins."
        return 1
    else
        warning "No plugins detected. Run 'prefix + I' in tmux to install plugins manually."
        return 1
    fi
}

# Install tmux plugins
if command_exists tmux; then
    if install_tmux_plugins; then
        verify_plugin_installation
    else
        warning "Automatic plugin installation failed."
        info "You can install plugins manually by:"
        info "  1. Starting tmux: tmux"
        info "  2. Pressing: Ctrl+A then I (capital i)"
        info "  3. Waiting for installation to complete"
    fi
else
    log "tmux not found, plugins will be installed on first tmux startup"
    info "After installing tmux, run 'prefix + I' to install plugins"
fi

log "tmux setup completed!"

# Final instructions
echo
info "🚀 Tmux Setup Complete!"
info "Next steps:"
info "  • Start tmux: ${BLUE}tmux${NC}"
info "  • If plugins aren't working, press: ${YELLOW}Ctrl+A then I${NC}"
info "  • Prefix key is: ${GREEN}Ctrl+A${NC}" 