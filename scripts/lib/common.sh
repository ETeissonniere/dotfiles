#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES_ROOT:-}" ]]; then
  DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
export DOTFILES_ROOT

# Establish a minimal color palette for nicer log output when the terminal supports
# it. Users can disable colors entirely by setting NO_COLOR.
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  DOTFILES_COLOR_RESET=$'\033[0m'
  DOTFILES_COLOR_INFO=$'\033[1;34m'
  DOTFILES_COLOR_WARN=$'\033[1;33m'
  DOTFILES_COLOR_ERROR=$'\033[1;31m'
  DOTFILES_COLOR_ACCENT=$'\033[1;36m'
  DOTFILES_COLOR_MUTED=$'\033[2m'
else
  DOTFILES_COLOR_RESET=''
  DOTFILES_COLOR_INFO=''
  DOTFILES_COLOR_WARN=''
  DOTFILES_COLOR_ERROR=''
  DOTFILES_COLOR_ACCENT=''
  DOTFILES_COLOR_MUTED=''
fi

DOTFILES_PREFIX_INFO="${DOTFILES_COLOR_INFO}[INFO]${DOTFILES_COLOR_RESET}"
DOTFILES_PREFIX_WARN="${DOTFILES_COLOR_WARN}[WARN]${DOTFILES_COLOR_RESET}"
DOTFILES_PREFIX_ERROR="${DOTFILES_COLOR_ERROR}[ERROR]${DOTFILES_COLOR_RESET}"

log_info() {
  printf '%s %s\n' "$DOTFILES_PREFIX_INFO" "$*"
}

log_warn() {
  printf '%s %s\n' "$DOTFILES_PREFIX_WARN" "$*" >&2
}

log_error() {
  printf '%s %s\n' "$DOTFILES_PREFIX_ERROR" "$*" >&2
}

prompt_confirm() {
  local prompt_message="$1"
  local default_choice="${2:-}"
  local default_hint
  local response

  case "$default_choice" in
    [Yy])
      default_hint='[Y/n]'
      ;;
    [Nn])
      default_hint='[y/N]'
      ;;
    *)
      default_hint='[y/n]'
      default_choice=''
      ;;
  esac

  while true; do
    read -r -p "${DOTFILES_COLOR_ACCENT}${prompt_message}${DOTFILES_COLOR_RESET} ${DOTFILES_COLOR_MUTED}${default_hint}${DOTFILES_COLOR_RESET} " response
    if [[ -z "$response" && -n "$default_choice" ]]; then
      response="$default_choice"
    fi

    case "$response" in
      [Yy]*)
        return 0
        ;;
      [Nn]*)
        return 1
        ;;
      *)
        log_warn "Please answer with y or n."
        ;;
    esac
  done
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
