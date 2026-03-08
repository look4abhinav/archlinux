#!/usr/bin/bash

# ==========================================
# Bat Verification Script
# Verifies bat installation (cat clone with syntax highlighting)
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Bat Verification"

if ! command_exists "bat"; then
    log_info "Installing Bat..."
    sudo pacman -S --noconfirm bat
else
    BAT_VER=$(bat --version | head -n 1)
    log_success "Bat is installed: $BAT_VER"
    log_info "Bat is used as the syntax-highlighting previewer for fzf."
fi
