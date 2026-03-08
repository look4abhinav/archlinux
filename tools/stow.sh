#!/usr/bin/bash

# ==========================================
# GNU Stow Configuration Script
# Manages dotfiles symlinks via GNU Stow
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "GNU Stow Configuration"

# Check if stow is installed
if ! command_exists "stow"; then
    log_info "Installing stow..."
    if sudo pacman -S --noconfirm stow; then
        log_success "Stow installed."
    else
        log_error "Failed to install stow."
        exit 1
    fi
fi

# Define dotfiles directory (relative to this script: ../dotfiles)
# Upstream expects dotfiles in ~/dotfiles or cloned there.
# But we are in a repo structure. Let's assume the repo IS the dotfiles source.
# If this script is in `archlinux/tools/stow.sh`, the root is `archlinux/`.
# Does `archlinux/` contain `dotfiles/`? Yes, based on README.
# So `DOTFILES_DIR` should be `../dotfiles`.

DOTFILES_DIR="$(realpath "$SCRIPT_DIR/../dotfiles")"

if [ -d "$DOTFILES_DIR" ]; then
    log_info "Found dotfiles at: $DOTFILES_DIR"
    log_info "Stowing dotfiles..."
    
    # Run stow command
    # -d: directory containing packages (DOTFILES_DIR)
    # -t: target directory ($HOME)
    # .: package name (treat DOTFILES_DIR content as the package)
    
    if stow -v -d "$DOTFILES_DIR" -t "$HOME" . 2>/dev/null; then
        log_success "Dotfiles stowed successfully."
    else
        log_warn "Stow reported conflicts. Retrying with --adopt..."
        if stow -v --adopt -d "$DOTFILES_DIR" -t "$HOME" .; then
            log_success "Dotfiles stowed with --adopt."
            log_info "Note: --adopt may have modified files in dotfiles/. Check git status."
            # Optionally reset changes if you want strictly repo version
            # git -C "$DOTFILES_DIR" checkout .
        else
            log_error "Failed to stow dotfiles."
            exit 1
        fi
    fi
else
    log_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi
