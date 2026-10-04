#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch
  log_info "Installing GNOME"
  log_info "gnome: full GNOME desktop environment"
  log_info "gnome-terminal: default GNOME terminal"
  log_info "sddm: display manager"

  pacman_install gnome gnome-terminal sddm xorg-server xorg-xinit

  if ! systemctl is-enabled --quiet sddm 2>/dev/null; then
    if confirm "Enable SDDM for GNOME?" "y"; then
      systemctl enable --now sddm
    fi
  else
    log_info "SDDM is already enabled."
  fi

  log_success "GNOME installation complete."
}

main "$@"
