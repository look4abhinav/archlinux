#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_packages uv ruff ty
require_commands uv uvx ty ruff

print_section 'uv verification'
verify_command uv --version
verify_command uvx --version
verify_command ty --version
verify_command ruff --version
print_success 'uv tooling verified.'
