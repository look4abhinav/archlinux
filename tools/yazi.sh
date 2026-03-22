#!/usr/bin/bash

# ==========================================
# Yazi Setup & Verification Script
# Fast, async terminal file manager
# ==========================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Yazi Setup${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Checking for Yazi...${NC}"

if command -v yazi &> /dev/null; then
    YAZI_PATH=$(command -v yazi)
    YAZI_VER=$(yazi --version | head -n 1)
    echo -e "${GREEN}✅ Yazi found at: $YAZI_PATH${NC}"
    echo -e "${GREEN}✅ $YAZI_VER${NC}"
else
    echo -e "${RED}❌ Yazi not found. Please add 'yazi' to the PACKAGES array in setup.sh.${NC}"
    exit 1
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Yazi setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
