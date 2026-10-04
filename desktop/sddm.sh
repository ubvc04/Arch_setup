#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch

  if ! command -v sddm >/dev/null 2>&1; then
    pacman_install sddm
  fi

  if systemctl is-enabled --quiet lightdm 2>/dev/null; then
    log_warn "LightDM is already enabled. Do not switch display managers without confirmation."
    if confirm "Would you like to keep LightDM and not enable SDDM?" "y"; then
      log_info "Leaving the existing display manager in place."
      exit 0
    fi
  fi

  if systemctl is-enabled --quiet sddm 2>/dev/null; then
    log_info "SDDM is already enabled."
  else
    if confirm "Enable SDDM as the display manager?" "y"; then
      systemctl enable --now sddm
    else
      log_info "Display manager left unchanged."
    fi
  fi

  log_info "SDDM is used to allow switching between installed desktop environments from the login screen."
  log_success "SDDM configuration checked."
}

main "$@"
