#!/usr/bin/bash

# ==========================================
# Arch Linux Development Setup Script
# Installs and configures development tools
# ==========================================

set -e

# Prevent running as root (makepkg in paru.sh will fail, and dotfiles shouldn't be root)
if [ "$EUID" -eq 0 ]; then
    echo -e "\033[0;31m[✗]\033[0m Please do not run this script as root."
    echo "Run it as your normal user. The script will prompt for sudo when necessary."
    exit 1
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/tools"

# ==========================================
# HELPER FUNCTIONS
# ==========================================

# Check if a command exists
cmd_exists() {
    command -v "$1" &> /dev/null
}

# Check if a pacman package is installed
pkg_installed() {
    pacman -Q "$1" &> /dev/null
}

# Print status message
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

# Print success message
print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Print error message
print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Run a tool script if it exists
run_tool_script() {
    local script_name="$1"
    local script_path="$TOOLS_DIR/$script_name.sh"

    if [ ! -f "$script_path" ]; then
        print_warning "Tool script not found: $script_path"
        return 1
    fi

    echo -e "\n${BLUE}========================================${NC}"
    bash "$script_path"
    echo -e "${BLUE}========================================${NC}"
}

# ==========================================
# MAIN SETUP
# ==========================================

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Arch Linux Development Setup${NC}"
echo -e "${BLUE}========================================${NC}"

# Install dialog for TUI if missing
if ! cmd_exists dialog; then
    print_status "Installing dialog for interactive menu..."
    sudo pacman -Sy --noconfirm dialog
fi

# ==========================================
# INTERACTIVE TUI SETUP
# ==========================================

# Create a modern dark theme for dialog
export DIALOGRC="/tmp/.setup_dialogrc"
cat << 'EOF' > "$DIALOGRC"
use_shadow = ON
use_colors = ON
screen_color = (CYAN,BLACK,ON)
title_color = (MAGENTA,BLACK,ON)
dialog_color = (WHITE,BLACK,OFF)
border_color = (MAGENTA,BLACK,ON)
button_active_color = (WHITE,BLUE,ON)
button_inactive_color = (WHITE,BLACK,OFF)
button_key_active_color = (WHITE,BLUE,ON)
button_key_inactive_color = (RED,BLACK,OFF)
button_label_active_color = (WHITE,BLUE,ON)
button_label_inactive_color = (WHITE,BLACK,ON)
menubox_color = (WHITE,BLACK,OFF)
menubox_border_color = (MAGENTA,BLACK,ON)
item_color = (WHITE,BLACK,OFF)
item_selected_color = (BLACK,CYAN,ON)
tag_color = (GREEN,BLACK,ON)
tag_selected_color = (BLACK,CYAN,ON)
tag_key_color = (GREEN,BLACK,OFF)
tag_key_selected_color = (BLACK,CYAN,ON)
check_color = (CYAN,BLACK,ON)
check_selected_color = (BLACK,CYAN,ON)
uarrow_color = (GREEN,BLACK,ON)
darrow_color = (GREEN,BLACK,ON)
EOF

# Define packages to install with their installation status
declare -A PACKAGES=(
    [hyprland]="Dynamic Wayland compositor"
    [xdg-desktop-portal-hyprland]="XDG portal for Hyprland"
    [qt5-wayland]="Qt5 Wayland module"
    [qt6-wayland]="Qt6 Wayland module"
    [sddm]="Simple Desktop Display Manager"
    [ghostty]="Fast, GPU-accelerated terminal emulator"
    [waybar]="Highly customizable Wayland bar"
    [fuzzel]="Application launcher for Wayland"
    [mako]="Lightweight notification daemon"
    [hyprpaper]="Wayland wallpaper utility"
    [hyprlock]="Wayland screen locker"
    [hypridle]="Idle management daemon"
    [grim]="Screenshot tool for Wayland"
    [slurp]="Region selection for Wayland"
    [wl-clipboard]="Wayland clipboard utility"
    [cliphist]="Clipboard history manager"
    [brightnessctl]="Backlight control"
    [polkit-kde-agent]="Authentication agent"
    [yazi]="Blazing-fast terminal file manager"
    [ffmpegthumbnailer]="Video thumbnails for yazi"
    [poppler]="PDF rendering for yazi"
    [fd]="Fast file search"
    [ttf-jetbrains-mono]="JetBrains Mono font"
    [ttf-nerd-fonts-symbols-common]="Nerd Fonts symbols"
    [base-devel]="Build tools and compilers"
    [git]="Version control system"
    [neovim]="Modern text editor"
    [tmux]="Terminal multiplexer"
    [zoxide]="Smart directory jumper"
    [eza]="Modern ls replacement"
    [fzf]="Fuzzy finder"
    [stow]="Dotfiles manager"
    [docker]="Container platform"
    [docker-compose]="Docker compose tool"
    [tree-sitter]="Tree-sitter CLI"
    [stylua]="Lua code formatter"
    [taplo]="TOML formatter"
    [yamlfmt]="YAML formatter"
    [ripgrep]="Extremely fast search tool"
    [bat]="Cat clone with syntax highlighting"
    [btop]="Resource monitor"
    [wget]="Network downloader (required for fonts)"
    [unzip]="Archive extractor (required for fonts)"
)

PKG_KEYS=($(echo "${!PACKAGES[@]}" | tr ' ' '\n' | sort))
PKG_OPTIONS=()
for pkg in "${PKG_KEYS[@]}"; do
    PKG_OPTIONS+=("$pkg" "${PACKAGES[$pkg]}" "ON")
done

set +e
SELECTED_PKGS=$(dialog --backtitle "✨ Arch Linux Developer Setup ✨" \
    --title " 📦 Package Selection " \
    --colors \
    --checklist "Select packages to install\n(Space to toggle, Enter to confirm, Arrows to navigate):" 22 80 15 "${PKG_OPTIONS[@]}" 3>&1 1>&2 2>&3)
exit_status=$?
set -e
if [ $exit_status -ne 0 ]; then
    clear
    print_warning "Setup cancelled by user."
    rm -f "$DIALOGRC"
    exit 0
fi

# TOOL_SCRIPTS
declare -A TOOL_DESCRIPTIONS=(
    ["base-devel"]="Verify build tools (Needed for Paru)"
    ["paru"]="Build and install AUR helper"
    ["wayland"]="Setup SDDM and Wayland ecosystem"
    ["zen-browser"]="Install telemetry-free Zen Browser"
    ["yazi"]="Verify yazi"
    ["git"]="Configure git"
    ["docker"]="Configure docker"
    ["neovim"]="Verify neovim"
    ["tree-sitter-cli"]="Setup Syntax Tree in Neovim"
    ["tmux"]="Verify tmux"
    ["uv"]="Setup UV"
    ["zoxide"]="Verify zoxide"
    ["eza"]="Verify eza"
    ["fzf"]="Verify fzf"
    ["ripgrep"]="Verify ripgrep"
    ["bat"]="Verify bat"
    ["btop"]="Verify btop"
    ["fonts"]="Download and install Nerd Fonts"
    ["stow"]="Dotfiles setup via stow"
)

# Order of execution
TOOL_ORDER=(
    "base-devel"
    "paru"
    "wayland"
    "zen-browser"
    "yazi"
    "git"
    "docker"
    "neovim"
    "tree-sitter-cli"
    "tmux"
    "uv"
    "zoxide"
    "eza"
    "fzf"
    "ripgrep"
    "bat"
    "btop"
    "fonts"
    "stow"
)

TOOL_OPTIONS=()
for tool in "${TOOL_ORDER[@]}"; do
    TOOL_OPTIONS+=("$tool" "${TOOL_DESCRIPTIONS[$tool]}" "ON")
done

set +e
SELECTED_TOOLS=$(dialog --backtitle "✨ Arch Linux Developer Setup ✨" \
    --title " ⚙️ Tool Configuration " \
    --colors \
    --checklist "Select tools to configure\n(Space to toggle, Enter to confirm, Arrows to navigate):" 22 80 15 "${TOOL_OPTIONS[@]}" 3>&1 1>&2 2>&3)
exit_status=$?
set -e
if [ $exit_status -ne 0 ]; then
    clear
    print_warning "Setup cancelled by user."
    rm -f "$DIALOGRC"
    exit 0
fi

clear
rm -f "$DIALOGRC"

eval "SELECTED_PKG_ARRAY=($SELECTED_PKGS)"
eval "SELECTED_TOOL_ARRAY=($SELECTED_TOOLS)"

# ==========================================
# STEP 1: SYSTEM UPDATE
# ==========================================
echo -e "\n${BLUE}[1/3] Updating system packages...${NC}"
print_status "Syncing and updating pacman..."
sudo pacman -Syu --noconfirm

# ==========================================
# STEP 2: INSTALL PACMAN PACKAGES
# ==========================================
echo -e "\n${BLUE}[2/3] Installing pacman packages...${NC}"

PACKAGES_TO_INSTALL=()

for pkg in "${SELECTED_PKG_ARRAY[@]}"; do
    if pkg_installed "$pkg"; then
        print_success "$pkg: already installed"
    else
        PACKAGES_TO_INSTALL+=("$pkg")
        print_warning "$pkg: will be installed"
    fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    print_status "Installing ${#PACKAGES_TO_INSTALL[@]} package(s)..."
    sudo pacman -S "${PACKAGES_TO_INSTALL[@]}" --noconfirm
    print_success "Pacman packages installed"
else
    print_success "All selected pacman packages already installed"
fi

# ==========================================
# STEP 3: RUN TOOL CONFIGURATION SCRIPTS
# ==========================================
echo -e "\n${BLUE}[3/3] Running tool configuration scripts...${NC}"

FAILED_SCRIPTS=()

for script in "${TOOL_ORDER[@]}"; do
    # Check if script is in SELECTED_TOOL_ARRAY
    if [[ " ${SELECTED_TOOL_ARRAY[@]} " =~ " ${script} " ]]; then
        if run_tool_script "$script"; then
            print_success "$script: completed"
        else
            print_error "$script: failed or skipped"
            FAILED_SCRIPTS+=("$script")
        fi
    fi
done

# ==========================================
# SUMMARY
# ==========================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Summary${NC}"
echo -e "${BLUE}========================================${NC}"

if [ ${#FAILED_SCRIPTS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All setup steps completed successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Some steps had issues:${NC}"
    for script in "${FAILED_SCRIPTS[@]}"; do
        echo -e "  ${YELLOW}-${NC} $script"
    done
fi

echo -e "\n${YELLOW}Next steps:${NC}"
echo "  1. Reload your shell: exec \$SHELL"
echo "  2. Verify everything: command -v git nvim tmux docker uv paru rg bat btop"
echo "  3. Check dotfiles: ls -la ~/"
echo "  4. Activate Docker permissions: newgrp docker"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
