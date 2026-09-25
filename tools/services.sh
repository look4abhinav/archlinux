#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_command systemctl
require_command sudo
require_command id

TARGET_USER=$(id -un)

print_status "Configuring services for $TARGET_USER"

run_systemctl() {
	local description=$1
	shift
	print_status "$description"
	if "$@"; then
		return 0
	fi
	print_error "$description failed"
	return 1
}

case "${SETUP_PROFILE:-}" in
	pc)
		run_systemctl 'Enabling and starting NetworkManager' \
			sudo systemctl enable --now NetworkManager.service
		run_systemctl 'Enabling and starting Bluetooth' \
			sudo systemctl enable --now bluetooth.service
		run_systemctl 'Enabling and starting the user SSH agent socket' \
			systemctl --user enable --now ssh-agent.socket
		;;
	server)
		run_systemctl 'Enabling and starting sshd' \
			sudo systemctl enable --now sshd.service
		;;
	*)
		die 'SETUP_PROFILE must be pc or server.'
		;;
esac

print_success "Services configured for $TARGET_USER"
