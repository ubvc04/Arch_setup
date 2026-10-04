#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch

  if ! lspci | grep -qi 'nvidia'; then
    log_warn "No NVIDIA GPU detected. Skipping NVIDIA driver installation."
    exit 0
  fi

  log_info "Installing NVIDIA support"
  log_info "The correct driver package can depend on GPU generation and kernel version."
  log_info "Install only if NVIDIA hardware was detected."

  pacman_install nvidia nvidia-utils lib32-nvidia-utils linux-firmware
  log_success "NVIDIA driver installation completed. Reboot after installation."
}

main "$@"
