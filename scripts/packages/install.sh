#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

DRY_RUN="${DRY_RUN:-0}"
export DRY_RUN

export_platform

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log_warn "Homebrew not found"
  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: would install Homebrew"
    return
  fi

  log_info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  case "$DOTFILES_PLATFORM" in
    macos)
      eval "$(/opt/homebrew/bin/brew shellenv)"
      ;;
    *)
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      ;;
  esac
}

run_brew_bundle() {
  local install_script="$DOTFILES_ROOT/packages/install.sh"
  if [[ -x "$install_script" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      log_info "DRY RUN: $install_script"
    else
      "$install_script"
    fi
  else
    log_warn "Missing or non-executable $install_script"
  fi
}

install_linux_prereqs() {
  local apt_list="$DOTFILES_ROOT/packages/linux/apt.txt"
  if ! command -v apt-get >/dev/null 2>&1; then
    log_warn "apt-get not available on this system"
    return
  fi

  if [[ ! -f "$apt_list" ]]; then
    return
  fi

  mapfile -t packages < <(grep -vE '^(#|\s*$)' "$apt_list")
  if [[ ${#packages[@]} -eq 0 ]]; then
    return
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: sudo apt-get update"
    log_info "DRY RUN: sudo apt-get install -y ${packages[*]}"
  else
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
  fi
}

install_linux_docker() {
  local docker_script="$DOTFILES_ROOT/packages/linux/postinstall/docker.sh"
  if [[ -x "$docker_script" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      log_info "DRY RUN: would run $docker_script"
    else
      log_info "Running Docker installer"
      bash "$docker_script"
    fi
  fi
}

case "$DOTFILES_PLATFORM" in
  macos)
    ensure_homebrew
    run_brew_bundle
    ;;
  ubuntu|raspbian|linux)
    install_linux_prereqs
    ensure_homebrew
    run_brew_bundle
    install_linux_docker
    ;;
  *)
    log_warn "No package installer defined for platform $DOTFILES_PLATFORM"
    ;;
esac
