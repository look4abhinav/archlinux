#!/usr/bin/bash

# ==========================================
# Docker Setup & Verification Script
# Enables Docker service and configures user permissions
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Docker Setup & Verification${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# 1. VERIFY INSTALLATION
# ==========================================
echo -e "\n${BLUE}Verifying Docker installation...${NC}"
if command -v docker &> /dev/null; then
    DOCKER_PATH=$(command -v docker)
    DOCKER_VER=$(docker --version)
    echo -e "${GREEN}✅ Docker found at: $DOCKER_PATH${NC}"
    echo -e "${GREEN}✅ $DOCKER_VER${NC}"
else
    echo -e "${RED}❌ Docker not found. Please install it via pacman first.${NC}"
    exit 1
fi

# ==========================================
# 2. ENABLE & START SERVICE
# ==========================================
echo -e "\n${BLUE}Configuring Docker service...${NC}"
# Using --now handles both 'enable' and 'start' in a single command
if sudo systemctl enable --now docker.service; then
    echo -e "${GREEN}✅ Docker service enabled and started${NC}"
else
    echo -e "${RED}❌ Failed to enable Docker service${NC}"
    exit 1
fi

# ==========================================
# 3. CONFIGURE USER PERMISSIONS
# ==========================================
echo -e "\n${BLUE}Configuring user permissions...${NC}"
if sudo usermod -aG docker "$USER"; then
    echo -e "${GREEN}✅ User $USER added to 'docker' group${NC}"
else
    echo -e "${RED}❌ Failed to add user to docker group${NC}"
    exit 1
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Docker setup complete!${NC}"
echo -e "${YELLOW}⚠️  IMPORTANT: Group changes do not apply to the current session.${NC}"
echo -e "   To run Docker without sudo right now, execute:"
echo -e "   ${NC}newgrp docker${NC}"
echo -e "   (Or simply log out and log back in)"
echo -e "${BLUE}========================================${NC}"