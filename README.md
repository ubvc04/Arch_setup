# Arch Setup

A reusable Arch Linux personal bootstrap repository for installing a base system, desktop environment, drivers, developer tooling, and daily utilities.

This repository is intentionally simple: it uses official Arch packages whenever possible, keeps scripts readable, and prefers safe, idempotent operations over destructive automation.

## Why this repository exists

The goal is to keep a single, version-controlled setup for the machines I use most often. Instead of manually redoing the same installation steps after every fresh Arch install, I can clone this repository and run a guided installer to set up:

- base packages and shell tools
- desktop environment
- graphics and hardware drivers
- Git and SSH configuration
- programming languages and tooling
- Docker and system services
- security-conscious backup and cleanup helpers

## Repository structure

The project follows a practical layout with a small shared library for common helper functions. The structure is intended to be easy to extend later for Hyprland, Sway, Neovim, or other dotfiles.

```text
.
├── README.md
├── LICENSE
├── .gitignore
├── install.sh
├── update.sh
├── lib/
│   └── common.sh
├── packages/
│   ├── base.txt
│   ├── development.txt
│   ├── terminal.txt
│   ├── desktop-xfce.txt
│   ├── desktop-kde.txt
│   ├── desktop-gnome.txt
│   └── applications.txt
├── desktop/
│   ├── xfce.sh
│   ├── kde.sh
│   ├── gnome.sh
│   └── sddm.sh
├── drivers/
│   ├── common.sh
│   ├── detect.sh
│   ├── intel.sh
│   ├── amd.sh
│   └── nvidia.sh
├── development/
│   ├── git.sh
│   ├── ssh.sh
│   ├── node.sh
│   ├── python.sh
│   ├── java.sh
│   └── docker.sh
├── terminal/
│   ├── bash.sh
│   ├── zsh.sh
│   └── aliases.sh
├── system/
│   ├── services.sh
│   ├── bluetooth.sh
│   ├── audio.sh
│   └── networking.sh
├── applications/
│   ├── browser.sh
│   ├── vscode.sh
│   └── utilities.sh
├── scripts/
│   ├── update.sh
│   ├── cleanup.sh
│   ├── backup.sh
│   └── system-info.sh
├── config/
│   ├── bashrc
│   ├── gitconfig.example
│   └── README.md
└── docs/
    └── future-work.md
```

The only intentional organization change from the original list is the shared `lib/common.sh` helper file. It keeps the scripts shorter, consistent, and easier to maintain without duplicating the same logging and safety logic across every script.

## Requirements

These are the typical requirements for a clean Arch installation:

- Arch Linux installed and booted
- internet access
- root access or sudo configured
- a user account with a working shell
- optional: a supported graphics card and Wi-Fi/Bluetooth hardware

## Fresh Arch installation

This is the basic flow for a fresh machine:

```bash
# Boot into Arch Linux
# Create a user if needed
passwd
useradd -m -G wheel -s /bin/bash youruser
visudo

# Login as the new user
su - youruser
```

Then install Git and clone this repository:

```bash
sudo pacman -S --needed git openssh base-devel
git clone git@github.com:USERNAME/arch-setup.git ~/arch-setup
cd ~/arch-setup
./install.sh
```

## SSH and GitHub setup

If you want to clone over SSH, generate an SSH key first and add it to GitHub:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh -T git@github.com
```

Then create a remote repository on GitHub and connect it:

```bash
git init
git remote add origin git@github.com:USERNAME/arch-setup.git
git add .
git commit -m "Initial Arch setup repository"
git push -u origin main
```

If the repository already exists:

```bash
git clone git@github.com:USERNAME/arch-setup.git
cd arch-setup
git status
git add .
git commit -m "Update Arch setup"
git push
git pull
```

## Installation

Run the main installer:

```bash
cd ~/arch-setup
./install.sh
```

The installer is interactive and asks for:

- desktop environment choice
- optional components to install
- whether to install drivers
- Git and SSH setup
- Docker and other tools

The script will explain the actions before doing anything destructive.

## Update script

To update the Arch packages on the machine:

```bash
cd ~/arch-setup
./update.sh
```

The root-level `update.sh` script delegates to the `scripts/update.sh` helper and will optionally update the repository itself if configured.

## Desktop selection

The install script supports:

- XFCE (recommended minimal option)
- KDE Plasma
- GNOME
- Skip desktop install

If you prefer a non-desktop setup, you can skip that part and still use the rest of the repository.

## Driver setup

Driver helpers detect hardware before making assumptions. The scripts check:

- GPU vendor
- CPU vendor
- Wi-Fi and Bluetooth hardware
- system architecture

They prefer official, supported packages and avoid blindly installing NVIDIA, Intel, and AMD stacks at the same time.

## Development environment

The repository can install:

- Git configuration
- SSH key generation and agent setup
- Node.js and npm
- Python and virtual environments
- Java
- Docker

It intentionally does not force all options by default.

## Security

This repository does not store secrets in Git. It ignores common sensitive paths and filenames such as:

- `.env`
- `.key`, `.pem`, `.crt`
- `id_rsa`, `id_ed25519`
- credentials and tokens
- node_modules
- Python virtual environments
- build artifacts

Keep SSH private keys local. Only store safe, non-sensitive configuration in Git.

## Backups

The backup helper copies safe files such as:

- `~/.bashrc`
- `~/.gitconfig`
- `~/.ssh/config`

It does not copy private keys into Git or remote storage without explicit user consent.

## Troubleshooting

Common fixes:

```bash
# Check whether pacman can reach the network
ping -c 3 archlinux.org

# Check the mirror list
pacman -Syyu

# Check the active services
systemctl status

# Check whether a desktop is installed
ls /usr/share/xsessions

# Check the current shell
echo $SHELL
```

## How to remove or change a desktop environment

This is usually done by removing the desktop packages and optionally switching the display manager.

```bash
sudo pacman -Rns xfce4 xfce4-goodies
sudo pacman -Rns plasma-meta kdebase kdegraphics
sudo pacman -Rns gnome gnome-shell
```

Before removing anything, review what is installed and confirm the replacement environment.

## Extending the repository

This repository is designed to grow. You can later add modules for:

- Hyprland
- Sway
- i3
- LXQt
- Neovim
- VS Code settings
- Rust, Go, Java Spring, Flutter, Kubernetes, Terraform
- local AI tooling

The scripts are intentionally structured so new modules can be added without touching the whole system blindly.

## License

This project is released under the MIT License. See [LICENSE](./LICENSE) for details.
