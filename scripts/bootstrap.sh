#!/usr/bin/env bash
# Zero-dependency bootstrap: install chezmoi, point it at this repo, and
# run the first `chezmoi init --apply`. Rerunnable — use `chezmoi apply`
# or `make apply` thereafter.
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

CHEZMOI_BIN_DIR="$HOME/.local/bin"
export PATH="$CHEZMOI_BIN_DIR:$PATH"

ensure_linux_prereqs() {
  [[ "$(uname -s)" == "Darwin" ]] && return 0
  command -v apt-get >/dev/null 2>&1 || return 0

  local need=()
  for pkg in curl git ca-certificates; do
    dpkg -s "$pkg" >/dev/null 2>&1 || need+=("$pkg")
  done
  [[ ${#need[@]} -gt 0 ]] || return 0

  log_info "Installing bootstrap prereqs: ${need[*]}"
  sudo apt-get update
  sudo apt-get install -y "${need[@]}"
}

install_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    log_info "chezmoi already installed"
    return
  fi
  log_info "Installing chezmoi to $CHEZMOI_BIN_DIR"
  ensure_dir "$CHEZMOI_BIN_DIR"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_BIN_DIR"
}

run_chezmoi_init() {
  local source_dir
  source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  log_info "Initializing chezmoi with source $source_dir"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    chezmoi init  --source="$source_dir" --dry-run --verbose
    chezmoi apply --source="$source_dir" --dry-run --verbose
  else
    chezmoi init --source="$source_dir" --apply
  fi
}

ensure_linux_prereqs
install_chezmoi
run_chezmoi_init

log_info "Bootstrap complete. Use 'make apply' to re-apply, 'make configure' to change toggles."
