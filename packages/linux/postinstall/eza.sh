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
  log_info "DRY RUN: would install eza via deb.gierens.de"
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  log_warn "apt-get not available; skipping eza installation"
  exit 0
fi

if command -v eza >/dev/null 2>&1; then
  log_info "eza already installed"
  exit 0
fi

case "$DOTFILES_PLATFORM" in
  ubuntu|raspbian|linux)
    ;;
  *)
    log_warn "Unsupported platform '$DOTFILES_PLATFORM' for eza installer"
    exit 0
    ;;
esac

keyring_path="/etc/apt/keyrings/gierens.gpg"
list_path="/etc/apt/sources.list.d/gierens.list"
repo_line="deb [signed-by=${keyring_path}] http://deb.gierens.de stable main"
APT_UPDATED=0

ensure_apt_updated() {
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    sudo apt-get update
    APT_UPDATED=1
  fi
}

if ! command -v gpg >/dev/null 2>&1; then
  log_info "Installing gpg dependency"
  ensure_apt_updated
  sudo apt-get install -y gpg
fi

if ! command -v curl >/dev/null 2>&1; then
  log_error "curl not available; cannot install eza"
  exit 1
fi

log_info "Configuring eza repository"

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://raw.githubusercontent.com/eza-community/eza/main/deb.asc" | sudo gpg --dearmor -o "$keyring_path"

sudo install -m 0755 -d /etc/apt/sources.list.d
printf '%s\n' "$repo_line" | sudo tee "$list_path" >/dev/null
sudo chmod 0644 "$keyring_path" "$list_path"

sudo apt-get update
sudo apt-get install -y eza

log_info "eza installation complete"
