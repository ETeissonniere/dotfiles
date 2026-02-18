# Linux-specific Zsh customisations.

if [[ -d /home/linuxbrew/.linuxbrew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Refresh SSH_AUTH_SOCK from tmux session environment when inside tmux.
# After detach/reconnect/reattach, existing panes keep a stale socket path;
# this hook picks up the current one before every prompt.
if [[ -n "$TMUX" ]]; then
  _refresh_ssh_auth_sock() {
    local new_sock
    new_sock=$(tmux show-environment SSH_AUTH_SOCK 2>/dev/null | sed -n 's/^SSH_AUTH_SOCK=//p')
    if [[ -n "$new_sock" && "$new_sock" != "$SSH_AUTH_SOCK" ]]; then
      export SSH_AUTH_SOCK="$new_sock"
    fi
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _refresh_ssh_auth_sock
fi

# Only start a local ssh-agent when there's no socket at all AND we're not
# in an SSH session (where agent forwarding is expected).
if command -v ssh-agent >/dev/null 2>&1; then
  if [[ -z "$SSH_AUTH_SOCK" && -z "$SSH_CONNECTION" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
  fi
fi
