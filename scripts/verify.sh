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
  files="$(git ls-files '*.sh' | grep -vE 'modules/zsh' || true)"
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

check_symlinks() {
  log_info "Verifying core symlink targets"
  local expected=("$DOTFILES_ROOT/config/zsh/zshrc")
  for path in "${expected[@]}"; do
    if [[ ! -f "$path" ]]; then
      log_error "Missing required file $path"
      errors=$((errors + 1))
    fi
  done
}

run_shellcheck
check_symlinks

if [[ $errors -gt 0 ]]; then
  log_error "Verification completed with $errors issue(s)"
  exit 1
fi

log_info "All checks passed"
