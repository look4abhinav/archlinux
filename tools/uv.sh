#!/bin/bash

# ==========================================
# UV (Python Environment Manager) Installer
# Astral: https://docs.astral.sh/uv/
# ==========================================

set -e

echo "------------------------------------------"
echo "UV Installation & Setup"
echo "------------------------------------------"

echo "[1/4] Cleaning up legacy pip installations..."
# The official installer handles overwriting existing binaries gracefully,
# but we remove pip-installed versions to prevent PATH conflicts.
if pip list 2>/dev/null | grep -q "^uv "; then
    echo "  Removing UV installed via pip..."
    pip uninstall uv -y 2>/dev/null || true
else
    echo "  No pip installations found."
fi

echo ""
echo "[2/4] Installing UV..."
# Download and run the official installer. 
# This automatically places binaries in ~/.local/bin and configures your shell profile.
if curl -LsSf https://astral.sh/uv/install.sh | sh; then
    echo "✅  UV installation script executed successfully."
else
    echo "❌  Failed to run UV installation script."
    exit 1
fi

# Add ~/.local/bin to the current script's PATH so the remaining commands work
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "[3/4] Installing UV Tools..."
# Verify uv command is available in the current session
if command -v uv &> /dev/null; then
    
    # Install tools using the modern `uv tool install` command
    echo "  Installing 'ty' tool..."
    if uv tool install ty; then
        echo "  ✅  ty installed"
    else
        echo "  ⚠️  Failed to install ty"
    fi
    
    echo "  Installing 'ruff' tool..."
    if uv tool install ruff; then
        echo "  ✅  ruff installed"
    else
        echo "  ⚠️  Failed to install ruff"
    fi
    
else
    echo "  ❌  UV binary not found in PATH. Installation may have failed."
    exit 1
fi

echo ""
echo "[4/4] Verification Report"
echo "------------------------------------------"

verify_tool() {
    local name=$1
    if command -v "$name" &> /dev/null; then
        local version=$($name --version 2>&1 | head -n 1)
        echo "✅  $name: FOUND ($version)"
    else
        echo "❌  $name: NOT FOUND"
    fi
}

verify_tool "uv"
verify_tool "uvx"
verify_tool "ty"
verify_tool "ruff"

echo "------------------------------------------"
echo ""
echo "Installation Summary:"
echo "  • UV and tools have been installed to: ~/.local/bin"
echo "  • The installer automatically updated your shell configuration."
echo ""
echo "Note: To use these tools in your current terminal session, run:"
echo "  source ~/.bashrc (or ~/.zshrc) OR simply open a new terminal."
echo "=========================================="