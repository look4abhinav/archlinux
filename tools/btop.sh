#!/usr/bin/bash

# ==========================================
# Btop Verification Script
# Verifies btop installation
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Btop Verification"

if ! command_exists "btop"; then
    log_info "Installing Btop..."
    sudo pacman -S --noconfirm btop
else
    BTOP_VER=$(btop --version | head -n 1)
    log_success "Btop is installed: $BTOP_VER"
fi
