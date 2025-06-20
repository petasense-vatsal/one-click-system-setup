#!/bin/bash

# Terminal configuration

set -euo pipefail

source "$(dirname "$0")/../../scripts/utils.sh"

log "Setting up terminal configurations..."

# Kitty configuration
if [[ -f "$REPO_ROOT/dotfiles/terminal/kitty.conf" ]]; then
    ensure_dir "$HOME/.config/kitty"
    link_dotfile "$REPO_ROOT/dotfiles/terminal/kitty.conf" "$HOME/.config/kitty/kitty.conf"
else
    # Create a basic Kitty config
    ensure_dir "$REPO_ROOT/dotfiles/terminal"
    ensure_dir "$HOME/.config/kitty"
    
    cat > "$REPO_ROOT/dotfiles/terminal/kitty.conf" << 'EOF'
# Font configuration
font_family JetBrains Mono
bold_font auto
italic_font auto
bold_italic_font auto
font_size 12.0

# Cursor
cursor_shape block
cursor_blink_interval 0

# Scrollback
scrollback_lines 10000

# Mouse
mouse_hide_wait 3.0

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Terminal bell
enable_audio_bell no
visual_bell_duration 0.0

# Window layout
remember_window_size yes
initial_window_width 1200
initial_window_height 800
window_padding_width 10

# Tab bar
tab_bar_edge bottom
tab_bar_style powerline
tab_powerline_style slanted

# Color scheme (Catppuccin Mocha)
foreground #CDD6F4
background #1E1E2E
selection_foreground #1E1E2E
selection_background #F5E0DC

# Black
color0 #45475A
color8 #585B70

# Red
color1 #F38BA8
color9 #F38BA8

# Green
color2 #A6E3A1
color10 #A6E3A1

# Yellow
color3 #F9E2AF
color11 #F9E2AF

# Blue
color4 #89B4FA
color12 #89B4FA

# Magenta
color5 #F5C2E7
color13 #F5C2E7

# Cyan
color6 #94E2D5
color14 #94E2D5

# White
color7 #BAC2DE
color15 #A6ADC8

# Cursor colors
cursor #F5E0DC
cursor_text_color #1E1E2E

# URL underline color when hovering
url_color #F5E0DC

# Keybindings
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+equal increase_font_size
map ctrl+shift+minus decrease_font_size
map ctrl+shift+0 restore_font_size
EOF
    
    link_dotfile "$REPO_ROOT/dotfiles/terminal/kitty.conf" "$HOME/.config/kitty/kitty.conf"
fi

# Install Kitty themes
if command_exists kitty; then
    log "Installing Kitty themes..."
    "$REPO_ROOT/scripts/install-kitty-themes.sh"
fi

log "Terminal setup completed!" 