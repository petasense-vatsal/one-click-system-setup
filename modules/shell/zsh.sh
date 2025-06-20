#!/bin/bash

# Zsh shell configuration

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up Zsh shell configuration..."

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh..."
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended
fi

# Install Zsh plugins
log "Installing Zsh plugins..."

# zsh-autosuggestions
clone_or_update_repo \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
clone_or_update_repo \
    "https://github.com/zsh-users/zsh-syntax-highlighting" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

# zsh-completions
clone_or_update_repo \
    "https://github.com/zsh-users/zsh-completions" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"

# Install Starship
if ! command_exists starship; then
    log "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Install Zinit plugin manager
if [[ ! -d "$HOME/.local/share/zinit" ]]; then
    log "Installing Zinit plugin manager..."
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

# Install additional tools used in the .zshrc
install_additional_tools() {
    # Install eza (modern ls replacement)
    if ! command_exists eza; then
        log "Installing eza..."
        install_package "eza"
    fi
    
    # Install zoxide (smart cd command)
    if ! command_exists zoxide; then
        log "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    # Install yazi (terminal file manager) 
    if ! command_exists yazi; then
        log "Installing yazi..."
        install_package "yazi"
    fi
    
    # Install fzf (fuzzy finder)
    if ! command_exists fzf; then
        log "Installing fzf..."
        install_package "fzf"
    fi
}

install_additional_tools

# Link configuration files
log "Linking Zsh configuration files..."
link_dotfile "$REPO_ROOT/dotfiles/zsh/.zshrc" "$HOME/.zshrc"

# Link Starship configuration if it exists
if [[ -f "$REPO_ROOT/dotfiles/starship/starship.toml" ]]; then
    ensure_dir "$HOME/.config"
    link_dotfile "$REPO_ROOT/dotfiles/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# Change default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

log "Zsh setup completed!" 