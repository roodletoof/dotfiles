SESSION_FILE=$(ls "$HOME/tmux" | fzf)
if [ -n "$SESSION_FILE" ]; then
    sh "$HOME/tmux/$SESSION_FILE"
fi
