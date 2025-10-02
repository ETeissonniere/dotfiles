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

# Key bindings.
bindkey -e
bindkey '[C' forward-word
bindkey '[D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word

# Completion and bash compatibility.
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Optional tooling.
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
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
PROMPT='%F{81}%n%f %F{247}on%f %F{39}%m%f %F{247}in%f %F{161}%2~%f %F{228}${vcs_info_msg_0_}%f
%(?.%F{76}√%f.%F{196}%?%f) → '

printf '\033[1 q'
