#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
total_input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

total_tokens=$((total_input_tokens + total_output_tokens))
if [[ $context_window_size -gt 0 ]]; then
    percentage=$((total_tokens * 100 / context_window_size))
    [[ $percentage -gt 100 ]] && percentage=100

    bar_width=15
    filled=$((percentage * bar_width / 100))

    bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<bar_width-filled; i++)); do bar+="░"; done

    context_info=$(printf "%s %3d%%" "$bar" "$percentage")
else
    context_info="░░░░░░░░░░░░░░░ N/A"
fi

git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null || echo "detached")

    status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    staged=$(echo "$status" | grep -c "^[MADRC]" || echo "0")
    modified=$(echo "$status" | grep -c "^.M" || echo "0")
    untracked=$(echo "$status" | grep -c "^??" || echo "0")

    git_info="$branch"
    [[ $staged -gt 0 ]] && git_info+=" +$staged"
    [[ $modified -gt 0 ]] && git_info+=" ~$modified"
    [[ $untracked -gt 0 ]] && git_info+=" ?$untracked"
fi

printf "\033[33m%s\033[0m | \033[36m%s\033[0m | \033[32m%s\033[0m" "$model_name" "$context_info" "$git_info"
