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
  log_info "DRY RUN: would install GitHub CLI"
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  log_warn "apt-get not available; skipping GitHub CLI installation"
  exit 0
fi

if command -v gh >/dev/null 2>&1; then
  log_info "GitHub CLI already installed"
  exit 0
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
else
  log_warn "/etc/os-release not found; unable to detect distribution"
  exit 1
fi

case "$DOTFILES_PLATFORM" in
  ubuntu|raspbian|linux)
    ;;
  *)
    log_warn "Unsupported platform '$DOTFILES_PLATFORM' for GitHub CLI installer"
    exit 0
    ;;
esac

log_info "Installing GitHub CLI from https://cli.github.com/packages"

ensure_fetch_tool() {
  if command -v wget >/dev/null 2>&1; then
    printf 'wget'
    return
  fi

  if command -v curl >/dev/null 2>&1; then
    printf 'curl'
    return
  fi

  log_info "Installing wget dependency"
  sudo apt-get update
  sudo apt-get install -y wget
  printf 'wget'
}

fetch_tool="$(ensure_fetch_tool)"

tmp_key="$(mktemp)"
cleanup() {
  rm -f "$tmp_key"
}
trap cleanup EXIT

if [[ "$fetch_tool" == "wget" ]]; then
  wget -nv -O "$tmp_key" "https://cli.github.com/packages/githubcli-archive-keyring.gpg"
else
  curl -fsSL -o "$tmp_key" "https://cli.github.com/packages/githubcli-archive-keyring.gpg"
fi

sudo install -m 0755 -d /etc/apt/keyrings
sudo cp "$tmp_key" /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

sudo install -m 0755 -d /etc/apt/sources.list.d

arch="$(dpkg --print-architecture)"
repo_line="deb [arch=${arch} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"

printf '%s\n' "$repo_line" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

sudo apt-get update
sudo apt-get install -y gh

log_info "GitHub CLI installation complete"
