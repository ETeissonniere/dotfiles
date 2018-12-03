eval "$(hub alias -s)"

export PATH=$PATH:/usr/local/opt/go/libexec/bin
export PATH=$PATH:/Users/`whoami`/go/bin

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export PS1="\[\033[38;5;10m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;4m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;3m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;1m\]\$?\[$(tput sgr0)\]\[\033[38;5;15m\]\n\\$ \[$(tput sgr0)\]"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
