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

# ==========================================
# STEP 1: SYSTEM UPDATE
# ==========================================
echo -e "\n${BLUE}[1/4] Updating system packages...${NC}"
print_status "Syncing and updating pacman..."
sudo pacman -Syu --noconfirm

# ==========================================
# STEP 2: INSTALL PACMAN PACKAGES
# ==========================================
echo -e "\n${BLUE}[2/4] Installing pacman packages...${NC}"

# Define packages to install with their installation status
declare -A PACKAGES=(
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

PACKAGES_TO_INSTALL=()

for pkg in "${!PACKAGES[@]}"; do
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
    print_success "All pacman packages already installed"
fi

# ==========================================
# STEP 3: RUN TOOL CONFIGURATION SCRIPTS
# ==========================================
echo -e "\n${BLUE}[3/4] Running tool configuration scripts...${NC}"

# Define the order of tool scripts to run
# Order matters: dependencies first, then configurations
TOOL_SCRIPTS=(
    "base-devel"    # Verify build tools (Needed for Paru)
    "paru"          # Build and install AUR helper
    "git"           # Configure git
    "docker"        # Configure docker
    "neovim"        # Verify neovim
    "tmux"          # Verify tmux
    "uv"            # Setup UV
    "zoxide"        # Verify zoxide
    "eza"           # Verify eza
    "fzf"           # Verify fzf
    "ripgrep"       # Verify ripgrep
    "bat"           # Verify bat
    "btop"          # Verify btop
    "fonts"         # Download and install Nerd Fonts
)

FAILED_SCRIPTS=()

for script in "${TOOL_SCRIPTS[@]}"; do
    if run_tool_script "$script"; then
        print_success "$script: completed"
    else
        print_error "$script: failed or skipped"
        FAILED_SCRIPTS+=("$script")
    fi
done

# ==========================================
# STEP 4: SETUP DOTFILES (LAST)
# ==========================================
echo -e "\n${BLUE}[4/4] Setting up dotfiles...${NC}"

if run_tool_script "stow"; then
    print_success "Dotfiles setup: completed"
else
    print_error "Dotfiles setup: failed or skipped"
    FAILED_SCRIPTS+=("stow")
fi

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