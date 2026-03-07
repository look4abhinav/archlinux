#!/usr/bin/bash

# ==========================================
# Base-devel Verification Script
# Verifies installation of base-devel group
# base-devel includes essential build tools (gcc, make, fakeroot, etc.)
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Base-devel Verification${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# VERIFY ESSENTIAL BUILD TOOLS
# ==========================================
echo -e "\n${BLUE}Verifying essential build tools...${NC}"

# Added 'fakeroot' and 'patch' as they are crucial for AUR makepkg builds
TOOLS=("gcc" "make" "pkg-config" "bison" "flex" "m4" "fakeroot" "patch")
MISSING_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        # Fetch the version string cleanly
        TOOL_VER=$($tool --version 2>/dev/null | head -n 1)
        
        # FIXED: Actually output the TOOL_VER variable we captured
        if [ -n "$TOOL_VER" ]; then
            echo -e "${GREEN}✅ $tool: installed (${TOOL_VER})${NC}"
        else
            echo -e "${GREEN}✅ $tool: installed${NC}"
        fi
    else
        echo -e "${RED}❌ $tool: NOT FOUND${NC}"
        MISSING_TOOLS+=("$tool")
    fi
done

# ==========================================
# REPORT STATUS
# ==========================================
echo -e "\n${BLUE}========================================${NC}"

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All base-devel tools are installed!${NC}"
else
    # FIXED: Output array properly using the [*] expansion syntax
    echo -e "${RED}❌ Missing tools: ${MISSING_TOOLS[*]}${NC}"
    echo -e "\n${BLUE}To install base-devel group:${NC}"
    echo "  sudo pacman -S --needed base-devel"
fi

echo -e "${BLUE}========================================${NC}"