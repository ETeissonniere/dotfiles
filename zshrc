HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob
unsetopt beep
bindkey -e

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle :compinstall filename '/Users/eliottteissonniere/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# System zshrc for various things.
source /etc/zshrc
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Open new tabs in same directory
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  function chpwd {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
  }
  chpwd
fi

# Correct key mappings
bindkey -e
bindkey '[C' forward-word
bindkey '[D' backward-word

# GPG / SSH
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# Various environment variables
export CLICOLOR=1
export EDITOR=vim
export GOPATH=$HOME/.go
export ORIGIN_SDK_PATH=/Users/eliottteissonniere/Documents/Work/Ledger/OriginSDK_0_1_0_Darwin

# PATH specifics
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/usr/local/MacGPG2/bin
export PATH=$PATH:$HOME/.radicle/bin
export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Prompt
eval "$(starship init zsh)"

alias ish="arch --x86_64 zsh"
alias ibrew="arch --x86_64 /usr/local/bin/brew"

# SSH agent compat
eval "$(ssh-agent)"
autoload -U +X bashcompinit && bashcompinit
if [[ -x /usr/local/bin/monk ]]; then complete -o nospace -C /usr/local/bin/monk monk; fi
