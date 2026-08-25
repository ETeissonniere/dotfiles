function fish_right_prompt --description 'Show the duration of slower commands'
    set -q CMD_DURATION; or return
    test "$CMD_DURATION" -ge 2000; or return

    set_color 8a9199
    if test "$CMD_DURATION" -ge 60000
        printf 'took %dm %.1fs' (math -s0 "$CMD_DURATION / 60000") (math -s1 "$CMD_DURATION % 60000 / 1000")
    else
        printf 'took %.1fs' (math -s1 "$CMD_DURATION / 1000")
    end
    set_color normal
end
