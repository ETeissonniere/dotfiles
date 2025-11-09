#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

export_platform

log_info "Applying system settings (platform: ${DOTFILES_PLATFORM})"

if [[ "$DOTFILES_PLATFORM" != "macos" ]]; then
  log_info "System settings only supported on macOS; skipping"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "DRY RUN: would apply macOS defaults and dock configuration"
  exit 0
fi

# Apply macOS defaults
log_info "Applying macOS defaults..."
"${DOTFILES_ROOT}/scripts/macos/defaults.sh"

# Apply dock configuration
log_info "Applying dock configuration..."
"${DOTFILES_ROOT}/scripts/macos/dock.sh"

log_info "System settings applied successfully"
