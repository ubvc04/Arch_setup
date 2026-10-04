#!/usr/bin/env bash
set -euo pipefail

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_warn() {
  printf '[WARNING] %s\n' "$*"
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

log_success() {
  printf '[SUCCESS] %s\n' "$*"
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Required command not found: $cmd"
    return 1
  fi
}

is_arch_linux() {
  if [[ -f /etc/arch-release ]]; then
    return 0
  fi

  if [[ -f /etc/os-release ]]; then
    local id
    id="$(grep '^ID=' /etc/os-release | head -n 1 | cut -d= -f2- | tr -d '"')"
    [[ "$id" == "arch" || "$id" == "archarm" ]]
    return $?
  fi

  return 1
}

check_arch() {
  if ! is_arch_linux; then
    log_error "This script is intended for Arch Linux only."
    exit 1
  fi
  log_success "Detected Arch Linux"
}

confirm() {
  local message="$1"
  local default="${2:-n}"
  local response

  while true; do
    if [[ "$default" == "y" || "$default" == "Y" ]]; then
      printf '%s [Y/n]: ' "$message"
    else
      printf '%s [y/N]: ' "$message"
    fi
    read -r response || true

    response="${response:-$default}"
    case "$response" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo]) return 1 ;;
      *) printf 'Please answer yes or no.\n' ;;
    esac
  done
}

ensure_root_or_sudo() {
  if [[ "$EUID" -ne 0 ]]; then
    log_warn "This installer should be run as root, or with sudo before each privileged action."
    log_info "Example: sudo ./install.sh"
    log_info "Or: sudo bash ./install.sh"
    return 1
  fi
  log_success "Running with root privileges"
}

ensure_internet() {
  require_command curl
  if ! curl -fsSL https://archlinux.org >/dev/null 2>&1; then
    log_error "No internet connection or archlinux.org is unreachable."
    return 1
  fi
  log_success "Internet connectivity OK"
}

pacman_install() {
  local packages=("$@")
  if [[ ${#packages[@]} -eq 0 ]]; then
    return 0
  fi

  log_info "Installing packages: ${packages[*]}"
  pacman -S --needed --noconfirm "${packages[@]}"
}

read_package_list() {
  local file_path="$1"
  if [[ ! -f "$file_path" ]]; then
    log_error "Missing package list: $file_path"
    return 1
  fi

  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    printf '%s\n' "$pkg"
  done <"$file_path"
}

print_banner() {
  local title="$1"
  printf '\n========================================\n'
  printf '  %s\n' "$title"
  printf '========================================\n\n'
}

show_service_status() {
  local service="$1"
  if systemctl is-enabled --quiet "$service" 2>/dev/null; then
    systemctl status --no-pager "$service" || true
  else
    log_info "$service is not enabled"
  fi
}

ensure_service_enabled() {
  local service="$1"
  if systemctl list-unit-files --type=service --no-legend | awk '{print $1}' | grep -Fxq "$service"; then
    if ! systemctl is-enabled --quiet "$service"; then
      log_info "Enabling service: $service"
      systemctl enable --now "$service"
    else
      log_info "$service is already enabled"
    fi
  else
    log_warn "Service $service is not available on this system"
  fi
}

ensure_user_service_enabled() {
  local service="$1"
  if systemctl --user is-enabled --quiet "$service" 2>/dev/null; then
    log_info "$service already enabled for the current user"
  else
    log_info "Enabling user service: $service"
    systemctl --user enable --now "$service" || log_warn "Could not enable $service for the current user"
  fi
}

ask_for_value() {
  local prompt="$1"
  local default_value="${2:-}"
  local response

  if [[ -n "$default_value" ]]; then
    printf '%s [%s]: ' "$prompt" "$default_value"
  else
    printf '%s: ' "$prompt"
  fi
  read -r response || true

  if [[ -z "$response" ]]; then
    response="$default_value"
  fi

  printf '%s' "$response"
}
