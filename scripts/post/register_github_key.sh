#!/usr/bin/env bash
# Register ~/.ssh/id_ed25519.pub on GitHub as both an authentication and a
# signing key. Handles `gh auth login` / `gh auth refresh` itself — no
# prerequisite setup needed beyond the key existing. Idempotent on re-run.
set -euo pipefail

KEY_PATH="$HOME/.ssh/id_ed25519"
[[ -f "$KEY_PATH.pub" ]] || { echo "No public key at $KEY_PATH.pub" >&2; exit 1; }

command -v gh >/dev/null 2>&1 || { echo "gh CLI not installed" >&2; exit 1; }

# Consider gh "ready" only if authed AND the current token carries the scopes
# we need. Otherwise we'd hit a scope error on `gh ssh-key add`.
gh_ready() {
  local status
  status="$(gh auth status 2>&1)" || return 1
  grep -q admin:public_key      <<<"$status" || return 1
  grep -q admin:ssh_signing_key <<<"$status" || return 1
}

if ! gh_ready; then
  if gh auth status >/dev/null 2>&1; then
    echo "==> Existing gh session is missing key-management scopes — refreshing"
    gh auth refresh -h github.com -s admin:public_key -s admin:ssh_signing_key
  else
    echo "==> Authenticating with GitHub"
    gh auth login --hostname github.com --git-protocol ssh \
                  -s admin:public_key -s admin:ssh_signing_key
  fi
fi

title="$(hostname)"
pub_key="$(<"$KEY_PATH.pub")"

register_if_missing() {
  local type="$1" label="$2" existing
  case "$type" in
    authentication) existing="$(gh ssh-key list 2>/dev/null || true)" ;;
    signing)        existing="$(gh api user/ssh_signing_keys --jq '.[].key' 2>/dev/null || true)" ;;
  esac
  if echo "$existing" | grep -qF "$pub_key"; then
    echo "==> SSH $type key already registered"
  else
    gh ssh-key add "$KEY_PATH.pub" --type "$type" --title "$label"
    echo "==> Registered SSH $type key on GitHub as '$label'"
  fi
}

register_if_missing authentication "$title"
register_if_missing signing        "$title signing"
