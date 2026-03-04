#!/usr/bin/bash

# ==========================================
# Zoxide Verification Script
# Verifies zoxide installation
# Shell integration is handled by dotfiles
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Zoxide Verification${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Verifying zoxide installation...${NC}"

if command -v zoxide &> /dev/null; then
    ZOXIDE_PATH=$(which zoxide)
    ZOXIDE_VER=$(zoxide --version)
    echo -e "${GREEN}✅ Zoxide found at: $ZOXIDE_PATH${NC}"
    echo -e "${GREEN}✅ $ZOXIDE_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Zoxide is installed!${NC}"
    echo -e "${BLUE}Shell integration is managed by dotfiles${NC}"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Zoxide not found. Please install it via pacman first.${NC}"
    exit 1
fi
