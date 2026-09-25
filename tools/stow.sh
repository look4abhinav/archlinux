#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root
require_commands git stow mktemp mv rm

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_URL='https://github.com/look4abhinav/dotfiles.git'
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
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

if [[ ! -d $TPM_DIR ]]; then
	die "TPM is missing. Run tools/tmux.sh before stowing: $TPM_DIR"
fi

print_section 'Dotfiles repository'

if [[ -e $DOTFILES_DIR || -L $DOTFILES_DIR ]]; then
	[[ -d $DOTFILES_DIR ]] || die "The dotfiles path is not a directory: $DOTFILES_DIR"
	if ! repo_root=$(git -C "$DOTFILES_DIR" rev-parse --show-toplevel 2>/dev/null); then
		die "The dotfiles path is not a Git repository: $DOTFILES_DIR"
	fi
	[[ -n $repo_root ]] || die "Unable to determine the dotfiles repository root: $DOTFILES_DIR"
	repo_root=$(cd -- "$repo_root" && pwd -P)
	dotfiles_root=$(cd -- "$DOTFILES_DIR" && pwd -P)
	[[ "$repo_root" == "$dotfiles_root" ]] ||
		die "The dotfiles path is not the repository root: $DOTFILES_DIR"
	if ! origin=$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null); then
		die "The dotfiles repository has no readable origin: $DOTFILES_DIR"
	fi
	case "$origin" in
		"$DOTFILES_URL" | 'git@github.com:look4abhinav/dotfiles.git') ;;
		*) die "Unexpected dotfiles origin: $origin. Expected: $DOTFILES_URL" ;;
	esac
	print_status "Updating $DOTFILES_DIR"
	if ! (
		cd -- "$DOTFILES_DIR"
		git pull --ff-only
	); then
		die 'Failed to update the dotfiles repository with a fast-forward pull.'
	fi
else
	TEMP_DIR=$(mktemp -d "${DOTFILES_DIR}.tmp.XXXXXX")
	print_status "Cloning dotfiles into $TEMP_DIR"
	if ! git clone "$DOTFILES_URL" "$TEMP_DIR"; then
		die 'Failed to clone the dotfiles repository.'
	fi
	if ! mv -T -- "$TEMP_DIR" "$DOTFILES_DIR"; then
		die 'Failed to install the cloned dotfiles repository.'
	fi
	TEMP_DIR=
fi

print_section 'Stowing dotfiles'
if ! stow \
	--dir="$DOTFILES_DIR" \
	--target="$HOME" \
	--ignore='(^|/)\.git(/|$)' \
	--ignore='(^|/)\.github(/|$)' \
	--ignore='(^|/)\.gitignore$' \
	--ignore='(^|/)AGENTS\.md$' \
	--ignore='(^|/)\.ruff_cache(/|$)' \
	--ignore='(^|/)__pycache__(/|$)' \
	--ignore='\.py[co]$' \
	--ignore='\.cache$' \
	--ignore='\.sw[op]$' \
	--ignore='~$' \
	--ignore='(^|/)\.DS_Store$' \
	.; then
	print_error "Stow failed. Existing files in $HOME may conflict with the dotfiles package."
	print_warning 'Inspect the reported paths, then remove or rename the conflicting files and rerun.'
	print_status 'Stow will not replace existing files automatically.'
	exit 1
fi
print_success 'Dotfiles stowed successfully.'
