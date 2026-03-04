#!/usr/bin/bash

# ==========================================
# UV Setup & Tool Installation
# Installs UV and Python tools (Ruff, etc.)
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "UV Setup & Tools"

# Install UV
if command_exists "uv"; then
    log_info "UV is already installed: $(uv --version)"
else
    # Check if 'uv' is available in pacman (extra repo)
    if pacman -Ss "^uv$" | grep -q "extra/uv"; then
        log_info "Installing UV via Pacman..."
        sudo pacman -S --noconfirm uv
    else
        log_info "Installing UV via official script..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Add to path for current session
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
fi

# Install Python tools via UV
if command_exists "uv"; then
    log_info "Installing Python tools via UV..."
    
    # Install ruff (linter/formatter)
    if ! uv tool list | grep -q "ruff"; then
        log_info "Installing ruff..."
        uv tool install ruff
    else
        log_info "ruff is already installed."
    fi
    
    # Add more tools here if needed
else
    log_error "UV installation failed or not found in PATH."
    exit 1
fi

log_success "UV setup complete."
