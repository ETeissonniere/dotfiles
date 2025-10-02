#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

DRY_RUN="${DRY_RUN:-0}"
export DRY_RUN

export_platform

write_if_needed() {
  local tmp="$1"
  local target="$2"
  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: would write $target"
    rm -f "$tmp"
    return
  fi

  mv "$tmp" "$target"
  log_info "Wrote $target"
}

render_gitconfig() {
  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  cat "$DOTFILES_ROOT/config/git/base.conf" >>"$tmp"

  local platform_file="$DOTFILES_ROOT/config/git/${DOTFILES_PLATFORM}.conf"
  if [[ -f "$platform_file" ]]; then
    printf '\n' >>"$tmp"
    cat "$platform_file" >>"$tmp"
  fi

  write_if_needed "$tmp" "$HOME/.gitconfig"
  trap - EXIT
}

render_ssh_config() {
  ensure_dir "$HOME/.ssh"
  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  cat "$DOTFILES_ROOT/config/ssh/base.conf" >>"$tmp"

  local platform_file="$DOTFILES_ROOT/config/ssh/${DOTFILES_PLATFORM}.conf"
  if [[ -f "$platform_file" ]]; then
    printf '\n' >>"$tmp"
    cat "$platform_file" >>"$tmp"
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: would write $HOME/.ssh/config"
    rm -f "$tmp"
  else
    mv "$tmp" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    log_info "Wrote $HOME/.ssh/config"
  fi
  trap - EXIT
}

link_zsh() {
  local source="$DOTFILES_ROOT/config/zsh/zshrc"
  local target="$HOME/.zshrc"
  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: would link $target -> $source"
  else
    link_file "$source" "$target"
  fi
}

ensure_default_shell() {
  local shell_path user
  shell_path="$(command -v zsh || true)"

  if [[ -z "$shell_path" ]]; then
    log_warn "zsh is not installed; skipping default shell update"
    return
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log_info "DRY RUN: would change default shell to $shell_path"
    return
  fi

  if ! grep -Fxq "$shell_path" /etc/shells; then
    log_warn "$shell_path is not listed in /etc/shells; please add it and rerun to change the default shell"
    return
  fi

  user="$(id -un)"

  if chsh -s "$shell_path" "$user"; then
    log_info "Default shell changed to $shell_path"
  else
    log_warn "Failed to change default shell automatically; run 'chsh -s $shell_path' manually."
  fi
}

render_gitconfig
render_ssh_config
link_zsh
ensure_default_shell

log_info "Configuration deployed"
