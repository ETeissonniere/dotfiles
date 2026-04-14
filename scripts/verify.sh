#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

errors=0

run_shellcheck() {
  command -v shellcheck >/dev/null 2>&1 || { log_warn "shellcheck not installed; skipping lint"; return; }

  local -a files
  mapfile -t files < <(git ls-files '*.sh' | grep -vE 'modules/(zsh|tmux)' || true)
  [[ ${#files[@]} -gt 0 ]] || { log_warn "No shell scripts found"; return; }

  log_info "Running shellcheck on ${#files[@]} files"
  shellcheck -x "${files[@]}" || errors=$((errors + 1))
}

check_chezmoi_sources() {
  log_info "Verifying chezmoi source tree"
  local expected=(
    "$DOTFILES_ROOT/.chezmoiroot"
    "$DOTFILES_ROOT/home/.chezmoi.toml.tmpl"
    "$DOTFILES_ROOT/home/dot_zshrc.tmpl"
    "$DOTFILES_ROOT/home/dot_gitconfig.tmpl"
    "$DOTFILES_ROOT/home/.chezmoidata/packages.yaml"
  )
  for path in "${expected[@]}"; do
    if [[ ! -f "$path" ]]; then
      log_error "Missing required file $path"
      errors=$((errors + 1))
    fi
  done
}

validate_templates() {
  command -v chezmoi >/dev/null 2>&1 || { log_warn "chezmoi not installed; skipping template validation"; return; }

  log_info "Validating chezmoi templates"
  local -a args=(--init)
  local key
  # Auto-extract prompt keys so new toggles don't require editing this script
  while IFS= read -r key; do
    args+=(--promptBool "$key=false")
  done < <(grep -oE 'promptBoolOnce \. "[^"]+"' "$DOTFILES_ROOT/home/.chezmoi.toml.tmpl" | awk -F'"' '{print $2}' | sort -u)

  if ! chezmoi execute-template "${args[@]}" < "$DOTFILES_ROOT/home/.chezmoi.toml.tmpl" >/dev/null; then
    log_error "Failed to render .chezmoi.toml.tmpl"
    errors=$((errors + 1))
  fi
}

run_shellcheck
check_chezmoi_sources
validate_templates

if [[ $errors -gt 0 ]]; then
  log_error "Verification completed with $errors issue(s)"
  exit 1
fi

log_info "All checks passed"
