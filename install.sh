#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

install_base_packages() {
  log_info "Installing base package set"
  local packages=()
  while IFS= read -r pkg; do
    [[ -n "$pkg" && "$pkg" != \#* ]] && packages+=("$pkg")
  done <"$SCRIPT_DIR/packages/base.txt"
  pacman_install "${packages[@]}"
}

install_desktop_xfce() {
  log_info "Installing XFCE"
  bash "$SCRIPT_DIR/desktop/xfce.sh"
}

install_desktop_kde() {
  log_info "Installing KDE Plasma"
  bash "$SCRIPT_DIR/desktop/kde.sh"
}

install_desktop_gnome() {
  log_info "Installing GNOME"
  bash "$SCRIPT_DIR/desktop/gnome.sh"
}

install_drivers() {
  log_info "Running driver detection"
  bash "$SCRIPT_DIR/drivers/detect.sh"
}

setup_git() {
  bash "$SCRIPT_DIR/development/git.sh"
}

setup_ssh() {
  bash "$SCRIPT_DIR/development/ssh.sh"
}

setup_dev_tools() {
  bash "$SCRIPT_DIR/development/node.sh"
  bash "$SCRIPT_DIR/development/python.sh"
  bash "$SCRIPT_DIR/development/java.sh"
  bash "$SCRIPT_DIR/development/docker.sh"
}

show_summary() {
  printf '\n\n=== INSTALL SUMMARY ===\n'
  printf 'Completed targeted setup steps. Inspect the scripts in the repo for any additional optional configuration.\n'
  printf 'Useful next steps:\n'
  printf '  - reboot\n'
  printf '  - systemctl status bluetooth\n'
  printf '  - systemctl status NetworkManager\n'
  printf '  - ls /usr/share/xsessions\n'
  printf '  - git config --global --list\n'
  printf '======================\n\n'
}

main_menu() {
  local choice

  while true; do
    print_banner "MY ARCH LINUX SETUP"
    cat <<'EOF'
1. Install base packages
2. Install XFCE
3. Install KDE
4. Install GNOME
5. Detect hardware
6. Install drivers
7. Setup Git
8. Setup SSH
9. Setup Development Environment
10. Setup Docker
11. Setup Bluetooth
12. Setup Audio
13. Update System
14. Cleanup
15. System Information
0. Exit
EOF

    printf 'Select an option: '
    read -r choice || exit 0

    case "$choice" in
      1) install_base_packages ;;
      2) install_desktop_xfce ;;
      3) install_desktop_kde ;;
      4) install_desktop_gnome ;;
      5) bash "$SCRIPT_DIR/drivers/detect.sh" ;;
      6) install_drivers ;;
      7) setup_git ;;
      8) setup_ssh ;;
      9) setup_dev_tools ;;
      10) bash "$SCRIPT_DIR/development/docker.sh" ;;
      11) bash "$SCRIPT_DIR/system/bluetooth.sh" ;;
      12) bash "$SCRIPT_DIR/system/audio.sh" ;;
      13) bash "$SCRIPT_DIR/scripts/update.sh" ;;
      14) bash "$SCRIPT_DIR/scripts/cleanup.sh" ;;
      15) bash "$SCRIPT_DIR/scripts/system-info.sh" ;;
      0) log_info "Exiting installer."; exit 0 ;;
      *) log_warn "Invalid choice. Try again." ;;
    esac

    printf '\nPress Enter to continue...\n'
    read -r _ || true
  done
}

main() {
  check_arch

  if ! ensure_root_or_sudo; then
    log_warn "Re-run this script with sudo or as root."
    exit 1
  fi

  ensure_internet
  log_info "Synchronizing package databases"
  pacman -Syy

  log_info "Updating the system"
  pacman -Syu --noconfirm

  install_base_packages

  print_banner "Desktop Environment"
  printf 'Choose a desktop environment:\n'
  printf '  1) XFCE (recommended minimal option)\n'
  printf '  2) KDE Plasma\n'
  printf '  3) GNOME\n'
  printf '  4) Skip desktop installation\n'
  printf 'Selection: '
  read -r desktop_choice || desktop_choice="4"

  case "$desktop_choice" in
    1) install_desktop_xfce ;;
    2) install_desktop_kde ;;
    3) install_desktop_gnome ;;
    4) log_info "Skipping desktop installation." ;;
    *) log_warn "Unknown choice; skipping desktop installation." ;;
  esac

  printf '\nSelect optional components to install (y/N):\n'
  if confirm "Install drivers"; then install_drivers; fi
  if confirm "Set up Git"; then setup_git; fi
  if confirm "Set up SSH"; then setup_ssh; fi
  if confirm "Install Node.js and npm"; then bash "$SCRIPT_DIR/development/node.sh"; fi
  if confirm "Install Python and tooling"; then bash "$SCRIPT_DIR/development/python.sh"; fi
  if confirm "Install Java"; then bash "$SCRIPT_DIR/development/java.sh"; fi
  if confirm "Install Docker"; then bash "$SCRIPT_DIR/development/docker.sh"; fi
  if confirm "Install VS Code"; then bash "$SCRIPT_DIR/applications/vscode.sh"; fi
  if confirm "Install Bluetooth support"; then bash "$SCRIPT_DIR/system/bluetooth.sh"; fi
  if confirm "Install audio support"; then bash "$SCRIPT_DIR/system/audio.sh"; fi
  if confirm "Install terminal customization"; then bash "$SCRIPT_DIR/terminal/bash.sh"; fi

  show_summary
  main_menu
}

main "$@"
