#!/usr/bin/env bash
set -e 

echo "🚀 Bootstrapping Arch Linux Setup ..."

# Safely create a temporary directory
INSTALL_DIR=$(mktemp -d -t arch-setup-XXXXXX)

# Ensure the temp directory is cleaned up even if the script fails midway
trap 'rm -rf -- "$INSTALL_DIR"' EXIT

if ! command -v git &> /dev/null; then
    echo "📦 Installing git..."
    sudo pacman -S --noconfirm git
fi

echo "📥 Cloning repository into $INSTALL_DIR..."
git clone https://github.com/look4abhinav/archlinux.git "$INSTALL_DIR"
cd "$INSTALL_DIR"

chmod +x setup.sh
echo "⚙️ Executing setup.sh..."
./setup.sh

echo "✅ Setup complete! Directory will be cleaned up automatically."
