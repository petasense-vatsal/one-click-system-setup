# One-Click System Setup

A comprehensive dotfiles and system configuration manager that handles both new system installations and new user setups.

## Features

- **Smart Detection**: Automatically detects if you're setting up a new system or just a new user
- **Modular Configuration**: Individual modules for different tools (Hyprland, tmux, LazyVim, etc.)
- **Application Installer**: Interactive application selection with 40+ essential apps
- **Backup System**: Automatically backs up existing configurations
- **Cross-Distribution Support**: Works on Arch, Ubuntu, Fedora, and other distributions
- **Idempotent**: Safe to run multiple times

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# Full system setup
./setup.sh

# Or install applications only
./install-apps.sh
```

## What Gets Configured

- **Window Manager**: Hyprland with optimized configuration, animations, and keybindings
- **Terminal Multiplexer**: tmux with custom keybindings, Catppuccin theme, and plugin manager
- **Editor**: LazyVim (Neovim) with plugins and language servers
- **Display Manager**: tuigreet for login
- **Shell**: Zsh with Oh My Zsh, Zinit plugin manager, and Starship prompt
- **Terminal**: Kitty with Catppuccin theme and JetBrains Mono font
- **Development Tools**: Git configuration and development environments
- **Applications**: Interactive installer for 40+ essential applications
- **User Scripts**: Custom utility scripts for monitor switching and file navigation
- **System Utilities**: eza, zoxide, yazi, fzf, and other modern CLI tools

## Application Categories

The application installer includes:

- **Development Tools**: Cursor AI, Postman
- **Browsers**: Firefox, Chrome  
- **Productivity**: Obsidian, Slack
- **Hyprland Ecosystem**: Waybar, SwayNC, Wofi, Hyprshot, Hypridle, Hyprpaper  
- **System Utilities**: Thunar + Plugins, Yazi, LXAppearance, nwg-look
- **Terminal**: Kitty

**CLI Tools (Auto-installed by System Setup)**:
LazyGit, Docker + Docker Compose, Htop, Eza, Bat, Ripgrep, fd, Zoxide, FZF, Starship

### 🎯 Selection Methods

**1. Interactive Mode (Recommended)**
- Yes/No prompts for each application
- Smart defaults for recommended apps
- Visual feedback with ✓/✗ indicators
- Can quit early with 'q'

**2. Quick Presets**
- **Essential** (5 apps): cursor, firefox, obsidian, thunar, kitty
- **Developer** (7 apps): Essential + chrome, postman
- **Full Desktop** (12 apps): Developer + slack, yazi, lxappearance, nwg-look, hyprshot
- **Everything**: All available applications
- **Browsers only**: firefox, chrome
- **Hyprland ecosystem**: waybar, swaync, wofi, hyprshot, hypridle, hyprpaper
- **Custom selection**: Switch to interactive mode

**3. Legacy Mode**
- Type application names or categories
- Individual apps: `cursor firefox obsidian`
- Categories: `dev browser prod hypr util term`
- All applications: `all`

> **Note**: CLI tools like htop, eza, bat, ripgrep, fd, zoxide, fzf, starship, lazygit, and docker are automatically installed by the system setup modules and don't need to be selected in the application installer.

## Usage

### Full System Setup
```bash
./setup.sh
```
Automatically detects and configures:
- **New System**: Installs packages + user configs + display manager
- **New User**: Only user configurations
- **Update**: Configuration updates only

### Application Installation Only
```bash
./install-apps.sh
```
Interactive application installer that works independently of the main setup.

## Directory Structure

```
├── setup.sh              # Main setup script
├── install-apps.sh       # Standalone application installer
├── modules/               # Individual configuration modules
│   ├── applications/      # Application installation module
│   ├── hyprland/         # Hyprland configuration
│   ├── tmux/             # tmux configuration
│   └── ...               # Other modules
├── dotfiles/             # All dotfiles and configurations
├── scripts/              # Utility scripts
└── backups/              # Backup directory (created during setup)
```

## Customization

Edit the configuration files in `dotfiles/` to customize your setup. The setup script will automatically deploy them to the correct locations.

## Supported Systems

- Arch Linux (and derivatives)
- Ubuntu/Debian
- Fedora/CentOS/RHEL
- Other systemd-based distributions 

## 🔧 **Tmux Configuration**

Includes a feature-rich tmux setup with:
- **TPM (Tmux Plugin Manager)** - Automatically installed and configured
- **10+ Essential Plugins** - All automatically installed during setup:
  - `tmux-sensible` - Basic tmux settings
  - `tmux-yank` - Copy to system clipboard  
  - `tmux-resurrect` - Save/restore tmux sessions
  - `tmux-continuum` - Auto-save sessions
  - `tmux-thumbs` - Copy text with hints
  - `tmux-fzf` - Fuzzy finder integration
  - `tmux-fzf-url` - URL extraction and opening
  - `catppuccin-tmux` - Beautiful theme
  - `tmux-sessionx` - Enhanced session management
  - `tmux-floax` - Floating terminal windows

**🚀 Automated Plugin Installation**: No need to manually run `prefix + I` - all plugins are installed automatically during setup with multiple fallback methods for reliability.

**Key Features**:
- Prefix key: `Ctrl+A`
- Mouse support enabled
- Status bar on top (macOS style)
- Vi-mode keybindings
- Session persistence and auto-restore 