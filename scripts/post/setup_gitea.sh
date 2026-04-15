#!/usr/bin/env bash
# Configure tea (Gitea CLI) for a self-hosted Gitea instance and register
# ~/.ssh/id_ed25519.pub on the same instance for git push/pull and signing.
#
# Generate a personal access token first: Settings → Applications →
# Generate New Token. Required scopes: write:user, write:public_key.
#
# Re-runnable per instance.
set -euo pipefail

command -v tea  >/dev/null 2>&1 || { echo "tea CLI not installed" >&2; exit 1; }
command -v jq   >/dev/null 2>&1 || { echo "jq not installed"      >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl not installed"    >&2; exit 1; }

KEY_PATH="$HOME/.ssh/id_ed25519"
[[ -f "$KEY_PATH.pub" ]] || { echo "No public key at $KEY_PATH.pub" >&2; exit 1; }

read -r  -p "Gitea URL (e.g. https://gitea.example.com): " url
read -r  -p "Gitea username: "                              user
read -rs -p "Gitea API token: "                             token
echo
[[ -n "$url" && -n "$user" && -n "$token" ]] || { echo "URL, username, and token are all required" >&2; exit 1; }

url="${url%/}"  # drop trailing slash
host="${url#http*://}"
login_name="$user@$host"

echo "==> Adding tea login '$login_name'"
tea login add --name "$login_name" --url "$url" --user "$user" --token "$token"

# Compare keys by base64 data only — Gitea returns the stored key with type
# prefix, and pasting via the web UI may include or strip the comment.
title="$(hostname)"
pub_key_data="$(awk '{print $2}' "$KEY_PATH.pub")"
pub_key_full="$(<"$KEY_PATH.pub")"

existing="$(curl -fsS "$url/api/v1/user/keys" \
                 -H "Authorization: token $token" \
            | jq -r '.[].key | split(" ")[1]' 2>/dev/null || true)"

if grep -qFx "$pub_key_data" <<<"$existing"; then
  echo "==> SSH key already registered on $url"
else
  curl -fsS -X POST "$url/api/v1/user/keys" \
       -H "Authorization: token $token" \
       -H "Content-Type: application/json" \
       -d "$(jq -n --arg t "$title" --arg k "$pub_key_full" '{title: $t, key: $k}')" \
       >/dev/null
  echo "==> Registered SSH key on $url as '$title'"
fi
