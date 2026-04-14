# Dotfiles sync module — pull updates and apply via chezmoi.
#
# Interactive: shown on shell startup once per DOTFILES_SYNC_CHECK_INTERVAL.
# Manual trigger:  `dotsync` (bypasses throttle).

DOTFILES_SYNC_CHECK_INTERVAL=${DOTFILES_SYNC_CHECK_INTERVAL:-86400}  # 24h
DOTFILES_SYNC_CACHE_FILE="$HOME/.cache/dotfiles-last-check"

_dotfiles_sync() {
  local force="${1:-}"
  local dotfiles_dir="${DOTFILES_ROOT:-$HOME/.dotfiles}"

  mkdir -p "$(dirname "$DOTFILES_SYNC_CACHE_FILE")"

  if [[ "$force" != "--force" ]] && [[ -f "$DOTFILES_SYNC_CACHE_FILE" ]]; then
    local last_check=$(<"$DOTFILES_SYNC_CACHE_FILE")
    local now=$(date +%s)
    local elapsed=$((now - last_check))
    if [[ $elapsed -lt $DOTFILES_SYNC_CHECK_INTERVAL ]]; then
      return 0
    fi
  fi

  date +%s > "$DOTFILES_SYNC_CACHE_FILE"

  pushd -q "$dotfiles_dir" || return 1
  trap "popd -q 2>/dev/null; return 130" INT TERM

  git fetch origin master 2>/dev/null || { popd -q; trap - INT TERM; return 1; }

  local commits_behind=$(git rev-list --count HEAD..origin/master 2>/dev/null)
  if [[ $commits_behind -gt 0 ]]; then
    echo ""
    echo "\033[1;33m==> Dotfiles Update Available\033[0m"
    echo "Your dotfiles are \033[1;36m${commits_behind}\033[0m commit(s) behind origin/master"
    echo ""
    echo "\033[1mNew commits:\033[0m"
    git log --oneline HEAD..origin/master | while read -r line; do
      echo "  \033[0;36m→\033[0m $line"
    done
    echo ""

    while read -t 0 -k 1 2>/dev/null; do :; done
    printf "Apply updates? [y/N]: "
    read -k 1 response
    echo
    echo ""

    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo "\033[1mPulling changes...\033[0m"
      git pull origin master

      if command -v chezmoi >/dev/null 2>&1; then
        echo ""
        echo "\033[1mApplying via chezmoi...\033[0m"
        chezmoi apply
        echo ""
        echo "\033[1;32m✓ Dotfiles updated and reapplied\033[0m"
      else
        echo ""
        echo "\033[1;31m✗ chezmoi not found on PATH; run 'make bootstrap'\033[0m"
      fi
    else
      echo "Skipped. Run \033[1;36mdotsync\033[0m anytime to apply."
    fi
    echo ""
  fi

  popd -q
  trap - INT TERM
}

dotsync() {
  _dotfiles_sync --force
}

_dotfiles_sync
