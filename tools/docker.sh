#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_commands docker docker-compose sudo systemctl usermod id

TARGET_USER=$(id -un)

print_section 'Docker setup'
verify_command docker --version
verify_command docker-compose version

print_status 'Enabling and starting docker.service'
if ! sudo systemctl enable --now docker.service; then
	die 'Failed to enable and start docker.service.'
fi
if ! systemctl is-enabled --quiet docker.service; then
	die 'docker.service is not enabled.'
fi
if ! systemctl is-active --quiet docker.service; then
	die 'docker.service is not active.'
fi

if ! groups=$(id -nG "$TARGET_USER"); then
	die "Unable to read groups for $TARGET_USER."
fi
if [[ " $groups " != *" docker "* ]]; then
	print_status "Adding $TARGET_USER to the docker group"
	if ! sudo usermod -aG docker "$TARGET_USER"; then
		die "Failed to add $TARGET_USER to the docker group."
	fi
	if ! groups=$(id -nG "$TARGET_USER"); then
		die "Unable to verify groups for $TARGET_USER."
	fi
	[[ " $groups " == *" docker "* ]] ||
		die "$TARGET_USER is not a member of the docker group after configuration."
else
	print_success "$TARGET_USER is already a member of the docker group."
fi

print_success 'Docker setup complete.'
print_warning 'Docker group changes require a new login.'
print_status 'For the current shell, run: newgrp docker'
