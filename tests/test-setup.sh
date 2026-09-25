#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_commands bash chmod cp mkdir mktemp rm

if ! command -v script >/dev/null 2>&1; then
	print_warning 'script not found; orchestration tests skipped'
	exit 0
fi

TEST_ROOT=$(mktemp -d)
cleanup() {
	rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

TOOLS=(
	base-devel
	paru
	tmux
	stow
	tmux-plugins
	zsh
	git
	neovim
	wayland
	services
	fonts
	uv
	docker
	zen-browser
	tree-sitter-cli
	zoxide
	eza
	fzf
	ripgrep
	bat
	fd
	btop
	yazi
)

make_case() {
	local name=$1
	local failing_tool=$2
	local case_dir="$TEST_ROOT/$name"
	local tool

	mkdir -p "$case_dir/lib" "$case_dir/tools" "$case_dir/bin"
	cp "$REPO_DIR/setup.sh" "$case_dir/setup.sh"
	cp "$REPO_DIR/lib/common.sh" "$case_dir/lib/common.sh"

	for tool in "${TOOLS[@]}"; do
		if [[ $tool == "$failing_tool" ]]; then
			cat >"$case_dir/tools/$tool.sh" <<'EOF'
#!/usr/bin/env bash
name=${0##*/}
printf '%s\n' "${name%.sh}" >>"${TOOL_LOG:?}"
exit 42
EOF
		else
			cat >"$case_dir/tools/$tool.sh" <<'EOF'
#!/usr/bin/env bash
name=${0##*/}
printf '%s\n' "${name%.sh}" >>"${TOOL_LOG:?}"
exit 0
EOF
		fi
		chmod 700 "$case_dir/tools/$tool.sh"
	done

	printf '#!/usr/bin/env bash\nexec "$@"\n' >"$case_dir/bin/sudo"
	printf '#!/usr/bin/env bash\nexit 0\n' >"$case_dir/bin/pacman"
	cat >"$case_dir/bin/dialog" <<'EOF'
#!/usr/bin/env bash
if [[ ${DIALOG_CANCEL:-0} == 1 ]]; then
	exit 1
fi
for argument in "$@"; do
	if [[ $argument == --menu ]]; then
		printf 'server\n' >&2
		break
	fi
done
exit 0
EOF
	chmod 700 "$case_dir/bin/sudo" "$case_dir/bin/pacman" "$case_dir/bin/dialog"
	printf '%s' "$case_dir"
}

assert_contains() {
	local output=$1
	local expected=$2
	[[ $output == *"$expected"* ]] || die "Expected output not found: $expected"
}

assert_not_contains() {
	local output=$1
	local unexpected=$2
	[[ $output != *"$unexpected"* ]] || die "Unexpected output found: $unexpected"
}

run_case() {
	local cancel=$1
	local case_dir=$2
	local tool_log=$3
	local output status

	set +e
	output=$(NO_COLOR=1 DIALOG_CANCEL="$cancel" TOOL_LOG="$tool_log" PATH="$case_dir/bin:$PATH" \
		script -qefc "bash '$case_dir/setup.sh'" /dev/null 2>&1)
	status=$?
	set -e
	printf '%s' "$output"
	return "$status"
}

print_section 'Version probe failure path'
BROKEN_BIN="$TEST_ROOT/broken-bin"
mkdir -p "$BROKEN_BIN"
printf '#!/usr/bin/env bash\nexit 42\n' >"$BROKEN_BIN/broken-command"
chmod 700 "$BROKEN_BIN/broken-command"
set +e
PATH="$BROKEN_BIN:$PATH" verify_command broken-command --version >/dev/null 2>&1
probe_status=$?
set -e
((probe_status != 0)) || die 'A failed version probe incorrectly succeeded'

print_section 'Piped bootstrap guard'
set +e
output=$(NO_COLOR=1 bash "$REPO_DIR/install.sh" </dev/null 2>&1)
bootstrap_status=$?
set -e
((bootstrap_status != 0)) || die 'Non-interactive piped bootstrap incorrectly succeeded'
assert_contains "$output" 'An interactive terminal is required.'
assert_not_contains "$output" 'BASH_SOURCE'

print_section 'Orchestrator success path'
case_dir=$(make_case success '')
tool_log="$TEST_ROOT/success-order"
set +e
output=$(run_case 0 "$case_dir" "$tool_log")
status=$?
set -e
((status == 0)) || die "Successful setup simulation failed with status $status"
assert_contains "$output" 'Setup completed in'
expected_order=(
	base-devel tmux stow tmux-plugins zsh git neovim services uv docker
	tree-sitter-cli zoxide eza fzf ripgrep bat fd btop yazi
)
mapfile -t actual_order <"$tool_log"
[[ ${actual_order[*]} == "${expected_order[*]}" ]] ||
	die "Tool order mismatch: ${actual_order[*]}"

print_section 'Orchestrator tool failure path'
case_dir=$(make_case tool-failure neovim)
set +e
output=$(run_case 0 "$case_dir" "$TEST_ROOT/failure-order")
status=$?
set -e
((status != 0)) || die 'Tool failure simulation incorrectly succeeded'
assert_contains "$output" 'neovim failed with status 42'
assert_contains "$output" 'Setup failed: 1 tool script(s) failed.'
assert_not_contains "$output" 'Setup completed in'

print_section 'Orchestrator cancellation path'
case_dir=$(make_case cancellation '')
set +e
output=$(run_case 1 "$case_dir" "$TEST_ROOT/cancel-order")
status=$?
set -e
((status != 0)) || die 'Cancellation simulation incorrectly succeeded'
assert_contains "$output" 'Setup cancelled by user.'
assert_not_contains "$output" 'Setup completed in'

print_section 'Orchestrator TTY guard'
case_dir=$(make_case no-tty '')
set +e
output=$(NO_COLOR=1 PATH="$case_dir/bin:$PATH" bash "$case_dir/setup.sh" 2>&1)
status=$?
set -e
((status != 0)) || die 'Non-interactive setup simulation incorrectly succeeded'
assert_contains "$output" 'An interactive terminal is required.'

print_success 'Orchestration tests passed.'
