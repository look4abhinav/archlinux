#!/usr/bin/env bash

# ==========================================
# Bootstrap Installer
# Clones the setup repo into a temp dir and runs setup.sh
# ==========================================

set -e

echo "🚀 Bootstrapping Arch Linux Setup ..."

if [ "$EUID" -eq 0 ]; then
	echo "❌ Please do not run this script as root."
	echo "Run it as your normal user. It will prompt for sudo when necessary."
	exit 1
fi

if ! command -v pacman &>/dev/null; then
	echo "❌ pacman not found. This installer is for Arch Linux only."
	exit 1
fi

# Safely create a temporary directory, cleaned up even if the script fails midway
INSTALL_DIR=$(mktemp -d -t arch-setup-XXXXXX)
trap 'rm -rf -- "$INSTALL_DIR"' EXIT

if ! command -v git &>/dev/null; then
	echo "📦 Installing git (full system refresh to avoid partial upgrades)..."
	sudo pacman -Syu --noconfirm git
fi

echo "📥 Cloning repository into $INSTALL_DIR..."
git clone --depth 1 https://github.com/look4abhinav/archlinux.git "$INSTALL_DIR"

echo "⚙️  Executing setup.sh..."
(
	cd "$INSTALL_DIR"
	bash setup.sh
)

echo "✅ Setup complete! The temporary directory will be cleaned up automatically."
