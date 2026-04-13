#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

KEY_PATH="$HOME/.ssh/id_ed25519"

ensure_dir "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Generate ed25519 key if missing
if [[ -f "$KEY_PATH" ]]; then
  log_info "SSH key already exists at $KEY_PATH"
else
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "DRY RUN: would generate ed25519 key at $KEY_PATH"
  else
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "$(whoami)@$(hostname)"
    log_info "Generated ed25519 key at $KEY_PATH"
  fi
fi

# Register key on GitHub via gh CLI
if ! command -v gh >/dev/null 2>&1; then
  log_warn "gh CLI not found; skipping GitHub key registration"
  exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
  log_warn "Not authenticated with GitHub CLI"
  log_warn "Run 'gh auth login' then re-run bootstrap to register your SSH key"
  exit 0
fi

# Ensure we have the required scopes for SSH key management
gh auth refresh -h github.com -s admin:public_key -s admin:ssh_signing_key 2>/dev/null || true

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "DRY RUN: would register SSH key on GitHub"
  exit 0
fi

key_title="$(hostname)"
pub_key="$(cat "$KEY_PATH.pub")"

# Check if key is already registered (by matching the public key content)
existing_keys="$(gh ssh-key list 2>/dev/null || true)"

if echo "$existing_keys" | grep -qF "$pub_key"; then
  log_info "SSH key already registered on GitHub"
else
  gh ssh-key add "$KEY_PATH.pub" --type authentication --title "$key_title"
  log_info "Registered SSH authentication key on GitHub as '$key_title'"
fi

# Check and register signing key separately
existing_signing="$(gh api user/ssh_signing_keys --jq '.[].key' 2>/dev/null || true)"

if echo "$existing_signing" | grep -qF "$pub_key"; then
  log_info "SSH signing key already registered on GitHub"
else
  gh ssh-key add "$KEY_PATH.pub" --type signing --title "$key_title signing"
  log_info "Registered SSH signing key on GitHub as '$key_title signing'"
fi
