#!/usr/bin/bash

# ==========================================
# Eza (LS Replacement) Setup
# Verifies installation and check
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Eza Verification"

if ! command_exists "eza"; then
    log_warn "Eza is not installed. Installing..."
    sudo pacman -S --noconfirm eza
else
    EZA_VER=$(eza --version | head -n 1)
    log_success "Eza is ready: $EZA_VER"
fi
