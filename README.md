# Arch Linux Development Setup

A modular bootstrap for Arch Linux that installs a complete development environment and deploys the single-package dotfiles repository with GNU Stow.

The installer supports two profiles:

- `pc`: Hyprland, SDDM, Wayland desktop, AUR desktop tools, fonts, and the full development stack.
- `server`: Headless development tools, Docker, OpenSSH server, and the same stowed shell and editor configuration.

## Requirements

- A fresh or existing Arch Linux installation.
- An interactive terminal.
- A non-root user with working `sudo` access.
- Working internet access.

Do not run the installer as root.

## Quick Start

```bash
curl -sL https://look4abhinav.in/archlinux | bash
```

The bootstrap performs a full system upgrade when Git is missing, clones the current default branch into a temporary directory, runs `setup.sh`, and removes the temporary clone.

For a local checkout:

```bash
git clone https://github.com/look4abhinav/archlinux.git ~/archlinux
cd ~/archlinux
./setup.sh
```

The first setup step refreshes pacman databases and installs `dialog`. It then asks for a profile and confirmation before installing the selected packages.

## Profiles

### PC

The PC profile installs:

- Hyprland, SDDM with the bundled Maldives theme and Weston compositor, Waypaper, Hyprpaper, Waybar, Mako, Fuzzel, Hyprlock, and Hypridle.
- NetworkManager, Bluetooth, PipeWire Pulse, WirePlumber, Polkit, and the user SSH agent.
- Ghostty, Waybar, Thunar, Zed, Visual Studio Code, Signal Desktop, Zen Browser, and wlogout.
- Clipboard, screenshot, thumbnail, OSD, and dock tooling used by the dotfiles.
- JetBrainsMono Nerd Font, Inter, and the Bibata Modern Ice cursor theme.
- Zsh, Git, GitHub CLI, Neovim, tmux, TPM, the latest stable Blink release, Ty, Ruff, uv, and all configured formatter and linter tooling.
- Docker, Docker Compose, and the complete CLI utility set.

### Server

The server profile omits GUI packages and installs:

- Zsh, Git, GitHub CLI, OpenSSH, and the complete CLI development stack.
- Neovim, tmux, TPM, Ty, Ruff, uv, and all configured formatter and linter tooling.
- Docker and Docker Compose with daemon access for the target user.
- The same single-package dotfiles tree through GNU Stow.

## Execution Order

Tool order is dependency-aware:

1. Verify `base-devel`.
2. Build Paru when needed.
3. Clone TPM before Stow so its state remains outside the dotfiles repository.
4. Clone or fast-forward the dotfiles repository and run Stow.
5. Install TPM plugins using the stowed `tmux.conf`.
6. Configure the Zsh login shell.
7. Verify the stowed Git configuration.
8. Smoke-test the stowed Neovim configuration.
9. Configure SDDM, Weston, and desktop packages.
10. Enable profile-specific services and fonts.
11. Verify Docker and the remaining development tools.

A failed tool is reported with its status, the final summary lists every failure, and `setup.sh` exits nonzero if any tool failed.

## Dotfiles Deployment

`tools/stow.sh` keeps the single all-tools package requested for this setup. It:

- Verifies an existing `~/dotfiles` checkout and its expected origin.
- Uses `git pull --ff-only` and never rebases local work.
- Clones into a temporary directory before moving a new checkout into place.
- Refuses to adopt or overwrite conflicting home files automatically.
- Ignores Git metadata, `AGENTS.md`, Python caches, and editor artifacts.

The tracked `.gitconfig` is deployed by Stow. `tools/git.sh` only verifies it and never creates or overwrites the file.

## Desktop Services

The PC profile enables:

- `NetworkManager.service`
- `bluetooth.service`
- `ssh-agent.socket` for the target user

The server profile enables `sshd.service`.

The installer enables SDDM and the graphical target for the PC profile but does not start a display manager during setup. Reboot after completing installation.

## AUR Packages

Paru builds the following packages when they are missing:

- `paru`
- `zen-browser-bin`
- `waypaper`
- `wlogout`
- `bibata-cursor-theme`

AUR PKGBUILDs and default-branch clones are mutable by design. The installer uses temporary build directories, validates results, and propagates failures.

## Docker

The installer enables and starts `docker.service`, then adds the target user to the `docker` group.

Membership in the `docker` group is effectively root-equivalent. Log out and back in, or run `newgrp docker`, before using Docker without `sudo`.

## GitHub Authentication

The stowed Git configuration uses GitHub CLI as its credential helper. Run once after installation:

```bash
gh auth login
```

## Validation

Run the repository checks without changing the system:

```bash
bash tests/validate.sh
```

Validation includes:

- Bash syntax checks for every script.
- ShellCheck when available.
- shfmt formatting checks when available.
- Pseudo-terminal orchestration tests covering success, tool failure, cancellation, and the non-TTY guard.

Set `NO_COLOR=1` for plain output.

## Post-Installation

1. Run `gh auth login` if GitHub access is needed.
2. Start a new login session so the Zsh shell and Docker group take effect.
3. Run `exec $SHELL` when only reloading the current shell.
4. Run `newgrp docker` if Docker access is needed immediately.
5. Reboot the PC profile to start SDDM.

## Repository Structure

```text
.
├── install.sh
├── setup.sh
├── lib
│   └── common.sh
├── tests
│   ├── test-setup.sh
│   └── validate.sh
└── tools
    ├── base-devel.sh
    ├── stow.sh
    ├── tmux.sh
    ├── tmux-plugins.sh
    ├── zsh.sh
    ├── git.sh
    ├── neovim.sh
    ├── wayland.sh
    ├── services.sh
    ├── fonts.sh
    ├── uv.sh
    ├── docker.sh
    └── ...
```

## Customization

- Add or remove pacman packages in `PC_PACKAGES` or `SERVER_PACKAGES` in `setup.sh`.
- Add or reorder tools in `PC_TOOLS` or `SERVER_TOOLS` and register them in `KNOWN_TOOLS`.
- Keep tool names lowercase and restricted to letters, numbers, and hyphens.
- Source `lib/common.sh` in new tool scripts and reuse its output and validation helpers.
- Run `bash tests/validate.sh` before committing.
