#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

errors=0

run_shellcheck() {
  if ! command -v shellcheck >/dev/null 2>&1; then
    log_warn "shellcheck not installed; skipping lint"
    return
  fi

  log_info "Running shellcheck"
  local files
  files="$(git ls-files '*.sh' | grep -vE 'modules/(zsh|tmux)' || true)"
  if [[ -z "$files" ]]; then
    log_warn "No shell scripts found"
    return
  fi

  local shellcheck_failed=0
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    if ! shellcheck -x "$file"; then
      shellcheck_failed=1
    fi
  done <<< "$files"

  if [[ $shellcheck_failed -ne 0 ]]; then
    log_error "shellcheck reported issues"
    errors=$((errors + 1))
  fi
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

validate_templates_if_chezmoi() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    log_warn "chezmoi not installed; skipping template validation"
    return
  fi

  log_info "Validating chezmoi templates"
  if ! chezmoi execute-template --init --promptBool 'isDesktop=true' \
        --promptBool 'includeVirt=false' --promptBool 'includeSocials=false' \
        --promptBool 'isLaptop=false'  --promptBool 'includeWorkApps=false' \
        --promptBool 'includePersonalApps=false' \
        --promptBool 'installDocker=false' \
        < "$DOTFILES_ROOT/home/.chezmoi.toml.tmpl" >/dev/null; then
    log_error "Failed to render .chezmoi.toml.tmpl"
    errors=$((errors + 1))
  fi
}

run_shellcheck
check_chezmoi_sources
validate_templates_if_chezmoi

if [[ $errors -gt 0 ]]; then
  log_error "Verification completed with $errors issue(s)"
  exit 1
fi

log_info "All checks passed"
