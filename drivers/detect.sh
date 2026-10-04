#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch
  require_command lspci

  log_info "Detecting hardware information"
  echo "--- CPU ---"
  uname -m
  echo "--- Disks ---"
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS || true
  echo "--- PCI devices ---"
  lspci -nn | grep -Ei 'vga|3d|display|network|bluetooth' || true
  echo "--- USB devices ---"
  lsusb || true
  echo "--- System ---"
  hostnamectl || true

  if lspci | grep -qi 'nvidia'; then
    log_info "Detected NVIDIA hardware"
    bash "$SCRIPT_DIR/nvidia.sh"
  elif lspci | grep -qi 'amd'; then
    log_info "Detected AMD hardware"
    bash "$SCRIPT_DIR/amd.sh"
  elif lspci | grep -qi 'intel'; then
    log_info "Detected Intel hardware"
    bash "$SCRIPT_DIR/intel.sh"
  else
    log_warn "No supported graphics vendor detected. Installing basic graphics packages only."
    pacman_install mesa vulkan-intel libva-intel-driver lib32-mesa lib32-vulkan-intel || true
  fi
}

main "$@"
