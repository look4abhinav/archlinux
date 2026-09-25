#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_packages ttf-jetbrains-mono-nerd inter-font fontconfig
require_command fc-match

CURSOR_DIR='/usr/share/icons/Bibata-Modern-Ice'

verify_font_family() {
	local expected=$1
	local matched

	if ! matched=$(fc-match --format='%{family[0]}' "$expected" 2>/dev/null); then
		die "fc-match failed for font family: $expected"
	fi
	[[ "$matched" == "$expected" ]] ||
		die "Font family '$expected' is unavailable; fc-match returned '$matched'."
	print_success "Font family verified: $expected"
}

print_section 'Font verification'
verify_font_family 'JetBrainsMono Nerd Font'
verify_font_family 'Inter'

if ! pacman -Qq bibata-cursor-theme >/dev/null 2>&1; then
	die 'AUR package bibata-cursor-theme is required for Bibata-Modern-Ice cursors.'
fi
[[ -d $CURSOR_DIR ]] || die "Bibata-Modern-Ice cursor directory not found: $CURSOR_DIR"
print_success "Cursor directory verified: $CURSOR_DIR"
print_success 'Font verification complete.'
