SESSION=$(tmux ls -F "#{session_name}" | gum filter --limit 1)

if [ -n "${TMUX+x}" ]; then
    tmux switch -t "$SESSION"
else
    tmux attach -t "$SESSION"
fi

