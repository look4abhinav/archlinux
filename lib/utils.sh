#!/bin/bash

# ==========================================
# Utility Functions for Arch Linux Setup
# ==========================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_section() {
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

# Error Handling
handle_error() {
    log_error "An error occurred on line $1"
    exit 1
}

# Check for Sudo
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        return 0
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        log_error "This script requires sudo privileges but sudo is not installed."
        exit 1
    fi

    if ! sudo -v; then
        log_error "Sudo authentication failed."
        exit 1
    fi
    
    # Keep sudo alive
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
}

# Command Check
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Package Check (Pacman)
package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Ensure Pacman Package
ensure_package() {
    if ! package_installed "$1"; then
        log_info "Installing package: $1"
        sudo pacman -S --noconfirm "$1"
    else
        log_info "Package $1 is already installed."
    fi
}

# Ensure AUR Helper (paru or yay)
ensure_aur_helper() {
    if command_exists "paru"; then
        AUR_HELPER="paru"
    elif command_exists "yay"; then
        AUR_HELPER="yay"
    else
        log_warn "No AUR helper found. Installing yay..."
        # Install yay from AUR manually
        ensure_package "git"
        ensure_package "base-devel"
        
        TEMP_DIR=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
        cd "$TEMP_DIR/yay"
        makepkg -si --noconfirm
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        AUR_HELPER="yay"
    fi
}

# Install AUR Package
ensure_aur_package() {
    ensure_aur_helper
    if ! package_installed "$1"; then
        log_info "Installing AUR package: $1"
        $AUR_HELPER -S --noconfirm "$1"
    fi
}
