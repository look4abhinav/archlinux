#!/usr/bin/bash

# ==========================================
# Btop Verification Script
# Verifies btop installation
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Btop Verification${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Verifying btop installation...${NC}"

if command -v btop &> /dev/null; then
    BTOP_PATH=$(command -v btop)
    BTOP_VER=$(btop --version | head -n 1)
    echo -e "${GREEN}✅ Btop found at: $BTOP_PATH${NC}"
    echo -e "${GREEN}✅ $BTOP_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Btop is ready!${NC}"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Btop not found. Please install 'btop' via pacman.${NC}"
    exit 1
fi