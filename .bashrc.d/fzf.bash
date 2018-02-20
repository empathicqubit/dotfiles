#! /bin/bash
# Setup fzf
# ---------
if [[ ! "$PATH" == */$HOME/.vim/plugged/fzf/bin* ]]; then
  export PATH="$PATH:$HOME/.vim/plugged/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.vim/plugged/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.vim/plugged/fzf/shell/key-bindings.bash"

