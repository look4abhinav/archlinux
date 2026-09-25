#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root

verify_paru() {
	local version

	command -v paru >/dev/null 2>&1 || die 'The paru binary was not found after installation.'
	if ! version=$(paru --version 2>&1); then
		die 'The paru binary exists but cannot be executed.'
	fi
	[[ -n $version ]] || die 'paru returned no version information.'
	print_success "paru: ${version%%$'\n'*}"
}

cleanup_build() {
	rm -rf -- "$BUILD_DIR"
}

print_section 'Paru setup'

if command -v paru >/dev/null 2>&1; then
	verify_paru
else
	require_commands git makepkg pacman mktemp rm
	require_package base-devel

	BUILD_DIR=$(mktemp -d)
	trap cleanup_build EXIT
	trap 'exit 129' HUP
	trap 'exit 130' INT
	trap 'exit 143' TERM

	print_status "Cloning paru into $BUILD_DIR"
	if ! git clone --depth 1 https://aur.archlinux.org/paru.git "$BUILD_DIR"; then
		die 'Failed to clone the paru AUR repository.'
	fi

	print_status 'Building and installing paru'
	if ! (
		cd -- "$BUILD_DIR"
		makepkg -si --noconfirm
	); then
		die 'Failed to build or install paru.'
	fi

	verify_paru
	print_success 'Paru setup complete.'
fi
