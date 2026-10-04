#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

install_graphics_stack() {
  local vendor="$1"
  case "$vendor" in
    intel)
      bash "$SCRIPT_DIR/intel.sh"
      ;;
    amd)
      bash "$SCRIPT_DIR/amd.sh"
      ;;
    nvidia)
      bash "$SCRIPT_DIR/nvidia.sh"
      ;;
    *)
      log_warn "No supported graphics stack selected."
      ;;
  esac
}
