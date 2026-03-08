#!/usr/bin/bash

# ==========================================
# Fzf (Fuzzy Finder) Setup
# Verifies installation
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Fzf Verification"

if ! command_exists "fzf"; then
    log_warn "Fzf is not installed. Installing..."
    sudo pacman -S --noconfirm fzf
else
    FZF_VER=$(fzf --version | head -n 1)
    log_success "Fzf is ready: $FZF_VER"
fi
