#!/usr/bin/bash

# ==========================================
# Zen Browser Setup Script
# Installs zen-browser-bin via AUR
# ==========================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Zen Browser Setup${NC}"
echo -e "${BLUE}========================================${NC}"

if command -v zen-browser &> /dev/null; then
    echo -e "${GREEN}✅ Zen Browser is already installed.${NC}"
else
    echo -e "${YELLOW}⚠️  Zen Browser not found. Installing via paru...${NC}"
    if command -v paru &> /dev/null; then
        paru -S --noconfirm zen-browser-bin
        echo -e "${GREEN}✅ Zen Browser installed successfully!${NC}"
    else
        echo -e "${RED}❌ Paru is required but not installed.${NC}"
        exit 1
    fi
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Zen Browser setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
