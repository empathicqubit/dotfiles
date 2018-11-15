#! /bin/bash

function tmux() {
    if [[ $# -eq 0 ]] ; then
        command tmux new-session \; new-window \; new-window \; new-window \; new-window \; new-window
    else
        command tmux "$@"
    fi
}

tmxsync () {
   export _TMUX_SYNC=1;
   for w in $(tmux lsw -F '#{window_index}#{window_active}'|sed -ne 's/0$//p'); do
      tmux joinp -d -b -s $w -v -t $(tmux lsp -F '#{pane_index}'|tail -n 1)
   done
   tmux setw synchronize-panes
}
tmxunsync () {
   [ -z "$_TMUX_SYNC" ] && return
   for p in $(tmux lsp -F '#{pane_index}#{pane_active}' | sed -ne 's/0$//p'); do
      tmux breakp -d -t 1
   done
   unset _TMUX_SYNC
   tmux setw synchronize-panes
}
