#!/usr/bin/env bash

if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
	BLUE=$'\033[0;34m'
	GREEN=$'\033[0;32m'
	YELLOW=$'\033[0;33m'
	RED=$'\033[0;31m'
	RESET=$'\033[0m'
else
	BLUE=
	GREEN=
	YELLOW=
	RED=
	RESET=
fi

print_status() {
	printf '%s[*]%s %s\n' "$BLUE" "$RESET" "$*"
}

print_success() {
	printf '%s[+]%s %s\n' "$GREEN" "$RESET" "$*"
}

print_warning() {
	printf '%s[!]%s %s\n' "$YELLOW" "$RESET" "$*" >&2
}

print_error() {
	printf '%s[x]%s %s\n' "$RED" "$RESET" "$*" >&2
}

print_section() {
	printf '\n%s==> %s%s\n' "$BLUE" "$*" "$RESET"
}

die() {
	print_error "$*"
	exit 1
}

require_non_root() {
	((EUID != 0)) || die 'Do not run this installer as root.'
}

require_tty() {
	[[ -t 1 ]] || die 'An interactive terminal is required.'
}

require_command() {
	command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

require_commands() {
	local missing=()
	local item
	for item in "$@"; do
		command -v "$item" >/dev/null 2>&1 || missing+=("$item")
	done
	((${#missing[@]} == 0)) || die "Required commands not found: ${missing[*]}"
}

require_package() {
	pacman -Qq "$1" >/dev/null 2>&1 || die "Required package not installed: $1"
}

require_packages() {
	local missing=()
	local item
	for item in "$@"; do
		pacman -Qq "$item" >/dev/null 2>&1 || missing+=("$item")
	done
	((${#missing[@]} == 0)) || die "Required packages not installed: ${missing[*]}"
}

verify_command() {
	local name=$1
	shift
	local path version
	path=$(command -v "$name" 2>/dev/null) || {
		print_error "Command not found: $name"
		return 1
	}
	if (($# > 0)); then
		if ! version=$("$name" "$@" 2>&1) || [[ -z $version ]]; then
			print_error "Version probe failed: $name"
			return 1
		fi
		version=${version%%$'\n'*}
		print_success "$name: $version"
	else
		print_success "$name: $path"
	fi
}
