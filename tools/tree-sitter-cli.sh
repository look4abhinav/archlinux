#!/usr/bin/env bash

# ==========================================
# Tree-sitter CLI Verification Script
# Verifies the tree-sitter CLI installation
# ==========================================

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Tree-sitter CLI Verification${NC}"
echo -e "${BLUE}========================================${NC}"

if command -v tree-sitter &>/dev/null; then
	TS_PATH=$(command -v tree-sitter)
	TS_VER=$(tree-sitter --version | head -n 1)
	echo -e "${GREEN}✅ tree-sitter found at: $TS_PATH${NC}"
	echo -e "${GREEN}✅ $TS_VER${NC}"
else
	echo -e "${RED}❌ tree-sitter not found. Please install it via pacman first.${NC}"
	exit 1
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Tree-sitter CLI setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
