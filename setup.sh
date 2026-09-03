#!/usr/bin/env bash

# ==========================================
# Arch Linux Development Setup Script
# Installs and configures development tools
# ==========================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/tools"

# ==========================================
# HELPER FUNCTIONS
# ==========================================

# Check if a command exists
cmd_exists() {
	command -v "$1" &>/dev/null
}

# Check if a pacman package is installed
pkg_installed() {
	pacman -Q "$1" &>/dev/null
}

# Print status message
print_status() {
	echo -e "${BLUE}[*]${NC} $1"
}

# Print success message
print_success() {
	echo -e "${GREEN}[✓]${NC} $1"
}

# Print warning message
print_warning() {
	echo -e "${YELLOW}[!]${NC} $1"
}

# Print error message
print_error() {
	echo -e "${RED}[✗]${NC} $1"
}

# Run a tool script if it exists
run_tool_script() {
	local script_name="$1"
	local script_path="$TOOLS_DIR/$script_name.sh"

	if [ ! -f "$script_path" ]; then
		print_warning "Tool script not found: $script_path"
		return 1
	fi

	echo -e "\n${BLUE}========================================${NC}"
	bash "$script_path"
	echo -e "${BLUE}========================================${NC}"
}

# ==========================================
# MAIN SETUP
# ==========================================

SECONDS=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Arch Linux Development Setup${NC}"
echo -e "${BLUE}========================================${NC}"

# Prevent running as root (makepkg in paru.sh will fail, and dotfiles shouldn't be root)
if [ "$EUID" -eq 0 ]; then
	print_error "Please do not run this script as root."
	echo "Run it as your normal user. The script will prompt for sudo when necessary."
	exit 1
fi

if ! cmd_exists pacman; then
	print_error "pacman not found. This setup is for Arch Linux only."
	exit 1
fi

# ==========================================
# STEP 1: SYSTEM UPDATE
# ==========================================
# A full sync now keeps every later install consistent (no partial upgrades,
# no 404s from stale databases) and provides fresh databases for 'dialog'.
echo -e "\n${BLUE}[1/3] Refreshing databases and updating system...${NC}"
sudo pacman -Syu --noconfirm
print_success "System is up to date"

# dialog powers the interactive menu below
if ! cmd_exists dialog; then
	print_status "Installing dialog for interactive menu..."
	sudo pacman -S --needed --noconfirm dialog
fi

# ==========================================
# SETUP PROFILES
# ==========================================

# Every package this setup can install
ALL_PACKAGES=(
	# Desktop environment (Wayland)
	hyprland
	xdg-desktop-portal-hyprland
	qt5-wayland
	qt6-wayland
	sddm
	ghostty
	waybar
	fuzzel
	mako
	hyprpaper
	hyprlock
	hypridle
	grim
	slurp
	wl-clipboard
	cliphist
	brightnessctl
	polkit-kde-agent

	# Terminal & development
	yazi
	ffmpegthumbnailer
	poppler
	fd
	ttf-jetbrains-mono
	ttf-nerd-fonts-symbols-common
	base-devel
	git
	neovim
	tmux
	zoxide
	eza
	fzf
	stow
	docker
	docker-compose
	tree-sitter-cli
	stylua
	taplo-cli
	yamlfmt
	shfmt
	shellcheck
	ripgrep
	bat
	btop

	# Required by fonts.sh
	wget
	unzip
)

# Server profile: terminal & development only (no GUI, no fonts)
SERVER_PACKAGES=(
	base-devel
	git
	docker
	docker-compose
	neovim
	tmux
	zoxide
	eza
	fzf
	fd
	ripgrep
	bat
	btop
	yazi
	ffmpegthumbnailer
	poppler
	tree-sitter-cli
	stylua
	taplo-cli
	yamlfmt
	shfmt
	shellcheck
	stow
)

# Order of execution for tool configuration scripts
TOOL_ORDER=(
	"base-devel"
	"paru"
	"wayland"
	"zen-browser"
	"yazi"
	"git"
	"docker"
	"neovim"
	"tree-sitter-cli"
	"tmux"
	"uv"
	"zoxide"
	"eza"
	"fzf"
	"ripgrep"
	"bat"
	"fd"
	"btop"
	"fonts"
	"stow"
)

# Server profile tools: no wayland, no zen-browser, no fonts
SERVER_TOOLS=(
	"base-devel"
	"paru"
	"yazi"
	"git"
	"docker"
	"neovim"
	"tree-sitter-cli"
	"tmux"
	"uv"
	"zoxide"
	"eza"
	"fzf"
	"ripgrep"
	"bat"
	"fd"
	"btop"
	"stow"
)

# Fail fast on profile typos instead of breaking pacman mid-install
declare -A PKG_LOOKUP=()
declare -A TOOL_LOOKUP=()
for pkg in "${ALL_PACKAGES[@]}"; do
	PKG_LOOKUP["$pkg"]=1
done
for tool in "${TOOL_ORDER[@]}"; do
	TOOL_LOOKUP["$tool"]=1
done
for pkg in "${SERVER_PACKAGES[@]}"; do
	if [ -z "${PKG_LOOKUP[$pkg]:-}" ]; then
		print_error "SERVER_PACKAGES contains unknown package: $pkg"
		exit 1
	fi
done
for tool in "${SERVER_TOOLS[@]}"; do
	if [ -z "${TOOL_LOOKUP[$tool]:-}" ]; then
		print_error "SERVER_TOOLS contains unknown tool: $tool"
		exit 1
	fi
done

# ==========================================
# INTERACTIVE TUI SETUP
# ==========================================

# Create a modern dark theme for dialog (private temp file, removed on exit)
DIALOGRC=$(mktemp)
export DIALOGRC
trap 'rm -f "$DIALOGRC"' EXIT

cat <<'EOF' >"$DIALOGRC"
use_shadow = ON
use_colors = ON
screen_color = (CYAN,BLACK,ON)
title_color = (MAGENTA,BLACK,ON)
dialog_color = (WHITE,BLACK,OFF)
border_color = (MAGENTA,BLACK,ON)
button_active_color = (WHITE,BLUE,ON)
button_inactive_color = (WHITE,BLACK,OFF)
button_key_active_color = (WHITE,BLUE,ON)
button_key_inactive_color = (RED,BLACK,OFF)
button_label_active_color = (WHITE,BLUE,ON)
button_label_inactive_color = (WHITE,BLACK,ON)
menubox_color = (WHITE,BLACK,OFF)
menubox_border_color = (MAGENTA,BLACK,ON)
item_color = (WHITE,BLACK,OFF)
item_selected_color = (BLACK,CYAN,ON)
tag_color = (GREEN,BLACK,ON)
tag_selected_color = (BLACK,CYAN,ON)
tag_key_color = (GREEN,BLACK,OFF)
tag_key_selected_color = (BLACK,CYAN,ON)
check_color = (CYAN,BLACK,ON)
check_selected_color = (BLACK,CYAN,ON)
uarrow_color = (GREEN,BLACK,ON)
darrow_color = (GREEN,BLACK,ON)
EOF

# ==========================================
# PROFILE SELECTION
# ==========================================
set +e
PROFILE=$(dialog --backtitle "✨ Arch Linux Developer Setup ✨" \
	--title " 🖥️  Setup Profile " \
	--colors \
	--menu "What kind of machine is this?\n\nPC installs the full desktop, Server stays headless." 14 62 2 \
	"pc" "Full desktop  - Hyprland, SDDM + all dev tools" \
	"server" "Headless      - terminal & dev tools, no GUI" \
	3>&1 1>&2 2>&3)
exit_status=$?
set -e
if [ $exit_status -ne 0 ]; then
	clear
	print_warning "Setup cancelled by user."
	exit 0
fi

case "$PROFILE" in
pc)
	SELECTED_PKG_ARRAY=("${ALL_PACKAGES[@]}")
	SELECTED_TOOL_ARRAY=("${TOOL_ORDER[@]}")
	PROFILE_LABEL="PC (full desktop)"
	;;
server)
	SELECTED_PKG_ARRAY=("${SERVER_PACKAGES[@]}")
	SELECTED_TOOL_ARRAY=("${SERVER_TOOLS[@]}")
	PROFILE_LABEL="Server (headless)"
	;;
esac

# Confirm before pulling the trigger
set +e
dialog --backtitle "✨ Arch Linux Developer Setup ✨" \
	--title " ${PROFILE_LABEL} " \
	--colors \
	--yesno "This will install ${#SELECTED_PKG_ARRAY[@]} pacman packages\nand run ${#SELECTED_TOOL_ARRAY[@]} tool configuration scripts.\n\nProceed with installation?" 12 56
exit_status=$?
set -e
if [ $exit_status -ne 0 ]; then
	clear
	print_warning "Setup cancelled by user."
	exit 0
fi

clear
print_status "Profile: ${PROFILE_LABEL} - ${#SELECTED_PKG_ARRAY[@]} packages, ${#SELECTED_TOOL_ARRAY[@]} tools"

# ==========================================
# STEP 2: INSTALL PACMAN PACKAGES
# ==========================================
echo -e "\n${BLUE}[2/3] Installing pacman packages...${NC}"

PACKAGES_TO_INSTALL=()

for pkg in "${SELECTED_PKG_ARRAY[@]}"; do
	if pkg_installed "$pkg"; then
		print_success "$pkg: already installed"
	else
		PACKAGES_TO_INSTALL+=("$pkg")
		print_warning "$pkg: will be installed"
	fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
	print_status "Installing ${#PACKAGES_TO_INSTALL[@]} package(s)..."
	sudo pacman -S --needed --noconfirm "${PACKAGES_TO_INSTALL[@]}"
	print_success "Pacman packages installed"
else
	print_success "All ${#SELECTED_PKG_ARRAY[@]} selected package(s) already installed"
fi

# ==========================================
# STEP 3: RUN TOOL CONFIGURATION SCRIPTS
# ==========================================
echo -e "\n${BLUE}[3/3] Running tool configuration scripts...${NC}"

# Fast O(1) lookup of which tools the profile selected
declare -A SELECTED_TOOL_SET=()
for tool in "${SELECTED_TOOL_ARRAY[@]}"; do
	SELECTED_TOOL_SET["$tool"]=1
done

FAILED_SCRIPTS=()

for script in "${TOOL_ORDER[@]}"; do
	if [ -n "${SELECTED_TOOL_SET[$script]:-}" ]; then
		if run_tool_script "$script"; then
			print_success "$script: completed"
		else
			print_error "$script: failed or skipped"
			FAILED_SCRIPTS+=("$script")
		fi
	fi
done

# ==========================================
# SUMMARY
# ==========================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Summary${NC}"
echo -e "${BLUE}========================================${NC}"

if [ ${#FAILED_SCRIPTS[@]} -eq 0 ]; then
	echo -e "${GREEN}✅ All ${#SELECTED_TOOL_ARRAY[@]} tool script(s) completed successfully!${NC}"
else
	echo -e "${YELLOW}⚠️  ${#FAILED_SCRIPTS[@]}/${#SELECTED_TOOL_ARRAY[@]} tool script(s) had issues:${NC}"
	for script in "${FAILED_SCRIPTS[@]}"; do
		echo -e "  ${YELLOW}-${NC} $script"
	done
fi

echo -e "\n${YELLOW}Next steps:${NC}"
echo "  1. Reload your shell: exec \$SHELL"
echo "  2. Verify key tools: command -v git nvim tmux paru docker uv rg fd eza bat btop shfmt shellcheck"
echo "  3. Check dotfiles: ls -la ~/"
echo "  4. Activate Docker permissions: newgrp docker"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}Setup complete in $((SECONDS / 60))m $((SECONDS % 60))s!${NC}"
echo -e "${BLUE}========================================${NC}"
