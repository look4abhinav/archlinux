#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root

verify_zen_browser() {
	local version

	command -v zen-browser >/dev/null 2>&1 || die 'The zen-browser binary was not found after installation.'
	if ! version=$(zen-browser --version 2>&1); then
		die 'The zen-browser binary exists but cannot be executed.'
	fi
	[[ -n $version ]] || die 'zen-browser returned no version information.'
	print_success "zen-browser: ${version%%$'\n'*}"
}

print_section 'Zen Browser setup'

if command -v zen-browser >/dev/null 2>&1; then
	verify_zen_browser
else
	require_command paru

	print_status 'Installing zen-browser-bin'
	if ! paru -S --needed --noconfirm zen-browser-bin; then
		die 'Failed to install zen-browser-bin.'
	fi

	verify_zen_browser
	print_success 'Zen Browser setup complete.'
fi
