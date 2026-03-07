#!/usr/bin/bash

# ==========================================
# Ripgrep Verification Script
# Verifies ripgrep (rg) installation
# ==========================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Ripgrep Verification${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Verifying ripgrep installation...${NC}"

if command -v rg &> /dev/null; then
    RG_PATH=$(command -v rg)
    RG_VER=$(rg --version | head -n 1)
    echo -e "${GREEN}✅ Ripgrep found at: $RG_PATH${NC}"
    echo -e "${GREEN}✅ $RG_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Ripgrep is ready!${NC}"
    echo -e "${YELLOW}Usage tip:${NC} Use 'rg <pattern>' instead of grep for massive speedups"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Ripgrep not found. Please install 'ripgrep' via pacman.${NC}"
    exit 1
fi