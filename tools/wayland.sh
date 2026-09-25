#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"

require_non_root

require_commands pacman paru systemctl install sudo cp mktemp rm date cmp test weston
require_packages sddm weston
[[ -d /usr/share/sddm/themes/maldives ]] || die 'The bundled SDDM theme is missing: /usr/share/sddm/themes/maldives'

COMPETING_DISPLAY_MANAGERS=(
	gdm.service
	lightdm.service
	xdm.service
	ly.service
	greetd.service
	lxdm.service
	nodem.service
)

for service in "${COMPETING_DISPLAY_MANAGERS[@]}"; do
	if systemctl is-enabled --quiet "$service" 2>/dev/null; then
		die "A competing display manager is already enabled: $service. Disable it with 'sudo systemctl disable --now $service' after logging out of graphical sessions, then rerun this script."
	fi
done

print_section 'Wayland and SDDM setup'

print_status 'Installing Wayland desktop packages'
if ! paru -S --needed --noconfirm waypaper wlogout bibata-cursor-theme; then
	die 'Failed to install the required AUR packages.'
fi

CONFIG_FILE=/etc/sddm.conf
CONFIG_CONTENT=$'[Theme]\nCurrent=maldives\n\n[General]\nDisplayServer=wayland\nGreeterEnvironment=QT_WAYLAND_DISABLE_WINDOWDECORATION=1\n\n[Wayland]\nSessionDir=/usr/share/wayland-sessions\nCompositorCommand=weston --shell=kiosk\n'
CONFIG_TMP=$(mktemp)
cleanup_config() {
	rm -f -- "$CONFIG_TMP"
}
trap cleanup_config EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

print_status 'Configuring SDDM'
if ! printf '%s' "$CONFIG_CONTENT" >"$CONFIG_TMP"; then
	die 'Failed to stage the SDDM configuration.'
fi
if sudo test -e "$CONFIG_FILE" || sudo test -L "$CONFIG_FILE"; then
	if sudo cmp -s -- "$CONFIG_TMP" "$CONFIG_FILE"; then
		print_success 'SDDM configuration is already current.'
	else
		BACKUP_FILE="$CONFIG_FILE.$(date -u +%Y%m%dT%H%M%SZ).bak"
		if sudo test -e "$BACKUP_FILE" || sudo test -L "$BACKUP_FILE"; then
			die "Refusing to overwrite an existing backup: $BACKUP_FILE"
		fi
		if ! sudo cp -a -- "$CONFIG_FILE" "$BACKUP_FILE"; then
			die "Failed to preserve the existing SDDM configuration at $BACKUP_FILE."
		fi
		if ! sudo install -o root -g root -m 0644 -- "$CONFIG_TMP" "$CONFIG_FILE"; then
			die "Failed to write $CONFIG_FILE."
		fi
		print_success "Preserved the previous configuration at $BACKUP_FILE"
	fi
else
	if ! sudo install -o root -g root -m 0644 -- "$CONFIG_TMP" "$CONFIG_FILE"; then
		die "Failed to write $CONFIG_FILE."
	fi
fi

if ! sudo cmp -s -- "$CONFIG_TMP" "$CONFIG_FILE"; then
	die "SDDM configuration verification failed: $CONFIG_FILE"
fi

print_status 'Enabling SDDM and the graphical target'
if ! sudo systemctl enable sddm.service graphical.target; then
	die 'Failed to enable sddm.service and graphical.target.'
fi
if ! systemctl is-enabled --quiet sddm.service; then
	die 'sddm.service is not enabled after configuration.'
fi
if ! systemctl is-enabled --quiet graphical.target; then
	die 'graphical.target is not enabled after configuration.'
fi

print_success 'Wayland and SDDM setup complete.'
