# ⚡ Arch Linux Development Setup

![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793d1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Wayland](https://img.shields.io/badge/Protocol-Wayland-red?style=for-the-badge)

A modular, idempotent, and beautifully formatted shell script for bootstrapping a fresh Arch Linux installation into a fully configured development environment.

## 🚀 Quick Start

The fastest way to get up and running is using our single-line bootstrap command. This safely clones the repository into a temporary directory and launches the interactive installer.

```bash
curl -sL https://setup.look4abhinav.in | bash
```
> **Note:** Do not run this as root. The script will securely prompt for `sudo` privileges only when necessary.

---

## ✨ Features

- **Modular Architecture**: The main `setup.sh` orchestrates the installation, while individual scripts in the `tools/` directory handle specific domain logic.
- **Idempotent Execution**: Safe to run multiple times. It intelligently checks if packages, fonts, or repositories are already installed before taking action.
- **Dotfiles Management**: Automatically clones your dotfiles repository and safely symlinks them using GNU Stow.
- **AUR Support**: Builds and installs `paru` from source to handle Arch User Repository packages natively.
- **Beautiful Output**: Consistent, color-coded status messages and error reporting across all scripts using a modern TUI powered by `dialog`.

## 📦 What's Included

- **Core CLI Tools**: `neovim`, `tmux`, `git`, `zoxide`, `eza`, `fzf`, `ripgrep`, `bat`, `btop`, `yazi`
- **Wayland Ecosystem**: `hyprland`, `sddm`, `ghostty`, `waybar`, `fuzzel`, `mako`, `hyprlock`, `hypridle`, `hyprpaper`
- **Browsers**: `zen-browser-bin` (via AUR)
- **Development & Build Tools**: `base-devel`, `docker`, `docker-compose`
- **Formatting & Parsing**: `tree-sitter`, `stylua`, `taplo`, `yamlfmt`
- **Aesthetics**: Automatically downloads and installs the *JetBrainsMono Nerd Font*.

## 🛠️ Prerequisites

1. A fresh or existing Arch Linux installation.
2. A working internet connection.
3. A non-root user with `sudo` privileges.

## 📥 Manual Installation (Alternative)

If you prefer to review the scripts locally before running them, you can clone the repository manually:

```bash
git clone https://github.com/look4abhinav/archlinux.git ~/archlinux
cd ~/archlinux

# Do not run as root!
./setup.sh
```

### Post-Installation Steps
At the end of the script, follow the printed instructions to finalize your setup:
1. Reload your shell.
2. Activate the Docker group with `newgrp docker` to run containers without sudo.

## 📁 Repository Structure

```text
.
├── install.sh          # One-liner bootstrap script
├── setup.sh            # Main orchestration & interactive UI script
├── tools/              # Modular scripts for individual tools
│   ├── base-devel.sh   # Verifies build essentials
│   ├── bat.sh          # Verifies bat
│   ├── btop.sh         # Verifies btop
│   ├── docker.sh       # Enables service & adds user to docker group
│   ├── eza.sh          # Verifies eza
│   ├── fonts.sh        # Downloads/Installs JetBrainsMono Nerd Font
│   ├── fzf.sh          # Verifies fzf
│   ├── git.sh          # Applies global performance configs for git
│   ├── neovim.sh       # Verifies nvim & formatters
│   ├── paru.sh         # Builds and installs paru AUR helper
│   ├── ripgrep.sh      # Verifies rg
│   ├── stow.sh         # Clones dotfiles & symlinks with GNU Stow
│   ├── tmux.sh         # Verifies tmux
│   ├── uv.sh           # Verifies/configures uv (Python)
│   ├── wayland.sh      # Configures SDDM & Wayland defaults
│   ├── yazi.sh         # Verifies yazi file manager
│   ├── zen-browser.sh  # Installs zen-browser via AUR
│   └── zoxide.sh       # Verifies zoxide
└── README.md
```

## ⚙️ Customization

- **Packages**: Edit the `PACKAGES` associative array in `setup.sh` to seamlessly add or remove pacman packages.
- **Dotfiles**: The `stow.sh` script assumes you have a repository named `dotfiles` on GitHub. Update the repository URL in `tools/stow.sh` if your username or source control provider differs.
- **Tools**: Add new `.sh` scripts to the `tools/` directory and append their names to the `TOOL_ORDER` array in `setup.sh` to include them in the installer UI.

## ⚠️ Important Notes

- **Root execution**: Do not execute the initial scripts as `root`. Arch Linux's `makepkg` (used in `paru.sh`) will explicitly refuse to run if executed as the root user.