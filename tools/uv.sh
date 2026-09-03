#!/usr/bin/env bash

# ==========================================
# UV (Python Environment Manager) Setup
# Installs uv plus Python tools (ty, ruff)
# https://docs.astral.sh/uv/
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}UV (Python Environment Manager) Setup${NC}"
echo -e "${BLUE}========================================${NC}"

# ==========================================
# 1. REMOVE LEGACY PIP INSTALLS
# ==========================================
echo -e "\n${BLUE}[1/3] Cleaning up legacy pip installations...${NC}"
if pip list 2>/dev/null | grep -q "^uv "; then
	echo -e "${YELLOW}⚠️  Removing uv installed via pip...${NC}"
	pip uninstall uv -y 2>/dev/null || true
else
	echo -e "${GREEN}✅ No pip-managed uv found.${NC}"
fi

# ==========================================
# 2. INSTALL UV
# ==========================================
echo -e "\n${BLUE}[2/3] Installing uv...${NC}"
# Binaries land in ~/.local/bin. Shell PATH is managed by dotfiles,
# so the installer is told not to touch any rc files.
if curl -LsSf https://astral.sh/uv/install.sh | UV_NO_MODIFY_PATH=1 sh; then
	echo -e "${GREEN}✅ uv installed to ~/.local/bin${NC}"
else
	echo -e "${RED}❌ Failed to run the uv installer.${NC}"
	exit 1
fi

export PATH="$HOME/.local/bin:$PATH"

# ==========================================
# 3. INSTALL PYTHON TOOLS
# ==========================================
echo -e "\n${BLUE}[3/3] Installing Python tools...${NC}"

if ! command -v uv &>/dev/null; then
	echo -e "${RED}❌ uv binary not found in PATH. Installation may have failed.${NC}"
	exit 1
fi

for tool in ty ruff; do
	if uv tool install "$tool"; then
		echo -e "${GREEN}✅ $tool installed${NC}"
	else
		echo -e "${YELLOW}⚠️  Failed to install $tool${NC}"
	fi
done

# ==========================================
# VERIFICATION REPORT
# ==========================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Verification Report${NC}"
echo -e "${BLUE}========================================${NC}"

verify_tool() {
	local name=$1
	if command -v "$name" &>/dev/null; then
		local version
		version=$($name --version 2>&1 | head -n 1)
		echo -e "${GREEN}✅ $name: found ($version)${NC}"
	else
		echo -e "${RED}❌ $name: not found${NC}"
	fi
}

verify_tool "uv"
verify_tool "uvx"
verify_tool "ty"
verify_tool "ruff"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ UV setup complete!${NC}"
echo -e "${YELLOW}Note:${NC} Run 'exec \$SHELL' (or open a new terminal) to use these tools."
echo -e "${BLUE}========================================${NC}"
