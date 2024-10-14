# Load system zshrc if present
ZSH_RC="/etc/zshrc"
if [ -f $ZSH_RC ]; then
    source $ZSH_RC
fi

typeset -U path PATH
path=(~/.local/bin $path)
path=(~/.dotfiles/bin $path)

# If running on Mac OS, ensure we properly load our SSH keys and init the terminal
if [[ "$OSTYPE" == "darwin"* ]]; then
  export EDITOR="code --wait"
  export GOPATH=~/Developer/.gopath

  path=(/opt/homebrew/bin $path)

  if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    function chpwd {
      printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
    }
    chpwd
  fi

  function init_ssh {
    # if ssh-agent is not running, start it
    if ! pgrep -q ssh-agent; then
      eval "$(ssh-agent -s)"
    fi
    # ensure we load the keychain
    ssh-add --apple-load-keychain
  }
  # We disown the function call so that no pesky logs show up in the terminal
  init_ssh > /dev/null 2>&1 &!
else
  export EDITOR="vim"
fi

export PATH

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# Common environment variables
export CLICOLOR=1
# Make folders cyan instead of blue as it renders better on a terminal with semi-transparent background
export LSCOLORS=gxfxcxdxbxegedabagacad
# Converted via https://geoff.greer.fm/lscolors/
export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# Add commands to history and enable extended globbing
setopt appendhistory extendedglob
# No beep sound
unsetopt beep
# Configure completion
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true # find new binaries as they are installed
zstyle :compinstall filename /Users/`whoami`/.zshrc

# Key bindings, EMACS mode. Cursor by move on a per word basis
bindkey -e
bindkey '[C' forward-word
bindkey '[D' backward-word

# Auto completion - with tabs and bash compatibility
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Aliases
alias dotedit="cd ~/.dotfiles && $EDITOR ."
alias dotup="zsh -c \"cd ~/.dotfiles && git pull\""

# if zoxide is installed, init and override cd
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

# if exa is installed, override ls
if command -v eza &> /dev/null; then
  alias ls="eza"
fi

# if fzf is installed, set it up
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

# Ensure we can obtain VCS/Git infos in prompt later on
autoload -Uz vcs_info
precmd() {
  vcs_info
}
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "[%b]"
zstyle ':vcs_info:git*' actionformats "[%b (%a)]"
# Prompt styling
setopt prompt_subst
# Left `username on hostname in directory (status) # `
PROMPT='%F{81}%n%f %F{247}on%f %F{39}%m%f %F{247}in%f %F{161}%2~%f %F{228}${vcs_info_msg_0_}%f
%(?.%F{76}√%f.%F{196}%?%f) → '
# Blinking cursor
echo -e -n "\x1b[\x31 q"
