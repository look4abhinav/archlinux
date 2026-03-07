#!/usr/bin/bash

# ==========================================
# Neovim Verification Script
# Verifies Neovim and dependencies
# Configuration is handled by dotfiles
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Neovim Verification${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# VERIFY NEOVIM INSTALLATION
# ==========================================
echo -e "\n${BLUE}Verifying Neovim installation...${NC}"

if command -v nvim &> /dev/null; then
    NVIM_PATH=$(command -v nvim)
    NVIM_VER=$(nvim --version | head -n 1)
    echo -e "${GREEN}✅ Neovim found at: $NVIM_PATH${NC}"
    echo -e "${GREEN}✅ $NVIM_VER${NC}"
else
    echo -e "${RED}❌ Neovim not found. Please install it via pacman first.${NC}"
    exit 1
fi

# ==========================================
# VERIFY EXTERNAL DEPENDENCIES
# ==========================================
echo -e "\n${BLUE}Verifying external dependencies...${NC}"

DEPS=("tree-sitter" "stylua" "taplo" "yamlfmt")
MISSING_DEPS=()

for dep in "${DEPS[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo -e "${GREEN}✅ $dep: installed${NC}"
    else
        echo -e "⚠️  $dep not found"
        MISSING_DEPS+=("$dep")
    fi
done

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Neovim is installed!${NC}"
echo -e "${BLUE}Configuration (init.lua) is managed by dotfiles${NC}"
echo -e "${BLUE}========================================${NC}"

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "\n${BLUE}Missing dependencies:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
        echo -e "  ⚠️  $dep"
    done
    echo "Install them via: sudo pacman -S tree-sitter-cli stylua taplo yamlfmt"
fi