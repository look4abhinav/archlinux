#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_commands git tmux mkdir mktemp mv rm

TPM_ROOT="$HOME/.config/tmux/plugins"
TPM_DIR="$TPM_ROOT/tpm"
TPM_URL='https://github.com/tmux-plugins/tpm'
TEMP_DIR=

cleanup() {
	if [[ -n ${TEMP_DIR:-} ]]; then
		rm -rf -- "$TEMP_DIR"
	fi
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

print_section 'Tmux and TPM setup'
verify_command tmux -V
verify_command git --version

if [[ -e $TPM_DIR || -L $TPM_DIR ]]; then
	[[ -d $TPM_DIR ]] || die "The TPM path is not a directory: $TPM_DIR"
else
	if ! mkdir -p "$TPM_ROOT"; then
		die "Unable to create the TPM parent directory: $TPM_ROOT"
	fi
	TEMP_DIR=$(mktemp -d "$TPM_ROOT/.tpm.XXXXXX")
	print_status "Cloning TPM into $TEMP_DIR"
	if ! git clone --depth 1 "$TPM_URL" "$TEMP_DIR"; then
		die 'Failed to clone TPM.'
	fi
	[[ -f $TEMP_DIR/scripts/install_plugins.sh ]] ||
		die 'Cloned TPM is incomplete; missing scripts/install_plugins.sh.'
	if ! mv -T -- "$TEMP_DIR" "$TPM_DIR"; then
		die 'Failed to install the cloned TPM directory.'
	fi
	TEMP_DIR=
fi

INSTALL_SCRIPT="$TPM_DIR/scripts/install_plugins.sh"
[[ -f $INSTALL_SCRIPT ]] || die "TPM is incomplete; missing $INSTALL_SCRIPT"
print_success 'TPM is available. Plugin installation runs after Stow.'
