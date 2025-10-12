SESSION="edit sessions"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$SESSION"
    else
        tmux attach -t "$SESSION"
    fi
    exit 0
fi

tmux new-session -d -s "$SESSION" -c ~/tmux/ -n "nvim"
tmux send-keys -t "$SESSION":"nvim" 'nvim .' C-m

tmux select-window -t "$SESSION":"nvim"
if [ -n "$TMUX" ]; then
    tmux switch-client -t "$SESSION"
else
    tmux attach -t "$SESSION"
fi
