#!/usr/bin/env bash
# Set up a tea (Gitea CLI) login. Interactive — tea prompts for the
# instance URL, your username, and a personal access token. Generate
# the token on your Gitea instance: Settings → Applications →
# Generate New Token (give it `repo` and `notification` scopes).
#
# Re-run this script to add additional Gitea instances.
set -euo pipefail

command -v tea >/dev/null 2>&1 || { echo "tea CLI not installed" >&2; exit 1; }

existing="$(tea login list 2>/dev/null || true)"
if [[ -n "$existing" ]]; then
  echo "==> Existing tea logins:"
  echo "$existing"
  echo ""
fi

echo "==> Adding tea login"
tea login add
