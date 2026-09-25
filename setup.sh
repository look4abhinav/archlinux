#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

TOOLS_DIR="$SCRIPT_DIR/tools"

require_non_root
require_tty
require_command pacman
require_command sudo
require_command mktemp
require_command rm
require_command cat

SECONDS=0

validate_unique() {
	local label=$1
	shift
	local item
	local -A seen=()

	for item in "$@"; do
		if [[ -n ${seen[$item]:-} ]]; then
			die "$label contains duplicate entry: $item"
		fi
		seen["$item"]=1
	done
}

validate_tools() {
	local label=$1
	shift
	local tool

	for tool in "$@"; do
		[[ $tool =~ ^[a-z0-9][a-z0-9-]*$ ]] ||
			die "$label contains invalid tool name: $tool"
		[[ -n ${KNOWN_TOOL_LOOKUP[$tool]:-} ]] ||
			die "$label contains unknown tool: $tool"
		[[ -f "$TOOLS_DIR/$tool.sh" ]] ||
			die "Tool script not found: $tool"
	done
}

PC_PACKAGES=(
	base-devel
	bat
	btop
	curl
	dialog
	docker
	docker-compose
	eza
	fd
	ffmpegthumbnailer
	fzf
	github-cli
	git
	htop
	jq
	less
	neovim
	openssh
	poppler
	python
	ripgrep
	ruff
	shfmt
	shellcheck
	stow
	stylua
	taplo-cli
	tmux
	tree-sitter-cli
	ty
	uv
	yamlfmt
	yazi
	zoxide
	zsh
	bluez
	bluez-utils
	bluetui
	brightnessctl
	cliphist
	code
	fontconfig
	fuzzel
	ghostty
	grim
	hypridle
	hyprlock
	hyprpaper
	hyprland
	inter-font
	kanshi
	libnotify
	mako
	networkmanager
	pavucontrol
	pipewire-pulse
	polkit-kde-agent
	qt5ct
	qt5-wayland
	qt6-wayland
	sddm
	signal-desktop
	slurp
	thunar
	ttf-jetbrains-mono-nerd
	waybar
	weston
	wl-clipboard
	wireplumber
	wtype
	xdg-desktop-portal-hyprland
	xdg-utils
	zed
)

SERVER_PACKAGES=(
	base-devel
	bat
	btop
	dialog
	docker
	docker-compose
	eza
	fd
	fzf
	github-cli
	git
	htop
	less
	neovim
	openssh
	python
	ripgrep
	ruff
	shfmt
	shellcheck
	stow
	stylua
	taplo-cli
	tmux
	tree-sitter-cli
	ty
	uv
	yamlfmt
	yazi
	zoxide
	zsh
)

PC_TOOLS=(
	base-devel
	paru
	tmux
	stow
	tmux-plugins
	zsh
	git
	neovim
	wayland
	services
	fonts
	uv
	docker
	zen-browser
	tree-sitter-cli
	zoxide
	eza
	fzf
	ripgrep
	bat
	fd
	btop
	yazi
)

SERVER_TOOLS=(
	base-devel
	tmux
	stow
	tmux-plugins
	zsh
	git
	neovim
	services
	uv
	docker
	tree-sitter-cli
	zoxide
	eza
	fzf
	ripgrep
	bat
	fd
	btop
	yazi
)

KNOWN_TOOLS=(
	base-devel
	paru
	tmux
	stow
	tmux-plugins
	zsh
	git
	neovim
	wayland
	services
	fonts
	uv
	docker
	zen-browser
	tree-sitter-cli
	zoxide
	eza
	fzf
	ripgrep
	bat
	fd
	btop
	yazi
)

declare -A KNOWN_TOOL_LOOKUP=()
for tool in "${KNOWN_TOOLS[@]}"; do
	KNOWN_TOOL_LOOKUP["$tool"]=1
done

validate_unique 'PC_PACKAGES' "${PC_PACKAGES[@]}"
validate_unique 'SERVER_PACKAGES' "${SERVER_PACKAGES[@]}"
validate_unique 'PC_TOOLS' "${PC_TOOLS[@]}"
validate_unique 'SERVER_TOOLS' "${SERVER_TOOLS[@]}"
validate_unique 'KNOWN_TOOLS' "${KNOWN_TOOLS[@]}"
validate_tools 'PC_TOOLS' "${PC_TOOLS[@]}"
validate_tools 'SERVER_TOOLS' "${SERVER_TOOLS[@]}"

print_section 'System bootstrap'
print_status 'Refreshing the system and ensuring dialog is installed'
sudo pacman -Syu --needed --noconfirm dialog
require_command dialog
print_success 'System bootstrap completed'

DIALOGRC=$(mktemp)
export DIALOGRC
cleanup_dialog() {
	rm -f -- "$DIALOGRC"
}
trap cleanup_dialog EXIT

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

print_section 'Profile selection'
if PROFILE=$(dialog --backtitle 'Arch Linux setup' \
	--title 'Setup profile' \
	--colors \
	--menu 'What kind of machine is this?\n\nPC installs the desktop. Server stays headless.' 14 62 2 \
	'pc' 'Full desktop - Hyprland, SDDM, and development tools' \
	'server' 'Headless - terminal and development tools' \
	3>&1 1>&2 2>&3); then
	:
else
	print_warning 'Setup cancelled by user.'
	exit 1
fi

case "$PROFILE" in
	pc)
		SELECTED_PACKAGES=("${PC_PACKAGES[@]}")
		SELECTED_TOOLS=("${PC_TOOLS[@]}")
		PROFILE_LABEL='PC (full desktop)'
		;;
	server)
		SELECTED_PACKAGES=("${SERVER_PACKAGES[@]}")
		SELECTED_TOOLS=("${SERVER_TOOLS[@]}")
		PROFILE_LABEL='Server (headless)'
		;;
	*)
		die 'Invalid profile selection.'
		;;
esac

export SETUP_PROFILE="$PROFILE"

print_section 'Confirmation'
if dialog --backtitle 'Arch Linux setup' \
	--title "$PROFILE_LABEL" \
	--colors \
	--yesno "This will install ${#SELECTED_PACKAGES[@]} pacman packages and run ${#SELECTED_TOOLS[@]} tool scripts.\n\nProceed?" 12 56; then
	:
else
	print_warning 'Setup cancelled by user.'
	exit 1
fi

print_status "Profile: $PROFILE_LABEL"

print_section 'Package installation'
print_status "Installing ${#SELECTED_PACKAGES[@]} packages with pacman"
sudo pacman -S --needed --noconfirm "${SELECTED_PACKAGES[@]}"
print_success 'Selected pacman packages installed'

print_section 'Tool configuration'
FAILED_TOOLS=()
for tool in "${SELECTED_TOOLS[@]}"; do
	print_section "$tool"
	if bash "$TOOLS_DIR/$tool.sh"; then
		print_success "$tool completed"
	else
		tool_status=$?
		print_error "$tool failed with status $tool_status"
		FAILED_TOOLS+=("$tool")
	fi
done

print_section 'Setup summary'
total_tools=${#SELECTED_TOOLS[@]}
failed_count=${#FAILED_TOOLS[@]}
successful_count=$((total_tools - failed_count))
print_status "Tools completed: $successful_count/$total_tools"
if ((failed_count > 0)); then
	print_error "Setup failed: $failed_count tool script(s) failed."
	for tool in "${FAILED_TOOLS[@]}"; do
		print_error "Failed tool: $tool"
	done
	exit 1
fi

print_success "Setup completed in $((SECONDS / 60))m $((SECONDS % 60))s"
print_status "Reload your shell with: exec \$SHELL"
print_status 'Activate Docker permissions with: newgrp docker'
