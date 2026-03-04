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
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Tmux Verification${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# VERIFY INSTALLATION
# ==========================================
echo -e "\n${BLUE}Verifying Tmux installation...${NC}"

if command -v tmux &> /dev/null; then
    TMUX_PATH=$(which tmux)
    TMUX_VER=$(tmux -V)
    echo -e "${GREEN}✅ Tmux found at: $TMUX_PATH${NC}"
    echo -e "${GREEN}✅ $TMUX_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Tmux is installed!${NC}"
    echo -e "${BLUE}Configuration (.tmux.conf) is managed by dotfiles${NC}"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Tmux installation could not be verified${NC}"
    exit 1
fi
