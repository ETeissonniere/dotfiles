#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES_ROOT:-}" ]]; then
  DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
export DOTFILES_ROOT

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_warn() {
  printf '[WARN] %s\n' "$*" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    log_info "Created directory $dir"
  fi
}

link_file() {
  local source_path="$1"
  local target_path="$2"

  if [[ ! -e "$source_path" ]]; then
    log_warn "Missing source $source_path"
    return 1
  fi

  local target_dir
  target_dir="$(dirname "$target_path")"
  ensure_dir "$target_dir"

  if [[ -L "$target_path" ]]; then
    local current
    current="$(readlink "$target_path")"
    if [[ "$current" == "$source_path" ]]; then
      log_info "Symlink already up to date at $target_path"
      return 0
    fi
  fi

  if [[ -e "$target_path" ]]; then
    log_warn "Replacing existing $target_path with symlink"
    rm -f "$target_path"
  fi

  ln -s "$source_path" "$target_path"
  log_info "Linked $target_path -> $source_path"
}
