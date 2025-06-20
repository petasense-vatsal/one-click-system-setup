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
    log "Checking for essential CLI tools..."
    
    # Check if tools are already installed system-wide first
    local missing_tools=()
    
    if ! command_exists eza; then
        missing_tools+=("eza")
    fi
    if ! command_exists zoxide; then
        missing_tools+=("zoxide")
    fi
    if ! command_exists yazi; then
        missing_tools+=("yazi")
    fi
    if ! command_exists fzf; then
        missing_tools+=("fzf")
    fi
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        info "All essential CLI tools are already installed"
        return 0
    fi
    
    log "Missing tools: ${missing_tools[*]}"
    
    # Try to install missing tools
    for tool in "${missing_tools[@]}"; do
        case "$tool" in
            "eza")
                if ! command_exists eza; then
                    log "Installing eza..."
                    install_package "eza" || warning "Failed to install eza via package manager"
                fi
                ;;
            "zoxide")
                if ! command_exists zoxide; then
                    log "Installing zoxide..."
                    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
                        warning "Failed to install zoxide"
                    fi
                fi
                ;;
            "yazi")
                if ! command_exists yazi; then
                    log "Installing yazi..."
                    install_package "yazi" || warning "Failed to install yazi via package manager"
                fi
                ;;
            "fzf")
                if ! command_exists fzf; then
                    log "Installing fzf..."
                    install_package "fzf" || warning "Failed to install fzf via package manager"
                fi
                ;;
        esac
    done
    
    # Final check and inform user
    local still_missing=()
    for tool in "${missing_tools[@]}"; do
        if ! command_exists "$tool"; then
            still_missing+=("$tool")
        fi
    done
    
    if [[ ${#still_missing[@]} -gt 0 ]]; then
        warning "Some tools could not be installed: ${still_missing[*]}"
        warning "These tools may have been installed by the system setup but require a shell restart"
        warning "If this is a new user setup, please ensure you have sudo privileges or ask an admin to install: ${still_missing[*]}"
    else
        info "All essential CLI tools are now available"
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