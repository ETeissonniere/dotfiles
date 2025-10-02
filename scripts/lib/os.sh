#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

detect_platform() {
  local uname
  uname="$(uname -s)"
  case "$uname" in
    Darwin)
      printf 'macos'
      ;;
    Linux)
      if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID:-}" in
          raspbian|raspios)
            printf 'raspbian'
            return
            ;;
          ubuntu)
            printf 'ubuntu'
            return
            ;;
        esac
      fi
      printf 'linux'
      ;;
    *)
      printf 'unknown'
      ;;
  esac
}

export_platform() {
  if [[ -n "${DOTFILES_PLATFORM:-}" ]]; then
    return
  fi
  DOTFILES_PLATFORM="$(detect_platform)"
  export DOTFILES_PLATFORM
  log_info "Detected platform ${DOTFILES_PLATFORM}"
}
