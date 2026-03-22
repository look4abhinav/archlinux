#!/usr/bin/bash

# ==========================================
# Wayland & SDDM Setup Script
# Configures SDDM for Wayland natively
# ==========================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Wayland & SDDM Setup${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Configuring SDDM for Wayland natively...${NC}"

if pacman -Q sddm &> /dev/null; then
    sudo mkdir -p /etc/sddm.conf.d
    echo -e "[General]\nDisplayServer=wayland\nGreeterEnvironment=QT_WAYLAND_DISABLE_WINDOWDECORATION=1\n\n[Theme]\nCurrent=breeze" | sudo tee /etc/sddm.conf.d/wayland.conf > /dev/null
    
    echo -e "${BLUE}Enabling SDDM service...${NC}"
    sudo systemctl enable sddm.service || true
    echo -e "${GREEN}✅ SDDM configured for Wayland and enabled!${NC}"
else
    echo -e "${RED}❌ SDDM is not installed. Please add it to your setup.sh PACKAGES array.${NC}"
    exit 1
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Wayland & SDDM setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
