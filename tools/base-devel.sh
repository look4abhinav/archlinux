#!/usr/bin/bash

# ==========================================
# Base Devel Verification Script
# Verifies build tools installation
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Base Devel Verification"

if pacman -Qi base-devel &>/dev/null; then
    log_success "Base Devel group is installed."
else
    log_warn "Base Devel group not fully installed. Installing..."
    sudo pacman -S --needed --noconfirm base-devel
    log_success "Base Devel installed."
fi
