#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch
  log_info "Installing AMD graphics support"
  log_info "mesa: open-source graphics stack"
  log_info "vulkan-radeon: AMD Vulkan support"
  log_info "libva-mesa-driver: VA-API support"

  pacman_install mesa vulkan-radeon libva-mesa-driver lib32-mesa lib32-vulkan-radeon linux-firmware
  log_success "AMD graphics stack installed."
}

main "$@"
