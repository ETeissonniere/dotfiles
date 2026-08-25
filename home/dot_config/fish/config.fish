# Paths and editor defaults shared by interactive and non-interactive shells.
fish_add_path --prepend "$HOME/.local/bin"

if test (uname) = Darwin
    fish_add_path --prepend /opt/homebrew/bin
end

if type -q zed
    set -gx EDITOR 'zed --wait'
    set -gx VISUAL 'zed --wait'
else
    set -gx EDITOR vim
    set -gx VISUAL vim
end

status is-interactive; or return

# Keep Fish's native searchable history pager on Ctrl-R.
bind ctrl-r history-pager

# Ayu Mirage syntax and completion colors.
set -g fish_color_normal cccac2
set -g fish_color_command 5ccfe6
set -g fish_color_keyword dfbfff
set -g fish_color_quote d5ff80
set -g fish_color_redirection dfbfff
set -g fish_color_end dfbfff
set -g fish_color_error f28779
set -g fish_color_param cccac2
set -g fish_color_comment 8a9199
set -g fish_color_selection --background=3b4261
set -g fish_color_search_match --background=3b4261
set -g fish_color_operator ffad66
set -g fish_color_escape f28779
set -g fish_color_autosuggestion 8a9199
set -g fish_pager_color_progress 8a9199
set -g fish_pager_color_prefix 73d0ff --bold
set -g fish_pager_color_completion cccac2
set -g fish_pager_color_description 8a9199
set -g fish_pager_color_selected_background --background=3b4261

# Include useful repository state in the native Fish VCS prompt.
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showstashstate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showupstream informative
set -g __fish_git_prompt_color_branch d5ff80
set -g __fish_git_prompt_color_dirtystate f28779
set -g __fish_git_prompt_color_invalidstate f28779
set -g __fish_git_prompt_color_stagedstate ffcc66
set -g __fish_git_prompt_color_untrackedfiles f28779
set -g __fish_git_prompt_color_upstream 8a9199

if type -q zoxide
    zoxide init --cmd cd fish | source
end

if type -q eza
    abbr --add --global ls 'eza --icons=auto --hyperlink=auto'
    abbr --add --global ll 'eza -lh --group-directories-first --icons=auto --hyperlink=auto'
    abbr --add --global la 'eza -a --group-directories-first --icons=auto --hyperlink=auto'
end
