#!/usr/bin/bash

# ==========================================
# Stow Configuration Script
# Manages dotfiles symlinks via GNU Stow
# Clones or updates dotfiles repository
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$(pwd)/dotfiles"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Dotfiles Setup via GNU Stow${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# PART 1: CHECK/CLONE DOTFILES REPOSITORY
# ==========================================
echo -e "\n${BLUE}[1/2] Checking dotfiles repository...${NC}"

if [ -d "$DOTFILES_DIR" ]; then
    echo -e "${GREEN}✅ Dotfiles directory found at: $DOTFILES_DIR${NC}"
    
    # Update existing repository
    echo -e "${BLUE}Updating dotfiles (git pull --rebase)...${NC}"
    cd "$DOTFILES_DIR"
    
    if git pull --rebase; then
        echo -e "${GREEN}✅ Dotfiles updated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to update dotfiles${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Dotfiles directory not found${NC}"
    echo -e "${BLUE}Cloning dotfiles repository...${NC}"
    
    DOTFILES_PARENT=$(dirname "$DOTFILES_DIR")
    mkdir -p "$DOTFILES_PARENT"
    
    if gh repo clone dotfiles "$DOTFILES_DIR"; then
        echo -e "${GREEN}✅ Dotfiles cloned successfully${NC}"
    else
        echo -e "${RED}❌ Failed to clone dotfiles. Make sure:${NC}"
        echo "    - GitHub CLI (gh) is installed and authenticated"
        echo "    - Your dotfiles repository exists as 'dotfiles'"
        exit 1
    fi
fi

# ==========================================
# PART 2: STOW DOTFILES
# ==========================================
echo -e "\n${BLUE}[2/2] Stowing dotfiles...${NC}"

cd "$DOTFILES_DIR"

if stow -d . -t ~ .; then
    echo -e "${GREEN}✅ Dotfiles stowed successfully${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Failed to stow dotfiles${NC}"
    echo -e "Check for conflicts or missing directories"
    exit 1
fi
