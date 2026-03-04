#!/usr/bin/bash

# ==========================================
# Eza Verification Script
# Verifies eza installation
# Aliases are configured in dotfiles
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Eza Verification${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Verifying eza installation...${NC}"

if command -v eza &> /dev/null; then
    EZA_PATH=$(which eza)
    EZA_VER=$(eza --version)
    echo -e "${GREEN}✅ Eza found at: $EZA_PATH${NC}"
    echo -e "${GREEN}✅ $EZA_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Eza is installed!${NC}"
    echo -e "${BLUE}Aliases (ls, ll, la, lt) are managed by dotfiles${NC}"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Eza not found. Please install it via pacman first.${NC}"
    exit 1
fi
