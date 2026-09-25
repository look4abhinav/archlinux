#!/usr/bin/env bash

set -Eeuo pipefail

print_status() {
	printf '[*] %s\n' "$*"
}

print_success() {
	printf '[+] %s\n' "$*"
}

print_error() {
	printf '[x] %s\n' "$*" >&2
}

die() {
	print_error "$*"
	exit 1
}

((EUID != 0)) || die 'Do not run this installer as root.'
[[ -t 1 ]] || die 'An interactive terminal is required.'
command -v pacman >/dev/null 2>&1 || die 'Required command not found: pacman'
command -v mktemp >/dev/null 2>&1 || die 'Required command not found: mktemp'
command -v rm >/dev/null 2>&1 || die 'Required command not found: rm'

print_status 'Bootstrapping Arch Linux setup'

if ! command -v git >/dev/null 2>&1; then
	command -v sudo >/dev/null 2>&1 || die 'Required command not found: sudo'
	print_status 'Installing git with a full system upgrade'
	sudo pacman -Syu --needed --noconfirm git
fi
command -v git >/dev/null 2>&1 || die 'Git installation failed.'

INSTALL_DIR=$(mktemp -d -t arch-setup-XXXXXX)
cleanup() {
	rm -rf -- "$INSTALL_DIR"
}
trap cleanup EXIT

print_status "Cloning the setup repository into $INSTALL_DIR"
git clone --depth 1 https://github.com/look4abhinav/archlinux.git "$INSTALL_DIR"

print_status 'Running setup.sh'
(
	cd -- "$INSTALL_DIR"
	bash setup.sh
)

print_success 'Setup completed successfully'
