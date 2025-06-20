#!/bin/bash

# LazyVim (Neovim) configuration

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up LazyVim (Neovim) configuration..."

# Backup existing Neovim configuration
backup_config "$HOME/.config/nvim"
backup_config "$HOME/.local/share/nvim"
backup_config "$HOME/.local/state/nvim"
backup_config "$HOME/.cache/nvim"

# Create necessary directories
ensure_dir "$HOME/.config/nvim"

# Clone LazyVim starter if no custom config exists
if [[ ! -f "$REPO_ROOT/dotfiles/nvim/lua/config/lazy.lua" ]]; then
    log "Cloning LazyVim starter configuration..."
    clone_or_update_repo \
        "https://github.com/LazyVim/starter" \
        "/tmp/lazyvim-starter"
    
    # Copy starter files to dotfiles directory
    ensure_dir "$REPO_ROOT/dotfiles/nvim"
    cp -r /tmp/lazyvim-starter/* "$REPO_ROOT/dotfiles/nvim/"
    rm -rf /tmp/lazyvim-starter
    
    # Remove .git directory from dotfiles
    rm -rf "$REPO_ROOT/dotfiles/nvim/.git"
    
    # Remove any cache directories that shouldn't be in dotfiles
    rm -rf "$REPO_ROOT/dotfiles/nvim/nvim"
    
    log "LazyVim starter files copied successfully"
fi

# Link configuration files
log "Linking Neovim configuration files..."
link_dotfile "$REPO_ROOT/dotfiles/nvim" "$HOME/.config/nvim"

# Install essential runtime dependencies that LazyVim expects
log "Installing essential runtime dependencies..."

# Install Node.js for various LSPs and tools (Mason will handle the rest)
if command_exists npm; then
    log "Setting up npm global directory..."
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.npm-global/bin:"* ]]; then
        export PATH="$HOME/.npm-global/bin:$PATH"
    fi
fi

# Install Python neovim provider (required for some plugins)
if command_exists pipx; then
    log "Installing Python neovim provider..."
    pipx install pynvim || warning "Failed to install pynvim"
elif command_exists pip3; then
    log "Installing Python neovim provider..."
    pip3 install --user pynvim || warning "Failed to install pynvim"
fi

log "LazyVim setup completed!"
log ""
log "🚀 Next steps:"
log "  1. Start Neovim: nvim"
log "  2. LazyVim will automatically install plugins on first run"
log "  3. Use :Mason to install language servers and tools as needed"
log "  4. Run :checkhealth to verify everything is working"
log ""
log "💡 LazyVim features:"
log "  • Mason.nvim: Automatic LSP/tool installation (:Mason)"
log "  • Pre-configured LSPs for most languages"
log "  • Built-in formatters and linters"
log "  • Just open a file and LazyVim will suggest installing the right tools!" 