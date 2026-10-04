#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch
  log_info "Installing a lightweight XFCE desktop"
  log_info "xfce4: core desktop environment"
  log_info "xfce4-terminal: modern terminal emulator"
  log_info "thunar: file manager"
  log_info "gvfs: desktop file system integration"
  log_info "xorg-server and xorg-xinit: graphical session support"

  pacman_install \
    xfce4 \
    xfce4-terminal \
    thunar \
    thunar-volman \
    xfce4-goodies \
    gvfs \
    gvfs-mtp \
    xorg-server \
    xorg-xinit

  if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl is-enabled --quiet lightdm 2>/dev/null; then
      if confirm "Enable LightDM for XFCE?" "y"; then
        pacman_install lightdm lightdm-gtk-greeter
        systemctl enable --now lightdm
      fi
    else
      log_info "LightDM is already enabled"
    fi
  fi

  log_success "XFCE setup completed. Log out and select an XFCE session at the login screen."
}

main "$@"
