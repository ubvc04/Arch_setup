#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  check_arch

  local ssh_dir="$HOME/.ssh"
  local key_path="$ssh_dir/id_ed25519"

  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  if [[ -f "$key_path" || -f "$key_path.pub" ]]; then
    log_info "SSH key already exists at $key_path"
  else
    if confirm "Generate a new ed25519 SSH key for GitHub?" "y"; then
      ssh-keygen -t ed25519 -C "$(git config --global user.email 2>/dev/null || echo "$USER@localhost")" -f "$key_path"
    else
      log_info "No new SSH key generated."
      exit 0
    fi
  fi

  if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)"
  fi

  ssh-add "$key_path" 2>/dev/null || log_warn "Could not add key to ssh-agent automatically. Try: ssh-add ~/.ssh/id_ed25519"

  log_info "Public key:"
  cat "$key_path.pub"

  log_info "Testing GitHub SSH connectivity. This command may show a host key prompt on first use."
  ssh -T -o StrictHostKeyChecking=accept-new git@github.com || true

  log_success "SSH setup checked. Add the public key to GitHub manually if needed."
}

main "$@"
