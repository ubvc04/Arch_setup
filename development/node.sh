#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch
  log_info "Installing Node.js and npm from the official Arch repositories"
  log_info "This is the recommended default. If you prefer nvm, use it only after confirming that you do not already have another Node manager installed."

  pacman_install nodejs npm

  node --version
  npm --version

  if confirm "Would you like to install a Node version manager such as nvm?" "n"; then
    log_info "Install nvm manually when you are ready."
    log_info "Example: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  fi

  log_success "Node.js and npm installed."
}

main "$@"
