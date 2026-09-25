#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_commands getent id sudo usermod zsh

TARGET_USER=$(id -un)
TARGET_SHELL=$(command -v zsh)

print_section 'Zsh login shell'
passwd_entry=$(getent passwd "$TARGET_USER") || die "Unable to resolve user: $TARGET_USER"
IFS=: read -r _ _ _ _ _ _ current_shell _ <<<"$passwd_entry"

if [[ $current_shell == "$TARGET_SHELL" ]]; then
	print_success "$TARGET_USER already uses $TARGET_SHELL"
else
	print_status "Setting $TARGET_USER login shell to $TARGET_SHELL"
	if ! sudo usermod -s "$TARGET_SHELL" "$TARGET_USER"; then
		die "Failed to update the login shell for $TARGET_USER."
	fi

	passwd_entry=$(getent passwd "$TARGET_USER") || die "Unable to re-read user: $TARGET_USER"
	IFS=: read -r _ _ _ _ _ _ verified_shell _ <<<"$passwd_entry"
	[[ $verified_shell == "$TARGET_SHELL" ]] ||
		die "Login shell verification failed for $TARGET_USER."
fi

print_success 'Zsh login shell configured.'
