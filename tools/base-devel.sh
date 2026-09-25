#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root

BUILD_COMMANDS=(
	gcc
	make
	pkg-config
	bison
	flex
	m4
	fakeroot
	patch
)

print_section 'Base-devel verification'
require_commands "${BUILD_COMMANDS[@]}"
for tool in "${BUILD_COMMANDS[@]}"; do
	verify_command "$tool" --version
done
print_success 'Essential build commands verified.'
