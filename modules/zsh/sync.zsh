# Dotfiles sync — fetch the source repo, show incoming commits, and delegate
# to `chezmoi update` (= `git pull --autostash --rebase` + `chezmoi apply`).
#
# Auto-runs once per DOTFILES_SYNC_CHECK_INTERVAL seconds on shell startup.
# Manual: `dotsync` (bypasses throttle).

DOTFILES_SYNC_CHECK_INTERVAL=${DOTFILES_SYNC_CHECK_INTERVAL:-86400}  # 24h
DOTFILES_SYNC_CACHE_FILE="$HOME/.cache/dotfiles-last-check"

_dotfiles_sync() {
  local force="${1:-}"
  command -v chezmoi >/dev/null 2>&1 || return 0

  local source_dir
  source_dir="$(chezmoi source-path 2>/dev/null)" || return 0
  [[ -d "$source_dir/.git" ]] || return 0

  mkdir -p "$(dirname "$DOTFILES_SYNC_CACHE_FILE")"

  if [[ "$force" != "--force" ]] && [[ -f "$DOTFILES_SYNC_CACHE_FILE" ]]; then
    local last_check=$(<"$DOTFILES_SYNC_CACHE_FILE")
    local now=$(date +%s)
    (( now - last_check < DOTFILES_SYNC_CHECK_INTERVAL )) && return 0
  fi

  date +%s > "$DOTFILES_SYNC_CACHE_FILE"

  pushd -q "$source_dir" || return 1
  trap "popd -q 2>/dev/null; return 130" INT TERM

  git fetch origin master 2>/dev/null || { popd -q; trap - INT TERM; return 1; }

  local behind=$(git rev-list --count HEAD..origin/master 2>/dev/null)
  if (( behind > 0 )); then
    echo ""
    echo "\033[1;33m==> Dotfiles update available (${behind} commit(s) behind origin/master)\033[0m"
    git log --oneline HEAD..origin/master | sed 's/^/  → /'
    echo ""
    while read -t 0 -k 1 2>/dev/null; do :; done
    printf "Apply? [y/N]: "
    read -k 1 response
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
      chezmoi update && echo "\033[1;32m✓ Dotfiles updated\033[0m"
    fi
    echo ""
  fi

  popd -q
  trap - INT TERM
}

dotsync() { _dotfiles_sync --force; }

_dotfiles_sync
