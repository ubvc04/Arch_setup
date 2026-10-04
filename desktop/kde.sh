#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch
  log_info "Installing KDE Plasma"
  log_info "plasma-desktop: KDE desktop session"
  log_info "plasma-nm: network connection applet"
  log_info "sddm: display manager"

  pacman_install plasma-desktop plasma-nm kde-system-meta sddm xorg-server xorg-xinit

  if ! systemctl is-enabled --quiet sddm 2>/dev/null; then
    if confirm "Enable SDDM for KDE?" "y"; then
      systemctl enable --now sddm
    fi
  else
    log_info "SDDM is already enabled."
  fi

  log_success "KDE Plasma installation complete."
}

main "$@"
