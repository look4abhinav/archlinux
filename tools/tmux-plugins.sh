#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_commands bash tmux

TPM_DIR="$HOME/.config/tmux/plugins/tpm"
INSTALL_SCRIPT="$TPM_DIR/scripts/install_plugins.sh"
CONFIG_FILE="$HOME/.config/tmux/tmux.conf"

[[ -d $TPM_DIR ]] || die "TPM is missing: $TPM_DIR"
[[ -f $INSTALL_SCRIPT ]] || die "TPM is incomplete: $INSTALL_SCRIPT"
[[ -f $CONFIG_FILE ]] || die "Stowed tmux configuration is missing: $CONFIG_FILE"

print_section 'TPM plugin installation'
if ! bash "$INSTALL_SCRIPT"; then
	die 'TPM plugin installation failed.'
fi
print_success 'TPM plugins installed.'
