#!/usr/bin/bash

# ==========================================
# Zoxide Setup (Smart Directory Jumper)
# Verifies installation
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Zoxide Verification"

if ! command_exists "zoxide"; then
    log_info "Installing Zoxide..."
    sudo pacman -S --noconfirm zoxide
else
    ZOXIDE_VER=$(zoxide --version)
    log_success "Zoxide is installed: $ZOXIDE_VER"
fi
