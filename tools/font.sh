#!/usr/bin/bash

# ==========================================
# Nerd Fonts Setup Script
# Downloads and installs JetBrainsMono Nerd Font
# ==========================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

FONT_NAME="JetBrainsMono"
FONT_DIR="$HOME/.local/share/fonts"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Nerd Fonts Setup (${FONT_NAME})${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}Checking for ${FONT_NAME} Nerd Font...${NC}"

# Check if the font is registered in the font cache
if fc-list | grep -iq "$FONT_NAME"; then
    echo -e "${GREEN}✅ $FONT_NAME Nerd Font is already installed.${NC}"
else
    echo -e "${YELLOW}⚠️  Font not found. Downloading and installing...${NC}"
    
    # Ensure font directory exists
    mkdir -p "$FONT_DIR"
    
    # Create temp directory for download/extraction
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    echo -e "${BLUE}Downloading $FONT_NAME from GitHub...${NC}"
    if wget -q --show-progress "$FONT_URL" -O "${FONT_NAME}.zip"; then
        echo -e "${BLUE}Extracting fonts...${NC}"
        unzip -q "${FONT_NAME}.zip" -d "$FONT_DIR"
        
        echo -e "${BLUE}Updating font cache...${NC}"
        fc-cache -fv &> /dev/null
        
        echo -e "${GREEN}✅ $FONT_NAME Nerd Font installed successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to download font.${NC}"
        rm -rf "$TMP_DIR"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$TMP_DIR"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Font setup complete!${NC}"
echo -e "${YELLOW}Note: Configure your terminal emulator to use '$FONT_NAME Nerd Font'${NC}"
echo -e "${BLUE}========================================${NC}"