#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

export_platform

log_info "Starting bootstrap (platform: ${DOTFILES_PLATFORM})"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "Running in dry-run mode; no changes will be applied"
fi

maybe_install_rosetta() {
  if [[ "$DOTFILES_PLATFORM" != "macos" ]]; then
    return
  fi

  if [[ "$(uname -m)" != "arm64" ]]; then
    return
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "DRY RUN: skipping Rosetta installation"
    return
  fi

  if prompt_confirm "Install Rosetta 2 (required for non-ARM containers)?" "Y"; then
    "${DOTFILES_ROOT}/scripts/macos/rosetta.sh"
  else
    log_info "Skipping Rosetta installation"
  fi
}

update_remote_to_ssh() {
  local remote_url
  remote_url="$(git -C "${DOTFILES_ROOT}" remote get-url origin 2>/dev/null || true)"

  if [[ -z "$remote_url" ]]; then
    log_warn "No origin remote found, skipping SSH conversion"
    return
  fi

  # Check if already using SSH
  if [[ "$remote_url" == git@* ]]; then
    log_info "Git remote already using SSH"
    return
  fi

  # Convert HTTPS to SSH (supports github.com and other hosts)
  # https://github.com/user/repo.git -> git@github.com:user/repo.git
  if [[ "$remote_url" =~ ^https://([^/]+)/(.+)$ ]]; then
    local host="${BASH_REMATCH[1]}"
    local path="${BASH_REMATCH[2]}"
    local ssh_url="git@${host}:${path}"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      log_info "DRY RUN: would update remote to ${ssh_url}"
      return
    fi

    git -C "${DOTFILES_ROOT}" remote set-url origin "$ssh_url"
    log_info "Updated git remote to SSH: ${ssh_url}"
  else
    log_warn "Unrecognized remote URL format: ${remote_url}"
  fi
}

"${DOTFILES_ROOT}/scripts/packages/install.sh"
"${DOTFILES_ROOT}/scripts/config/deploy.sh"
maybe_install_rosetta
update_remote_to_ssh

log_info "Bootstrap complete"