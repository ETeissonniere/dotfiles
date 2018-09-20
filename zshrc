export ZSH="/Users/eliott/.oh-my-zsh"

ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE=true

plugins=(
  git
  docker
)

source $ZSH/oh-my-zsh.sh

export CLICOLOR=1   # I want colorZ
export EDITOR=vim   # VIM!

alias battery='pmset -g batt | egrep "([0-9]+\%).*" -o'

alias ls='ls -Ghl'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
