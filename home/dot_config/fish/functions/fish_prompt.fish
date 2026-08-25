function fish_prompt --description 'A compact Ayu Mirage prompt'
    set -l last_status $status

    if set -q SSH_TTY; or set -q SSH_CONNECTION
        set_color 242936 --background=f28779
        printf ' remote '
        set_color normal
        printf ' '
    end

    set_color 73d0ff
    printf '%s' (prompt_pwd --dir-length=0)
    set_color normal
    fish_vcs_prompt
    printf ' '

    if test $last_status -eq 0
        set_color d5ff80 --bold
    else
        set_color f28779 --bold
    end
    printf '→ '
    set_color normal
end
