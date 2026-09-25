#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_commands nvim tree-sitter stylua taplo yamlfmt shfmt shellcheck ty ruff

print_section 'Neovim verification'
for tool in nvim tree-sitter stylua taplo yamlfmt shfmt shellcheck ty ruff; do
	verify_command "$tool" --version
done

INIT_FILE="$HOME/.config/nvim/init.lua"
if [[ -e $INIT_FILE || -L $INIT_FILE ]]; then
	[[ -f $INIT_FILE ]] || die "The stowed Neovim configuration is not a file: $INIT_FILE"
	print_status 'Running the headless Neovim configuration smoke test'
	smoke_command="lua if vim.v.errmsg ~= '' then io.stderr:write(vim.v.errmsg) vim.cmd('cquit 1') end"
	if ! nvim --headless -u "$INIT_FILE" -i NONE "+$smoke_command" '+qa!'; then
		die 'The stowed Neovim configuration failed its headless smoke test.'
	fi
	print_success 'Neovim configuration smoke test passed.'
else
	print_success 'No stowed init.lua found; smoke test skipped.'
fi
print_success 'Neovim verification complete.'
