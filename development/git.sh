#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch

  local username
  local email
  username="$(ask_for_value "Git username" "")"
  email="$(ask_for_value "Git email" "")"

  if [[ -z "$username" || -z "$email" ]]; then
    log_error "Both Git username and email are required."
    exit 1
  fi

  git config --global user.name "$username"
  git config --global user.email "$email"

  git config --global init.defaultBranch main
  git config --global core.editor nano
  git config --global pull.rebase false
  git config --global color.ui auto
  git config --global push.autoSetupRemote true

  log_info "Configured Git defaults"
  log_info "user.name: $username"
  log_info "user.email: $email"
  log_info "init.defaultBranch: main"
  log_info "core.editor: nano"
  log_info "pull.rebase: false"

  git config --global --list | sed 's/^/  /'
  log_success "Git setup complete."
}

main "$@"
