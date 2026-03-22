# Arch Linux Development Setup

A modular, idempotent, and beautifully formatted shell script for bootstrapping a fresh Arch Linux installation into a fully configured development environment.

## 🚀 Features

- **Modular Architecture**: The main `setup.sh` orchestrates the installation, while individual scripts in the `tools/` directory handle specific tools.
- **Idempotent Execution**: Safe to run multiple times. It checks if packages, fonts, or repositories are already installed before taking action.
- **Dotfiles Management**: Automatically clones your dotfiles repository and symlinks them using GNU Stow.
- **AUR Support**: Builds and installs `paru` from source to handle Arch User Repository packages.
- **Beautiful Output**: Consistent, color-coded status messages and error reporting across all scripts.

## 📦 What's Included

- **Core CLI Tools**: `neovim`, `tmux`, `git`, `zoxide`, `eza`, `fzf`, `ripgrep`, `bat`, `btop`, `yazi`
- **Wayland Ecosystem**: `hyprland`, `sddm`, `ghostty`, `waybar`, `fuzzel`, `mako`, `hyprlock`, `hypridle`, `hyprpaper`
- **Browsers**: `zen-browser-bin` (AUR)
- **Development & Build Tools**: `base-devel`, `docker`, `docker-compose`
- **Formatting & Parsing**: `tree-sitter`, `stylua`, `taplo`, `yamlfmt`
- **Aesthetics**: Automatically downloads and installs the JetBrainsMono Nerd Font.

## 🛠️ Prerequisites

1. A fresh or existing Arch Linux installation.
2. A working internet connection.
3. A non-root user with `sudo` privileges.

## 📥 Installation & Usage

1. **Clone the repository**:
   ```bash
   git clone https://github.com/look4abhinav/archlinux.git ~/archlinux
   cd ~/archlinux
   ```

2. **Run the setup script**:
   ```bash
   # Do not run as root! The script will prompt for sudo when necessary.
   ./setup.sh
   ```

3. **Follow the post-installation steps**:
   At the end of the script, follow the printed instructions (e.g., reloading your shell, activating the Docker group with `newgrp docker`).

## 📁 Repository Structure

```text
.
├── setup.sh            # Main orchestration script
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
└── .gitignore
```

## ⚙️ Customization

- **Packages**: Edit the `PACKAGES` associative array in `setup.sh` to add or remove pacman packages.
- **Dotfiles**: The `stow.sh` script assumes you have a repository named `dotfiles` on GitHub. Update the repository URL in `tools/stow.sh` if yours differs.
- **Tools**: Add new `.sh` scripts to the `tools/` directory and append their names to the `TOOL_SCRIPTS` array in `setup.sh`.

## ⚠️ Important Notes

- **GitHub CLI (`gh`)**: The `stow.sh` script attempts to clone your dotfiles using `gh repo clone dotfiles`. Ensure you are authenticated (`gh auth login`) before running, or modify the script to use standard `git clone` with an HTTPS/SSH URL.
- **Root execution**: Do not execute the scripts as `root`. `makepkg` (used in `paru.sh`) will explicitly fail if run as root.
