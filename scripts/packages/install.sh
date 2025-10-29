#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

DRY_RUN="${DRY_RUN:-0}"
export DRY_RUN

export_platform

install_macos_packages() {
  local install_script="$DOTFILES_ROOT/packages/macos/install.sh"

  if ! command -v brew >/dev/null 2>&1; then
    log_warn "Homebrew not found"
    if [[ "$DRY_RUN" == "1" ]]; then
      log_info "DRY RUN: would install Homebrew"
    else
      log_info "Installing Homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

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

install_apt_packages() {
  local apt_list="$DOTFILES_ROOT/packages/linux/apt.txt"
  if ! command -v apt-get >/dev/null 2>&1; then
    log_warn "apt-get not available on this system"
    return
  fi

  if [[ ! -f "$apt_list" ]]; then
    log_warn "Missing $apt_list"
    return
  fi

  mapfile -t packages < <(grep -vE '^(#|\s*$)' "$apt_list")

  if [[ ${#packages[@]} -eq 0 ]]; then
    log_warn "No apt packages listed"
    return
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: sudo apt-get update"
    log_info "DRY RUN: sudo apt-get install -y ${packages[*]}"
  else
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
  fi

  local postinstall_dir="$DOTFILES_ROOT/packages/linux/postinstall"
  if [[ -d "$postinstall_dir" ]]; then
    for script in "$postinstall_dir"/*.sh; do
      [[ -e "$script" ]] || continue
      if [[ "$DRY_RUN" == "1" ]]; then
        log_info "DRY RUN: would run $script"
      else
        log_info "Running post-install script $script"
        bash "$script"
      fi
    done
  fi
}

case "$DOTFILES_PLATFORM" in
  macos)
    install_macos_packages
    ;;
  ubuntu|raspbian|linux)
    install_apt_packages
    ;;
  *)
    log_warn "No package installer defined for platform $DOTFILES_PLATFORM"
    ;;
 esac
