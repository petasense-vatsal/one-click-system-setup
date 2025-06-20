#!/bin/bash

# Git configuration

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up Git configuration..."

# Link git configuration if it exists
if [[ -f "$REPO_ROOT/dotfiles/git/.gitconfig" ]]; then
    link_dotfile "$REPO_ROOT/dotfiles/git/.gitconfig" "$HOME/.gitconfig"
else
    # Create a basic gitconfig template
    ensure_dir "$REPO_ROOT/dotfiles/git"
    cat > "$REPO_ROOT/dotfiles/git/.gitconfig" << 'EOF'
[user]
    name = Your Name
    email = your.email@example.com

[core]
    editor = nvim
    autocrlf = input
    excludesfile = ~/.gitignore_global

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = simple

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    di = diff
    lg = log --oneline --graph --decorate --all
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk

[color]
    ui = auto

[merge]
    tool = vimdiff

[diff]
    tool = vimdiff
EOF
    
    link_dotfile "$REPO_ROOT/dotfiles/git/.gitconfig" "$HOME/.gitconfig"
    warning "Created template .gitconfig. Please update with your name and email."
fi

# Create global gitignore if it doesn't exist
if [[ ! -f "$HOME/.gitignore_global" ]]; then
    log "Creating global gitignore..."
    cat > "$HOME/.gitignore_global" << 'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# Log files
*.log

# Temporary files
*.tmp
*.temp

# Compiled files
*.o
*.so
*.dll
*.exe

# Package files
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
.env

# Rust
target/
Cargo.lock
EOF
fi

log "Git setup completed!" 