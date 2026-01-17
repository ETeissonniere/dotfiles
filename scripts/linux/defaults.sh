#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

export_platform

if [[ "$DOTFILES_PLATFORM" == "macos" ]]; then
  log_warn "Linux defaults script invoked on macOS; skipping"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "DRY RUN: would configure Linux defaults"
  exit 0
fi

log_info "Configuring Linux system settings"

# Configure passwordless sudo for admin group
configure_passwordless_sudo() {
  local admin_group=""

  # Detect admin group (sudo on Debian/Ubuntu, wheel on RHEL/Fedora, admin on some systems)
  if getent group sudo >/dev/null 2>&1; then
    admin_group="sudo"
  elif getent group wheel >/dev/null 2>&1; then
    admin_group="wheel"
  elif getent group admin >/dev/null 2>&1; then
    admin_group="admin"
  else
    log_warn "No admin group (sudo/wheel/admin) found; skipping passwordless sudo configuration"
    return 0
  fi

  log_info "Detected admin group: ${admin_group}"

  local sudoers_file="/etc/sudoers.d/nopasswd-${admin_group}"
  local sudoers_line="%${admin_group} ALL=(ALL) NOPASSWD: ALL"

  if [[ -f "$sudoers_file" ]]; then
    if grep -qF "$sudoers_line" "$sudoers_file" 2>/dev/null; then
      log_info "Passwordless sudo already configured for ${admin_group} group"
      return 0
    fi
  fi

  log_info "Configuring passwordless sudo for ${admin_group} group"
  echo "$sudoers_line" | sudo tee "$sudoers_file" >/dev/null
  sudo chmod 0440 "$sudoers_file"

  # Validate sudoers syntax
  if sudo visudo -cf "$sudoers_file" >/dev/null 2>&1; then
    log_info "Passwordless sudo configured successfully for ${admin_group} group"
  else
    log_error "Invalid sudoers syntax; removing ${sudoers_file}"
    sudo rm -f "$sudoers_file"
    return 1
  fi
}

configure_passwordless_sudo

log_info "Linux defaults configured"
