#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log_info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
log_error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1"; }

detect_platform() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux)  echo "linux" ;;
    *)      log_error "Unsupported platform: $(uname -s)"; exit 1 ;;
  esac
}

install_nix() {
  if command -v nix &>/dev/null; then
    return
  fi

  log_info "Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck source=/dev/null
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

install_rosetta() {
  if [[ "$(uname -s)" != "Darwin" ]] || [[ "$(uname -m)" != "arm64" ]]; then
    return
  fi
  if /usr/bin/pgrep -q oahd 2>/dev/null; then
    return
  fi
  log_info "Installing Rosetta 2..."
  softwareupdate --install-rosetta --agree-to-license
}

update_remote_to_ssh() {
  local remote_url
  remote_url="$(git -C "${DOTFILES_ROOT}" remote get-url origin 2>/dev/null || true)"
  if [[ -z "$remote_url" ]] || [[ "$remote_url" == git@* ]]; then
    return
  fi
  if [[ "$remote_url" =~ ^https://([^/]+)/(.+)$ ]]; then
    local ssh_url="git@${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"
    git -C "${DOTFILES_ROOT}" remote set-url origin "$ssh_url"
    log_info "Updated git remote to SSH: ${ssh_url}"
  fi
}

switch_config() {
  local flavor="$1"
  local platform
  platform="$(detect_platform)"

  case "$platform" in
    darwin)
      if ! command -v darwin-rebuild &>/dev/null; then
        nix run nix-darwin -- switch --flake "${DOTFILES_ROOT}#${flavor}"
      else
        darwin-rebuild switch --flake "${DOTFILES_ROOT}#${flavor}"
      fi
      ;;
    linux)
      if nixos-rebuild --version &>/dev/null; then
        sudo nixos-rebuild switch --flake "${DOTFILES_ROOT}#${flavor}"
      elif command -v home-manager &>/dev/null; then
        home-manager switch --flake "${DOTFILES_ROOT}#${flavor}"
      else
        nix run home-manager/master -- switch --flake "${DOTFILES_ROOT}#${flavor}"
      fi
      ;;
  esac
}

usage() {
  echo "Usage: $0 <command> [args]"
  echo ""
  echo "Commands:"
  echo "  switch <flavor>              Apply configuration locally"
  echo "  deploy <flavor> <user@host>  Deploy NixOS config to a remote host"
  echo "  install <flavor> <user@host> Provision NixOS on a new machine (nixos-anywhere)"
  echo "  update                       Update flake dependencies"
  echo "  check                        Validate flake configuration"
  echo ""
  echo "Flavors:"
  echo "  personal   Personal Mac (all apps, socials, Docker, UTM)"
  echo "  work       Work Mac (Docker, Tailscale, no socials/personal apps)"
  echo "  vm         Mac VM (minimal, no Docker/UTM/socials)"
  echo "  server     NixOS server (Docker, SSH, passwordless sudo)"
  echo "  linux      Non-NixOS Linux (Home Manager standalone)"
  echo ""
  echo "Examples:"
  echo "  $0 switch personal"
  echo "  $0 deploy server user@192.168.1.100"
  echo "  $0 install server root@192.168.1.100"
  echo "  $0 update"
  exit 1
}

cmd_switch() {
  local flavor="${1:-}"
  if [[ -z "$flavor" ]]; then
    log_error "Missing flavor. Available: personal, work, vm, server, linux"
    exit 1
  fi

  install_nix
  install_rosetta

  log_info "Switching to ${flavor}..."
  switch_config "$flavor"

  update_remote_to_ssh

  log_info "Done"
}

cmd_deploy() {
  local flavor="${1:-}"
  local target="${2:-}"
  if [[ -z "$flavor" ]] || [[ -z "$target" ]]; then
    log_error "Usage: $0 deploy <flavor> <user@host>"
    exit 1
  fi

  log_info "Deploying ${flavor} to ${target}..."
  nix run nixpkgs#nixos-rebuild -- switch \
    --flake "${DOTFILES_ROOT}#${flavor}" \
    --target-host "$target" \
    --use-remote-sudo
  log_info "Done"
}

cmd_install() {
  local flavor="${1:-}"
  local target="${2:-}"
  if [[ -z "$flavor" ]] || [[ -z "$target" ]]; then
    log_error "Usage: $0 install <flavor> <user@host>"
    exit 1
  fi

  log_info "Installing NixOS (${flavor}) on ${target} via nixos-anywhere..."
  nix run github:nix-community/nixos-anywhere -- \
    --flake "${DOTFILES_ROOT}#${flavor}" \
    "$target"
  log_info "Done"
}

cmd_update() {
  log_info "Updating flake inputs..."
  nix flake update --flake "${DOTFILES_ROOT}"
  log_info "Done. Run '$0 switch <flavor>' to apply."
}

cmd_check() {
  nix flake check "${DOTFILES_ROOT}"
}

main() {
  local command="${1:-}"
  shift || true

  case "$command" in
    switch)  cmd_switch "$@" ;;
    deploy)  cmd_deploy "$@" ;;
    install) cmd_install "$@" ;;
    update)  cmd_update ;;
    check)   cmd_check ;;
    *)       usage ;;
  esac
}

main "$@"
