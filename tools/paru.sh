#!/usr/bin/bash

# ==========================================
# Paru Setup & Verification Script
# Installs the Paru AUR helper
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Paru (AUR Helper) Setup${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Checking for Paru installation...${NC}"

if command -v paru &> /dev/null; then
    PARU_PATH=$(command -v paru)
    PARU_VER=$(paru --version | head -n 1)
    echo -e "${GREEN}✅ Paru found at: $PARU_PATH${NC}"
    echo -e "${GREEN}✅ $PARU_VER${NC}"
else
    echo -e "${YELLOW}⚠️  Paru not found. Building from AUR...${NC}"
    
    # Create a temporary build directory
    BUILD_DIR=$(mktemp -d)
    echo -e "${BLUE}Cloning into temporary directory: $BUILD_DIR${NC}"
    
    git clone https://aur.archlinux.org/paru.git "$BUILD_DIR"
    
    # Run makepkg inside the build directory
    cd "$BUILD_DIR"
    echo -e "${BLUE}Building and installing paru...${NC}"
    # -s: install dependencies, -i: install package, --noconfirm: don't prompt
    makepkg -si --noconfirm
    
    # Cleanup
    cd "$HOME"
    rm -rf "$BUILD_DIR"
    
    echo -e "${GREEN}✅ Paru built and installed successfully!${NC}"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ AUR Helper setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"