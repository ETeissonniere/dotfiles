#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

export_platform

log_info "Applying system settings (platform: ${DOTFILES_PLATFORM})"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "DRY RUN: would apply system settings for ${DOTFILES_PLATFORM}"
  exit 0
fi

case "$DOTFILES_PLATFORM" in
  macos)
    # Apply macOS defaults
    log_info "Applying macOS defaults..."
    "${DOTFILES_ROOT}/scripts/macos/defaults.sh"

    # Apply dock configuration
    log_info "Applying dock configuration..."
    "${DOTFILES_ROOT}/scripts/macos/dock.sh"
    ;;
  linux|ubuntu|raspbian)
    # Apply Linux defaults
    log_info "Applying Linux defaults..."
    "${DOTFILES_ROOT}/scripts/linux/defaults.sh"
    ;;
  *)
    log_info "System settings not supported on ${DOTFILES_PLATFORM}; skipping"
    exit 0
    ;;
esac

log_info "System settings applied successfully"
