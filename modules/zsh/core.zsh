# Base Zsh configuration shared across platforms.

# Deduplicate PATH entries and add user bin directories.
typeset -U path PATH
path=($HOME/.local/bin $path)

export PATH

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000

# Common environment variables.
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

setopt appendhistory extendedglob
unsetopt beep

# Completion configuration.
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle :compinstall filename "$HOME/.zshrc"

# Completion and bash compatibility.
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

if command -v zoxide >/dev/null 2>&1 && [[ -z "${CLAUDECODE:-}" ]]; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
fi

if command -v fdfind >/dev/null 2>&1 && [[ -z "${CLAUDECODE:-}" ]]; then
  alias find="fdfind"
fi

if command -v fd >/dev/null 2>&1 && [[ -z "${CLAUDECODE:-}" ]]; then
  alias find="fd"
fi

if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    for script in /usr/share/doc/fzf/examples/key-bindings.zsh \
                 /usr/share/fzf/shell/key-bindings.zsh \
                 "$HOME/.fzf/shell/key-bindings.zsh"; do
      if [[ -r "$script" ]]; then
        source "$script"
        break
      fi
    done
    for script in /usr/share/doc/fzf/examples/completion.zsh \
                 /usr/share/fzf/shell/completion.zsh \
                 "$HOME/.fzf/shell/completion.zsh"; do
      if [[ -r "$script" ]]; then
        source "$script"
        break
      fi
    done
  fi
fi

if command -v rg >/dev/null 2>&1 && [[ -z "${CLAUDECODE:-}" ]]; then
  alias grep="rg"
fi

if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

if command -v uvx >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion zsh)"
fi

# Editor preference: favour VS Code when available.
if command -v code >/dev/null 2>&1; then
  export EDITOR="code --wait"
elif [[ "${VSCODE_INJECTION:-0}" == "1" ]]; then
  export EDITOR="code --wait"
else
  export EDITOR="vim"
fi

# VCS prompt integration.
autoload -Uz vcs_info

precmd() {
  vcs_info
}
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "[%b]"
zstyle ':vcs_info:git*' actionformats "[%b (%a)]"

setopt prompt_subst

if [[ -z ${PROMPT_REMOTE_LABEL-} ]]; then
  if [[ -n ${SSH_CONNECTION:-} || -n ${SSH_TTY:-} ]]; then
    PROMPT_REMOTE_LABEL='%F{244}[ %K{196}%F{231} remote %f%k%F{244} ]%f'
  fi
fi

PROMPT='%F{81}%n%f %F{247}on%f %F{39}%m%f${PROMPT_PLATFORM_LABEL:+ ${PROMPT_PLATFORM_LABEL}}${PROMPT_REMOTE_LABEL:+ ${PROMPT_REMOTE_LABEL}} %F{247}in%f %F{161}%2~%f %F{228}${vcs_info_msg_0_}%f
%(?.%F{76}√%f.%F{196}%?%f) → '
RPROMPT='${RPROMPT_PLATFORM_LABEL}'

printf '\033[1 q'
