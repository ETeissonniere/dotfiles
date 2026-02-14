#!/usr/bin/env bash
set -euo pipefail

# Removes apt-installed packages and custom repos that have been migrated to Homebrew.
# Run this once on existing Linux machines before `make packages`.

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

DRY_RUN="${DRY_RUN:-0}"

run_cmd() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: $*"
  else
    "$@"
  fi
}

# --- Remove apt packages now handled by Homebrew ---
APT_PACKAGES=(
  btop
  eza
  fd-find
  fzf
  gh
  git-lfs
  ripgrep
  vim
  zoxide
)

if command -v apt-get >/dev/null 2>&1; then
  log_info "Removing apt packages migrated to Homebrew"
  run_cmd sudo apt-get remove --purge -y "${APT_PACKAGES[@]}" 2>/dev/null || true
  run_cmd sudo apt-get autoremove -y
fi

# --- Remove custom apt repos ---

# eza (gierens)
if [[ -f /etc/apt/sources.list.d/gierens.list ]]; then
  log_info "Removing eza apt repo"
  run_cmd sudo rm -f /etc/apt/sources.list.d/gierens.list
  run_cmd sudo rm -f /etc/apt/keyrings/gierens.gpg
fi

# GitHub CLI
if [[ -f /etc/apt/sources.list.d/github-cli.list ]]; then
  log_info "Removing GitHub CLI apt repo"
  run_cmd sudo rm -f /etc/apt/sources.list.d/github-cli.list
  run_cmd sudo rm -f /etc/apt/keyrings/githubcli-archive-keyring.gpg
fi

# --- Remove standalone uv install (astral.sh curl installer) ---
for uv_bin in "$HOME/.cargo/bin/uv" "$HOME/.cargo/bin/uvx" \
              "$HOME/.local/bin/uv" "$HOME/.local/bin/uvx"; do
  if [[ -f "$uv_bin" ]]; then
    log_info "Removing standalone uv binary $uv_bin"
    run_cmd rm -f "$uv_bin"
  fi
done

# --- Refresh apt index ---
if command -v apt-get >/dev/null 2>&1; then
  log_info "Refreshing apt index"
  run_cmd sudo apt-get update
fi

log_info "Legacy cleanup complete — run 'make packages' to install via Homebrew"
