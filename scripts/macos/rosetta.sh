#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

export_platform

if [[ "$DOTFILES_PLATFORM" != "macos" ]]; then
  log_warn "macOS Rosetta script invoked on non-macOS platform; skipping"
  exit 0
fi

# Check if running on Apple Silicon
if [[ "$(uname -m)" != "arm64" ]]; then
  log_info "Not running on Apple Silicon; Rosetta installation not required"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "DRY RUN: would install Rosetta 2"
  exit 0
fi

# Check if Rosetta is already installed
if /usr/bin/pgrep -q oahd; then
  log_info "Rosetta 2 is already installed"
  exit 0
fi

log_info "Installing Rosetta 2 (required for running non-ARM containers)"

# Install Rosetta with automatic license agreement
if softwareupdate --install-rosetta --agree-to-license; then
  log_info "Rosetta 2 installed successfully"
else
  log_error "Failed to install Rosetta 2"
  exit 1
fi
