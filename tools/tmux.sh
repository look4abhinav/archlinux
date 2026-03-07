#!/bin/bash

# ==========================================
# Tmux Verification Script
# Verifies Tmux installation
# Configuration is handled by dotfiles
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Tmux Verification${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# VERIFY INSTALLATION
# ==========================================
echo -e "\n${BLUE}Verifying Tmux installation...${NC}"

if command -v tmux &> /dev/null; then
    TMUX_PATH=$(command -v tmux)
    TMUX_VER=$(tmux -V)
    echo -e "${GREEN}✅ Tmux found at: $TMUX_PATH${NC}"
    echo -e "${GREEN}✅ $TMUX_VER${NC}"
    
    # NEW: Check for Tmux Plugin Manager (TPM)
    echo -e "\n${BLUE}Verifying dependencies...${NC}"
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        echo -e "${GREEN}✅ TPM (Tmux Plugin Manager): installed${NC}"
    else
        echo -e "${YELLOW}⚠️  TPM not found at ~/.tmux/plugins/tpm${NC}"
        echo -e "   Install via: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
    fi

    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Tmux setup verified!${NC}"
    echo -e "${BLUE}Configuration (.tmux.conf) is managed by dotfiles${NC}"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Tmux not found. Please install it via pacman first.${NC}"
    exit 1
fi