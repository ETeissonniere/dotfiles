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
  log_info "DRY RUN: would configure Docker repository and packages"
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  log_warn "apt-get not available; skipping Docker installation"
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  log_info "Docker already installed"
  exit 0
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
else
  log_warn "/etc/os-release not found; unable to detect distribution"
  exit 1
fi

repo_url="https://download.docker.com/linux/debian"
codename="${VERSION_CODENAME:-}"

case "${DOTFILES_PLATFORM}" in
  ubuntu)
    repo_url="https://download.docker.com/linux/ubuntu"
    codename="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
    ;;
  raspbian|linux)
    # Raspberry Pi OS 64-bit and generic Debian use the default values above.
    ;;
  *)
    log_warn "Unsupported platform '$DOTFILES_PLATFORM' for Docker installer"
    exit 0
    ;;
esac

if [[ -z "$codename" ]]; then
  log_error "Unable to determine distribution codename"
  exit 1
fi

arch="$(dpkg --print-architecture)"
gpg_path="/etc/apt/keyrings/docker.asc"
list_path="/etc/apt/sources.list.d/docker.list"

log_info "Configuring Docker apt repository ($repo_url) for $codename [$arch]"

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL "$repo_url/gpg" -o "$gpg_path"
sudo chmod a+r "$gpg_path"

echo "deb [arch=${arch} signed-by=${gpg_path}] ${repo_url} ${codename} stable" | sudo tee "$list_path" >/dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable docker >/dev/null 2>&1 || true
  sudo systemctl start docker || true
fi

user_to_config="${SUDO_USER:-$USER}"
if id -nG "$user_to_config" | grep -qw docker; then
  log_info "User $user_to_config already in docker group"
else
  sudo usermod -aG docker "$user_to_config"
  log_info "Added $user_to_config to docker group (log out/in to apply)"
fi

log_info "Docker installation complete"
