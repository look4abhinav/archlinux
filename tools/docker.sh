#!/usr/bin/bash

# ==========================================
# Docker Setup & Verification Script
# Enables Docker service and configures user permissions
# ==========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Docker Setup & Verification"

# Check if Docker is installed (setup.sh should handle this, but double check)
if ! command_exists "docker"; then
    log_info "Installing Docker..."
    sudo pacman -S --noconfirm docker docker-compose
fi

# Verify version
DOCKER_VER=$(docker --version)
log_info "Docker version: $DOCKER_VER"

# Enable and start service
log_info "Configuring Docker service..."
if ! systemctl is-active --quiet docker; then
    sudo systemctl enable --now docker.service
    log_success "Docker service started."
else
    log_info "Docker service is already running."
fi

# Configure user permissions
log_info "Configuring user permissions..."
if ! groups "$USER" | grep -q "\bdocker\b"; then
    sudo usermod -aG docker "$USER"
    log_success "User $USER added to 'docker' group."
    log_warn "Group changes require logout/login or 'newgrp docker' to take effect."
else
    log_info "User already in 'docker' group."
fi

log_success "Docker setup complete!"
