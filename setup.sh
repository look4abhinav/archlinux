#!/usr/bin/bash

# ==========================================
# Arch Linux Development Setup Script
# Installs and configures development tools
# ==========================================

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

log_section "Arch Linux Development Setup"

# Check for sudo privileges
check_sudo

# ==========================================
# STEP 1: SYSTEM UPDATE
# ==========================================
log_section "System Update"
log_info "Syncing and updating pacman..."
sudo pacman -Syu --noconfirm

# ==========================================
# STEP 2: INSTALL CORE PACKAGES
# ==========================================
log_section "Installing Core Packages"

# Define packages to install
PACKAGES=(
    "base-devel"    # Build tools
    "git"           # VCS
    "neovim"        # Editor
    "tmux"          # Multiplexer
    "zoxide"        # Navigation
    "eza"           # LS replacement
    "fzf"           # Fuzzy finder
    "stow"          # Dotfiles
    "docker"        # Containers
    "docker-compose" # Compose
    "tree-sitter-cli" # Treesitter
    "stylua"        # Lua formatter
    "taplo-cli"     # TOML formatter
    "yamlfmt"       # YAML formatter
    "ripgrep"       # Extremely fast search tool
    "bat"           # Cat clone with syntax highlighting
    "btop"          # Resource monitor
    "wget"          # Network downloader (required for fonts)
    "unzip"         # Archive extractor (required for fonts)
)

PACKAGES_TO_INSTALL=()

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        log_info "$pkg: already installed"
    else
        PACKAGES_TO_INSTALL+=("$pkg")
        log_info "$pkg: scheduled for installation"
    fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    log_info "Installing ${#PACKAGES_TO_INSTALL[@]} package(s)..."
    sudo pacman -S --noconfirm "${PACKAGES_TO_INSTALL[@]}"
    log_success "Core packages installed."
else
    log_success "All core packages already installed."
fi

# ==========================================
# STEP 3: RUN TOOL CONFIGURATION SCRIPTS
# ==========================================
log_section "Running Tool Configuration Scripts"

# Find all executable scripts in tools/
TOOL_SCRIPTS=("$SCRIPT_DIR/tools/"*.sh)

if [ ${#TOOL_SCRIPTS[@]} -eq 0 ]; then
    log_warn "No tool scripts found in tools/."
else
    # Run tools in alphabetical order (default glob behavior)
    for script in "${TOOL_SCRIPTS[@]}"; do
        if [ -x "$script" ]; then
            script_name=$(basename "$script")
            log_info "Running $script_name..."
            if "$script"; then
                log_success "$script_name completed."
            else
                log_error "$script_name failed."
            fi
        else
            log_warn "Skipping non-executable script: $(basename "$script")"
        fi
    done
fi

log_section "Setup Complete!"
log_info "Next steps:"
log_info "  1. Reload your shell: exec \$SHELL"
log_info "  2. Verify everything: command -v git nvim tmux docker uv paru rg bat btop"
log_info "  3. Check dotfiles: ls -la ~/"
log_info "  4. Activate Docker permissions: newgrp docker"
log_info "Please restart your shell or log out/in for changes to take effect."
