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
ZSH_RC="/etc/zshrc"
ZSH_SUGGESTIONS="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [ -f $ZSH_RC ]; then
    source $ZSH_RC
fi
if [ -f $ZSH_SUGGESTIONS ]; then
    source $ZSH_SUGGESTIONS
fi

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

# Various environment variables
export CLICOLOR=1
export EDITOR=code
export GOPATH=$HOME/.go

# PATH specifics
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"

# Prompt
eval "$(starship init zsh)"

# SSH agent compat
eval "$(ssh-agent)"
export SSH_AUTH_SOCK="~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# end
autoload -U +X bashcompinit && bashcompinit
