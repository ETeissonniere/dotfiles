#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
transcript_path=$(echo "$input" | jq -r '.transcript_path')
model_name=$(echo "$input" | jq -r '.model.display_name')

if [[ -f "$transcript_path" ]]; then
    char_count=$(wc -c < "$transcript_path" 2>/dev/null || echo "0")
    token_estimate=$((char_count / 4))
    max_tokens=200000
    percentage=$((token_estimate * 100 / max_tokens))
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
