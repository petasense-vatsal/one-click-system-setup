#!/bin/bash

# Application installation module with interactive selection

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_ROOT/scripts/utils.sh"

# Colors for output (in case they're not defined in utils.sh)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Define application categories and their apps
declare -A APPLICATIONS

# Development Tools (GUI apps get desktop entries)
APPLICATIONS["dev_cursor"]="Cursor AI|https://cursor.sh/|cursor|AI-powered code editor [GUI]"
APPLICATIONS["dev_postman"]="Postman|https://www.postman.com/|postman|API development platform [GUI]"
APPLICATIONS["dev_lazygit"]="LazyGit|https://github.com/jesseduffield/lazygit|lazygit|Terminal UI for git [CLI]"
APPLICATIONS["dev_docker"]="Docker + Docker Compose|https://www.docker.com/|docker docker-compose|Container platform [CLI]"

# Browsers (GUI apps get desktop entries)
APPLICATIONS["browser_firefox"]="Firefox|https://www.mozilla.org/firefox/|firefox|Open source browser [GUI]"
APPLICATIONS["browser_chrome"]="Google Chrome|https://www.google.com/chrome/|google-chrome|Google's browser [GUI]"

# Productivity (GUI apps get desktop entries)
APPLICATIONS["prod_obsidian"]="Obsidian|https://obsidian.md/|obsidian|Knowledge management [GUI]"
APPLICATIONS["prod_slack"]="Slack|https://slack.com/|slack|Team communication [GUI]"

# Hyprland Ecosystem (system components, no desktop entries needed)
APPLICATIONS["hypr_waybar"]="Waybar|https://github.com/Alexays/Waybar|waybar|Status bar for Wayland [SYSTEM]"
APPLICATIONS["hypr_swaync"]="SwayNC|https://github.com/ErikReider/SwayNotificationCenter|swaync|Notification center [SYSTEM]"
APPLICATIONS["hypr_wofi"]="Wofi|https://sr.ht/~scoopta/wofi/|wofi|Application launcher [SYSTEM]"
APPLICATIONS["hypr_hyprshot"]="Hyprshot|https://github.com/Gustash/Hyprshot|hyprshot|Screenshot tool for Hyprland [CLI]"
APPLICATIONS["hypr_hypridle"]="Hypridle|https://github.com/hyprwm/hypridle|hypridle|Idle daemon for Hyprland [SYSTEM]"
APPLICATIONS["hypr_hyprpaper"]="Hyprpaper|https://github.com/hyprwm/hyprpaper|hyprpaper|Wallpaper utility for Hyprland [SYSTEM]"

# System Utilities (mixed - some need desktop entries)
APPLICATIONS["util_thunar"]="Thunar + Plugins|https://docs.xfce.org/xfce/thunar/start|thunar thunar-archive-plugin|File manager with archive support [GUI]"
APPLICATIONS["util_yazi"]="Yazi|https://github.com/sxyazi/yazi|yazi|Terminal file manager [GUI]"
APPLICATIONS["util_lxappearance"]="LXAppearance|https://wiki.lxde.org/en/LXAppearance|lxappearance|GTK theme switcher [GUI]"
APPLICATIONS["util_nwg_look"]="nwg-look|https://github.com/nwg-piotr/nwg-look|nwg-look|GTK settings for Wayland [GUI]"

# Terminal & CLI Tools (only kitty gets desktop entry)
APPLICATIONS["term_kitty"]="Kitty|https://sw.kovidgoyal.net/kitty/|kitty kitty-shell-integration kitty-terminfo|GPU-accelerated terminal [GUI]"
APPLICATIONS["term_htop"]="Htop|https://htop.dev/|htop|Interactive process viewer [CLI]"
APPLICATIONS["term_eza"]="Eza|https://github.com/eza-community/eza|eza|Modern ls replacement [CLI]"
APPLICATIONS["term_bat"]="Bat|https://github.com/sharkdp/bat|bat|Cat clone with syntax highlighting [CLI]"
APPLICATIONS["term_ripgrep"]="Ripgrep|https://github.com/BurntSushi/ripgrep|ripgrep|Fast grep alternative [CLI]"
APPLICATIONS["term_fd"]="fd|https://github.com/sharkdp/fd|fd|Fast find alternative [CLI]"
APPLICATIONS["term_zoxide"]="Zoxide|https://github.com/ajeetdsouza/zoxide|zoxide|Smart cd command [CLI]"
APPLICATIONS["term_fzf"]="FZF|https://github.com/junegunn/fzf|fzf|Fuzzy finder [CLI]"
APPLICATIONS["term_starship"]="Starship|https://starship.rs/|starship|Cross-shell prompt [CLI]"

# Function to display applications by category
show_applications() {
    local category="$1"
    local title="$2"
    
    echo -e "\n${BLUE}=== $title ===${NC}"
    for key in "${!APPLICATIONS[@]}"; do
        if [[ "$key" == "${category}_"* ]]; then
            IFS='|' read -r name url package desc <<< "${APPLICATIONS[$key]}"
            local display_key="${key#${category}_}"
            printf "  %-15s %s - %s\n" "$display_key" "$name" "$desc"
        fi
    done
}

# Function to get user selections
get_user_selections() {
    local -n result_array=$1
    local selections=()
    
    echo -e "\n${YELLOW}Available Applications:${NC}"
    
    # Show all categories
    show_applications "dev" "Development Tools"
    show_applications "browser" "Browsers"
    show_applications "prod" "Productivity"
    show_applications "hypr" "Hyprland Ecosystem"
    show_applications "util" "System Utilities"
    show_applications "term" "Terminal & CLI Tools"
    
    echo -e "\n${CYAN}Selection Options:${NC}"
    echo "  - Individual apps: cursor firefox obsidian"
    echo "  - Categories: dev browser prod hypr util term"
    echo "  - All: all"
    echo "  - Essential preset: essential"
    echo -e "\n${YELLOW}Essential preset includes:${NC} cursor, firefox, obsidian, slack, thunar, yazi, kitty, htop"
    echo -e "\n${CYAN}Desktop Entry Info:${NC}"
    echo "  [GUI] = Gets desktop entry for application launcher"
    echo "  [CLI] = Command-line tool, no desktop entry"
    echo "  [SYSTEM] = System component, no desktop entry"
    
    while true; do
        echo
        read -p "Enter your selection (space-separated, or 'skip' to skip): " user_input
        
        if [[ -z "$user_input" ]] || [[ "$user_input" == "skip" ]]; then
            log "Skipping application installation as requested"
            return 0
        fi
        
        # Process user input
        for item in $user_input; do
            case "$item" in
                "all")
                    selections=($(printf '%s\n' "${!APPLICATIONS[@]}"))
                    break 2
                    ;;
                "essential")
                    selections+=(
                        "dev_cursor" "browser_firefox" "prod_obsidian" "prod_slack"
                        "util_thunar" "util_yazi" "term_kitty" "term_htop"
                    )
                    ;;
                "dev")
                    for key in "${!APPLICATIONS[@]}"; do
                        [[ "$key" == "dev_"* ]] && selections+=("$key")
                    done
                    ;;
                "browser")
                    for key in "${!APPLICATIONS[@]}"; do
                        [[ "$key" == "browser_"* ]] && selections+=("$key")
                    done
                    ;;
                "prod")
                    for key in "${!APPLICATIONS[@]}"; do
                        [[ "$key" == "prod_"* ]] && selections+=("$key")
                    done
                    ;;
                "hypr")
                    for key in "${!APPLICATIONS[@]}"; do
                        [[ "$key" == "hypr_"* ]] && selections+=("$key")
                    done
                    ;;
                "util")
                    for key in "${!APPLICATIONS[@]}"; do
                        [[ "$key" == "util_"* ]] && selections+=("$key")
                    done
                    ;;
                "term")
                    for key in "${!APPLICATIONS[@]}"; do
                        [[ "$key" == "term_"* ]] && selections+=("$key")
                    done
                    ;;
                *)
                    # Try to find individual app
                    local found=false
                    for key in "${!APPLICATIONS[@]}"; do
                        if [[ "$key" == *"_$item" ]]; then
                            selections+=("$key")
                            found=true
                            break
                        fi
                    done
                    if [[ "$found" == false ]]; then
                        echo -e "${YELLOW}Warning: '$item' not found, skipping...${NC}"
                    fi
                    ;;
            esac
        done
        break
    done
    
    # Remove duplicates and populate result array
    local unique_selections=($(printf '%s\n' "${selections[@]}" | sort -u))
    result_array=("${unique_selections[@]}")
}

# Function to install packages based on distribution
install_package() {
    local package="$1"
    local name="$2"
    
    log "Installing $name ($package)..."
    
    if command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        case "$package" in
            "cursor")
                install_aur_package "cursor-bin" "$name"
                ;;
            "google-chrome")
                install_aur_package "google-chrome" "$name"
                ;;
            "obsidian")
                install_aur_package "obsidian" "$name"
                ;;
            "slack")
                install_aur_package "slack-desktop" "$name"
                ;;
            "postman")
                install_aur_package "postman-bin" "$name"
                ;;
            "docker docker-compose")
                install_package_manager "docker docker-compose" "$name"
                ;;
            "kitty kitty-shell-integration kitty-terminfo")
                install_package_manager "kitty kitty-shell-integration kitty-terminfo" "$name"
                ;;
            "thunar thunar-archive-plugin")
                install_package_manager "thunar thunar-archive-plugin" "$name"
                ;;
            *)
                install_package_manager "$package" "$name"
                ;;
        esac
    elif command -v apt >/dev/null 2>&1; then
        # Debian/Ubuntu
        case "$package" in
            "cursor"|"obsidian"|"postman")
                install_from_download "$package" "$name"
                ;;
            "google-chrome")
                install_chrome_deb "$name"
                ;;
            "slack")
                # Slack has a snap package for Ubuntu
                if command -v snap >/dev/null 2>&1; then
                    snap install slack
                else
                    install_from_download "$package" "$name"
                fi
                ;;
            *)
                install_package_manager "$package" "$name"
                ;;
        esac
    else
        warn "Package manager not supported, skipping $name installation"
        return 1
    fi
}

# Function to install from downloads (for Debian/Ubuntu)
install_from_download() {
    local package="$1"
    local name="$2"
    
    case "$package" in
        "cursor")
            download_and_install_deb "https://downloader.cursor.sh/linux/appImage/x64" "cursor.AppImage" "$name"
            ;;
        "obsidian")
            download_and_install_deb "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian_*_amd64.deb" "obsidian.deb" "$name"
            ;;
        *)
            warn "Manual installation needed for $name"
            ;;
    esac
}

# Function to create desktop entries (only for GUI applications)
create_desktop_entries() {
    local selections=("$@")
    
    # Define which applications need desktop entries (GUI apps only)
    local gui_apps=(
        "dev_cursor" "dev_postman"
        "browser_firefox" "browser_chrome"
        "prod_obsidian" "prod_slack"
        "util_thunar" "util_yazi" "util_lxappearance" "util_nwg_look"
        "term_kitty"
    )
    
    # Map application keys to their desktop entry filenames
    declare -A desktop_entry_files
    desktop_entry_files["dev_cursor"]="cursor.desktop"
    desktop_entry_files["prod_obsidian"]="obsidian.desktop"
    desktop_entry_files["prod_slack"]="slack.desktop"
    
    ensure_dir "$HOME/.local/share/applications"
    
    for selection in "${selections[@]}"; do
        # Check if this app needs a desktop entry
        local needs_desktop_entry=false
        for gui_app in "${gui_apps[@]}"; do
            if [[ "$selection" == "$gui_app" ]]; then
                needs_desktop_entry=true
                break
            fi
        done
        
        if [[ "$needs_desktop_entry" == true ]]; then
            IFS='|' read -r name url package desc <<< "${APPLICATIONS[$selection]}"
            
            log "Creating desktop entry for $name..."
            
            # Get the primary package name for desktop entry
            local primary_package=$(echo "$package" | cut -d' ' -f1)
            
            # Check if we have a custom desktop entry for this app
            if [[ -n "${desktop_entry_files[$selection]:-}" ]]; then
                local custom_entry="$REPO_ROOT/dotfiles/desktop-entries/${desktop_entry_files[$selection]}"
                if [[ -f "$custom_entry" ]]; then
                    log "Using custom desktop entry for $name with Wayland optimizations"
                    cp "$custom_entry" "$HOME/.local/share/applications/${desktop_entry_files[$selection]}"
                    info "Installed optimized desktop entry for $name"
                    continue
                fi
            fi
            
            # Fallback: Create basic desktop entry for apps without custom configs
            cat > "$HOME/.local/share/applications/${primary_package}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Comment=$desc
Exec=$primary_package
Icon=$primary_package
Terminal=false
Categories=Application;
EOF
            
            info "Created basic desktop entry for $name"
        else
            IFS='|' read -r name url package desc <<< "${APPLICATIONS[$selection]}"
            info "Skipping desktop entry for $name (CLI/system component)"
        fi
    done
    
    # Copy monitor configuration desktop entries if they exist
    if [[ -d "$REPO_ROOT/dotfiles/desktop-entries" ]]; then
        for monitor_entry in "$REPO_ROOT/dotfiles/desktop-entries"/monitor-*.desktop; do
            if [[ -f "$monitor_entry" ]]; then
                local filename=$(basename "$monitor_entry")
                cp "$monitor_entry" "$HOME/.local/share/applications/$filename"
                info "Installed monitor configuration: $filename"
            fi
        done
    fi
    
    # Update desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    fi
}

# Main function
main() {
    log "Starting application installation..."
    
    # Determine setup mode
    local setup_mode
    if [[ "${SETUP_MODE:-}" == "new_system" ]]; then
        setup_mode="new_system"
        log "Detected new system setup mode - will install packages and create desktop entries"
    elif [[ "${SETUP_MODE:-}" == "new_user" ]]; then
        setup_mode="new_user"
        log "Detected new user setup mode - will create desktop entries only"
    else
        # Ask user for setup mode preference
        echo -e "\n${CYAN}Setup Mode Selection:${NC}"
        echo "  1) Full installation - Install packages and create desktop entries"
        echo "  2) Desktop entries only - Create desktop entries without installing packages"
        echo
        while true; do
            read -p "Choose setup mode [1/2]: " mode_choice
            case "$mode_choice" in
                1)
                    setup_mode="new_system"
                    log "Selected full installation mode"
                    break
                    ;;
                2)
                    setup_mode="new_user"
                    log "Selected desktop entries only mode"
                    break
                    ;;
                *)
                    echo -e "${YELLOW}Please enter 1 or 2${NC}"
                    ;;
            esac
        done
    fi
    
    # Get user selections
    local selected_apps=()
    get_user_selections selected_apps
    local selection_exit_code=$?
    
    # If user chose to skip (function returned early), exit gracefully
    if [[ $selection_exit_code -ne 0 ]] || [[ ${#selected_apps[@]} -eq 0 ]]; then
        return 0
    fi
    
    if [[ ${#selected_apps[@]} -eq 0 ]]; then
        warn "No applications selected, skipping..."
        return 0
    fi
    
    echo -e "\n${CYAN}Selected applications:${NC}"
    for app in "${selected_apps[@]}"; do
        IFS='|' read -r name url package desc <<< "${APPLICATIONS[$app]}"
        echo "  - $name"
    done
    
    echo
    read -p "Proceed with installation? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log "Installation cancelled by user"
        return 0
    fi
    
    # Process based on setup mode
    if [[ "$setup_mode" == "new_system" ]]; then
        log "Installing selected applications..."
        for app in "${selected_apps[@]}"; do
            IFS='|' read -r name url package desc <<< "${APPLICATIONS[$app]}"
            install_package "$package" "$name" || warn "Failed to install $name"
        done
        
        log "Creating desktop entries..."
        create_desktop_entries "${selected_apps[@]}"
    else
        log "Creating desktop entries only (packages will not be installed)..."
        create_desktop_entries "${selected_apps[@]}"
        
        echo -e "\n${YELLOW}Note: Only desktop entries were created. To install the actual packages, use your package manager:${NC}"
        echo -e "  ${CYAN}Arch Linux:${NC} sudo pacman -S <package-name> or yay -S <aur-package>"
        echo -e "  ${CYAN}Debian/Ubuntu:${NC} sudo apt install <package-name>"
    fi
    
    log "Application setup completed!"
    log "Installed/configured ${#selected_apps[@]} applications"
}

# Run main function
main "$@" 