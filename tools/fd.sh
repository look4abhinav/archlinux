#!/usr/bin/bash

# ==========================================
# fd Verification Script
# Verifies fd installation
# ==========================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}fd Verification${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Verifying fd installation...${NC}"

if command -v fd &> /dev/null; then
    FD_PATH=$(command -v fd)
    FD_VER=$(fd --version | head -n 1)
    echo -e "${GREEN}✅ fd found at: $FD_PATH${NC}"
    echo -e "${GREEN}✅ $FD_VER${NC}"
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ fd is ready!${NC}"
    echo -e "${YELLOW}Usage tip:${NC} Use 'fd <pattern>' instead of find for faster and simpler searches"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ fd not found. Please install 'fd' via pacman.${NC}"
    exit 1
fi