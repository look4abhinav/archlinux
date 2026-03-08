#!/usr/bin/bash

# ==========================================
# Neovim Configuration & Verification
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Neovim Configuration"

# Verify Neovim is installed (from core packages)
if command_exists "nvim"; then
    NVIM_VER=$(nvim --version | head -n 1)
    log_success "Neovim is installed: $NVIM_VER"
else
    log_error "Neovim is not installed. Please run setup.sh again."
    exit 1
fi

# Ensure Python Support for Neovim (pynvim)
# Check if python3 is available
if command_exists "python3"; then
    log_info "Checking pynvim support..."
    # Check if pynvim is installed via pip (user or system)
    # Alternatively, use pacman package `python-pynvim` if available (Arch way)
    if pacman -Qi python-pynvim &>/dev/null; then
        log_success "pynvim (system) is installed."
    else
        log_info "Installing python-pynvim via pacman..."
        sudo pacman -S --noconfirm python-pynvim
    fi
else
    log_warn "Python3 not found. Skipping pynvim check."
fi

# Verify formatters/LSP tools (optional check)
MISSING_TOOLS=()
for tool in stylua taplo yamlfmt; do
    if ! command_exists "$tool"; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    log_warn "Some LSP tools are missing: ${MISSING_TOOLS[*]}"
    log_info "They should have been installed by setup.sh."
else
    log_success "LSP tools (stylua, taplo, yamlfmt) are ready."
fi

log_success "Neovim setup complete."
