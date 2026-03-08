#!/usr/bin/bash

# ==========================================
# Tmux Setup & Verification
# Installs Tmux and TPM (Plugin Manager)
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Tmux Setup & Verification"

# Install Tmux
if ! command_exists "tmux"; then
    log_info "Installing Tmux..."
    sudo pacman -S --noconfirm tmux
else
    TMUX_VER=$(tmux -V)
    log_info "Tmux is installed: $TMUX_VER"
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
log_info "Checking TPM (Tmux Plugin Manager)..."

if [ ! -d "$TPM_DIR" ]; then
    log_info "Installing TPM..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    log_success "TPM installed."
else
    log_info "TPM is already installed. Updating..."
    if git -C "$TPM_DIR" pull; then
        log_success "TPM updated."
    else
        log_warn "Failed to update TPM."
    fi
fi

log_success "Tmux setup complete."
