#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_command bash
require_command find

shell_scripts=()
while IFS= read -r -d '' script; do
	shell_scripts+=("$script")
done < <(find "$REPO_DIR" -path "$REPO_DIR/.git" -prune -o -type f -name '*.sh' -print0)

status=0
print_section 'Bash syntax'
for script in "${shell_scripts[@]}"; do
	if bash -n "$script"; then
		print_status "bash -n: $script"
	else
		print_error "bash -n failed: $script"
		status=1
	fi
done

print_section 'ShellCheck'
if command -v shellcheck >/dev/null 2>&1; then
	if shellcheck "${shell_scripts[@]}"; then
		print_success 'ShellCheck passed'
	else
		print_error 'ShellCheck failed'
		status=1
	fi
else
	print_warning 'ShellCheck not found; skipped'
fi

print_section 'shfmt'
if command -v shfmt >/dev/null 2>&1; then
	if shfmt -d -i 0 -ci "${shell_scripts[@]}"; then
		print_success 'shfmt check passed'
	else
		print_error 'shfmt check failed'
		status=1
	fi
else
	print_warning 'shfmt not found; skipped'
fi

print_section 'Orchestration tests'
if bash "$REPO_DIR/tests/test-setup.sh"; then
	print_success 'Orchestration tests passed'
else
	print_error 'Orchestration tests failed'
	status=1
fi

if ((status == 0)); then
	print_success 'Validation passed'
else
	print_error 'Validation failed'
fi

exit "$status"
