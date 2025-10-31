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

"${DOTFILES_ROOT}/scripts/packages/install.sh"
"${DOTFILES_ROOT}/scripts/config/deploy.sh"

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

maybe_apply_macos_defaults() {
  if [[ "$DOTFILES_PLATFORM" != "macos" ]]; then
    return
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "DRY RUN: skipping macOS defaults"
    return
  fi

  if prompt_confirm "Apply macOS defaults and system settings now?" "N"; then
    "${DOTFILES_ROOT}/scripts/macos/defaults.sh"
  else
    log_info "Skipping macOS defaults"
  fi
}

maybe_apply_macos_dock() {
  if [[ "$DOTFILES_PLATFORM" != "macos" ]]; then
    return
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "DRY RUN: skipping macOS dock"
    return
  fi

  if prompt_confirm "Edit macOS dock configuration?" "N"; then
    "${DOTFILES_ROOT}/scripts/macos/dock.sh"
  else
    log_info "Skipping macOS dock"
  fi
}

maybe_install_rosetta
maybe_apply_macos_defaults
maybe_apply_macos_dock

log_info "Bootstrap complete"
