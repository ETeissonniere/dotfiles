#!/usr/bin/env bash
# Re-run chezmoi's interactive prompts and apply the result.
#
# chezmoi caches answers in ~/.config/chezmoi/chezmoi.toml; this wrapper
# asks again (with the previous answers as defaults) so you can flip any
# module toggle, then `chezmoi apply` so packages and settings update.
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

if ! command -v chezmoi >/dev/null 2>&1; then
  log_error "chezmoi is not installed. Run 'make bootstrap' first."
  exit 1
fi

log_info "Re-running chezmoi init (your previous answers become the defaults)"
chezmoi init --prompt

log_info "Applying changes"
chezmoi apply

log_info "Configuration updated"
