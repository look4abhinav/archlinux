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

DOTFILES_DIR="$HOME/dotfiles"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Dotfiles Setup via GNU Stow${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# PRE-FLIGHT DEPENDENCY CHECK
# ==========================================
echo -e "\n${BLUE}Checking core dependencies...${NC}"
DEPS=("git" "stow")
for cmd in "${DEPS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}❌ Missing dependency: $cmd${NC}"
        echo "Please install it via pacman first."
        exit 1
    else
        echo -e "${GREEN}✅ $cmd: installed${NC}"
    fi
done

# ==========================================
# PART 1: CHECK/CLONE DOTFILES REPOSITORY
# ==========================================
echo -e "\n${BLUE}[1/2] Checking dotfiles repository...${NC}"

if [ -d "$DOTFILES_DIR" ]; then
    echo -e "${GREEN}✅ Dotfiles directory found at: $DOTFILES_DIR${NC}"
    
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
    
    # We can skip the mkdir -p since $HOME already exists
    if git clone https://github.com/look4abhinav/dotfiles.git "$DOTFILES_DIR"; then
        echo -e "${GREEN}✅ Dotfiles cloned successfully${NC}"
    else
        echo -e "${RED}❌ Failed to clone dotfiles. Make sure:${NC}"
        echo "    - The repository is accessible at https://github.com/look4abhinav/dotfiles.git"
        echo "    - You have an active internet connection"
        exit 1
    fi
fi

# ==========================================
# PART 2: STOW DOTFILES
# ==========================================
echo -e "\n${BLUE}[2/2] Stowing dotfiles...${NC}"

# Treat the dotfiles directory itself as the package using '.'
if stow -d "$DOTFILES_DIR" -t ~ .; then
    echo -e "${GREEN}✅ Dotfiles stowed successfully${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
else
    echo -e "${RED}❌ Failed to stow dotfiles${NC}"
    echo -e "${YELLOW}Fixing Conflicts:${NC} If Stow says a file already exists (like ~/.zshrc),"
    echo -e "you must delete the existing file first, or run:"
    echo -e "  stow --adopt -d \"$DOTFILES_DIR\" -t ~ ."
    exit 1
fi
