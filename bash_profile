eval "$(hub alias -s)"

export DOTFILES_DIR=.dotfiles

export PATH=$PATH:/Users/`whoami`/$DOTFILES_DIR/bin
export PATH=$PATH:/usr/local/opt/go/libexec/bin
export PATH=$PATH:/Users/`whoami`/go/bin

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export PS1="\[\e[32m\]\u@\[\e[32m\]\h \[\e[36m\]\W \[\e[31m\]\$? \[\e[1m\]\[\e[33m\]$ \[\e[0m\]"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
