function fish_greeting --description 'Show a compact welcome in top-level local terminals'
    if set -q FISH_GREETING_SHOWN; or set -q TMUX; or set -q SSH_TTY; or set -q SSH_CONNECTION
        return
    end
    set -gx FISH_GREETING_SHOWN 1

    if type -q fastfetch
        fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
    end
end
