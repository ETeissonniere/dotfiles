#!/usr/bin/env bash
# Register ~/.ssh/id_ed25519.pub on GitHub as both an authentication and a
# signing key. Requires gh to already be authenticated. Idempotent — safe to
# re-run; keys that are already registered are skipped.
set -euo pipefail

KEY_PATH="$HOME/.ssh/id_ed25519"
[[ -f "$KEY_PATH.pub" ]] || { echo "No public key at $KEY_PATH.pub" >&2; exit 1; }

command -v gh >/dev/null 2>&1 || { echo "gh CLI not installed" >&2; exit 1; }

if ! gh auth status >/dev/null 2>&1; then
  cat >&2 <<'EOF'
gh is not authenticated. First run:
  gh auth login -h github.com -p ssh -s admin:public_key -s admin:ssh_signing_key
EOF
  exit 1
fi

# Belt-and-suspenders in case the existing auth was created without key scopes
gh auth refresh -h github.com -s admin:public_key -s admin:ssh_signing_key 2>/dev/null || true

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
