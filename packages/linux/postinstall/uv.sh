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
  log_info "DRY RUN: would install uv via astral.sh installer"
  exit 0
fi

case "$DOTFILES_PLATFORM" in
  ubuntu|raspbian|linux)
    ;;
  *)
    log_warn "Unsupported platform '$DOTFILES_PLATFORM' for uv installer"
    exit 0
    ;;
esac

if command -v uv >/dev/null 2>&1; then
  log_info "uv already installed"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  log_error "curl not available; cannot install uv"
  exit 1
fi

log_info "Installing uv from https://astral.sh/uv/install.sh"

# Use a subshell to avoid leaking environment changes from the installer.
if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
  log_error "uv installation script failed"
  exit 1
fi

log_info "uv installation complete"
