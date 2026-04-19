#!/usr/bin/env bash
# Configure tea (Gitea CLI) for a self-hosted Gitea instance using SSH-based
# authentication. Prints copy-paste-ready values for Gitea's SSH key settings
# page and waits for you to register the key, then runs `tea login add` with
# --ssh-agent-key so no API token is ever created or stored.
#
# Re-runnable per instance.
set -euo pipefail

command -v tea     >/dev/null 2>&1 || { echo "tea CLI not installed" >&2; exit 1; }
command -v ssh-add >/dev/null 2>&1 || { echo "ssh-add not installed" >&2; exit 1; }

KEY_PATH="$HOME/.ssh/id_ed25519"
[[ -f "$KEY_PATH.pub" ]] || { echo "No public key at $KEY_PATH.pub" >&2; exit 1; }

read -r -p "Gitea URL (e.g. https://gitea.example.com): " url
read -r -p "Gitea username: "                              user
[[ -n "$url" && -n "$user" ]] || { echo "URL and username are required" >&2; exit 1; }

# Normalize URL: add https:// if no scheme, drop trailing slash.
[[ "$url" =~ ^https?:// ]] || url="https://$url"
url="${url%/}"
host="${url#http*://}"
login_name="$user@$host"

title="$(hostname)"
pub_key="$(<"$KEY_PATH.pub")"

cat <<EOF

==> Register this SSH key on $host before continuing:

    Page:  $url/user/settings/keys
    Title: $title
    Key:   $pub_key

EOF
read -r -p "Press Enter once the key is saved... " _

# tea --ssh-agent-key proves key ownership via ssh-agent, so the agent must be
# running with our key loaded.
if ! ssh-add -l >/dev/null 2>&1; then
  echo "==> Starting ssh-agent"
  eval "$(ssh-agent -s)" >/dev/null
fi

fingerprint="$(ssh-keygen -lf "$KEY_PATH.pub" | awk '{print $2}')"
if ! ssh-add -l 2>/dev/null | grep -qF "$fingerprint"; then
  ssh-add "$KEY_PATH"
fi

echo "==> Adding tea login '$login_name' via SSH"
tea login add \
  --name "$login_name" \
  --url "$url" \
  --user "$user" \
  --ssh-agent-key "$fingerprint"
