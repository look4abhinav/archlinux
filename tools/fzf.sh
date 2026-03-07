#!/usr/bin/bash

# ==========================================
# FZF Verification Script
# Verifies fzf installation
# Shell integration is handled by dotfiles
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}FZF Verification${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Verifying fzf installation...${NC}"

if command -v fzf &> /dev/null; then
    FZF_PATH=$(which fzf)
    FZF_VER=$(fzf --version)
    echo -e "${GREEN}✅ FZF found at: $FZF_PATH${NC}"
    echo -e "${GREEN}✅ $FZF_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ FZF is installed!${NC}"
    echo -e "${BLUE}Shell integration is managed by dotfiles${NC}"
    echo -e "${YELLOW}Key Bindings:${NC}"
    echo "  Ctrl+T - Fuzzy find files"
    echo "  Ctrl+R - Fuzzy search history"
    echo "  Alt+C  - Fuzzy change directory"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ FZF not found. Please install it via pacman first.${NC}"
    exit 1
fi
