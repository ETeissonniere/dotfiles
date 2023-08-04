# Load system zshrc if present
ZSH_RC="/etc/zshrc"
if [ -f $ZSH_RC ]; then
    source $ZSH_RC
fi

# If running in the Apple Terminal, ensure new tabs
# open in the same directory than the current shell.
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  function chpwd {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
  }
  chpwd
fi

# If running on Mac OS, ensure we properly load our SSH keys
if [[ "$OSTYPE" == "darwin"* ]]; then
  function init_ssh {
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain
  }
  init_ssh > /dev/null 2>&1
fi

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# Add commands to history and enable extended globbing
setopt appendhistory extendedglob
# No beep sound
unsetopt beep
# Configure completion
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle :compinstall filename /Users/`whoami`/.zshrc

# Key bindings, EMACS mode. Cursor by move on a per word basis
bindkey -e
bindkey '[C' forward-word
bindkey '[D' backward-word

# Auto completion - with tabs and bash compatibility
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Common environment variables
export CLICOLOR=1
export EDITOR="code --wait"
# PATH adjustments
# Homebrew binaries will shadow system binaries. This is intended.
export PATH=/opt/homebrew/bin:$PATH

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
PROMPT='%F{cyan}%n%f %F{white}on%f %F{blue}%m%f %F{white}in%f %F{magenta}%2~%f %F{yellow}${vcs_info_msg_0_}%f
%(?.%F{green}√%f.%F{red}%?%f) → '
# Blinking cursor
echo -e -n "\x1b[\x31 q"