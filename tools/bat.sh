#!/usr/bin/bash

# ==========================================
# Bat Verification Script
# Verifies bat installation (cat clone with syntax highlighting)
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Bat Verification${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Verifying bat installation...${NC}"

if command -v bat &> /dev/null; then
    BAT_PATH=$(command -v bat)
    BAT_VER=$(bat --version | head -n 1)
    echo -e "${GREEN}✅ Bat found at: $BAT_PATH${NC}"
    echo -e "${GREEN}✅ $BAT_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Bat is ready!${NC}"
    echo -e "${YELLOW}Integration:${NC} Used as the syntax-highlighting previewer for fzf"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Bat not found. Please install 'bat' via pacman.${NC}"
    exit 1
fi