#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../../../scripts/lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$SCRIPT_DIR/../../../scripts/lib/os.sh"

DRY_RUN="${DRY_RUN:-0}"
export_platform

if [[ "$DRY_RUN" == "1" ]]; then
  log_info "DRY RUN: would install Homebrew via install script"
  exit 0
fi

case "$DOTFILES_PLATFORM" in
  ubuntu|raspbian|linux)
    ;;
  *)
    log_warn "Unsupported platform '$DOTFILES_PLATFORM' for Homebrew installer"
    exit 0
    ;;
esac

if command -v brew >/dev/null 2>&1; then
  log_info "Homebrew already installed"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  log_error "curl not available; cannot install Homebrew"
  exit 1
fi

log_info "Installing Homebrew from https://brew.sh"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

log_info "Homebrew installation complete"
