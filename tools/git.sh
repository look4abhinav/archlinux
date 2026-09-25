#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_commands git gh

CONFIG_FILE="$HOME/.gitconfig"
IDENTITY_KEYS=(user.name user.email)

print_section 'Git verification'
verify_command git --version
verify_command gh --version
[[ -f $CONFIG_FILE ]] || die "Stowed Git configuration not found: $CONFIG_FILE"

for key in "${IDENTITY_KEYS[@]}"; do
	if ! value=$(git config --file "$CONFIG_FILE" --get "$key" 2>/dev/null); then
		die "Missing $key in $CONFIG_FILE"
	fi
	[[ -n $value ]] || die "Empty $key in $CONFIG_FILE"
	print_success "Git config verified: $key"
done

if gh auth status >/dev/null 2>&1; then
	print_success 'GitHub CLI is authenticated.'
else
	print_warning 'GitHub CLI is not authenticated.'
	print_status 'Run once: gh auth login'
fi
print_success 'Git verification complete.'
