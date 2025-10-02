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

maybe_apply_macos_defaults() {
  if [[ "$DOTFILES_PLATFORM" != "macos" ]]; then
    return
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "DRY RUN: skipping macOS defaults"
    return
  fi

  read -r -p "Apply macOS defaults and system settings now? [y/N]: " response
  case "$response" in
    [Yy]*)
      "${DOTFILES_ROOT}/scripts/macos/defaults.sh"
      ;;
    *)
      log_info "Skipping macOS defaults"
      ;;
  esac
}

maybe_apply_macos_defaults

log_info "Bootstrap complete"
