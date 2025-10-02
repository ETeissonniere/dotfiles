# Linux-specific Zsh customisations.

if command -v ssh-agent >/dev/null 2>&1; then
  if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
  fi
fi
