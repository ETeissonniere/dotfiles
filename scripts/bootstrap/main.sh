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

"${DOTFILES_ROOT}/scripts/packages/install.sh"
"${DOTFILES_ROOT}/scripts/config/deploy.sh"
maybe_install_rosetta

log_info "Bootstrap complete"