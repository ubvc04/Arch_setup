#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch
  log_info "Installing Intel graphics support"
  log_info "mesa: 3D graphics library"
  log_info "vulkan-intel: Intel Vulkan support"
  log_info "libva-intel-driver: hardware video acceleration"

  pacman_install mesa vulkan-intel libva-intel-driver lib32-mesa lib32-vulkan-intel linux-firmware
  log_success "Intel graphics stack installed."
}

main "$@"
